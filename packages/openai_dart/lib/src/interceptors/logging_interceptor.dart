import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../utils/monitoring_error_redaction.dart';
import '../utils/request_id.dart';
import '../utils/speech_redaction.dart';
import '../utils/webhooks/signing_secret_redaction.dart';
import 'interceptor.dart';

/// Interceptor that logs HTTP requests and responses.
///
/// This interceptor logs request and response information at various
/// log levels for debugging and monitoring purposes.
///
/// ## Log Levels
///
/// - [Level.FINE]: Request/response headers and timing
/// - [Level.FINER]: Request/response bodies (truncated)
/// - [Level.FINEST]: Full request/response bodies
///
/// ## Example
///
/// ```dart
/// final interceptor = LoggingInterceptor(
///   logger: Logger('OpenAI'),
/// );
/// ```
class LoggingInterceptor implements Interceptor {
  /// Creates a [LoggingInterceptor] with the given logger.
  const LoggingInterceptor({
    required this.logger,
    this.logRequestBody = false,
    this.logResponseBody = false,
    this.maxBodyLength = 1000,
  });

  /// The logger to use for output.
  final Logger logger;

  /// Whether to log request bodies.
  final bool logRequestBody;

  /// Whether to log response bodies.
  final bool logResponseBody;

  /// Maximum length of body to log before truncating.
  final int maxBodyLength;

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    var request = context.request;
    final speechRequest = isSpeechRequest(request);
    final privateAudioRequest = isPrivateAudioRequest(request);
    final privateVoiceRequest =
        isVoiceConsentRequest(request) ||
        isCustomVoiceRequest(request) ||
        isLiveRequest(request);
    final diagnosticUrl = privateVoiceRequest
        ? '[REDACTED]'
        : request.url.toString();
    final startTime = DateTime.now();

    // Ensure request has a correlation ID for tracing
    final correlationId =
        request.headers['X-Request-ID'] ?? generateRequestId();
    if (!request.headers.containsKey('X-Request-ID')) {
      // Add the request ID if not already present
      request = _cloneRequestWithHeader(request, 'X-Request-ID', correlationId);
    }

    // Update context with the potentially modified request and add metadata
    final updatedContext = context.copyWith(
      request: request,
      metadata: {
        ...context.metadata,
        'correlationId': correlationId,
        'startTime': startTime,
      },
    );

    // Log request
    final diagnosticCorrelationId = privateVoiceRequest
        ? '[REDACTED]'
        : correlationId;
    logger
      ..fine('→ ${request.method} $diagnosticUrl [$diagnosticCorrelationId]')
      ..finer(
        '  Headers: ${privateVoiceRequest ? '[REDACTED]' : _sanitizeHeaders(request.headers)}',
      );

    if (logRequestBody && request is http.Request && request.body.isNotEmpty) {
      logger.finest(
        '  Body: ${isLiveRequest(request)
            ? '[REDACTED Live request]'
            : privateAudioRequest
            ? '[REDACTED audio request]'
            : _truncate(request.body)}',
      );
    }

    try {
      final response = await next(updatedContext);

      // Monitoring response values remain caller-readable but stay out of logs.
      final responseText = privateAudioRequest
          ? ''
          : _diagnosticResponseText(response);
      final monitoringBody = redactMonitoringErrorBody(responseText);
      final monitoringResponse = monitoringBody != responseText;
      // Log response
      final duration = DateTime.now().difference(startTime);
      final requestId = privateAudioRequest
          ? correlationId
          : response.headers['x-request-id'] ?? correlationId;
      final diagnosticResponseId = monitoringResponse || privateVoiceRequest
          ? '[REDACTED]'
          : requestId;
      logger
        ..fine(
          '← ${response.statusCode} ${monitoringResponse ? '[REDACTED]' : diagnosticUrl} (${duration.inMilliseconds}ms) [$diagnosticResponseId]',
        )
        ..finer(
          '  Headers: ${monitoringResponse || privateAudioRequest ? '[REDACTED]' : response.headers}',
        );

      if (logResponseBody && privateAudioRequest) {
        logger.finest(
          '  Body: ${isLiveRequest(request)
              ? '[REDACTED Live response]'
              : speechRequest
              ? '[REDACTED speech response]'
              : '[REDACTED audio response]'}',
        );
      } else if (logResponseBody && responseText.isNotEmpty) {
        final diagnosticBody = redactMonitoringErrorBody(
          redactWebhookSigningSecretBody(
            responseText,
            secretBearingResponse: revealsWebhookSigningSecret(request),
          ),
        );
        logger.finest('  Body: ${_truncate(diagnosticBody)}');
      }

      return response;
    } catch (e) {
      // Log error
      final duration = DateTime.now().difference(startTime);
      final diagnosticError = privateAudioRequest ? e.runtimeType : e;
      logger.warning(
        '✕ ${request.method} $diagnosticUrl failed after ${duration.inMilliseconds}ms [$diagnosticCorrelationId]: $diagnosticError',
      );
      rethrow;
    }
  }

  /// Clones a request and adds a header.
  http.BaseRequest _cloneRequestWithHeader(
    http.BaseRequest original,
    String key,
    String value,
  ) {
    if (original is http.Request) {
      final cloned = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers[key] = value
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
      if (original.body.isNotEmpty) {
        cloned.body = original.body;
      }
      return cloned;
    } else if (original is http.MultipartRequest) {
      final cloned = http.MultipartRequest(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers[key] = value
        ..fields.addAll(original.fields)
        ..files.addAll(original.files)
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects
        ..persistentConnection = original.persistentConnection;
      return cloned;
    } else {
      // For other request types, modify in place (may not work for all types)
      original.headers[key] = value;
      return original;
    }
  }

  /// Sanitizes headers by redacting sensitive values.
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    const sensitiveHeaders = {
      'authorization',
      'x-api-key',
      'api-key',
      'openai-api-key',
    };

    return headers.map((key, value) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        // Show first and last few characters for debugging
        if (value.length > 10) {
          return MapEntry(
            key,
            '${value.substring(0, 4)}...${value.substring(value.length - 4)}',
          );
        }
        return MapEntry(key, '****');
      }
      return MapEntry(key, value);
    });
  }

  /// Truncates a string if it exceeds the maximum length.
  String _truncate(String value) {
    if (value.length <= maxBodyLength) {
      return value;
    }
    return '${value.substring(0, maxBodyLength)}... (truncated)';
  }
}

// Diagnostics must not make binary or malformed response decoding a failure.
String _diagnosticResponseText(http.Response response) {
  try {
    return response.body;
  } on FormatException {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }
}
