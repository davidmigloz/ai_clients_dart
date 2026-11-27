import '../../models/admin/admin_vibe_analytics.dart';
import 'admin_transport.dart';

/// Admin Vibe Code and Vibe Work analytics.
class AdminVibeAnalyticsResource {
  /// Creates the Vibe analytics resource.
  const AdminVibeAnalyticsResource(this._transport);

  final AdminTransport _transport;

  /// Usage by organization.
  Future<VibeCodeOrganizationUsage> getCodeByOrganization({
    required int startTime,
    required int endTime,
  }) => _transport.json(
    'GET',
    '/v1/admin/analytics/vibe/code/usage/by_organization',
    VibeCodeOrganizationUsage.fromJson,
    query: {'start_time': startTime.toString(), 'end_time': endTime.toString()},
  );

  /// Usage by workspace.
  Future<VibeCodeWorkspaceUsage> getCodeByWorkspace({
    required int startTime,
    required int endTime,
    String? workspaceId,
  }) => _transport.json(
    'GET',
    '/v1/admin/analytics/vibe/code/usage/by_workspace',
    VibeCodeWorkspaceUsage.fromJson,
    query: {
      'start_time': startTime.toString(),
      'end_time': endTime.toString(),
      'workspace_id': ?workspaceId,
    },
  );

  /// Usage by agent.
  Future<VibeWorkAgentUsage> getWorkByAgent({
    required int startTime,
    required int endTime,
  }) => _transport.json(
    'GET',
    '/v1/admin/analytics/vibe/work/usage/by_agent_stats',
    VibeWorkAgentUsage.fromJson,
    query: {'start_time': startTime.toString(), 'end_time': endTime.toString()},
  );

  /// Usage over time.
  Future<VibeWorkTimeUsage> getWorkByTime({
    required int startTime,
    required int endTime,
    VibeUsageGranularity? granularity,
  }) => _transport.json(
    'GET',
    '/v1/admin/analytics/vibe/work/usage/by_time_stats',
    VibeWorkTimeUsage.fromJson,
    query: {
      'start_time': startTime.toString(),
      'end_time': endTime.toString(),
      'granularity': ?granularity?.value,
    },
  );

  /// Usage by user.
  Future<VibeWorkUserUsage> getWorkByUser({
    required int startTime,
    required int endTime,
  }) => _transport.json(
    'GET',
    '/v1/admin/analytics/vibe/work/usage/by_user_stats',
    VibeWorkUserUsage.fromJson,
    query: {'start_time': startTime.toString(), 'end_time': endTime.toString()},
  );
}
