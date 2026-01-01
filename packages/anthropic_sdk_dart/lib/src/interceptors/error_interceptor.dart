import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
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

    final responseMetadata = ResponseMetadata(
      statusCode: response.statusCode,
      headers: response.headers,
      bodyExcerpt: _truncateBody(response.body),
      latency: latency,
    );

    // Parse error message from response body
    final (message, details) = _parseErrorBody(response.body);

    // Handle authentication errors
    if (response.statusCode == 401) {
      return AuthenticationException(
        message: message,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
      );
    }

    // Handle rate limiting
    if (response.statusCode == 429) {
      return RateLimitException(
        code: response.statusCode,
        message: message,
        details: details,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
        retryAfter: _parseRetryAfter(response.headers),
      );
    }

    // General API error
    return ApiException(
      code: response.statusCode,
      message: message,
      details: details,
      requestMetadata: requestMetadata,
      responseMetadata: responseMetadata,
    );
  }

  /// Parses error message and details from response body.
  (String, List<Object>) _parseErrorBody(String body) {
    if (body.isEmpty) {
      return ('Unknown error', []);
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
          return (message, []);
        }
        return (body, []);
      }
      return (body, []);
    } catch (_) {
      return (body, []);
    }
  }

  /// Parses Retry-After header.
  DateTime? _parseRetryAfter(Map<String, String> headers) {
    final retryAfter = headers['retry-after'] ?? headers['Retry-After'];
    if (retryAfter == null) return null;

    // Try parsing as seconds
    final seconds = int.tryParse(retryAfter);
    if (seconds != null) {
      return DateTime.now().add(Duration(seconds: seconds));
    }

    // Try parsing as HTTP date
    try {
      return DateTime.parse(retryAfter);
    } catch (_) {
      return null;
    }
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
