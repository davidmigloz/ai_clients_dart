import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../registry/alias_list.dart';

/// Request body to update a prompt version's metadata.
@immutable
class UpdatePromptVersionRequest {
  /// Aliases pointing to this version.
  ///
  /// Carries explicit presence: omit to leave aliases unchanged, or pass an
  /// [AliasList] with empty `values` to clear all aliases.
  final AliasList? aliases;

  /// Notes for this version.
  final String? notes;

  /// Creates an [UpdatePromptVersionRequest].
  const UpdatePromptVersionRequest({this.aliases, this.notes});

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (aliases != null) 'aliases': aliases!.toJson(),
    if (notes != null) 'notes': notes,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  UpdatePromptVersionRequest copyWith({
    Object? aliases = unsetCopyWithValue,
    Object? notes = unsetCopyWithValue,
  }) => UpdatePromptVersionRequest(
    aliases: aliases == unsetCopyWithValue
        ? this.aliases
        : aliases as AliasList?,
    notes: notes == unsetCopyWithValue ? this.notes : notes as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePromptVersionRequest &&
          runtimeType == other.runtimeType &&
          aliases == other.aliases &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(aliases, notes);

  @override
  String toString() =>
      'UpdatePromptVersionRequest(aliases: $aliases, notes: $notes)';
}
