import '../../models/admin/admin_workspaces.dart';
import 'admin_transport.dart';

/// Administrative workspaces operations.
class AdminWorkspacesResource {
  /// Creates the workspaces resource.
  const AdminWorkspacesResource(this._transport);

  final AdminTransport _transport;

  /// Get Workspaces.
  Future<AdminWorkspacesPage> list({
    bool? isArchived,
    int? page,
    int? pageSize,
    String? search,
  }) => _transport.json(
    'GET',
    '/v1/admin/workspaces',
    AdminWorkspacesPage.fromJson,
    query: {
      'is_archived': ?isArchived?.toString(),
      'page': ?page?.toString(),
      'page_size': ?pageSize?.toString(),
      'search': ?search,
    },
  );

  /// Create Workspace.
  Future<AdminCreatedWorkspace> create({
    required CreateAdminWorkspaceRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/workspaces',
    AdminCreatedWorkspace.fromJson,
    body: request.toJson(),
  );

  /// Delete Workspaces.
  Future<void> delete({required String workspaceUuid}) => _transport.empty(
    'DELETE',
    '/v1/admin/workspaces/${Uri.encodeComponent(workspaceUuid)}',
  );

  /// Update Workspaces.
  Future<AdminWorkspace> update({
    required String workspaceUuid,
    required UpdateAdminWorkspaceRequest request,
  }) => _transport.json(
    'PATCH',
    '/v1/admin/workspaces/${Uri.encodeComponent(workspaceUuid)}',
    AdminWorkspace.fromJson,
    body: request.toJson(),
  );

  /// Add Users Workspaces.
  Future<AddAdminWorkspaceUsersResult> addUsers({
    required String workspaceUuid,
    required AddAdminWorkspaceUsersRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/workspaces/${Uri.encodeComponent(workspaceUuid)}/add-users',
    AddAdminWorkspaceUsersResult.fromJson,
    body: request.toJson(),
  );

  /// Remove Users Workspaces.
  Future<RemoveAdminWorkspaceUsersResult> removeUsers({
    required String workspaceUuid,
    required RemoveAdminWorkspaceUsersRequest request,
  }) => _transport.json(
    'DELETE',
    '/v1/admin/workspaces/${Uri.encodeComponent(workspaceUuid)}/remove-users',
    RemoveAdminWorkspaceUsersResult.fromJson,
    body: request.toJson(),
  );

  /// List Workspace Users.
  Future<AdminWorkspaceUsersPage> listUsers({
    required String workspaceUuid,
    int? page,
    int? pageSize,
    bool? includeInactive,
  }) => _transport.json(
    'GET',
    '/v1/admin/workspaces/${Uri.encodeComponent(workspaceUuid)}/users',
    AdminWorkspaceUsersPage.fromJson,
    query: {
      'page': ?page?.toString(),
      'page_size': ?pageSize?.toString(),
      'include_inactive': ?includeInactive?.toString(),
    },
  );

  /// Add Or Update Users Workspaces.
  Future<UpsertAdminWorkspaceUsersResult> upsertUsers({
    required String workspaceUuid,
    required UpsertAdminWorkspaceUsersRequest request,
  }) => _transport.json(
    'PATCH',
    '/v1/admin/workspaces/${Uri.encodeComponent(workspaceUuid)}/users',
    UpsertAdminWorkspaceUsersResult.fromJson,
    body: request.toJson(),
  );
}
