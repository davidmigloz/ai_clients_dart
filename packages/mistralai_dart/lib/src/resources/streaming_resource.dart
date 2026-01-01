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
///     var httpRequest = http.Request('POST', url)...;
///     httpRequest = await prepareStreamingRequest(httpRequest);
///     final response = await sendStreamingRequest(httpRequest);
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
  /// apply, but without buffering the response.
  Future<http.Request> prepareStreamingRequest(http.Request request) async {
    var req = request;

    // Apply auth
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    req = _applyAuthToRequest(req, credentials);

    // Apply logging
    req = _applyLoggingToRequest(req);

    return req;
  }

  /// Sends a streaming request with error handling.
  ///
  /// Returns the [StreamedResponse] if successful, or throws a
  /// [MistralException] if the response indicates an error.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.Request request,
  ) async {
    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await httpClient.send(request);

      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        throw mapHttpError(response);
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

  /// Applies logging to a request by adding a request ID.
  http.Request _applyLoggingToRequest(http.Request request) {
    if (!request.headers.containsKey('X-Request-ID')) {
      final requestId = generateRequestId();
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;

      if (config.logLevel.value <= Level.INFO.value) {
        Logger(
          'Mistral.HTTP',
        ).info('REQUEST [$requestId] ${request.method} ${request.url}');
      }

      return updatedRequest;
    }

    return request;
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
        code: statusCode,
        message: message,
        retryAfter: retryAfter,
      );
    }

    return ApiException(code: statusCode, message: message);
  }

  /// Logs a streaming error.
  void _logStreamError(Object error, String requestId) {
    if (config.logLevel.value <= Level.SEVERE.value) {
      Logger('Mistral.HTTP').severe('STREAM ERROR [$requestId] $error', error);
    }
  }
}
