import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative organization users page.
@immutable
class AdminOrganizationUsersPage {
  /// Creates a [AdminOrganizationUsersPage].
  const AdminOrganizationUsersPage({
    required this.invites,
    required this.members,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Pending Organization invitations on this page.
  final List<AdminOrganizationInvite> invites;

  /// Organization members on this page.
  final List<AdminOrganizationMember> members;

  /// Page number returned.
  final int? page;

  /// Maximum number of results per page.
  final int? pageSize;

  /// Total number of users and invitations that match the request.
  final int? total;

  /// Parses a [AdminOrganizationUsersPage] from JSON.
  factory AdminOrganizationUsersPage.fromJson(Map<String, dynamic> json) {
    if (json['invites'] == null) {
      throw const FormatException(
        'AdminOrganizationUsersPage: missing invites',
      );
    }
    if (json['members'] == null) {
      throw const FormatException(
        'AdminOrganizationUsersPage: missing members',
      );
    }
    if (!json.containsKey('page')) {
      throw const FormatException('AdminOrganizationUsersPage: missing page');
    }
    if (!json.containsKey('page_size')) {
      throw const FormatException(
        'AdminOrganizationUsersPage: missing page_size',
      );
    }
    if (!json.containsKey('total')) {
      throw const FormatException('AdminOrganizationUsersPage: missing total');
    }
    return AdminOrganizationUsersPage(
      invites: (json['invites'] as List)
          .map(
            (item) =>
                AdminOrganizationInvite.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      members: (json['members'] as List)
          .map(
            (item) =>
                AdminOrganizationMember.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: json['page'] == null ? null : json['page'] as int,
      pageSize: json['page_size'] == null ? null : json['page_size'] as int,
      total: json['total'] == null ? null : json['total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'invites': invites.map((item) => item.toJson()).toList(),
    'members': members.map((item) => item.toJson()).toList(),
    'page': page,
    'page_size': pageSize,
    'total': total,
  };

  /// Creates a copy with the given fields replaced.
  AdminOrganizationUsersPage copyWith({
    List<AdminOrganizationInvite>? invites,
    List<AdminOrganizationMember>? members,
    Object? page = unsetCopyWithValue,
    Object? pageSize = unsetCopyWithValue,
    Object? total = unsetCopyWithValue,
  }) => AdminOrganizationUsersPage(
    invites: invites ?? this.invites,
    members: members ?? this.members,
    page: page == unsetCopyWithValue ? this.page : page as int?,
    pageSize: pageSize == unsetCopyWithValue ? this.pageSize : pageSize as int?,
    total: total == unsetCopyWithValue ? this.total : total as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminOrganizationUsersPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(invites, other.invites) &&
          valuesDeepEqual(members, other.members) &&
          page == other.page &&
          pageSize == other.pageSize &&
          total == other.total;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(invites),
    valueDeepHashCode(members),
    page,
    pageSize,
    total,
  ]);

  @override
  String toString() =>
      'AdminOrganizationUsersPage('
      'invites: ${invites.length}, '
      'members: ${members.length}, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative create admin user request.
@immutable
class CreateAdminUserRequest {
  /// Creates a [CreateAdminUserRequest].
  const CreateAdminUserRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    this.roleName,
    this.roleNames,
    this.roles,
    this.subscriptionTypes,
  });

  /// Email address of the user to create.
  final String email;

  /// First name of the user to create.
  final String firstName;

  /// Last name of the user to create.
  final String lastName;

  /// Deprecated legacy single role value, kept for backward compatibility. Mutually exclusive with 'role_name'.
  final String? role;

  /// Deprecated single role name, kept for backward compatibility. Mutually exclusive with 'role'.
  final String? roleName;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final Object? roles;

  /// Product seats to assign to the user.
  final List<AdminPlanType>? subscriptionTypes;

  /// Parses a [CreateAdminUserRequest] from JSON.
  factory CreateAdminUserRequest.fromJson(Map<String, dynamic> json) {
    if (json['email'] == null) {
      throw const FormatException('CreateAdminUserRequest: missing email');
    }
    if (json['first_name'] == null) {
      throw const FormatException('CreateAdminUserRequest: missing first_name');
    }
    if (json['last_name'] == null) {
      throw const FormatException('CreateAdminUserRequest: missing last_name');
    }
    return CreateAdminUserRequest(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] == null ? null : json['role'] as String,
      roleName: json['role_name'] == null ? null : json['role_name'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'],
      subscriptionTypes: json['subscription_types'] == null
          ? null
          : (json['subscription_types'] as List)
                .map((item) => AdminPlanType.fromJson(item as String))
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': ?role,
    'role_name': ?roleName,
    'role_names': ?roleNames,
    'roles': ?roles,
    if (subscriptionTypes != null)
      'subscription_types': subscriptionTypes!
          .map((item) => item.toJson())
          .toList(),
  };

  /// Creates a copy with the given fields replaced.
  CreateAdminUserRequest copyWith({
    String? email,
    String? firstName,
    String? lastName,
    Object? role = unsetCopyWithValue,
    Object? roleName = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
    Object? subscriptionTypes = unsetCopyWithValue,
  }) => CreateAdminUserRequest(
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    role: role == unsetCopyWithValue ? this.role : role as String?,
    roleName: roleName == unsetCopyWithValue
        ? this.roleName
        : roleName as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue ? this.roles : roles,
    subscriptionTypes: subscriptionTypes == unsetCopyWithValue
        ? this.subscriptionTypes
        : (subscriptionTypes as List?)?.cast<AdminPlanType>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAdminUserRequest &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          role == other.role &&
          roleName == other.roleName &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles) &&
          valuesDeepEqual(subscriptionTypes, other.subscriptionTypes);

  @override
  int get hashCode => Object.hashAll([
    email,
    firstName,
    lastName,
    role,
    roleName,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
    valueDeepHashCode(subscriptionTypes),
  ]);

  @override
  String toString() =>
      'CreateAdminUserRequest('
      'email: $email, '
      'firstName: $firstName, '
      'lastName: $lastName, '
      'role: $role, '
      'roleName: $roleName, '
      'roleNames: ${roleNames?.length}, '
      'roles: $roles, '
      'subscriptionTypes: ${subscriptionTypes?.length})';
}

/// Administrative create admin user response.
@immutable
class CreateAdminUserResponse {
  /// Creates a [CreateAdminUserResponse].
  const CreateAdminUserResponse({
    required this.emailToUserId,
    required this.invalidEmails,
  });

  /// Mapping from created user email to user identifier.
  final Map<String, String> emailToUserId;

  /// Email addresses that could not be created.
  final List<String> invalidEmails;

  /// Parses a [CreateAdminUserResponse] from JSON.
  factory CreateAdminUserResponse.fromJson(Map<String, dynamic> json) {
    if (json['email_to_user_id'] == null) {
      throw const FormatException(
        'CreateAdminUserResponse: missing email_to_user_id',
      );
    }
    if (json['invalid_emails'] == null) {
      throw const FormatException(
        'CreateAdminUserResponse: missing invalid_emails',
      );
    }
    return CreateAdminUserResponse(
      emailToUserId: (json['email_to_user_id'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(key, item as String),
      ),
      invalidEmails: (json['invalid_emails'] as List)
          .map((item) => item as String)
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'email_to_user_id': emailToUserId,
    'invalid_emails': invalidEmails,
  };

  /// Creates a copy with the given fields replaced.
  CreateAdminUserResponse copyWith({
    Map<String, String>? emailToUserId,
    List<String>? invalidEmails,
  }) => CreateAdminUserResponse(
    emailToUserId: emailToUserId ?? this.emailToUserId,
    invalidEmails: invalidEmails ?? this.invalidEmails,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAdminUserResponse &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(emailToUserId, other.emailToUserId) &&
          valuesDeepEqual(invalidEmails, other.invalidEmails);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(emailToUserId),
    valueDeepHashCode(invalidEmails),
  ]);

  @override
  String toString() =>
      'CreateAdminUserResponse('
      'emailToUserId: ${emailToUserId.length}, '
      'invalidEmails: ${invalidEmails.length})';
}

/// Administrative user invite.
@immutable
class AdminUserInvite {
  /// Creates a [AdminUserInvite].
  const AdminUserInvite({
    required this.email,
    required this.inviteUuid,
    required this.role,
    required this.roles,
  });

  /// Email address invited to the Organization.
  final String? email;

  /// Organization invitation ID.
  final String inviteUuid;

  /// Deprecated single invite role. Use 'roles' instead.
  final String role;

  /// Organization roles assigned by the invite.
  final List<String> roles;

  /// Parses a [AdminUserInvite] from JSON.
  factory AdminUserInvite.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('email')) {
      throw const FormatException('AdminUserInvite: missing email');
    }
    if (json['invite_uuid'] == null) {
      throw const FormatException('AdminUserInvite: missing invite_uuid');
    }
    if (json['role'] == null) {
      throw const FormatException('AdminUserInvite: missing role');
    }
    if (json['roles'] == null) {
      throw const FormatException('AdminUserInvite: missing roles');
    }
    return AdminUserInvite(
      email: json['email'] == null ? null : json['email'] as String,
      inviteUuid: json['invite_uuid'] as String,
      role: json['role'] as String,
      roles: (json['roles'] as List).map((item) => item as String).toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'email': email,
    'invite_uuid': inviteUuid,
    'role': role,
    'roles': roles,
  };

  /// Creates a copy with the given fields replaced.
  AdminUserInvite copyWith({
    Object? email = unsetCopyWithValue,
    String? inviteUuid,
    String? role,
    List<String>? roles,
  }) => AdminUserInvite(
    email: email == unsetCopyWithValue ? this.email : email as String?,
    inviteUuid: inviteUuid ?? this.inviteUuid,
    role: role ?? this.role,
    roles: roles ?? this.roles,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserInvite &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          inviteUuid == other.inviteUuid &&
          role == other.role &&
          valuesDeepEqual(roles, other.roles);

  @override
  int get hashCode =>
      Object.hashAll([email, inviteUuid, role, valueDeepHashCode(roles)]);

  @override
  String toString() =>
      'AdminUserInvite('
      'email: $email, '
      'inviteUuid: $inviteUuid, '
      'role: $role, '
      'roles: ${roles.length})';
}

/// Administrative invite admin user request.
@immutable
class InviteAdminUserRequest {
  /// Creates a [InviteAdminUserRequest].
  const InviteAdminUserRequest({
    required this.email,
    this.emailLanguage,
    this.role,
    this.roleName,
    this.roleNames,
    this.roles,
    this.subscriptionSeatAutomaticGranting,
    this.subscriptionType,
    this.subscriptionTypes,
    this.workspaceUuids,
  });

  /// Email address, comma-separated emails, or newline-separated emails to invite.
  final String email;

  /// Language used for invitation emails.
  final String? emailLanguage;

  /// Deprecated legacy single role value, kept for backward compatibility. Mutually exclusive with 'role_name'.
  final String? role;

  /// Deprecated single role name, kept for backward compatibility. Mutually exclusive with 'role'.
  final String? roleName;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final Object? roles;

  /// Whether to grant subscription seats automatically.
  final bool? subscriptionSeatAutomaticGranting;

  /// Deprecated single product seat to assign.
  final AdminPlanType? subscriptionType;

  /// Product seats to assign to invited users.
  final List<AdminPlanType>? subscriptionTypes;

  /// Workspace IDs the invited users should join.
  final List<String>? workspaceUuids;

  /// Parses a [InviteAdminUserRequest] from JSON.
  factory InviteAdminUserRequest.fromJson(Map<String, dynamic> json) {
    if (json['email'] == null) {
      throw const FormatException('InviteAdminUserRequest: missing email');
    }
    return InviteAdminUserRequest(
      email: json['email'] as String,
      emailLanguage: json['email_language'] == null
          ? null
          : json['email_language'] as String,
      role: json['role'] == null ? null : json['role'] as String,
      roleName: json['role_name'] == null ? null : json['role_name'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'],
      subscriptionSeatAutomaticGranting:
          json['subscription_seat_automatic_granting'] == null
          ? null
          : json['subscription_seat_automatic_granting'] as bool,
      subscriptionType: json['subscription_type'] == null
          ? null
          : AdminPlanType.fromJson(json['subscription_type'] as String),
      subscriptionTypes: json['subscription_types'] == null
          ? null
          : (json['subscription_types'] as List)
                .map((item) => AdminPlanType.fromJson(item as String))
                .toList(),
      workspaceUuids: json['workspace_uuids'] == null
          ? null
          : (json['workspace_uuids'] as List)
                .map((item) => item as String)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'email': email,
    'email_language': ?emailLanguage,
    'role': ?role,
    'role_name': ?roleName,
    'role_names': ?roleNames,
    'roles': ?roles,
    'subscription_seat_automatic_granting': ?subscriptionSeatAutomaticGranting,
    if (subscriptionType != null)
      'subscription_type': subscriptionType!.toJson(),
    if (subscriptionTypes != null)
      'subscription_types': subscriptionTypes!
          .map((item) => item.toJson())
          .toList(),
    'workspace_uuids': ?workspaceUuids,
  };

  /// Creates a copy with the given fields replaced.
  InviteAdminUserRequest copyWith({
    String? email,
    Object? emailLanguage = unsetCopyWithValue,
    Object? role = unsetCopyWithValue,
    Object? roleName = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
    Object? subscriptionSeatAutomaticGranting = unsetCopyWithValue,
    Object? subscriptionType = unsetCopyWithValue,
    Object? subscriptionTypes = unsetCopyWithValue,
    Object? workspaceUuids = unsetCopyWithValue,
  }) => InviteAdminUserRequest(
    email: email ?? this.email,
    emailLanguage: emailLanguage == unsetCopyWithValue
        ? this.emailLanguage
        : emailLanguage as String?,
    role: role == unsetCopyWithValue ? this.role : role as String?,
    roleName: roleName == unsetCopyWithValue
        ? this.roleName
        : roleName as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue ? this.roles : roles,
    subscriptionSeatAutomaticGranting:
        subscriptionSeatAutomaticGranting == unsetCopyWithValue
        ? this.subscriptionSeatAutomaticGranting
        : subscriptionSeatAutomaticGranting as bool?,
    subscriptionType: subscriptionType == unsetCopyWithValue
        ? this.subscriptionType
        : subscriptionType as AdminPlanType?,
    subscriptionTypes: subscriptionTypes == unsetCopyWithValue
        ? this.subscriptionTypes
        : (subscriptionTypes as List?)?.cast<AdminPlanType>(),
    workspaceUuids: workspaceUuids == unsetCopyWithValue
        ? this.workspaceUuids
        : (workspaceUuids as List?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InviteAdminUserRequest &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          emailLanguage == other.emailLanguage &&
          role == other.role &&
          roleName == other.roleName &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles) &&
          subscriptionSeatAutomaticGranting ==
              other.subscriptionSeatAutomaticGranting &&
          subscriptionType == other.subscriptionType &&
          valuesDeepEqual(subscriptionTypes, other.subscriptionTypes) &&
          valuesDeepEqual(workspaceUuids, other.workspaceUuids);

  @override
  int get hashCode => Object.hashAll([
    email,
    emailLanguage,
    role,
    roleName,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
    subscriptionSeatAutomaticGranting,
    subscriptionType,
    valueDeepHashCode(subscriptionTypes),
    valueDeepHashCode(workspaceUuids),
  ]);

  @override
  String toString() =>
      'InviteAdminUserRequest('
      'email: $email, '
      'emailLanguage: $emailLanguage, '
      'role: $role, '
      'roleName: $roleName, '
      'roleNames: ${roleNames?.length}, '
      'roles: $roles, '
      'subscriptionSeatAutomaticGranting: $subscriptionSeatAutomaticGranting, '
      'subscriptionType: $subscriptionType, '
      'subscriptionTypes: ${subscriptionTypes?.length}, '
      'workspaceUuids: ${workspaceUuids?.length})';
}

/// Administrative invite admin user response.
@immutable
class InviteAdminUserResponse {
  /// Creates a [InviteAdminUserResponse].
  const InviteAdminUserResponse({
    required this.alreadyMembers,
    required this.invalidEmails,
    this.invitedMembersCount,
  });

  /// Email addresses that already belong to the Organization.
  final List<String> alreadyMembers;

  /// Email addresses that could not be invited.
  final List<String> invalidEmails;

  /// Number of invitations successfully created.
  final int? invitedMembersCount;

  /// Parses a [InviteAdminUserResponse] from JSON.
  factory InviteAdminUserResponse.fromJson(Map<String, dynamic> json) {
    if (json['already_members'] == null) {
      throw const FormatException(
        'InviteAdminUserResponse: missing already_members',
      );
    }
    if (json['invalid_emails'] == null) {
      throw const FormatException(
        'InviteAdminUserResponse: missing invalid_emails',
      );
    }
    return InviteAdminUserResponse(
      alreadyMembers: (json['already_members'] as List)
          .map((item) => item as String)
          .toList(),
      invalidEmails: (json['invalid_emails'] as List)
          .map((item) => item as String)
          .toList(),
      invitedMembersCount: json['invited_members_count'] == null
          ? null
          : json['invited_members_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'already_members': alreadyMembers,
    'invalid_emails': invalidEmails,
    'invited_members_count': ?invitedMembersCount,
  };

  /// Creates a copy with the given fields replaced.
  InviteAdminUserResponse copyWith({
    List<String>? alreadyMembers,
    List<String>? invalidEmails,
    Object? invitedMembersCount = unsetCopyWithValue,
  }) => InviteAdminUserResponse(
    alreadyMembers: alreadyMembers ?? this.alreadyMembers,
    invalidEmails: invalidEmails ?? this.invalidEmails,
    invitedMembersCount: invitedMembersCount == unsetCopyWithValue
        ? this.invitedMembersCount
        : invitedMembersCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InviteAdminUserResponse &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(alreadyMembers, other.alreadyMembers) &&
          valuesDeepEqual(invalidEmails, other.invalidEmails) &&
          invitedMembersCount == other.invitedMembersCount;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(alreadyMembers),
    valueDeepHashCode(invalidEmails),
    invitedMembersCount,
  ]);

  @override
  String toString() =>
      'InviteAdminUserResponse('
      'alreadyMembers: ${alreadyMembers.length}, '
      'invalidEmails: ${invalidEmails.length}, '
      'invitedMembersCount: $invitedMembersCount)';
}

/// Administrative delete result.
@immutable
class AdminDeleteResult {
  /// Creates a [AdminDeleteResult].
  const AdminDeleteResult({required this.message});

  /// Deletion result message.
  final String message;

  /// Parses a [AdminDeleteResult] from JSON.
  factory AdminDeleteResult.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw const FormatException('AdminDeleteResult: missing message');
    }
    return AdminDeleteResult(message: json['message'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'message': message};

  /// Creates a copy with the given fields replaced.
  AdminDeleteResult copyWith({String? message}) =>
      AdminDeleteResult(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDeleteResult &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hashAll([message]);

  @override
  String toString() =>
      'AdminDeleteResult('
      'message: $message)';
}

/// Administrative user.
@immutable
class AdminUser {
  /// Creates a [AdminUser].
  const AdminUser({
    required this.createdAt,
    required this.email,
    required this.firstName,
    this.isSsoOutsider,
    this.lastLoginAt,
    required this.lastName,
    required this.name,
    required this.oidId,
    required this.rawRole,
    required this.rawRoles,
    this.status,
    this.subscriptionTypes,
    this.subscriptions,
    required this.uuid,
    this.workspaces,
    this.workspacesTotal,
  });

  /// Date the member was added to the Organization.
  final String createdAt;

  /// Email address of the Organization member.
  final String? email;

  /// User first name.
  final String? firstName;

  /// Whether the member is outside the SSO domain.
  final bool? isSsoOutsider;

  /// Last time the member signed in to the Organization, accurate to about 30 minutes. Null if they never signed in.
  final String? lastLoginAt;

  /// User last name.
  final String? lastName;

  /// Name of the Organization member.
  final String? name;

  /// Identity provider ID for the member.
  final String? oidId;

  /// Deprecated single organization role. Use 'raw_roles' instead.
  final String rawRole;

  /// Organization roles assigned to the member.
  final List<String> rawRoles;

  /// Account status of the member. Deactivated and blocked members cannot access the Organization.
  final AdminMemberStatus? status;

  /// Product seats assigned to the member.
  final List<String>? subscriptionTypes;

  /// Subscriptions assigned to the member.
  final List<AdminMemberSubscription>? subscriptions;

  /// Organization member ID.
  final String uuid;

  /// Deprecated: limited to the first 100 Workspaces the member belongs to, ordered by name. Use GET /users/{user_id}/workspaces instead.
  final List<AdminMemberWorkspace>? workspaces;

  /// Total number of Workspaces the member belongs to, including those not returned in 'workspaces'.
  final int? workspacesTotal;

  /// Parses a [AdminUser] from JSON.
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('AdminUser: missing created_at');
    }
    if (!json.containsKey('email')) {
      throw const FormatException('AdminUser: missing email');
    }
    if (!json.containsKey('first_name')) {
      throw const FormatException('AdminUser: missing first_name');
    }
    if (!json.containsKey('last_name')) {
      throw const FormatException('AdminUser: missing last_name');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('AdminUser: missing name');
    }
    if (!json.containsKey('oid_id')) {
      throw const FormatException('AdminUser: missing oid_id');
    }
    if (json['raw_role'] == null) {
      throw const FormatException('AdminUser: missing raw_role');
    }
    if (json['raw_roles'] == null) {
      throw const FormatException('AdminUser: missing raw_roles');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminUser: missing uuid');
    }
    return AdminUser(
      createdAt: json['created_at'] as String,
      email: json['email'] == null ? null : json['email'] as String,
      firstName: json['first_name'] == null
          ? null
          : json['first_name'] as String,
      isSsoOutsider: json['is_sso_outsider'] == null
          ? null
          : json['is_sso_outsider'] as bool,
      lastLoginAt: json['last_login_at'] == null
          ? null
          : json['last_login_at'] as String,
      lastName: json['last_name'] == null ? null : json['last_name'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      oidId: json['oid_id'] == null ? null : json['oid_id'] as String,
      rawRole: json['raw_role'] as String,
      rawRoles: (json['raw_roles'] as List)
          .map((item) => item as String)
          .toList(),
      status: json['status'] == null
          ? null
          : AdminMemberStatus.fromJson(json['status'] as String),
      subscriptionTypes: json['subscription_types'] == null
          ? null
          : (json['subscription_types'] as List)
                .map((item) => item as String)
                .toList(),
      subscriptions: json['subscriptions'] == null
          ? null
          : (json['subscriptions'] as List)
                .map(
                  (item) => AdminMemberSubscription.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      uuid: json['uuid'] as String,
      workspaces: json['workspaces'] == null
          ? null
          : (json['workspaces'] as List)
                .map(
                  (item) => AdminMemberWorkspace.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      workspacesTotal: json['workspaces_total'] == null
          ? null
          : json['workspaces_total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'email': email,
    'first_name': firstName,
    'is_sso_outsider': ?isSsoOutsider,
    'last_login_at': ?lastLoginAt,
    'last_name': lastName,
    'name': name,
    'oid_id': oidId,
    'raw_role': rawRole,
    'raw_roles': rawRoles,
    'status': ?status?.toJson(),
    'subscription_types': ?subscriptionTypes,
    if (subscriptions != null)
      'subscriptions': subscriptions!.map((item) => item.toJson()).toList(),
    'uuid': uuid,
    if (workspaces != null)
      'workspaces': workspaces!.map((item) => item.toJson()).toList(),
    'workspaces_total': ?workspacesTotal,
  };

  /// Creates a copy with the given fields replaced.
  AdminUser copyWith({
    String? createdAt,
    Object? email = unsetCopyWithValue,
    Object? firstName = unsetCopyWithValue,
    Object? isSsoOutsider = unsetCopyWithValue,
    Object? lastLoginAt = unsetCopyWithValue,
    Object? lastName = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? oidId = unsetCopyWithValue,
    String? rawRole,
    List<String>? rawRoles,
    Object? status = unsetCopyWithValue,
    Object? subscriptionTypes = unsetCopyWithValue,
    Object? subscriptions = unsetCopyWithValue,
    String? uuid,
    Object? workspaces = unsetCopyWithValue,
    Object? workspacesTotal = unsetCopyWithValue,
  }) => AdminUser(
    createdAt: createdAt ?? this.createdAt,
    email: email == unsetCopyWithValue ? this.email : email as String?,
    firstName: firstName == unsetCopyWithValue
        ? this.firstName
        : firstName as String?,
    isSsoOutsider: isSsoOutsider == unsetCopyWithValue
        ? this.isSsoOutsider
        : isSsoOutsider as bool?,
    lastLoginAt: lastLoginAt == unsetCopyWithValue
        ? this.lastLoginAt
        : lastLoginAt as String?,
    lastName: lastName == unsetCopyWithValue
        ? this.lastName
        : lastName as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    oidId: oidId == unsetCopyWithValue ? this.oidId : oidId as String?,
    rawRole: rawRole ?? this.rawRole,
    rawRoles: rawRoles ?? this.rawRoles,
    status: status == unsetCopyWithValue
        ? this.status
        : status as AdminMemberStatus?,
    subscriptionTypes: subscriptionTypes == unsetCopyWithValue
        ? this.subscriptionTypes
        : (subscriptionTypes as List?)?.cast<String>(),
    subscriptions: subscriptions == unsetCopyWithValue
        ? this.subscriptions
        : (subscriptions as List?)?.cast<AdminMemberSubscription>(),
    uuid: uuid ?? this.uuid,
    workspaces: workspaces == unsetCopyWithValue
        ? this.workspaces
        : (workspaces as List?)?.cast<AdminMemberWorkspace>(),
    workspacesTotal: workspacesTotal == unsetCopyWithValue
        ? this.workspacesTotal
        : workspacesTotal as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUser &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          email == other.email &&
          firstName == other.firstName &&
          isSsoOutsider == other.isSsoOutsider &&
          lastLoginAt == other.lastLoginAt &&
          lastName == other.lastName &&
          name == other.name &&
          oidId == other.oidId &&
          rawRole == other.rawRole &&
          valuesDeepEqual(rawRoles, other.rawRoles) &&
          status == other.status &&
          valuesDeepEqual(subscriptionTypes, other.subscriptionTypes) &&
          valuesDeepEqual(subscriptions, other.subscriptions) &&
          uuid == other.uuid &&
          valuesDeepEqual(workspaces, other.workspaces) &&
          workspacesTotal == other.workspacesTotal;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    email,
    firstName,
    isSsoOutsider,
    lastLoginAt,
    lastName,
    name,
    oidId,
    rawRole,
    valueDeepHashCode(rawRoles),
    status,
    valueDeepHashCode(subscriptionTypes),
    valueDeepHashCode(subscriptions),
    uuid,
    valueDeepHashCode(workspaces),
    workspacesTotal,
  ]);

  @override
  String toString() =>
      'AdminUser('
      'createdAt: $createdAt, '
      'email: $email, '
      'firstName: $firstName, '
      'isSsoOutsider: $isSsoOutsider, '
      'lastLoginAt: $lastLoginAt, '
      'lastName: $lastName, '
      'name: $name, '
      'oidId: $oidId, '
      'rawRole: $rawRole, '
      'rawRoles: ${rawRoles.length}, '
      'status: $status, '
      'subscriptionTypes: ${subscriptionTypes?.length}, '
      'subscriptions: ${subscriptions?.length}, '
      'uuid: $uuid, '
      'workspaces: ${workspaces?.length}, '
      'workspacesTotal: $workspacesTotal)';
}

/// Administrative update admin user request.
@immutable
class UpdateAdminUserRequest {
  /// Creates a [UpdateAdminUserRequest].
  const UpdateAdminUserRequest({
    this.role,
    this.roleName,
    this.roleNames,
    this.roles,
    this.subscriptionTypes,
  });

  /// Deprecated legacy single role value, kept for backward compatibility. Mutually exclusive with 'role_name'.
  final String? role;

  /// Deprecated single role name, kept for backward compatibility. Mutually exclusive with 'role'.
  final String? roleName;

  /// Simplified role names to assign. Mutually exclusive with 'roles'.
  final List<String>? roleNames;

  /// Role values to assign. Mutually exclusive with 'role_names'.
  final Object? roles;

  /// Product seats to assign to the member.
  final List<String>? subscriptionTypes;

  /// Parses a [UpdateAdminUserRequest] from JSON.
  factory UpdateAdminUserRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAdminUserRequest(
      role: json['role'] == null ? null : json['role'] as String,
      roleName: json['role_name'] == null ? null : json['role_name'] as String,
      roleNames: json['role_names'] == null
          ? null
          : (json['role_names'] as List).map((item) => item as String).toList(),
      roles: json['roles'],
      subscriptionTypes: json['subscription_types'] == null
          ? null
          : (json['subscription_types'] as List)
                .map((item) => item as String)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'role': ?role,
    'role_name': ?roleName,
    'role_names': ?roleNames,
    'roles': ?roles,
    'subscription_types': ?subscriptionTypes,
  };

  /// Creates a copy with the given fields replaced.
  UpdateAdminUserRequest copyWith({
    Object? role = unsetCopyWithValue,
    Object? roleName = unsetCopyWithValue,
    Object? roleNames = unsetCopyWithValue,
    Object? roles = unsetCopyWithValue,
    Object? subscriptionTypes = unsetCopyWithValue,
  }) => UpdateAdminUserRequest(
    role: role == unsetCopyWithValue ? this.role : role as String?,
    roleName: roleName == unsetCopyWithValue
        ? this.roleName
        : roleName as String?,
    roleNames: roleNames == unsetCopyWithValue
        ? this.roleNames
        : (roleNames as List?)?.cast<String>(),
    roles: roles == unsetCopyWithValue ? this.roles : roles,
    subscriptionTypes: subscriptionTypes == unsetCopyWithValue
        ? this.subscriptionTypes
        : (subscriptionTypes as List?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminUserRequest &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          roleName == other.roleName &&
          valuesDeepEqual(roleNames, other.roleNames) &&
          valuesDeepEqual(roles, other.roles) &&
          valuesDeepEqual(subscriptionTypes, other.subscriptionTypes);

  @override
  int get hashCode => Object.hashAll([
    role,
    roleName,
    valueDeepHashCode(roleNames),
    valueDeepHashCode(roles),
    valueDeepHashCode(subscriptionTypes),
  ]);

  @override
  String toString() =>
      'UpdateAdminUserRequest('
      'role: $role, '
      'roleName: $roleName, '
      'roleNames: ${roleNames?.length}, '
      'roles: $roles, '
      'subscriptionTypes: ${subscriptionTypes?.length})';
}

/// Administrative organization member.
@immutable
class AdminOrganizationMember {
  /// Creates a [AdminOrganizationMember].
  const AdminOrganizationMember({
    required this.createdAt,
    required this.email,
    this.isSsoOutsider,
    this.lastLoginAt,
    required this.name,
    required this.oidId,
    required this.rawRole,
    required this.rawRoles,
    this.status,
    this.subscriptionTypes,
    this.subscriptions,
    required this.uuid,
    this.workspaces,
    this.workspacesTotal,
  });

  /// Date the member was added to the Organization.
  final String createdAt;

  /// Email address of the Organization member.
  final String? email;

  /// Whether the member is outside the SSO domain.
  final bool? isSsoOutsider;

  /// Last time the member signed in to the Organization, accurate to about 30 minutes. Null if they never signed in.
  final String? lastLoginAt;

  /// Name of the Organization member.
  final String? name;

  /// Identity provider ID for the member.
  final String? oidId;

  /// Deprecated single organization role. Use 'raw_roles' instead.
  final String rawRole;

  /// Organization roles assigned to the member.
  final List<String> rawRoles;

  /// Account status of the member. Deactivated and blocked members cannot access the Organization.
  final AdminMemberStatus? status;

  /// Product seats assigned to the member.
  final List<String>? subscriptionTypes;

  /// Subscriptions assigned to the member.
  final List<AdminMemberSubscription>? subscriptions;

  /// Organization member ID.
  final String uuid;

  /// Deprecated: limited to the first 100 Workspaces the member belongs to, ordered by name. Use GET /users/{user_id}/workspaces instead.
  final List<AdminMemberWorkspace>? workspaces;

  /// Total number of Workspaces the member belongs to, including those not returned in 'workspaces'.
  final int? workspacesTotal;

  /// Parses a [AdminOrganizationMember] from JSON.
  factory AdminOrganizationMember.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'AdminOrganizationMember: missing created_at',
      );
    }
    if (!json.containsKey('email')) {
      throw const FormatException('AdminOrganizationMember: missing email');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('AdminOrganizationMember: missing name');
    }
    if (!json.containsKey('oid_id')) {
      throw const FormatException('AdminOrganizationMember: missing oid_id');
    }
    if (json['raw_role'] == null) {
      throw const FormatException('AdminOrganizationMember: missing raw_role');
    }
    if (json['raw_roles'] == null) {
      throw const FormatException('AdminOrganizationMember: missing raw_roles');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminOrganizationMember: missing uuid');
    }
    return AdminOrganizationMember(
      createdAt: json['created_at'] as String,
      email: json['email'] == null ? null : json['email'] as String,
      isSsoOutsider: json['is_sso_outsider'] == null
          ? null
          : json['is_sso_outsider'] as bool,
      lastLoginAt: json['last_login_at'] == null
          ? null
          : json['last_login_at'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      oidId: json['oid_id'] == null ? null : json['oid_id'] as String,
      rawRole: json['raw_role'] as String,
      rawRoles: (json['raw_roles'] as List)
          .map((item) => item as String)
          .toList(),
      status: json['status'] == null
          ? null
          : AdminMemberStatus.fromJson(json['status'] as String),
      subscriptionTypes: json['subscription_types'] == null
          ? null
          : (json['subscription_types'] as List)
                .map((item) => item as String)
                .toList(),
      subscriptions: json['subscriptions'] == null
          ? null
          : (json['subscriptions'] as List)
                .map(
                  (item) => AdminMemberSubscription.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      uuid: json['uuid'] as String,
      workspaces: json['workspaces'] == null
          ? null
          : (json['workspaces'] as List)
                .map(
                  (item) => AdminMemberWorkspace.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      workspacesTotal: json['workspaces_total'] == null
          ? null
          : json['workspaces_total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'email': email,
    'is_sso_outsider': ?isSsoOutsider,
    'last_login_at': ?lastLoginAt,
    'name': name,
    'oid_id': oidId,
    'raw_role': rawRole,
    'raw_roles': rawRoles,
    'status': ?status?.toJson(),
    'subscription_types': ?subscriptionTypes,
    if (subscriptions != null)
      'subscriptions': subscriptions!.map((item) => item.toJson()).toList(),
    'uuid': uuid,
    if (workspaces != null)
      'workspaces': workspaces!.map((item) => item.toJson()).toList(),
    'workspaces_total': ?workspacesTotal,
  };

  /// Creates a copy with the given fields replaced.
  AdminOrganizationMember copyWith({
    String? createdAt,
    Object? email = unsetCopyWithValue,
    Object? isSsoOutsider = unsetCopyWithValue,
    Object? lastLoginAt = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? oidId = unsetCopyWithValue,
    String? rawRole,
    List<String>? rawRoles,
    Object? status = unsetCopyWithValue,
    Object? subscriptionTypes = unsetCopyWithValue,
    Object? subscriptions = unsetCopyWithValue,
    String? uuid,
    Object? workspaces = unsetCopyWithValue,
    Object? workspacesTotal = unsetCopyWithValue,
  }) => AdminOrganizationMember(
    createdAt: createdAt ?? this.createdAt,
    email: email == unsetCopyWithValue ? this.email : email as String?,
    isSsoOutsider: isSsoOutsider == unsetCopyWithValue
        ? this.isSsoOutsider
        : isSsoOutsider as bool?,
    lastLoginAt: lastLoginAt == unsetCopyWithValue
        ? this.lastLoginAt
        : lastLoginAt as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    oidId: oidId == unsetCopyWithValue ? this.oidId : oidId as String?,
    rawRole: rawRole ?? this.rawRole,
    rawRoles: rawRoles ?? this.rawRoles,
    status: status == unsetCopyWithValue
        ? this.status
        : status as AdminMemberStatus?,
    subscriptionTypes: subscriptionTypes == unsetCopyWithValue
        ? this.subscriptionTypes
        : (subscriptionTypes as List?)?.cast<String>(),
    subscriptions: subscriptions == unsetCopyWithValue
        ? this.subscriptions
        : (subscriptions as List?)?.cast<AdminMemberSubscription>(),
    uuid: uuid ?? this.uuid,
    workspaces: workspaces == unsetCopyWithValue
        ? this.workspaces
        : (workspaces as List?)?.cast<AdminMemberWorkspace>(),
    workspacesTotal: workspacesTotal == unsetCopyWithValue
        ? this.workspacesTotal
        : workspacesTotal as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminOrganizationMember &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          email == other.email &&
          isSsoOutsider == other.isSsoOutsider &&
          lastLoginAt == other.lastLoginAt &&
          name == other.name &&
          oidId == other.oidId &&
          rawRole == other.rawRole &&
          valuesDeepEqual(rawRoles, other.rawRoles) &&
          status == other.status &&
          valuesDeepEqual(subscriptionTypes, other.subscriptionTypes) &&
          valuesDeepEqual(subscriptions, other.subscriptions) &&
          uuid == other.uuid &&
          valuesDeepEqual(workspaces, other.workspaces) &&
          workspacesTotal == other.workspacesTotal;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    email,
    isSsoOutsider,
    lastLoginAt,
    name,
    oidId,
    rawRole,
    valueDeepHashCode(rawRoles),
    status,
    valueDeepHashCode(subscriptionTypes),
    valueDeepHashCode(subscriptions),
    uuid,
    valueDeepHashCode(workspaces),
    workspacesTotal,
  ]);

  @override
  String toString() =>
      'AdminOrganizationMember('
      'createdAt: $createdAt, '
      'email: $email, '
      'isSsoOutsider: $isSsoOutsider, '
      'lastLoginAt: $lastLoginAt, '
      'name: $name, '
      'oidId: $oidId, '
      'rawRole: $rawRole, '
      'rawRoles: ${rawRoles.length}, '
      'status: $status, '
      'subscriptionTypes: ${subscriptionTypes?.length}, '
      'subscriptions: ${subscriptions?.length}, '
      'uuid: $uuid, '
      'workspaces: ${workspaces?.length}, '
      'workspacesTotal: $workspacesTotal)';
}

/// Administrative deactivate user result.
@immutable
class AdminDeactivateUserResult {
  /// Creates a [AdminDeactivateUserResult].
  const AdminDeactivateUserResult({required this.message});

  /// Deactivation result message.
  final String message;

  /// Parses a [AdminDeactivateUserResult] from JSON.
  factory AdminDeactivateUserResult.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw const FormatException('AdminDeactivateUserResult: missing message');
    }
    return AdminDeactivateUserResult(message: json['message'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'message': message};

  /// Creates a copy with the given fields replaced.
  AdminDeactivateUserResult copyWith({String? message}) =>
      AdminDeactivateUserResult(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDeactivateUserResult &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hashAll([message]);

  @override
  String toString() =>
      'AdminDeactivateUserResult('
      'message: $message)';
}

/// Administrative reactivate user result.
@immutable
class AdminReactivateUserResult {
  /// Creates a [AdminReactivateUserResult].
  const AdminReactivateUserResult({required this.message});

  /// Reactivation result message.
  final String message;

  /// Parses a [AdminReactivateUserResult] from JSON.
  factory AdminReactivateUserResult.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw const FormatException('AdminReactivateUserResult: missing message');
    }
    return AdminReactivateUserResult(message: json['message'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'message': message};

  /// Creates a copy with the given fields replaced.
  AdminReactivateUserResult copyWith({String? message}) =>
      AdminReactivateUserResult(message: message ?? this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminReactivateUserResult &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hashAll([message]);

  @override
  String toString() =>
      'AdminReactivateUserResult('
      'message: $message)';
}

/// Administrative user workspaces page.
@immutable
class AdminUserWorkspacesPage {
  /// Creates a [AdminUserWorkspacesPage].
  const AdminUserWorkspacesPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Workspaces the member belongs to on this page, ordered by name.
  final List<AdminMemberWorkspace> items;

  /// Page number returned.
  final int page;

  /// Maximum number of results per page.
  final int pageSize;

  /// Total number of Workspaces the member belongs to.
  final int total;

  /// Parses a [AdminUserWorkspacesPage] from JSON.
  factory AdminUserWorkspacesPage.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      throw const FormatException('AdminUserWorkspacesPage: missing items');
    }
    if (json['page'] == null) {
      throw const FormatException('AdminUserWorkspacesPage: missing page');
    }
    if (json['page_size'] == null) {
      throw const FormatException('AdminUserWorkspacesPage: missing page_size');
    }
    if (json['total'] == null) {
      throw const FormatException('AdminUserWorkspacesPage: missing total');
    }
    return AdminUserWorkspacesPage(
      items: (json['items'] as List)
          .map(
            (item) =>
                AdminMemberWorkspace.fromJson(item as Map<String, dynamic>),
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
  AdminUserWorkspacesPage copyWith({
    List<AdminMemberWorkspace>? items,
    int? page,
    int? pageSize,
    int? total,
  }) => AdminUserWorkspacesPage(
    items: items ?? this.items,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserWorkspacesPage &&
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
      'AdminUserWorkspacesPage('
      'items: ${items.length}, '
      'page: $page, '
      'pageSize: $pageSize, '
      'total: $total)';
}

/// Administrative organization invite.
@immutable
class AdminOrganizationInvite {
  /// Creates a [AdminOrganizationInvite].
  const AdminOrganizationInvite({
    required this.createdAt,
    required this.email,
    required this.expired,
    required this.rawRole,
    required this.rawRoles,
    required this.uuid,
    this.workspaceUuids,
  });

  /// Time when the invitation was created.
  final String createdAt;

  /// Email address invited to the Organization.
  final String email;

  /// Whether the invitation has expired.
  final bool expired;

  /// Deprecated single invite role. Use 'raw_roles' instead.
  final String rawRole;

  /// Organization roles assigned by the invite.
  final List<String> rawRoles;

  /// Organization invitation ID.
  final String uuid;

  /// Workspace IDs the invited user will join.
  final List<String>? workspaceUuids;

  /// Parses a [AdminOrganizationInvite] from JSON.
  factory AdminOrganizationInvite.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'AdminOrganizationInvite: missing created_at',
      );
    }
    if (json['email'] == null) {
      throw const FormatException('AdminOrganizationInvite: missing email');
    }
    if (json['expired'] == null) {
      throw const FormatException('AdminOrganizationInvite: missing expired');
    }
    if (json['raw_role'] == null) {
      throw const FormatException('AdminOrganizationInvite: missing raw_role');
    }
    if (json['raw_roles'] == null) {
      throw const FormatException('AdminOrganizationInvite: missing raw_roles');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminOrganizationInvite: missing uuid');
    }
    return AdminOrganizationInvite(
      createdAt: json['created_at'] as String,
      email: json['email'] as String,
      expired: json['expired'] as bool,
      rawRole: json['raw_role'] as String,
      rawRoles: (json['raw_roles'] as List)
          .map((item) => item as String)
          .toList(),
      uuid: json['uuid'] as String,
      workspaceUuids: json['workspace_uuids'] == null
          ? null
          : (json['workspace_uuids'] as List)
                .map((item) => item as String)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'email': email,
    'expired': expired,
    'raw_role': rawRole,
    'raw_roles': rawRoles,
    'uuid': uuid,
    'workspace_uuids': ?workspaceUuids,
  };

  /// Creates a copy with the given fields replaced.
  AdminOrganizationInvite copyWith({
    String? createdAt,
    String? email,
    bool? expired,
    String? rawRole,
    List<String>? rawRoles,
    String? uuid,
    Object? workspaceUuids = unsetCopyWithValue,
  }) => AdminOrganizationInvite(
    createdAt: createdAt ?? this.createdAt,
    email: email ?? this.email,
    expired: expired ?? this.expired,
    rawRole: rawRole ?? this.rawRole,
    rawRoles: rawRoles ?? this.rawRoles,
    uuid: uuid ?? this.uuid,
    workspaceUuids: workspaceUuids == unsetCopyWithValue
        ? this.workspaceUuids
        : (workspaceUuids as List?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminOrganizationInvite &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          email == other.email &&
          expired == other.expired &&
          rawRole == other.rawRole &&
          valuesDeepEqual(rawRoles, other.rawRoles) &&
          uuid == other.uuid &&
          valuesDeepEqual(workspaceUuids, other.workspaceUuids);

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    email,
    expired,
    rawRole,
    valueDeepHashCode(rawRoles),
    uuid,
    valueDeepHashCode(workspaceUuids),
  ]);

  @override
  String toString() =>
      'AdminOrganizationInvite('
      'createdAt: $createdAt, '
      'email: $email, '
      'expired: $expired, '
      'rawRole: $rawRole, '
      'rawRoles: ${rawRoles.length}, '
      'uuid: $uuid, '
      'workspaceUuids: ${workspaceUuids?.length})';
}

/// Values for AdminPlanType.
enum AdminPlanType {
  /// Represents API.
  api('API'),

  /// Represents CHAT.
  chat('CHAT'),

  /// Represents ON_PREMISE.
  onPremise('ON_PREMISE'),

  /// Represents LICENSE.
  license('LICENSE'),

  /// Represents MISTRAL_CODE.
  mistralCode('MISTRAL_CODE'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminPlanType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminPlanType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminMemberStatus.
enum AdminMemberStatus {
  /// Represents active.
  active('active'),

  /// Represents deactivated.
  deactivated('deactivated'),

  /// Represents blocked.
  blocked('blocked'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminMemberStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminMemberStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Administrative member subscription.
@immutable
class AdminMemberSubscription {
  /// Creates a [AdminMemberSubscription].
  const AdminMemberSubscription({
    this.memberHasAccess,
    this.plan,
    this.selfService,
    this.status,
    required this.type,
    this.user,
  });

  /// Whether the member currently has access to the plan.
  final bool? memberHasAccess;

  /// Plan assigned to the member.
  final Object? plan;

  /// Whether the subscription was created through self-service.
  final bool? selfService;

  /// Current status of the member subscription.
  final AdminSubscriptionStatus? status;

  /// Type of subscription assigned to the member.
  final AdminPlanType type;

  /// User ID associated with the subscription.
  final String? user;

  /// Parses a [AdminMemberSubscription] from JSON.
  factory AdminMemberSubscription.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      throw const FormatException('AdminMemberSubscription: missing type');
    }
    return AdminMemberSubscription(
      memberHasAccess: json['member_has_access'] == null
          ? null
          : json['member_has_access'] as bool,
      plan: json['plan'],
      selfService: json['self_service'] == null
          ? null
          : json['self_service'] as bool,
      status: json['status'] == null
          ? null
          : AdminSubscriptionStatus.fromJson(json['status'] as String),
      type: AdminPlanType.fromJson(json['type'] as String),
      user: json['user'] == null ? null : json['user'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'member_has_access': ?memberHasAccess,
    'plan': ?plan,
    'self_service': ?selfService,
    if (status != null) 'status': status!.toJson(),
    'type': type.toJson(),
    'user': ?user,
  };

  /// Creates a copy with the given fields replaced.
  AdminMemberSubscription copyWith({
    Object? memberHasAccess = unsetCopyWithValue,
    Object? plan = unsetCopyWithValue,
    Object? selfService = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    AdminPlanType? type,
    Object? user = unsetCopyWithValue,
  }) => AdminMemberSubscription(
    memberHasAccess: memberHasAccess == unsetCopyWithValue
        ? this.memberHasAccess
        : memberHasAccess as bool?,
    plan: plan == unsetCopyWithValue ? this.plan : plan,
    selfService: selfService == unsetCopyWithValue
        ? this.selfService
        : selfService as bool?,
    status: status == unsetCopyWithValue
        ? this.status
        : status as AdminSubscriptionStatus?,
    type: type ?? this.type,
    user: user == unsetCopyWithValue ? this.user : user as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminMemberSubscription &&
          runtimeType == other.runtimeType &&
          memberHasAccess == other.memberHasAccess &&
          valuesDeepEqual(plan, other.plan) &&
          selfService == other.selfService &&
          status == other.status &&
          type == other.type &&
          user == other.user;

  @override
  int get hashCode => Object.hashAll([
    memberHasAccess,
    valueDeepHashCode(plan),
    selfService,
    status,
    type,
    user,
  ]);

  @override
  String toString() =>
      'AdminMemberSubscription('
      'memberHasAccess: $memberHasAccess, '
      'plan: $plan, '
      'selfService: $selfService, '
      'status: $status, '
      'type: $type, '
      'user: $user)';
}

/// Administrative member workspace.
@immutable
class AdminMemberWorkspace {
  /// Creates a [AdminMemberWorkspace].
  const AdminMemberWorkspace({
    required this.isDefault,
    required this.name,
    required this.rawRole,
    required this.rawRoles,
    required this.uuid,
  });

  /// Whether this is the default Workspace for the Organization.
  final bool isDefault;

  /// Workspace name.
  final String name;

  /// Deprecated single workspace role. Use 'raw_roles' instead.
  final String rawRole;

  /// Workspace roles assigned to the member.
  final List<String> rawRoles;

  /// Workspace ID.
  final String uuid;

  /// Parses a [AdminMemberWorkspace] from JSON.
  factory AdminMemberWorkspace.fromJson(Map<String, dynamic> json) {
    if (json['is_default'] == null) {
      throw const FormatException('AdminMemberWorkspace: missing is_default');
    }
    if (json['name'] == null) {
      throw const FormatException('AdminMemberWorkspace: missing name');
    }
    if (json['raw_role'] == null) {
      throw const FormatException('AdminMemberWorkspace: missing raw_role');
    }
    if (json['raw_roles'] == null) {
      throw const FormatException('AdminMemberWorkspace: missing raw_roles');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminMemberWorkspace: missing uuid');
    }
    return AdminMemberWorkspace(
      isDefault: json['is_default'] as bool,
      name: json['name'] as String,
      rawRole: json['raw_role'] as String,
      rawRoles: (json['raw_roles'] as List)
          .map((item) => item as String)
          .toList(),
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'is_default': isDefault,
    'name': name,
    'raw_role': rawRole,
    'raw_roles': rawRoles,
    'uuid': uuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminMemberWorkspace copyWith({
    bool? isDefault,
    String? name,
    String? rawRole,
    List<String>? rawRoles,
    String? uuid,
  }) => AdminMemberWorkspace(
    isDefault: isDefault ?? this.isDefault,
    name: name ?? this.name,
    rawRole: rawRole ?? this.rawRole,
    rawRoles: rawRoles ?? this.rawRoles,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminMemberWorkspace &&
          runtimeType == other.runtimeType &&
          isDefault == other.isDefault &&
          name == other.name &&
          rawRole == other.rawRole &&
          valuesDeepEqual(rawRoles, other.rawRoles) &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([
    isDefault,
    name,
    rawRole,
    valueDeepHashCode(rawRoles),
    uuid,
  ]);

  @override
  String toString() =>
      'AdminMemberWorkspace('
      'isDefault: $isDefault, '
      'name: $name, '
      'rawRole: $rawRole, '
      'rawRoles: ${rawRoles.length}, '
      'uuid: $uuid)';
}

/// Values for AdminApiPlan.
enum AdminApiPlan {
  /// Represents FREE.
  free('FREE'),

  /// Represents PAY_AS_YOU_GO.
  payAsYouGo('PAY_AS_YOU_GO'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminApiPlan(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminApiPlan fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminChatPlan.
enum AdminChatPlan {
  /// Represents INDIVIDUAL.
  individual('INDIVIDUAL'),

  /// Represents EDU.
  edu('EDU'),

  /// Represents TEAM.
  team('TEAM'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminChatPlan(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminChatPlan fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminCodePlan.
enum AdminCodePlan {
  /// Represents ENTERPRISE.
  enterprise('ENTERPRISE'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminCodePlan(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminCodePlan fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminSubscriptionStatus.
enum AdminSubscriptionStatus {
  /// Represents NS.
  ns('NS'),

  /// Represents S.
  s('S'),

  /// Represents IC.
  ic('IC'),

  /// Represents A.
  a('A'),

  /// Represents CF.
  cf('CF'),

  /// Represents CG.
  cg('CG'),

  /// Represents C.
  c('C'),

  /// Represents PC.
  pc('PC'),

  /// Represents GP.
  gp('GP'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminSubscriptionStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminSubscriptionStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}
