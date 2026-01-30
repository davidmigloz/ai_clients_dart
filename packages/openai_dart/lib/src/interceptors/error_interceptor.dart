import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
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
  Duration? _parseRetryAfter(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Try parsing as seconds
    final seconds = int.tryParse(value);
    if (seconds != null) {
      return Duration(seconds: seconds);
    }

    // Try parsing as HTTP-date (simplified)
    try {
      final date = HttpDate.parse(value);
      final now = DateTime.now();
      if (date.isAfter(now)) {
        return date.difference(now);
      }
    } catch (_) {
      // Ignore parse errors
    }

    return null;
  }
}

/// Utility class for parsing HTTP dates.
///
/// Supports RFC 7231 date formats:
/// - IMF-fixdate: `Sun, 06 Nov 1994 08:49:37 GMT`
/// - RFC 850: `Sunday, 06-Nov-94 08:49:37 GMT`
/// - ANSI C: `Sun Nov  6 08:49:37 1994`
class HttpDate {
  HttpDate._();

  static const _months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };

  /// Parses an HTTP date string.
  static DateTime parse(String value) {
    // IMF-fixdate: "Sun, 06 Nov 1994 08:49:37 GMT"
    final imfRegex = RegExp(
      r'^[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
    );

    final match = imfRegex.firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid HTTP date: $value');
    }

    final day = int.parse(match.group(1)!);
    final month = _months[match.group(2)!]!;
    final year = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);

    return DateTime.utc(year, month, day, hour, minute, second);
  }
}
