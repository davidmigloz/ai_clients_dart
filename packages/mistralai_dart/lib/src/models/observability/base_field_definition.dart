import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A field definition for chat completion event filtering.
@immutable
class BaseFieldDefinition {
  /// The field name.
  final String name;

  /// The display label.
  final String label;

  /// The field type (e.g., "ENUM", "TEXT", "INT", "FLOAT", "BOOL",
  /// "TIMESTAMP", "ARRAY").
  final String type;

  /// Supported filter operators for this field.
  final List<String> supportedOperators;

  /// Optional group name this field belongs to.
  final String? group;

  /// Creates a [BaseFieldDefinition].
  BaseFieldDefinition({
    required this.name,
    required this.label,
    required this.type,
    required List<String> supportedOperators,
    this.group,
  }) : supportedOperators = List.unmodifiable(supportedOperators);

  /// Creates a [BaseFieldDefinition] from JSON.
  factory BaseFieldDefinition.fromJson(Map<String, dynamic> json) =>
      BaseFieldDefinition(
        name: json['name'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: json['type'] as String? ?? '',
        supportedOperators:
            (json['supported_operators'] as List?)?.cast<String>() ?? [],
        group: json['group'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'label': label,
    'type': type,
    'supported_operators': supportedOperators,
    if (group != null) 'group': group,
  };

  /// Creates a copy with replaced values.
  BaseFieldDefinition copyWith({
    String? name,
    String? label,
    String? type,
    List<String>? supportedOperators,
    Object? group = unsetCopyWithValue,
  }) {
    return BaseFieldDefinition(
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      supportedOperators: supportedOperators ?? this.supportedOperators,
      group: group == unsetCopyWithValue ? this.group : group as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseFieldDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        label == other.label &&
        type == other.type &&
        listsEqual(supportedOperators, other.supportedOperators) &&
        group == other.group;
  }

  @override
  int get hashCode =>
      Object.hash(name, label, type, listHash(supportedOperators), group);

  @override
  String toString() =>
      'BaseFieldDefinition(name: $name, label: $label, type: $type, '
      'supportedOperators: ${supportedOperators.length} operators, '
      'group: $group)';
}
