import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative user group page.
@immutable
class AdminUserGroupPage {
  /// Creates a [AdminUserGroupPage].
  const AdminUserGroupPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// User groups on this page.
  final List<AdminUserGroup> items;

  /// Page number returned.
  final int page;

  /// Maximum number of results per page.
  final int pageSize;

  /// Total number of user groups that match the request.
  final int total;

  /// Parses a [AdminUserGroupPage] from JSON.
  factory AdminUserGroupPage.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException('AdminUserGroupPage: missing items');
    }
    if (json['page'] == null) {
      throw const FormatException('AdminUserGroupPage: missing page');
    }
    if (json['page_size'] == null) {
      throw const FormatException('AdminUserGroupPage: missing page_size');
    }
    if (json['total'] == null) {
      throw const FormatException('AdminUserGroupPage: missing total');
    }
    return AdminUserGroupPage(
      items: (json['items'] as List)
          .map((item) => AdminUserGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'page': page,
    'page_size': pageSize,
    'total': total,
  };

  /// Creates a copy with the given fields replaced.
  AdminUserGroupPage copyWith({
    List<AdminUserGroup>? items,
    int? page,
    int? pageSize,
    int? total,
  }) => AdminUserGroupPage(
    items: items ?? this.items,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserGroupPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(items, other.items) &&
          page == other.page &&
          pageSize == other.pageSize &&
          total == other.total;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(items), page, pageSize, total]);

  @override
  String toString() =>
      'AdminUserGroupPage('
      'items: ${items.length}, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative create admin user group request.
@immutable
class CreateAdminUserGroupRequest {
  /// Creates a [CreateAdminUserGroupRequest].
  const CreateAdminUserGroupRequest({this.description, required this.name});

  /// Optional description of the user group.
  final String? description;

  /// Name of the user group.
  final String name;

  /// Parses a [CreateAdminUserGroupRequest] from JSON.
  factory CreateAdminUserGroupRequest.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('CreateAdminUserGroupRequest: missing name');
    }
    return CreateAdminUserGroupRequest(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'description': ?description, 'name': name};

  /// Creates a copy with the given fields replaced.
  CreateAdminUserGroupRequest copyWith({
    Object? description = unsetCopyWithValue,
    String? name,
  }) => CreateAdminUserGroupRequest(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAdminUserGroupRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([description, name]);

  @override
  String toString() =>
      'CreateAdminUserGroupRequest('
      'description: $description, '
      'name: $name)';
}

/// Administrative user group.
@immutable
class AdminUserGroup {
  /// Creates a [AdminUserGroup].
  const AdminUserGroup({
    required this.description,
    this.externallyManaged,
    required this.name,
    this.organizationRole,
    required this.uuid,
  });

  /// Optional description of the user group.
  final String? description;

  /// Whether the group is managed by an external system.
  final bool? externallyManaged;

  /// Name of the user group.
  final String name;

  /// Organization role assigned to the group.
  final String? organizationRole;

  /// User group ID.
  final String uuid;

