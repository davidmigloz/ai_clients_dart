import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'admin_users.dart';

/// Administrative workspaces page.
@immutable
class AdminWorkspacesPage {
  /// Creates a [AdminWorkspacesPage].
  const AdminWorkspacesPage({
    required this.items,
    this.object,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Workspaces on this page.
  final List<AdminWorkspace> items;

  /// Type of paginated API object.
  final Object? object;

  /// Page number returned.
  final int page;

  /// Maximum number of results per page.
  final int pageSize;

  /// Total number of Workspaces that match the request.
  final int total;

  /// Parses a [AdminWorkspacesPage] from JSON.
  factory AdminWorkspacesPage.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException('AdminWorkspacesPage: missing items');
    }
    if (json['page'] == null) {
      throw const FormatException('AdminWorkspacesPage: missing page');
    }
    if (json['page_size'] == null) {
      throw const FormatException('AdminWorkspacesPage: missing page_size');
    }
    if (json['total'] == null) {
      throw const FormatException('AdminWorkspacesPage: missing total');
    }
    return AdminWorkspacesPage(
      items: (json['items'] as List)
          .map((item) => AdminWorkspace.fromJson(item as Map<String, dynamic>))
          .toList(),
      object: json['object'],
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'object': ?object,
    'page': page,
    'page_size': pageSize,
    'total': total,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspacesPage copyWith({
    List<AdminWorkspace>? items,
    Object? object = unsetCopyWithValue,
    int? page,
    int? pageSize,
    int? total,
  }) => AdminWorkspacesPage(
    items: items ?? this.items,
    object: object == unsetCopyWithValue ? this.object : object,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspacesPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(items, other.items) &&
          valuesDeepEqual(object, other.object) &&
          page == other.page &&
          pageSize == other.pageSize &&
          total == other.total;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(items),
    valueDeepHashCode(object),
    page,
    pageSize,
    total,
  ]);

  @override
  String toString() =>
      'AdminWorkspacesPage('
      'items: ${items.length}, '
      'object: $object, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative create admin workspace request.
@immutable
class CreateAdminWorkspaceRequest {
  /// Creates a [CreateAdminWorkspaceRequest].
  const CreateAdminWorkspaceRequest({
    this.addAllOrgMembers,
    required this.adminUserId,
    this.description,
    this.icon,
    required this.name,
  });

  /// Whether to add all Organization members to the Workspace.
  final bool? addAllOrgMembers;

  /// User ID to grant the Workspace Admin role to.
  final String adminUserId;

  /// Workspace description.
  final String? description;

  /// Workspace icon.
  final String? icon;

  /// Workspace name.
  final String name;

  /// Parses a [CreateAdminWorkspaceRequest] from JSON.
  factory CreateAdminWorkspaceRequest.fromJson(Map<String, dynamic> json) {
    if (json['admin_user_id'] == null) {
      throw const FormatException(
        'CreateAdminWorkspaceRequest: missing admin_user_id',
      );
    }
    if (json['name'] == null) {
      throw const FormatException('CreateAdminWorkspaceRequest: missing name');
    }
    return CreateAdminWorkspaceRequest(
      addAllOrgMembers: json['add_all_org_members'] == null
          ? null
          : json['add_all_org_members'] as bool,
      adminUserId: json['admin_user_id'] as String,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      icon: json['icon'] == null ? null : json['icon'] as String,
      name: json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'add_all_org_members': ?addAllOrgMembers,
    'admin_user_id': adminUserId,
    'description': ?description,
    'icon': ?icon,
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  CreateAdminWorkspaceRequest copyWith({
    Object? addAllOrgMembers = unsetCopyWithValue,
    String? adminUserId,
    Object? description = unsetCopyWithValue,
    Object? icon = unsetCopyWithValue,
    String? name,
  }) => CreateAdminWorkspaceRequest(
    addAllOrgMembers: addAllOrgMembers == unsetCopyWithValue
        ? this.addAllOrgMembers
        : addAllOrgMembers as bool?,
    adminUserId: adminUserId ?? this.adminUserId,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    icon: icon == unsetCopyWithValue ? this.icon : icon as String?,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAdminWorkspaceRequest &&
          runtimeType == other.runtimeType &&
          addAllOrgMembers == other.addAllOrgMembers &&
          adminUserId == other.adminUserId &&
          description == other.description &&
          icon == other.icon &&
          name == other.name;

  @override
  int get hashCode =>
      Object.hashAll([addAllOrgMembers, adminUserId, description, icon, name]);

  @override
  String toString() =>
      'CreateAdminWorkspaceRequest('
      'addAllOrgMembers: $addAllOrgMembers, '
      'adminUserId: $adminUserId, '
      'description: $description, '
      'icon: $icon, '
      'name: $name)';
}

/// Administrative created workspace.
@immutable
class AdminCreatedWorkspace {
  /// Creates a [AdminCreatedWorkspace].
  const AdminCreatedWorkspace({
    required this.description,
    this.groupsCount,
    required this.icon,
    required this.isDefault,
    this.membersCount,
    required this.name,
    required this.rawRole,
    required this.rawRoles,
    this.spendLimit,
    required this.uuid,
  });

  /// Workspace description.
  final String? description;

  /// Number of groups assigned to the Workspace.
  final int? groupsCount;

  /// Workspace icon.
  final String? icon;

  /// Whether this is the default Workspace for the Organization.
  final bool isDefault;

  /// Number of members in the Workspace.
  final int? membersCount;

  /// Workspace name.
  final String name;

  /// Deprecated single role for the Workspace. Use 'raw_roles' instead.
  final String rawRole;

  /// Roles granted for the Workspace.
  final List<String> rawRoles;

  /// Workspace spending limit.
  final AdminWorkspaceSpendLimit? spendLimit;

  /// Workspace ID.
  final String uuid;

  /// Parses a [AdminCreatedWorkspace] from JSON.
  factory AdminCreatedWorkspace.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('description')) {
      throw const FormatException('AdminCreatedWorkspace: missing description');
    }
    if (!json.containsKey('icon')) {
      throw const FormatException('AdminCreatedWorkspace: missing icon');
    }
    if (json['is_default'] == null) {
      throw const FormatException('AdminCreatedWorkspace: missing is_default');
    }
    if (json['name'] == null) {
      throw const FormatException('AdminCreatedWorkspace: missing name');
    }
    if (json['raw_role'] == null) {
      throw const FormatException('AdminCreatedWorkspace: missing raw_role');
    }
    if (json['raw_roles'] == null) {
      throw const FormatException('AdminCreatedWorkspace: missing raw_roles');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminCreatedWorkspace: missing uuid');
    }
    return AdminCreatedWorkspace(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      groupsCount: json['groups_count'] == null
          ? null
          : json['groups_count'] as int,
      icon: json['icon'] == null ? null : json['icon'] as String,
      isDefault: json['is_default'] as bool,
      membersCount: json['members_count'] == null
          ? null
          : json['members_count'] as int,
      name: json['name'] as String,
      rawRole: json['raw_role'] as String,
      rawRoles: (json['raw_roles'] as List)
          .map((item) => item as String)
          .toList(),
      spendLimit: json['spend_limit'] == null
          ? null
          : AdminWorkspaceSpendLimit.fromJson(
              json['spend_limit'] as Map<String, dynamic>,
            ),
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': description,
    'groups_count': ?groupsCount,
    'icon': icon,
    'is_default': isDefault,
    'members_count': ?membersCount,
    'name': name,
    'raw_role': rawRole,
    'raw_roles': rawRoles,
    if (spendLimit != null) 'spend_limit': spendLimit!.toJson(),
    'uuid': uuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminCreatedWorkspace copyWith({
    Object? description = unsetCopyWithValue,
    Object? groupsCount = unsetCopyWithValue,
    Object? icon = unsetCopyWithValue,
    bool? isDefault,
    Object? membersCount = unsetCopyWithValue,
    String? name,
    String? rawRole,
    List<String>? rawRoles,
    Object? spendLimit = unsetCopyWithValue,
    String? uuid,
  }) => AdminCreatedWorkspace(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    groupsCount: groupsCount == unsetCopyWithValue
        ? this.groupsCount
        : groupsCount as int?,
    icon: icon == unsetCopyWithValue ? this.icon : icon as String?,
    isDefault: isDefault ?? this.isDefault,
    membersCount: membersCount == unsetCopyWithValue
        ? this.membersCount
        : membersCount as int?,
    name: name ?? this.name,
    rawRole: rawRole ?? this.rawRole,
    rawRoles: rawRoles ?? this.rawRoles,
    spendLimit: spendLimit == unsetCopyWithValue
        ? this.spendLimit
        : spendLimit as AdminWorkspaceSpendLimit?,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminCreatedWorkspace &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          groupsCount == other.groupsCount &&
          icon == other.icon &&
          isDefault == other.isDefault &&
          membersCount == other.membersCount &&
          name == other.name &&
          rawRole == other.rawRole &&
          valuesDeepEqual(rawRoles, other.rawRoles) &&
          spendLimit == other.spendLimit &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([
    description,
    groupsCount,
    icon,
    isDefault,
    membersCount,
    name,
    rawRole,
    valueDeepHashCode(rawRoles),
    spendLimit,
    uuid,
  ]);

  @override
  String toString() =>
      'AdminCreatedWorkspace('
      'description: $description, '
      'groupsCount: $groupsCount, '
      'icon: $icon, '
      'isDefault: $isDefault, '
      'membersCount: $membersCount, '
      'name: $name, '
      'rawRole: $rawRole, '
      'rawRoles: ${rawRoles.length}, '
      'spendLimit: $spendLimit, '
      'uuid: $uuid)';
}

/// Administrative update admin workspace request.
@immutable
class UpdateAdminWorkspaceRequest {
  /// Creates a [UpdateAdminWorkspaceRequest].
  const UpdateAdminWorkspaceRequest({this.description, this.icon, this.name});

  /// Updated Workspace description.
  final String? description;

  /// Updated Workspace icon.
  final String? icon;

  /// Updated Workspace name.
  final String? name;

  /// Parses a [UpdateAdminWorkspaceRequest] from JSON.
  factory UpdateAdminWorkspaceRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAdminWorkspaceRequest(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      icon: json['icon'] == null ? null : json['icon'] as String,
      name: json['name'] == null ? null : json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': ?description,
    'icon': ?icon,
    'name': ?name,
  };

  /// Creates a copy with the given fields replaced.
  UpdateAdminWorkspaceRequest copyWith({
    Object? description = unsetCopyWithValue,
    Object? icon = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
  }) => UpdateAdminWorkspaceRequest(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    icon: icon == unsetCopyWithValue ? this.icon : icon as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminWorkspaceRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          icon == other.icon &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([description, icon, name]);

  @override
  String toString() =>
      'UpdateAdminWorkspaceRequest('
      'description: $description, '
      'icon: $icon, '
      'name: $name)';
}

/// Administrative workspace.
@immutable
class AdminWorkspace {
  /// Creates a [AdminWorkspace].
  const AdminWorkspace({
    required this.description,
    this.groupsCount,
    required this.icon,
    required this.isDefault,
    this.membersCount,
    required this.name,
    this.spendLimit,
    required this.uuid,
  });

  /// Workspace description.
  final String? description;

  /// Number of groups assigned to the Workspace.
  final int? groupsCount;

  /// Workspace icon.
  final String? icon;

  /// Whether this is the default Workspace for the Organization.
  final bool isDefault;

  /// Number of members in the Workspace.
  final int? membersCount;

  /// Workspace name.
  final String name;

  /// Workspace spending limit.
  final AdminWorkspaceSpendLimit? spendLimit;

  /// Workspace ID.
  final String uuid;

  /// Parses a [AdminWorkspace] from JSON.
  factory AdminWorkspace.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('description')) {
      throw const FormatException('AdminWorkspace: missing description');
    }
    if (!json.containsKey('icon')) {
      throw const FormatException('AdminWorkspace: missing icon');
    }
    if (json['is_default'] == null) {
      throw const FormatException('AdminWorkspace: missing is_default');
    }
    if (json['name'] == null) {
      throw const FormatException('AdminWorkspace: missing name');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminWorkspace: missing uuid');
    }
    return AdminWorkspace(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      groupsCount: json['groups_count'] == null
          ? null
          : json['groups_count'] as int,
      icon: json['icon'] == null ? null : json['icon'] as String,
      isDefault: json['is_default'] as bool,
      membersCount: json['members_count'] == null
          ? null
          : json['members_count'] as int,
      name: json['name'] as String,
      spendLimit: json['spend_limit'] == null
          ? null
          : AdminWorkspaceSpendLimit.fromJson(
              json['spend_limit'] as Map<String, dynamic>,
            ),
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': description,
    'groups_count': ?groupsCount,
    'icon': icon,
    'is_default': isDefault,
    'members_count': ?membersCount,
    'name': name,
    if (spendLimit != null) 'spend_limit': spendLimit!.toJson(),
    'uuid': uuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspace copyWith({
    Object? description = unsetCopyWithValue,
    Object? groupsCount = unsetCopyWithValue,
    Object? icon = unsetCopyWithValue,
    bool? isDefault,
    Object? membersCount = unsetCopyWithValue,
    String? name,
    Object? spendLimit = unsetCopyWithValue,
    String? uuid,
  }) => AdminWorkspace(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    groupsCount: groupsCount == unsetCopyWithValue
        ? this.groupsCount
        : groupsCount as int?,
    icon: icon == unsetCopyWithValue ? this.icon : icon as String?,
    isDefault: isDefault ?? this.isDefault,
    membersCount: membersCount == unsetCopyWithValue
        ? this.membersCount
        : membersCount as int?,
    name: name ?? this.name,
    spendLimit: spendLimit == unsetCopyWithValue
        ? this.spendLimit
        : spendLimit as AdminWorkspaceSpendLimit?,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspace &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          groupsCount == other.groupsCount &&
          icon == other.icon &&
          isDefault == other.isDefault &&
          membersCount == other.membersCount &&
          name == other.name &&
          spendLimit == other.spendLimit &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([
    description,
    groupsCount,
    icon,
    isDefault,
    membersCount,
    name,
    spendLimit,
    uuid,
  ]);

  @override
  String toString() =>
      'AdminWorkspace('
      'description: $description, '
      'groupsCount: $groupsCount, '
      'icon: $icon, '
      'isDefault: $isDefault, '
      'membersCount: $membersCount, '
      'name: $name, '
      'spendLimit: $spendLimit, '
      'uuid: $uuid)';
}

/// Administrative add admin workspace users request.
@immutable
class AddAdminWorkspaceUsersRequest {
  /// Creates a [AddAdminWorkspaceUsersRequest].
  const AddAdminWorkspaceUsersRequest({this.members});

  /// Workspace members to add or update.
  final List<AdminWorkspaceUserAddition>? members;

  /// Parses a [AddAdminWorkspaceUsersRequest] from JSON.
  factory AddAdminWorkspaceUsersRequest.fromJson(Map<String, dynamic> json) {
    return AddAdminWorkspaceUsersRequest(
      members: json['members'] == null
          ? null
          : (json['members'] as List)
                .map(
                  (item) => AdminWorkspaceUserAddition.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (members != null)
      'members': members!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AddAdminWorkspaceUsersRequest copyWith({
    Object? members = unsetCopyWithValue,
  }) => AddAdminWorkspaceUsersRequest(
    members: members == unsetCopyWithValue
        ? this.members
        : (members as List?)?.cast<AdminWorkspaceUserAddition>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddAdminWorkspaceUsersRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(members, other.members);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(members)]);

  @override
  String toString() =>
      'AddAdminWorkspaceUsersRequest('
      'members: ${members?.length})';
}

/// Administrative add admin workspace users result.
@immutable
class AddAdminWorkspaceUsersResult {
  /// Creates a [AddAdminWorkspaceUsersResult].
  const AddAdminWorkspaceUsersResult({required this.addedMembersCount});

  /// Number of users added to the Workspace.
  final int addedMembersCount;

  /// Parses a [AddAdminWorkspaceUsersResult] from JSON.
  factory AddAdminWorkspaceUsersResult.fromJson(Map<String, dynamic> json) {
    if (json['added_members_count'] == null) {
      throw const FormatException(
        'AddAdminWorkspaceUsersResult: missing added_members_count',
      );
    }
    return AddAdminWorkspaceUsersResult(
      addedMembersCount: json['added_members_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'added_members_count': addedMembersCount};

  /// Creates a copy with the given fields replaced.
  AddAdminWorkspaceUsersResult copyWith({int? addedMembersCount}) =>
      AddAdminWorkspaceUsersResult(
        addedMembersCount: addedMembersCount ?? this.addedMembersCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddAdminWorkspaceUsersResult &&
          runtimeType == other.runtimeType &&
          addedMembersCount == other.addedMembersCount;

  @override
  int get hashCode => Object.hashAll([addedMembersCount]);

  @override
  String toString() =>
      'AddAdminWorkspaceUsersResult('
      'addedMembersCount: $addedMembersCount)';
}

/// Administrative remove admin workspace users request.
@immutable
class RemoveAdminWorkspaceUsersRequest {
  /// Creates a [RemoveAdminWorkspaceUsersRequest].
  const RemoveAdminWorkspaceUsersRequest({required this.members});

  /// Workspace members to remove.
  final List<AdminWorkspaceUserReference> members;

  /// Parses a [RemoveAdminWorkspaceUsersRequest] from JSON.
  factory RemoveAdminWorkspaceUsersRequest.fromJson(Map<String, dynamic> json) {
    if (json['members'] == null) {
      throw const FormatException(
        'RemoveAdminWorkspaceUsersRequest: missing members',
      );
    }
    return RemoveAdminWorkspaceUsersRequest(
      members: (json['members'] as List)
          .map(
            (item) => AdminWorkspaceUserReference.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'members': members.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  RemoveAdminWorkspaceUsersRequest copyWith({
    List<AdminWorkspaceUserReference>? members,
  }) => RemoveAdminWorkspaceUsersRequest(members: members ?? this.members);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoveAdminWorkspaceUsersRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(members, other.members);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(members)]);

  @override
  String toString() =>
      'RemoveAdminWorkspaceUsersRequest('
      'members: ${members.length})';
}

/// Administrative remove admin workspace users result.
@immutable
class RemoveAdminWorkspaceUsersResult {
  /// Creates a [RemoveAdminWorkspaceUsersResult].
  const RemoveAdminWorkspaceUsersResult({
    required this.deletedMembersCount,
    this.notDeletedMembers,
  });

  /// Number of Workspace members removed.
  final int deletedMembersCount;

  /// Users that could not be removed.
  final List<String>? notDeletedMembers;

  /// Parses a [RemoveAdminWorkspaceUsersResult] from JSON.
  factory RemoveAdminWorkspaceUsersResult.fromJson(Map<String, dynamic> json) {
    if (json['deleted_members_count'] == null) {
      throw const FormatException(
        'RemoveAdminWorkspaceUsersResult: missing deleted_members_count',
      );
    }
    return RemoveAdminWorkspaceUsersResult(
      deletedMembersCount: json['deleted_members_count'] as int,
      notDeletedMembers: json['not_deleted_members'] == null
          ? null
          : (json['not_deleted_members'] as List)
                .map((item) => item as String)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'deleted_members_count': deletedMembersCount,
    'not_deleted_members': ?notDeletedMembers,
  };

  /// Creates a copy with the given fields replaced.
  RemoveAdminWorkspaceUsersResult copyWith({
    int? deletedMembersCount,
    Object? notDeletedMembers = unsetCopyWithValue,
  }) => RemoveAdminWorkspaceUsersResult(
    deletedMembersCount: deletedMembersCount ?? this.deletedMembersCount,
    notDeletedMembers: notDeletedMembers == unsetCopyWithValue
        ? this.notDeletedMembers
        : (notDeletedMembers as List?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoveAdminWorkspaceUsersResult &&
          runtimeType == other.runtimeType &&
          deletedMembersCount == other.deletedMembersCount &&
          valuesDeepEqual(notDeletedMembers, other.notDeletedMembers);

  @override
  int get hashCode => Object.hashAll([
    deletedMembersCount,
    valueDeepHashCode(notDeletedMembers),
  ]);

  @override
  String toString() =>
      'RemoveAdminWorkspaceUsersResult('
      'deletedMembersCount: $deletedMembersCount, '
      'notDeletedMembers: ${notDeletedMembers?.length})';
}

/// Administrative workspace users page.
@immutable
class AdminWorkspaceUsersPage {
  /// Creates a [AdminWorkspaceUsersPage].
  const AdminWorkspaceUsersPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Members of the Workspace on this page, direct or through a group.
  final List<AdminWorkspaceMember> items;

  /// Page number returned.
  final int page;

  /// Maximum number of results per page.
  final int pageSize;

  /// Total number of members of the Workspace.
  final int total;

  /// Parses a [AdminWorkspaceUsersPage] from JSON.
  factory AdminWorkspaceUsersPage.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException('AdminWorkspaceUsersPage: missing items');
    }
    if (json['page'] == null) {
      throw const FormatException('AdminWorkspaceUsersPage: missing page');
    }
    if (json['page_size'] == null) {
      throw const FormatException('AdminWorkspaceUsersPage: missing page_size');
    }
    if (json['total'] == null) {
      throw const FormatException('AdminWorkspaceUsersPage: missing total');
    }
    return AdminWorkspaceUsersPage(
      items: (json['items'] as List)
          .map(
            (item) =>
                AdminWorkspaceMember.fromJson(item as Map<String, dynamic>),
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
  AdminWorkspaceUsersPage copyWith({
    List<AdminWorkspaceMember>? items,
    int? page,
    int? pageSize,
    int? total,
  }) => AdminWorkspaceUsersPage(
    items: items ?? this.items,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceUsersPage &&
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
      'AdminWorkspaceUsersPage('
      'items: ${items.length}, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative upsert admin workspace users request.
@immutable
class UpsertAdminWorkspaceUsersRequest {
  /// Creates a [UpsertAdminWorkspaceUsersRequest].
  const UpsertAdminWorkspaceUsersRequest({this.members});

  /// Workspace members to add or update. 'roles' or 'role_names' replace the member's roles; 'add_*' and 'remove_*' change them without touching the others.
  final List<AdminWorkspaceUserUpsert>? members;

  /// Parses a [UpsertAdminWorkspaceUsersRequest] from JSON.
  factory UpsertAdminWorkspaceUsersRequest.fromJson(Map<String, dynamic> json) {
    return UpsertAdminWorkspaceUsersRequest(
      members: json['members'] == null
          ? null
          : (json['members'] as List)
                .map(
                  (item) => AdminWorkspaceUserUpsert.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (members != null)
      'members': members!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  UpsertAdminWorkspaceUsersRequest copyWith({
    Object? members = unsetCopyWithValue,
  }) => UpsertAdminWorkspaceUsersRequest(
    members: members == unsetCopyWithValue
        ? this.members
        : (members as List?)?.cast<AdminWorkspaceUserUpsert>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertAdminWorkspaceUsersRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(members, other.members);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(members)]);

  @override
  String toString() =>
      'UpsertAdminWorkspaceUsersRequest('
      'members: ${members?.length})';
}

/// Administrative upsert admin workspace users result.
@immutable
class UpsertAdminWorkspaceUsersResult {
  /// Creates a [UpsertAdminWorkspaceUsersResult].
  const UpsertAdminWorkspaceUsersResult({
    required this.addedMembersCount,
    required this.updatedMembersCount,
  });

  /// Number of users added to the Workspace.
  final int addedMembersCount;

  /// Number of Workspace members updated.
  final int updatedMembersCount;

  /// Parses a [UpsertAdminWorkspaceUsersResult] from JSON.
  factory UpsertAdminWorkspaceUsersResult.fromJson(Map<String, dynamic> json) {
    if (json['added_members_count'] == null) {
      throw const FormatException(
        'UpsertAdminWorkspaceUsersResult: missing added_members_count',
      );
    }
    if (json['updated_members_count'] == null) {
      throw const FormatException(
        'UpsertAdminWorkspaceUsersResult: missing updated_members_count',
      );
    }
    return UpsertAdminWorkspaceUsersResult(
      addedMembersCount: json['added_members_count'] as int,
      updatedMembersCount: json['updated_members_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'added_members_count': addedMembersCount,
    'updated_members_count': updatedMembersCount,
  };

  /// Creates a copy with the given fields replaced.
  UpsertAdminWorkspaceUsersResult copyWith({
    int? addedMembersCount,
    int? updatedMembersCount,
  }) => UpsertAdminWorkspaceUsersResult(
    addedMembersCount: addedMembersCount ?? this.addedMembersCount,
    updatedMembersCount: updatedMembersCount ?? this.updatedMembersCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertAdminWorkspaceUsersResult &&
          runtimeType == other.runtimeType &&
          addedMembersCount == other.addedMembersCount &&
          updatedMembersCount == other.updatedMembersCount;

  @override
  int get hashCode => Object.hashAll([addedMembersCount, updatedMembersCount]);

  @override
  String toString() =>
      'UpsertAdminWorkspaceUsersResult('
      'addedMembersCount: $addedMembersCount, '
      'updatedMembersCount: $updatedMembersCount)';
}

/// Values for AdminApiObjectType.
enum AdminApiObjectType {
  /// Represents list.
  list('list'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminApiObjectType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminApiObjectType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Administrative workspace spend limit.
@immutable
class AdminWorkspaceSpendLimit {
  /// Creates a [AdminWorkspaceSpendLimit].
  const AdminWorkspaceSpendLimit({
    required this.currency,
    required this.noMonthlyLimit,
    required this.value,
  });

  /// Currency used for the Workspace spending limit.
  final String? currency;

  /// Whether the Workspace has no monthly spending limit.
  final bool? noMonthlyLimit;

  /// Monthly spending limit for the Workspace.
  final double? value;

  /// Parses a [AdminWorkspaceSpendLimit] from JSON.
  factory AdminWorkspaceSpendLimit.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('currency')) {
      throw const FormatException('AdminWorkspaceSpendLimit: missing currency');
    }
    if (!json.containsKey('no_monthly_limit')) {
      throw const FormatException(
        'AdminWorkspaceSpendLimit: missing no_monthly_limit',
      );
    }
    if (!json.containsKey('value')) {
      throw const FormatException('AdminWorkspaceSpendLimit: missing value');
    }
    return AdminWorkspaceSpendLimit(
      currency: json['currency'] == null ? null : json['currency'] as String,
      noMonthlyLimit: json['no_monthly_limit'] == null
          ? null
          : json['no_monthly_limit'] as bool,
      value: json['value'] == null ? null : (json['value'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'currency': currency,
    'no_monthly_limit': noMonthlyLimit,
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceSpendLimit copyWith({
    Object? currency = unsetCopyWithValue,
    Object? noMonthlyLimit = unsetCopyWithValue,
    Object? value = unsetCopyWithValue,
  }) => AdminWorkspaceSpendLimit(
    currency: currency == unsetCopyWithValue
        ? this.currency
        : currency as String?,
    noMonthlyLimit: noMonthlyLimit == unsetCopyWithValue
        ? this.noMonthlyLimit
        : noMonthlyLimit as bool?,
    value: value == unsetCopyWithValue
        ? this.value
        : (value as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceSpendLimit &&
          runtimeType == other.runtimeType &&
          currency == other.currency &&
          noMonthlyLimit == other.noMonthlyLimit &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([currency, noMonthlyLimit, value]);

  @override
  String toString() =>
      'AdminWorkspaceSpendLimit('
      'currency: $currency, '
      'noMonthlyLimit: $noMonthlyLimit, '
      'value: $value)';
}

/// Administrative workspace user addition.
@immutable
class AdminWorkspaceUserAddition {
  /// Creates a [AdminWorkspaceUserAddition].
  const AdminWorkspaceUserAddition({
    this.role,
    this.roleName,
    this.roleNames,
    this.roles,
    required this.userUuid,
  });

  /// Deprecated legacy single role value, kept for backward compatibility. Mutually exclusive with 'role_name'.
  final String? role;

  /// Deprecated single role name, kept for backward compatibility. Mutually exclusive with 'role'.
  final String? roleName;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final Object? roles;

  /// User ID of the Workspace member.
  final String userUuid;

  /// Parses a [AdminWorkspaceUserAddition] from JSON.
  factory AdminWorkspaceUserAddition.fromJson(Map<String, dynamic> json) {
    if (json['user_uuid'] == null) {
      throw const FormatException(
        'AdminWorkspaceUserAddition: missing user_uuid',
      );
    }
    return AdminWorkspaceUserAddition(
      role: json['role'] == null ? null : json['role'] as String,
      roleName: json['role_name'] == null ? null : json['role_name'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'],
      userUuid: json['user_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'role': ?role,
    'role_name': ?roleName,
    'role_names': ?roleNames,
    'roles': ?roles,
    'user_uuid': userUuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceUserAddition copyWith({
    Object? role = unsetCopyWithValue,
    Object? roleName = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
    String? userUuid,
  }) => AdminWorkspaceUserAddition(
    role: role == unsetCopyWithValue ? this.role : role as String?,
    roleName: roleName == unsetCopyWithValue
        ? this.roleName
        : roleName as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue ? this.roles : roles,
    userUuid: userUuid ?? this.userUuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceUserAddition &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          roleName == other.roleName &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles) &&
          userUuid == other.userUuid;

  @override
  int get hashCode => Object.hashAll([
    role,
    roleName,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
    userUuid,
  ]);

  @override
  String toString() =>
      'AdminWorkspaceUserAddition('
      'role: $role, '
      'roleName: $roleName, '
      'roleNames: ${roleNames?.length}, '
      'roles: $roles, '
      'userUuid: $userUuid)';
}

/// Administrative workspace user reference.
@immutable
class AdminWorkspaceUserReference {
  /// Creates a [AdminWorkspaceUserReference].
  const AdminWorkspaceUserReference({required this.userUuid});

  /// User ID of the Workspace member.
  final String userUuid;

  /// Parses a [AdminWorkspaceUserReference] from JSON.
  factory AdminWorkspaceUserReference.fromJson(Map<String, dynamic> json) {
    if (json['user_uuid'] == null) {
      throw const FormatException(
        'AdminWorkspaceUserReference: missing user_uuid',
      );
    }
    return AdminWorkspaceUserReference(userUuid: json['user_uuid'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'user_uuid': userUuid};

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceUserReference copyWith({String? userUuid}) =>
      AdminWorkspaceUserReference(userUuid: userUuid ?? this.userUuid);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceUserReference &&
          runtimeType == other.runtimeType &&
          userUuid == other.userUuid;

  @override
  int get hashCode => Object.hashAll([userUuid]);

  @override
  String toString() =>
      'AdminWorkspaceUserReference('
      'userUuid: $userUuid)';
}

/// Administrative workspace member.
@immutable
class AdminWorkspaceMember {
  /// Creates a [AdminWorkspaceMember].
  const AdminWorkspaceMember({
    required this.directMember,
    required this.email,
    required this.externallyManaged,
    required this.groupGrants,
    required this.name,
    required this.roles,
    required this.status,
    required this.userId,
  });

  /// Whether the user is a direct member of the Workspace. Members who only belong to it through a group are managed by changing the group.
  final bool directMember;

  /// Email address of the Workspace member.
  final String? email;

  /// Whether the member is managed by an external identity provider, through SSO or SCIM.
  final bool externallyManaged;

  /// Groups assigned to the Workspace that grant the member roles, with the roles each one grants.
  final List<AdminWorkspaceGroupGrant> groupGrants;

  /// Name of the Workspace member.
  final String? name;

  /// Names of the Workspace roles assigned directly to the member.
  final List<String> roles;

  /// Account status of the member.
  final AdminMemberStatus status;

  /// User ID of the Workspace member.
  final String userId;

  /// Parses a [AdminWorkspaceMember] from JSON.
  factory AdminWorkspaceMember.fromJson(Map<String, dynamic> json) {
    if (json['direct_member'] == null) {
      throw const FormatException(
        'AdminWorkspaceMember: missing direct_member',
      );
    }
    if (!json.containsKey('email')) {
      throw const FormatException('AdminWorkspaceMember: missing email');
    }
    if (json['externally_managed'] == null) {
      throw const FormatException(
        'AdminWorkspaceMember: missing externally_managed',
      );
    }
    if (json['group_grants'] == null) {
      throw const FormatException('AdminWorkspaceMember: missing group_grants');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('AdminWorkspaceMember: missing name');
    }
    if (json['roles'] == null) {
      throw const FormatException('AdminWorkspaceMember: missing roles');
    }
    if (json['status'] == null) {
      throw const FormatException('AdminWorkspaceMember: missing status');
    }
    if (json['user_id'] == null) {
      throw const FormatException('AdminWorkspaceMember: missing user_id');
    }
    return AdminWorkspaceMember(
      directMember: json['direct_member'] as bool,
      email: json['email'] == null ? null : json['email'] as String,
      externallyManaged: json['externally_managed'] as bool,
      groupGrants: (json['group_grants'] as List)
          .map(
            (item) =>
                AdminWorkspaceGroupGrant.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      name: json['name'] == null ? null : json['name'] as String,
      roles: (json['roles'] as List).map((item) => item as String).toList(),
      status: AdminMemberStatus.fromJson(json['status'] as String),
      userId: json['user_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'direct_member': directMember,
    'email': email,
    'externally_managed': externallyManaged,
    'group_grants': groupGrants.map((item) => item.toJson()).toList(),
    'name': name,
    'roles': roles,
    'status': status.toJson(),
    'user_id': userId,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceMember copyWith({
    bool? directMember,
    Object? email = unsetCopyWithValue,
    bool? externallyManaged,
    List<AdminWorkspaceGroupGrant>? groupGrants,
    Object? name = unsetCopyWithValue,
    List<String>? roles,
    AdminMemberStatus? status,
    String? userId,
  }) => AdminWorkspaceMember(
    directMember: directMember ?? this.directMember,
    email: email == unsetCopyWithValue ? this.email : email as String?,
    externallyManaged: externallyManaged ?? this.externallyManaged,
    groupGrants: groupGrants ?? this.groupGrants,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    roles: roles ?? this.roles,
    status: status ?? this.status,
    userId: userId ?? this.userId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceMember &&
          runtimeType == other.runtimeType &&
          directMember == other.directMember &&
          email == other.email &&
          externallyManaged == other.externallyManaged &&
          valuesDeepEqual(groupGrants, other.groupGrants) &&
          name == other.name &&
          valuesDeepEqual(roles, other.roles) &&
          status == other.status &&
          userId == other.userId;

  @override
  int get hashCode => Object.hashAll([
    directMember,
    email,
    externallyManaged,
    valueDeepHashCode(groupGrants),
    name,
    valueDeepHashCode(roles),
    status,
    userId,
  ]);

  @override
  String toString() =>
      'AdminWorkspaceMember('
      'directMember: $directMember, '
      'email: $email, '
      'externallyManaged: $externallyManaged, '
      'groupGrants: ${groupGrants.length}, '
      'name: $name, '
      'roles: ${roles.length}, '
      'status: $status, '
      'userId: $userId)';
}

/// Workspace member to add or update, either by setting its roles or by adding and removing some.
@immutable
class AdminWorkspaceUserUpsert {
  /// Creates a [AdminWorkspaceUserUpsert].
  const AdminWorkspaceUserUpsert({
    this.addRoleNames,
    this.addRoles,
    this.removeRoleNames,
    this.removeRoles,
    this.role,
    this.roleName,
    this.roleNames,
    this.roles,
    required this.userUuid,
  });

  /// Simplified role names to add to the existing roles. Mutually exclusive with 'add_roles'.
  final List<String>? addRoleNames;

  /// Role values to add to the existing roles. Mutually exclusive with 'add_role_names'.
  final List<String>? addRoles;

  /// Simplified role names to remove from the existing roles. Mutually exclusive with 'remove_roles'.
  final List<String>? removeRoleNames;

  /// Role values to remove from the existing roles. Mutually exclusive with 'remove_role_names'.
  final List<String>? removeRoles;

  /// Deprecated legacy single role value, kept for backward compatibility. Mutually exclusive with 'role_name'.
  final String? role;

  /// Deprecated single role name, kept for backward compatibility. Mutually exclusive with 'role'.
  final String? roleName;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final Object? roles;

  /// User ID of the Workspace member.
  final String userUuid;

  /// Parses a [AdminWorkspaceUserUpsert] from JSON.
  factory AdminWorkspaceUserUpsert.fromJson(Map<String, dynamic> json) {
    if (json['user_uuid'] == null) {
      throw const FormatException(
        'AdminWorkspaceUserUpsert: missing user_uuid',
      );
    }
    return AdminWorkspaceUserUpsert(
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
      roleName: json['role_name'] == null ? null : json['role_name'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'],
      userUuid: json['user_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'add_role_names': ?addRoleNames,
    'add_roles': ?addRoles,
    'remove_role_names': ?removeRoleNames,
    'remove_roles': ?removeRoles,
    'role': ?role,
    'role_name': ?roleName,
    'role_names': ?roleNames,
    'roles': ?roles,
    'user_uuid': userUuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceUserUpsert copyWith({
    Object? addRoleNames = unsetCopyWithValue,
    Object? addRoles = unsetCopyWithValue,
    Object? removeRoleNames = unsetCopyWithValue,
    Object? removeRoles = unsetCopyWithValue,
    Object? role = unsetCopyWithValue,
    Object? roleName = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
    String? userUuid,
  }) => AdminWorkspaceUserUpsert(
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
    roleName: roleName == unsetCopyWithValue
        ? this.roleName
        : roleName as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue ? this.roles : roles,
    userUuid: userUuid ?? this.userUuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceUserUpsert &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(addRoleNames, other.addRoleNames) &&
          valuesDeepEqual(addRoles, other.addRoles) &&
          valuesDeepEqual(removeRoleNames, other.removeRoleNames) &&
          valuesDeepEqual(removeRoles, other.removeRoles) &&
          role == other.role &&
          roleName == other.roleName &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles) &&
          userUuid == other.userUuid;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(addRoleNames),
    valueDeepHashCode(addRoles),
    valueDeepHashCode(removeRoleNames),
    valueDeepHashCode(removeRoles),
    role,
    roleName,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
    userUuid,
  ]);

  @override
  String toString() =>
      'AdminWorkspaceUserUpsert('
      'addRoleNames: ${addRoleNames?.length}, '
      'addRoles: ${addRoles?.length}, '
      'removeRoleNames: ${removeRoleNames?.length}, '
      'removeRoles: ${removeRoles?.length}, '
      'role: $role, '
      'roleName: $roleName, '
      'roleNames: ${roleNames?.length}, '
      'roles: $roles, '
      'userUuid: $userUuid)';
}

/// Administrative workspace group grant.
@immutable
class AdminWorkspaceGroupGrant {
  /// Creates a [AdminWorkspaceGroupGrant].
  const AdminWorkspaceGroupGrant({
    required this.groupId,
    required this.groupName,
    required this.roles,
  });

  /// ID of the group assigned to the Workspace.
  final String groupId;

  /// Name of the group assigned to the Workspace.
  final String groupName;

  /// Names of the Workspace roles the group assignment grants.
  final List<String> roles;

  /// Parses a [AdminWorkspaceGroupGrant] from JSON.
  factory AdminWorkspaceGroupGrant.fromJson(Map<String, dynamic> json) {
    if (json['group_id'] == null) {
      throw const FormatException('AdminWorkspaceGroupGrant: missing group_id');
    }
    if (json['group_name'] == null) {
      throw const FormatException(
        'AdminWorkspaceGroupGrant: missing group_name',
      );
    }
    if (json['roles'] == null) {
      throw const FormatException('AdminWorkspaceGroupGrant: missing roles');
    }
    return AdminWorkspaceGroupGrant(
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      roles: (json['roles'] as List).map((item) => item as String).toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'group_id': groupId,
    'group_name': groupName,
    'roles': roles,
  };

  /// Creates a copy with the given fields replaced.
  AdminWorkspaceGroupGrant copyWith({
    String? groupId,
    String? groupName,
    List<String>? roles,
  }) => AdminWorkspaceGroupGrant(
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    roles: roles ?? this.roles,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWorkspaceGroupGrant &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          groupName == other.groupName &&
          valuesDeepEqual(roles, other.roles);

  @override
  int get hashCode =>
      Object.hashAll([groupId, groupName, valueDeepHashCode(roles)]);

  @override
  String toString() =>
      'AdminWorkspaceGroupGrant('
      'groupId: $groupId, '
      'groupName: $groupName, '
      'roles: ${roles.length})';
}
