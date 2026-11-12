import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// A group managed directly or synchronized from an identity provider.
@immutable
final class OrganizationRbacGroup {
  /// Parses a group's metadata and nullable custom role IDs.
  OrganizationRbacGroup.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(json, 'id', 'RBAC group'),
      name = requiredOrganizationField<String>(json, 'name', 'RBAC group'),
      sourceType = requiredOrganizationField<String>(
        json,
        'source_type',
        'RBAC group',
      ),
      roleIds = switch (requiredOrganizationField<List<Object?>?>(
        json,
        'role_ids',
        'RBAC group',
        legacyKey: 'roles',
      )) {
        final ids? => List<String>.unmodifiable(ids.cast<String>()),
        null => null,
      },
      createdAt = DateTime.parse(
        requiredOrganizationField<String>(json, 'created_at', 'RBAC group'),
      ),
      updatedAt = DateTime.parse(
        requiredOrganizationField<String>(json, 'updated_at', 'RBAC group'),
      ) {
    checkOrganizationType(json, 'rbac_group');
  }

  /// The tagged group ID.
  final String id;

  /// The group's display name.
  final String name;

  /// The source discriminator, currently `direct` or `scim`.
  final String sourceType;

  /// Custom role IDs, or null when the server returns no assignment list.
  final List<String>? roleIds;

  /// When the group was created.
  final DateTime createdAt;

  /// When the group was last updated.
  final DateTime updatedAt;

  /// Converts this group to its API representation.
  Map<String, dynamic> toJson() => {
    'type': 'rbac_group',
    'id': id,
    'name': name,
    'source_type': sourceType,
    'role_ids': roleIds,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRbacGroup &&
      id == other.id &&
      name == other.name &&
      sourceType == other.sourceType &&
      listsEqual(roleIds, other.roleIds) &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sourceType,
    listHash(roleIds),
    createdAt,
    updatedAt,
  );
}

/// A user membership in a role-based access group.
@immutable
final class OrganizationRbacGroupMember {
  /// Parses a group membership.
  OrganizationRbacGroupMember.fromJson(Map<String, dynamic> json)
    : groupId = requiredOrganizationField<String>(
        json,
        'rbac_group_id',
        'RBAC group member',
        legacyKey: 'group_id',
      ),
      userId = requiredOrganizationField<String>(
        json,
        'user_id',
        'RBAC group member',
      ),
      email = requiredOrganizationField<String>(
        json,
        'email',
        'RBAC group member',
      ),
      createdAt = DateTime.parse(
        requiredOrganizationField<String>(
          json,
          'created_at',
          'RBAC group member',
        ),
      ) {
    checkOrganizationType(json, 'rbac_group_member');
  }

  /// The group's tagged ID.
  final String groupId;

  /// The member's tagged user ID.
  final String userId;

  /// The member's current email address.
  final String email;

  /// When the member joined this group.
  final DateTime createdAt;

  /// Converts the membership to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'rbac_group_member',
    'rbac_group_id': groupId,
    'user_id': userId,
    'email': email,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRbacGroupMember &&
      groupId == other.groupId &&
      userId == other.userId &&
      email == other.email &&
      createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(groupId, userId, email, createdAt);
}

/// Confirmation of a deleted group.
@immutable
final class DeletedOrganizationRbacGroup {
  /// Parses the group deletion receipt.
  DeletedOrganizationRbacGroup.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(json, 'id', 'deleted RBAC group') {
    checkOrganizationType(json, 'rbac_group_deleted');
  }

  /// The deleted group ID.
  final String id;

  /// Converts the deletion receipt to JSON.
  Map<String, dynamic> toJson() => {'type': 'rbac_group_deleted', 'id': id};

  @override
  bool operator ==(Object other) =>
      other is DeletedOrganizationRbacGroup && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Confirmation that a group membership was removed.
@immutable
final class DeletedOrganizationRbacGroupMember {
  /// Parses the group-member deletion receipt.
  DeletedOrganizationRbacGroupMember.fromJson(Map<String, dynamic> json)
    : groupId = requiredOrganizationField<String>(
        json,
        'rbac_group_id',
        'deleted RBAC group member',
        legacyKey: 'group_id',
      ),
      userId = requiredOrganizationField<String>(
        json,
        'user_id',
        'deleted RBAC group member',
      ) {
    checkOrganizationType(json, 'rbac_group_member_deleted');
  }

