import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'prompt_definition.dart';

/// Request body to create a new version of a prompt.
@immutable
class CreatePromptVersionRequest {
  /// Definition for the new version.
  final PromptDefinition definition;

  /// Aliases pointing to this version.
  final List<String>? aliases;

  /// Notes for this version.
  final String? notes;

  /// Creates a [CreatePromptVersionRequest].
  const CreatePromptVersionRequest({
    required this.definition,
    this.aliases,
    this.notes,
  });

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'definition': definition.toJson(),
    if (aliases != null) 'aliases': aliases,
    if (notes != null) 'notes': notes,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  CreatePromptVersionRequest copyWith({
    PromptDefinition? definition,
    Object? aliases = unsetCopyWithValue,
    Object? notes = unsetCopyWithValue,
  }) => CreatePromptVersionRequest(
    definition: definition ?? this.definition,
    aliases: aliases == unsetCopyWithValue
        ? this.aliases
        : aliases as List<String>?,
    notes: notes == unsetCopyWithValue ? this.notes : notes as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePromptVersionRequest &&
          runtimeType == other.runtimeType &&
          definition == other.definition &&
          listsEqual(aliases, other.aliases) &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(definition, listHash(aliases), notes);

  @override
  String toString() =>
      'CreatePromptVersionRequest(definition: $definition, aliases: $aliases, '
      'notes: $notes)';
}
