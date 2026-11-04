import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../client/retry_after.dart';
import '../errors/exceptions.dart';
import '../utils/monitoring_error_redaction.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Mixin that adds streaming capabilities to a [ResourceBase].
///
/// Provides [sendStream] for making SSE streaming requests with
/// request-scoped abort support and cleanup on completion, error, and
/// subscription cancellation.
mixin StreamingResource on ResourceBase {
  /// Sends a streaming request with request-scoped transport cancellation.
  ///
  /// A configured [streamClientFactory] creates an owned client
  /// when [abortTrigger] is supplied. Otherwise the shared client is borrowed
  /// and is never closed by a streaming request.
  ///
  /// Streaming requests bypass interceptors and are not retried. Transport
  /// cancellation requires support from the supplied HTTP client.
  Future<http.StreamedResponse> sendStream({
    required http.BaseRequest request,
    String? jsonBody,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) => _sendStream(
    request: request,
    jsonBody: jsonBody,
    additionalHeaders: additionalHeaders,
    abortTrigger: abortTrigger,
    useDedicatedClient: abortTrigger != null && streamClientFactory != null,
  );

  Future<http.StreamedResponse> _sendStream({
    required http.BaseRequest request,
    String? jsonBody,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
    required bool useDedicatedClient,
  }) async {
    ensureNotClosed?.call();
    request.headers.addAll(
      request is http.MultipartRequest
          ? requestBuilder.buildMultipartHeaders(
              additionalHeaders: {
                ...?additionalHeaders,
                'Accept': 'text/event-stream',
              },
            )
          : requestBuilder.buildStreamingHeaders(
              additionalHeaders: additionalHeaders,
            ),
    );
    if (jsonBody != null) {
      if (request is! http.Request) {
        throw ArgumentError('jsonBody requires http.Request');
      }
      request.body = jsonBody;
    }
    Logger('OpenAIClient').fine('Streaming ${request.method} ${request.url}');

    final transport = useDedicatedClient ? streamClientFactory!() : httpClient;
    var closed = false;
    var aborted = false;
    void closeClient() {
      if (useDedicatedClient && !closed) {
        closed = true;
        transport.close();
      }
    }

    final nativeAbort = Completer<void>();
    void abort() {
      aborted = true;
      if (!nativeAbort.isCompleted) nativeAbort.complete();
      closeClient();
    }

    unawaited(
      abortTrigger?.then((_) => abort(), onError: (Object _) => abort()),
    );
    if (request is http.Abortable) {
      unawaited(
        request.abortTrigger?.then(
          (_) => abort(),
          onError: (Object _) => abort(),
        ),
      );
    }

    try {
      // Let an already completed abort trigger prevent dispatch entirely.
      await Future<void>.value();
      if (aborted) {
        throw const AbortedException(stage: AbortionStage.duringStream);
      }
      final response = await transport.send(
        _abortableRequest(request, nativeAbort.future),
      );
      if (aborted) {
        await response.stream.listen(null).cancel();
        throw const AbortedException(stage: AbortionStage.duringStream);
      }
      if (!useDedicatedClient) return response;

      StreamSubscription<List<int>>? subscription;
      late StreamController<List<int>> controller;
      var ended = false;
      void finish([Object? error, StackTrace? stackTrace]) {
        if (ended) return;
        ended = true;
        if (error != null) controller.addError(error, stackTrace);
        closeClient();
        subscription?.cancel().ignore();
        unawaited(controller.close());
      }

      controller = StreamController<List<int>>(
        onListen: () {
          subscription = response.stream.listen(
            controller.add,
            onError: finish,
            onDone: finish,
          );
        },
        onPause: () => subscription?.pause(),
        onResume: () => subscription?.resume(),
        onCancel: () {
          ended = true;
          closeClient();
          subscription?.cancel().ignore();
        },
      );
      return http.StreamedResponse(
        controller.stream,
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (_) {
      closeClient();
      if (aborted) {
        throw AbortedException(
          stage: AbortionStage.duringStream,
          correlationId: request.headers['X-Request-ID'],
        );
      }
      rethrow;
    }
  }

  /// Parses an error response from a streaming request.
  ApiException parseStreamError(
    int statusCode,
    String body,
    String requestId, {
    Map<String, String> headers = const {},
    Object? cause,
  }) {
    final retryAfter = parseRetryAfter(headers);
    String message;
    String? type;
    String? code;
    String? param;
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
      if (json['error'] case final Map<String, dynamic> error) {
        message = error['message'] == null
            ? 'Unknown error'
            : _errorString(error['message']) ?? body;
        type = _errorString(error['type']);
        code = _errorString(error['code']);
        param = _errorString(error['param']);
      } else {
        message = _errorString(json['message']) ?? body;
      }
    } catch (_) {
      message = body.isNotEmpty ? body : 'HTTP $statusCode error';
    }
    return createApiException(
      statusCode: statusCode,
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: json,
      retryAfter: retryAfter,
      cause: cause,
    );
  }

  /// Helper to create a streaming POST request with a JSON body.
  ///
  /// Returns the [http.StreamedResponse] with proper error checking.
  Future<http.StreamedResponse> sendStreamRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? queryParams,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    final url = requestBuilder.buildUrl(endpoint, queryParams: queryParams);
    final request = http.Request('POST', url);

    return sendStream(
      request: request,
      jsonBody: jsonEncode(body),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Streams SSE events from a streaming POST request.
  ///
  /// Yields parsed JSON maps from Server-Sent Events. Handles error
  /// responses (status >= 400) by throwing appropriate [ApiException]s.
  Stream<Map<String, dynamic>> streamSseEvents({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? queryParams,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    return _streamSseEvents(
      () => http.Request(
        'POST',
        requestBuilder.buildUrl(endpoint, queryParams: queryParams),
      ),
      jsonBody: () => jsonEncode(body),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Streams SSE events from a pre-built request, including multipart bodies.
  Stream<Map<String, dynamic>> streamSseEventsForRequest({
    required http.BaseRequest request,
    Future<void>? abortTrigger,
  }) => _streamSseEvents(() => request, abortTrigger: abortTrigger);

  Stream<Map<String, dynamic>> _streamSseEvents(
    http.BaseRequest Function() buildRequest, {
    String Function()? jsonBody,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    final nativeAbort = Completer<void>();
    StreamSubscription<Map<String, dynamic>>? subscription;
    late StreamController<Map<String, dynamic>> controller;
    var ended = false;

    void cleanup({required bool abort}) {
      if (abort && !nativeAbort.isCompleted) nativeAbort.complete();
      // Local termination must not wait for a custom transport's cleanup.
      subscription?.cancel().ignore();
    }

    void finish([Object? error, StackTrace? stackTrace]) {
      if (ended) return;
      ended = true;
      if (error != null) controller.addError(error, stackTrace);
      cleanup(abort: error != null);
      unawaited(controller.close());
    }

    Future<void> run() async {
      try {
        // Register cancellation before starting authentication/header building.
        await Future<void>.value();
        if (ended) return;
        final response = await _sendStream(
          request: buildRequest(),
          jsonBody: jsonBody?.call(),
          additionalHeaders: additionalHeaders,
          abortTrigger: nativeAbort.future,
          useDedicatedClient:
              abortTrigger != null && streamClientFactory != null,
        );
        if (ended) {
          await response.stream.listen(null).cancel();
          return;
        }
        final requestId =
            response.headers['x-request-id'] ??
            response.request?.headers['X-Request-ID'] ??
            'unknown';
        Stream<Map<String, dynamic>> events;
        if (response.statusCode >= 400) {
          final body = StringBuffer();
          events = response.stream
              .transform(utf8.decoder)
              .transform(
                StreamTransformer<String, Map<String, dynamic>>.fromHandlers(
                  handleData: (data, sink) => body.write(data),
                  handleDone: (sink) {
                    sink
                      ..addError(
                        parseStreamError(
                          response.statusCode,
                          body.toString(),
                          requestId,
                          headers: response.headers,
                        ),
                      )
                      ..close();
                  },
                ),
              );
        } else {
          events = const SseParser().parse(response.stream);
        }
        subscription = events.listen(
          controller.add,
          onError: finish,
          onDone: finish,
        );
        if (controller.isPaused) subscription!.pause();
      } catch (error, stackTrace) {
        finish(error, stackTrace);
      }
    }

    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        void abort() =>
            finish(const AbortedException(stage: AbortionStage.duringStream));
        unawaited(
          abortTrigger?.then((_) => abort(), onError: (Object _) => abort()),
        );
        unawaited(run());
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        final abort = !ended;
        ended = true;
        cleanup(abort: abort);
      },
    );
    return controller.stream;
  }

  /// Checks for inline errors in SSE stream data and throws
  /// [StreamException] if found.
  ///
  /// Detects two error patterns:
  /// 1. SSE `event: error` — parser sets `_event: "error"` in the JSON map
  /// 2. Error objects in data — from providers like AWS Bedrock that embed
  ///    errors in HTTP 200 SSE responses
  ///
  /// Supports multiple error formats:
  /// - Standard OpenAI: `{"error": {"message": "...", "type": "..."}}`
  /// - AWS Bedrock: `{"error": {"error": "...", "error_code": 4001}}`
  /// - Plain string: `{"error": "Something went wrong"}`
  ///
  /// This is intentionally NOT called from [streamSseEvents] because some
  /// resources (e.g., Responses API) handle `ErrorEvent` as a normal stream
  /// event rather than as an exception.
  Never throwInlineStreamError(
    Map<String, dynamic> json,
    String? sseEvent,
    Object? error,
  ) {
    String message;
    if (error is Map<String, dynamic>) {
      message = (error['message'] ?? error['error'] ?? 'Unknown stream error')
          .toString();
    } else if (error is String) {
      message = error;
    } else if (sseEvent == 'error') {
      message = (json['_rawData'] as String?) ?? 'Stream error event received';
    } else {
      message = 'Unknown stream error';
    }

    Logger('OpenAIClient').warning(
      'Inline stream error: ${redactMonitoringErrorValue(message, json)}',
    );

    // Strip internal `_event` field and encode as JSON for partialData
    final cleanJson = Map<String, dynamic>.from(json)
      ..remove('_event')
      ..remove('_rawData');
    throw StreamException(message: message, partialData: jsonEncode(cleanJson));
  }
}

String? _errorString(Object? value) => value is String ? value : null;

/// Adds cancellation without buffering streamed or multipart request bodies.
http.BaseRequest _abortableRequest(
  http.BaseRequest source,
  Future<void> abortTrigger,
) {
  final http.BaseRequest request;
  if (source is http.Request) {
    request =
        http.AbortableRequest(
            source.method,
            source.url,
            abortTrigger: abortTrigger,
          )
          ..encoding = source.encoding
          ..bodyBytes = source.bodyBytes;
  } else if (source is http.MultipartRequest) {
    request =
        http.AbortableMultipartRequest(
            source.method,
            source.url,
            abortTrigger: abortTrigger,
          )
          ..fields.addAll(source.fields)
          ..files.addAll(source.files);
  } else {
    request = _AbortableStreamRequest(source, abortTrigger);
  }
  return request
    ..headers.addAll(source.headers)
    ..followRedirects = source.followRedirects
    ..maxRedirects = source.maxRedirects
    ..persistentConnection = source.persistentConnection;
}

class _AbortableStreamRequest extends http.BaseRequest
    implements http.Abortable {
  _AbortableStreamRequest(this._source, this.abortTrigger)
    : super(_source.method, _source.url) {
    contentLength = _source.contentLength;
  }

  final http.BaseRequest _source;

  @override
  final Future<void> abortTrigger;

  @override
  http.ByteStream finalize() {
    super.finalize();
    return _source.finalize();
  }
}
