import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../utils/request_id.dart';
import 'interceptor.dart';

/// Interceptor that logs HTTP requests and responses.
///
/// Adds `X-Request-ID` header if not already present.
/// Logs request/response details based on configured log level.
class LoggingInterceptor implements Interceptor {
  /// Logger instance.
  final Logger _logger;

  /// Log level.
  final Level logLevel;

  /// Fields to redact in logs.
  final List<String> redactionList;

  /// Creates a [LoggingInterceptor].
  LoggingInterceptor({required this.logLevel, required this.redactionList})
    : _logger = Logger('mistralai_dart');

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    final startTime = DateTime.now();

    // Add request ID if not present
    final requestId =
        context.request.headers['X-Request-ID'] ?? generateRequestId();

    final request = _ensureRequestId(context.request, requestId);

    // Store correlation ID in metadata
    final metadata = Map<String, dynamic>.from(context.metadata)
      ..['correlationId'] = requestId;

    // Log request
    if (_logger.level <= logLevel) {
      _logRequest(request, requestId);
    }

    try {
      final response = await next(
        context.copyWith(request: request, metadata: metadata),
      );

      // Log response
      if (_logger.level <= logLevel) {
        final duration = DateTime.now().difference(startTime);
        _logResponse(response, requestId, duration);
      }

      return response;
    } catch (e) {
      // Log error
      if (_logger.level <= logLevel) {
        final duration = DateTime.now().difference(startTime);
        _logError(e, requestId, duration);
      }
      rethrow;
    }
  }

  /// Ensures request has X-Request-ID header.
  http.BaseRequest _ensureRequestId(
    http.BaseRequest original,
    String requestId,
  ) {
    if (original.headers.containsKey('X-Request-ID')) {
      return original;
    }

    if (original is http.Request) {
      final copy = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers['X-Request-ID'] = requestId
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;

      if (original.body.isNotEmpty) {
        copy.body = original.body;
      }

      return copy;
    }

    // For other request types, try to add header directly
    original.headers['X-Request-ID'] = requestId;
    return original;
  }

  /// Logs request details.
  void _logRequest(http.BaseRequest request, String requestId) {
    final redactedHeaders = _redactHeaders(request.headers);
    _logger.info(
      '[$requestId] --> ${request.method} ${request.url}\n'
      '[$requestId] Headers: $redactedHeaders',
    );
  }

  /// Logs response details.
  void _logResponse(
    http.Response response,
    String requestId,
    Duration duration,
  ) {
    _logger.info(
      '[$requestId] <-- ${response.statusCode} (${duration.inMilliseconds}ms)',
    );
  }

  /// Logs error details.
  void _logError(Object error, String requestId, Duration duration) {
    _logger.warning(
      '[$requestId] <-- ERROR (${duration.inMilliseconds}ms): $error',
    );
  }

  /// Redacts sensitive headers.
  Map<String, String> _redactHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (redactionList.any((r) => lowerKey.contains(r.toLowerCase()))) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}
