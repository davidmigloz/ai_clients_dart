import 'package:http/http.dart' as http;

import '../utils/http_error_response.dart';
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
      throw parseHttpErrorResponse(response, request: context.request);
    }

    return response;
  }
}
