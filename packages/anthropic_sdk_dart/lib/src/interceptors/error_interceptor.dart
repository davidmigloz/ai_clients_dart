import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../errors/response_error.dart';
import 'interceptor.dart';

/// Interceptor that transforms HTTP errors into typed exceptions.
class ErrorInterceptor implements Interceptor {
  /// Creates an [ErrorInterceptor].
  const ErrorInterceptor();

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final startTime = DateTime.now();
    final response = await next(context);

    // Check for error status codes
    if (response.statusCode >= 400) {
      final latency = DateTime.now().difference(startTime);
      throw _createException(context, response, latency);
    }

    return response;
  }

  /// Creates an appropriate exception for the response.
  AnthropicException _createException(
    RequestContext context,
    http.Response response,
    Duration latency,
  ) {
    final requestMetadata = RequestMetadata(
      method: context.request.method,
      url: context.request.url,
      headers: _redactHeaders(context.request.headers),
      correlationId:
          context.metadata['correlationId'] as String? ??
          context.request.headers['X-Request-ID'] ??
          'unknown',
      timestamp: DateTime.now(),
    );

    final body = decodeApiErrorResponse(response);
    final (:message, :details, :errorCode, :requestId) = parseApiErrorBody(
      body,
    );
    final responseMetadata = ResponseMetadata(
      statusCode: response.statusCode,
      headers: response.headers,
      bodyExcerpt: _truncateBody(body),
      latency: latency,
      bodyRequestId: requestId,
    );

    // Handle authentication errors
    if (response.statusCode == 401) {
      return AuthenticationException(
        message: message,
        details: details,
        errorCode: errorCode,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
      );
    }

    // Handle rate limiting
    if (response.statusCode == 429) {
      return RateLimitException(
        statusCode: response.statusCode,
        message: message,
        details: details,
        errorCode: errorCode,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
        retryAfter: retryAfterTime(response.headers),
      );
    }

    // General API error
    return ApiException(
      statusCode: response.statusCode,
      message: message,
      details: details,
      errorCode: errorCode,
      requestMetadata: requestMetadata,
      responseMetadata: responseMetadata,
    );
  }

  /// Truncates body to 200 characters.
  String _truncateBody(String body) {
    if (body.length <= 200) return body;
    return '${body.substring(0, 200)}...';
  }

  /// Redacts sensitive headers.
  Map<String, String> _redactHeaders(Map<String, String> headers) {
    const sensitiveKeys = [
      'x-api-key',
      'authorization',
      'token',
      'password',
      'secret',
    ];

    return headers.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (sensitiveKeys.any(lowerKey.contains)) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}
