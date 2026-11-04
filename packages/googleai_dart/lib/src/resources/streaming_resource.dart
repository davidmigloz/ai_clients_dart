import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../utils/redactor.dart';
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
/// - Abort trigger monitoring
///
/// ## Why Streaming Bypasses the Interceptor Chain
///
/// The interceptor chain operates on buffered [http.Response]. Streaming
/// requires unbuffered [http.StreamedResponse] access. Resources with
/// streaming must:
/// 1. Apply auth/logging manually to the request
/// 2. Send via [httpClient.send] to get [StreamedResponse]
/// 3. Check status and map errors before consuming stream
///
/// Streaming resources delegate SSE requests to [streamRequest] so cancellation
/// reaches both a pending transport and the active response body.
mixin StreamingResource on ResourceBase {
  /// Prepares a streaming request by applying auth and logging.
  ///
  /// This applies the same auth and logging that the interceptor chain would
  /// apply, but without buffering the response.
  Future<http.Request> prepareStreamingRequest(http.Request request) async {
    var req = request;

    // Apply auth
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    req = _applyAuthToRequestSync(req, credentials);

    // Apply logging
    req = _applyLoggingToRequest(req);

    return req;
  }

  /// Sends a streaming request with error handling.
  ///
  /// Returns the [StreamedResponse] if successful, or throws a
  /// [GoogleAIException] if the response indicates an error.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.Request request,
  ) async {
    ensureNotClosed?.call();

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await httpClient.send(request);

      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        throw mapHttpErrorForStreaming(response);
      }
    } catch (e) {
      _logStreamError(
        e,
        request.headers['X-Request-ID'] ?? generateRequestId(),
      );
      rethrow;
    }

    return streamedResponse;
  }

  /// Sends and parses an SSE request with request-scoped cancellation.
  ///
  /// Cancellation closes the local stream promptly, including while credentials
  /// or response headers are pending. Native transport cancellation depends on
  /// the supplied HTTP client's support for [http.AbortableRequest].
  Stream<T> streamRequest<T>({
    required http.Request Function() createRequest,
    required T Function(Map<String, dynamic>) fromJson,
    Future<void>? abortTrigger,
  }) {
    final requestAbort = Completer<void>();
    StreamSubscription<List<int>>? bodySubscription;
    StreamSubscription<Map<String, dynamic>>? eventSubscription;
    StreamController<List<int>>? bytesController;
    late StreamController<T> controller;
    var stopped = false;
    var requestId = generateRequestId();

    void stop() {
      if (stopped) return;
      stopped = true;
      if (!requestAbort.isCompleted) requestAbort.complete();
      // Parser cancellation can wait for an incomplete SSE event. Cancel its
      // byte source separately and unblock it, without delaying local closure.
      bodySubscription?.cancel().ignore();
      eventSubscription?.cancel().ignore();
      bytesController?.close().ignore();
    }

    void finish([Object? error, StackTrace? stackTrace]) {
      if (stopped) return;
      if (error != null) controller.addError(error, stackTrace);
      stop();
      unawaited(controller.close());
    }

    Future<void> run() async {
      try {
        ensureNotClosed?.call();
        final request = createRequest();
        requestId = request.headers['X-Request-ID'] ?? requestId;
        final prepared = await prepareStreamingRequest(request);
        if (stopped) return;
        requestId = prepared.headers['X-Request-ID'] ?? requestId;
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
          // Clients without native abort support may return a response later.
          response.stream.listen(null).cancel().ignore();
          return;
        }
        if (response.statusCode >= 400) {
          final errorBytes = <int>[];
          bodySubscription = response.stream.listen(
            errorBytes.addAll,
            onError: finish,
            onDone: () {
              if (stopped) return;
              try {
                finish(
                  mapHttpErrorForStreaming(
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
          if (controller.isPaused) bodySubscription?.pause();
          return;
        }
        final bytes = StreamController<List<int>>(
          onListen: () {
            bodySubscription = response.stream.listen(
              (chunk) {
                if (!stopped) bytesController!.add(chunk);
              },
              onError: finish,
              onDone: () => bytesController!.close().ignore(),
            );
            if (controller.isPaused) bodySubscription?.pause();
          },
          onCancel: () {
            // A parser terminator such as [DONE] must also release the body.
            if (!requestAbort.isCompleted) requestAbort.complete();
            bodySubscription?.cancel().ignore();
          },
        );
        bytesController = bytes;
        eventSubscription = parseSSE(bytesToLines(bytes.stream)).listen(
          (json) {
            if (stopped) return;
            try {
              controller.add(fromJson(json));
            } catch (error, trace) {
              finish(error, trace);
            }
          },
          onError: finish,
          onDone: finish,
        );
        if (controller.isPaused) eventSubscription?.pause();
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
      onPause: () {
        eventSubscription?.pause();
        bodySubscription?.pause();
      },
      onResume: () {
        eventSubscription?.resume();
        bodySubscription?.resume();
      },
      onCancel: stop,
    );
    return controller.stream;
  }

  /// Monitors an abort trigger while transforming an existing event stream.
  ///
  /// Emits [AbortedException] promptly even when the source's cancellation
  /// cleanup waits for another event. Errors and converter failures terminate
  /// the stream and release its subscription.
  Stream<T> streamWithAbortMonitoring<T>({
    required Stream<Map<String, dynamic>> source,
    required Future<void> abortTrigger,
    required String requestId,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    StreamSubscription<Map<String, dynamic>>? subscription;
    late StreamController<T> controller;
    var stopped = false;

    void stop() {
      if (stopped) return;
      stopped = true;
      subscription?.cancel().ignore();
    }

    void finish([Object? error, StackTrace? trace]) {
      if (stopped) return;
      if (error != null) controller.addError(error, trace);
      stop();
      unawaited(controller.close());
    }

    controller = StreamController<T>(
      onListen: () {
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
        subscription = source.listen(
          (json) {
            if (stopped) return;
            try {
              controller.add(fromJson(json));
            } catch (error, trace) {
              finish(error, trace);
            }
          },
          onError: finish,
          onDone: finish,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: stop,
    );
    return controller.stream;
  }

  /// Applies authentication to a request (mirrors AuthInterceptor logic).
  http.Request _applyAuthToRequestSync(
    http.Request request,
    AuthCredentials? credentials,
  ) {
    if (credentials == null) return request;

    return switch (credentials) {
      ApiKeyCredentials(:final apiKey, :final placement) => _addApiKey(
        request,
        apiKey,
        placement,
      ),
      BearerTokenCredentials(:final token) => _addBearerToken(request, token),
      EphemeralTokenCredentials(:final token) => _addEphemeralToken(
        request,
        token,
      ),
      NoAuthCredentials() => request,
    };
  }

  /// Adds API key to request based on placement strategy.
  http.Request _addApiKey(
    http.Request request,
    String apiKey,
    AuthPlacement placement,
  ) {
    if (placement == AuthPlacement.header) {
      if (!request.headers.containsKey('X-Goog-Api-Key')) {
        return http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['X-Goog-Api-Key'] = apiKey
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding;
      }
    } else {
      final uri = request.url;
      if (!uri.queryParameters.containsKey('key')) {
        final queryParams = Map<String, dynamic>.from(uri.queryParametersAll);
        queryParams['key'] = apiKey;
        final newUri = uri.replace(queryParameters: queryParams);

        return http.Request(request.method, newUri)
          ..headers.addAll(request.headers)
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding;
      }
    }

    return request;
  }

  /// Adds Bearer token to request headers.
  http.Request _addBearerToken(http.Request request, String bearerToken) {
    if (!request.headers.containsKey('Authorization')) {
      return http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['Authorization'] = 'Bearer $bearerToken'
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;
    }

    return request;
  }

  /// Adds ephemeral token to request as query parameter.
  http.Request _addEphemeralToken(http.Request request, String token) {
    final uri = request.url;
    if (uri.queryParameters.containsKey('access_token')) {
      return request;
    }
    final queryParams = Map<String, dynamic>.from(uri.queryParametersAll);
    queryParams['access_token'] = token;
    final newUri = uri.replace(queryParameters: queryParams);

    return http.Request(request.method, newUri)
      ..headers.addAll(request.headers)
      ..bodyBytes = request.bodyBytes
      ..encoding = request.encoding;
  }

  /// Applies logging to a request (mirrors LoggingInterceptor logic).
  http.Request _applyLoggingToRequest(http.Request request) {
    if (!request.headers.containsKey('X-Request-ID')) {
      final requestId = generateRequestId();
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;

      if (config.logLevel.value <= Level.INFO.value) {
        // Redact credentials from URL before logging
        const redactor = Redactor(redactionList: ['key', 'access_token']);
        final safeUrl = redactor.redactString(request.url.toString());
        Logger(
          'GoogleAI.HTTP',
        ).info('REQUEST [$requestId] ${request.method} $safeUrl');
      }

      return updatedRequest;
    }

    return request;
  }

  /// Maps HTTP errors for streaming (mirrors ErrorInterceptor logic).
  GoogleAIException mapHttpErrorForStreaming(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    var message = 'HTTP $statusCode error';
    final details = <Object>[];

    try {
      final errorDetails = jsonDecode(body);
      if (errorDetails is Map<String, dynamic>) {
        final error = errorDetails['error'] as Map<String, dynamic>?;
        message = error?['message']?.toString() ?? message;
        if (error?['details'] != null) {
          final errorDetailsList = error!['details'];
          if (errorDetailsList is List) {
            details.addAll(errorDetailsList.cast<Object>());
          }
        }
      }
    } catch (_) {
      if (body.length < 200 && body.isNotEmpty) {
        message = body;
      }
    }

    if (statusCode == 401) {
      return AuthenticationException(message: message, details: details);
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
        details: details,
        retryAfter: retryAfter,
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      details: details,
    );
  }

  /// Logs streaming errors.
  void _logStreamError(Object error, String requestId) {
    if (config.logLevel.value <= Level.SEVERE.value) {
      Logger('GoogleAI.HTTP').severe('STREAM ERROR [$requestId] $error', error);
    }
  }

  /// Checks for inline errors in SSE stream data and throws
  /// [StreamException] if found.
  ///
  /// Detects two error patterns:
  /// 1. SSE `event: error` — parser sets `_event: "error"` in the JSON map
  /// 2. Error objects in data — `{"error": ...}` in the JSON payload
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

    Logger('GoogleAI.HTTP').warning('Inline stream error: $message');

    final cleanJson = Map<String, dynamic>.from(json)
      ..remove('_event')
      ..remove('_rawData');
    throw StreamException(message: message, partialData: jsonEncode(cleanJson));
  }
}
