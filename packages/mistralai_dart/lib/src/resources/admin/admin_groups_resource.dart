import '../../models/admin/admin_groups.dart';
import 'admin_transport.dart';

/// Administrative groups operations.
class AdminGroupsResource {
  /// Creates the groups resource.
  const AdminGroupsResource(this._transport);

  final AdminTransport _transport;

  /// Get User Groups.
  Future<AdminUserGroupPage> list({
    int? page,
    int? pageSize,
    String? search,
    String? workspaceUuid,
    String? role,
  }) => _transport.json(
    'GET',
    '/v1/admin/user-groups',
    AdminUserGroupPage.fromJson,
    query: {
      'page': ?page?.toString(),
      'page_size': ?pageSize?.toString(),
      'search': ?search,
      'workspace_uuid': ?workspaceUuid,
      'role': ?role,
    },
  );

  /// Create User Group.
  Future<AdminUserGroup> create({
    required CreateAdminUserGroupRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/user-groups',
    AdminUserGroup.fromJson,
    body: request.toJson(),
  );

  /// Delete User Group.
  Future<void> delete({required String groupUuid}) => _transport.empty(
    'DELETE',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}',
  );

  /// Get User Group.
  Future<AdminUserGroup> get({required String groupUuid}) => _transport.json(
    'GET',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}',
    AdminUserGroup.fromJson,
  );

  /// Update User Group.
  Future<AdminUserGroup> update({
    required String groupUuid,
    required UpdateAdminUserGroupRequest request,
  }) => _transport.json(
    'PATCH',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}',
    AdminUserGroup.fromJson,
    body: request.toJson(),
  );

  /// Remove Users From Group.
  Future<void> removeUsers({
    required String groupUuid,
    required AdminGroupUsersRequest request,
  }) => _transport.empty(
    'DELETE',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/members',
    body: request.toJson(),
  );

  /// Get User Group Members.
  Future<AdminUserGroupMembersPage> listUsers({
    required String groupUuid,
    int? page,
    int? pageSize,
  }) => _transport.json(
    'GET',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/members',
    AdminUserGroupMembersPage.fromJson,
    query: {'page': ?page?.toString(), 'page_size': ?pageSize?.toString()},
  );

  /// Assign Users To Group.
  Future<void> addUsers({
    required String groupUuid,
    required AdminGroupUsersRequest request,
  }) => _transport.empty(
    'POST',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/members',
    body: request.toJson(),
  );

  /// Update User Group Organization Role.
  Future<void> setOrganizationRole({
    required String groupUuid,
    required SetAdminGroupOrganizationRoleRequest request,
  }) => _transport.empty(
    'PATCH',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/organization-role',
    body: request.toJson(),
  );

  /// Get Group Workspace Assignments.
  Future<AdminGroupWorkspaceAssignmentPage> listWorkspaceAssignments({
    required String groupUuid,
    int? page,
    int? pageSize,
  }) => _transport.json(
    'GET',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/workspaces',
    AdminGroupWorkspaceAssignmentPage.fromJson,
    query: {'page': ?page?.toString(), 'page_size': ?pageSize?.toString()},
  );

  /// Assign Group To Workspace.
  Future<void> assignWorkspace({
    required String groupUuid,
    required AssignAdminGroupWorkspaceRequest request,
  }) => _transport.empty(
    'POST',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/workspaces',
    body: request.toJson(),
  );

  /// Remove Group From Workspace.
  Future<void> removeWorkspace({
    required String groupUuid,
    required String workspaceUuid,
  }) => _transport.empty(
    'DELETE',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/workspaces/${Uri.encodeComponent(workspaceUuid)}',
  );

  /// Update Group Workspace Assignment.
  Future<void> updateWorkspaceAssignment({
    required String groupUuid,
    required String workspaceUuid,
    required UpdateAdminGroupWorkspaceRequest request,
  }) => _transport.empty(
    'PATCH',
    '/v1/admin/user-groups/${Uri.encodeComponent(groupUuid)}/workspaces/${Uri.encodeComponent(workspaceUuid)}',
    body: request.toJson(),
  );
}
