import '../../models/organization/analytics_query.dart';
import '../../models/organization/analytics_reports.dart';
import 'organization_transport.dart';

const _usageCostBeta = 'analytics-usage-cost-2026-08-24';

/// Usage and cost analytics for an organization.
final class OrganizationAnalyticsResource {
  /// Creates an analytics resource on the organization transport.
  const OrganizationAnalyticsResource(this._transport);

  final OrganizationTransport _transport;

  /// Gets token usage grouped by the dimensions in [query].
  ///
  /// The endpoint requires an organization credential with analytics access.
  Future<AnalyticsReportPage<AnalyticsUsageRow>> usage(
    UsageCostAnalyticsQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/analytics/usage',
    (json) => AnalyticsReportPage.fromJson(json, AnalyticsUsageRow.fromJson),
    query: query.toQuery(),
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _usageCostBeta,
    abortTrigger: abortTrigger,
  );

  /// Gets costs grouped by the dimensions in [query].
  ///
  /// Amounts are decimal strings in minor currency units.
  Future<AnalyticsReportPage<AnalyticsCostRow>> cost(
    UsageCostAnalyticsQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '/analytics/cost',
    (json) => AnalyticsReportPage.fromJson(json, AnalyticsCostRow.fromJson),
    query: query.toQuery(),
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _usageCostBeta,
    abortTrigger: abortTrigger,
  );
}
