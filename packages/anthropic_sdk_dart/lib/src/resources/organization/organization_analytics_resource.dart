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
  }) => _report(
    '/analytics/usage',
    AnalyticsUsageRow.fromJson,
    query.toQuery(),
    abortTrigger,
    betas: betas,
    requiredBeta: _usageCostBeta,
  );

  /// Gets costs grouped by the dimensions in [query].
  ///
  /// Amounts are decimal strings in minor currency units.
  Future<AnalyticsReportPage<AnalyticsCostRow>> cost(
    UsageCostAnalyticsQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _report(
    '/analytics/cost',
    AnalyticsCostRow.fromJson,
    query.toQuery(),
    abortTrigger,
    betas: betas,
    requiredBeta: _usageCostBeta,
  );

  /// Gets the legacy Enterprise usage report with time buckets.
  Future<AnalyticsReportPage<AnalyticsTimeBucket<LegacyAnalyticsUsageRow>>>
  usageReport(
    LegacyEnterpriseAnalyticsQuery query, {
    Future<void>? abortTrigger,
  }) => _report(
    '/analytics/usage_report',
    _legacyUsageBucket,
    query.toQuery(),
    abortTrigger,
  );

  /// Gets the legacy Enterprise cost report with time buckets.
  Future<AnalyticsReportPage<AnalyticsTimeBucket<LegacyAnalyticsCostRow>>>
  costReport(
    LegacyEnterpriseAnalyticsQuery query, {
    Future<void>? abortTrigger,
  }) => _report(
    '/analytics/cost_report',
    _legacyCostBucket,
    query.toQuery(),
    abortTrigger,
  );

  /// Gets the legacy Enterprise per-user usage report.
  Future<AnalyticsReportPage<LegacyAnalyticsUsageRow>> userUsageReport(
    LegacyEnterpriseAnalyticsQuery query, {
    String? orderBy,
    String? order,
    bool? excludeDeletedUsers,
    Future<void>? abortTrigger,
  }) => _report(
    '/analytics/user_usage_report',
    LegacyAnalyticsUsageRow.fromJson,
    _legacyUserQuery(query, orderBy, order, excludeDeletedUsers),
    abortTrigger,
  );

  /// Gets the legacy Enterprise per-user cost report.
  Future<AnalyticsReportPage<LegacyAnalyticsCostRow>> userCostReport(
    LegacyEnterpriseAnalyticsQuery query, {
    String? orderBy,
    String? order,
    bool? excludeDeletedUsers,
    Future<void>? abortTrigger,
  }) => _report(
    '/analytics/user_cost_report',
    LegacyAnalyticsCostRow.fromJson,
    _legacyUserQuery(query, orderBy, order, excludeDeletedUsers),
    abortTrigger,
  );

  /// Gets the legacy Console Messages usage report.
  ///
  /// The original report uses the singular wire key `context_window[]`.
  Future<AnalyticsReportPage<AnalyticsTimeBucket<LegacyAnalyticsUsageRow>>>
  messagesUsageReport({
    required DateTime startingAt,
    DateTime? endingAt,
    AnalyticsBucketWidth? bucketWidth,
    List<String> apiKeyIds = const [],
    List<String> workspaceIds = const [],
    List<String> accountIds = const [],
    List<String> serviceAccountIds = const [],
    List<String> models = const [],
    List<String> serviceTiers = const [],
    List<String> contextWindows = const [],
    List<String> inferenceGeos = const [],
    List<String> speeds = const [],
    List<String> groupBy = const [],
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _report(
    '/usage_report/messages',
    _legacyUsageBucket,
    {
      'starting_at': startingAt.toUtc().toIso8601String(),
      'ending_at': ?endingAt?.toUtc().toIso8601String(),
      'bucket_width': ?bucketWidth?.value,
      if (apiKeyIds.isNotEmpty) 'api_key_ids[]': apiKeyIds,
      if (workspaceIds.isNotEmpty) 'workspace_ids[]': workspaceIds,
      if (accountIds.isNotEmpty) 'account_ids[]': accountIds,
      if (serviceAccountIds.isNotEmpty)
        'service_account_ids[]': serviceAccountIds,
      if (models.isNotEmpty) 'models[]': models,
      if (serviceTiers.isNotEmpty) 'service_tiers[]': serviceTiers,
      if (contextWindows.isNotEmpty) 'context_window[]': contextWindows,
      if (inferenceGeos.isNotEmpty) 'inference_geos[]': inferenceGeos,
      if (speeds.isNotEmpty) 'speeds[]': speeds,
      if (groupBy.isNotEmpty) 'group_by[]': groupBy,
      'limit': ?limit?.toString(),
      'page': ?page,
    },
    abortTrigger,
    betas: betas,
  );

  /// Gets the legacy Console cost report, which returns daily buckets.
  Future<AnalyticsReportPage<AnalyticsTimeBucket<LegacyAnalyticsCostRow>>>
  consoleCostReport({
    required DateTime startingAt,
    DateTime? endingAt,
    List<String> groupBy = const [],
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _report(
    '/cost_report',
    _legacyCostBucket,
    {
      'starting_at': startingAt.toUtc().toIso8601String(),
      'ending_at': ?endingAt?.toUtc().toIso8601String(),
      'bucket_width': AnalyticsBucketWidth.day.value,
      if (groupBy.isNotEmpty) 'group_by[]': groupBy,
      'limit': ?limit?.toString(),
      'page': ?page,
    },
    abortTrigger,
    betas: betas,
  );

  /// Gets Claude Code usage on the UTC [date], formatted as YYYY-MM-DD.
  Future<AnalyticsReportPage<ClaudeCodeUsageRow>> claudeCodeUsageReport({
    required String date,
    int? limit,
    String? page,
    Future<void>? abortTrigger,
  }) => _report('/usage_report/claude_code', ClaudeCodeUsageRow.fromJson, {
    'starting_at': _utcDay(date, 'date'),
    'limit': ?limit?.toString(),
    'page': ?page,
  }, abortTrigger);

  Future<AnalyticsReportPage<T>> _report<T>(
    String path,
    T Function(Map<String, dynamic>) decode,
    Map<String, dynamic> query,
    Future<void>? abortTrigger, {
    List<String> betas = const [],
    String? requiredBeta,
  }) => _transport.send(
    'GET',
    path,
    (json) => AnalyticsReportPage.fromJson(json, decode),
    query: query,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: requiredBeta,
    abortTrigger: abortTrigger,
  );
}

AnalyticsTimeBucket<LegacyAnalyticsUsageRow> _legacyUsageBucket(
  Map<String, dynamic> json,
) => AnalyticsTimeBucket.fromJson(json, LegacyAnalyticsUsageRow.fromJson);

AnalyticsTimeBucket<LegacyAnalyticsCostRow> _legacyCostBucket(
  Map<String, dynamic> json,
) => AnalyticsTimeBucket.fromJson(json, LegacyAnalyticsCostRow.fromJson);

Map<String, dynamic> _legacyUserQuery(
  LegacyEnterpriseAnalyticsQuery query,
  String? orderBy,
  String? order,
  bool? excludeDeletedUsers,
) {
  if (query.bucketWidth != null && query.endingAt == null) {
    throw ArgumentError('endingAt is required with a per-user bucketWidth');
  }
  return {
    ...query.toQuery(),
    'order_by': ?orderBy,
    'order': ?order,
    'exclude_deleted_users': ?excludeDeletedUsers?.toString(),
  };
}

final _utcDayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String _utcDay(String value, String parameter) {
  final date = DateTime.tryParse('${value}T00:00:00Z');
  if (!_utcDayPattern.hasMatch(value) ||
      date == null ||
      !date.toIso8601String().startsWith('${value}T')) {
    throw ArgumentError.value(
      value,
      parameter,
      'Expected a UTC YYYY-MM-DD date',
    );
  }
  return value;
}
