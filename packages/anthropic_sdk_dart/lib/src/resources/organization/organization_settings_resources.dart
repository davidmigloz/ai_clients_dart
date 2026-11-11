import '../../models/organization/organization_limits.dart';
import '../../models/organization/organization_page.dart';
import 'organization_transport.dart';

/// Organization-level Messages API rate limits.
final class OrganizationRateLimitsResource {
  /// Creates the organization rate-limits resource.
  const OrganizationRateLimitsResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists effective limits for the organization.
  Future<OrganizationCursorPage<OrganizationRateLimit>> list({
    String? groupType,
    String? model,
    int? limit,
    String? page,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/rate_limits',
    (json) =>
        OrganizationCursorPage.fromJson(json, OrganizationRateLimit.fromJson),
    query: {
      'group_type': ?groupType,
      'model': ?model,
      'limit': ?limit?.toString(),
      'page': ?page,
    },
    abortTrigger: abortTrigger,
  );
}

/// Workspace-specific rate-limit overrides.
final class OrganizationWorkspaceRateLimitsResource {
  /// Creates the workspace rate-limits resource.
  const OrganizationWorkspaceRateLimitsResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists workspace limits, optionally including inherited limits.
  Future<OrganizationCursorPage<OrganizationRateLimit>> list(
    String workspaceId, {
    String? groupType,
    bool? includeInherited,
    int? limit,
    String? page,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _path(workspaceId),
    (json) =>
        OrganizationCursorPage.fromJson(json, OrganizationRateLimit.fromJson),
    query: {
      'group_type': ?groupType,
      'include_inherited': ?includeInherited?.toString(),
      'limit': ?limit?.toString(),
      'page': ?page,
    },
    abortTrigger: abortTrigger,
  );

  /// Sets or clears the named workspace rate-limit overrides.
  Future<OrganizationRateLimit> update(
    String workspaceId,
    String rateLimitId, {
    required List<WorkspaceRateLimitUpdate> limits,
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_path(workspaceId)}/${organizationIdSegment(rateLimitId, 'rateLimitId')}',
    OrganizationRateLimit.fromJson,
    body: {'limits': limits.map((entry) => entry.toJson()).toList()},
    abortTrigger: abortTrigger,
  );

  static String _path(String workspaceId) =>
      '/workspaces/${organizationIdSegment(workspaceId, 'workspaceId')}/rate_limits';
}

/// Organization compliance settings exposed by the Admin API.
final class OrganizationComplianceSettingsResource {
  /// Creates the settings resource.
  const OrganizationComplianceSettingsResource(this._transport);

  final OrganizationTransport _transport;

  /// Gets compliance settings for the organization.
  Future<OrganizationComplianceSettings> retrieve({
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/compliance_settings',
    OrganizationComplianceSettings.fromJson,
    abortTrigger: abortTrigger,
  );

  /// Changes the organization's compliance settings state.
  Future<OrganizationComplianceSettings> update(
    OrganizationComplianceState state, {
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '/compliance_settings',
    OrganizationComplianceSettings.fromJson,
    body: {
      'state': {'type': state.name},
    },
    abortTrigger: abortTrigger,
  );
}
