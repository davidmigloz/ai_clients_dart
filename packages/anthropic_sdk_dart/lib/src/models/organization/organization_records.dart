import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// An organization returned by the Admin API.
@immutable
final class OrganizationInfo {
  /// The organization ID.
  final String id;

  /// The organization display name.
  final String name;

  /// The response discriminator.
  String get type => 'organization';

  /// Creates a [OrganizationInfo].
  const OrganizationInfo({required this.id, required this.name});

  /// Reads a [OrganizationInfo] from its response object.
  factory OrganizationInfo.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'organization');
    return OrganizationInfo(
      id: requiredOrganizationField<String>(json, 'id', 'OrganizationInfo'),
      name: requiredOrganizationField<String>(json, 'name', 'OrganizationInfo'),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'name': name};

  /// Copies this record with selected values replaced.
  OrganizationInfo copyWith({String? id, String? name}) =>
      OrganizationInfo(id: id ?? this.id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationInfo && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'OrganizationInfo(id: $id)';
}

/// An organization member.
@immutable
final class OrganizationUser {
  /// The user ID.
  final String id;

  /// The user email address.
  final String email;

  /// The user display name.
  final String name;

  /// The organization role as sent by the server.
  final String role;

  /// When the user joined the organization.
  final DateTime addedAt;

  /// The response discriminator.
  String get type => 'user';

  /// Creates a [OrganizationUser].
  const OrganizationUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.addedAt,
  });

  /// Reads a [OrganizationUser] from its response object.
  factory OrganizationUser.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'user');
    return OrganizationUser(
      id: requiredOrganizationField<String>(json, 'id', 'OrganizationUser'),
      email: requiredOrganizationField<String>(
        json,
        'email',
        'OrganizationUser',
      ),
      name: requiredOrganizationField<String>(json, 'name', 'OrganizationUser'),
      role: requiredOrganizationField<String>(json, 'role', 'OrganizationUser'),
      addedAt: DateTime.parse(
        requiredOrganizationField<String>(json, 'added_at', 'OrganizationUser'),
      ),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'added_at': addedAt.toUtc().toIso8601String(),
  };

  /// Copies this record with selected values replaced.
  OrganizationUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? addedAt,
  }) => OrganizationUser(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    role: role ?? this.role,
    addedAt: addedAt ?? this.addedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationUser &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          role == other.role &&
          addedAt == other.addedAt;

  @override
  int get hashCode => Object.hash(id, email, name, role, addedAt);

  @override
  String toString() => 'OrganizationUser(id: $id)';
}

/// An invitation to join an organization.
@immutable
final class OrganizationInvite {
  /// The invitation ID.
  final String id;

  /// The invited email address.
  final String email;

  /// The organization role assigned on acceptance.
  final String role;

  /// The current invitation status.
  final String status;

  /// When the invitation was sent.
  final DateTime invitedAt;

  /// When the invitation expires.
  final DateTime expiresAt;

  /// When the invitation was accepted, if any.
  final DateTime? acceptedAt;

  /// RBAC groups assigned on acceptance.
  final List<String> rbacGroupIds;

  /// The response discriminator.
  String get type => 'invite';

  /// Creates a [OrganizationInvite].
  OrganizationInvite({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedAt,
    required this.expiresAt,
    required this.acceptedAt,
    required List<String> rbacGroupIds,
  }) : rbacGroupIds = List.unmodifiable(rbacGroupIds);

  /// Reads a [OrganizationInvite] from its response object.
  factory OrganizationInvite.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'invite');
    return OrganizationInvite(
      id: requiredOrganizationField<String>(json, 'id', 'OrganizationInvite'),
      email: requiredOrganizationField<String>(
        json,
        'email',
        'OrganizationInvite',
      ),
      role: requiredOrganizationField<String>(
        json,
        'role',
        'OrganizationInvite',
      ),
      status: requiredOrganizationField<String>(
        json,
        'status',
        'OrganizationInvite',
      ),
      invitedAt: DateTime.parse(
        requiredOrganizationField<String>(
          json,
          'invited_at',
          'OrganizationInvite',
        ),
      ),
      expiresAt: DateTime.parse(
        requiredOrganizationField<String>(
          json,
          'expires_at',
          'OrganizationInvite',
        ),
      ),
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      rbacGroupIds: List<String>.unmodifiable(
        requiredOrganizationField<List<Object?>>(
          json,
          'rbac_group_ids',
          'OrganizationInvite',
        ).cast<String>(),
      ),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'email': email,
    'role': role,
    'status': status,
    'invited_at': invitedAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'accepted_at': acceptedAt?.toUtc().toIso8601String(),
    'rbac_group_ids': rbacGroupIds,
  };

  /// Copies this record with selected values replaced.
  OrganizationInvite copyWith({
    String? id,
    String? email,
    String? role,
    String? status,
    DateTime? invitedAt,
    DateTime? expiresAt,
    Object? acceptedAt = unsetCopyWithValue,
    List<String>? rbacGroupIds,
  }) => OrganizationInvite(
    id: id ?? this.id,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
    invitedAt: invitedAt ?? this.invitedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    acceptedAt: acceptedAt == unsetCopyWithValue
        ? this.acceptedAt
        : acceptedAt as DateTime?,
    rbacGroupIds: rbacGroupIds ?? this.rbacGroupIds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationInvite &&
          id == other.id &&
          email == other.email &&
          role == other.role &&
          status == other.status &&
          invitedAt == other.invitedAt &&
          expiresAt == other.expiresAt &&
          acceptedAt == other.acceptedAt &&
          listsEqual(rbacGroupIds, other.rbacGroupIds);

  @override
  int get hashCode => Object.hash(
    id,
    email,
    role,
    status,
    invitedAt,
    expiresAt,
    acceptedAt,
    listHash(rbacGroupIds),
  );

  @override
  String toString() => 'OrganizationInvite(id: $id)';
}

