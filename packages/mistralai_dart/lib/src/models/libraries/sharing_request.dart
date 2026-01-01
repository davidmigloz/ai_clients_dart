import 'package:meta/meta.dart';

import 'entity_type.dart';
import 'share_level.dart';

/// Request to create or update library sharing.
@immutable
class SharingRequest {
  /// The organization ID.
  final String? orgId;

  /// The access level to grant.
  final ShareLevel level;

  /// The UUID of the entity to share with.
  final String shareWithUuid;

  /// The type of entity to share with.
  final EntityType shareWithType;

  /// Creates [SharingRequest].
  const SharingRequest({
    this.orgId,
    required this.level,
    required this.shareWithUuid,
    required this.shareWithType,
  });

  /// Creates from JSON.
  factory SharingRequest.fromJson(Map<String, dynamic> json) => SharingRequest(
    orgId: json['org_id'] as String?,
    level: ShareLevel.fromString(json['level'] as String?),
    shareWithUuid: json['share_with_uuid'] as String,
    shareWithType: EntityType.fromString(json['share_with_type'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (orgId != null) 'org_id': orgId,
    'level': level.value,
    'share_with_uuid': shareWithUuid,
    'share_with_type': shareWithType.value,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingRequest &&
          runtimeType == other.runtimeType &&
          orgId == other.orgId &&
          level == other.level &&
          shareWithUuid == other.shareWithUuid &&
          shareWithType == other.shareWithType;

  @override
  int get hashCode => Object.hash(orgId, level, shareWithUuid, shareWithType);

  @override
  String toString() =>
      'SharingRequest('
      'orgId: $orgId, level: $level, '
      'shareWithUuid: $shareWithUuid, shareWithType: $shareWithType)';
}
