import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';

/// An organization role assignable to a service account.
enum ServiceAccountRole {
  /// Grants organization administration where the interactive credential allows.
  admin,

  /// Grants the default developer role.
  developer,
}

/// A workspace role assignable to a service account.
enum ServiceAccountWorkspaceRole {
  /// Administers the workspace.
  admin('workspace_admin'),

  /// Develops applications in the workspace.
  developer('workspace_developer'),

  /// Develops with restricted workspace permissions.
  restrictedDeveloper('workspace_restricted_developer'),

  /// Has basic workspace membership.
  user('workspace_user');

  const ServiceAccountWorkspaceRole(this.wireValue);

  /// The role sent to the Admin API.
  final String wireValue;
}

/// A non-human organization identity for credentials and federation.
@immutable
final class ServiceAccount {
  /// Creates a ServiceAccount record.
  const ServiceAccount({
    required this.id,
    required this.name,
    required this.description,
    required this.organizationRole,
    required this.createdAt,
    required this.createdByActorId,
    required this.updatedAt,
    required this.updatedByActorId,
    required this.archivedAt,
    required this.archivedByActorId,
  });

  /// The tagged service account ID.
  final String id;

  /// The service account slug.
  final String name;

  /// The account description, when set.
  final String? description;

  /// The organization role as sent by the API.
  final String organizationRole;

  /// When the account was created.
  final DateTime createdAt;

  /// The actor who created the account.
  final String? createdByActorId;

  /// When the account was last updated.
  final DateTime updatedAt;

  /// The actor who last updated the account.
  final String? updatedByActorId;

  /// When the account was archived, if applicable.
  final DateTime? archivedAt;

  /// The actor who archived the account.
  final String? archivedByActorId;

  /// The wire discriminator.
  String get type => 'service_account';

  /// Decodes this record from the Admin API.
  factory ServiceAccount.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'service_account');
    return ServiceAccount(
      id: requiredOrganizationField<String>(json, 'id', 'ServiceAccount'),
      name: requiredOrganizationField<String>(json, 'name', 'ServiceAccount'),
      description: requiredOrganizationField<String?>(
        json,
        'description',
        'ServiceAccount',
      ),
      organizationRole: requiredOrganizationField<String>(
        json,
        'organization_role',
        'ServiceAccount',
      ),
      createdAt: DateTime.parse(
        requiredOrganizationField<String>(json, 'created_at', 'ServiceAccount'),
      ),
      createdByActorId: requiredOrganizationField<String?>(
        json,
        'created_by_actor_id',
        'ServiceAccount',
      ),
      updatedAt: DateTime.parse(
        requiredOrganizationField<String>(json, 'updated_at', 'ServiceAccount'),
      ),
      updatedByActorId: requiredOrganizationField<String?>(
        json,
        'updated_by_actor_id',
        'ServiceAccount',
      ),
      archivedAt: _nullableTime(json, 'archived_at', 'ServiceAccount'),
      archivedByActorId: requiredOrganizationField<String?>(
        json,
        'archived_by_actor_id',
        'ServiceAccount',
      ),
    );
  }

  /// Encodes the response with the original wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'description': description,
    'organization_role': organizationRole,
    'created_at': createdAt.toUtc().toIso8601String(),
    'created_by_actor_id': createdByActorId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'updated_by_actor_id': updatedByActorId,
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'archived_by_actor_id': archivedByActorId,
  };

  /// Copies this record with selected fields replaced.
  ServiceAccount copyWith({
    String? id,
    String? name,
    Object? description = unsetCopyWithValue,
    String? organizationRole,
    DateTime? createdAt,
    Object? createdByActorId = unsetCopyWithValue,
    DateTime? updatedAt,
    Object? updatedByActorId = unsetCopyWithValue,
    Object? archivedAt = unsetCopyWithValue,
    Object? archivedByActorId = unsetCopyWithValue,
  }) => ServiceAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    description: identical(description, unsetCopyWithValue)
        ? this.description
        : description as String?,
    organizationRole: organizationRole ?? this.organizationRole,
    createdAt: createdAt ?? this.createdAt,
    createdByActorId: identical(createdByActorId, unsetCopyWithValue)
        ? this.createdByActorId
        : createdByActorId as String?,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedByActorId: identical(updatedByActorId, unsetCopyWithValue)
        ? this.updatedByActorId
        : updatedByActorId as String?,
    archivedAt: identical(archivedAt, unsetCopyWithValue)
        ? this.archivedAt
        : archivedAt as DateTime?,
    archivedByActorId: identical(archivedByActorId, unsetCopyWithValue)
        ? this.archivedByActorId
        : archivedByActorId as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is ServiceAccount &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      organizationRole == other.organizationRole &&
      createdAt == other.createdAt &&
      createdByActorId == other.createdByActorId &&
      updatedAt == other.updatedAt &&
      updatedByActorId == other.updatedByActorId &&
      archivedAt == other.archivedAt &&
      archivedByActorId == other.archivedByActorId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    organizationRole,
    createdAt,
    createdByActorId,
    updatedAt,
    updatedByActorId,
    archivedAt,
    archivedByActorId,
  );

  @override
  String toString() =>
      'ServiceAccount(id: $id, name: $name, description: ${description?.length ?? 0} chars, '
      'organizationRole: $organizationRole, createdAt: $createdAt, createdByActorId: $createdByActorId, '
      'updatedAt: $updatedAt, updatedByActorId: $updatedByActorId, archivedAt: $archivedAt, '
      'archivedByActorId: $archivedByActorId)';
}