/// A workspace member and assigned workspace role.
@immutable
final class OrganizationWorkspaceMember {
  /// The member user ID.
  final String userId;

  /// The workspace ID.
  final String workspaceId;

  /// The role granted in this workspace.
  final String workspaceRole;

  /// The response discriminator.
  String get type => 'workspace_member';

  /// Creates a [OrganizationWorkspaceMember].
  const OrganizationWorkspaceMember({
    required this.userId,
    required this.workspaceId,
    required this.workspaceRole,
  });

  /// Reads a [OrganizationWorkspaceMember] from its response object.
  factory OrganizationWorkspaceMember.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'workspace_member');
    return OrganizationWorkspaceMember(
      userId: requiredOrganizationField<String>(
        json,
        'user_id',
        'OrganizationWorkspaceMember',
      ),
      workspaceId: requiredOrganizationField<String>(
        json,
        'workspace_id',
        'OrganizationWorkspaceMember',
      ),
      workspaceRole: requiredOrganizationField<String>(
        json,
        'workspace_role',
        'OrganizationWorkspaceMember',
      ),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'user_id': userId,
    'workspace_id': workspaceId,
    'workspace_role': workspaceRole,
  };

  /// Copies this record with selected values replaced.
  OrganizationWorkspaceMember copyWith({
    String? userId,
    String? workspaceId,
    String? workspaceRole,
  }) => OrganizationWorkspaceMember(
    userId: userId ?? this.userId,
    workspaceId: workspaceId ?? this.workspaceId,
    workspaceRole: workspaceRole ?? this.workspaceRole,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationWorkspaceMember &&
          userId == other.userId &&
          workspaceId == other.workspaceId &&
          workspaceRole == other.workspaceRole;

  @override
  int get hashCode => Object.hash(userId, workspaceId, workspaceRole);

  @override
  String toString() => 'OrganizationWorkspaceMember(userId: $userId)';
}

/// Confirmation that an invitation was deleted.
@immutable
final class DeletedOrganizationInvite {
  /// The removed invitation ID.
  final String id;

  /// The response discriminator.
  String get type => 'invite_deleted';

  /// Creates a [DeletedOrganizationInvite].
  const DeletedOrganizationInvite({required this.id});

  /// Reads a [DeletedOrganizationInvite] from its response object.
  factory DeletedOrganizationInvite.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'invite_deleted');
    return DeletedOrganizationInvite(
      id: requiredOrganizationField<String>(
        json,
        'id',
        'DeletedOrganizationInvite',
      ),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies this record with selected values replaced.
  DeletedOrganizationInvite copyWith({String? id}) =>
      DeletedOrganizationInvite(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedOrganizationInvite && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeletedOrganizationInvite(id: $id)';
}

/// Confirmation that an organization member was removed.
@immutable
final class DeletedOrganizationUser {
  /// The removed user ID.
  final String id;

  /// The response discriminator.
  String get type => 'user_deleted';

  /// Creates a [DeletedOrganizationUser].
  const DeletedOrganizationUser({required this.id});

  /// Reads a [DeletedOrganizationUser] from its response object.
  factory DeletedOrganizationUser.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'user_deleted');
    return DeletedOrganizationUser(
      id: requiredOrganizationField<String>(
        json,
        'id',
        'DeletedOrganizationUser',
      ),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies this record with selected values replaced.
  DeletedOrganizationUser copyWith({String? id}) =>
      DeletedOrganizationUser(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedOrganizationUser && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeletedOrganizationUser(id: $id)';
}

/// Confirmation that a workspace member was removed.
@immutable
final class DeletedOrganizationWorkspaceMember {
  /// The removed user ID.
  final String userId;

  /// The workspace ID.
  final String workspaceId;

  /// The response discriminator.
  String get type => 'workspace_member_deleted';

  /// Creates a [DeletedOrganizationWorkspaceMember].
  const DeletedOrganizationWorkspaceMember({
    required this.userId,
    required this.workspaceId,
  });

  /// Reads a [DeletedOrganizationWorkspaceMember] from its response object.
  factory DeletedOrganizationWorkspaceMember.fromJson(
    Map<String, dynamic> json,
  ) {
    checkOrganizationType(json, 'workspace_member_deleted');
    return DeletedOrganizationWorkspaceMember(
      userId: requiredOrganizationField<String>(
        json,
        'user_id',
        'DeletedOrganizationWorkspaceMember',
      ),
      workspaceId: requiredOrganizationField<String>(
        json,
        'workspace_id',
        'DeletedOrganizationWorkspaceMember',
      ),
    );
  }

  /// Converts this record to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'user_id': userId,
    'workspace_id': workspaceId,
  };

  /// Copies this record with selected values replaced.
  DeletedOrganizationWorkspaceMember copyWith({
    String? userId,
    String? workspaceId,
  }) => DeletedOrganizationWorkspaceMember(
    userId: userId ?? this.userId,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedOrganizationWorkspaceMember &&
          userId == other.userId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(userId, workspaceId);

  @override
  String toString() => 'DeletedOrganizationWorkspaceMember(userId: $userId)';
}
