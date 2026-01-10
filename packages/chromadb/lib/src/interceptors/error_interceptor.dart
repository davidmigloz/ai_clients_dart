import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import 'interceptor.dart';

/// Interceptor that converts HTTP errors to typed exceptions.
///
/// This interceptor examines the response status code and throws
/// appropriate [ChromaException] subclasses for error responses.
///
/// ChromaDB error response format:
/// ```json
/// {
///   "error": "error type",
///   "message": "detailed message"
/// }
/// ```
class ErrorInterceptor implements Interceptor {
  /// Headers that should have their values redacted in metadata.
  static const _sensitiveHeaders = {
    'authorization',
    'x-chroma-token',
    'x-api-key',
  };

  /// Maximum length for body excerpt in metadata.
  static const _maxBodyExcerptLength = 200;

  /// Creates an error interceptor.
  const ErrorInterceptor();

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final stopwatch = Stopwatch()..start();
    final response = await next(context);
    stopwatch.stop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // Parse error response
    String message;

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      message =
          json['message'] as String? ??
          json['error'] as String? ??
          json['detail'] as String? ??
          response.body;
    } catch (_) {
      message = response.body.isNotEmpty
          ? response.body
          : 'Request failed with status ${response.statusCode}';
    }

    final requestMeta = RequestMetadata(
      method: context.method,
      url: context.fullUrl ?? Uri.parse(context.path),
      headers: _redactHeaders(context.headers),
      correlationId: context.headers['X-Request-ID'] ?? 'unknown',
      timestamp: context.timestamp,
      attemptNumber: context.attemptNumber,
    );

    final responseMeta = ResponseMetadata(
      statusCode: response.statusCode,
      headers: response.headers,
      bodyExcerpt: _truncateBody(response.body, _maxBodyExcerptLength),
      latency: stopwatch.elapsed,
    );

    // Map status codes to exception types
    switch (response.statusCode) {
      case 400:
        throw ValidationException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
      case 401:
      case 403:
        throw AuthenticationException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
      case 404:
        throw NotFoundException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
      case 409:
        throw ConflictException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
      case 422:
        throw ValidationException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
      case 429:
        // Parse retry-after if available
        final retryAfter = response.headers['retry-after'];
        Duration? retryAfterDuration;
        if (retryAfter != null) {
          final seconds = int.tryParse(retryAfter);
          if (seconds != null) {
            retryAfterDuration = Duration(seconds: seconds);
          }
        }
        throw RateLimitException(
          message: message,
          request: requestMeta,
          response: responseMeta,
          retryAfter: retryAfterDuration,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
      default:
        throw ApiException(
          message: message,
          request: requestMeta,
          response: responseMeta,
        );
    }
  }

  /// Redacts sensitive header values.
  Map<String, String> _redactHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }

  /// Truncates body to specified length with ellipsis.
  String _truncateBody(String body, int maxLength) {
    if (body.length <= maxLength) return body;
    return '${body.substring(0, maxLength)}...';
  }
}
