import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../errors/exceptions.dart';
import '../errors/response_error.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Mixin that provides streaming capabilities for resources.
///
/// Handles SSE (Server-Sent Events) streaming for Anthropic API responses.
mixin StreamingResource on ResourceBase {
  /// Maps events while treating decoding failures as terminal stream errors.
  ///
  /// Unlike an async generator, this forwards listener cancellation while idle.
  Stream<T> mapStream<T>(
    Stream<Map<String, dynamic>> source,
    T Function(Map<String, dynamic>) decode,
  ) => Stream<T>.eventTransformed(
    source,
    (sink) => _MappedEventSink(sink, decode),
  );

  /// Makes a streaming POST request.
  ///
  /// Returns a stream of parsed SSE events as JSON maps.
  /// The optional [abortTrigger] cancels the request and closes the stream.
  /// Transport cancellation depends on support from the supplied HTTP client;
  /// it does not guarantee the server has stopped processing the request.
  /// [validateHeaders] sees the effective headers before transport starts.
  Stream<Map<String, dynamic>> postStream(
    String path, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
    void Function(Map<String, String>)? validateHeaders,
  }) => _stream(
    'POST',
    path,
    body: body,
    queryParams: queryParams,
    headers: headers,
    abortTrigger: abortTrigger,
    validateHeaders: validateHeaders,
    decode: (response) => SseParser().parse(response.stream),
  );

  /// Makes a streaming GET request whose response contains JSON lines.
  ///
  /// Uses the same cancellation lifecycle as SSE requests.
  ///
  /// [errorFactoryWithMetadata] receives safe response metadata and takes
  /// precedence over [errorFactory] when both are provided. The legacy
  /// [errorFactory] receives only the status and body; its exception is returned
  /// unchanged, so that factory remains responsible for its own metadata.
  Stream<Map<String, dynamic>> getJsonlStream(
    String path, {
    Future<void>? abortTrigger,
    Map<String, String>? headers,
    AnthropicException Function(int statusCode, String body)? errorFactory,
    AnthropicException Function(
      int statusCode,
      String body,
      ResponseMetadata responseMetadata,
    )?
    errorFactoryWithMetadata,
  }) => _stream(
    'GET',
    path,
    abortTrigger: abortTrigger,
    headers: headers,
    errorFactory: errorFactory,
    errorFactoryWithMetadata: errorFactoryWithMetadata,
    jsonlMedia: true,
    decode: (response) => response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) => line.trim().isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>),
  );

  /// Creates an exception for streaming errors.
  AnthropicException _createStreamException(
    int statusCode,
    String body,
    ResponseMetadata responseMetadata,
  ) {
    final (:message, :details, :errorCode, requestId: _) = parseApiErrorBody(
      body,
    );

    if (statusCode == 401) {
      return AuthenticationException(
        message: message,
        details: details,
        errorCode: errorCode,
        responseMetadata: responseMetadata,
      );
    }

    if (statusCode == 429) {
      return RateLimitException(
        statusCode: statusCode,
        message: message,
        details: details,
        errorCode: errorCode,
        responseMetadata: responseMetadata,
        retryAfter: retryAfterTime(responseMetadata.headers),
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      details: details,
      errorCode: errorCode,
      responseMetadata: responseMetadata,
    );
  }

  /// Makes a streaming GET request.
  ///
  /// Returns a stream of parsed SSE events as JSON maps.
  /// The optional [abortTrigger] cancels the request and closes the stream.
  /// Transport cancellation depends on support from the supplied HTTP client;
  /// it does not guarantee the server has stopped processing the request.
  Stream<Map<String, dynamic>> getStream(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) => _stream(
    'GET',
    path,
    queryParams: queryParams,
    headers: headers,
    abortTrigger: abortTrigger,
    decode: (response) => SseParser().parse(response.stream),
  );

  Stream<T> _stream<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
    void Function(Map<String, String>)? validateHeaders,
    required Stream<T> Function(http.StreamedResponse response) decode,
    Map<String, String> Function()? buildRequestHeaders,
    bool followRedirects = true,
    bool jsonlMedia = false,
    AnthropicException Function(int statusCode, String body)? errorFactory,
    AnthropicException Function(
      int statusCode,
      String body,
      ResponseMetadata responseMetadata,
    )?
    errorFactoryWithMetadata,
  }) {
    final requestAbort = Completer<void>();
    // Canceled by stop when the stream terminates or its listener cancels.
    // ignore: cancel_subscriptions
    StreamSubscription<dynamic>? subscription;
    var correlationId = generateRequestId();
    var stopped = false;
    late StreamController<T> controller;

    void stop({bool abort = true}) {
      if (stopped) return;
      stopped = true;
      if (abort && !requestAbort.isCompleted) requestAbort.complete();
      final current = subscription;
      current?.cancel().ignore();
    }

    void finish([Object? error, StackTrace? stackTrace]) {
      if (stopped) return;
      stop(abort: error != null);
      if (error != null) controller.addError(error, stackTrace);
      unawaited(controller.close());
    }

    Future<void> run() async {
      try {
        ensureNotClosed?.call();
        final uri = requestBuilder.buildUrl(path, queryParams: queryParams);
        final requestHeaders =
            buildRequestHeaders?.call() ??
            requestBuilder.buildHeaders(additionalHeaders: headers);
        if (jsonlMedia) {
          // JSONL responses are streamed bytes. Leave explicit header
          // overrides in place and omit the synthesized JSON Content-Type.
          if (!requestHeaders.keys.any(
            (key) => key.toLowerCase() == 'accept',
          )) {
            requestHeaders['accept'] = 'application/x-jsonl';
          }
          if (![config.defaultHeaders, ?headers].any(
            (source) =>
                source.keys.any((key) => key.toLowerCase() == 'content-type'),
          )) {
            requestHeaders.remove('content-type');
          }
        }
        validateHeaders?.call(requestHeaders);
        final request =
            http.AbortableRequest(
                method,
                uri,
                abortTrigger: requestAbort.future,
              )
              ..followRedirects = followRedirects
              ..headers.addAll(requestHeaders);
        if (body != null) request.body = jsonEncode(body);
        await _applyAuthentication(request);
        if (abortTrigger != null && !stopped) {
          // Drain cancellation queued in the same event turn as authentication.
          await Future<void>.delayed(Duration.zero);
        }
        if (stopped) return;
        ensureNotClosed?.call();
        correlationId = request.headers['X-Request-ID'] ?? correlationId;
        final stopwatch = Stopwatch()..start();
        final response = await httpClient.send(request);
        stopwatch.stop();
        if (stopped) {
          await response.stream.listen(null).cancel();
          return;
        }
        if (!followRedirects &&
            response.statusCode >= 300 &&
            response.statusCode < 400) {
          response.stream.listen(null).cancel().ignore();
          finish(
            ApiException(
              statusCode: response.statusCode,
              message: 'Unexpected redirect from the API',
              responseMetadata: createSafeResponseMetadata(
                statusCode: response.statusCode,
                headers: response.headers,
                latency: stopwatch.elapsed,
              ),
            ),
          );
          return;
        }
        if (response.statusCode >= 400) {
          final responseBody = BytesBuilder();
          subscription = response.stream.listen(
            responseBody.add,
            onError: finish,
            onDone: () {
              if (stopped) return;
              try {
                final body = decodeStreamingApiErrorBody(
                  responseBody.takeBytes(),
                  response.headers,
                );
                final responseMetadata = createSafeResponseMetadata(
                  statusCode: response.statusCode,
                  headers: response.headers,
                  latency: stopwatch.elapsed,
                  bodyRequestId: parseApiErrorBody(body).requestId,
                );
                finish(
                  errorFactoryWithMetadata?.call(
                        response.statusCode,
                        body,
                        responseMetadata,
                      ) ??
                      errorFactory?.call(response.statusCode, body) ??
                      _createStreamException(
                        response.statusCode,
                        body,
                        responseMetadata,
                      ),
                );
              } catch (error, stackTrace) {
                finish(error, stackTrace);
              }
            },
          );
        } else {
          final decoded = decode(response);
          if (stopped) {
            await decoded.listen(null).cancel();
            return;
          }
          subscription = decoded.listen(
            controller.add,
            onError: finish,
            onDone: finish,
          );
        }
        // A custom response stream can abort synchronously from its onListen
        // callback, before its subscription is available to stop().
        if (stopped) {
          await subscription?.cancel();
          return;
        }
        if (controller.isPaused) subscription?.pause();
      } catch (error, stackTrace) {
        finish(error, stackTrace);
      }
    }

    controller = StreamController<T>(
      onListen: () {
        unawaited(
          abortTrigger?.then((_) {
            finish(
              AbortedException(
                message: 'Stream aborted by user',
                correlationId: correlationId,
                timestamp: DateTime.now(),
                stage: AbortionStage.duringStream,
              ),
            );
          }, onError: (Object _, StackTrace stackTrace) {}),
        );
        unawaited(run());
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: stop,
    );
    return controller.stream;
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.Request request) async {
    final provider = config.authProvider;
    if (provider == null) return;

    request.headers.addAll(
      await resolveCredentialHeaders(request.headers, provider),
    );
  }
}

/// Opens a raw response body using the same lifecycle as SSE and JSONL streams.
Stream<List<int>> getResourceByteStream(
  StreamingResource resource,
  String path, {
  Map<String, dynamic>? queryParams,
  required Map<String, String> Function() headers,
  void Function(Map<String, String>)? onResponse,
  Future<void>? abortTrigger,
}) => resource._stream(
  'GET',
  path,
  queryParams: queryParams,
  buildRequestHeaders: headers,
  followRedirects: false,
  abortTrigger: abortTrigger,
  decode: (response) {
    try {
      onResponse?.call(response.headers);
      return response.stream;
    } catch (_) {
      response.stream.listen(null).cancel().ignore();
      rethrow;
    }
  },
);

class _MappedEventSink<T> implements EventSink<Map<String, dynamic>> {
  final EventSink<T> _output;
  final T Function(Map<String, dynamic>) _decode;
  bool _closed = false;

  _MappedEventSink(this._output, this._decode);

  @override
  void add(Map<String, dynamic> event) {
    if (_closed) return;
    try {
      _output.add(_decode(event));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) return;
    _closed = true;
    _output
      ..addError(error, stackTrace)
      ..close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _output.close();
  }
}
