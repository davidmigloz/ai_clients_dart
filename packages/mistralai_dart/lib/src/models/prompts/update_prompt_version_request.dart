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
  ///
  /// Leave both this and [clearNotes] at their defaults to preserve the
  /// current value; set this to replace it; or pass `clearNotes: true`
  /// (leaving this `null`) to clear it.
  final String? notes;

  /// Whether to emit an explicit JSON `null` for `notes`, clearing it.
  ///
  /// Must not be `true` while [notes] is non-null.
  final bool clearNotes;

  /// Creates an [UpdatePromptVersionRequest].
  ///
  /// Asserts that [clearNotes] is not `true` while [notes] is also non-null.
  const UpdatePromptVersionRequest({
    this.aliases,
    this.notes,
    this.clearNotes = false,
  }) : assert(
         !(clearNotes && notes != null),
         'Cannot set both notes and clearNotes: true.',
       );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (aliases != null) 'aliases': aliases!.toJson(),
    if (notes != null) 'notes': notes else if (clearNotes) 'notes': null,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear [aliases]. Omit [notes] to preserve its
  /// current value (including whether it is currently marked for clearing);
  /// pass a value to replace it; pass `clearNotes: true` to clear it, or
  /// `clearNotes: false` to return a cleared field to the omitted / no-change
  /// state.
  UpdatePromptVersionRequest copyWith({
    Object? aliases = unsetCopyWithValue,
    Object? notes = unsetCopyWithValue,
    bool? clearNotes,
  }) {
    final notesSet = notes != unsetCopyWithValue;
    return UpdatePromptVersionRequest(
      aliases: aliases == unsetCopyWithValue
          ? this.aliases
          : aliases as AliasList?,
      notes: notesSet
          ? notes as String?
          : ((clearNotes ?? false) ? null : this.notes),
      clearNotes: clearNotes ?? (notesSet ? notes == null : this.clearNotes),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePromptVersionRequest &&
          runtimeType == other.runtimeType &&
          aliases == other.aliases &&
          notes == other.notes &&
          clearNotes == other.clearNotes;

  @override
  int get hashCode => Object.hash(aliases, notes, clearNotes);

  @override
  String toString() =>
      'UpdatePromptVersionRequest(aliases: $aliases, notes: $notes, '
      'clearNotes: $clearNotes)';
}
