import '../../models/admin/admin_usage.dart';
import 'admin_transport.dart';

/// Administrative usage operations.
class AdminUsageResource {
  /// Creates the usage resource.
  const AdminUsageResource(this._transport);

  final AdminTransport _transport;

  /// Monthly Usage and Pricing.
  Future<AdminMonthlyUsage> getMonthly({
    String? month,
    String? year,
    String? workspaceId,
    AdminApiZone? apiZone,
  }) => _transport.json(
    'GET',
    '/v1/admin/usage',
    AdminMonthlyUsage.fromJson,
    query: {
      'month': ?month,
      'year': ?year,
      'workspace_id': ?workspaceId,
      'api_zone': ?apiZone?.toJson(),
    },
  );

  /// Detailed Usage Query.
  Future<AdminUsageQueryResult> query({required AdminUsageQuery request}) =>
      _transport.json(
        'POST',
        '/v1/admin/usage/query',
        AdminUsageQueryResult.fromJson,
        body: request.toJson(),
      );

  /// Get Rate Limits.
  Future<AdminRateLimits> getRateLimits() =>
      _transport.json('GET', '/v1/admin/rate-limit', AdminRateLimits.fromJson);

  /// Get Spend Limits.
  Future<AdminSpendLimits> getSpendLimits() => _transport.json(
    'GET',
    '/v1/admin/spend-limit',
    AdminSpendLimits.fromJson,
  );

  /// Update Spend Limits.
  Future<AdminSpendLimits> updateSpendLimit({
    required UpdateAdminSpendLimitRequest request,
  }) => _transport.json(
    'POST',
    '/v1/admin/spend-limit',
    AdminSpendLimits.fromJson,
    body: request.toJson(),
  );
}
