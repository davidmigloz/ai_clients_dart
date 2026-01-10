import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../utils/request_id.dart';
import 'interceptor.dart';

/// Interceptor that logs requests and responses.
///
/// This interceptor:
/// - Adds a unique `X-Request-ID` header if not already present
/// - Logs request details (method, URL, headers)
/// - Logs response details (status, timing, headers)
/// - Redacts sensitive headers (Authorization, x-chroma-token)
///
/// Log levels used:
/// - [Level.FINE]: Request/response details
/// - [Level.FINER]: Headers (with redaction)
/// - [Level.FINEST]: Full response body
class LoggingInterceptor implements Interceptor {
  static final _log = Logger('chromadb.http');

  /// Headers that should have their values redacted in logs.
  static const _sensitiveHeaders = {
    'authorization',
    'x-chroma-token',
    'x-api-key',
  };

  /// Creates a logging interceptor.
  const LoggingInterceptor();

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    // Use existing X-Request-ID if present, otherwise generate one
    final requestId = context.headers['X-Request-ID'] ?? generateRequestId();
    if (!context.headers.containsKey('X-Request-ID')) {
      context.headers['X-Request-ID'] = requestId;
    }

    final stopwatch = Stopwatch()..start();

    _logRequest(requestId, context);

    try {
      final response = await next(context);
      stopwatch.stop();
      _logResponse(requestId, response, stopwatch.elapsed);
      return response;
    } catch (e) {
      stopwatch.stop();
      _logError(requestId, e, stopwatch.elapsed);
      rethrow;
    }
  }

  void _logRequest(String requestId, RequestContext context) {
    _log.fine('[$requestId] → ${context.method} ${context.path}');

    if (context.queryParameters.isNotEmpty) {
      _log.finer('[$requestId] Query: ${context.queryParameters}');
    }

    if (context.headers.isNotEmpty) {
      final redacted = _redactHeaders(context.headers);
      _log.finer('[$requestId] Headers: $redacted');
    }
  }

  void _logResponse(
    String requestId,
    http.Response response,
    Duration elapsed,
  ) {
    _log.fine(
      '[$requestId] ← ${response.statusCode} ${response.reasonPhrase} '
      '(${elapsed.inMilliseconds}ms)',
    );

    if (response.headers.isNotEmpty) {
      final redacted = _redactHeaders(response.headers);
      _log.finer('[$requestId] Headers: $redacted');
    }

    if (response.body.isNotEmpty) {
      _log.finest('[$requestId] Body: ${response.body}');
    }
  }

  void _logError(String requestId, Object error, Duration elapsed) {
    _log.fine('[$requestId] ✗ Error after ${elapsed.inMilliseconds}ms: $error');
  }

  Map<String, String> _redactHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}
