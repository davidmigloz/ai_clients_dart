import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';
import '../utils/diagnostic_body.dart';
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
    final restrictBody = context.skipResponseBodyDiagnostics;
    final body = restrictBody ? '' : readDiagnosticBody(response);
