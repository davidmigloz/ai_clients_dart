import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'telemetry_aggregation.dart';

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
    this.sourceAttributeKey,
    List<MetricAggregation>? supportedAggregations,
    required this.name,
    required this.label,
    required this.type,
    required List<String> supportedOperators,
    this.group,
  }) : supportedOperators = List.unmodifiable(supportedOperators),
       _hasSupportedAggregations = supportedAggregations != null,
       supportedAggregations = List.unmodifiable(
         supportedAggregations ?? const [],
       );

  /// Creates an [OtelFieldDefinition] from JSON.
  factory OtelFieldDefinition.fromJson(Map<String, dynamic> json) =>
      OtelFieldDefinition(
        sourceAttributeKey: json['source_attribute_key'] as String?,
        supportedAggregations:
            (json['supported_aggregations'] as List<Object?>?)
                ?.map((value) => MetricAggregation.fromJson(value! as String))
                .toList(),
        name: json['name'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: json['type'] as String? ?? '',
        supportedOperators:
            (json['supported_operators'] as List?)?.cast<String>() ?? [],
        group: json['group'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (sourceAttributeKey != null) 'source_attribute_key': sourceAttributeKey,
    if (_hasSupportedAggregations)
      'supported_aggregations': supportedAggregations
          .map((value) => value.toJson())
          .toList(),
    'name': name,
    'label': label,
    'type': type,
    'supported_operators': supportedOperators,
    if (group != null) 'group': group,
  };

  /// Original OpenTelemetry attribute name for this field.
  final String? sourceAttributeKey;

  /// Aggregations supported by this field.
  final List<MetricAggregation> supportedAggregations;

  final bool _hasSupportedAggregations;

  /// Creates a copy with replaced values.
  OtelFieldDefinition copyWith({
    Object? sourceAttributeKey = unsetCopyWithValue,
    List<MetricAggregation>? supportedAggregations,
    String? name,
    String? label,
    String? type,
    List<String>? supportedOperators,
    Object? group = unsetCopyWithValue,
  }) {
    return OtelFieldDefinition(
      sourceAttributeKey: sourceAttributeKey == unsetCopyWithValue
          ? this.sourceAttributeKey
          : sourceAttributeKey as String?,
      supportedAggregations:
          supportedAggregations ??
          (_hasSupportedAggregations ? this.supportedAggregations : null),
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
    return _hasSupportedAggregations == other._hasSupportedAggregations &&
        sourceAttributeKey == other.sourceAttributeKey &&
        listsEqual(supportedAggregations, other.supportedAggregations) &&
        name == other.name &&
        label == other.label &&
        type == other.type &&
        listsEqual(supportedOperators, other.supportedOperators) &&
        group == other.group;
  }

  @override
  int get hashCode => Object.hashAll([
    name,
    label,
    type,
    listHash(supportedOperators),
    group,
    sourceAttributeKey,
    listHash(supportedAggregations),
    _hasSupportedAggregations,
  ]);

  @override
  String toString() =>
      'OtelFieldDefinition(sourceAttributeKey: $sourceAttributeKey, supportedAggregations: ${supportedAggregations.length}, name: $name, label: $label, type: $type, '
      'supportedOperators: ${supportedOperators.length} operators, '
      'group: $group)';
}
