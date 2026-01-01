import 'package:meta/meta.dart';

/// Response containing library sharing information.
@immutable
class SharingResponse {
  /// The library ID.
  final String libraryId;

  /// The user ID (if shared with a user).
  final String? userId;

  /// The organization ID.
  final String orgId;

  /// The role/access level.
  final String role;

  /// The type of entity the library is shared with.
  final String shareWithType;

  /// The UUID of the entity the library is shared with.
  final String? shareWithUuid;

  /// Creates [SharingResponse].
  const SharingResponse({
    required this.libraryId,
    this.userId,
    required this.orgId,
    required this.role,
    required this.shareWithType,
    this.shareWithUuid,
  });

  /// Creates from JSON.
  factory SharingResponse.fromJson(Map<String, dynamic> json) =>
      SharingResponse(
        libraryId: json['library_id'] as String,
        userId: json['user_id'] as String?,
        orgId: json['org_id'] as String,
        role: json['role'] as String,
        shareWithType: json['share_with_type'] as String,
        shareWithUuid: json['share_with_uuid'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'library_id': libraryId,
    if (userId != null) 'user_id': userId,
    'org_id': orgId,
    'role': role,
    'share_with_type': shareWithType,
    if (shareWithUuid != null) 'share_with_uuid': shareWithUuid,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingResponse &&
          runtimeType == other.runtimeType &&
          libraryId == other.libraryId &&
          orgId == other.orgId &&
          role == other.role;

  @override
  int get hashCode => Object.hash(libraryId, orgId, role);

  @override
  String toString() =>
      'SharingResponse('
      'libraryId: $libraryId, userId: $userId, orgId: $orgId, '
      'role: $role, shareWithType: $shareWithType, '
      'shareWithUuid: $shareWithUuid)';
}
