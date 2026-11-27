import '../../models/service_accounts/service_account.dart';
import '../../models/service_accounts/update_service_account_request.dart';
import '../base_resource.dart';
import '../platform_resource.dart';

/// Manages workspace service accounts and their roles (beta).
class ServiceAccountsResource extends ResourceBase with PlatformResource {
  /// Creates a [ServiceAccountsResource].
  ServiceAccountsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _path = '/v1/service-accounts';

  String _account(String id) => '$_path/${Uri.encodeComponent(id)}';

  /// Lists service accounts with optional workspace, name and paging filters.
  Future<ServiceAccountList> list({
    String? workspaceId,
    bool? includeDeleted,
    String? query,
    ServiceAccountSortOrder? order,
    int? offset,
    int? limit,
  }) => requestPlatform(
    'GET',
    _path,
    (json) => ServiceAccountList.fromJson(json! as Map<String, dynamic>),
    query: {
      'workspace_id': ?workspaceId,
      'include_deleted': ?includeDeleted?.toString(),
      'q': ?query,
      'order': ?order?.value,
      'offset': ?offset?.toString(),
      'limit': ?limit?.toString(),
    },
  );

  /// Creates a service account in the requested workspace.
  Future<ServiceAccount> create({
    required CreateServiceAccountRequest request,
  }) => requestPlatform(
    'POST',
    _path,
    (json) => ServiceAccount.fromJson(json! as Map<String, dynamic>),
    body: request.toJson(),
  );

  /// Retrieves a service account.
  Future<ServiceAccount> get({required String serviceAccountId}) =>
      requestPlatform(
        'GET',
        _account(serviceAccountId),
        (json) => ServiceAccount.fromJson(json! as Map<String, dynamic>),
      );

  /// Updates a service account's description.
  Future<ServiceAccount> update({
    required String serviceAccountId,
    required UpdateServiceAccountRequest request,
  }) => requestPlatform(
    'PATCH',
    _account(serviceAccountId),
    (json) => ServiceAccount.fromJson(json! as Map<String, dynamic>),
    body: request.toJson(),
  );

  /// Deletes a service account.
  Future<void> delete({required String serviceAccountId}) =>
      requestPlatform('DELETE', _account(serviceAccountId), (_) {});

  /// Lists roles that may be assigned within the specified workspace.
  Future<AssignableServiceAccountRoles> listAssignableRoles({
    required String workspaceId,
  }) => requestPlatform(
    'GET',
    '$_path/assignable-roles',
    (json) =>
        AssignableServiceAccountRoles.fromJson(json! as Map<String, dynamic>),
    query: {'workspace_id': workspaceId},
  );

  /// Lists the current roles of a service account.
  Future<ServiceAccountRoles> listRoles({required String serviceAccountId}) =>
      requestPlatform(
        'GET',
        '${_account(serviceAccountId)}/roles',
        (json) => ServiceAccountRoles.fromJson(json! as Map<String, dynamic>),
      );

  /// Replaces the current role assignments with the supplied role IDs.
  Future<ServiceAccountRoles> setRoles({
    required String serviceAccountId,
    required SetServiceAccountRolesRequest request,
  }) => requestPlatform(
    'PUT',
    '${_account(serviceAccountId)}/roles',
    (json) => ServiceAccountRoles.fromJson(json! as Map<String, dynamic>),
    body: request.toJson(),
  );
}
