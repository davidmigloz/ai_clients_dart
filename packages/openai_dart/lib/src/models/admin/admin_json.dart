import 'dart:collection';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

export '../common/copy_with_sentinel.dart' show unsetCopyWithValue;

/// Immutable Admin wire values with complete value semantics and private text.
@immutable
abstract class AdminJsonValue {
  /// Creates an Admin value.
  const AdminJsonValue();

  /// Validates writable contracts without displaying submitted values.
  void validate() {}

  /// Serializes exact typed fields and permitted future JSON.
  Object toJson();

  @override
  bool operator ==(Object other) =>
      runtimeType == other.runtimeType &&
      other is AdminJsonValue &&
      mapsDeepEqual({'value': toJson()}, {'value': other.toJson()});

  @override
  int get hashCode =>
      Object.hash(runtimeType, mapDeepHashCode({'value': toJson()}));

  @override
  String toString() => '$runtimeType([REDACTED])';
}

/// Reads an object without coercing or printing private values.
Map<String, dynamic> adminObject(Object? value, String context) =>
    requireJsonObject(value, context);

/// Reads an exact string.
String adminString(Object? value, String context) =>
    requireJsonString(value, context);

/// Reads a finite integer without rounding.
int adminInt(Object? value, String context) {
  if (value is! int || !value.isFinite) {
    throw FormatException('$context: expected a finite integer');
  }
  return value;
}

/// Reads a boolean without coercion.
bool adminBool(Object? value, String context) {
  if (value is! bool) throw FormatException('$context: expected a boolean');
  return value;
}

/// Reads an exact list.
List<dynamic> adminList(Object? value, String context) {
  if (value is! List) throw FormatException('$context: expected an array');
  return value;
}

/// Reads a string map, retaining empty keys and values unless its owner bounds them.
Map<String, String> adminStringMap(Object? value, String context) => {
  for (final entry in adminObject(value, context).entries)
    entry.key: adminString(entry.value, context),
};

/// Reads a required member, including a required nullable member.
T? adminRequired<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object?, String) parse, {
  bool nullable = false,
}) {
  if (!json.containsKey(key)) {
    throw FormatException('$context: missing required field');
  }
  final value = json[key];
  if (value == null) {
    if (nullable) return null;
    throw FormatException('$context: null is not allowed');
  }
  return parse(value, context);
}

/// Reads an optional member without changing null into an invented default.
T? adminOptional<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object?, String) parse, {
  bool nullable = false,
}) => json.containsKey(key)
    ? adminRequired(json, key, context, parse, nullable: nullable)
    : null;

/// Rejects a wrong or missing required fixed discriminator.
void adminTag(
  Map<String, dynamic> json,
  String key,
  String expected,
  String context,
) {
  if (json[key] != expected) {
    throw FormatException('$context: invalid discriminator');
  }
}

/// Snapshots finite acyclic JSON without using private keys in diagnostics.
Map<String, dynamic> adminSnapshot(Map<String, dynamic> json, String context) {
  void check(Object? value, Set<Object> ancestors) {
    if (value == null ||
        value is String ||
        value is bool ||
        (value is num && value.isFinite)) {
      return;
    }
    if (value is List || value is Map) {
      if (!ancestors.add(value)) throw FormatException('$context: cyclic JSON');
      try {
        if (value is List) {
          for (final item in value) {
            check(item, ancestors);
          }
        } else {
          for (final entry in (value as Map).entries) {
            if (entry.key is! String) {
              throw FormatException('$context: expected string keys');
            }
            check(entry.value, ancestors);
          }
        }
      } finally {
        ancestors.remove(value);
      }
      return;
    }
    throw FormatException('$context: expected finite JSON');
  }

  check(json, HashSet<Object>.identity());
  return freezeJsonObject(json);
}

/// Preserves permitted overflow fields while keeping typed fields authoritative.
Map<String, dynamic> adminExtras(
  Map<String, dynamic> json,
  Set<String> known,
  String context,
) => adminSnapshot({
  for (final entry in json.entries)
    if (!known.contains(entry.key)) entry.key: entry.value,
}, context);

/// Validates source string bounds using Unicode code points.
void adminLength(String value, String context, {int? min, int? max}) {
  final count = value.runes.length;
  if ((min != null && count < min) || (max != null && count > max)) {
    throw FormatException('$context: invalid character length');
  }
}

/// Copies an optional typed scalar/model, with explicit null clearing locally.
T? adminCopy<T>(Object? value, T? previous, String context) {
  if (identical(value, unsetCopyWithValue)) return previous;
  if (value == null) return null;
  if (value is! T) throw FormatException('$context: invalid copy value');
  return value as T;
}

/// Copies a typed list, including an untyped empty literal.
List<T>? adminCopyList<T>(Object? value, List<T>? previous, String context) {
  if (identical(value, unsetCopyWithValue)) return previous;
  if (value == null) return null;
  return [
    for (final item in adminList(value, context))
      if (item is T)
        item
      else
        throw FormatException('$context: invalid list item'),
  ];
}
