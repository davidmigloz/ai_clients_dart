import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../registry/registry_sharing_scope.dart';

/// Request body to update a skill's metadata.
@immutable
class UpdateSkillRequest {
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

  /// Creates an [UpdateSkillRequest].
  ///
  /// Asserts that [clearSharingScope] is not `true` while [sharingScope] is
  /// also non-null.
  const UpdateSkillRequest({this.sharingScope, this.clearSharingScope = false})
    : assert(
        !(clearSharingScope && sharingScope != null),
        'Cannot set both sharingScope and clearSharingScope: true.',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (sharingScope != null)
      'sharingScope': sharingScope!.value
    else if (clearSharingScope)
      'sharingScope': null,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Omit [sharingScope] to preserve its current value (including whether it
  /// is currently marked for clearing); pass a value to replace it; pass
  /// `clearSharingScope: true` to clear it, or `clearSharingScope: false` to
  /// return a cleared field to the omitted / no-change state.
  UpdateSkillRequest copyWith({
    Object? sharingScope = unsetCopyWithValue,
    bool? clearSharingScope,
  }) {
    final sharingScopeSet = sharingScope != unsetCopyWithValue;
    return UpdateSkillRequest(
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
      other is UpdateSkillRequest &&
          runtimeType == other.runtimeType &&
          sharingScope == other.sharingScope &&
          clearSharingScope == other.clearSharingScope;

  @override
  int get hashCode => Object.hash(sharingScope, clearSharingScope);

  @override
  String toString() =>
      'UpdateSkillRequest(sharingScope: $sharingScope, '
      'clearSharingScope: $clearSharingScope)';
}
