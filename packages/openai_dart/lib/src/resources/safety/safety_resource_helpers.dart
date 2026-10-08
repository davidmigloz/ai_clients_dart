import 'dart:convert';

import 'package:http/http.dart' as http;

/// Builds one encoded safety identifier segment without disclosing its value.
String safetyResourcePath(
  String collection,
  String id, {
  required int maximumLength,
  required String context,
}) {
  // Dart Uri normalizes literal and escaped dot segments. Only these unusable
  // route segments are rejected in addition to the canonical length maximum.
  if (id.isEmpty || id == '.' || id == '..') {
    throw ArgumentError('$context ID must be a nonempty path segment.');
  }
  if (id.runes.length > maximumLength) {
    throw ArgumentError(
      '$context ID must contain at most $maximumLength Unicode characters.',
    );
  }
  try {
    return '$collection/${Uri.encodeComponent(id)}';
  } on ArgumentError {
    throw ArgumentError('$context ID must be encodable as a path segment.');
  }
}

/// Parses a successful UTF-8 safety response with payload-free diagnostics.
T parseSafetyResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic>) parse,
  String context,
) {
  try {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return parse(json);
  } on FormatException {
    throw FormatException('Invalid $context response.');
  } on TypeError {
    throw FormatException('Invalid $context response.');
  } on ArgumentError {
    throw FormatException('Invalid $context response.');
  }
}
