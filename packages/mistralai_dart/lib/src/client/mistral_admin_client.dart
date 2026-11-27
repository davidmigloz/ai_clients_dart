import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../resources/admin/admin_api_keys_resource.dart';
import '../resources/admin/admin_audit_logs_resource.dart';
import '../resources/admin/admin_groups_resource.dart';
import '../resources/admin/admin_roles_resource.dart';
import '../resources/admin/admin_scim_resource.dart';
import '../resources/admin/admin_transport.dart';
import '../resources/admin/admin_usage_resource.dart';
import '../resources/admin/admin_users_resource.dart';
import '../resources/admin/admin_vibe_analytics_resource.dart';
import '../resources/admin/admin_workspaces_resource.dart';
import 'mistral_client.dart';

/// Mistral's Enterprise Preview Admin API.
///
/// Use an organization Admin API key from the Mistral Admin Panel. This
/// client sends it through `x-api-key` only on its Admin routes. Use
/// [MistralClient] with a workspace API key for inference.
class MistralAdminClient {
  /// Creates a client with a dedicated organization Admin API key.
  MistralAdminClient.withApiKey(
    String apiKey, {
    String baseUrl = 'https://api.mistral.ai',
    Duration timeout = const Duration(minutes: 5),
    Level logLevel = Level.OFF,
    http.Client? httpClient,
  }) : _transport = AdminTransport(
         apiKey: apiKey,
         baseUrl: baseUrl,
         timeout: timeout,
         logLevel: logLevel,
         httpClient: httpClient,
       );

  final AdminTransport _transport;

  /// Organization users, invitations, and subscriptions.
  late final AdminUsersResource users = AdminUsersResource(_transport);

  /// Organization groups and assignments.
  late final AdminGroupsResource groups = AdminGroupsResource(_transport);

  /// Workspaces and their members.
  late final AdminWorkspacesResource workspaces = AdminWorkspacesResource(
    _transport,
  );

  /// Organization and workspace roles.
  late final AdminRolesResource roles = AdminRolesResource(_transport);

  /// SCIM provisioning and synchronization runs.
  late final AdminScimResource scim = AdminScimResource(_transport);

  /// Workspace API keys owned by the organization.
  late final AdminApiKeysResource apiKeys = AdminApiKeysResource(_transport);

  /// Organization audit events.
  late final AdminAuditLogsResource auditLogs = AdminAuditLogsResource(
    _transport,
  );

  /// Organization billing usage, spend limits, and rate limits.
  late final AdminUsageResource usage = AdminUsageResource(_transport);

  /// Vibe Code and Vibe Work analytics.
  late final AdminVibeAnalyticsResource vibeAnalytics =
      AdminVibeAnalyticsResource(_transport);

  /// Closes the client. A supplied HTTP client remains owned by the caller.
  void close() => _transport.close();
}