/// A service account’s membership in a workspace.
@immutable
final class ServiceAccountWorkspaceMember {
  /// Creates a ServiceAccountWorkspaceMember record.
  const ServiceAccountWorkspaceMember({
    required this.serviceAccountId,
    required this.workspaceId,
    required this.workspaceRole,
    required this.implicit,
    required this.createdByActorId,
  });

  /// The tagged service account ID.
  final String serviceAccountId;

  /// The tagged workspace ID.
  final String workspaceId;

  /// The workspace role as sent by the API.
  final String workspaceRole;

  /// Whether this is the implicit Default Workspace membership.
  final bool? implicit;

  /// The actor who created the membership, when available.
  final String? createdByActorId;

  /// The wire discriminator.
  String get type => 'service_account_workspace_member';

  /// Decodes this record from the Admin API.
  factory ServiceAccountWorkspaceMember.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'service_account_workspace_member');
    return ServiceAccountWorkspaceMember(
      serviceAccountId: requiredOrganizationField<String>(
        json,
        'service_account_id',
        'ServiceAccountWorkspaceMember',
      ),
      workspaceId: requiredOrganizationField<String>(
        json,
        'workspace_id',
        'ServiceAccountWorkspaceMember',
      ),
      workspaceRole: requiredOrganizationField<String>(
        json,
        'workspace_role',
        'ServiceAccountWorkspaceMember',
      ),
      implicit: requiredOrganizationField<bool?>(
        json,
        'implicit',
        'ServiceAccountWorkspaceMember',
      ),
      createdByActorId: requiredOrganizationField<String?>(
        json,
        'created_by_actor_id',
        'ServiceAccountWorkspaceMember',
      ),
    );
  }

  /// Encodes the response with the original wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'service_account_id': serviceAccountId,
    'workspace_id': workspaceId,
    'workspace_role': workspaceRole,
    'implicit': implicit,
    'created_by_actor_id': createdByActorId,
  };

  /// Copies this record with selected fields replaced.
  ServiceAccountWorkspaceMember copyWith({
    String? serviceAccountId,
    String? workspaceId,
    String? workspaceRole,
    Object? implicit = unsetCopyWithValue,
    Object? createdByActorId = unsetCopyWithValue,
  }) => ServiceAccountWorkspaceMember(
    serviceAccountId: serviceAccountId ?? this.serviceAccountId,
    workspaceId: workspaceId ?? this.workspaceId,
    workspaceRole: workspaceRole ?? this.workspaceRole,
    implicit: identical(implicit, unsetCopyWithValue)
        ? this.implicit
        : implicit as bool?,
    createdByActorId: identical(createdByActorId, unsetCopyWithValue)
        ? this.createdByActorId
        : createdByActorId as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is ServiceAccountWorkspaceMember &&
      serviceAccountId == other.serviceAccountId &&
      workspaceId == other.workspaceId &&
      workspaceRole == other.workspaceRole &&
      implicit == other.implicit &&
      createdByActorId == other.createdByActorId;

  @override
  int get hashCode => Object.hash(
    serviceAccountId,
    workspaceId,
    workspaceRole,
    implicit,
    createdByActorId,
  );

  @override
  String toString() =>
      'ServiceAccountWorkspaceMember(serviceAccountId: $serviceAccountId, workspaceId: $workspaceId, workspaceRole: $workspaceRole, '
      'implicit: $implicit, createdByActorId: $createdByActorId)';
}

/// The receipt for removal of a service account’s workspace membership.
@immutable
final class DeletedServiceAccountWorkspaceMember {
  /// Creates a DeletedServiceAccountWorkspaceMember record.
  const DeletedServiceAccountWorkspaceMember({
    required this.serviceAccountId,
    required this.workspaceId,
  });

  /// The tagged service account ID.
  final String serviceAccountId;

  /// The tagged workspace ID.
  final String workspaceId;

  /// The wire discriminator.
  String get type => 'service_account_workspace_member_deleted';

  /// Decodes this record from the Admin API.
  factory DeletedServiceAccountWorkspaceMember.fromJson(
    Map<String, dynamic> json,
  ) {
    checkOrganizationType(json, 'service_account_workspace_member_deleted');
    return DeletedServiceAccountWorkspaceMember(
      serviceAccountId: requiredOrganizationField<String>(
        json,
        'service_account_id',
        'DeletedServiceAccountWorkspaceMember',
      ),
      workspaceId: requiredOrganizationField<String>(
        json,
        'workspace_id',
        'DeletedServiceAccountWorkspaceMember',
      ),
    );
  }

  /// Encodes the response with the original wire keys.
  Map<String, dynamic> toJson() => {
    'type': type,
    'service_account_id': serviceAccountId,
    'workspace_id': workspaceId,
  };

  /// Copies this record with selected fields replaced.
  DeletedServiceAccountWorkspaceMember copyWith({
    String? serviceAccountId,
    String? workspaceId,
  }) => DeletedServiceAccountWorkspaceMember(
    serviceAccountId: serviceAccountId ?? this.serviceAccountId,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      other is DeletedServiceAccountWorkspaceMember &&
      serviceAccountId == other.serviceAccountId &&
      workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(serviceAccountId, workspaceId);

  @override
  String toString() =>
      'DeletedServiceAccountWorkspaceMember(serviceAccountId: $serviceAccountId, workspaceId: $workspaceId)';
}

DateTime? _nullableTime(Map<String, dynamic> json, String key, String model) {
  final value = requiredOrganizationField<String?>(json, key, model);
  return value == null ? null : DateTime.parse(value);
}
