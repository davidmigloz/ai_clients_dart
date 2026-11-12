import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/retry_after.dart';
import 'exceptions.dart';

/// Reads the provider error envelope, retaining existing message and type
/// behavior for malformed or legacy responses.
({String message, List<Object> details, String? errorCode, String? requestId})
parseApiErrorBody(String body) {
  if (body.isEmpty) {
    return (
      message: 'Unknown error',
      details: const [],
      errorCode: null,
      requestId: null,
    );
  }
  String? requestId;
  try {
    final decoded = jsonDecode(body);
    requestId = switch (decoded) {
      {'request_id': final String id} when id.trim().isNotEmpty => id,
      _ => null,
    };
    if (decoded case {'error': final Map<String, dynamic> error}) {
      final message = error['message'] as String? ?? 'Unknown error';
      final type = error['type'] as String?;
      return (
        message: message,
        details: type == null ? const [] : <Object>[type],
        errorCode: _providerErrorCode(error['details']),
        requestId: requestId,
      );
    }
    if (decoded case {'message': final String message}) {
      return (
        message: message,
        details: const [],
        errorCode: null,
        requestId: requestId,
      );
    }
  } on FormatException {
    // Some proxies return an error body that isn't JSON.
  } on TypeError {
    // Preserve the fallback if the error envelope has unexpected types.
  }
  return (
    message: body,
    details: const [],
    errorCode: null,
    requestId: requestId,
  );
}

String? _providerErrorCode(Object? details) => switch (details) {
  {'error_code': final String code} => code,
  _ => null,
};

/// Retains useful response diagnostics without copying sensitive content.
ResponseMetadata createSafeResponseMetadata({
  required int statusCode,
  required Map<String, String> headers,
  required Duration latency,
  String? bodyRequestId,
}) => ResponseMetadata(
  statusCode: statusCode,
  headers: Map.unmodifiable({
    for (final entry in headers.entries)
      if (const {
        'request-id',
        'retry-after',
        'retry-after-ms',
      }.contains(entry.key.toLowerCase()))
        entry.key.toLowerCase(): entry.value,
  }),
  bodyExcerpt: '',
  latency: latency,
  bodyRequestId: bodyRequestId,
);

/// Reads HTTP error text even when the response charset decoder fails.
String decodeApiErrorResponse(http.Response response) {
  try {
    return response.body;
  } on FormatException {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }
}

/// Decodes failed streaming responses with the declared charset or UTF-8.
String decodeStreamingApiErrorBody(
  List<int> bytes,
  Map<String, String> headers,
) {
  final contentType = _headerValue(headers, 'content-type');
  if (contentType != null) {
    try {
      final charset = http.MediaType.parse(contentType).parameters['charset'];
      final encoding = Encoding.getByName(charset);
      if (encoding != null) return encoding.decode(bytes);
    } on FormatException {
      // Preserve the error diagnostics if a proxy sends invalid metadata or bytes.
    }
  }
  return utf8.decode(bytes, allowMalformed: true);
}

/// Converts server retry guidance to the timestamp exposed by exceptions.
DateTime? retryAfterTime(Map<String, String> headers) {
  final now = DateTime.now();
  final delay = parseRetryAfter(headers, now: now);
  if (delay != null) return now.add(delay);
  // Keep legacy ISO deadlines on the exception without scheduling retries
  // from that nonstandard format. Numeric overflow must stay invalid.
  final legacy = _headerValue(headers, 'retry-after')?.trim();
  if (legacy == null || double.tryParse(legacy) != null) return null;
  return DateTime.tryParse(legacy);
}

String? _headerValue(Map<String, String> headers, String name) {
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == name) return entry.value;
  }
  return null;
}

/// Creates an error for resource requests that historically treat 400 as
/// validation errors, preserving their existing exception types and messages.
AnthropicException createResourceException(
  int statusCode,
  String body,
  ResponseMetadata responseMetadata,
) {
  String message;
  String? errorCode;
  Map<String, dynamic>? errorDetails;
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final error = json['error'] as Map<String, dynamic>?;
    message = error?['message'] as String? ?? body;
    final providerDetails = error?['details'];
    errorCode = _providerErrorCode(providerDetails);
    if (providerDetails is Map<String, dynamic>) {
      errorDetails = Map.unmodifiable(providerDetails);
    }
  } catch (_) {
    message = body;
  }
  return switch (statusCode) {
    400 => ValidationException(
      message: message,
      errorCode: errorCode,
      errorDetails: errorDetails,
      fieldErrors: const {},
      responseMetadata: responseMetadata,
    ),
    401 => AuthenticationException(
      message: message,
      errorCode: errorCode,
      responseMetadata: responseMetadata,
    ),
    429 => RateLimitException(
      statusCode: statusCode,
      message: message,
      errorCode: errorCode,
      responseMetadata: responseMetadata,
      retryAfter: retryAfterTime(responseMetadata.headers),
    ),
    _ => ApiException(
      statusCode: statusCode,
      message: message,
      errorCode: errorCode,
      responseMetadata: responseMetadata,
    ),
  };
}
