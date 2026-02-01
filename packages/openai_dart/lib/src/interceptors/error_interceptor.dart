import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../platform/http_utils.dart';
import 'interceptor.dart';

/// Interceptor that handles error responses from the API.
///
/// This interceptor examines HTTP responses and throws appropriate
/// exceptions for error status codes. It parses the OpenAI error
/// response format to provide detailed error information.
///
/// ## OpenAI Error Response Format
///
/// ```json
/// {
///   "error": {
///     "message": "Error description",
///     "type": "invalid_request_error",
///     "param": "model",
///     "code": "model_not_found"
///   }
/// }
/// ```
class ErrorInterceptor implements Interceptor {
  /// Creates an [ErrorInterceptor].
  const ErrorInterceptor();

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final response = await next(context);

    // Check for error status codes
    if (response.statusCode >= 400) {
      throw _parseErrorResponse(response);
    }

    return response;
  }

  /// Parses an error response and creates the appropriate exception.
  ApiException _parseErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    final requestId = response.headers['x-request-id'];
    final retryAfter = _parseRetryAfter(response.headers['retry-after']);

    // Try to parse the error body
    String message;
    String? type;
    String? code;
    String? param;
    Map<String, dynamic>? body;

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      body = json;

      if (json['error'] case final Map<String, dynamic> error) {
        message = error['message'] as String? ?? 'Unknown error';
        type = error['type'] as String?;
        code = error['code'] as String?;
        param = error['param'] as String?;
      } else {
        message = json['message'] as String? ?? response.body;
      }
    } catch (_) {
      // Fallback to raw body if JSON parsing fails
      message = response.body.isNotEmpty
          ? response.body
          : 'HTTP $statusCode error';
    }

    return createApiException(
      statusCode: statusCode,
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      retryAfter: retryAfter,
    );
  }

  /// Parses the Retry-After header value.
  ///
  /// Supports both seconds (`"120"`) and HTTP-date formats (RFC 7231).
  /// Trims whitespace before parsing. Returns null if parsing fails.
  Duration? _parseRetryAfter(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Trim whitespace
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    // Try parsing as seconds
    final seconds = int.tryParse(trimmed);
    if (seconds != null) {
      return Duration(seconds: seconds);
    }

    // Try parsing as HTTP-date using platform-specific implementation
    // which supports IMF-fixdate, RFC 850, and ANSI C formats
    try {
      final date = parseHttpDate(trimmed);
      final now = DateTime.now().toUtc();
      if (date.isAfter(now)) {
        return date.difference(now);
      }
    } catch (_) {
      // Ignore parse errors
    }

    return null;
  }
}
