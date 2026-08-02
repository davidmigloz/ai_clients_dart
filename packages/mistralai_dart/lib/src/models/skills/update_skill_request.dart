import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../registry/registry_sharing_scope.dart';

/// Request body to update a skill's metadata.
@immutable
class UpdateSkillRequest {
  /// Registry sharing scope.
  final RegistrySharingScope? sharingScope;

  /// Creates an [UpdateSkillRequest].
  const UpdateSkillRequest({this.sharingScope});

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (sharingScope != null) 'sharingScope': sharingScope!.value,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  UpdateSkillRequest copyWith({Object? sharingScope = unsetCopyWithValue}) =>
      UpdateSkillRequest(
        sharingScope: sharingScope == unsetCopyWithValue
            ? this.sharingScope
            : sharingScope as RegistrySharingScope?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSkillRequest &&
          runtimeType == other.runtimeType &&
          sharingScope == other.sharingScope;

  @override
  int get hashCode => sharingScope.hashCode;

  @override
  String toString() => 'UpdateSkillRequest(sharingScope: $sharingScope)';
}
