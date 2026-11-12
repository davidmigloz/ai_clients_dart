import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
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

    final credentials = requestCredentialValues(
      context.request.headers,
      sentHeaders: response.request?.headers,
    )..addAll(requestDiagnosticCredentials(context.request));
    final body = decodeApiErrorResponse(response);
    final parsed = parseApiErrorBody(body, credentials: credentials);
    final responseMetadata = ResponseMetadata(
      statusCode: response.statusCode,
      headers: Map.unmodifiable({
        for (final entry in response.headers.entries)
          if (redactPercentEncodedCredentialEcho(entry.key, credentials) !=
              null)
            if (redactPercentEncodedCredentialEcho(entry.value, credentials)
                case final String value)
              entry.key: value,
      }),
      bodyExcerpt: apiErrorBodyExcerpt(body, credentials),
      latency: latency,
      bodyRequestId: parsed.requestId,
    );

    // Handle authentication errors
    if (response.statusCode == 401) {
      return AuthenticationException(
        message: parsed.message,
        details: parsed.details,
        errorCode: parsed.errorCode,
        errorDetails: parsed.errorDetails,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
      );
    }

    // Handle rate limiting
    if (response.statusCode == 429) {
      return RateLimitException(
        statusCode: response.statusCode,
        message: parsed.message,
        details: parsed.details,
        errorCode: parsed.errorCode,
        errorDetails: parsed.errorDetails,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
        retryAfter: retryAfterTime(responseMetadata.headers),
      );
    }

    // General API error
    return ApiException(
      statusCode: response.statusCode,
      message: parsed.message,
      details: parsed.details,
      errorCode: parsed.errorCode,
      errorDetails: parsed.errorDetails,
      requestMetadata: requestMetadata,
      responseMetadata: responseMetadata,
    );
  }

  /// Redacts sensitive headers.
  Map<String, String> _redactHeaders(Map<String, String> headers) {
    const sensitiveKeys = [
      'api-key',
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
