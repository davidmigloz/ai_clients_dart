import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A field definition for OpenTelemetry-based observability filtering
/// (traces, spans, span evaluations, and logs).
@immutable
class OtelFieldDefinition {
  /// The field name.
  final String name;

  /// The display label.
  final String label;

  /// The field type (e.g., "ENUM", "TEXT", "INT", "FLOAT", "BOOL",
  /// "TIMESTAMP", "ARRAY", "MAP").
  final String type;

  /// Supported filter operators for this field (e.g., "eq", "neq", "lt",
  /// "in", "contains").
  final List<String> supportedOperators;

  /// Optional group name this field belongs to.
  final String? group;

  /// Creates an [OtelFieldDefinition].
  OtelFieldDefinition({
    required this.name,
    required this.label,
    required this.type,
    required List<String> supportedOperators,
    this.group,
  }) : supportedOperators = List.unmodifiable(supportedOperators);

  /// Creates an [OtelFieldDefinition] from JSON.
  factory OtelFieldDefinition.fromJson(Map<String, dynamic> json) =>
      OtelFieldDefinition(
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
  OtelFieldDefinition copyWith({
    String? name,
    String? label,
    String? type,
    List<String>? supportedOperators,
    Object? group = unsetCopyWithValue,
  }) {
    return OtelFieldDefinition(
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
    if (other is! OtelFieldDefinition) return false;
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
      'OtelFieldDefinition(name: $name, label: $label, type: $type, '
      'supportedOperators: ${supportedOperators.length} operators, '
      'group: $group)';
}
