import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/retry_after.dart';
import 'exceptions.dart';

/// Parsed and sanitized provider error diagnostics.
typedef ParsedApiErrorBody = ({
  String message,
  List<Object> details,
  Map<String, dynamic>? errorDetails,
  String? errorCode,
  String? requestId,
});

/// Reads the provider error envelope, retaining existing message and type
/// behavior for malformed or legacy responses.
ParsedApiErrorBody parseApiErrorBody(
  String body, {
  Set<String> credentials = const {},
  bool legacyResourceMessage = false,
}) {
  if (body.isEmpty) {
    return (
      message: legacyResourceMessage ? body : 'Unknown error',
      details: const [],
      errorDetails: null,
      errorCode: null,
      requestId: null,
    );
  }
  String? requestId;
  try {
    final decoded = jsonDecode(body);
    requestId = switch (decoded) {
      {'request_id': final String id} when id.trim().isNotEmpty =>
        redactCredentialEcho(id, credentials),
      _ => null,
    };
    if (decoded case {'error': final Map<String, dynamic> error}) {
      final message = error['message'] as String?;
      final type = legacyResourceMessage
          ? null
          : redactCredentialEcho(error['type'] as String?, credentials);
      final details = error['details'];
      return (
        message: message != null
            ? _redactDiagnosticText(message, credentials)
            : legacyResourceMessage
            ? _safeFallbackMessage(body, credentials)
            : 'Unknown error',
        details: type == null ? const [] : <Object>[type],
        errorDetails: details is Map<String, dynamic>
            ? _redactDiagnosticMap(details, credentials)
            : null,
        errorCode: redactCredentialEcho(
          _providerErrorCode(details),
          credentials,
        ),
        requestId: requestId,
      );
    }
    if (decoded case {
      'message': final String message,
    } when !legacyResourceMessage) {
      return (
        message: _redactDiagnosticText(message, credentials),
        details: const [],
        errorDetails: null,
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
    message: _safeFallbackMessage(body, credentials),
    details: const [],
    errorDetails: null,
    errorCode: null,
    requestId: requestId,
  );
}

String _safeFallbackMessage(String body, Set<String> credentials) =>
    _bodyContainsCredential(body, credentials)
    ? 'API error response contained a redacted credential'
    : body;

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
  Set<String> credentials = const {},
}) => ResponseMetadata(
  statusCode: statusCode,
  headers: Map.unmodifiable({
    for (final entry in headers.entries)
      if (const {
        'request-id',
        'retry-after',
        'retry-after-ms',
      }.contains(entry.key.toLowerCase()))
        if (redactCredentialEcho(entry.value, credentials)
            case final String value)
          entry.key.toLowerCase(): value,
  }),
  bodyExcerpt: '',
  latency: latency,
  bodyRequestId: redactCredentialEcho(bodyRequestId, credentials),
);

/// Omits diagnostic values that echo an effective request credential.
String? redactCredentialEcho(String? value, Set<String> credentials) =>
    value != null && credentials.any(value.contains) ? null : value;

/// A bounded excerpt that omits responses containing echoed credentials.
String apiErrorBodyExcerpt(String body, Set<String> credentials) {
  if (_bodyContainsCredential(body, credentials)) return '';
  return body.length <= 200 ? body : '${body.substring(0, 200)}...';
}

bool _bodyContainsCredential(String body, Set<String> credentials) {
  if (credentials.isEmpty) return false;
  if (redactCredentialEcho(body, credentials) == null) return true;
  try {
    return _containsCredential(jsonDecode(body), credentials);
  } on FormatException {
    return false;
  }
}

bool _containsCredential(Object? value, Set<String> credentials) =>
    switch (value) {
      String() => redactCredentialEcho(value, credentials) == null,
      List<Object?>() => value.any(
        (item) => _containsCredential(item, credentials),
      ),
      Map<String, dynamic>() => value.entries.any(
        (entry) =>
            _containsCredential(entry.key, credentials) ||
            _containsCredential(entry.value, credentials),
      ),
      _ => false,
    };

