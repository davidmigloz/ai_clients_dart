import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../utils/request_id.dart';
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
/// ## Usage
///
/// ```dart
/// class ChatResource extends ResourceBase with StreamingResource {
///   Stream<ChatCompletionStreamResponse> createStream({
///     required ChatCompletionRequest request,
///   }) async* {
///     final httpRequest = http.Request('POST', url)...;
///     final (preparedRequest, requestId) =
///         await prepareStreamingRequest(httpRequest);
///     final response = await sendStreamingRequest(
///       preparedRequest,
///       requestId: requestId,
///     );
///     await for (final json in parseSSE(response.stream)) {
///       yield ChatCompletionStreamResponse.fromJson(json);
///     }
///   }
/// }
/// ```
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
