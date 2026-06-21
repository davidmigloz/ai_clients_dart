import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'otel_field_definition.dart';

/// Response containing the available log field definitions.
@immutable
class GetLogFields {
  /// The field definitions.
  final List<OtelFieldDefinition> fieldDefinitions;

  /// Creates a [GetLogFields].
  GetLogFields({required List<OtelFieldDefinition> fieldDefinitions})
    : fieldDefinitions = List.unmodifiable(fieldDefinitions);

  /// Creates a [GetLogFields] from JSON.
  factory GetLogFields.fromJson(Map<String, dynamic> json) => GetLogFields(
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
  GetLogFields copyWith({List<OtelFieldDefinition>? fieldDefinitions}) =>
      GetLogFields(fieldDefinitions: fieldDefinitions ?? this.fieldDefinitions);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetLogFields) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(fieldDefinitions, other.fieldDefinitions);
  }

  @override
  int get hashCode => listHash(fieldDefinitions);

  @override
  String toString() =>
      'GetLogFields(fieldDefinitions: ${fieldDefinitions.length})';
}
