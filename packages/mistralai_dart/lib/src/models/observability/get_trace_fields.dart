import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'otel_field_definition.dart';

/// Response containing the available trace field definitions.
@immutable
class GetTraceFields {
  /// The field definitions.
  final List<OtelFieldDefinition> fieldDefinitions;

  /// Creates a [GetTraceFields].
  GetTraceFields({required List<OtelFieldDefinition> fieldDefinitions})
    : fieldDefinitions = List.unmodifiable(fieldDefinitions);

  /// Creates a [GetTraceFields] from JSON.
  factory GetTraceFields.fromJson(Map<String, dynamic> json) => GetTraceFields(
    fieldDefinitions:
        (json['field_definitions'] as List?)
            ?.map(
              (e) => OtelFieldDefinition.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'field_definitions': fieldDefinitions.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  GetTraceFields copyWith({List<OtelFieldDefinition>? fieldDefinitions}) =>
      GetTraceFields(
        fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetTraceFields) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(fieldDefinitions, other.fieldDefinitions);
  }

  @override
  int get hashCode => listHash(fieldDefinitions);

  @override
  String toString() =>
      'GetTraceFields(fieldDefinitions: ${fieldDefinitions.length})';
}
