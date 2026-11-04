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
/// 2. Send via [httpClient.send] to get [StreamedResponse]
/// 3. Check status and map errors before consuming stream
///
mixin StreamingResource on ResourceBase {
  /// Prepares a streaming request by applying auth and logging.
  ///
  /// This applies the same auth and logging that the interceptor chain would
  /// apply, but without buffering the response. Returns the prepared request
  /// together with its request ID (for log/error correlation); the ID is only
  /// added to the request as an `X-Request-ID` header when
  /// [MistralConfig.sendRequestIdHeader] is enabled.
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

  /// Prepares a streaming multipart request by applying auth and logging.
  ///
  /// Unlike [prepareStreamingRequest], the headers are set on [request]
  /// itself: an [http.MultipartRequest] cannot be cloned once its parts
  /// have been added, and it has not been finalized at this point. Returns the
  /// request together with its request ID, which is only sent as an
  /// `X-Request-ID` header when [MistralConfig.sendRequestIdHeader] is enabled.
  Future<(http.MultipartRequest, String)> prepareStreamingMultipartRequest(
    http.MultipartRequest request,
  ) async {
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    if (credentials is BearerTokenCredentials &&
        !request.headers.containsKey('Authorization')) {
      request.headers['Authorization'] = 'Bearer ${credentials.token}';
    }

    final requestId = request.headers['X-Request-ID'] ?? generateRequestId();
    _logStreamRequest(request, requestId);

    if (config.sendRequestIdHeader &&
        !request.headers.containsKey('X-Request-ID')) {
      request.headers['X-Request-ID'] = requestId;
    }

    return (request, requestId);
  }

  /// Sends a streaming request with error handling.
  ///
  /// Returns the [StreamedResponse] if successful, or throws a
  /// [MistralException] if the response indicates an error. [requestId] is
  /// used for error-log correlation.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.BaseRequest request, {
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

  /// Sends and parses a streaming request with request-scoped cancellation.
  ///
  /// The request is created on listen. Cancellation closes the local stream and
  /// signals the transport without closing the shared HTTP client. Native
  /// transport cancellation depends on support from the supplied HTTP client.
  Stream<T> streamRequest<T>(
    http.BaseRequest Function() createRequest,
    T Function(Map<String, dynamic>) parseEvent, {
    Future<void>? abortTrigger,
    Stream<Map<String, dynamic>> Function(Stream<List<int>>) parseEvents =
        parseSSE,
    bool checkInlineErrors = true,
  }) {
    final nativeAbort = Completer<void>();
    StreamSubscription<dynamic>? subscription;
    Future<void>? cancellation;
    var finished = false;
    var stage = AbortionStage.beforeRequest;
    var correlationId = generateRequestId();
    late StreamController<T> controller;

    Future<void> cancel({bool abortTransport = true}) {
      finished = true;
      if (abortTransport && !nativeAbort.isCompleted) nativeAbort.complete();
      return cancellation ??= Future<void>.sync(() => subscription?.cancel());
    }

    void finish([Object? error, StackTrace? stackTrace]) {
      if (finished) return;
      finished = true;
      if (error != null) {
        _logStreamError(error, correlationId);
        controller.addError(error, stackTrace);
      }
      // onCancel shares this cleanup future with subscription.cancel().
      cancel(abortTransport: error != null).ignore();
      unawaited(controller.close());
    }

    Future<void> run() async {
      try {
        ensureNotClosed?.call();
        final request = createRequest();
        final (preparedRequest, requestId) = switch (request) {
          http.MultipartRequest() => await prepareStreamingMultipartRequest(
            request,
          ),
          http.Request() => await prepareStreamingRequest(request),
          _ => throw ArgumentError('Unsupported streaming request type'),
        };
        correlationId = requestId;
        if (finished) return;
        stage = AbortionStage.duringRequest;
        final response = await httpClient.send(
          _abortableRequest(preparedRequest, nativeAbort.future),
        );
        if (finished) {
          await response.stream.listen(null).cancel();
          return;
        }
        stage = AbortionStage.duringStream;
        if (response.statusCode >= 400) {
          final body = <int>[];
          subscription = response.stream.listen(
            body.addAll,
            onError: finish,
            onDone: () {
              try {
                finish(
                  mapHttpError(
                    http.Response.bytes(
                      body,
                      response.statusCode,
                      headers: response.headers,
                      request: response.request,
                      reasonPhrase: response.reasonPhrase,
                    ),
                  ),
                );
              } catch (error, stackTrace) {
                finish(error, stackTrace);
              }
            },
          );
        } else {
          subscription = parseEvents(response.stream).listen(
            (event) {
              if (finished) return;
              try {
                if (checkInlineErrors) {
                  final sseEvent = event['_event'] as String?;
                  final error = event['error'];
                  if (sseEvent == 'error' || error != null) {
                    throwInlineStreamError(event, sseEvent, error);
                  }
                }
                controller.add(parseEvent(event));
              } catch (error, stackTrace) {
                finish(error, stackTrace);
              }
            },
            onError: finish,
            onDone: finish,
          );
        }
        if (finished) {
          await subscription?.cancel();
        } else if (controller.isPaused) {
          subscription?.pause();
        }
      } catch (error, stackTrace) {
        finish(error, stackTrace);
      }
    }

    controller = StreamController<T>(
      onListen: () {
        unawaited(
          abortTrigger?.then(
            (_) => finish(
              AbortedException(
                message: 'Stream aborted by user',
                correlationId: correlationId,
                timestamp: DateTime.now(),
                stage: stage,
              ),
            ),
            onError: (Object _, StackTrace _) {},
          ),
        );
        unawaited(run());
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        // Local cancellation must not wait for a supplied client's cleanup.
        cancel(abortTransport: !finished).ignore();
      },
    );
    return controller.stream;
  }

  http.BaseRequest _abortableRequest(
    http.BaseRequest request,
    Future<void> abortTrigger,
  ) {
    final http.BaseRequest abortable = switch (request) {
      http.Request() =>
        http.AbortableRequest(
            request.method,
            request.url,
            abortTrigger: abortTrigger,
          )
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding,
      http.MultipartRequest() =>
        http.AbortableMultipartRequest(
            request.method,
            request.url,
            abortTrigger: abortTrigger,
          )
          ..fields.addAll(request.fields)
          ..files.addAll(request.files),
      _ => throw ArgumentError('Unsupported streaming request type'),
    };
    return abortable
      ..headers.addAll(request.headers)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection;
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
          ..encoding = request.encoding,
      NoAuthCredentials() => request,
    };
  }

  /// Derives a request ID for the request and logs it.
  ///
  /// Returns the request together with its ID. The `X-Request-ID` header is
  /// only added to the outgoing request when
  /// [MistralConfig.sendRequestIdHeader] is enabled and the caller didn't
  /// already supply one; otherwise the ID is used for logging only.
  (http.Request, String) _applyLoggingToRequest(http.Request request) {
    final requestId = request.headers['X-Request-ID'] ?? generateRequestId();
    _logStreamRequest(request, requestId);

    if (config.sendRequestIdHeader &&
        !request.headers.containsKey('X-Request-ID')) {
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;

      return (updatedRequest, requestId);
    }

    return (request, requestId);
  }

  /// Logs an outgoing streaming request.
  void _logStreamRequest(http.BaseRequest request, String requestId) {
    if (config.logLevel.value <= Level.INFO.value) {
      Logger(
        'Mistral.HTTP',
      ).info('REQUEST [$requestId] ${request.method} ${request.url}');
    }
  }

  /// Maps an HTTP error response to a [MistralException].
  MistralException mapHttpError(http.Response response) {
    final statusCode = response.statusCode;
    var message = 'HTTP $statusCode error';

    try {
      final errorDetails = jsonDecode(response.body);
      if (errorDetails is Map<String, dynamic>) {
        // Mistral error format: {"message": "...", "request_id": "..."}
        message =
            errorDetails['message']?.toString() ??
            errorDetails['detail']?.toString() ??
            message;
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
      Logger('Mistral.HTTP').severe('STREAM ERROR [$requestId] $error', error);
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

    Logger('Mistral.HTTP').warning('Inline stream error: $message');

    final cleanJson = Map<String, dynamic>.from(json)
      ..remove('_event')
      ..remove('_rawData');
    throw StreamException(message: message, partialData: jsonEncode(cleanJson));
  }
}
