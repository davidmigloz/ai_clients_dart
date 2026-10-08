import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/retry_after.dart';
import '../errors/exceptions.dart';
import '../utils/webhooks/signing_secret_redaction.dart';
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
      throw _parseErrorResponse(
        response,
        secretBearingResponse: revealsWebhookSigningSecret(context.request),
      );
    }

    return response;
  }

  /// Parses an error response and creates the appropriate exception.
  ApiException _parseErrorResponse(
    http.Response response, {
    required bool secretBearingResponse,
  }) {
    final statusCode = response.statusCode;
    final requestId = response.headers['x-request-id'];
    final retryAfter = parseRetryAfter(response.headers);

    final diagnosticBody = redactWebhookSigningSecretBody(
      response.body,
      secretBearingResponse: secretBearingResponse,
    );

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
        message = error['message'] == null
            ? 'Unknown error'
            : _errorString(error['message']) ?? diagnosticBody;
        type = _errorString(error['type']);
        code = _errorString(error['code']);
        param = _errorString(error['param']);
      } else {
        message = _errorString(json['message']) ?? diagnosticBody;
      }
    } catch (_) {
      // Keep unrelated raw-body behavior; omit malformed secret-bearing bodies.
      message = diagnosticBody.isNotEmpty
          ? diagnosticBody
          : 'HTTP $statusCode error';
    }

    return createApiException(
      statusCode: statusCode,
      message: redactWebhookSecretErrorValue(message, body)!,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      retryAfter: retryAfter,
    );
  }
}

String? _errorString(Object? value) => value is String ? value : null;
