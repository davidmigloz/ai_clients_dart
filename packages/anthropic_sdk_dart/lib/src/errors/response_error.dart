import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
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
        redactPercentEncodedCredentialEcho(id, credentials),
      _ => null,
    };
    if (decoded case {'error': final Map<String, dynamic> error}) {
      final message = error['message'] as String?;
      final type = legacyResourceMessage
          ? null
          : redactPercentEncodedCredentialEcho(
              error['type'] as String?,
              credentials,
            );
      final details = error['details'];
      return (
        message: message != null
            ? redactDiagnosticText(message, credentials)
            : legacyResourceMessage
            ? _safeFallbackMessage(body, credentials)
            : 'Unknown error',
        details: type == null ? const [] : <Object>[type],
        errorDetails: details is Map<String, dynamic>
            ? _redactDiagnosticMap(details, credentials)
            : null,
        errorCode: redactPercentEncodedCredentialEcho(
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
        message: redactDiagnosticText(message, credentials),
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
        'x-amzn-requestid',
        'apim-request-id',
        'retry-after',
        'retry-after-ms',
      }.contains(entry.key.toLowerCase()))
        if (redactPercentEncodedCredentialEcho(entry.value, credentials)
            case final String value)
          entry.key.toLowerCase(): value,
  }),
  bodyExcerpt: '',
  latency: latency,
  bodyRequestId: redactPercentEncodedCredentialEcho(bodyRequestId, credentials),
);

/// Omits diagnostic values that echo an effective request credential.
String? redactCredentialEcho(String? value, Set<String> credentials) =>
    value != null && credentials.any(value.contains) ? null : value;

final _percentEscapes = RegExp(r'(?:%[0-9a-fA-F]{2})+');

/// Drops diagnostics that echo credentials directly or as percent escapes.
/// Returns the original value when safe so encoded identifiers and filenames
/// retain their wire representation.
String? redactPercentEncodedCredentialEcho(
  String? value,
  Set<String> credentials,
) {
  final safe = redactCredentialEcho(value, credentials);
  if (safe == null || credentials.isEmpty || !safe.contains('%')) return safe;
  final decoded = safe.replaceAllMapped(_percentEscapes, (match) {
    final encoded = match[0]!;
    return utf8.decode([
      for (var offset = 0; offset < encoded.length; offset += 3)
        int.parse(encoded.substring(offset + 1, offset + 3), radix: 16),
    ], allowMalformed: true);
  });
  return redactCredentialEcho(decoded, credentials) == null ? null : safe;
}

/// A bounded excerpt that omits responses containing echoed credentials.
String apiErrorBodyExcerpt(String body, Set<String> credentials) {
  if (_bodyContainsCredential(body, credentials)) return '';
  return body.length <= 200 ? body : '${body.substring(0, 200)}...';
}

bool _bodyContainsCredential(String body, Set<String> credentials) =>
    _redactDiagnosticBodyText(body, credentials) != body;

bool _containsCredential(Object? value, Set<String> credentials) =>
    switch (value) {
      String() =>
        redactPercentEncodedCredentialEcho(value, credentials) == null,
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

/// Redacts effective credentials in decoded provider diagnostics.
String redactDiagnosticText(String value, Set<String> credentials) {
  var redacted = value;
  final longestFirst = credentials.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final credential in longestFirst) {
    redacted = redacted.replaceAll(credential, '[REDACTED]');
  }
  return redactPercentEncodedCredentialEcho(redacted, credentials) == null
      ? 'API error response contained a redacted credential'
      : redacted;
}

final _jsonDiagnosticEscape = RegExp(r'\\(?:u[0-9a-fA-F]{4}|["\\/bfnrt])');

/// Redacts plain credentials and detects standard JSON escapes in raw
/// diagnostics. The raw check also sees fields hidden by duplicate JSON keys.
String _redactDiagnosticBodyText(String text, Set<String> credentials) {
  if (credentials.isEmpty) return text;
  // Decode escape tokens independently so a truncated JSON envelope remains
  // checkable without relying on its quotes or structural delimiters.
  final decoded = text.replaceAllMapped(_jsonDiagnosticEscape, (match) {
    final escape = match[0]!;
    return switch (escape[1]) {
      'u' => String.fromCharCode(int.parse(escape.substring(2), radix: 16)),
      'b' => '\b',
      'f' => '\f',
      'n' => '\n',
      'r' => '\r',
      't' => '\t',
      final char => char,
    };
  });
  if (decoded != text &&
      redactPercentEncodedCredentialEcho(decoded, credentials) == null) {
    return 'API error response contained a redacted credential';
  }
  return redactDiagnosticText(text, credentials);
}

