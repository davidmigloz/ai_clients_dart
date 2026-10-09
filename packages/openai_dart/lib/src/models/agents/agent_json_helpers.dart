import 'dart:collection';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

/// Value semantics for saved-agent configuration and private wire objects.
@immutable
abstract class AgentJsonModel {
  /// Creates an immutable Agents value.
  const AgentJsonModel();

  /// Produces the exact wire value, including explicit null presence.
  Object toJson();

  /// Validates writable fields before authentication or dispatch.
  void validate() {}

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is AgentJsonModel &&
      mapsDeepEqual({'value': toJson()}, {'value': other.toJson()});

  @override
  int get hashCode =>
      Object.hash(runtimeType, mapDeepHashCode({'value': toJson()}));

  @override
  String toString() => '$runtimeType([REDACTED])';
}

/// Takes a finite, acyclic, deeply immutable JSON snapshot.
Map<String, dynamic> snapshotAgentJson(
  Map<String, dynamic> json,
  String context,
) {
  _finite(json, context, HashSet<Object>.identity());
  return freezeJsonObject(json);
}

void _finite(Object? value, String context, Set<Object> ancestors) {
  if (value == null || value is String || value is bool) return;
  if (value is num && value.isFinite) return;
  if (value is List<dynamic> || value is Map<dynamic, dynamic>) {
    if (!ancestors.add(value)) {
      throw FormatException('$context: expected acyclic JSON');
    }
    try {
      if (value is List<dynamic>) {
        for (final item in value) {
          _finite(item, context, ancestors);
        }
      } else if (value is Map<dynamic, dynamic>) {
        for (final entry in value.entries) {
          if (entry.key is! String) {
            throw FormatException('$context: expected string object keys');
          }
          _finite(entry.value, context, ancestors);
        }
      }
    } finally {
      ancestors.remove(value);
    }
    return;
  }
  throw FormatException('$context: expected finite JSON');
}

/// Retains received extras without allowing them to override typed fields.
Map<String, dynamic> agentExtras(
  Map<String, dynamic> json,
  List<String> knownKeys,
  String context,
) {
  if (json.keys.any(knownKeys.contains)) {
    throw FormatException('$context: extras cannot contain declared fields');
  }
  return snapshotAgentJson(json, context);
}

/// Rejects unsupported fields on closed writable objects.
void requireClosedAgentJson(
  Map<String, dynamic> json,
  List<String> keys,
  String context,
) {
  if (json.keys.any((key) => !keys.contains(key))) {
    throw FormatException('$context: unexpected field');
  }
}

/// Validates a fixed type or object discriminator without echoing its value.
void requireAgentTag(
  Map<String, dynamic> json,
  String key,
  String value,
  String context,
) {
  if (json[key] != value) {
    throw FormatException('$context.$key: expected the canonical value');
  }
}

/// Reads a string without coercion or disclosure.
String requireAgentString(Object? value, String context) {
  if (value is! String) {
    throw FormatException('$context: expected a string');
  }
  return value;
}

/// Reads a finite integer without rounding or coercion.
int requireAgentInt(Object? value, String context) {
  if (value is! int || !value.isFinite) {
    throw FormatException('$context: expected a finite integer');
  }
  return value;
}

/// Reads a finite number.
double requireAgentNumber(Object? value, String context) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$context: expected a finite number');
  }
  return value.toDouble();
}

/// Reads a boolean without truth-value coercion.
bool requireAgentBool(Object? value, String context) {
  if (value is! bool) {
    throw FormatException('$context: expected a boolean');
  }
  return value;
}

/// Reads an object without printing arbitrary field names or values.
Map<String, dynamic> requireAgentObject(Object? value, String context) {
  if (value is! Map<dynamic, dynamic> ||
      value.keys.any((key) => key is! String)) {
    throw FormatException('$context: expected a string-keyed object');
  }
  return {for (final entry in value.entries) entry.key as String: entry.value};
}

/// Reads a string-valued map without unchecked bulk casts.
Map<String, String> requireAgentStringMap(Object? value, String context) => {
  for (final entry in requireAgentObject(value, context).entries)
    entry.key: requireAgentString(entry.value, context),
};

/// Reads an array without unchecked element casts.
List<dynamic> requireAgentList(Object? value, String context) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return value;
}

/// Requires key presence even when a field allows a null value.
T? requiredAgentValue<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object? value, String context) parse, {
  required bool nullable,
}) {
  if (!json.containsKey(key)) {
    throw FormatException('$context: missing required field');
  }
  if (json[key] == null) {
    if (nullable) return null;
    throw FormatException('$context: null is not allowed');
  }
  return parse(json[key], context);
}

/// Rejects explicit null on optional nonnullable fields.
T? optionalAgentValue<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object? value, String context) parse, {
  required bool nullable,
}) => json.containsKey(key)
    ? requiredAgentValue(json, key, context, parse, nullable: nullable)
    : null;

/// Reads a nullable copy argument with private contextual errors.
T? copyAgentValue<T>(Object? value, T? current, String context) {
  if (identical(value, unsetCopyWithValue)) return current;
  if (value == null) return null;
  if (value is! T) {
    throw FormatException('$context: expected the declared field type');
  }
  return value as T;
}

/// Owns a nullable collection, leaving absence distinct from an empty value.
T? ownAgentValue<T>(T? value, T Function(T) own) =>
    value == null ? null : own(value);

/// Checks Unicode code-point limits rather than UTF-16 code-unit counts.
void validateAgentLength(
  String value,
  String context, {
  int min = 0,
  int? max,
}) {
  final count = value.runes.length;
  if (count < min || (max != null && count > max)) {
    throw FormatException('$context: invalid character length');
  }
}

/// Checks canonical collection and map bounds.
void validateAgentCount(int count, String context, {int min = 0, int? max}) {
  if (count < min || (max != null && count > max)) {
    throw FormatException('$context: invalid collection size');
  }
}

/// Checks integer bounds in release builds and on web platforms.
void validateAgentInt(int value, String context, {int? min, int? max}) {
  if (!value.isFinite ||
      (min != null && value < min) ||
      (max != null && value > max)) {
    throw FormatException('$context: invalid integer');
  }
}

/// Keeps future received enum strings out of closed request fields.
void validateAgentEnum(String value, List<String> allowed, String context) {
  if (!allowed.contains(value)) {
    throw FormatException('$context: unsupported request value');
  }
}

/// Enforces the documented compact UTF-8 JSON budget for the complete tool list.
void validateAgentToolBudget(List<Map<String, dynamic>> tools) {
  if (utf8.encode(jsonEncode(tools)).length > 3145728) {
    throw const FormatException(
      'Agent tools: compact UTF-8 JSON exceeds 3 MiB',
    );
  }
}
