import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// JSON Schema for tool input.
///
/// Defines the shape of the input that a tool accepts.
/// Follows JSON Schema specification.
///
/// The [extra] field holds additional JSON Schema keywords beyond
/// [type], [properties], and [required] (e.g., `additionalProperties`,
/// `description`, `$defs`, `anyOf`).
@immutable
class InputSchema {
  /// Schema type (always "object").
  final String type;

  /// Property definitions.
  final Map<String, dynamic>? properties;

  /// Required property names.
  final List<String>? required;

  /// Additional JSON Schema keywords not covered by the named fields.
  ///
  /// Keys are spread as top-level entries in [toJson], not nested under
  /// an `extra` key. For example:
  /// ```dart
  /// InputSchema(
  ///   properties: {'x': {'type': 'string'}},
  ///   required: ['x'],
  ///   extra: {'additionalProperties': false},
  /// )
  /// ```
  /// serializes as `{"type": "object", "properties": ..., "required": ...,
  /// "additionalProperties": false}`.
  final Map<String, dynamic>? extra;

  /// Creates an [InputSchema].
  const InputSchema({
    this.type = 'object',
    this.properties,
    this.required,
    this.extra,
  });

  /// Creates an [InputSchema] from JSON.
  ///
  /// Known keys (`type`, `properties`, `required`) are extracted into typed
  /// fields. All remaining keys are collected into [extra].
  factory InputSchema.fromJson(Map<String, dynamic> json) {
    const knownKeys = {'type', 'properties', 'required'};
    final extraEntries = {
      for (final entry in json.entries)
        if (!knownKeys.contains(entry.key)) entry.key: entry.value,
    };
    return InputSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] as Map<String, dynamic>?,
      required: (json['required'] as List?)?.cast<String>(),
      extra: extraEntries.isEmpty ? null : extraEntries,
    );
  }

  /// Converts to JSON.
  ///
  /// [extra] is spread first; known keys are written after, so typed fields
  /// always take precedence on key collision.
  Map<String, dynamic> toJson() => {
    if (extra != null) ...extra!,
    'type': type,
    if (properties != null) 'properties': properties,
    if (required != null) 'required': required,
  };

  /// Creates a copy with replaced values.
  InputSchema copyWith({
    String? type,
    Object? properties = unsetCopyWithValue,
    Object? required = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) {
    return InputSchema(
      type: type ?? this.type,
      properties: properties == unsetCopyWithValue
          ? this.properties
          : properties as Map<String, dynamic>?,
      required: required == unsetCopyWithValue
          ? this.required
          : required as List<String>?,
      extra: extra == unsetCopyWithValue
          ? this.extra
          : extra as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputSchema &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(properties, other.properties) &&
          listsEqual(required, other.required) &&
          mapsDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hash(
    type,
    mapDeepHashCode(properties),
    listHash(required),
    mapDeepHashCode(extra),
  );

  @override
  String toString() =>
      'InputSchema(type: $type, properties: $properties, '
      'required: $required, '
      'extra: ${extra != null ? '${extra!.length} entries' : null})';
}
