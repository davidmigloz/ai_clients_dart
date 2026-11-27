import '../../models/admin/admin_users.dart';
import 'admin_transport.dart';

/// Administrative users operations.
class AdminUsersResource {
  /// Creates the users resource.
  const AdminUsersResource(this._transport);

  final AdminTransport _transport;

  /// Get Users.
  Future<AdminOrganizationUsersPage> list({
    int? page,
    int? pageSize,
    String? email,
    bool? includeInactive,
  }) => _transport.json(
    'GET',
    '/v1/admin/users',
    AdminOrganizationUsersPage.fromJson,
    query: {
      'page': ?page?.toString(),
      'page_size': ?pageSize?.toString(),
      'email': ?email,
      'include_inactive': ?includeInactive?.toString(),
    },
  );

  /// Create Users.
  Future<CreateAdminUserResponse> create({
    required List<CreateAdminUserRequest> request,
  }) => _transport.json(
    'POST',
    '/v1/admin/users',
    CreateAdminUserResponse.fromJson,
    body: request.map((item) => item.toJson()).toList(),
  );

  /// Get Invite.
  Future<List<AdminUserInvite>> listInvites() => _transport.list(
    'GET',
    '/v1/admin/users-invite',
    AdminUserInvite.fromJson,
  );

  /// Invite Users.
  Future<InviteAdminUserResponse> invite({
    required InviteAdminUserRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/users-invite',
    InviteAdminUserResponse.fromJson,
    body: request.toJson(),
  );

  /// Delete Invite.
  Future<AdminDeleteResult> deleteInvite({required String inviteUuid}) =>
      _transport.json(
        'DELETE',
        '/v1/admin/users-invite/${Uri.encodeComponent(inviteUuid)}',
        AdminDeleteResult.fromJson,
      );

  /// Delete User.
  Future<AdminDeleteResult> delete({required String userId}) => _transport.json(
    'DELETE',
    '/v1/admin/users/${Uri.encodeComponent(userId)}',
    AdminDeleteResult.fromJson,
  );

  /// Get User.
  Future<AdminUser> get({required String userId}) => _transport.json(
    'GET',
    '/v1/admin/users/${Uri.encodeComponent(userId)}',
    AdminUser.fromJson,
  );

  /// Update User.
  Future<AdminOrganizationMember> update({
    required String userId,
    required UpdateAdminUserRequest request,
  }) => _transport.json(
    'PATCH',
    '/v1/admin/users/${Uri.encodeComponent(userId)}',
    AdminOrganizationMember.fromJson,
    body: request.toJson(),
  );

  /// Deactivate User.
  Future<AdminDeactivateUserResult> deactivate({required String userId}) =>
      _transport.json(
        'POST',
        '/v1/admin/users/${Uri.encodeComponent(userId)}/deactivate',
        AdminDeactivateUserResult.fromJson,
      );

  /// Reactivate User.
  Future<AdminReactivateUserResult> reactivate({required String userId}) =>
      _transport.json(
        'POST',
        '/v1/admin/users/${Uri.encodeComponent(userId)}/reactivate',
        AdminReactivateUserResult.fromJson,
      );

  /// Get User Workspaces.
  Future<AdminUserWorkspacesPage> listWorkspaces({
    required String userId,
    int? page,
    int? pageSize,
  }) => _transport.json(
    'GET',
    '/v1/admin/users/${Uri.encodeComponent(userId)}/workspaces',
    AdminUserWorkspacesPage.fromJson,
    query: {'page': ?page?.toString(), 'page_size': ?pageSize?.toString()},
  );
}
