import 'dart:collection';
import 'dart:convert';

/// Detects monitoring metadata without interpreting or exposing its contents.
///
/// Identity tracking accepts arbitrary caller-owned shared/cyclic error bodies.
bool containsMonitoringError(Object? value) {
  final visited = HashSet<Object>.identity();
  final pending = <Object?>[value];
  while (pending.isNotEmpty) {
    final item = pending.removeLast();
    if (item is Map<dynamic, dynamic>) {
      if (!visited.add(item)) continue;
      final code = item['code'];
      if (item.containsKey('misalignment') ||
          (code is String && code == 'misalignment_policy_violation')) {
        return true;
      }
      pending.addAll(item.values);
    } else if (item is List<dynamic>) {
      if (!visited.add(item)) continue;
      pending.addAll(item);
    }
  }
  return false;
}

/// Masks diagnostic strings while retaining their original caller-readable data.
String? redactMonitoringErrorValue(
  String? value,
  Object? body, {
  bool redact = false,
}) => value == null
    ? null
    : redact ||
          containsMonitoringError(body) ||
          redactMonitoringErrorBody(value) != value
    ? '[REDACTED]'
    : value;

/// Omits complete monitoring response bodies before logging or truncation.
///
/// Error explanations, opaque review tokens, instructions and future metadata
/// remain in the original HTTP response. Unrelated body formatting is unchanged.
String redactMonitoringErrorBody(String body) {
  try {
    return containsMonitoringError(jsonDecode(body)) ? '[REDACTED]' : body;
  } on FormatException {
    // A malformed but identifiable monitoring response cannot be safely split.
    if (body.contains('misalignment_policy_violation')) return '[REDACTED]';
    for (final match in _quotedJsonStrings.allMatches(body)) {
      try {
        final value = jsonDecode(match.group(0)!);
        if (value == 'misalignment_policy_violation') return '[REDACTED]';
        if (value == 'misalignment' &&
            body.substring(match.end).trimLeft().startsWith(':')) {
          return '[REDACTED]';
        }
      } on FormatException {
        // Invalid quoted strings do not establish a JSON metadata key.
      }
    }
    return body;
  }
}

final _quotedJsonStrings = RegExp(r'"(?:[^"\\]|\\.)*"');
