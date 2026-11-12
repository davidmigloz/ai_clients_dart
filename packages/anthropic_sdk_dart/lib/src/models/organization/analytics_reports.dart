import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';
import '../metadata/usage.dart' show CacheCreation, ServerToolUsage;

/// A report record that retains all provider fields for forward compatibility.
@immutable
abstract base class AnalyticsResponseRecord {
  /// Creates a record from its provider payload.
  AnalyticsResponseRecord(Map<String, dynamic> json)
    : rawJson = deepUnmodifiableMap(json);

  /// Original response fields, including unrecognized and explicit null values.
  final Map<String, dynamic> rawJson;

  /// Converts the record to its original response shape.
  Map<String, dynamic> toJson() => Map.of(rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsResponseRecord &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(rawJson));
}

/// A page of flat rows or time buckets from a usage or cost report.
final class AnalyticsReportPage<T> extends AnalyticsResponseRecord {
  /// Parses the report envelope and decodes its rows with [decode].
  AnalyticsReportPage.fromJson(
    super.json,
    T Function(Map<String, dynamic>) decode,
  ) : data = List.unmodifiable(
        requiredOrganizationField<List<Object?>>(
          json,
          'data',
          'Report page',
        ).cast<Map<String, dynamic>>().map(decode),
      ),
      hasMore = requiredOrganizationField<bool>(
        json,
        'has_more',
        'Report page',
      ),
      nextPage = requiredOrganizationField<String?>(
        json,
        'next_page',
        'Report page',
      ),
      dataRefreshedAt = _optionalReportTime(json['data_refreshed_at']),
      organizationId = json['organization_id'] as String? {
    if (hasMore && nextPage?.isNotEmpty != true) {
      throw const FormatException('Missing analytics continuation token');
    }
  }

  /// Rows on this page.
  final List<T> data;

  /// Whether more rows follow.
  final bool hasMore;

  /// Opaque cursor for the next page, or null at the end of the report.
  final String? nextPage;

  /// Freshness of this report's snapshot, when available.
  final DateTime? dataRefreshedAt;

  /// Organization identifier returned by legacy Enterprise reports.
  final String? organizationId;
}

/// A principal to which the report attributes usage or cost.
final class AnalyticsActor extends AnalyticsResponseRecord {
  /// Parses an actor and retains future actor types.
  AnalyticsActor.fromJson(super.json)
    : type = requiredOrganizationField<String>(json, 'type', 'Report actor'),
      provider = switch (json['provider']) {
        final Map<String, dynamic> value => AnalyticsActorProvider.fromJson(
          value,
        ),
        _ => null,
      };

  /// Provider discriminator, such as `user_actor`.
  final String type;

  /// Federated actor's cloud or OIDC provider, if applicable.
  final AnalyticsActorProvider? provider;

  /// User actor's identifier.
  String? get userId => rawJson['user_id'] as String?;

  /// User actor's email. Older API versions can return `email`.
  String? get emailAddress =>
      (rawJson.containsKey('email_address')
              ? rawJson['email_address']
              : rawJson['email'])
          as String?;

  /// User actor's name.
  String? get name => rawJson['name'] as String?;

  /// Whether the user actor has been deleted.
  bool? get deleted => rawJson['deleted'] as bool?;

  /// Service account actor's identifier.
  String? get serviceAccountId => rawJson['service_account_id'] as String?;

  /// API key actor's identifier.
  String? get apiKeyId => rawJson['api_key_id'] as String?;

  /// Federated identity's subject.
  String? get subject => rawJson['subject'] as String?;
}

/// Provider-specific identifiers for a federated analytics actor.
final class AnalyticsActorProvider extends AnalyticsResponseRecord {
  /// Parses a provider descriptor.
  AnalyticsActorProvider.fromJson(super.json);

  /// Provider discriminator, including future provider types.
  String get type => rawJson['type'] as String;

  /// AWS account identifier.
  String? get accountId => rawJson['account_id'] as String?;

  /// AWS principal signing the request.
  String? get signedPrincipal => rawJson['signed_principal'] as String?;

  /// Azure subscription identifier.
  String? get subscriptionId => rawJson['subscription_id'] as String?;

  /// Google Cloud project number.
  String? get projectNumber => rawJson['project_number'] as String?;

  /// OIDC issuer.
  String? get issuer => rawJson['issuer'] as String?;
}

/// Group dimensions for a usage or cost row.
///
/// Dimensions that were not grouped or are not applicable can be null.
final class AnalyticsDimensions extends AnalyticsResponseRecord {
  /// Parses the grouped dimensions.
  AnalyticsDimensions.fromJson(super.json)
    : actor = switch (json['actor']) {
        final Map<String, dynamic> value => AnalyticsActor.fromJson(value),
        _ => null,
      };

  /// Principal attributed to the row.
  final AnalyticsActor? actor;

  /// Actor discriminator selected by grouping.
  String? get actorType => rawJson['actor_type'] as String?;

  /// Child organization identifier.
  String? get organizationId => rawJson['organization_id'] as String?;

  /// Workspace identifier.
  String? get workspaceId => rawJson['workspace_id'] as String?;

  /// Model identifier.
  String? get model => rawJson['model'] as String?;

  /// Product generating the usage or cost.
  String? get product => rawJson['product'] as String?;

  /// API key identifier.
  String? get apiKeyId => rawJson['api_key_id'] as String?;

  /// Context-window class.
  String? get contextWindow => rawJson['context_window'] as String?;

