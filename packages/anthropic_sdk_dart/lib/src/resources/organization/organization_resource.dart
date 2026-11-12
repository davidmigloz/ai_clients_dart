import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import '../../models/organization/organization_records.dart';
import 'organization_access_resources.dart';
import 'organization_analytics_resource.dart';
import 'organization_external_keys_resource.dart';
import 'organization_federation_resource.dart';
import 'organization_rbac_resources.dart';
import 'organization_service_accounts_resource.dart';
import 'organization_settings_resources.dart';
import 'organization_spend_resources.dart';
import 'organization_telemetry_destinations_resource.dart';
import 'organization_transport.dart';
import 'organization_webhooks_resource.dart';
import 'organization_workspaces_resource.dart';

/// Organization-scoped Claude Admin API operations.
///
/// Use an Admin API key or another credential with the documented scope.
final class OrganizationResource {
  /// Creates an organization resource on the shared client transport.
  OrganizationResource({
    required RequestBuilder requestBuilder,
    required InterceptorChain interceptorChain,
    void Function()? ensureNotClosed,
  }) : this._(
         OrganizationTransport(
           requestBuilder: requestBuilder,
           interceptorChain: interceptorChain,
           ensureNotClosed: ensureNotClosed,
         ),
       );

  OrganizationResource._(this._transport)
    : apiKeys = OrganizationApiKeysResource(_transport),
      invites = OrganizationInvitesResource(_transport),
      users = OrganizationUsersResource(_transport),
      workspaces = OrganizationWorkspacesResource(_transport),
      rateLimits = OrganizationRateLimitsResource(_transport),
      rbacGroups = OrganizationRbacGroupsResource(_transport),
      rbacRoles = OrganizationRbacRolesResource(_transport),
      spendLimits = OrganizationSpendLimitsResource(_transport),
      webhooks = OrganizationWebhooksResource(_transport),
      telemetryDestinations = OrganizationTelemetryDestinationsResource(
        _transport,
      ),
      complianceSettings = OrganizationComplianceSettingsResource(_transport),
      federation = OrganizationFederationResource(_transport),
      serviceAccounts = OrganizationServiceAccountsResource(_transport),
      externalKeys = OrganizationExternalKeysResource(_transport),
      analytics = OrganizationAnalyticsResource(_transport);

  final OrganizationTransport _transport;

  /// API key metadata and lifecycle.
  final OrganizationApiKeysResource apiKeys;

  /// Organization invitations.
  final OrganizationInvitesResource invites;

  /// Organization membership.
  final OrganizationUsersResource users;

  /// Organization rate limits.
  final OrganizationRateLimitsResource rateLimits;

  /// Organization compliance settings.
  final OrganizationComplianceSettingsResource complianceSettings;

  /// Workload Identity Federation configuration.
  final OrganizationFederationResource federation;

  /// Service accounts and their workspace memberships.
  final OrganizationServiceAccountsResource serviceAccounts;

  /// Customer-managed encryption keys.
  final OrganizationExternalKeysResource externalKeys;

  /// Organization usage and cost reports.
  final OrganizationAnalyticsResource analytics;

  /// Role-based access groups and their members.
  final OrganizationRbacGroupsResource rbacGroups;

  /// Custom roles and permissions.
  final OrganizationRbacRolesResource rbacRoles;

  /// Configured and effective spend limits and increase requests.
  final OrganizationSpendLimitsResource spendLimits;

  /// Server-side OpenTelemetry destinations.
  final OrganizationTelemetryDestinationsResource telemetryDestinations;

  /// Organization webhook subscriptions and signing secret rotation.
  final OrganizationWebhooksResource webhooks;

  /// Workspaces and workspace membership.
  final OrganizationWorkspacesResource workspaces;

  /// Retrieves the organization associated with the credential.
  Future<OrganizationInfo> retrieve({Future<void>? abortTrigger}) =>
      _transport.send(
        'GET',
        '/me',
        OrganizationInfo.fromJson,
        abortTrigger: abortTrigger,
      );
}