  /// The group ID.
  final String groupId;

  /// The removed user's ID.
  final String userId;

  /// Converts the deletion receipt to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'rbac_group_member_deleted',
    'rbac_group_id': groupId,
    'user_id': userId,
  };

  @override
  bool operator ==(Object other) =>
      other is DeletedOrganizationRbacGroupMember &&
      groupId == other.groupId &&
      userId == other.userId;

  @override
  int get hashCode => Object.hash(groupId, userId);
}

/// A custom role and its display metadata.
@immutable
final class OrganizationRbacRole {
  /// Parses a custom role.
  OrganizationRbacRole.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(json, 'id', 'RBAC role'),
      displayName = requiredOrganizationField<String>(
        json,
        'display_name',
        'RBAC role',
        legacyKey: 'name',
      ),
      createdAt = DateTime.parse(
        requiredOrganizationField<String>(json, 'created_at', 'RBAC role'),
      ),
      updatedAt = DateTime.parse(
        requiredOrganizationField<String>(json, 'updated_at', 'RBAC role'),
      ) {
    checkOrganizationType(json, 'rbac_role');
  }

  /// The role's tagged ID.
  final String id;

  /// The role's display name.
  final String displayName;

  /// When the role was created.
  final DateTime createdAt;

  /// When the role was last updated.
  final DateTime updatedAt;

  /// Converts the role to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'rbac_role',
    'id': id,
    'display_name': displayName,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRbacRole &&
      id == other.id &&
      displayName == other.displayName &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, displayName, createdAt, updatedAt);
}

/// The organization or connector resource addressed by an RBAC permission.
@immutable
final class OrganizationRbacPermissionResource {
  /// Parses known identifier fields and preserves future resource kinds.
  OrganizationRbacPermissionResource.fromJson(Map<String, dynamic> json)
    : raw = deepUnmodifiableMap(json),
      type = requiredOrganizationField<String>(json, 'type', 'RBAC resource') {
    switch (type) {
      case 'organization':
        requiredOrganizationField<String>(
          json,
          'organization_id',
          'RBAC resource',
        );
      case 'connector_tool':
        requiredOrganizationField<String>(json, 'tool_name', 'RBAC resource');
        continue connector;
      case 'connector_scope':
        requiredOrganizationField<String>(json, 'scope', 'RBAC resource');
        continue connector;
      connector:
      case 'connector':
        requiredOrganizationField<String>(
          json,
          'connector_id',
          'RBAC resource',
        );
    }
  }

  /// The resource kind, including any newly introduced wire value.
  final String type;

  /// Original fields, including identifiers on future resource kinds.
  final Map<String, dynamic> raw;

  /// The organization ID for an organization resource.
  String? get organizationId => raw['organization_id'] as String?;

  /// The connector ID for a connector, scope or tool resource.
  String? get connectorId => raw['connector_id'] as String?;

  /// The scope name for a connector scope resource.
  String? get scope => raw['scope'] as String?;

  /// The tool name for a connector tool resource.
  String? get toolName => raw['tool_name'] as String?;

  /// Converts the resource to its original JSON.
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      other is OrganizationRbacPermissionResource &&
      mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A named action granted on an organization or connector resource.
@immutable
final class OrganizationRbacRolePermission {
  /// Parses the action and its target resource.
  OrganizationRbacRolePermission.fromJson(Map<String, dynamic> json)
    : action = requiredOrganizationField<String>(
        json,
        'action',
        'RBAC permission',
      ),
      resource = OrganizationRbacPermissionResource.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(
          json,
          'resource',
          'RBAC permission',
        ),
      ) {
    checkOrganizationType(json, 'rbac_role_permission');
  }

  /// The action string as returned by the server.
  final String action;

  /// The resource this permission applies to.
  final OrganizationRbacPermissionResource resource;

  /// Converts the permission to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'rbac_role_permission',
    'action': action,
    'resource': resource.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationRbacRolePermission &&
      action == other.action &&
      resource == other.resource;

  @override
  int get hashCode => Object.hash(action, resource);
}
