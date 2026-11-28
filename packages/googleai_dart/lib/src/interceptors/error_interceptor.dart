import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';
import '../utils/redactor.dart';
import '../utils/request_id.dart';
import 'interceptor.dart';

/// Interceptor that maps HTTP errors to domain exceptions.
class ErrorInterceptor implements Interceptor {
  /// Creates an [ErrorInterceptor].
  const ErrorInterceptor();

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final startTime = DateTime.now();

    try {
      final response = await next(context);

      // Check for HTTP errors
      if (response.statusCode >= 400) {
        final latency = DateTime.now().difference(startTime);
        throw _mapHttpError(response, context, latency);
      }

      return response;
    } on GoogleAIException {
      // Re-throw our own exceptions
      rethrow;
    } catch (error, stackTrace) {
      // Wrap unknown errors
      final description = error.toString();
      final safeDescription =
          context.diagnosticRedactor?.redactString(description) ?? description;
      throw ApiException(
        statusCode: 0,
        message: 'Unexpected error: $safeDescription',
        stackTrace: stackTrace,
      );
    }
  }

  /// Maps HTTP response to appropriate exception.
  GoogleAIException _mapHttpError(
    http.Response response,
    RequestContext context,
    Duration latency,
  ) {
    final statusCode = response.statusCode;
    final body = response.body;
    final scopedRedactor = context.diagnosticRedactor;

    // Try to parse error details from response body
    var excerptSource = body;
    var message = 'HTTP $statusCode error';
    final details = <Object>[];

    try {
      final decoded = jsonDecode(body);
      final continuationSafe = Redactor.continuationTokens.redactJson(decoded);
      final errorDetails = scopedRedactor == null
          ? continuationSafe
          : scopedRedactor.redactJson(continuationSafe);
      if (!identical(decoded, errorDetails)) {
        excerptSource = jsonEncode(errorDetails);
      }
      if (errorDetails is Map<String, dynamic>) {
        final error = errorDetails['error'];
        if (error is Map<String, dynamic>) {
          message = error['message']?.toString() ?? message;
          final errorDetailsList = error['details'];
          if (errorDetailsList is List) {
            details.addAll(errorDetailsList.cast<Object>());
          }
        }
      }
    } catch (_) {
      // If body is not JSON, use it as message if short enough
      if (body.length < 200) {
        message = body.isNotEmpty ? body : message;
      }
    }
    message = Redactor.continuationTokens.redactString(message);
    if (scopedRedactor != null) message = scopedRedactor.redactString(message);

    // Extract request metadata from context
    final correlationId =
        context.metadata['correlationId'] as String? ??
        context.request.headers['X-Request-ID'] ??
        generateRequestId();
    final timestamp =
        context.metadata['timestamp'] as DateTime? ?? DateTime.now();
    final attemptNumber = context.metadata['attemptNumber'] as int? ?? 0;

    // Redact sensitive headers
    const redactor = Redactor(
      redactionList: [
        'authorization',
        'api-key',
        'api_key',
        'x-goog-api-key',
        'token',
        ...Redactor.continuationTokenFields,
      ],
    );
    final redactedHeaders = redactor.redactMap(context.request.headers);

    // Create request metadata
    final requestMetadata = RequestMetadata(
      method: context.request.method,
      url:
          scopedRedactor?.redactUri(context.request.url) ?? context.request.url,
      headers: scopedRedactor?.redactMap(redactedHeaders) ?? redactedHeaders,
      correlationId: correlationId,
      timestamp: timestamp,
      attemptNumber: attemptNumber,
    );

    // Create response metadata
    final safeBody = redactor.redactString(
      scopedRedactor?.redactBody(excerptSource) ?? excerptSource,
    );
    final responseMetadata = ResponseMetadata(
      statusCode: statusCode,
      headers: scopedRedactor?.redactMap(response.headers) ?? response.headers,
      bodyExcerpt: safeBody.length > 200
          ? safeBody.substring(0, 200)
          : safeBody,
      latency: latency,
    );

    // Map to specific exception types
    if (statusCode == 401) {
      // Authentication error
      return AuthenticationException(
        message: message,
        details: details,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
      );
    }

    if (statusCode == 429) {
      // Rate limit error
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
        details: details,
        retryAfter: retryAfter,
        requestMetadata: requestMetadata,
        responseMetadata: responseMetadata,
      );
    }

    // Generic API exception
    return ApiException(
      statusCode: statusCode,
      message: message,
      details: details,
      requestMetadata: requestMetadata,
      responseMetadata: responseMetadata,
    );
  }
}
