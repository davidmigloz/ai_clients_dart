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
    (sink) => _MappedEventSink<T>(sink, decode),
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
    decode: (body, _, _) => SseParser().parse(body),
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
    decode: (body, _, _) => body
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
    final parsed = parseApiErrorBody(body);

    if (statusCode == 401) {
      return AuthenticationException(
        message: parsed.message,
        details: parsed.details,
        errorCode: parsed.errorCode,
        errorDetails: parsed.errorDetails,
        responseMetadata: responseMetadata,
      );
    }

    if (statusCode == 429) {
      return RateLimitException(
        statusCode: statusCode,
        message: parsed.message,
        details: parsed.details,
        errorCode: parsed.errorCode,
        errorDetails: parsed.errorDetails,
        responseMetadata: responseMetadata,
        retryAfter: retryAfterTime(responseMetadata.headers),
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: parsed.message,
      details: parsed.details,
      errorCode: parsed.errorCode,
      errorDetails: parsed.errorDetails,
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
    decode: (body, _, _) => SseParser().parse(body),
  );

  Stream<T> _stream<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
    void Function(Map<String, String>)? validateHeaders,
    required Stream<T> Function(
      Stream<List<int>> body,
      http.StreamedResponse response,
      Duration latency,
    )
    decode,
    bool Function(T)? isTerminal,
    void Function(http.StreamedResponse, Duration)? onResponse,
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
    Timer? headerTimer;
    var correlationId = generateRequestId();
    var stopped = false;
    late StreamController<T> controller;

    void stop({bool abort = true}) {
      if (stopped) return;
      stopped = true;
      headerTimer?.cancel();
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
        headerTimer = Timer(
          config.timeout,
          () => finish(
            TimeoutException(
              message: 'Timed out waiting for HTTP response headers',
              timeout: config.timeout,
              elapsed: stopwatch.elapsed,
            ),
          ),
        );
        final response = await httpClient.send(request);
        headerTimer?.cancel();
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
        final responseBodyStream = response.stream.timeout(
          config.timeout,
          onTimeout: (sink) => sink
            ..addError(
              TimeoutException(
                message: 'Timed out waiting for response body data',
                timeout: config.timeout,
                elapsed: config.timeout,
              ),
            )
            ..close(),
        );
        if (response.statusCode >= 400) {
          final responseBody = BytesBuilder();
          subscription = responseBodyStream.listen(
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
          try {
            onResponse?.call(response, stopwatch.elapsed);
          } catch (_) {
            response.stream.listen(null).cancel().ignore();
            rethrow;
          }
          if (stopped) {
            await response.stream.listen(null).cancel();
            return;
          }
          subscription = decode(responseBodyStream, response, stopwatch.elapsed)
              .listen(
                (event) {
                  if (stopped) return;
                  final terminal = isTerminal?.call(event) == true;
                  if (terminal) stop();
                  controller.add(event);
                  if (terminal) unawaited(controller.close());
                },
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

/// Decodes Messages SSE with handshake metadata and immediate terminal cleanup.
Stream<T> postResourceEventStream<T>(
  StreamingResource resource,
  String path, {
  required Map<String, dynamic> body,
  required T Function(Map<String, dynamic>, ResponseMetadata) decodeEvent,
  required bool Function(T) isTerminal,
  Map<String, String>? headers,
  Future<void>? abortTrigger,
  void Function(Map<String, String>)? validateHeaders,
}) => resource._stream(
  'POST',
  path,
  body: body,
  headers: headers,
  abortTrigger: abortTrigger,
  validateHeaders: validateHeaders,
  isTerminal: isTerminal,
  decode: (body, response, latency) {
    final metadata = createSafeResponseMetadata(
      statusCode: response.statusCode,
      headers: response.headers,
      latency: latency,
    );
    return SseParser()
        .parse(body, strictJson: true)
        .map((event) => decodeEvent(event, metadata));
  },
);

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
  onResponse: onResponse == null
      ? null
      : (response, _) => onResponse(response.headers),
  decode: (body, _, _) => body,
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
