import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

import '../common/equality_helpers.dart';

/// A workspace-scoped service account.
@immutable
class ServiceAccount {
  /// Creates a [ServiceAccount].
  const ServiceAccount({
    required this.createdAt,
    required this.customerId,
    required this.deletedAt,
    required this.description,
    required this.id,
    required this.name,
    required this.organizationId,
    required this.updatedAt,
    required this.workspaceId,
  });

  /// The created_at field.
  final String createdAt;

  /// The customer_id field.
  final String customerId;

  /// The deleted_at field.
  final String? deletedAt;

  /// The description field.
  final String? description;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The organization_id field.
  final String organizationId;

  /// The updated_at field.
  final String updatedAt;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [ServiceAccount] from JSON.
  factory ServiceAccount.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('ServiceAccount: missing created_at');
    }
    if (json['customer_id'] == null) {
      throw const FormatException('ServiceAccount: missing customer_id');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('ServiceAccount: missing deleted_at');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('ServiceAccount: missing description');
    }
    if (json['id'] == null) {
      throw const FormatException('ServiceAccount: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('ServiceAccount: missing name');
    }
    if (json['organization_id'] == null) {
      throw const FormatException('ServiceAccount: missing organization_id');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('ServiceAccount: missing updated_at');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException('ServiceAccount: missing workspace_id');
    }
    return ServiceAccount(
      createdAt: json['created_at'] as String,
      customerId: json['customer_id'] as String,
      deletedAt: json['deleted_at'] == null
          ? null
          : json['deleted_at'] as String,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
      updatedAt: json['updated_at'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'customer_id': customerId,
    'deleted_at': deletedAt,
    'description': description,
    'id': id,
    'name': name,
    'organization_id': organizationId,
    'updated_at': updatedAt,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  ServiceAccount copyWith({
    String? createdAt,
    String? customerId,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    String? id,
    String? name,
    String? organizationId,
    String? updatedAt,
    String? workspaceId,
  }) => ServiceAccount(
    createdAt: createdAt ?? this.createdAt,
    customerId: customerId ?? this.customerId,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    id: id ?? this.id,
    name: name ?? this.name,
    organizationId: organizationId ?? this.organizationId,
    updatedAt: updatedAt ?? this.updatedAt,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAccount &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          customerId == other.customerId &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          id == other.id &&
          name == other.name &&
          organizationId == other.organizationId &&
          updatedAt == other.updatedAt &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    customerId,
    deletedAt,
    description,
    id,
    name,
    organizationId,
    updatedAt,
    workspaceId,
  ]);

  @override
  String toString() =>
      'ServiceAccount('
      'createdAt: $createdAt, '
      'customerId: $customerId, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'id: $id, '
      'name: $name, '
      'organizationId: $organizationId, '
      'updatedAt: $updatedAt, '
      'workspaceId: $workspaceId)';
}

/// An offset-paginated page of service accounts.
@immutable
class ServiceAccountList {
  /// Creates a [ServiceAccountList].
  const ServiceAccountList({required this.items});

  /// The items field.
  final List<ServiceAccount> items;

  /// Parses a [ServiceAccountList] from JSON.
  factory ServiceAccountList.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException('ServiceAccountList: missing items');
    }
    return ServiceAccountList(
      items: (json['items'] as List)
          .map((item) => ServiceAccount.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ServiceAccountList copyWith({List<ServiceAccount>? items}) =>
      ServiceAccountList(items: items ?? this.items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAccountList &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(items, other.items);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(items)]);

  @override
  String toString() =>
      'ServiceAccountList('
      'items: ${items.length})';
}

/// Direction to sort service accounts by creation time.
enum ServiceAccountSortOrder {
  /// Represents asc.
  asc('asc'),

  /// Represents desc.
  desc('desc'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ServiceAccountSortOrder(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ServiceAccountSortOrder fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Creates a service account in a workspace.
@immutable
class CreateServiceAccountRequest {
  /// Creates a [CreateServiceAccountRequest].
  const CreateServiceAccountRequest({
    this.description,
    required this.name,
    this.roleIds,
    required this.workspaceId,
  });

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// Workspace role UUIDs to assign. Omitted or empty lists default to member, which grants no role permissions. Workspace-wide sharing may still grant access.
  final List<String>? roleIds;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [CreateServiceAccountRequest] from JSON.
  factory CreateServiceAccountRequest.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('CreateServiceAccountRequest: missing name');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException(
        'CreateServiceAccountRequest: missing workspace_id',
      );
    }
    return CreateServiceAccountRequest(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
      roleIds: json['role_ids'] == null
          ? null
          : (json['role_ids'] as List).map((item) => item as String).toList(),
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': ?description,
    'name': name,
    'role_ids': ?roleIds,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  CreateServiceAccountRequest copyWith({
    Object? description = unsetCopyWithValue,
    String? name,
    Object? roleIds = unsetCopyWithValue,
    String? workspaceId,
  }) => CreateServiceAccountRequest(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
    roleIds: roleIds == unsetCopyWithValue
        ? this.roleIds
        : (roleIds as List?)?.cast<String>(),
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateServiceAccountRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          name == other.name &&
          valuesDeepEqual(roleIds, other.roleIds) &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    description,
    name,
    valueDeepHashCode(roleIds),
    workspaceId,
  ]);

  @override
  String toString() =>
      'CreateServiceAccountRequest('
      'description: $description, '
      'name: $name, '
      'roleIds: ${roleIds?.length}, '
      'workspaceId: $workspaceId)';
}

/// A role that can be assigned to a service account.
@immutable
class AssignableServiceAccountRole {
  /// Creates a [AssignableServiceAccountRole].
  const AssignableServiceAccountRole({
    required this.description,
    required this.isCustomRole,
    required this.name,
    required this.uuid,
  });

  /// The description field.
  final String description;

  /// The is_custom_role field.
  final bool isCustomRole;

  /// The name field.
  final String name;

  /// The uuid field.
  final String uuid;

  /// Parses a [AssignableServiceAccountRole] from JSON.
  factory AssignableServiceAccountRole.fromJson(Map<String, dynamic> json) {
    if (json['description'] == null) {
      throw const FormatException(
        'AssignableServiceAccountRole: missing description',
      );
    }
    if (json['is_custom_role'] == null) {
      throw const FormatException(
        'AssignableServiceAccountRole: missing is_custom_role',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('AssignableServiceAccountRole: missing name');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AssignableServiceAccountRole: missing uuid');
    }
    return AssignableServiceAccountRole(
      description: json['description'] as String,
      isCustomRole: json['is_custom_role'] as bool,
      name: json['name'] as String,
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': description,
    'is_custom_role': isCustomRole,
    'name': name,
    'uuid': uuid,
  };

  /// Creates a copy with the given fields replaced.
  AssignableServiceAccountRole copyWith({
    String? description,
    bool? isCustomRole,
    String? name,
    String? uuid,
  }) => AssignableServiceAccountRole(
    description: description ?? this.description,
    isCustomRole: isCustomRole ?? this.isCustomRole,
    name: name ?? this.name,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignableServiceAccountRole &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          isCustomRole == other.isCustomRole &&
          name == other.name &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([description, isCustomRole, name, uuid]);

  @override
  String toString() =>
      'AssignableServiceAccountRole('
      'description: $description, '
      'isCustomRole: $isCustomRole, '
      'name: $name, '
      'uuid: $uuid)';
}

/// Roles available for assignment in a workspace.
@immutable
class AssignableServiceAccountRoles {
  /// Creates a [AssignableServiceAccountRoles].
  const AssignableServiceAccountRoles({required this.items});

  /// The items field.
  final List<AssignableServiceAccountRole> items;

  /// Parses a [AssignableServiceAccountRoles] from JSON.
  factory AssignableServiceAccountRoles.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException(
        'AssignableServiceAccountRoles: missing items',
      );
    }
    return AssignableServiceAccountRoles(
      items: (json['items'] as List)
          .map(
            (item) => AssignableServiceAccountRole.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AssignableServiceAccountRoles copyWith({
    List<AssignableServiceAccountRole>? items,
  }) => AssignableServiceAccountRoles(items: items ?? this.items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignableServiceAccountRoles &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(items, other.items);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(items)]);

  @override
  String toString() =>
      'AssignableServiceAccountRoles('
      'items: ${items.length})';
}

/// A role assigned to a service account.
@immutable
class ServiceAccountRole {
  /// Creates a [ServiceAccountRole].
  const ServiceAccountRole({required this.roleId});

  /// The role_id field.
  final String roleId;

  /// Parses a [ServiceAccountRole] from JSON.
  factory ServiceAccountRole.fromJson(Map<String, dynamic> json) {
    if (json['role_id'] == null) {
      throw const FormatException('ServiceAccountRole: missing role_id');
    }
    return ServiceAccountRole(roleId: json['role_id'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'role_id': roleId};

  /// Creates a copy with the given fields replaced.
  ServiceAccountRole copyWith({String? roleId}) =>
      ServiceAccountRole(roleId: roleId ?? this.roleId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAccountRole &&
          runtimeType == other.runtimeType &&
          roleId == other.roleId;

  @override
  int get hashCode => Object.hashAll([roleId]);

  @override
  String toString() =>
      'ServiceAccountRole('
      'roleId: $roleId)';
}

/// The roles assigned to a service account.
@immutable
class ServiceAccountRoles {
  /// Creates a [ServiceAccountRoles].
  const ServiceAccountRoles({required this.items});

  /// The items field.
  final List<ServiceAccountRole> items;

  /// Parses a [ServiceAccountRoles] from JSON.
  factory ServiceAccountRoles.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException('ServiceAccountRoles: missing items');
    }
    return ServiceAccountRoles(
      items: (json['items'] as List)
          .map(
            (item) => ServiceAccountRole.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ServiceAccountRoles copyWith({List<ServiceAccountRole>? items}) =>
      ServiceAccountRoles(items: items ?? this.items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAccountRoles &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(items, other.items);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(items)]);

  @override
  String toString() =>
      'ServiceAccountRoles('
      'items: ${items.length})';
}

/// Replaces a service account's assigned roles.
@immutable
class SetServiceAccountRolesRequest {
  /// Creates a [SetServiceAccountRolesRequest].
  const SetServiceAccountRolesRequest({required this.roleIds});

  /// Workspace role UUIDs to assign. Required and non-empty; omitted or empty lists return 422. Select member explicitly for no role-granted permissions; workspace-wide sharing may still grant access.
  final List<String> roleIds;

  /// Parses a [SetServiceAccountRolesRequest] from JSON.
  factory SetServiceAccountRolesRequest.fromJson(Map<String, dynamic> json) {
    if (json['role_ids'] == null) {
      throw const FormatException(
        'SetServiceAccountRolesRequest: missing role_ids',
      );
    }
    return SetServiceAccountRolesRequest(
      roleIds: (json['role_ids'] as List)
          .map((item) => item as String)
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'role_ids': roleIds};

  /// Creates a copy with the given fields replaced.
  SetServiceAccountRolesRequest copyWith({List<String>? roleIds}) =>
      SetServiceAccountRolesRequest(roleIds: roleIds ?? this.roleIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetServiceAccountRolesRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(roleIds, other.roleIds);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(roleIds)]);

  @override
  String toString() =>
      'SetServiceAccountRolesRequest('
      'roleIds: ${roleIds.length})';
}