  /// Parses a [AdminUserGroup] from JSON.
  factory AdminUserGroup.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('description')) {
      throw const FormatException('AdminUserGroup: missing description');
    }
    if (json['name'] == null) {
      throw const FormatException('AdminUserGroup: missing name');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminUserGroup: missing uuid');
    }
    return AdminUserGroup(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      externallyManaged: json['externally_managed'] == null
          ? null
          : json['externally_managed'] as bool,
      name: json['name'] as String,
      organizationRole: json['organization_role'] == null
          ? null
          : json['organization_role'] as String,
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': description,
    'externally_managed': ?externallyManaged,
    'name': name,
    'organization_role': ?organizationRole,
    'uuid': uuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminUserGroup copyWith({
    Object? description = unsetCopyWithValue,
    Object? externallyManaged = unsetCopyWithValue,
    String? name,
    Object? organizationRole = unsetCopyWithValue,
    String? uuid,
  }) => AdminUserGroup(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    externallyManaged: externallyManaged == unsetCopyWithValue
        ? this.externallyManaged
        : externallyManaged as bool?,
    name: name ?? this.name,
    organizationRole: organizationRole == unsetCopyWithValue
        ? this.organizationRole
        : organizationRole as String?,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserGroup &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          externallyManaged == other.externallyManaged &&
          name == other.name &&
          organizationRole == other.organizationRole &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([
    description,
    externallyManaged,
    name,
    organizationRole,
    uuid,
  ]);

  @override
  String toString() =>
      'AdminUserGroup('
      'description: $description, '
      'externallyManaged: $externallyManaged, '
      'name: $name, '
      'organizationRole: $organizationRole, '
      'uuid: $uuid)';
}

/// Administrative update admin user group request.
@immutable
class UpdateAdminUserGroupRequest {
  /// Creates a [UpdateAdminUserGroupRequest].
  const UpdateAdminUserGroupRequest({this.description, this.name});

  /// Updated description of the user group. Pass an empty string to clear it; omit the field or pass null to leave it unchanged.
  final String? description;

  /// Updated name of the user group.
  final String? name;

  /// Parses a [UpdateAdminUserGroupRequest] from JSON.
  factory UpdateAdminUserGroupRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAdminUserGroupRequest(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] == null ? null : json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'description': ?description, 'name': ?name};

  /// Creates a copy with the given fields replaced.
  UpdateAdminUserGroupRequest copyWith({
    Object? description = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
  }) => UpdateAdminUserGroupRequest(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminUserGroupRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([description, name]);

  @override
  String toString() =>
      'UpdateAdminUserGroupRequest('
      'description: $description, '
      'name: $name)';
}

/// Administrative group users request.
@immutable
class AdminGroupUsersRequest {
  /// Creates a [AdminGroupUsersRequest].
  const AdminGroupUsersRequest({required this.userUuids});

  /// User IDs to add to the group.
  final List<String> userUuids;

  /// Parses a [AdminGroupUsersRequest] from JSON.
  factory AdminGroupUsersRequest.fromJson(Map<String, dynamic> json) {
    if (json['user_uuids'] == null) {
      throw const FormatException('AdminGroupUsersRequest: missing user_uuids');
    }
    return AdminGroupUsersRequest(
      userUuids: (json['user_uuids'] as List)
          .map((item) => item as String)
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'user_uuids': userUuids};

  /// Creates a copy with the given fields replaced.
  AdminGroupUsersRequest copyWith({List<String>? userUuids}) =>
      AdminGroupUsersRequest(userUuids: userUuids ?? this.userUuids);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminGroupUsersRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(userUuids, other.userUuids);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(userUuids)]);

  @override
  String toString() =>
      'AdminGroupUsersRequest('
      'userUuids: ${userUuids.length})';
}

