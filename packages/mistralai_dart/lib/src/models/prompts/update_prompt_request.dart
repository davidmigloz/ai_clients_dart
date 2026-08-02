import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../registry/registry_sharing_scope.dart';

/// Request body to update a prompt's metadata.
///
/// Each field distinguishes three states: omit it (and its `clearX` flag) to
/// leave the current value unchanged, pass a value to replace it, or pass
/// `clearX: true` (with the value left `null`) to explicitly reset it to
/// `null` server-side. Passing both a non-null value and its `clearX: true`
/// flag is a contradiction and asserts.
@immutable
class UpdatePromptRequest {
  /// Display description.
  ///
  /// Leave both this and [clearDescription] at their defaults to preserve
  /// the current value; set this to replace it; or pass
  /// `clearDescription: true` (leaving this `null`) to clear it.
  final String? description;

  /// Whether to emit an explicit JSON `null` for `description`, clearing it.
  ///
  /// Must not be `true` while [description] is non-null.
  final bool clearDescription;

  /// Display title.
  ///
  /// Leave both this and [clearTitle] at their defaults to preserve the
  /// current value; set this to replace it; or pass `clearTitle: true`
  /// (leaving this `null`) to clear it.
  final String? title;

  /// Whether to emit an explicit JSON `null` for `title`, clearing it.
  ///
  /// Must not be `true` while [title] is non-null.
  final bool clearTitle;

  /// Registry sharing scope.
  ///
  /// Leave both this and [clearSharingScope] at their defaults to preserve
  /// the current value; set this to replace it; or pass
  /// `clearSharingScope: true` (leaving this `null`) to clear it.
  final RegistrySharingScope? sharingScope;

  /// Whether to emit an explicit JSON `null` for `sharingScope`, clearing it.
  ///
  /// Must not be `true` while [sharingScope] is non-null.
  final bool clearSharingScope;

  /// Creates an [UpdatePromptRequest].
  ///
  /// Asserts that a `clearX` flag is not `true` while its corresponding
  /// value is also non-null.
  const UpdatePromptRequest({
    this.description,
    this.clearDescription = false,
    this.title,
    this.clearTitle = false,
    this.sharingScope,
    this.clearSharingScope = false,
  }) : assert(
         !(clearDescription && description != null),
         'Cannot set both description and clearDescription: true.',
       ),
       assert(
         !(clearTitle && title != null),
         'Cannot set both title and clearTitle: true.',
       ),
       assert(
         !(clearSharingScope && sharingScope != null),
         'Cannot set both sharingScope and clearSharingScope: true.',
       );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (description != null)
      'description': description
    else if (clearDescription)
      'description': null,
    if (title != null) 'title': title else if (clearTitle) 'title': null,
    if (sharingScope != null)
      'sharingScope': sharingScope!.value
    else if (clearSharingScope)
      'sharingScope': null,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Omit a field to preserve its current value (including whether it is
  /// currently marked for clearing). Pass a value to replace it. Pass the
  /// matching `clearX: true` to clear a field (this also resets the value to
  /// `null` so the result stays internally consistent), or `clearX: false`
  /// to return a cleared field to the omitted / no-change state.
  UpdatePromptRequest copyWith({
    Object? description = unsetCopyWithValue,
    bool? clearDescription,
    Object? title = unsetCopyWithValue,
    bool? clearTitle,
    Object? sharingScope = unsetCopyWithValue,
    bool? clearSharingScope,
  }) {
    final descriptionSet = description != unsetCopyWithValue;
    final titleSet = title != unsetCopyWithValue;
    final sharingScopeSet = sharingScope != unsetCopyWithValue;
    return UpdatePromptRequest(
      description: descriptionSet
          ? description as String?
          : ((clearDescription ?? false) ? null : this.description),
      clearDescription:
          clearDescription ??
          (descriptionSet ? description == null : this.clearDescription),
      title: titleSet
          ? title as String?
          : ((clearTitle ?? false) ? null : this.title),
      clearTitle: clearTitle ?? (titleSet ? title == null : this.clearTitle),
      sharingScope: sharingScopeSet
          ? sharingScope as RegistrySharingScope?
          : ((clearSharingScope ?? false) ? null : this.sharingScope),
      clearSharingScope:
          clearSharingScope ??
          (sharingScopeSet ? sharingScope == null : this.clearSharingScope),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePromptRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          clearDescription == other.clearDescription &&
          title == other.title &&
          clearTitle == other.clearTitle &&
          sharingScope == other.sharingScope &&
          clearSharingScope == other.clearSharingScope;

  @override
  int get hashCode => Object.hash(
    description,
    clearDescription,
    title,
    clearTitle,
    sharingScope,
    clearSharingScope,
  );

  @override
  String toString() =>
      'UpdatePromptRequest(description: $description, '
      'clearDescription: $clearDescription, title: $title, '
      'clearTitle: $clearTitle, sharingScope: $sharingScope, '
      'clearSharingScope: $clearSharingScope)';
}
