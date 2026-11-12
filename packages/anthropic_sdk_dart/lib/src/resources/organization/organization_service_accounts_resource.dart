import '../../models/common/copy_with_sentinel.dart';
import '../../models/organization/organization_page.dart';
import '../../models/organization/service_account.dart';
import 'organization_transport.dart';

/// Manages non-human organization identities and their federation memberships.
///
/// Use an OAuth token with `org:admin`. An interactive token is required to
/// create an admin account or assign the admin organization role.
final class OrganizationServiceAccountsResource {
  /// Creates the service accounts resource.
  OrganizationServiceAccountsResource(this._transport)
    : workspaces = OrganizationServiceAccountWorkspacesResource(_transport);

  final OrganizationTransport _transport;

  /// Workspaces in which a specific service account is a member.
  final OrganizationServiceAccountWorkspacesResource workspaces;

  /// Lists service accounts with an opaque page token.
  Future<OrganizationCursorPage<ServiceAccount>> list({
    String? page,
    int? limit,
    bool? includeArchived,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/service_accounts',
    (json) => OrganizationCursorPage.fromJson(json, ServiceAccount.fromJson),
    query: {
      ..._pageQuery(page, limit),
      'include_archived': ?includeArchived?.toString(),
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Creates a service account. The default organization role is developer.
  Future<ServiceAccount> create({
    required String name,
    String? description,
    ServiceAccountRole? organizationRole,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/service_accounts',
    ServiceAccount.fromJson,
    body: {
      'name': name,
      'description': ?description,
      'organization_role': ?organizationRole?.name,
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Retrieves a service account.
  Future<ServiceAccount> retrieve(
    String serviceAccountId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _accountPath(serviceAccountId),
    ServiceAccount.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Updates the description and role. Pass null to clear [description].
  Future<ServiceAccount> update(
    String serviceAccountId, {
    Object? description = unsetCopyWithValue,
    ServiceAccountRole? organizationRole,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _accountPath(serviceAccountId),
    ServiceAccount.fromJson,
    body: {
      if (!identical(description, unsetCopyWithValue))
        'description': description as String?,
      'organization_role': ?organizationRole?.name,
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Archives a service account and prevents future use by federation rules.
  Future<ServiceAccount> archive(
    String serviceAccountId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_accountPath(serviceAccountId)}/archive',
    ServiceAccount.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );
}

/// Service account membership viewed from the service account.
///
/// Use an OAuth token with `org:admin`.
final class OrganizationServiceAccountWorkspacesResource {
  /// Creates the service account workspace membership resource.
  const OrganizationServiceAccountWorkspacesResource(this._transport);
  final OrganizationTransport _transport;

  /// Lists memberships, including the implicit Default Workspace membership.
  Future<OrganizationCursorPage<ServiceAccountWorkspaceMember>> list(
    String serviceAccountId, {
    String? page,
    int? limit,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '${_accountPath(serviceAccountId)}/workspaces',
    _membershipPage,
    query: _pageQuery(page, limit),
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Adds the account to a workspace with an explicit role.
  Future<ServiceAccountWorkspaceMember> add(
    String serviceAccountId, {
    required String workspaceId,
    required ServiceAccountWorkspaceRole workspaceRole,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_accountPath(serviceAccountId)}/workspaces',
    ServiceAccountWorkspaceMember.fromJson,
    body: {
      'workspace_id': workspaceId,
      'workspace_role': workspaceRole.wireValue,
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Removes an explicit workspace membership. The implicit one is a no-op.
  Future<DeletedServiceAccountWorkspaceMember> remove(
    String serviceAccountId,
    String workspaceId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    '${_accountPath(serviceAccountId)}/workspaces/${_workspaceId(workspaceId)}',
    DeletedServiceAccountWorkspaceMember.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );
}

/// Service account membership viewed from a workspace.
///
/// Use an OAuth token with `org:admin`.
final class OrganizationWorkspaceServiceAccountsResource {
  /// Creates the workspace's service accounts resource.
  const OrganizationWorkspaceServiceAccountsResource(this._transport);
  final OrganizationTransport _transport;

  /// Lists service accounts in a workspace.
  Future<OrganizationCursorPage<ServiceAccountWorkspaceMember>> list(
    String workspaceId, {
    String? page,
    int? limit,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _workspaceAccountsPath(workspaceId),
    _membershipPage,
    query: _pageQuery(page, limit),
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Adds a service account to a workspace.
  Future<ServiceAccountWorkspaceMember> create(
    String workspaceId, {
    required String serviceAccountId,
    required ServiceAccountWorkspaceRole workspaceRole,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _workspaceAccountsPath(workspaceId),
    ServiceAccountWorkspaceMember.fromJson,
    body: {
      'service_account_id': serviceAccountId,
      'workspace_role': workspaceRole.wireValue,
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Retrieves a workspace membership.
  Future<ServiceAccountWorkspaceMember> retrieve(
    String workspaceId,
    String serviceAccountId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _membershipPath(workspaceId, serviceAccountId),
    ServiceAccountWorkspaceMember.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Changes the workspace role of a service account.
  Future<ServiceAccountWorkspaceMember> update(
    String workspaceId,
    String serviceAccountId, {
    required ServiceAccountWorkspaceRole workspaceRole,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _membershipPath(workspaceId, serviceAccountId),
    ServiceAccountWorkspaceMember.fromJson,
    body: {'workspace_role': workspaceRole.wireValue},
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Removes an explicit membership. The implicit one is a no-op.
  Future<DeletedServiceAccountWorkspaceMember> delete(
    String workspaceId,
    String serviceAccountId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _membershipPath(workspaceId, serviceAccountId),
    DeletedServiceAccountWorkspaceMember.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );
}

Map<String, dynamic> _pageQuery(String? page, int? limit) => {
  'page': ?page,
  'limit': ?limit?.toString(),
};

OrganizationCursorPage<ServiceAccountWorkspaceMember> _membershipPage(
  Map<String, dynamic> json,
) => OrganizationCursorPage.fromJson(
  json,
  ServiceAccountWorkspaceMember.fromJson,
);

String _accountId(String id) => organizationIdSegment(id, 'serviceAccountId');
String _workspaceId(String id) => organizationIdSegment(id, 'workspaceId');
String _accountPath(String id) => '/service_accounts/${_accountId(id)}';
String _workspaceAccountsPath(String workspaceId) =>
    '/workspaces/${_workspaceId(workspaceId)}/service_accounts';
String _membershipPath(String workspaceId, String serviceAccountId) =>
    '${_workspaceAccountsPath(workspaceId)}/${_accountId(serviceAccountId)}';
String? _beta(List<String> values) => values.isEmpty ? null : values.join(',');
