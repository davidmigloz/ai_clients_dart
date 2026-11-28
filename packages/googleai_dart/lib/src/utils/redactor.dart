import 'dart:convert';

/// Utility for redacting sensitive data from logs.
class Redactor {
  /// JSON and diagnostic field names for opaque continuation tokens.
  static const continuationTokenFields = [
    'continuationToken',
    'continuation_token',
  ];

  /// Redacts continuation tokens without changing unrelated error text.
  static const continuationTokens = Redactor(
    redactionList: continuationTokenFields,
  );

  /// Field names used for interaction-scoped credentials.
  static const interactionAuthTokenFields = ['auth_token', 'authToken'];

  /// Treat opaque response tokens as credentials in HTTP diagnostics.
  static const interactionCredentials = Redactor(
    redactionList: [...continuationTokenFields, ...interactionAuthTokenFields],
  );

  /// Fields to redact (case-insensitive).
  final List<String> redactionList;

  /// Exact sensitive values to remove from diagnostic keys and text.
  final List<String> sensitiveValues;

  /// Replacement text for redacted values.
  final String replacement;

  /// Creates a [Redactor].
  const Redactor({
    required this.redactionList,
    this.sensitiveValues = const [],
    this.replacement = '***REDACTED***',
  });

  /// Redacts sensitive fields from a map.
  ///
  /// Returns a new map with sensitive values replaced.
  Map<String, String> redactMap(Map<String, String> input) {
    final redacted = <String, String>{};
    final lowercaseFields = redactionList.map((f) => f.toLowerCase()).toSet();

    for (final entry in input.entries) {
      redacted[_redactValues(
        entry.key,
      )] = lowercaseFields.contains(entry.key.toLowerCase())
          ? replacement
          : _redactValues(entry.value);
    }

    return redacted;
  }

  /// Redacts data in a diagnostic URI without changing its scheme or host.
  Uri redactUri(Uri uri) {
    final fields = redactionList.map((field) => field.toLowerCase()).toSet();
    return uri.replace(
      userInfo: _redactValues(uri.userInfo),
      pathSegments: uri.pathSegments.map(_redactValues),
      queryParameters: {
        for (final entry in uri.queryParametersAll.entries)
          _redactValues(entry.key): fields.contains(entry.key.toLowerCase())
              ? replacement
              : entry.value.map(_redactValues).toList(),
      },
      fragment: uri.hasFragment ? _redactValues(uri.fragment) : null,
    );
  }

  /// Redacts JSON response bodies and falls back to plain text redaction.
  String redactBody(String body) {
    try {
      final decoded = jsonDecode(body);
      final redacted = redactJson(decoded);
      return identical(decoded, redacted) ? body : jsonEncode(redacted);
    } on FormatException {
      return redactString(body);
    }
  }

  /// Redacts matching keys and labeled strings anywhere in a JSON value.
  Object? redactJson(Object? input) => _redactJson(
    input,
    redactionList.map((field) => field.toLowerCase()).toSet(),
  );

  Object? _redactJson(Object? input, Set<String> fields) {
    if (input is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      var changed = false;
      for (final entry in input.entries) {
        final value = entry.value;
        final redacted =
            value != null && fields.contains(entry.key.toLowerCase())
            ? replacement
            : _redactJson(value, fields);
        final key = _redactValues(entry.key);
        result[key] = redacted;
        changed |= key != entry.key || redacted != value;
      }
      return changed ? result : input;
    }

    if (input is List<dynamic>) {
      final result = <Object?>[];
      var changed = false;
      for (final value in input) {
        final redacted = _redactJson(value, fields);
        result.add(redacted);
        changed |= redacted != value;
      }
      return changed ? result : input;
    }

    return input is String ? redactString(input) : input;
  }

  static final _interactionTokenPattern = RegExp(
    r"""auth_tokens(?:/|%2f)[^&\s"'<>;,)}\]]+""",
    caseSensitive: false,
  );

  /// Redacts sensitive data from a string.
  ///
  /// This is a simple implementation that looks for key=value patterns.
  String redactString(String input) {
    var result = input;

    for (final field in redactionList) {
      final fieldPattern = RegExp.escape(field);
      const quotedValue = r'"(?:\\.|[^"\\])*"';
      // Redact JSON-style: "field": "value"
      result = result.replaceAllMapped(
        RegExp('"$fieldPattern"\\s*:\\s*$quotedValue', caseSensitive: false),
        (match) => '"$field": "$replacement"',
      );

      if (continuationTokenFields.contains(field)) {
        final label = RegExp(
          '\\b$fieldPattern([ \\t]*[:=][ \\t]*)'
          '($quotedValue|[^"\\s&;,)}\\]]+)',
          caseSensitive: false,
        );
        result = result.replaceAllMapped(
          label,
          (match) => '$field${match[1]}$replacement',
        );
        continue;
      }

      // Redact query param style: field=value
      result = result.replaceAllMapped(
        RegExp('$fieldPattern=([^&\\s]*)', caseSensitive: false),
        (match) => '$field=$replacement',
      );

      // Redact header style: field: value
      result = result.replaceAllMapped(
        RegExp('$fieldPattern:\\s*([^\\n]*)', caseSensitive: false),
        (match) => '$field: $replacement',
      );
    }

    if (redactionList.any(interactionAuthTokenFields.contains)) {
      result = result.replaceAll(_interactionTokenPattern, replacement);
    }
    return _redactValues(result);
  }

  String _redactValues(String input) {
    var result = input;
    for (final value in sensitiveValues) {
      if (value.isNotEmpty) result = result.replaceAll(value, replacement);
    }
    return result;
  }

  /// Truncates a string to a maximum length.
  String truncate(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength)}... [truncated]';
  }
}
