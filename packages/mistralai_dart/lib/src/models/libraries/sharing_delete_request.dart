import 'package:meta/meta.dart';

import 'entity_type.dart';

/// Request to delete library sharing.
@immutable
class SharingDeleteRequest {
  /// The organization ID.
  final String? orgId;

  /// The UUID of the entity to remove sharing for.
  final String shareWithUuid;

  /// The type of entity to remove sharing for.
  final EntityType shareWithType;

  /// Creates [SharingDeleteRequest].
  const SharingDeleteRequest({
    this.orgId,
    required this.shareWithUuid,
    required this.shareWithType,
  });

  /// Creates from JSON.
  factory SharingDeleteRequest.fromJson(Map<String, dynamic> json) =>
      SharingDeleteRequest(
        orgId: json['org_id'] as String?,
        shareWithUuid: json['share_with_uuid'] as String,
        shareWithType: EntityType.fromString(
          json['share_with_type'] as String?,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (orgId != null) 'org_id': orgId,
    'share_with_uuid': shareWithUuid,
    'share_with_type': shareWithType.value,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingDeleteRequest &&
          runtimeType == other.runtimeType &&
          orgId == other.orgId &&
          shareWithUuid == other.shareWithUuid &&
          shareWithType == other.shareWithType;

  @override
  int get hashCode => Object.hash(orgId, shareWithUuid, shareWithType);

  @override
  String toString() =>
      'SharingDeleteRequest('
      'orgId: $orgId, shareWithUuid: $shareWithUuid, '
      'shareWithType: $shareWithType)';
}
