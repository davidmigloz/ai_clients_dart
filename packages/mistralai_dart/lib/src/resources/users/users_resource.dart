import '../../models/users/user_identity.dart';
import '../../models/users/user_memberships.dart';
import '../../models/users/whoami_response.dart';
import '../base_resource.dart';
import '../platform_resource.dart';

/// Resource for authenticated caller identity and memberships (beta).
///
/// User routes accept a bearer credential or the x-api-key header. Set
/// `authInApiKeyHeader` to send the configured credential as an API key.
/// [whoami] also resolves service account principals.
class UsersResource extends ResourceBase with PlatformResource {
  /// Creates a [UsersResource].
  UsersResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Retrieves the currently authenticated user's profile.
  Future<UserIdentity> me({bool authInApiKeyHeader = false}) => requestPlatform(
    'GET',
    '/v1/users/me',
    (json) => UserIdentity.fromJson(json! as Map<String, dynamic>),
    authInApiKeyHeader: authInApiKeyHeader,
  );

  /// Retrieves the currently authenticated user or service account identity.
  Future<WhoamiResponse> whoami({bool authInApiKeyHeader = false}) =>
      requestPlatform(
        'GET',
        '/v1/whoami',
        (json) => WhoamiResponse.fromJson(json! as Map<String, dynamic>),
        authInApiKeyHeader: authInApiKeyHeader,
      );

  /// Lists organizations the authenticated user belongs to.
  ///
  /// [offset] skips organizations and [limit] sets the page size (1–100).
  Future<UserOrganizations> listOrganizations({
    int? offset,
    int? limit,
    bool authInApiKeyHeader = false,
  }) => requestPlatform(
    'GET',
    '/v1/users/me/organizations',
    (json) => UserOrganizations.fromJson(json! as Map<String, dynamic>),
    query: {'offset': ?offset?.toString(), 'limit': ?limit?.toString()},
    authInApiKeyHeader: authInApiKeyHeader,
  );

  /// Lists workspaces the authenticated user belongs to.
  ///
  /// Filter by [organizationId], or page across all organizations with
  /// [offset] and [limit]. [limit] accepts 1–100.
  Future<UserWorkspaces> listWorkspaces({
    String? organizationId,
    int? offset,
    int? limit,
    bool authInApiKeyHeader = false,
  }) => requestPlatform(
    'GET',
    '/v1/users/me/workspaces',
    (json) => UserWorkspaces.fromJson(json! as Map<String, dynamic>),
    query: {
      'organization_id': ?organizationId,
      'offset': ?offset?.toString(),
      'limit': ?limit?.toString(),
    },
    authInApiKeyHeader: authInApiKeyHeader,
  );
}
