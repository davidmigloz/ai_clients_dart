import '../../models/organization/organization_api_key.dart';
import '../../models/organization/organization_page.dart';
import '../../models/organization/organization_records.dart';
import 'organization_transport.dart';

/// Organization roles assignable through the Admin API.
///
/// The allowed roles depend on the organization type and credential scopes.
enum AssignableOrganizationRole {
  /// Billing role.
  billing('billing'),

  /// Claude Code user role.
  claudeCodeUser('claude_code_user'),

  /// Developer role.
  developer('developer'),

  /// Managed member role for supported Claude Enterprise organizations.
  managed('managed'),

  /// User role.
  user('user');

  const AssignableOrganizationRole(this.wireValue);

  /// The role sent in a write request.
  final String wireValue;
}

/// Read and manage API key metadata within an organization.
final class OrganizationApiKeysResource {
  /// Creates the API keys resource.
  const OrganizationApiKeysResource(this._transport);
  final OrganizationTransport _transport;

  /// Lists API keys. [workspaceId] filters keys and is a query parameter.
  Future<OrganizationPage<OrganizationApiKey>> list({
    String? beforeId,
    String? afterId,
    int? limit,
    String? status,
    String? workspaceId,
    String? createdByUserId,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/api_keys',
    (json) => OrganizationPage.fromJson(json, OrganizationApiKey.fromJson),
    query: {
      ...organizationPageQuery(beforeId, afterId, limit),
      'status': ?status,
      'workspace_id': ?workspaceId,
      'created_by_user_id': ?createdByUserId,
    },
    abortTrigger: abortTrigger,
  );

  /// Retrieves API key metadata without retrieving its secret.
  Future<OrganizationApiKey> retrieve(
    String apiKeyId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/api_keys/${organizationIdSegment(apiKeyId, 'apiKeyId')}',
    OrganizationApiKey.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Updates an API key's name or status.
  Future<OrganizationApiKey> update(
    String apiKeyId, {
    String? name,
    OrganizationApiKeyStatus? status,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/api_keys/${organizationIdSegment(apiKeyId, 'apiKeyId')}',
    OrganizationApiKey.fromJson,
    body: {'name': ?name, 'status': ?status?.name},
    abortTrigger: abortTrigger,
  );
}

/// Read and manage organization members.
final class OrganizationUsersResource {
  /// Creates the members resource.
  const OrganizationUsersResource(this._transport);
  final OrganizationTransport _transport;

  /// Lists members filtered by email or any of [roles].
  Future<OrganizationPage<OrganizationUser>> list({
    String? beforeId,
    String? afterId,
    int? limit,
    String? email,
    List<String> roles = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/users',
    (json) => OrganizationPage.fromJson(json, OrganizationUser.fromJson),
    query: {
      ...organizationPageQuery(beforeId, afterId, limit),
      'email': ?email,
      if (roles.isNotEmpty) 'roles[]': roles,
    },
    abortTrigger: abortTrigger,
  );

  /// Retrieves an organization member.
  Future<OrganizationUser> retrieve(
    String userId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/users/${organizationIdSegment(userId, 'userId')}',
    OrganizationUser.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Updates an organization member's role.
  Future<OrganizationUser> update(
    String userId, {
    required AssignableOrganizationRole role,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/users/${organizationIdSegment(userId, 'userId')}',
    OrganizationUser.fromJson,
    body: {'role': role.wireValue},
    abortTrigger: abortTrigger,
  );

  /// Removes the member from the organization.
  Future<DeletedOrganizationUser> remove(
    String userId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    '/users/${organizationIdSegment(userId, 'userId')}',
    DeletedOrganizationUser.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Signs a member out of Claude everywhere without removing membership.
  ///
  /// This Claude Enterprise beta requires a key with `write:members`.
  /// A successful response returns the existing membership record.
  Future<OrganizationUser> signOut(
    String userId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/users/${organizationIdSegment(userId, 'userId')}/sign_out',
    OrganizationUser.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: 'admin-user-sign-out-2026-10-08',
    abortTrigger: abortTrigger,
  );
}

/// Read and manage organization invitations.
final class OrganizationInvitesResource {
  /// Creates the invitations resource.
  const OrganizationInvitesResource(this._transport);
  final OrganizationTransport _transport;

  /// Lists invitations. The API accepts repeated statuses and roles.
  Future<OrganizationPage<OrganizationInvite>> list({
    String? beforeId,
    String? afterId,
    int? limit,
    String? email,
    List<String> statuses = const [],
    List<String> roles = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/invites',
    (json) => OrganizationPage.fromJson(json, OrganizationInvite.fromJson),
    query: {
      ...organizationPageQuery(beforeId, afterId, limit),
      'email': ?email,
      if (statuses.isNotEmpty) 'statuses[]': statuses,
      if (roles.isNotEmpty) 'roles[]': roles,
    },
    abortTrigger: abortTrigger,
  );

  /// Invites an email address to join the organization.
  ///
  /// Nonempty [rbacGroupIds] require eligible Enterprise RBAC access and the
  /// appropriate write scope.
  Future<OrganizationInvite> create({
    required String email,
    required AssignableOrganizationRole role,
    List<String>? rbacGroupIds,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/invites',
    OrganizationInvite.fromJson,
    body: {
      'email': email,
      'role': role.wireValue,
      'rbac_group_ids': ?rbacGroupIds,
    },
    abortTrigger: abortTrigger,
  );

  /// Retrieves an invitation.
  Future<OrganizationInvite> retrieve(
    String inviteId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/invites/${organizationIdSegment(inviteId, 'inviteId')}',
    OrganizationInvite.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Deletes the invitation.
  Future<DeletedOrganizationInvite> delete(
    String inviteId, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    '/invites/${organizationIdSegment(inviteId, 'inviteId')}',
    DeletedOrganizationInvite.fromJson,
    abortTrigger: abortTrigger,
  );
}
