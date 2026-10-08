import 'dart:collection';

import '../../common/json_helpers.dart';

/// Validates and snapshots arbitrary JSON without including payloads in errors.
Map<String, dynamic> snapshotResponsesJson(
  Map<String, dynamic> json,
  String context,
) {
  _validateJson(json, context, HashSet<Object>.identity());
  return freezeJsonObject(json);
}

void _validateJson(Object? value, String context, Set<Object> ancestors) {
  if (value == null || value is String || value is bool) return;
  // Dart2JS may classify Infinity as an int. Validate finiteness for every
  // numeric representation before accepting either integers or doubles.
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
        // Provider-defined keys may themselves contain sensitive text.
        _validateJson(entry.value, '$context member', ancestors);
      }
    } finally {
      ancestors.remove(value);
    }
    return;
  }
  throw FormatException('$context: expected a JSON value');
}

/// Merges an original object with typed fields, removing cleared known fields.
Map<String, dynamic> mergeResponsesJson(
  Map<String, dynamic> rawJson,
  Set<String> knownKeys,
  Map<String, dynamic> fields,
) => {
  for (final entry in rawJson.entries)
    if (!knownKeys.contains(entry.key)) entry.key: entry.value,
  ...fields,
};

/// Retains future child metadata while removing omitted schema-known members.
///
/// Callers reconcile replacements in `copyWith` before applying this merge.
/// Explicit parent raw metadata remains available for the new child, while
/// typed fields always determine schema-known output.
Map<String, dynamic> mergeResponsesModelJson(
  Object? original,
  Map<String, dynamic> typed,
  Set<String> knownKeys, {
  Map<String, Set<String>> childKeys = const {},
}) {
  final raw = original is Map<String, dynamic>
      ? original
      : const <String, dynamic>{};
  return mergeResponsesJson(raw, knownKeys, {
    for (final entry in typed.entries)
      entry.key:
          childKeys.containsKey(entry.key) &&
              entry.value is Map<String, dynamic>
          ? mergeResponsesModelJson(
              raw[entry.key],
              entry.value as Map<String, dynamic>,
              childKeys[entry.key]!,
              childKeys: childKeys,
            )
          : entry.value,
  });
}

/// Retains nested future provider metadata when shared typed DTOs serialize.
Map<String, dynamic> overlayResponsesJson(
  Map<String, dynamic> original,
  Map<String, dynamic> typed,
) => {
  ...original,
  for (final entry in typed.entries)
    entry.key: _overlayValue(original[entry.key], entry.value),
};

Object? _overlayValue(Object? original, Object? typed) {
  if (original is Map<String, dynamic> && typed is Map<String, dynamic>) {
    return overlayResponsesJson(original, typed);
  }
  if (original is List<dynamic> && typed is List<dynamic>) {
    return [
      for (var index = 0; index < typed.length; index++)
        _overlayValue(
          index < original.length ? original[index] : null,
          typed[index],
        ),
    ];
  }
  return typed;
}

/// Reconciles a typed edit with original future metadata. A cleared known field
/// disappears completely; unchanged nested objects retain their future keys.
Map<String, dynamic> replaceResponsesTypedJson(
  Map<String, dynamic> original,
  Map<String, dynamic> before,
  Map<String, dynamic> after,
) => {
  for (final entry in original.entries)
    if (!before.containsKey(entry.key)) entry.key: entry.value,
  for (final entry in after.entries)
    entry.key: _replaceValue(
      original[entry.key],
      before[entry.key],
      entry.value,
    ),
};

Object? _replaceValue(Object? original, Object? before, Object? after) {
  if (original is Map<String, dynamic> &&
      before is Map<String, dynamic> &&
      after is Map<String, dynamic>) {
    // Changed identities are replacements, not edits to the old nested item.
    for (final identity in const ['id', 'type']) {
      if (before.containsKey(identity) &&
          after.containsKey(identity) &&
          before[identity] != after[identity]) {
        return after;
      }
    }
    return replaceResponsesTypedJson(original, before, after);
  }
  if (original is List<dynamic> &&
      before is List<dynamic> &&
      after is List<dynamic>) {
    return [
      for (var index = 0; index < after.length; index++)
        _replaceValue(
          index < original.length ? original[index] : null,
          index < before.length ? before[index] : null,
          after[index],
        ),
    ];
  }
  return after;
}

/// Summarizes sensitive metadata without exposing its contents.
String responsesPresence(Object? value) =>
    value == null ? 'null' : '[REDACTED]';
