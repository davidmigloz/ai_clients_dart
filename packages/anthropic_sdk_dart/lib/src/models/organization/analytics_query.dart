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
  organizationId('organization_ids[]');

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
  }) : filters = Map.unmodifiable({
         for (final entry in filters.entries)
           entry.key: List<String>.unmodifiable(entry.value),
       }),
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
