import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../resources/admin/organization_resource.dart';
import 'admin_config.dart';
import 'admin_http.dart';

/// Organization administration with an explicit, separate credential realm.
///
/// This bounded namespace exposes external keys/storage, project API-key updates
/// and Decisions usage. It has no inference resources and never reads project
/// API credentials. Redirects are disabled to avoid forwarding Admin tokens.
final class OpenAIAdminClient {
  /// Uses only [config]'s Admin credentials. An injected transport is borrowed.
  OpenAIAdminClient({
    required OpenAIAdminConfig config,
    http.Client? httpClient,
  }) : _http = AdminHttp(config, httpClient);

  /// Reads OPENAI_ADMIN_KEY, never OPENAI_API_KEY.
  factory OpenAIAdminClient.fromEnvironment({http.Client? httpClient}) =>
      OpenAIAdminClient(
        config: OpenAIAdminConfig.fromEnvironment(),
        httpClient: httpClient,
      );

  /// Convenience constructor for an explicitly supplied Admin API key.
  factory OpenAIAdminClient.withApiKey(
    String adminApiKey, {
    http.Client? httpClient,
  }) => OpenAIAdminClient(
    config: OpenAIAdminConfig(authProvider: ApiKeyProvider(adminApiKey)),
    httpClient: httpClient,
  );

  final AdminHttp _http;
  AdminOrganizationResource? _organization;

  /// The bounded organization administration namespace.
  AdminOrganizationResource get organization {
    _http.ensureOpen();
    return _organization ??= AdminOrganizationResource(_http);
  }

  /// Prevents further requests and closes only an internally owned HTTP client.
  void close() => _http.close();
}
