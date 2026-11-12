import '../../models/common/copy_with_sentinel.dart';
import '../../models/organization/organization_page.dart';
import '../../models/organization/organization_records.dart';
import '../../models/organization/organization_workspace.dart';
import 'organization_service_accounts_resource.dart';
import 'organization_settings_resources.dart';
import 'organization_transport.dart';

/// Read and manage workspaces within an organization.
final class OrganizationWorkspacesResource {
  /// Creates the workspaces resource.
  OrganizationWorkspacesResource(this._transport)
    : members = OrganizationWorkspaceMembersResource(_transport),
      rateLimits = OrganizationWorkspaceRateLimitsResource(_transport),
      serviceAccounts = OrganizationWorkspaceServiceAccountsResource(
        _transport,
      );

  final OrganizationTransport _transport;

  /// Workspace rate-limit overrides.
  final OrganizationWorkspaceRateLimitsResource rateLimits;

  /// Service account memberships in a workspace.
  final OrganizationWorkspaceServiceAccountsResource serviceAccounts;

  /// Workspace membership operations.
  final OrganizationWorkspaceMembersResource members;

  /// Lists workspaces. Set [includeDefault] to retrieve the Default Workspace.
  Future<OrganizationPage<OrganizationWorkspace>> list({
    String? beforeId,
    String? afterId,
    int? limit,
    bool? includeArchived,
    bool? includeDefault,
    List<String> ids = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/workspaces',
    (json) => OrganizationPage.fromJson(json, OrganizationWorkspace.fromJson),
    query: {
      ...organizationPageQuery(beforeId, afterId, limit),
      'include_archived': ?includeArchived?.toString(),
      'include_default': ?includeDefault?.toString(),
      if (ids.isNotEmpty) 'ids[]': ids,
    },
    abortTrigger: abortTrigger,
  );

  /// Creates a workspace. The storage location can only be set at creation.
  Future<OrganizationWorkspace> create({
    required String name,
    String? displayColor,
    String? externalKeyId,
    String? userProfileId,
    Map<String, String>? tags,
    AllowedInferenceGeos? allowedInferenceGeos,
    String? defaultInferenceGeo,
    String? workspaceGeo,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/workspaces',
    OrganizationWorkspace.fromJson,
    body: {
      'name': name,
      'display_color': ?displayColor,
      'external_key_id': ?externalKeyId,
      'user_profile_id': ?userProfileId,
      'tags': ?tags,
      if (allowedInferenceGeos != null ||
          defaultInferenceGeo != null ||
          workspaceGeo != null)
        'data_residency': {
          'allowed_inference_geos': ?allowedInferenceGeos?.toJson(),
          'default_inference_geo': ?defaultInferenceGeo,
          'workspace_geo': ?workspaceGeo,
        },
    },
    abortTrigger: abortTrigger,
  );

  /// Retrieves a workspace.
  Future<OrganizationWorkspace> retrieve(
    String workspaceId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _workspace(workspaceId),
    OrganizationWorkspace.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Updates the supplied workspace properties.
  ///
  /// Omit [tags] to omit that field. Pass a string map or explicit null
  /// to send the corresponding tags value.
  Future<OrganizationWorkspace> update(
    String workspaceId, {
    String? name,
    String? displayColor,
    String? externalKeyId,
    String? userProfileId,
    Object? tags = unsetCopyWithValue,
    AllowedInferenceGeos? allowedInferenceGeos,
    String? defaultInferenceGeo,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _workspace(workspaceId),
    OrganizationWorkspace.fromJson,
    body: {
      'name': ?name,
      'display_color': ?displayColor,
      'external_key_id': ?externalKeyId,
      'user_profile_id': ?userProfileId,
      if (tags != unsetCopyWithValue)
        'tags': tags == null ? null : Map<String, String?>.from(tags as Map),
      if (allowedInferenceGeos != null || defaultInferenceGeo != null)
        'data_residency': {
          'allowed_inference_geos': ?allowedInferenceGeos?.toJson(),
          'default_inference_geo': ?defaultInferenceGeo,
        },
    },
    abortTrigger: abortTrigger,
  );

  /// Archives a workspace.
  Future<OrganizationWorkspace> archive(
    String workspaceId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_workspace(workspaceId)}/archive',
    OrganizationWorkspace.fromJson,
    abortTrigger: abortTrigger,
  );
}

/// Read and manage membership of a workspace.
final class OrganizationWorkspaceMembersResource {
  /// Creates the workspace membership resource.
  const OrganizationWorkspaceMembersResource(this._transport);
  final OrganizationTransport _transport;

  /// Lists members in a workspace.
  Future<OrganizationPage<OrganizationWorkspaceMember>> list(
    String workspaceId, {
    String? beforeId,
    String? afterId,
    int? limit,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '${_workspace(workspaceId)}/members',
    (json) =>
        OrganizationPage.fromJson(json, OrganizationWorkspaceMember.fromJson),
    query: organizationPageQuery(beforeId, afterId, limit),
    abortTrigger: abortTrigger,
  );

  /// Adds a member. The create operation excludes the workspace billing role.
  Future<OrganizationWorkspaceMember> create(
    String workspaceId, {
    required String userId,
    required String workspaceRole,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_workspace(workspaceId)}/members',
    OrganizationWorkspaceMember.fromJson,
    body: {'user_id': userId, 'workspace_role': workspaceRole},
    abortTrigger: abortTrigger,
  );

  /// Retrieves a workspace member.
  Future<OrganizationWorkspaceMember> retrieve(
    String workspaceId,
    String userId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _member(workspaceId, userId),
    OrganizationWorkspaceMember.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Updates a member's workspace role.
  Future<OrganizationWorkspaceMember> update(
    String workspaceId,
    String userId, {
    required String workspaceRole,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _member(workspaceId, userId),
    OrganizationWorkspaceMember.fromJson,
    body: {'workspace_role': workspaceRole},
    abortTrigger: abortTrigger,
  );

  /// Removes a user from this workspace.
  Future<DeletedOrganizationWorkspaceMember> delete(
    String workspaceId,
    String userId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _member(workspaceId, userId),
    DeletedOrganizationWorkspaceMember.fromJson,
    abortTrigger: abortTrigger,
  );
}

String _workspace(String workspaceId) =>
    '/workspaces/${organizationIdSegment(workspaceId, 'workspaceId')}';

String _member(String workspaceId, String userId) =>
    '${_workspace(workspaceId)}/members/${organizationIdSegment(userId, 'userId')}';