/// Keeps the parse error and position while removing an unsafe decoder source.
FormatException redactApiFormatException(
  FormatException error,
  Set<String> credentials,
) {
  if (credentials.isEmpty) return error;
  final message = _redactDiagnosticBodyText(error.message, credentials);
  final Object? source = error.source;
  final sourceText = switch (source) {
    String() => source,
    List<int>() => utf8.decode(source, allowMalformed: true),
    _ => null,
  };
  final unsafeSource =
      sourceText != null &&
      _redactDiagnosticBodyText(sourceText, credentials) != sourceText;
  if (message == error.message && !unsafeSource) return error;
  return FormatException(message, unsafeSource ? null : source, error.offset);
}

/// Removes credential echoes from JSON and typed decoding failures.
Object redactApiDecoderError(Object error, Set<String> credentials) {
  if (error is FormatException) {
    return redactApiFormatException(error, credentials);
  }
  if (error is TypeError && credentials.isNotEmpty) {
    // Web type errors can include the value from a failed JSON field cast.
    final message = error.toString();
    final safe = _redactDiagnosticBodyText(message, credentials);
    if (safe != message) return FormatException(safe);
  }
  return error;
}

Map<String, dynamic> _redactDiagnosticMap(
  Map<String, dynamic> value,
  Set<String> credentials, {
  bool omitEchoedIdentifiers = false,
}) => Map.unmodifiable({
  for (final entry in value.entries)
    if (redactPercentEncodedCredentialEcho(entry.key, credentials) != null &&
        !(omitEchoedIdentifiers &&
            const {'request_id', 'error_code', 'type'}.contains(entry.key) &&
            entry.value is String &&
            redactPercentEncodedCredentialEcho(
                  entry.value as String,
                  credentials,
                ) ==
                null))
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
  String() => redactDiagnosticText(value, credentials),
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
  if (credentials.isEmpty) return envelope;
  if (envelope case {
    '_event': 'error',
    'type': 'error',
    '_rawData': final String raw,
  } when envelope.length == 3) {
    final safe = _redactDiagnosticBodyText(raw, credentials);
    return safe == raw ? envelope : {...envelope, '_rawData': safe};
  }
  if (!_containsCredential(envelope, credentials)) return envelope;
  return {
    ..._redactDiagnosticMap(envelope, credentials, omitEchoedIdentifiers: true),
    // Protocol discriminators are independent of the provider diagnostics.
    if (envelope['type'] == 'error') 'type': 'error',
    if (envelope['_event'] == 'error') '_event': 'error',
  };
}

/// Provides a safe body to custom error factories while retaining its shape.
String redactApiErrorBody(String body, Set<String> credentials) {
  final safeText = _redactDiagnosticBodyText(body, credentials);
  if (safeText == body) return body;
  try {
    final decoded = jsonDecode(body);
    return jsonEncode(
      decoded is Map<String, dynamic>
          ? redactApiErrorEnvelope(decoded, credentials)
          : _redactDiagnosticValue(decoded, credentials),
    );
  } on FormatException {
    return safeText;
  }
}

/// Decodes a JSON API response without exposing reflected request credentials
/// in format errors from a provider transport.
T decodeApiJsonResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic>) decode, {
  bool utf8Body = false,
  String? nonObjectMessage,
  Iterable<String> additionalCredentials = const [],
}) {
  try {
    final body = utf8Body ? utf8.decode(response.bodyBytes) : response.body;
    final json = jsonDecode(body);
    if (nonObjectMessage != null && json is! Map<String, dynamic>) {
      throw FormatException(nonObjectMessage);
    }
    return decode(json as Map<String, dynamic>);
  } on Object catch (error, stackTrace) {
    if (error is! FormatException && error is! TypeError) rethrow;
    final credentials = responseCredentialValues(response)
      ..addAll(additionalCredentials);
    final safe = redactApiDecoderError(error, credentials);
    if (identical(safe, error)) rethrow;
    Error.throwWithStackTrace(safe, stackTrace);
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