String _redactDiagnosticText(String value, Set<String> credentials) {
  var redacted = value;
  for (final credential in credentials) {
    redacted = redacted.replaceAll(credential, '[REDACTED]');
  }
  return redacted;
}

Map<String, dynamic> _redactDiagnosticMap(
  Map<String, dynamic> value,
  Set<String> credentials, {
  bool omitEchoedIdentifiers = false,
}) => Map.unmodifiable({
  for (final entry in value.entries)
    if (redactCredentialEcho(entry.key, credentials) != null &&
        !(omitEchoedIdentifiers &&
            const {'request_id', 'error_code', 'type'}.contains(entry.key) &&
            entry.value is String &&
            redactCredentialEcho(entry.value as String, credentials) == null))
      entry.key: _redactDiagnosticValue(
        entry.value,
        credentials,
        omitEchoedIdentifiers: omitEchoedIdentifiers,
      ),
});

Object? _redactDiagnosticValue(
  Object? value,
  Set<String> credentials, {
  bool omitEchoedIdentifiers = false,
}) => switch (value) {
  String() => _redactDiagnosticText(value, credentials),
  List<Object?>() => List<Object?>.unmodifiable(
    value.map(
      (item) => _redactDiagnosticValue(
        item,
        credentials,
        omitEchoedIdentifiers: omitEchoedIdentifiers,
      ),
    ),
  ),
  Map<String, dynamic>() => _redactDiagnosticMap(
    value,
    credentials,
    omitEchoedIdentifiers: omitEchoedIdentifiers,
  ),
  _ => value,
};

/// Sanitizes the error envelope before handing it to an event decoder.
Map<String, dynamic> redactApiErrorEnvelope(
  Map<String, dynamic> envelope,
  Set<String> credentials,
) {
  if (credentials.isEmpty || !_containsCredential(envelope, credentials)) {
    return envelope;
  }
  return {
    ..._redactDiagnosticMap(envelope, credentials, omitEchoedIdentifiers: true),
    // Protocol discriminators are independent of the provider diagnostics.
    if (envelope['type'] == 'error') 'type': 'error',
    if (envelope['_event'] == 'error') '_event': 'error',
  };
}

/// Provides a safe body to custom error factories while retaining its shape.
String redactApiErrorBody(String body, Set<String> credentials) {
  if (credentials.isEmpty) return body;
  try {
    final decoded = jsonDecode(body);
    if (!_containsCredential(decoded, credentials)) return body;
    return jsonEncode(
      decoded is Map<String, dynamic>
          ? redactApiErrorEnvelope(decoded, credentials)
          : _redactDiagnosticValue(decoded, credentials),
    );
  } on FormatException {
    return _redactDiagnosticText(body, credentials);
  }
}

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
  ResponseMetadata responseMetadata, {
  Set<String> credentials = const {},
}) {
  final parsed = parseApiErrorBody(
    body,
    credentials: credentials,
    legacyResourceMessage: true,
  );
  return switch (statusCode) {
    400 => ValidationException(
      message: parsed.message,
      errorCode: parsed.errorCode,
      errorDetails: parsed.errorDetails,
      fieldErrors: const {},
      responseMetadata: responseMetadata,
    ),
    401 => AuthenticationException(
      message: parsed.message,
      errorCode: parsed.errorCode,
      errorDetails: parsed.errorDetails,
      responseMetadata: responseMetadata,
    ),
    429 => RateLimitException(
      statusCode: statusCode,
      message: parsed.message,
      errorCode: parsed.errorCode,
      errorDetails: parsed.errorDetails,
      responseMetadata: responseMetadata,
      retryAfter: retryAfterTime(responseMetadata.headers),
    ),
    _ => ApiException(
      statusCode: statusCode,
      message: parsed.message,
      errorCode: parsed.errorCode,
      errorDetails: parsed.errorDetails,
      responseMetadata: responseMetadata,
    ),
  };
}
