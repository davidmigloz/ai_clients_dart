import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
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
  Stream<Map<String, dynamic>> postStream(
    String path, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) => _stream(
    'POST',
    path,
    body: body,
    queryParams: queryParams,
    headers: headers,
    abortTrigger: abortTrigger,
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
    errorFactory: errorFactory,
    errorFactoryWithMetadata: errorFactoryWithMetadata,
    decode: (bytes) => bytes
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
    final (message, details) = _parseErrorBody(body);

    if (statusCode == 401) {
      return AuthenticationException(
        message: message,
        details: details,
        responseMetadata: responseMetadata,
      );
    }

    if (statusCode == 429) {
      return RateLimitException(
        statusCode: statusCode,
        message: message,
        details: details,
        responseMetadata: responseMetadata,
        retryAfter: parseRetryAfter(responseMetadata.headers),
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      details: details,
      responseMetadata: responseMetadata,
    );
  }

  /// Parses error message and details from response body.
  (String, List<Object>) _parseErrorBody(String body) {
    if (body.isEmpty) {
      return ('Unknown error', <Object>[]);
    }

    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        // Anthropic error format: {"type": "error", "error": {"type": "...", "message": "..."}}
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'] as String? ?? 'Unknown error';
          final errorType = error['type'] as String?;
          return (
            message,
            errorType != null ? <Object>[errorType] : <Object>[],
          );
        }
        // Fallback: {"message": "..."}
        final message = json['message'];
        if (message is String) {
          return (message, <Object>[]);
        }
        return (body, <Object>[]);
      }
      return (body, <Object>[]);
    } catch (_) {
      return (body, <Object>[]);
    }
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
  );

  Stream<Map<String, dynamic>> _stream(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
    Stream<Map<String, dynamic>> Function(Stream<List<int>> bytes)? decode,
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
    late StreamController<Map<String, dynamic>> controller;

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
        final request =
            http.AbortableRequest(
                method,
                uri,
                abortTrigger: requestAbort.future,
              )
              ..headers.addAll(
                requestBuilder.buildHeaders(additionalHeaders: headers),
              );
        if (body != null) request.body = jsonEncode(body);
        await _applyAuthentication(request);
        if (stopped) return;
        correlationId = request.headers['X-Request-ID'] ?? correlationId;
        final stopwatch = Stopwatch()..start();
        final response = await httpClient.send(request);
        stopwatch.stop();
        if (stopped) {
          await response.stream.listen(null).cancel();
          return;
        }
        if (response.statusCode >= 400) {
          final responseBody = StringBuffer();
          subscription = response.stream
              .transform(utf8.decoder)
              .listen(
                responseBody.write,
                onError: finish,
                onDone: () {
                  final responseMetadata = createSafeResponseMetadata(
                    statusCode: response.statusCode,
                    headers: response.headers,
                    latency: stopwatch.elapsed,
                  );
                  final body = responseBody.toString();
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
                },
              );
        } else {
          subscription = (decode ?? SseParser().parse)(
            response.stream,
          ).listen(controller.add, onError: finish, onDone: finish);
        }
        if (controller.isPaused) subscription?.pause();
      } catch (error, stackTrace) {
        finish(error, stackTrace);
      }
    }

    controller = StreamController<Map<String, dynamic>>(
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

    final credentials = await provider.getCredentials();
    switch (credentials) {
      case ApiKeyCredentials(:final apiKey):
        if (!request.headers.containsKey('x-api-key')) {
          request.headers['x-api-key'] = apiKey;
        }
      case NoAuthCredentials():
        // No authentication needed
        break;
    }
  }
}

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
