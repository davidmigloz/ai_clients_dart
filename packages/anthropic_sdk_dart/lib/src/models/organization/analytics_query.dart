import 'package:meta/meta.dart';

/// Time granularity for an analytics report.
enum AnalyticsBucketWidth {
  /// One UTC minute.
  minute('1m'),

  /// One UTC hour.
  hour('1h'),

  /// One UTC day.
  day('1d');

  const AnalyticsBucketWidth(this.value);

  /// Provider value for the bucket width.
  final String value;
}

/// A repeated filter for usage and cost analytics.
enum AnalyticsFilter {
  /// Product using Claude.
  product('products[]'),

  /// Model identifier.
  model('models[]'),

  /// Context-window size.
  contextWindow('context_windows[]'),

  /// Inference region.
  inferenceGeo('inference_geos[]'),

  /// Model inference speed.
  speed('speeds[]'),

  /// Slack channel for Claude Tag usage.
  slackChannelId('slack_channel_ids[]'),

  /// Claude Tag interaction category.
  claudeTagCategory('claude_tag_categories[]'),

  /// Claude Tag user identifier.
  claudeTagUserId('claude_tag_user_ids[]'),

  /// Workspace identifier. An empty entry selects the default workspace.
  workspaceId('workspace_ids[]'),

  /// Service tier.
  serviceTier('service_tiers[]'),

  /// Enterprise RBAC group identifier.
  rbacGroupId('rbac_group_ids[]'),

  /// End-user profile identifier.
  userProfileId('user_profile_ids[]'),

  /// Managed Agents agent identifier.
  agentId('agent_ids[]'),

  /// Managed Agents environment identifier.
  environmentId('environment_ids[]'),

  /// Managed Agents deployment identifier.
  deploymentId('deployment_ids[]'),

  /// Managed Agents session identifier.
  sessionId('session_ids[]'),

  /// User, service account, or API key actor identifier.
  actorId('actor_ids[]'),

  /// Actor discriminator, such as `user_actor`.
  actorType('actor_types[]'),

  /// API key identifier. An empty entry selects usage without a key.
  apiKeyId('api_key_ids[]'),

  /// Child organization UUID for an authorized parent-organization report.
  organizationId('organization_ids[]'),

  /// User ID for the legacy Enterprise reports that accept a user filter.
  userId('user_ids[]');

  const AnalyticsFilter(this.key);

  /// Query parameter name, including brackets for repeated values.
  final String key;
}

/// Request options shared by the current usage and cost analytics endpoints.
///
/// [startingAt] is inclusive and [endingAt] is exclusive. Both are sent as
/// RFC 3339 timestamps in UTC. [endingAt] is required with [timeBucketWidth].
/// Dimensions in [groupBy] use wire names such as `actor`, `model`, and
/// `organization_id`. Reuse the same options with the returned page cursor.
@immutable
final class UsageCostAnalyticsQuery {
  /// Creates a dimensioned report query.
  UsageCostAnalyticsQuery({
    required this.startingAt,
    this.endingAt,
    this.timeBucketWidth,
    Map<AnalyticsFilter, List<String>> filters = const {},
    List<String> groupBy = const [],
    this.orderBy,
    this.order,
    this.excludeDeletedUsers,
    this.limit,
    this.page,
  }) : filters = _snapshotFilters(filters),
       groupBy = List.unmodifiable(groupBy);

  /// Start of the range, inclusive.
  final DateTime startingAt;

  /// End of the range, exclusive.
  final DateTime? endingAt;

  /// Splits each dimension combination into UTC time buckets.
  final AnalyticsBucketWidth? timeBucketWidth;

  /// Repeated values for each selected filter.
  final Map<AnalyticsFilter, List<String>> filters;

  /// Dimensions to group by. The API accepts up to five.
  final List<String> groupBy;

  /// Endpoint-specific ordering metric, or `time`.
  final String? orderBy;

  /// `asc` or `desc`.
  final String? order;

  /// Whether to exclude deleted users.
  final bool? excludeDeletedUsers;

  /// Maximum number of rows on a page.
  final int? limit;

  /// Opaque next-page cursor from a previous response.
  final String? page;

  /// Returns the query using Anthropic's repeated-key syntax.
  Map<String, dynamic> toQuery() {
    if (filters[AnalyticsFilter.userId]?.isNotEmpty ?? false) {
      throw ArgumentError('Use the actorId filter for dimensioned analytics');
    }
    if (timeBucketWidth != null && endingAt == null) {
      throw ArgumentError('endingAt is required with timeBucketWidth');
    }
    return {
      'starting_at': startingAt.toUtc().toIso8601String(),
      'ending_at': ?endingAt?.toUtc().toIso8601String(),
      'time_bucket_width': ?timeBucketWidth?.value,
      for (final entry in filters.entries)
        if (entry.value.isNotEmpty) entry.key.key: entry.value,
      if (groupBy.isNotEmpty) 'group_by[]': groupBy,
      'order_by': ?orderBy,
      'order': ?order,
      'exclude_deleted_users': ?excludeDeletedUsers?.toString(),
      'limit': ?limit?.toString(),
      'page': ?page,
    };
  }

