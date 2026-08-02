import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../registry/registry_sharing_scope.dart';

/// Request body to update a prompt's metadata.
@immutable
class UpdatePromptRequest {
  /// Display description.
  final String? description;

  /// Display title.
  final String? title;

  /// Registry sharing scope.
  final RegistrySharingScope? sharingScope;

  /// Creates an [UpdatePromptRequest].
  const UpdatePromptRequest({this.description, this.title, this.sharingScope});

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (description != null) 'description': description,
    if (title != null) 'title': title,
    if (sharingScope != null) 'sharingScope': sharingScope!.value,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  UpdatePromptRequest copyWith({
    Object? description = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? sharingScope = unsetCopyWithValue,
  }) => UpdatePromptRequest(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    title: title == unsetCopyWithValue ? this.title : title as String?,
    sharingScope: sharingScope == unsetCopyWithValue
        ? this.sharingScope
        : sharingScope as RegistrySharingScope?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePromptRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          title == other.title &&
          sharingScope == other.sharingScope;

  @override
  int get hashCode => Object.hash(description, title, sharingScope);

  @override
  String toString() =>
      'UpdatePromptRequest(description: $description, title: $title, '
      'sharingScope: $sharingScope)';
}
