import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// JSON Schema for tool input.
///
/// Defines the shape of the input that a tool accepts.
/// Follows JSON Schema specification.
@immutable
class InputSchema {
  /// Schema type (always "object").
  final String type;

  /// Property definitions.
  final Map<String, dynamic>? properties;

  /// Required property names.
  final List<String>? required;

  /// Creates an [InputSchema].
  const InputSchema({this.type = 'object', this.properties, this.required});

  /// Creates an [InputSchema] from JSON.
  factory InputSchema.fromJson(Map<String, dynamic> json) {
    return InputSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] as Map<String, dynamic>?,
      required: (json['required'] as List?)?.cast<String>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (properties != null) 'properties': properties,
    if (required != null) 'required': required,
  };

  /// Creates a copy with replaced values.
  InputSchema copyWith({
    String? type,
    Object? properties = unsetCopyWithValue,
    Object? required = unsetCopyWithValue,
  }) {
    return InputSchema(
      type: type ?? this.type,
      properties: properties == unsetCopyWithValue
          ? this.properties
          : properties as Map<String, dynamic>?,
      required: required == unsetCopyWithValue
          ? this.required
          : required as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputSchema &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          _mapsEqual(properties, other.properties) &&
          _listsEqual(required, other.required);

  @override
  int get hashCode => Object.hash(type, properties, required);

  @override
  String toString() =>
      'InputSchema(type: $type, properties: $properties, required: $required)';
}

bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapsEqual<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