/// Administrative user group members page.
@immutable
class AdminUserGroupMembersPage {
  /// Creates a [AdminUserGroupMembersPage].
  const AdminUserGroupMembersPage({
    required this.members,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Group members on this page.
  final List<AdminUserGroupMember> members;

  /// Page number returned.
  final int page;

  /// Maximum number of results per page.
  final int pageSize;

  /// Total number of group members that match the request.
  final int total;

  /// Parses a [AdminUserGroupMembersPage] from JSON.
  factory AdminUserGroupMembersPage.fromJson(Map<String, dynamic> json) {
    if (json['members'] == null) {
      throw const FormatException('AdminUserGroupMembersPage: missing members');
    }
    if (json['page'] == null) {
      throw const FormatException('AdminUserGroupMembersPage: missing page');
    }
    if (json['page_size'] == null) {
      throw const FormatException(
        'AdminUserGroupMembersPage: missing page_size',
      );
    }
    if (json['total'] == null) {
      throw const FormatException('AdminUserGroupMembersPage: missing total');
    }
    return AdminUserGroupMembersPage(
      members: (json['members'] as List)
          .map(
            (item) =>
                AdminUserGroupMember.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'members': members.map((item) => item.toJson()).toList(),
    'page': page,
    'page_size': pageSize,
    'total': total,
  };

  /// Creates a copy with the given fields replaced.
  AdminUserGroupMembersPage copyWith({
    List<AdminUserGroupMember>? members,
    int? page,
    int? pageSize,
    int? total,
  }) => AdminUserGroupMembersPage(
    members: members ?? this.members,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserGroupMembersPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(members, other.members) &&
          page == other.page &&
          pageSize == other.pageSize &&
          total == other.total;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(members), page, pageSize, total]);

  @override
  String toString() =>
      'AdminUserGroupMembersPage('
      'members: ${members.length}, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative set admin group organization role request.
@immutable
class SetAdminGroupOrganizationRoleRequest {
  /// Creates a [SetAdminGroupOrganizationRoleRequest].
  const SetAdminGroupOrganizationRoleRequest({required this.organizationRole});

  /// Organization role to assign to the group: a role name (`member`, `billing_manager`, `organization_admin`) or a role UUID.
  final String organizationRole;

  /// Parses a [SetAdminGroupOrganizationRoleRequest] from JSON.
  factory SetAdminGroupOrganizationRoleRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['organization_role'] == null) {
      throw const FormatException(
        'SetAdminGroupOrganizationRoleRequest: missing organization_role',
      );
    }
    return SetAdminGroupOrganizationRoleRequest(
      organizationRole: json['organization_role'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'organization_role': organizationRole};

  /// Creates a copy with the given fields replaced.
  SetAdminGroupOrganizationRoleRequest copyWith({String? organizationRole}) =>
      SetAdminGroupOrganizationRoleRequest(
        organizationRole: organizationRole ?? this.organizationRole,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetAdminGroupOrganizationRoleRequest &&
          runtimeType == other.runtimeType &&
          organizationRole == other.organizationRole;

  @override
  int get hashCode => Object.hashAll([organizationRole]);

  @override
  String toString() =>
      'SetAdminGroupOrganizationRoleRequest('
      'organizationRole: $organizationRole)';
}

/// Administrative group workspace assignment page.
@immutable
class AdminGroupWorkspaceAssignmentPage {
  /// Creates a [AdminGroupWorkspaceAssignmentPage].
  const AdminGroupWorkspaceAssignmentPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Workspace assignments on this page.
  final List<AdminGroupWorkspaceAssignment> items;

  /// Page number returned.
  final int page;

  /// Maximum number of results per page.
  final int pageSize;

  /// Total number of Workspace assignments that match the request.
  final int total;

  /// Parses a [AdminGroupWorkspaceAssignmentPage] from JSON.
  factory AdminGroupWorkspaceAssignmentPage.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['items'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignmentPage: missing items',
      );
    }
    if (json['page'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignmentPage: missing page',
      );
    }
    if (json['page_size'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignmentPage: missing page_size',
      );
    }
    if (json['total'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignmentPage: missing total',
      );
    }
    return AdminGroupWorkspaceAssignmentPage(
      items: (json['items'] as List)
          .map(
            (item) => AdminGroupWorkspaceAssignment.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'page': page,
    'page_size': pageSize,
    'total': total,
  };

  /// Creates a copy with the given fields replaced.
  AdminGroupWorkspaceAssignmentPage copyWith({
    List<AdminGroupWorkspaceAssignment>? items,
    int? page,
    int? pageSize,
    int? total,
  }) => AdminGroupWorkspaceAssignmentPage(
    items: items ?? this.items,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminGroupWorkspaceAssignmentPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(items, other.items) &&
          page == other.page &&
          pageSize == other.pageSize &&
          total == other.total;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(items), page, pageSize, total]);

  @override
  String toString() =>
      'AdminGroupWorkspaceAssignmentPage('
      'items: ${items.length}, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative assign admin group workspace request.
@immutable
class AssignAdminGroupWorkspaceRequest {
  /// Creates a [AssignAdminGroupWorkspaceRequest].
  const AssignAdminGroupWorkspaceRequest({
    this.role,
    this.roleNames,
    this.roles,
    required this.workspaceUuid,
  });

  /// Deprecated single role value. Use 'role_names' instead.
  final String? role;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final List<String>? roles;

  /// The workspace_uuid field.
  final String workspaceUuid;

  /// Parses a [AssignAdminGroupWorkspaceRequest] from JSON.
  factory AssignAdminGroupWorkspaceRequest.fromJson(Map<String, dynamic> json) {
    if (json['workspace_uuid'] == null) {
      throw const FormatException(
        'AssignAdminGroupWorkspaceRequest: missing workspace_uuid',
      );
    }
    return AssignAdminGroupWorkspaceRequest(
      role: json['role'] == null ? null : json['role'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'] == null
          ? null
          : (json['roles'] as List).map((item) => item as String).toList(),
      workspaceUuid: json['workspace_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'role': ?role,
    'role_names': ?roleNames,
    'roles': ?roles,
    'workspace_uuid': workspaceUuid,
  };

  /// Creates a copy with the given fields replaced.
  AssignAdminGroupWorkspaceRequest copyWith({
    Object? role = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
    String? workspaceUuid,
  }) => AssignAdminGroupWorkspaceRequest(
    role: role == unsetCopyWithValue ? this.role : role as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue
        ? this.roles
        : (roles as List?)?.cast<String>(),
    workspaceUuid: workspaceUuid ?? this.workspaceUuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignAdminGroupWorkspaceRequest &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles) &&
          workspaceUuid == other.workspaceUuid;

  @override
  int get hashCode => Object.hashAll([
    role,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
    workspaceUuid,
  ]);

  @override
  String toString() =>
      'AssignAdminGroupWorkspaceRequest('
      'role: $role, '
      'roleNames: ${roleNames?.length}, '
      'roles: ${roles?.length}, '
      'workspaceUuid: $workspaceUuid)';
}

/// Either set the group's roles on the Workspace, or add and remove some of them.
@immutable
class UpdateAdminGroupWorkspaceRequest {
  /// Creates a [UpdateAdminGroupWorkspaceRequest].
  const UpdateAdminGroupWorkspaceRequest({
    this.addRoleNames,
    this.addRoles,
    this.removeRoleNames,
    this.removeRoles,
    this.role,
    this.roleNames,
    this.roles,
  });

  /// Simplified role names to add to the existing roles. Mutually exclusive with 'add_roles'.
  final List<String>? addRoleNames;

  /// Role values to add to the existing roles. Mutually exclusive with 'add_role_names'.
  final List<String>? addRoles;

  /// Simplified role names to remove from the existing roles. Mutually exclusive with 'remove_roles'.
  final List<String>? removeRoleNames;

  /// Role values to remove from the existing roles. Mutually exclusive with 'remove_role_names'.
  final List<String>? removeRoles;

  /// Deprecated single role value. Use 'role_names' instead.
  final String? role;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final List<String>? roles;

  /// Parses a [UpdateAdminGroupWorkspaceRequest] from JSON.
  factory UpdateAdminGroupWorkspaceRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAdminGroupWorkspaceRequest(
      addRoleNames: json['add_role_names'] == null
          ? null
          : (json['add_role_names'] as List)
                .map((item) => item as String)
                .toList(),
      addRoles: json['add_roles'] == null
          ? null
          : (json['add_roles'] as List).map((item) => item as String).toList(),
      removeRoleNames: json['remove_role_names'] == null
          ? null
          : (json['remove_role_names'] as List)
                .map((item) => item as String)
                .toList(),
      removeRoles: json['remove_roles'] == null
          ? null
          : (json['remove_roles'] as List)
                .map((item) => item as String)
                .toList(),
      role: json['role'] == null ? null : json['role'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'] == null
          ? null
          : (json['roles'] as List).map((item) => item as String).toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'add_role_names': ?addRoleNames,
    'add_roles': ?addRoles,
    'remove_role_names': ?removeRoleNames,
    'remove_roles': ?removeRoles,
    'role': ?role,
    'role_names': ?roleNames,
    'roles': ?roles,
  };

  /// Creates a copy with the given fields replaced.
  UpdateAdminGroupWorkspaceRequest copyWith({
    Object? addRoleNames = unsetCopyWithValue,
    Object? addRoles = unsetCopyWithValue,
    Object? removeRoleNames = unsetCopyWithValue,
    Object? removeRoles = unsetCopyWithValue,
    Object? role = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
  }) => UpdateAdminGroupWorkspaceRequest(
    addRoleNames: addRoleNames == unsetCopyWithValue
        ? this.addRoleNames
        : (addRoleNames as List?)?.cast<String>(),
    addRoles: addRoles == unsetCopyWithValue
        ? this.addRoles
        : (addRoles as List?)?.cast<String>(),
    removeRoleNames: removeRoleNames == unsetCopyWithValue
        ? this.removeRoleNames
        : (removeRoleNames as List?)?.cast<String>(),
    removeRoles: removeRoles == unsetCopyWithValue
        ? this.removeRoles
        : (removeRoles as List?)?.cast<String>(),
    role: role == unsetCopyWithValue ? this.role : role as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue
        ? this.roles
        : (roles as List?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminGroupWorkspaceRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(addRoleNames, other.addRoleNames) &&
          valuesDeepEqual(addRoles, other.addRoles) &&
          valuesDeepEqual(removeRoleNames, other.removeRoleNames) &&
          valuesDeepEqual(removeRoles, other.removeRoles) &&
          role == other.role &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(addRoleNames),
    valueDeepHashCode(addRoles),
    valueDeepHashCode(removeRoleNames),
    valueDeepHashCode(removeRoles),
    role,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
  ]);

  @override
  String toString() =>
      'UpdateAdminGroupWorkspaceRequest('
      'addRoleNames: ${addRoleNames?.length}, '
      'addRoles: ${addRoles?.length}, '
      'removeRoleNames: ${removeRoleNames?.length}, '
      'removeRoles: ${removeRoles?.length}, '
      'role: $role, '
      'roleNames: ${roleNames?.length}, '
      'roles: ${roles?.length})';
}

/// Administrative user group member.
@immutable
class AdminUserGroupMember {
  /// Creates a [AdminUserGroupMember].
  const AdminUserGroupMember({
    required this.email,
    required this.name,
    required this.userUuid,
  });

  /// Email address of the group member.
  final String? email;

  /// Name of the group member.
  final String? name;

  /// User ID of the group member.
  final String userUuid;

  /// Parses a [AdminUserGroupMember] from JSON.
  factory AdminUserGroupMember.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('email')) {
      throw const FormatException('AdminUserGroupMember: missing email');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('AdminUserGroupMember: missing name');
    }
    if (json['user_uuid'] == null) {
      throw const FormatException('AdminUserGroupMember: missing user_uuid');
    }
    return AdminUserGroupMember(
      email: json['email'] == null ? null : json['email'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      userUuid: json['user_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'user_uuid': userUuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminUserGroupMember copyWith({
    Object? email = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    String? userUuid,
  }) => AdminUserGroupMember(
    email: email == unsetCopyWithValue ? this.email : email as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    userUuid: userUuid ?? this.userUuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserGroupMember &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          name == other.name &&
          userUuid == other.userUuid;

  @override
  int get hashCode => Object.hashAll([email, name, userUuid]);

  @override
  String toString() =>
      'AdminUserGroupMember('
      'email: $email, '
      'name: $name, '
      'userUuid: $userUuid)';
}

/// Administrative group workspace assignment.
@immutable
class AdminGroupWorkspaceAssignment {
  /// Creates a [AdminGroupWorkspaceAssignment].
  const AdminGroupWorkspaceAssignment({
    required this.created,
    this.roleName,
    this.roleUuid,
    required this.roles,
    required this.workspaceName,
    required this.workspaceUuid,
  });

  /// The created field.
  final String created;

  /// Deprecated: Workspace assignments now support multiple roles. This field only contains the name of the first entry in `roles`; use `roles` instead.
  final String? roleName;

  /// Deprecated: Workspace assignments now support multiple roles. This field only contains the UUID of the first entry in `roles`; use `roles` instead.
  final String? roleUuid;

  /// The roles field.
  final List<AdminWorkspaceRoleReference> roles;

  /// Name of the Workspace.
  final String workspaceName;

  /// The workspace_uuid field.
  final String workspaceUuid;

  /// Parses a [AdminGroupWorkspaceAssignment] from JSON.
  factory AdminGroupWorkspaceAssignment.fromJson(Map<String, dynamic> json) {
    if (json['created'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignment: missing created',
      );
    }
    if (json['roles'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignment: missing roles',
      );
    }
    if (json['workspace_name'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignment: missing workspace_name',
      );
    }
    if (json['workspace_uuid'] == null) {
      throw const FormatException(
        'AdminGroupWorkspaceAssignment: missing workspace_uuid',
      );
    }
    return AdminGroupWorkspaceAssignment(
      created: json['created'] as String,
      roleName: json['role_name'] == null ? null : json['role_name'] as String,
      roleUuid: json['role_uuid'] == null ? null : json['role_uuid'] as String,
      roles: (json['roles'] as List)
          .map(
            (item) => AdminWorkspaceRoleReference.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      workspaceName: json['workspace_name'] as String,
      workspaceUuid: json['workspace_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created': created,
    'role_name': ?roleName,
    'role_uuid': ?roleUuid,
    'roles': roles.map((item) => item.toJson()).toList(),
    'workspace_name': workspaceName,
    'workspace_uuid': workspaceUuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminGroupWorkspaceAssignment copyWith({
    String? created,
    Object? roleName = unsetCopyWithValue,
    Object? roleUuid = unsetCopyWithValue,
    List<AdminWorkspaceRoleReference>? roles,
    String? workspaceName,
    String? workspaceUuid,
  }) => AdminGroupWorkspaceAssignment(
    created: created ?? this.created,
    roleName: roleName == unsetCopyWithValue
        ? this.roleName
        : roleName as String?,
    roleUuid: roleUuid == unsetCopyWithValue
        ? this.roleUuid
        : roleUuid as String?,
    roles: roles ?? this.roles,
    workspaceName: workspaceName ?? this.workspaceName,
    workspaceUuid: workspaceUuid ?? this.workspaceUuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminGroupWorkspaceAssignment &&
          runtimeType == other.runtimeType &&
          created == other.created &&
          roleName == other.roleName &&
          roleUuid == other.roleUuid &&
          valuesDeepEqual(roles, other.roles) &&
          workspaceName == other.workspaceName &&
          workspaceUuid == other.workspaceUuid;

  @override
  int get hashCode => Object.hashAll([
    created,
    roleName,
    roleUuid,
    valueDeepHashCode(roles),
    workspaceName,
    workspaceUuid,
  ]);

  @override
  String toString() =>
      'AdminGroupWorkspaceAssignment('
      'created: $created, '
      'roleName: $roleName, '
      'roleUuid: $roleUuid, '
      'roles: ${roles.length}, '
      'workspaceName: $workspaceName, '
      'workspaceUuid: $workspaceUuid)';
}

/// Administrative workspace role reference.
@immutable
class AdminWorkspaceRoleReference {
  /// Creates a [AdminWorkspaceRoleReference].
  const AdminWorkspaceRoleReference({required this.name, required this.uuid});

  /// The name field.
  final String name;

  /// The uuid field.
  final String uuid;

  /// Parses a [AdminWorkspaceRoleReference] from JSON.
  factory AdminWorkspaceRoleReference.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('AdminWorkspaceRoleReference: missing name');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminWorkspaceRoleReference: missing uuid');
    }
    return AdminWorkspaceRoleReference(
      name: json['name'] as String,
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'name': name, 'uuid': uuid};

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceRoleReference copyWith({String? name, String? uuid}) =>
      AdminWorkspaceRoleReference(
        name: name ?? this.name,
        uuid: uuid ?? this.uuid,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceRoleReference &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([name, uuid]);

  @override
  String toString() =>
      'AdminWorkspaceRoleReference('
      'name: $name, '
      'uuid: $uuid)';
}
