import 'dart:collection';

import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

/// Distinguishes an omitted copy argument from an explicit null.
const Object liveUnset = _LiveUnset();

class _LiveUnset {
  const _LiveUnset();
}

/// Shared value semantics for private Live configuration and wire unions.
@immutable
abstract class LiveJsonModel {
  /// Creates a Live value.
  const LiveJsonModel();

  /// Serializes this value using the canonical wire representation.
  Object toJson();

  /// Validates writable fields before a request is authenticated or sent.
  void validate() {}

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is LiveJsonModel &&
      mapsDeepEqual({'value': toJson()}, {'value': other.toJson()});

  @override
  int get hashCode =>
      Object.hash(runtimeType, mapDeepHashCode({'value': toJson()}));

  @override
  String toString() => '$runtimeType([REDACTED])';
}

/// Takes a finite, acyclic and deeply immutable snapshot of Live JSON.
Map<String, dynamic> snapshotLiveJson(
  Map<String, dynamic> json,
  String context, {
  Set<String> knownKeys = const {},
}) {
  _validateLiveJson(json, context, HashSet<Object>.identity(), knownKeys);
  return freezeJsonObject(json);
}

void _validateLiveJson(
  Object? value,
  String context,
  Set<Object> ancestors, [
  Set<String> knownKeys = const {},
]) {
  if (value == null || value is String || value is bool) return;
  if (value is num && value.isFinite) return;
  if (value is List<dynamic>) {
    if (!ancestors.add(value)) {
      throw FormatException('$context: expected acyclic JSON');
    }
    try {
      for (var index = 0; index < value.length; index++) {
        _validateLiveJson(value[index], '$context[$index]', ancestors);
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
        _validateLiveJson(
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

/// Rejects undeclared writable fields without echoing private key names.
void requireClosedLiveJson(
  Map<String, dynamic> json,
  Set<String> fields,
  String context,
) {
  if (json.keys.any((key) => !fields.contains(key))) {
    throw FormatException('$context: unexpected field');
  }
}

/// Reads a string without coercion or value disclosure.
String requireLiveString(Object? value, String context) {
  if (value is! String) {
    throw FormatException('$context: expected a string');
  }
  return value;
}

/// Reads an integer without rounding or accepting nonfinite JavaScript values.
int requireLiveInt(Object? value, String context) {
  if (value is! int || !value.isFinite) {
    throw FormatException('$context: expected a finite integer');
  }
  return value;
}

/// Reads a finite number.
double requireLiveNumber(Object? value, String context) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$context: expected a finite number');
  }
  return value.toDouble();
}

/// Reads a boolean without truth-value coercion.
bool requireLiveBool(Object? value, String context) {
  if (value is! bool) {
    throw FormatException('$context: expected a boolean');
  }
  return value;
}

/// Reads an object without exposing malformed keys or content.
Map<String, dynamic> requireLiveObject(Object? value, String context) {
  if (value is! Map<dynamic, dynamic>) {
    throw FormatException('$context: expected an object');
  }
  if (value.keys.any((key) => key is! String)) {
    throw FormatException('$context: expected string object keys');
  }
  return {for (final entry in value.entries) entry.key as String: entry.value};
}

/// Reads an array without unchecked element casts.
List<dynamic> requireLiveList(Object? value, String context) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return value;
}

/// Reads an optional field and rejects null unless the schema permits it.
T? optionalLiveValue<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object? value, String context) parser, {
  bool nullable = false,
}) {
  if (!json.containsKey(key)) return null;
  if (json[key] == null) {
    if (nullable) return null;
    throw FormatException('$context.$key: null is not allowed');
  }
  try {
    return parser(json[key], '$context.$key');
  } on FormatException catch (error) {
    final fieldContext = '$context.$key';
    throw FormatException(
      error.message.startsWith(fieldContext)
          ? error.message
          : '$fieldContext: ${error.message}',
    );
  }
}

/// Validates a fixed discriminator without reflecting the supplied value.
void requireLiveType(
  Map<String, dynamic> json,
  String expected,
  String context, {
  String key = 'type',
  bool required = true,
}) {
  if (!required && !json.containsKey(key)) return;
  if (json[key] != expected) {
    throw FormatException('$context.$key: expected the canonical value');
  }
}

/// Overlays typed fields and removes omitted known fields from stale raw JSON.
Map<String, dynamic> mergeLiveJson(
  Map<String, dynamic> rawJson,
  Set<String> knownKeys,
  Map<String, dynamic> typed,
) => {
  for (final entry in rawJson.entries)
    if (!knownKeys.contains(entry.key)) entry.key: entry.value,
  ...typed,
};

/// Checks schema character limits using Unicode code points.
void validateLiveLength(String value, String context, {int? min, int? max}) {
  final length = value.runes.length;
  if ((min != null && length < min) || (max != null && length > max)) {
    throw FormatException('$context: invalid character length');
  }
}

/// Describes presence without exposing private content.
String livePresence(Object? value) => value == null ? 'null' : '[REDACTED]';

/// Reads a nullable copy argument with the same safe errors as JSON parsing.
T? copyLiveValue<T>(Object? value, T? current, String context) {
  if (identical(value, liveUnset)) return current;
  if (value == null) return null;
  if (value is! T) {
    throw FormatException('$context: expected the declared field type');
  }
  return value as T;
}
