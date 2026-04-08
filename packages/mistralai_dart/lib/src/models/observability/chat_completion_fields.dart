import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'base_field_definition.dart';
import 'field_group.dart';

/// Response containing chat completion field definitions and groups.
@immutable
class ChatCompletionFields {
  /// The field definitions.
  final List<BaseFieldDefinition> fieldDefinitions;

  /// The field groups.
  final List<FieldGroup> fieldGroups;

  /// Creates a [ChatCompletionFields].
  ChatCompletionFields({
    required List<BaseFieldDefinition> fieldDefinitions,
    required List<FieldGroup> fieldGroups,
  }) : fieldDefinitions = List.unmodifiable(fieldDefinitions),
       fieldGroups = List.unmodifiable(fieldGroups);

  /// Creates a [ChatCompletionFields] from JSON.
  factory ChatCompletionFields.fromJson(Map<String, dynamic> json) =>
      ChatCompletionFields(
        fieldDefinitions:
            (json['field_definitions'] as List?)
                ?.map(
                  (e) =>
                      BaseFieldDefinition.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        fieldGroups:
            (json['field_groups'] as List?)
                ?.map((e) => FieldGroup.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'field_definitions': fieldDefinitions.map((e) => e.toJson()).toList(),
    'field_groups': fieldGroups.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionFields) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(fieldDefinitions, other.fieldDefinitions) &&
        listsEqual(fieldGroups, other.fieldGroups);
  }

  @override
  int get hashCode =>
      Object.hash(listHash(fieldDefinitions), listHash(fieldGroups));

  @override
  String toString() =>
      'ChatCompletionFields(fieldDefinitions: ${fieldDefinitions.length}, '
      'fieldGroups: ${fieldGroups.length})';
}
