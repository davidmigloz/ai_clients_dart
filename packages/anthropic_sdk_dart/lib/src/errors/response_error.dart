import 'dart:convert';

import 'exceptions.dart';

/// Reads the provider error envelope, retaining existing message and type
/// behavior for malformed or legacy responses.
({String message, List<Object> details, String? errorCode}) parseApiErrorBody(
  String body,
) {
  if (body.isEmpty) {
    return (message: 'Unknown error', details: const [], errorCode: null);
  }
  try {
    final decoded = jsonDecode(body);
    if (decoded case {'error': final Map<String, dynamic> error}) {
      final message = error['message'] as String? ?? 'Unknown error';
      final type = error['type'] as String?;
      final details = error['details'];
      return (
        message: message,
        details: type == null ? const [] : <Object>[type],
        errorCode: switch (details) {
          {'error_code': final String code} => code,
          _ => null,
        },
      );
    }
    if (decoded case {'message': final String message}) {
      return (message: message, details: const [], errorCode: null);
    }
  } on FormatException {
    // Some proxies return an error body that isn't JSON.
  } on TypeError {
    // Preserve the fallback if the error envelope has unexpected types.
  }
  return (message: body, details: const [], errorCode: null);
}

/// Retains useful response diagnostics without copying sensitive content.
ResponseMetadata createSafeResponseMetadata({
  required int statusCode,
  required Map<String, String> headers,
  required Duration latency,
}) => ResponseMetadata(
  statusCode: statusCode,
  headers: Map.unmodifiable({
    for (final entry in headers.entries)
      if (const {'request-id', 'retry-after'}.contains(entry.key.toLowerCase()))
        entry.key.toLowerCase(): entry.value,
  }),
  bodyExcerpt: '',
  latency: latency,
);

/// Parses a retry delay without allowing oversized values to mask an API error.
DateTime? parseRetryAfter(Map<String, String> headers) {
  final value = headers['retry-after']?.trim();
  if (value == null) return null;
  if (!RegExp(r'^-?\d+$').hasMatch(value)) {
    return DateTime.tryParse(value);
  }
  final seconds = int.tryParse(value);
  if (seconds == null || seconds < 0) return null;
  final duration = Duration(seconds: seconds);
  if (duration.inSeconds != seconds) return null;
  try {
    return DateTime.now().add(duration);
  } on ArgumentError {
    return null;
  }
}

/// Creates an error for resource requests that historically treat 400 as
/// validation errors, preserving their existing exception types and messages.
AnthropicException createResourceException(
  int statusCode,
  String body,
  ResponseMetadata responseMetadata,
) {
  String message;
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final error = json['error'] as Map<String, dynamic>?;
    message = error?['message'] as String? ?? body;
  } catch (_) {
    message = body;
  }
  return switch (statusCode) {
    400 => ValidationException(
      message: message,
      fieldErrors: const {},
      responseMetadata: responseMetadata,
    ),
    401 => AuthenticationException(
      message: message,
      responseMetadata: responseMetadata,
    ),
    429 => RateLimitException(
      statusCode: statusCode,
      message: message,
      responseMetadata: responseMetadata,
      retryAfter: parseRetryAfter(responseMetadata.headers),
    ),
    _ => ApiException(
      statusCode: statusCode,
      message: message,
      responseMetadata: responseMetadata,
    ),
  };
}