  /// Creates the same query for the next page, or resets to the first page.
  UsageCostAnalyticsQuery withPage(String? cursor) => UsageCostAnalyticsQuery(
    startingAt: startingAt,
    endingAt: endingAt,
    timeBucketWidth: timeBucketWidth,
    filters: filters,
    groupBy: groupBy,
    orderBy: orderBy,
    order: order,
    excludeDeletedUsers: excludeDeletedUsers,
    limit: limit,
    page: cursor,
  );
}

/// Options shared by legacy Enterprise usage and cost reports.
@immutable
final class LegacyEnterpriseAnalyticsQuery {
  /// Creates a legacy Enterprise report query.
  LegacyEnterpriseAnalyticsQuery({
    required this.startingAt,
    this.endingAt,
    this.bucketWidth,
    Map<AnalyticsFilter, List<String>> filters = const {},
    List<String> groupBy = const [],
    this.limit,
    this.page,
  }) : filters = _snapshotFilters(filters),
       groupBy = List.unmodifiable(groupBy);

  /// Start of the report range, inclusive.
  final DateTime startingAt;

  /// End of the report range, exclusive.
  final DateTime? endingAt;

  /// Granularity for bucketed or per-user reports, when specified.
  final AnalyticsBucketWidth? bucketWidth;

  /// Repeated filters accepted by the legacy endpoint.
  final Map<AnalyticsFilter, List<String>> filters;

  /// Dimensions to group by, using the endpoint's wire names.
  final List<String> groupBy;

  /// Maximum number of rows or buckets on a page.
  final int? limit;

  /// Opaque cursor from the same report and filter options.
  final String? page;

  /// Serializes this query using the legacy `bucket_width` parameter.
  Map<String, dynamic> toQuery() {
    const sharedFilters = {
      AnalyticsFilter.product,
      AnalyticsFilter.model,
      AnalyticsFilter.contextWindow,
      AnalyticsFilter.inferenceGeo,
      AnalyticsFilter.speed,
      AnalyticsFilter.slackChannelId,
      AnalyticsFilter.claudeTagCategory,
      AnalyticsFilter.claudeTagUserId,
      AnalyticsFilter.rbacGroupId,
      AnalyticsFilter.userId,
    };
    for (final filter in filters.entries) {
      if (filter.value.isNotEmpty && !sharedFilters.contains(filter.key)) {
        throw ArgumentError.value(
          filter.key,
          'filters',
          'Filter not supported by this legacy report',
        );
      }
    }
    return {
      'starting_at': startingAt.toUtc().toIso8601String(),
      'ending_at': ?endingAt?.toUtc().toIso8601String(),
      'bucket_width': ?bucketWidth?.value,
      for (final entry in filters.entries)
        if (entry.value.isNotEmpty) entry.key.key: entry.value,
      if (groupBy.isNotEmpty) 'group_by[]': groupBy,
      'limit': ?limit?.toString(),
      'page': ?page,
    };
  }

  /// Creates the same report query with a different page cursor.
  LegacyEnterpriseAnalyticsQuery withPage(String? cursor) =>
      LegacyEnterpriseAnalyticsQuery(
        startingAt: startingAt,
        endingAt: endingAt,
        bucketWidth: bucketWidth,
        filters: filters,
        groupBy: groupBy,
        limit: limit,
        page: cursor,
      );
}

Map<AnalyticsFilter, List<String>> _snapshotFilters(
  Map<AnalyticsFilter, List<String>> filters,
) => Map.unmodifiable({
  for (final entry in filters.entries)
    entry.key: List<String>.unmodifiable(entry.value),
});

/// Day or date-range options for Enterprise activity reports.
///
/// Dates are UTC calendar dates in YYYY-MM-DD form. Use [date] for one day
/// or [startingDate] and an optional exclusive [endingDate] for a rollup.
@immutable
final class AnalyticsActivityQuery {
  /// Creates an activity query.
  AnalyticsActivityQuery({
    this.date,
    this.startingDate,
    this.endingDate,
    List<String> filters = const [],
    List<String> groupBy = const [],
    this.orderBy,
    this.order,
    this.limit,
    this.page,
  }) : filters = List.unmodifiable(filters),
       groupBy = List.unmodifiable(groupBy);

  /// The UTC day to report.
  final String? date;

  /// Inclusive start of a range.
  final String? startingDate;

  /// Exclusive end of a range.
  final String? endingDate;

  /// Repeated dimension filters, such as `rbac_group_id:rbac_group_example`.
  final List<String> filters;

  /// Dimensions supported by the selected activity endpoint.
  final List<String> groupBy;

  /// Endpoint-specific sort metric.
  final String? orderBy;

  /// Sort direction, `asc` or `desc`.
  final String? order;

  /// Maximum number of rows per page.
  final int? limit;

  /// Cursor from a previous page of the same query.
  final String? page;

  /// Creates a copy with a different cursor.
  AnalyticsActivityQuery withPage(String? cursor) => AnalyticsActivityQuery(
    date: date,
    startingDate: startingDate,
    endingDate: endingDate,
    filters: filters,
    groupBy: groupBy,
    orderBy: orderBy,
    order: order,
    limit: limit,
    page: cursor,
  );
}
