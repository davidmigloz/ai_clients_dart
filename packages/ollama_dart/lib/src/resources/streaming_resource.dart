import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Mixin providing streaming request capabilities for resources.
///
/// This mixin provides shared infrastructure for streaming HTTP requests,
/// including:
/// - Auth application (bypassing interceptor chain for streaming)
/// - Request ID generation and logging
/// - Error mapping for streaming responses
/// - Stream error logging
///
/// ## Why Streaming Bypasses the Interceptor Chain
///
/// The interceptor chain operates on buffered [http.Response]. Streaming
/// requires unbuffered [http.StreamedResponse] access. Resources with
/// streaming must:
/// 1. Apply auth/logging manually to the request
/// 2. Send via [httpClient.send] to get [http.StreamedResponse]
/// 3. Check status and map errors before consuming stream
///
/// ## Resource implementation
///
/// Delegate NDJSON requests to [streamRequest] so cancellation reaches both
/// pending transport requests and the active body subscription.
mixin StreamingResource on ResourceBase {
  /// Prepares a streaming request by applying auth and logging.
  ///
  /// This applies the same auth and logging that the interceptor chain would
  /// apply, but without buffering the response. Returns the prepared request
  /// together with its request ID (for log/error correlation); the ID is only
  /// added to the request as an `X-Request-ID` header when
  /// [OllamaConfig.sendRequestIdHeader] is enabled.
  Future<(http.Request, String)> prepareStreamingRequest(
    http.Request request,
  ) async {
    var req = request;

    // Apply auth
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    req = _applyAuthToRequest(req, credentials);

    // Apply logging
    return _applyLoggingToRequest(req);
  }

  /// Sends a streaming request with error handling.
  ///
  /// Returns the [http.StreamedResponse] if successful, or throws an
  /// [OllamaException] if the response indicates an error. [requestId] is used
  /// for error-log correlation.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.Request request, {
    required String requestId,
  }) async {
    ensureNotClosed?.call();

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await httpClient.send(request);

      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        throw mapHttpError(response);
      }
    } catch (e) {
      _logStreamError(e, requestId);
      rethrow;
    }

    return streamedResponse;
  }

  /// Sends and parses an NDJSON request with request-scoped cancellation.
  ///
  /// Cancellation closes the local stream promptly while credentials, headers,
  /// or response data are pending. Native transport cancellation depends on the
  /// supplied client's [http.AbortableRequest] support.
  Stream<T> streamRequest<T>({
    required http.Request Function() createRequest,
    required T Function(Map<String, dynamic>) fromJson,
    Future<void>? abortTrigger,
  }) => _streamBody(
    createRequest: createRequest,
    abortTrigger: abortTrigger,
    transform: (body) => parseNDJSON(body).map((json) {
      if (json['error'] != null) throwInlineStreamError(json);
      return fromJson(json);
    }),
  );

  /// Streams raw response bytes without buffering or decoding binary audio.
  ///
  /// Subscription cancellation and [abortTrigger] cancel the pending request
  /// and active response body. HTTP failures use the normal error hierarchy.
  Stream<List<int>> streamBytes({
    required http.Request Function() createRequest,
    Future<void>? abortTrigger,
  }) => _streamBody(
    createRequest: createRequest,
    abortTrigger: abortTrigger,
    transform: (body) => body,
  );

  Stream<T> _streamBody<T>({
    required http.Request Function() createRequest,
    required Stream<T> Function(Stream<List<int>>) transform,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final requestAbort = Completer<void>();
    StreamSubscription<dynamic>? subscription;
    late StreamController<T> controller;
    var stopped = false;
    var requestId = generateRequestId();

    void stop({bool abort = true}) {
      if (stopped) return;
      stopped = true;
      if (abort && !requestAbort.isCompleted) requestAbort.complete();
      // The parser uses forwarding transformations, so canceling this
      // subscription reaches the body even when no complete line is available.
      subscription?.cancel().ignore();
    }

    void finish([Object? error, StackTrace? trace]) {
      if (stopped) return;
      if (error != null) controller.addError(error, trace);
      stop(abort: error != null);
      unawaited(controller.close());
    }

    Future<void> run() async {
      try {
        ensureNotClosed?.call();
        final request = createRequest();
        requestId = request.headers['X-Request-ID'] ?? requestId;
        final (prepared, correlationId) = await prepareStreamingRequest(
          request,
        );
        if (stopped) return;
        requestId = correlationId;
        final abortable =
            http.AbortableRequest(
                prepared.method,
                prepared.url,
                abortTrigger: requestAbort.future,
              )
              ..headers.addAll(prepared.headers)
              ..bodyBytes = prepared.bodyBytes
              ..followRedirects = prepared.followRedirects
              ..maxRedirects = prepared.maxRedirects
              ..persistentConnection = prepared.persistentConnection;
        final response = await httpClient.send(abortable);
        if (stopped) {
          // A custom client may ignore native abort and return a response later.
          response.stream.listen(null).cancel().ignore();
          return;
        }
        if (response.statusCode >= 400) {
          final errorBytes = <int>[];
          subscription = response.stream.listen(
            errorBytes.addAll,
            onError: finish,
            onDone: () {
              if (stopped) return;
              try {
                finish(
                  mapHttpError(
                    http.Response.bytes(
                      errorBytes,
                      response.statusCode,
                      headers: response.headers,
                      request: response.request,
                    ),
                  ),
                );
              } catch (error, trace) {
                finish(error, trace);
              }
            },
          );
        } else {
          subscription = transform(response.stream).listen(
            (event) {
              if (!stopped) controller.add(event);
            },
            onError: finish,
            onDone: finish,
          );
        }
        if (controller.isPaused) subscription?.pause();
      } catch (error, trace) {
        if (!stopped) {
          _logStreamError(error, requestId);
          finish(error, trace);
        }
      }
    }

    controller = StreamController<T>(
      onListen: () {
        if (abortTrigger != null) {
          unawaited(
            abortTrigger.then((_) {
              finish(
                AbortedException(
                  message: 'Request aborted by user',
                  correlationId: requestId,
                  timestamp: DateTime.now(),
                  stage: AbortionStage.duringStream,
                ),
              );
            }, onError: (Object _, StackTrace _) {}),
          );
        }
        unawaited(run());
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: stop,
    );
    return controller.stream;
  }

  /// Applies auth credentials to a request.
  http.Request _applyAuthToRequest(
    http.Request request,
    AuthCredentials? credentials,
  ) {
    if (credentials == null) return request;

    return switch (credentials) {
      BearerTokenCredentials(:final token) =>
        http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['Authorization'] = 'Bearer $token'
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding
          ..followRedirects = request.followRedirects
          ..maxRedirects = request.maxRedirects
          ..persistentConnection = request.persistentConnection,
      NoAuthCredentials() => request,
    };
  }

  /// Derives a request ID for the request and logs it.
  ///
  /// Returns the request together with its ID. The `X-Request-ID` header is
  /// only added to the outgoing request when
  /// [OllamaConfig.sendRequestIdHeader] is enabled and the caller didn't
  /// already supply one; otherwise the ID is used for logging only.
  (http.Request, String) _applyLoggingToRequest(http.Request request) {
    final requestId = request.headers['X-Request-ID'] ?? generateRequestId();

    if (config.logLevel.value <= Level.INFO.value) {
      Logger(
        'Ollama.HTTP',
      ).info('REQUEST [$requestId] ${request.method} ${request.url}');
    }

    if (config.sendRequestIdHeader &&
        !request.headers.containsKey('X-Request-ID')) {
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;

      return (updatedRequest, requestId);
    }

    return (request, requestId);
  }

  /// Maps an HTTP error response to an [OllamaException].
  OllamaException mapHttpError(http.Response response) {
    final statusCode = response.statusCode;
    var message = 'HTTP $statusCode error';

    try {
      final errorDetails = jsonDecode(response.body);
      if (errorDetails is Map<String, dynamic>) {
        final error = errorDetails['error'];
        message = switch (error) {
          String() => error,
          Map<String, dynamic>() => error['message']?.toString() ?? message,
          _ => message,
        };
      }
    } catch (_) {
      if (response.body.isNotEmpty && response.body.length < 200) {
        message = response.body;
      }
    }

    if (statusCode == 401) {
      return AuthenticationException(message: message);
    }

    if (statusCode == 429) {
      DateTime? retryAfter;
      final retryHeader = response.headers['retry-after'];
      if (retryHeader != null) {
        final seconds = int.tryParse(retryHeader);
        if (seconds != null) {
          retryAfter = DateTime.now().add(Duration(seconds: seconds));
        }
      }

      return RateLimitException(
        statusCode: statusCode,
        message: message,
        retryAfter: retryAfter,
      );
    }

    return ApiException(statusCode: statusCode, message: message);
  }

  /// Logs a streaming error.
  void _logStreamError(Object error, String requestId) {
    if (config.logLevel.value <= Level.SEVERE.value) {
      Logger('Ollama.HTTP').severe('STREAM ERROR [$requestId] $error', error);
    }
  }

  /// Checks for inline errors in NDJSON stream data and throws
  /// [StreamException] if found.
  ///
  /// Ollama embeds errors in HTTP 200 streaming responses as
  /// `{"error": "message string"}`.
  Never throwInlineStreamError(Map<String, dynamic> json) {
    final error = json['error'];
    final message = error is String ? error : 'Unknown stream error';
    Logger('Ollama.HTTP').warning('Inline stream error: $message');
    throw StreamException(message: message, partialData: jsonEncode(json));
  }
}
