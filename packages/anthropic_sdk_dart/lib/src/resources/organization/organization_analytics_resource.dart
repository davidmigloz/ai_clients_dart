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

  /// Gets daily activity summaries, including Claude Tag counts when available.
  ///
  /// The requested range is inclusive at [startingDate] and exclusive at
  /// [endingDate]. Use a Claude Enterprise key with `read:analytics`.
  Future<AnalyticsActivityPage<AnalyticsSingleDayActivitySummary>> summaries({
    required String startingDate,
    String? endingDate,
    List<String> filters = const [],
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/summaries',
    AnalyticsSingleDayActivitySummary.fromJson,
    _activityQuery(
      AnalyticsActivityQuery(
        startingDate: startingDate,
        endingDate: endingDate,
        filters: filters,
        limit: limit,
        page: page,
      ),
    ),
    betas,
    abortTrigger,
    allowLegacySummaries: true,
  );

  /// Lists activity by Enterprise user or grouped dimensions.
  Future<AnalyticsActivityPage<AnalyticsUserActivity>> users(
    AnalyticsActivityQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/users',
    AnalyticsUserActivity.fromJson,
    _activityQuery(query),
    betas,
    abortTrigger,
  );

  /// Lists Chat project activity.
  Future<AnalyticsActivityPage<AnalyticsProjectActivity>> projects(
    AnalyticsActivityQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/apps/chat/projects',
    AnalyticsProjectActivity.fromJson,
    _activityQuery(query),
    betas,
    abortTrigger,
  );

  /// Lists skill activity and attributed cost.
  Future<AnalyticsActivityPage<AnalyticsSkillActivity>> skills(
    AnalyticsActivityQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/skills',
    AnalyticsSkillActivity.fromJson,
    _activityQuery(query),
    betas,
    abortTrigger,
  );

  /// Lists connector activity and managed-auth attribution.
  Future<AnalyticsActivityPage<AnalyticsConnectorActivity>> connectors(
    AnalyticsActivityQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/connectors',
    AnalyticsConnectorActivity.fromJson,
    _activityQuery(query),
    betas,
    abortTrigger,
  );

  /// Lists plugin installation and invocation activity.
  Future<AnalyticsActivityPage<AnalyticsPluginActivity>> plugins(
    AnalyticsActivityQuery query, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/plugins',
    AnalyticsPluginActivity.fromJson,
    _activityQuery(query),
    betas,
    abortTrigger,
  );

  /// Lists artifacts created on the UTC [date].
  Future<AnalyticsActivityPage<AnalyticsArtifactActivity>> artifacts({
    required String date,
    List<String> filters = const [],
    List<String> groupBy = const [],
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _activityReport(
    '/analytics/artifacts',
    AnalyticsArtifactActivity.fromJson,
    _activityQuery(
      AnalyticsActivityQuery(
        date: date,
        filters: filters,
        groupBy: groupBy,
        limit: limit,
        page: page,
      ),
    ),
    betas,
    abortTrigger,
  );

  Future<AnalyticsActivityPage<T>> _activityReport<T>(
    String path,
    T Function(Map<String, dynamic>) decode,
    Map<String, dynamic> query,
    List<String> betas,
    Future<void>? abortTrigger, {
    bool allowLegacySummaries = false,
  }) => _transport.send(
    'GET',
    path,
    (json) => AnalyticsActivityPage.fromJson(
      json,
      decode,
      allowLegacySummaries: allowLegacySummaries,
    ),
    query: query,
    beta: betas.isEmpty ? null : betas.join(','),
    abortTrigger: abortTrigger,
  );

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

Map<String, dynamic> _activityQuery(AnalyticsActivityQuery query) {
  if (query.date != null && query.startingDate != null) {
    throw ArgumentError('Specify either date or startingDate');
  }
  if (query.endingDate != null && query.startingDate == null) {
    throw ArgumentError('endingDate requires startingDate');
  }
  return {
    if (query.date case final date?) 'date': _utcDay(date, 'date'),
    if (query.startingDate case final start?)
      'starting_date': _utcDay(start, 'startingDate'),
    if (query.endingDate case final end?)
      'ending_date': _utcDay(end, 'endingDate'),
    if (query.filters.isNotEmpty) 'filter[]': query.filters,
    if (query.groupBy.isNotEmpty) 'group_by[]': query.groupBy,
    'order_by': ?query.orderBy,
    'order': ?query.order,
    'limit': ?query.limit?.toString(),
    'page': ?query.page,
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
