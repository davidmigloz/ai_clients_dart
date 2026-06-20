import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'otel_field_definition.dart';

/// Response containing the available span evaluation field definitions.
@immutable
class GetSpanEvaluationFields {
  /// The field definitions.
  final List<OtelFieldDefinition> fieldDefinitions;

  /// Creates a [GetSpanEvaluationFields].
  GetSpanEvaluationFields({required List<OtelFieldDefinition> fieldDefinitions})
    : fieldDefinitions = List.unmodifiable(fieldDefinitions);

  /// Creates a [GetSpanEvaluationFields] from JSON.
  factory GetSpanEvaluationFields.fromJson(Map<String, dynamic> json) =>
      GetSpanEvaluationFields(
        fieldDefinitions:
            (json['field_definitions'] as List?)
                ?.map(
                  (e) =>
                      OtelFieldDefinition.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'field_definitions': fieldDefinitions.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  GetSpanEvaluationFields copyWith({
    List<OtelFieldDefinition>? fieldDefinitions,
  }) => GetSpanEvaluationFields(
    fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpanEvaluationFields) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(fieldDefinitions, other.fieldDefinitions);
  }

  @override
  int get hashCode => listHash(fieldDefinitions);

  @override
  String toString() =>
      'GetSpanEvaluationFields(fieldDefinitions: ${fieldDefinitions.length})';
}
