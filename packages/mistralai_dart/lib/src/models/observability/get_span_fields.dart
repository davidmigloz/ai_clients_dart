import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'otel_field_definition.dart';

/// Response containing the available span field definitions.
@immutable
class GetSpanFields {
  /// The field definitions.
  final List<OtelFieldDefinition> fieldDefinitions;

  /// Creates a [GetSpanFields].
  GetSpanFields({required List<OtelFieldDefinition> fieldDefinitions})
    : fieldDefinitions = List.unmodifiable(fieldDefinitions);

  /// Creates a [GetSpanFields] from JSON.
  factory GetSpanFields.fromJson(Map<String, dynamic> json) => GetSpanFields(
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
  GetSpanFields copyWith({List<OtelFieldDefinition>? fieldDefinitions}) =>
      GetSpanFields(
        fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpanFields) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(fieldDefinitions, other.fieldDefinitions);
  }

  @override
  int get hashCode => listHash(fieldDefinitions);

  @override
  String toString() =>
      'GetSpanFields(fieldDefinitions: ${fieldDefinitions.length})';
}