  /// Inference region.
  String? get inferenceGeo => rawJson['inference_geo'] as String?;

  /// Inference speed.
  String? get speed => rawJson['speed'] as String?;

  /// Service tier.
  String? get serviceTier => rawJson['service_tier'] as String?;

  /// End-user profile identifier.
  String? get userProfileId => rawJson['user_profile_id'] as String?;

  /// Managed Agents agent identifier.
  String? get agentId => rawJson['agent_id'] as String?;

  /// Managed Agents environment identifier.
  String? get environmentId => rawJson['environment_id'] as String?;

  /// Managed Agents deployment identifier.
  String? get deploymentId => rawJson['deployment_id'] as String?;

  /// Managed Agents session identifier.
  String? get sessionId => rawJson['session_id'] as String?;

  /// Enterprise RBAC group identifier.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// Slack channel identifier.
  String? get slackChannelId => rawJson['slack_channel_id'] as String?;

  /// Claude Tag category.
  String? get claudeTagCategory => rawJson['claude_tag_category'] as String?;

  /// Claude Tag user identifier.
  String? get claudeTagUserId => rawJson['claude_tag_user_id'] as String?;

  /// Cost category.
  String? get costType => rawJson['cost_type'] as String?;

  /// Cost token category.
  String? get tokenType => rawJson['token_type'] as String?;
}

/// Token counts and server tool use for a report row.
final class AnalyticsUsageMetrics extends AnalyticsResponseRecord {
  /// Parses a usage metrics object.
  AnalyticsUsageMetrics.fromJson(super.json)
    : cacheCreation = CacheCreation.fromJson(
        _reportObject(json, 'cache_creation'),
      ),
      serverToolUse = ServerToolUsage.fromJson(
        _reportObject(json, 'server_tool_use'),
      ),
      cacheReadInputTokens = requiredOrganizationField<int>(
        json,
        'cache_read_input_tokens',
        'Usage metrics',
      ),
      uncachedInputTokens = requiredOrganizationField<int>(
        json,
        'uncached_input_tokens',
        'Usage metrics',
      ),
      outputTokens = requiredOrganizationField<int>(
        json,
        'output_tokens',
        'Usage metrics',
      );

  /// Tokens used to create cache entries.
  final CacheCreation cacheCreation;

  /// Counts of server tool calls.
  final ServerToolUsage serverToolUse;

  /// Input tokens retrieved from cache.
  final int cacheReadInputTokens;

  /// Input tokens outside the cache.
  final int uncachedInputTokens;

  /// Output tokens.
  final int outputTokens;

  /// Total tokens, when reported by the endpoint.
  int? get totalTokens => rawJson['total_tokens'] as int?;

  /// Request count, when available.
  int? get requests => rawJson['requests'] as int?;
}

/// Amounts reported by the cost endpoints.
final class AnalyticsCostMetrics extends AnalyticsResponseRecord {
  /// Parses a cost metrics object.
  AnalyticsCostMetrics.fromJson(super.json)
    : amount = requiredOrganizationField<String>(
        json,
        'amount',
        'Cost metrics',
      ),
      currency = requiredOrganizationField<String>(
        json,
        'currency',
        'Cost metrics',
      );

  /// Decimal string in the currency's minor unit. Precision is preserved.
  final String amount;

  /// Currency code reported by the API.
  final String currency;

  /// Decimal list-price amount before adjustments, when available.
  String? get listAmount => rawJson['list_amount'] as String?;

  /// Request count, when available.
  int? get requests => rawJson['requests'] as int?;
}

/// A row from the dimensioned usage endpoint.
final class AnalyticsUsageRow extends AnalyticsResponseRecord {
  /// Parses a dimensioned usage row.
  AnalyticsUsageRow.fromJson(super.json)
    : startingAt = _requiredReportTime(json, 'starting_at'),
      endingAt = _requiredReportTime(json, 'ending_at'),
      group = AnalyticsDimensions.fromJson(_reportObject(json, 'group')),
      usage = AnalyticsUsageMetrics.fromJson(_reportObject(json, 'usage'));

  /// Start of the period represented by this row.
  final DateTime startingAt;

  /// End of the period represented by this row.
  final DateTime endingAt;

  /// Group dimensions.
  final AnalyticsDimensions group;

  /// Token and tool usage.
  final AnalyticsUsageMetrics usage;
}

/// A row from the dimensioned cost endpoint.
final class AnalyticsCostRow extends AnalyticsResponseRecord {
  /// Parses a dimensioned cost row.
  AnalyticsCostRow.fromJson(super.json)
    : startingAt = _requiredReportTime(json, 'starting_at'),
      endingAt = _requiredReportTime(json, 'ending_at'),
      group = AnalyticsDimensions.fromJson(_reportObject(json, 'group')),
      cost = AnalyticsCostMetrics.fromJson(_reportObject(json, 'cost'));

  /// Start of the period represented by this row.
  final DateTime startingAt;

  /// End of the period represented by this row.
  final DateTime endingAt;

  /// Group dimensions.
  final AnalyticsDimensions group;

  /// Decimal cost amounts and request counts.
  final AnalyticsCostMetrics cost;
}

Map<String, dynamic> _reportObject(Map<String, dynamic> json, String key) =>
    requiredOrganizationField<Map<String, dynamic>>(json, key, 'Report');

DateTime _requiredReportTime(Map<String, dynamic> json, String key) =>
    DateTime.parse(requiredOrganizationField<String>(json, key, 'Report'));

DateTime? _optionalReportTime(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
