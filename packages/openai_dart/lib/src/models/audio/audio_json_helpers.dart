import 'dart:collection';

import '../common/json_helpers.dart';

/// Takes a finite, acyclic, deeply immutable snapshot without echoing values.
Map<String, dynamic> snapshotAudioJson(
  Map<String, dynamic> json,
  String context, {
  Set<String> knownKeys = const {},
}) {
  _validateJson(json, context, HashSet<Object>.identity(), knownKeys);
  return freezeJsonObject(json);
}

void _validateJson(
  Object? value,
  String context,
  Set<Object> ancestors, [
  Set<String> knownKeys = const {},
]) {
  if (value == null || value is String || value is bool) return;
  // JavaScript may classify nonfinite numbers as integers.
  if (value is num && value.isFinite) return;
  if (value is List<dynamic>) {
    if (!ancestors.add(value)) {
      throw FormatException('$context: expected acyclic JSON');
    }
    try {
      for (var index = 0; index < value.length; index++) {
        _validateJson(value[index], '$context[$index]', ancestors);
      }
    } finally {
      ancestors.remove(value);
    }
    return;
  }
  if (value is Map<dynamic, dynamic>) {
    if (!ancestors.add(value)) {
      throw FormatException('$context: expected acyclic JSON');
    }
    try {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw FormatException('$context: expected string object keys');
        }
        // Future provider keys can themselves contain private content.
        _validateJson(
          entry.value,
          knownKeys.contains(entry.key)
              ? '$context.${entry.key}'
              : '$context member',
          ancestors,
        );
      }
    } finally {
      ancestors.remove(value);
    }
    return;
  }
  throw FormatException('$context: expected a finite JSON value');
}

/// Rejects undeclared writable fields without disclosing their names or values.
void requireClosedAudioJson(
  Map<String, dynamic> json,
  Set<String> fields,
  String context,
) {
  if (json.keys.any((key) => !fields.contains(key))) {
    throw FormatException('$context: unexpected field');
  }
}

/// Reads a finite integer without rounding or exposing malformed values.
int requireAudioInt(Object? value, String context) {
  if (value is! int || !value.isFinite) {
    throw FormatException('$context: expected a finite integer');
  }
  return value;
}

/// Reads a finite number without exposing malformed values.
double requireAudioNumber(Object? value, String context) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$context: expected a finite number');
  }
  return value.toDouble();
}

/// Overlays typed members and removes omitted schema-known fields.
Map<String, dynamic> mergeAudioJson(
  Map<String, dynamic> rawJson,
  Set<String> knownKeys,
  Map<String, dynamic> fields,
) => {
  for (final entry in rawJson.entries)
    if (!knownKeys.contains(entry.key)) entry.key: entry.value,
  ...fields,
};

/// Preserves parent future metadata while schema-known typed child fields win.
///
/// Parent future members take priority over child future members. Callers remove
/// stale parent child metadata before an explicit fresh child replacement.
Map<String, dynamic> mergeAudioModelJson(
  Object? original,
  Set<String> knownKeys,
  Map<String, dynamic> typed,
) => {
  for (final entry in typed.entries)
    if (!knownKeys.contains(entry.key)) entry.key: entry.value,
  if (original is Map<String, dynamic>)
    for (final entry in original.entries)
      if (!knownKeys.contains(entry.key)) entry.key: entry.value,
  for (final entry in typed.entries)
    if (knownKeys.contains(entry.key)) entry.key: entry.value,
};

/// Summarizes an optional private value without displaying its content.
String audioPresence(Object? value) => value == null ? 'null' : '[REDACTED]';
