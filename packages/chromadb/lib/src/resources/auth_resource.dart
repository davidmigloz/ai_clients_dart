import 'package:http/http.dart' as http;

import '../models/auth/user_identity.dart';
import 'base_resource.dart';

/// Resource for authentication endpoints.
///
/// This resource provides methods for authentication-related operations,
/// such as getting the current user's identity.
///
/// Example:
/// ```dart
/// final client = ChromaClient.withApiKey('your-api-key');
///
/// // Get current user identity
/// final identity = await client.auth.identity();
/// print('User: ${identity.userId}');
/// print('Tenant: ${identity.tenant}');
/// print('Databases: ${identity.databases}');
/// ```
class AuthResource extends ResourceBase {
  /// Creates an auth resource.
  AuthResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets the current user's identity.
  ///
  /// Returns information about the authenticated user, including their
  /// user ID, tenant, and accessible databases.
  ///
  /// Requires authentication to be configured on the client.
  ///
  /// Endpoint: `GET /api/v2/auth/identity`
  Future<UserIdentity> identity() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/api/v2/auth/identity');
    final headers = requestBuilder.buildHeaders(null);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return UserIdentity.fromJson(parseJson(response));
  }
}
