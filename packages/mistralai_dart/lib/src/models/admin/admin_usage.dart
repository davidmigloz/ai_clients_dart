import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative monthly usage.
@immutable
class AdminMonthlyUsage {
  /// Creates a [AdminMonthlyUsage].
  const AdminMonthlyUsage({
    required this.audio,
    required this.audioAgents,
    required this.audioCharacters,
    required this.chat,
    required this.completion,
    required this.connectors,
    required this.currency,
    required this.currencySymbol,
    required this.date,
    required this.endDate,
    required this.fineTuning,
    required this.librariesApi,
    required this.nextMonth,
    required this.ocr,
    required this.previousMonth,
    required this.prices,
    required this.startDate,
    required this.vibeCode,
    required this.vibeUsage,
  });

  /// Audio usage data.
  final AdminModelUsage audio;

  /// Audio Agent session duration usage data.
  final AdminModelUsage audioAgents;

  /// Text-to-speech (audio characters) usage data.
  final AdminModelUsage audioCharacters;

  /// Chat usage data.
  final AdminModelUsage chat;

  /// Completion usage data.
  final AdminModelUsage completion;

  /// Connector usage data.
  final AdminModelUsage connectors;

  /// Currency used for usage prices.
  final String? currency;

  /// Currency symbol used for usage prices.
  final String? currencySymbol;

  /// Reference date for the usage period.
  final String date;

  /// End of the usage period.
  final String endDate;

  /// Fine-tuning usage data.
  final AdminFineTuningUsage fineTuning;

  /// Libraries API usage data.
  final AdminLibrariesUsage librariesApi;

  /// Next month in the usage report.
  final String? nextMonth;

  /// OCR usage data.
  final AdminModelUsage ocr;

  /// Previous month in the usage report.
  final String? previousMonth;

  /// Prices used to calculate usage amounts.
  final List<AdminUsagePrice>? prices;

  /// Start of the usage period.
  final String startDate;

  /// Vibe Code usage data, broken down by sub-usage type.
  final AdminVibeCodeUsage vibeCode;

  /// Legacy Vibe usage field. Always 0; use the Vibe usage API instead.
  final double vibeUsage;

  /// Parses a [AdminMonthlyUsage] from JSON.
  factory AdminMonthlyUsage.fromJson(Map<String, dynamic> json) {
    if (json['audio'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing audio');
    }
    if (json['audio_agents'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing audio_agents');
    }
    if (json['audio_characters'] == null) {
      throw const FormatException(
        'AdminMonthlyUsage: missing audio_characters',
      );
    }
    if (json['chat'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing chat');
    }
    if (json['completion'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing completion');
    }
    if (json['connectors'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing connectors');
    }
    if (!json.containsKey('currency')) {
      throw const FormatException('AdminMonthlyUsage: missing currency');
    }
    if (!json.containsKey('currency_symbol')) {
      throw const FormatException('AdminMonthlyUsage: missing currency_symbol');
    }
    if (json['date'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing date');
    }
    if (json['end_date'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing end_date');
    }
    if (json['fine_tuning'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing fine_tuning');
    }
    if (json['libraries_api'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing libraries_api');
    }
    if (!json.containsKey('next_month')) {
      throw const FormatException('AdminMonthlyUsage: missing next_month');
    }
    if (json['ocr'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing ocr');
    }
    if (!json.containsKey('previous_month')) {
      throw const FormatException('AdminMonthlyUsage: missing previous_month');
    }
    if (!json.containsKey('prices')) {
      throw const FormatException('AdminMonthlyUsage: missing prices');
    }
    if (json['start_date'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing start_date');
    }
    if (json['vibe_code'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing vibe_code');
    }
    if (json['vibe_usage'] == null) {
      throw const FormatException('AdminMonthlyUsage: missing vibe_usage');
    }
    return AdminMonthlyUsage(
      audio: AdminModelUsage.fromJson(json['audio'] as Map<String, dynamic>),
      audioAgents: AdminModelUsage.fromJson(
        json['audio_agents'] as Map<String, dynamic>,
      ),
      audioCharacters: AdminModelUsage.fromJson(
        json['audio_characters'] as Map<String, dynamic>,
      ),
      chat: AdminModelUsage.fromJson(json['chat'] as Map<String, dynamic>),
      completion: AdminModelUsage.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      connectors: AdminModelUsage.fromJson(
        json['connectors'] as Map<String, dynamic>,
      ),
      currency: json['currency'] == null ? null : json['currency'] as String,
      currencySymbol: json['currency_symbol'] == null
          ? null
          : json['currency_symbol'] as String,
      date: json['date'] as String,
      endDate: json['end_date'] as String,
      fineTuning: AdminFineTuningUsage.fromJson(
        json['fine_tuning'] as Map<String, dynamic>,
      ),
      librariesApi: AdminLibrariesUsage.fromJson(
        json['libraries_api'] as Map<String, dynamic>,
      ),
      nextMonth: json['next_month'] == null
          ? null
          : json['next_month'] as String,
      ocr: AdminModelUsage.fromJson(json['ocr'] as Map<String, dynamic>),
      previousMonth: json['previous_month'] == null
          ? null
          : json['previous_month'] as String,
      prices: json['prices'] == null
          ? null
          : (json['prices'] as List)
                .map(
                  (item) =>
                      AdminUsagePrice.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      startDate: json['start_date'] as String,
      vibeCode: AdminVibeCodeUsage.fromJson(
        json['vibe_code'] as Map<String, dynamic>,
      ),
      vibeUsage: (json['vibe_usage'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'audio': audio.toJson(),
    'audio_agents': audioAgents.toJson(),
    'audio_characters': audioCharacters.toJson(),
    'chat': chat.toJson(),
    'completion': completion.toJson(),
    'connectors': connectors.toJson(),
    'currency': currency,
    'currency_symbol': currencySymbol,
    'date': date,
    'end_date': endDate,
    'fine_tuning': fineTuning.toJson(),
    'libraries_api': librariesApi.toJson(),
    'next_month': nextMonth,
    'ocr': ocr.toJson(),
    'previous_month': previousMonth,
    'prices': prices?.map((item) => item.toJson()).toList(),
    'start_date': startDate,
    'vibe_code': vibeCode.toJson(),
    'vibe_usage': vibeUsage,
  };

  /// Creates a copy with the given fields replaced.
  AdminMonthlyUsage copyWith({
    AdminModelUsage? audio,
    AdminModelUsage? audioAgents,
    AdminModelUsage? audioCharacters,
    AdminModelUsage? chat,
    AdminModelUsage? completion,
    AdminModelUsage? connectors,
    Object? currency = unsetCopyWithValue,
    Object? currencySymbol = unsetCopyWithValue,
    String? date,
    String? endDate,
    AdminFineTuningUsage? fineTuning,
    AdminLibrariesUsage? librariesApi,
    Object? nextMonth = unsetCopyWithValue,
    AdminModelUsage? ocr,
    Object? previousMonth = unsetCopyWithValue,
    Object? prices = unsetCopyWithValue,
    String? startDate,
    AdminVibeCodeUsage? vibeCode,
    double? vibeUsage,
  }) => AdminMonthlyUsage(
    audio: audio ?? this.audio,
    audioAgents: audioAgents ?? this.audioAgents,
    audioCharacters: audioCharacters ?? this.audioCharacters,
    chat: chat ?? this.chat,
    completion: completion ?? this.completion,
    connectors: connectors ?? this.connectors,
    currency: currency == unsetCopyWithValue
        ? this.currency
        : currency as String?,
    currencySymbol: currencySymbol == unsetCopyWithValue
        ? this.currencySymbol
        : currencySymbol as String?,
    date: date ?? this.date,
    endDate: endDate ?? this.endDate,
    fineTuning: fineTuning ?? this.fineTuning,
    librariesApi: librariesApi ?? this.librariesApi,
    nextMonth: nextMonth == unsetCopyWithValue
        ? this.nextMonth
        : nextMonth as String?,
    ocr: ocr ?? this.ocr,
    previousMonth: previousMonth == unsetCopyWithValue
        ? this.previousMonth
        : previousMonth as String?,
    prices: prices == unsetCopyWithValue
        ? this.prices
        : (prices as List?)?.cast<AdminUsagePrice>(),
    startDate: startDate ?? this.startDate,
    vibeCode: vibeCode ?? this.vibeCode,
    vibeUsage: vibeUsage ?? this.vibeUsage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminMonthlyUsage &&
          runtimeType == other.runtimeType &&
          audio == other.audio &&
          audioAgents == other.audioAgents &&
          audioCharacters == other.audioCharacters &&
          chat == other.chat &&
          completion == other.completion &&
          connectors == other.connectors &&
          currency == other.currency &&
          currencySymbol == other.currencySymbol &&
          date == other.date &&
          endDate == other.endDate &&
          fineTuning == other.fineTuning &&
          librariesApi == other.librariesApi &&
          nextMonth == other.nextMonth &&
          ocr == other.ocr &&
          previousMonth == other.previousMonth &&
          valuesDeepEqual(prices, other.prices) &&
          startDate == other.startDate &&
          vibeCode == other.vibeCode &&
          vibeUsage == other.vibeUsage;

  @override
  int get hashCode => Object.hashAll([
    audio,
    audioAgents,
    audioCharacters,
    chat,
    completion,
    connectors,
    currency,
    currencySymbol,
    date,
    endDate,
    fineTuning,
    librariesApi,
    nextMonth,
    ocr,
    previousMonth,
    valueDeepHashCode(prices),
    startDate,
    vibeCode,
    vibeUsage,
  ]);

  @override
  String toString() =>
      'AdminMonthlyUsage('
      'audio: $audio, '
      'audioAgents: $audioAgents, '
      'audioCharacters: $audioCharacters, '
      'chat: $chat, '
      'completion: $completion, '
      'connectors: $connectors, '
      'currency: $currency, '
      'currencySymbol: $currencySymbol, '
      'date: $date, '
      'endDate: $endDate, '
      'fineTuning: $fineTuning, '
      'librariesApi: $librariesApi, '
      'nextMonth: $nextMonth, '
      'ocr: $ocr, '
      'previousMonth: $previousMonth, '
      'prices: ${prices?.length}, '
      'startDate: $startDate, '
      'vibeCode: $vibeCode, '
      'vibeUsage: $vibeUsage)';
}

/// Administrative usage query.
@immutable
class AdminUsageQuery {
  /// Creates a [AdminUsageQuery].
  const AdminUsageQuery({
    this.apiKeyId,
    this.apiZone,
    this.billingDisplayName,
    this.billingGroup,
    this.billingMetric,
    required this.end,
    this.filters,
    this.groupBy,
    this.includeAggregates,
    this.includeNbApiCalls,
    this.limit,
    this.offset,
    this.organizationId,
    this.serviceAccountId,
    this.serviceTier,
    required this.start,
    this.timeBucket,
    this.untracked,
    this.usageType,
    this.userId,
    this.workspaceIds,
  });

  /// API key IDs to include.
  final List<String>? apiKeyId;

  /// Inference regions to include.
  final List<String>? apiZone;

  /// Customer-facing billing metric names to include.
  final List<String>? billingDisplayName;

  /// Billing metric components to include.
  final List<String>? billingGroup;

  /// Billing metric identifiers to include.
  final List<String>? billingMetric;

  /// Exclusive end of the usage interval.
  final String end;

  /// Additional inclusion or exclusion filters applied alongside the dimension fields.
  final List<AdminUsageFilter>? filters;

  /// Dimensions used to group the returned usage rows.
  final List<String>? groupBy;

  /// Return aggregates computed over the complete filtered result set.
  final bool? includeAggregates;

  /// Include the number of distinct API calls in grouped rows and aggregates.
  final bool? includeNbApiCalls;

  /// Maximum number of grouped rows to return.
  final int? limit;

  /// Number of grouped rows to skip.
  final int? offset;

  /// Organization IDs to include within the authenticated customer.
  final List<String>? organizationId;

  /// Service account IDs to include.
  final List<String>? serviceAccountId;

  /// Service tiers to include.
  final List<String>? serviceTier;

  /// Inclusive start of the usage interval.
  final String start;

  /// Time interval used to bucket grouped rows.
  final String? timeBucket;

  /// Filter by attribution status. Omit or use null to include both tracked and untracked usage.
  final bool? untracked;

  /// Usage event types to include.
  final List<AdminUsageType>? usageType;

  /// User IDs to include.
  final List<String>? userId;

  /// Workspace IDs to include. Use null to include usage without a workspace.
  final List<String?>? workspaceIds;

  /// Parses a [AdminUsageQuery] from JSON.
  factory AdminUsageQuery.fromJson(Map<String, dynamic> json) {
    if (json['end'] == null) {
      throw const FormatException('AdminUsageQuery: missing end');
    }
    if (json['start'] == null) {
      throw const FormatException('AdminUsageQuery: missing start');
    }
    return AdminUsageQuery(
      apiKeyId: json['api_key_id'] == null
          ? null
          : (json['api_key_id'] as List).map((item) => item as String).toList(),
      apiZone: json['api_zone'] == null
          ? null
          : (json['api_zone'] as List).map((item) => item as String).toList(),
      billingDisplayName: json['billing_display_name'] == null
          ? null
          : (json['billing_display_name'] as List)
                .map((item) => item as String)
                .toList(),
      billingGroup: json['billing_group'] == null
          ? null
          : (json['billing_group'] as List)
                .map((item) => item as String)
                .toList(),
      billingMetric: json['billing_metric'] == null
          ? null
          : (json['billing_metric'] as List)
                .map((item) => item as String)
                .toList(),
      end: json['end'] as String,
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List)
                .map(
                  (item) =>
                      AdminUsageFilter.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      groupBy: json['group_by'] == null
          ? null
          : (json['group_by'] as List).map((item) => item as String).toList(),
      includeAggregates: json['include_aggregates'] == null
          ? null
          : json['include_aggregates'] as bool,
      includeNbApiCalls: json['include_nb_api_calls'] == null
          ? null
          : json['include_nb_api_calls'] as bool,
      limit: json['limit'] == null ? null : json['limit'] as int,
      offset: json['offset'] == null ? null : json['offset'] as int,
      organizationId: json['organization_id'] == null
          ? null
          : (json['organization_id'] as List)
                .map((item) => item as String)
                .toList(),
      serviceAccountId: json['service_account_id'] == null
          ? null
          : (json['service_account_id'] as List)
                .map((item) => item as String)
                .toList(),
      serviceTier: json['service_tier'] == null
          ? null
          : (json['service_tier'] as List)
                .map((item) => item as String)
                .toList(),
      start: json['start'] as String,
      timeBucket: json['time_bucket'] == null
          ? null
          : json['time_bucket'] as String,
      untracked: json['untracked'] == null ? null : json['untracked'] as bool,
      usageType: json['usage_type'] == null
          ? null
          : (json['usage_type'] as List)
                .map((item) => AdminUsageType.fromJson(item as String))
                .toList(),
      userId: json['user_id'] == null
          ? null
          : (json['user_id'] as List).map((item) => item as String).toList(),
      workspaceIds: json['workspace_ids'] == null
          ? null
          : (json['workspace_ids'] as List)
                .map((item) => item as String?)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'api_key_id': ?apiKeyId,
    'api_zone': ?apiZone,
    'billing_display_name': ?billingDisplayName,
    'billing_group': ?billingGroup,
    'billing_metric': ?billingMetric,
    'end': end,
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
    'group_by': ?groupBy,
    'include_aggregates': ?includeAggregates,
    'include_nb_api_calls': ?includeNbApiCalls,
    'limit': ?limit,
    'offset': ?offset,
    'organization_id': ?organizationId,
    'service_account_id': ?serviceAccountId,
    'service_tier': ?serviceTier,
    'start': start,
    'time_bucket': ?timeBucket,
    'untracked': ?untracked,
    if (usageType != null)
      'usage_type': usageType!.map((item) => item.toJson()).toList(),
    'user_id': ?userId,
    'workspace_ids': ?workspaceIds,
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageQuery copyWith({
    Object? apiKeyId = unsetCopyWithValue,
    Object? apiZone = unsetCopyWithValue,
    Object? billingDisplayName = unsetCopyWithValue,
    Object? billingGroup = unsetCopyWithValue,
    Object? billingMetric = unsetCopyWithValue,
    String? end,
    Object? filters = unsetCopyWithValue,
    Object? groupBy = unsetCopyWithValue,
    Object? includeAggregates = unsetCopyWithValue,
    Object? includeNbApiCalls = unsetCopyWithValue,
    Object? limit = unsetCopyWithValue,
    Object? offset = unsetCopyWithValue,
    Object? organizationId = unsetCopyWithValue,
    Object? serviceAccountId = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    String? start,
    Object? timeBucket = unsetCopyWithValue,
    Object? untracked = unsetCopyWithValue,
    Object? usageType = unsetCopyWithValue,
    Object? userId = unsetCopyWithValue,
    Object? workspaceIds = unsetCopyWithValue,
  }) => AdminUsageQuery(
    apiKeyId: apiKeyId == unsetCopyWithValue
        ? this.apiKeyId
        : (apiKeyId as List?)?.cast<String>(),
    apiZone: apiZone == unsetCopyWithValue
        ? this.apiZone
        : (apiZone as List?)?.cast<String>(),
    billingDisplayName: billingDisplayName == unsetCopyWithValue
        ? this.billingDisplayName
        : (billingDisplayName as List?)?.cast<String>(),
    billingGroup: billingGroup == unsetCopyWithValue
        ? this.billingGroup
        : (billingGroup as List?)?.cast<String>(),
    billingMetric: billingMetric == unsetCopyWithValue
        ? this.billingMetric
        : (billingMetric as List?)?.cast<String>(),
    end: end ?? this.end,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List?)?.cast<AdminUsageFilter>(),
    groupBy: groupBy == unsetCopyWithValue
        ? this.groupBy
        : (groupBy as List?)?.cast<String>(),
    includeAggregates: includeAggregates == unsetCopyWithValue
        ? this.includeAggregates
        : includeAggregates as bool?,
    includeNbApiCalls: includeNbApiCalls == unsetCopyWithValue
        ? this.includeNbApiCalls
        : includeNbApiCalls as bool?,
    limit: limit == unsetCopyWithValue ? this.limit : limit as int?,
    offset: offset == unsetCopyWithValue ? this.offset : offset as int?,
    organizationId: organizationId == unsetCopyWithValue
        ? this.organizationId
        : (organizationId as List?)?.cast<String>(),
    serviceAccountId: serviceAccountId == unsetCopyWithValue
        ? this.serviceAccountId
        : (serviceAccountId as List?)?.cast<String>(),
    serviceTier: serviceTier == unsetCopyWithValue
        ? this.serviceTier
        : (serviceTier as List?)?.cast<String>(),
    start: start ?? this.start,
    timeBucket: timeBucket == unsetCopyWithValue
        ? this.timeBucket
        : timeBucket as String?,
    untracked: untracked == unsetCopyWithValue
        ? this.untracked
        : untracked as bool?,
    usageType: usageType == unsetCopyWithValue
        ? this.usageType
        : (usageType as List?)?.cast<AdminUsageType>(),
    userId: userId == unsetCopyWithValue
        ? this.userId
        : (userId as List?)?.cast<String>(),
    workspaceIds: workspaceIds == unsetCopyWithValue
        ? this.workspaceIds
        : (workspaceIds as List?)?.cast<String?>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageQuery &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(apiKeyId, other.apiKeyId) &&
          valuesDeepEqual(apiZone, other.apiZone) &&
          valuesDeepEqual(billingDisplayName, other.billingDisplayName) &&
          valuesDeepEqual(billingGroup, other.billingGroup) &&
          valuesDeepEqual(billingMetric, other.billingMetric) &&
          end == other.end &&
          valuesDeepEqual(filters, other.filters) &&
          valuesDeepEqual(groupBy, other.groupBy) &&
          includeAggregates == other.includeAggregates &&
          includeNbApiCalls == other.includeNbApiCalls &&
          limit == other.limit &&
          offset == other.offset &&
          valuesDeepEqual(organizationId, other.organizationId) &&
          valuesDeepEqual(serviceAccountId, other.serviceAccountId) &&
          valuesDeepEqual(serviceTier, other.serviceTier) &&
          start == other.start &&
          timeBucket == other.timeBucket &&
          untracked == other.untracked &&
          valuesDeepEqual(usageType, other.usageType) &&
          valuesDeepEqual(userId, other.userId) &&
          valuesDeepEqual(workspaceIds, other.workspaceIds);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(apiKeyId),
    valueDeepHashCode(apiZone),
    valueDeepHashCode(billingDisplayName),
    valueDeepHashCode(billingGroup),
    valueDeepHashCode(billingMetric),
    end,
    valueDeepHashCode(filters),
    valueDeepHashCode(groupBy),
    includeAggregates,
    includeNbApiCalls,
    limit,
    offset,
    valueDeepHashCode(organizationId),
    valueDeepHashCode(serviceAccountId),
    valueDeepHashCode(serviceTier),
    start,
    timeBucket,
    untracked,
    valueDeepHashCode(usageType),
    valueDeepHashCode(userId),
    valueDeepHashCode(workspaceIds),
  ]);

  @override
  String toString() =>
      'AdminUsageQuery('
      'apiKeyId: ${apiKeyId?.length}, '
      'apiZone: ${apiZone?.length}, '
      'billingDisplayName: ${billingDisplayName?.length}, '
      'billingGroup: ${billingGroup?.length}, '
      'billingMetric: ${billingMetric?.length}, '
      'end: $end, '
      'filters: ${filters?.length}, '
      'groupBy: ${groupBy?.length}, '
      'includeAggregates: $includeAggregates, '
      'includeNbApiCalls: $includeNbApiCalls, '
      'limit: $limit, '
      'offset: $offset, '
      'organizationId: ${organizationId?.length}, '
      'serviceAccountId: ${serviceAccountId?.length}, '
      'serviceTier: ${serviceTier?.length}, '
      'start: $start, '
      'timeBucket: $timeBucket, '
      'untracked: $untracked, '
      'usageType: ${usageType?.length}, '
      'userId: ${userId?.length}, '
      'workspaceIds: ${workspaceIds?.length})';
}

/// Administrative usage query result.
@immutable
class AdminUsageQueryResult {
  /// Creates a [AdminUsageQueryResult].
  const AdminUsageQueryResult({
    this.aggregates,
    required this.groups,
    required this.metadata,
  });

  /// Aggregates over the complete filtered result set when requested.
  final AdminUsageQueryAggregates? aggregates;

  /// Grouped usage rows.
  final List<AdminUsageQueryRow> groups;

  /// Query parameters and pagination metadata.
  final AdminUsageQueryMetadata metadata;

  /// Parses a [AdminUsageQueryResult] from JSON.
  factory AdminUsageQueryResult.fromJson(Map<String, dynamic> json) {
    if (json['groups'] == null) {
      throw const FormatException('AdminUsageQueryResult: missing groups');
    }
    if (json['metadata'] == null) {
      throw const FormatException('AdminUsageQueryResult: missing metadata');
    }
    return AdminUsageQueryResult(
      aggregates: json['aggregates'] == null
          ? null
          : AdminUsageQueryAggregates.fromJson(
              json['aggregates'] as Map<String, dynamic>,
            ),
      groups: (json['groups'] as List)
          .map(
            (item) => AdminUsageQueryRow.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      metadata: AdminUsageQueryMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (aggregates != null) 'aggregates': aggregates!.toJson(),
    'groups': groups.map((item) => item.toJson()).toList(),
    'metadata': metadata.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageQueryResult copyWith({
    Object? aggregates = unsetCopyWithValue,
    List<AdminUsageQueryRow>? groups,
    AdminUsageQueryMetadata? metadata,
  }) => AdminUsageQueryResult(
    aggregates: aggregates == unsetCopyWithValue
        ? this.aggregates
        : aggregates as AdminUsageQueryAggregates?,
    groups: groups ?? this.groups,
    metadata: metadata ?? this.metadata,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageQueryResult &&
          runtimeType == other.runtimeType &&
          aggregates == other.aggregates &&
          valuesDeepEqual(groups, other.groups) &&
          metadata == other.metadata;

  @override
  int get hashCode =>
      Object.hashAll([aggregates, valueDeepHashCode(groups), metadata]);

  @override
  String toString() =>
      'AdminUsageQueryResult('
      'aggregates: $aggregates, '
      'groups: ${groups.length}, '
      'metadata: $metadata)';
}

/// Administrative rate limits.
@immutable
class AdminRateLimits {
  /// Creates a [AdminRateLimits].
  const AdminRateLimits({
    required this.requestsPerSecond,
    required this.tokensLimitsByModel,
  });

  /// Maximum API requests allowed per second.
  final int requestsPerSecond;

  /// Token limits for each model.
  final Map<String, AdminModelRateLimits> tokensLimitsByModel;

  /// Parses a [AdminRateLimits] from JSON.
  factory AdminRateLimits.fromJson(Map<String, dynamic> json) {
    if (json['requests_per_second'] == null) {
      throw const FormatException(
        'AdminRateLimits: missing requests_per_second',
      );
    }
    if (json['tokens_limits_by_model'] == null) {
      throw const FormatException(
        'AdminRateLimits: missing tokens_limits_by_model',
      );
    }
    return AdminRateLimits(
      requestsPerSecond: json['requests_per_second'] as int,
      tokensLimitsByModel:
          (json['tokens_limits_by_model'] as Map<String, dynamic>).map(
            (key, item) => MapEntry(
              key,
              AdminModelRateLimits.fromJson(item as Map<String, dynamic>),
            ),
          ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'requests_per_second': requestsPerSecond,
    'tokens_limits_by_model': tokensLimitsByModel.map(
      (key, item) => MapEntry(key, item.toJson()),
    ),
  };

  /// Creates a copy with the given fields replaced.
  AdminRateLimits copyWith({
    int? requestsPerSecond,
    Map<String, AdminModelRateLimits>? tokensLimitsByModel,
  }) => AdminRateLimits(
    requestsPerSecond: requestsPerSecond ?? this.requestsPerSecond,
    tokensLimitsByModel: tokensLimitsByModel ?? this.tokensLimitsByModel,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminRateLimits &&
          runtimeType == other.runtimeType &&
          requestsPerSecond == other.requestsPerSecond &&
          valuesDeepEqual(tokensLimitsByModel, other.tokensLimitsByModel);

  @override
  int get hashCode => Object.hashAll([
    requestsPerSecond,
    valueDeepHashCode(tokensLimitsByModel),
  ]);

  @override
  String toString() =>
      'AdminRateLimits('
      'requestsPerSecond: $requestsPerSecond, '
      'tokensLimitsByModel: ${tokensLimitsByModel.length})';
}

/// Administrative spend limits.
@immutable
class AdminSpendLimits {
  /// Creates a [AdminSpendLimits].
  const AdminSpendLimits({required this.limits});

  /// Usage, rate, and job limits for the Organization.
  final AdminSpendLimitContext limits;

  /// Parses a [AdminSpendLimits] from JSON.
  factory AdminSpendLimits.fromJson(Map<String, dynamic> json) {
    if (json['limits'] == null) {
      throw const FormatException('AdminSpendLimits: missing limits');
    }
    return AdminSpendLimits(
      limits: AdminSpendLimitContext.fromJson(
        json['limits'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'limits': limits.toJson()};

  /// Creates a copy with the given fields replaced.
  AdminSpendLimits copyWith({AdminSpendLimitContext? limits}) =>
      AdminSpendLimits(limits: limits ?? this.limits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminSpendLimits &&
          runtimeType == other.runtimeType &&
          limits == other.limits;

  @override
  int get hashCode => Object.hashAll([limits]);

  @override
  String toString() =>
      'AdminSpendLimits('
      'limits: $limits)';
}

/// Administrative update admin spend limit request.
@immutable
class UpdateAdminSpendLimitRequest {
  /// Creates a [UpdateAdminSpendLimitRequest].
  const UpdateAdminSpendLimitRequest({
    required this.amount,
    this.noMonthlyLimit,
  });

  /// New monthly usage limit amount.
  final int amount;

  /// Whether to remove the monthly usage limit.
  final bool? noMonthlyLimit;

  /// Parses a [UpdateAdminSpendLimitRequest] from JSON.
  factory UpdateAdminSpendLimitRequest.fromJson(Map<String, dynamic> json) {
    if (json['amount'] == null) {
      throw const FormatException(
        'UpdateAdminSpendLimitRequest: missing amount',
      );
    }
    return UpdateAdminSpendLimitRequest(
      amount: json['amount'] as int,
      noMonthlyLimit: json['no_monthly_limit'] == null
          ? null
          : json['no_monthly_limit'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'no_monthly_limit': ?noMonthlyLimit,
  };

  /// Creates a copy with the given fields replaced.
  UpdateAdminSpendLimitRequest copyWith({
    int? amount,
    Object? noMonthlyLimit = unsetCopyWithValue,
  }) => UpdateAdminSpendLimitRequest(
    amount: amount ?? this.amount,
    noMonthlyLimit: noMonthlyLimit == unsetCopyWithValue
        ? this.noMonthlyLimit
        : noMonthlyLimit as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminSpendLimitRequest &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          noMonthlyLimit == other.noMonthlyLimit;

  @override
  int get hashCode => Object.hashAll([amount, noMonthlyLimit]);

  @override
  String toString() =>
      'UpdateAdminSpendLimitRequest('
      'amount: $amount, '
      'noMonthlyLimit: $noMonthlyLimit)';
}

/// Values for AdminApiZone.
enum AdminApiZone {
  /// Represents global.
  global('global'),

  /// Represents us.
  us('us'),

  /// Represents eu.
  eu('eu'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminApiZone(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminApiZone fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Administrative model usage.
@immutable
class AdminModelUsage {
  /// Creates a [AdminModelUsage].
  const AdminModelUsage({required this.models});

  /// Usage data grouped by model.
  final Map<String, Map<String, List<Map<String, dynamic>>>> models;

  /// Parses a [AdminModelUsage] from JSON.
  factory AdminModelUsage.fromJson(Map<String, dynamic> json) {
    if (json['models'] == null) {
      throw const FormatException('AdminModelUsage: missing models');
    }
    return AdminModelUsage(
      models: (json['models'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(
          key,
          (item as Map<String, dynamic>).map(
            (key, item) => MapEntry(
              key,
              (item as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'models': models};

  /// Creates a copy with the given fields replaced.
  AdminModelUsage copyWith({
    Map<String, Map<String, List<Map<String, dynamic>>>>? models,
  }) => AdminModelUsage(models: models ?? this.models);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminModelUsage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(models, other.models);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(models)]);

  @override
  String toString() =>
      'AdminModelUsage('
      'models: ${models.length})';
}

/// Administrative fine tuning usage.
@immutable
class AdminFineTuningUsage {
  /// Creates a [AdminFineTuningUsage].
  const AdminFineTuningUsage({required this.storage, required this.training});

  /// Fine-tuning storage usage.
  final Map<String, int> storage;

  /// Fine-tuning training usage.
  final Map<String, Map<String, List<Map<String, dynamic>>>> training;

  /// Parses a [AdminFineTuningUsage] from JSON.
  factory AdminFineTuningUsage.fromJson(Map<String, dynamic> json) {
    if (json['storage'] == null) {
      throw const FormatException('AdminFineTuningUsage: missing storage');
    }
    if (json['training'] == null) {
      throw const FormatException('AdminFineTuningUsage: missing training');
    }
    return AdminFineTuningUsage(
      storage: (json['storage'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(key, item as int),
      ),
      training: (json['training'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(
          key,
          (item as Map<String, dynamic>).map(
            (key, item) => MapEntry(
              key,
              (item as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'storage': storage, 'training': training};

  /// Creates a copy with the given fields replaced.
  AdminFineTuningUsage copyWith({
    Map<String, int>? storage,
    Map<String, Map<String, List<Map<String, dynamic>>>>? training,
  }) => AdminFineTuningUsage(
    storage: storage ?? this.storage,
    training: training ?? this.training,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminFineTuningUsage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(storage, other.storage) &&
          valuesDeepEqual(training, other.training);

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(storage), valueDeepHashCode(training)]);

  @override
  String toString() =>
      'AdminFineTuningUsage('
      'storage: ${storage.length}, '
      'training: ${training.length})';
}

/// Administrative libraries usage.
@immutable
class AdminLibrariesUsage {
  /// Creates a [AdminLibrariesUsage].
  const AdminLibrariesUsage({
    required this.audioSeconds,
    required this.pages,
    required this.tokens,
  });

  /// Audio usage for Libraries API.
  final AdminModelUsage audioSeconds;

  /// Page usage for Libraries API.
  final AdminModelUsage pages;

  /// Token usage for Libraries API.
  final AdminModelUsage tokens;

  /// Parses a [AdminLibrariesUsage] from JSON.
  factory AdminLibrariesUsage.fromJson(Map<String, dynamic> json) {
    if (json['audio_seconds'] == null) {
      throw const FormatException('AdminLibrariesUsage: missing audio_seconds');
    }
    if (json['pages'] == null) {
      throw const FormatException('AdminLibrariesUsage: missing pages');
    }
    if (json['tokens'] == null) {
      throw const FormatException('AdminLibrariesUsage: missing tokens');
    }
    return AdminLibrariesUsage(
      audioSeconds: AdminModelUsage.fromJson(
        json['audio_seconds'] as Map<String, dynamic>,
      ),
      pages: AdminModelUsage.fromJson(json['pages'] as Map<String, dynamic>),
      tokens: AdminModelUsage.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'audio_seconds': audioSeconds.toJson(),
    'pages': pages.toJson(),
    'tokens': tokens.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminLibrariesUsage copyWith({
    AdminModelUsage? audioSeconds,
    AdminModelUsage? pages,
    AdminModelUsage? tokens,
  }) => AdminLibrariesUsage(
    audioSeconds: audioSeconds ?? this.audioSeconds,
    pages: pages ?? this.pages,
    tokens: tokens ?? this.tokens,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminLibrariesUsage &&
          runtimeType == other.runtimeType &&
          audioSeconds == other.audioSeconds &&
          pages == other.pages &&
          tokens == other.tokens;

  @override
  int get hashCode => Object.hashAll([audioSeconds, pages, tokens]);

  @override
  String toString() =>
      'AdminLibrariesUsage('
      'audioSeconds: $audioSeconds, '
      'pages: $pages, '
      'tokens: $tokens)';
}

/// A unit price encoded as a JSON number or an exact decimal string.
@immutable
sealed class AdminUsagePriceValue {
  const AdminUsagePriceValue();

  /// Parses the published numeric and string representations.
  factory AdminUsagePriceValue.fromJson(Object? value) => switch (value) {
    final num amount => AdminNumericPrice(amount),
    final String amount => AdminDecimalPrice(amount),
    _ => throw const FormatException('Expected a number or decimal string.'),
  };

  /// The original wire representation.
  Object toJson();
}

/// A unit price transmitted as a JSON number.
final class AdminNumericPrice extends AdminUsagePriceValue {
  /// Creates a numeric price.
  const AdminNumericPrice(this.amount);

  /// Numeric amount.
  final num amount;

  @override
  num toJson() => amount;

  @override
  bool operator ==(Object other) =>
      other is AdminNumericPrice && other.amount == amount;

  @override
  int get hashCode => Object.hash(runtimeType, amount);

  @override
  String toString() => 'AdminNumericPrice($amount)';
}

/// A unit price transmitted as a string to retain its exact decimal digits.
final class AdminDecimalPrice extends AdminUsagePriceValue {
  /// Creates a decimal price.
  const AdminDecimalPrice(this.amount);

  /// Exact decimal amount.
  final String amount;

  @override
  String toJson() => amount;

  @override
  bool operator ==(Object other) =>
      other is AdminDecimalPrice && other.amount == amount;

  @override
  int get hashCode => Object.hash(runtimeType, amount);

  @override
  String toString() => 'AdminDecimalPrice($amount)';
}

/// Administrative usage price.
@immutable
class AdminUsagePrice {
  /// Creates a [AdminUsagePrice].
  const AdminUsagePrice({
    required this.apiZone,
    required this.billingGroup,
    required this.billingMetric,
    required this.eventType,
    required this.price,
    required this.serviceTier,
  });

  /// API zone this price applies to.
  final AdminApiZone apiZone;

  /// Billing metric group this price applies to.
  final String billingGroup;

  /// Billing metric this price applies to.
  final String billingMetric;

  /// Billing event type for the price.
  final AdminBillingEventType? eventType;

  /// Unit price for the billing metric.
  final AdminUsagePriceValue price;

  /// Service tier this price applies to.
  final AdminBilledServiceTier serviceTier;

  /// Parses a [AdminUsagePrice] from JSON.
  factory AdminUsagePrice.fromJson(Map<String, dynamic> json) {
    if (json['api_zone'] == null) {
      throw const FormatException('AdminUsagePrice: missing api_zone');
    }
    if (json['billing_group'] == null) {
      throw const FormatException('AdminUsagePrice: missing billing_group');
    }
    if (json['billing_metric'] == null) {
      throw const FormatException('AdminUsagePrice: missing billing_metric');
    }
    if (!json.containsKey('event_type')) {
      throw const FormatException('AdminUsagePrice: missing event_type');
    }
    if (json['price'] == null) {
      throw const FormatException('AdminUsagePrice: missing price');
    }
    if (json['service_tier'] == null) {
      throw const FormatException('AdminUsagePrice: missing service_tier');
    }
    return AdminUsagePrice(
      apiZone: AdminApiZone.fromJson(json['api_zone'] as String),
      billingGroup: json['billing_group'] as String,
      billingMetric: json['billing_metric'] as String,
      eventType: json['event_type'] == null
          ? null
          : AdminBillingEventType.fromJson(json['event_type'] as String),
      price: AdminUsagePriceValue.fromJson(json['price']),
      serviceTier: AdminBilledServiceTier.fromJson(
        json['service_tier'] as String,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'api_zone': apiZone.toJson(),
    'billing_group': billingGroup,
    'billing_metric': billingMetric,
    'event_type': eventType?.toJson(),
    'price': price.toJson(),
    'service_tier': serviceTier.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminUsagePrice copyWith({
    AdminApiZone? apiZone,
    String? billingGroup,
    String? billingMetric,
    Object? eventType = unsetCopyWithValue,
    AdminUsagePriceValue? price,
    AdminBilledServiceTier? serviceTier,
  }) => AdminUsagePrice(
    apiZone: apiZone ?? this.apiZone,
    billingGroup: billingGroup ?? this.billingGroup,
    billingMetric: billingMetric ?? this.billingMetric,
    eventType: eventType == unsetCopyWithValue
        ? this.eventType
        : eventType as AdminBillingEventType?,
    price: price ?? this.price,
    serviceTier: serviceTier ?? this.serviceTier,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsagePrice &&
          runtimeType == other.runtimeType &&
          apiZone == other.apiZone &&
          billingGroup == other.billingGroup &&
          billingMetric == other.billingMetric &&
          eventType == other.eventType &&
          price == other.price &&
          serviceTier == other.serviceTier;

  @override
  int get hashCode => Object.hashAll([
    apiZone,
    billingGroup,
    billingMetric,
    eventType,
    price,
    serviceTier,
  ]);

  @override
  String toString() =>
      'AdminUsagePrice('
      'apiZone: $apiZone, '
      'billingGroup: $billingGroup, '
      'billingMetric: $billingMetric, '
      'eventType: $eventType, '
      'price: $price, '
      'serviceTier: $serviceTier)';
}

/// Administrative vibe code usage.
@immutable
class AdminVibeCodeUsage {
  /// Creates a [AdminVibeCodeUsage].
  const AdminVibeCodeUsage({
    required this.audio,
    required this.audioCharacters,
    required this.completion,
    required this.connectors,
    required this.ocr,
  });

  /// Vibe Code audio transcription usage data.
  final AdminModelUsage audio;

  /// Vibe Code text-to-speech usage data.
  final AdminModelUsage audioCharacters;

  /// Vibe Code completion (token) usage data.
  final AdminModelUsage completion;

  /// Vibe Code connectors usage data.
  final AdminModelUsage connectors;

  /// Vibe Code OCR usage data.
  final AdminModelUsage ocr;

  /// Parses a [AdminVibeCodeUsage] from JSON.
  factory AdminVibeCodeUsage.fromJson(Map<String, dynamic> json) {
    if (json['audio'] == null) {
      throw const FormatException('AdminVibeCodeUsage: missing audio');
    }
    if (json['audio_characters'] == null) {
      throw const FormatException(
        'AdminVibeCodeUsage: missing audio_characters',
      );
    }
    if (json['completion'] == null) {
      throw const FormatException('AdminVibeCodeUsage: missing completion');
    }
    if (json['connectors'] == null) {
      throw const FormatException('AdminVibeCodeUsage: missing connectors');
    }
    if (json['ocr'] == null) {
      throw const FormatException('AdminVibeCodeUsage: missing ocr');
    }
    return AdminVibeCodeUsage(
      audio: AdminModelUsage.fromJson(json['audio'] as Map<String, dynamic>),
      audioCharacters: AdminModelUsage.fromJson(
        json['audio_characters'] as Map<String, dynamic>,
      ),
      completion: AdminModelUsage.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      connectors: AdminModelUsage.fromJson(
        json['connectors'] as Map<String, dynamic>,
      ),
      ocr: AdminModelUsage.fromJson(json['ocr'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'audio': audio.toJson(),
    'audio_characters': audioCharacters.toJson(),
    'completion': completion.toJson(),
    'connectors': connectors.toJson(),
    'ocr': ocr.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminVibeCodeUsage copyWith({
    AdminModelUsage? audio,
    AdminModelUsage? audioCharacters,
    AdminModelUsage? completion,
    AdminModelUsage? connectors,
    AdminModelUsage? ocr,
  }) => AdminVibeCodeUsage(
    audio: audio ?? this.audio,
    audioCharacters: audioCharacters ?? this.audioCharacters,
    completion: completion ?? this.completion,
    connectors: connectors ?? this.connectors,
    ocr: ocr ?? this.ocr,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminVibeCodeUsage &&
          runtimeType == other.runtimeType &&
          audio == other.audio &&
          audioCharacters == other.audioCharacters &&
          completion == other.completion &&
          connectors == other.connectors &&
          ocr == other.ocr;

  @override
  int get hashCode =>
      Object.hashAll([audio, audioCharacters, completion, connectors, ocr]);

  @override
  String toString() =>
      'AdminVibeCodeUsage('
      'audio: $audio, '
      'audioCharacters: $audioCharacters, '
      'completion: $completion, '
      'connectors: $connectors, '
      'ocr: $ocr)';
}

/// Administrative usage filter.
@immutable
class AdminUsageFilter {
  /// Creates a [AdminUsageFilter].
  const AdminUsageFilter({
    required this.field,
    required this.matchOperator,
    required this.values,
  });

  /// Usage dimension to filter.
  final String field;

  /// Whether rows must match or must not match the supplied values.
  final String matchOperator;

  /// Accepted or excluded values. Use null to filter missing dimension values.
  final List<String?> values;

  /// Parses a [AdminUsageFilter] from JSON.
  factory AdminUsageFilter.fromJson(Map<String, dynamic> json) {
    if (json['field'] == null) {
      throw const FormatException('AdminUsageFilter: missing field');
    }
    if (json['operator'] == null) {
      throw const FormatException('AdminUsageFilter: missing operator');
    }
    if (json['values'] == null) {
      throw const FormatException('AdminUsageFilter: missing values');
    }
    return AdminUsageFilter(
      field: json['field'] as String,
      matchOperator: json['operator'] as String,
      values: (json['values'] as List).map((item) => item as String?).toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'field': field,
    'operator': matchOperator,
    'values': values,
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageFilter copyWith({
    String? field,
    String? matchOperator,
    List<String?>? values,
  }) => AdminUsageFilter(
    field: field ?? this.field,
    matchOperator: matchOperator ?? this.matchOperator,
    values: values ?? this.values,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageFilter &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          matchOperator == other.matchOperator &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode =>
      Object.hashAll([field, matchOperator, valueDeepHashCode(values)]);

  @override
  String toString() =>
      'AdminUsageFilter('
      'field: $field, '
      'matchOperator: $matchOperator, '
      'values: ${values.length})';
}

/// Values for AdminUsageType.
enum AdminUsageType {
  /// Represents usage.
  usage('usage'),

  /// Represents codestral.
  codestral('codestral'),

  /// Represents document_library.
  documentLibrary('document_library'),

  /// Represents document_library_api.
  documentLibraryApi('document_library_api'),

  /// Represents libraries_pages.
  librariesPages('libraries_pages'),

  /// Represents libraries_tokens.
  librariesTokens('libraries_tokens'),

  /// Represents libraries_audio.
  librariesAudio('libraries_audio'),

  /// Represents chat.
  chat('chat'),

  /// Represents rlhf.
  rlhf('rlhf'),

  /// Represents ocr.
  ocr('ocr'),

  /// Represents audio_seconds.
  audioSeconds('audio_seconds'),

  /// Represents audio_characters.
  audioCharacters('audio_characters'),

  /// Represents audio_agents.
  audioAgents('audio_agents'),

  /// Represents connectors.
  connectors('connectors'),

  /// Represents workflow_executions.
  workflowExecutions('workflow_executions'),

  /// Represents skill_activations.
  skillActivations('skill_activations'),

  /// Represents managed_index_storage_bytes.
  managedIndexStorageBytes('managed_index_storage_bytes'),

  /// Represents managed_index_written_bytes.
  managedIndexWrittenBytes('managed_index_written_bytes'),

  /// Represents managed_index_searches.
  managedIndexSearches('managed_index_searches'),

  /// Represents vibe.
  vibe('vibe'),

  /// Represents vibe_connectors.
  vibeConnectors('vibe_connectors'),

  /// Represents vibe_ocr.
  vibeOcr('vibe_ocr'),

  /// Represents vibe_audio_seconds.
  vibeAudioSeconds('vibe_audio_seconds'),

  /// Represents vibe_audio_characters.
  vibeAudioCharacters('vibe_audio_characters'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminUsageType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminUsageType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Administrative usage query aggregates.
@immutable
class AdminUsageQueryAggregates {
  /// Creates a [AdminUsageQueryAggregates].
  const AdminUsageQueryAggregates({
    required this.customerCount,
    required this.totalApiCalls,
    required this.totalCount,
    required this.totalValue,
    required this.usageTypeCount,
  });

  /// Number of matching customers.
  final int customerCount;

  /// Total number of distinct API calls.
  final int totalApiCalls;

  /// Total number of matching usage records.
  final int totalCount;

  /// Total usage value across all matching rows.
  final double totalValue;

  /// Number of matching usage types.
  final int usageTypeCount;

  /// Parses a [AdminUsageQueryAggregates] from JSON.
  factory AdminUsageQueryAggregates.fromJson(Map<String, dynamic> json) {
    if (json['customer_count'] == null) {
      throw const FormatException(
        'AdminUsageQueryAggregates: missing customer_count',
      );
    }
    if (json['total_api_calls'] == null) {
      throw const FormatException(
        'AdminUsageQueryAggregates: missing total_api_calls',
      );
    }
    if (json['total_count'] == null) {
      throw const FormatException(
        'AdminUsageQueryAggregates: missing total_count',
      );
    }
    if (json['total_value'] == null) {
      throw const FormatException(
        'AdminUsageQueryAggregates: missing total_value',
      );
    }
    if (json['usage_type_count'] == null) {
      throw const FormatException(
        'AdminUsageQueryAggregates: missing usage_type_count',
      );
    }
    return AdminUsageQueryAggregates(
      customerCount: json['customer_count'] as int,
      totalApiCalls: json['total_api_calls'] as int,
      totalCount: json['total_count'] as int,
      totalValue: (json['total_value'] as num).toDouble(),
      usageTypeCount: json['usage_type_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'customer_count': customerCount,
    'total_api_calls': totalApiCalls,
    'total_count': totalCount,
    'total_value': totalValue,
    'usage_type_count': usageTypeCount,
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageQueryAggregates copyWith({
    int? customerCount,
    int? totalApiCalls,
    int? totalCount,
    double? totalValue,
    int? usageTypeCount,
  }) => AdminUsageQueryAggregates(
    customerCount: customerCount ?? this.customerCount,
    totalApiCalls: totalApiCalls ?? this.totalApiCalls,
    totalCount: totalCount ?? this.totalCount,
    totalValue: totalValue ?? this.totalValue,
    usageTypeCount: usageTypeCount ?? this.usageTypeCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageQueryAggregates &&
          runtimeType == other.runtimeType &&
          customerCount == other.customerCount &&
          totalApiCalls == other.totalApiCalls &&
          totalCount == other.totalCount &&
          totalValue == other.totalValue &&
          usageTypeCount == other.usageTypeCount;

  @override
  int get hashCode => Object.hashAll([
    customerCount,
    totalApiCalls,
    totalCount,
    totalValue,
    usageTypeCount,
  ]);

  @override
  String toString() =>
      'AdminUsageQueryAggregates('
      'customerCount: $customerCount, '
      'totalApiCalls: $totalApiCalls, '
      'totalCount: $totalCount, '
      'totalValue: $totalValue, '
      'usageTypeCount: $usageTypeCount)';
}

/// Administrative usage query row.
@immutable
class AdminUsageQueryRow {
  /// Creates a [AdminUsageQueryRow].
  const AdminUsageQueryRow({
    this.apiKeyId,
    this.apiZone,
    this.billingDisplayName,
    this.billingGroup,
    this.billingMetric,
    this.callSource,
    this.callType,
    this.count,
    this.customerId,
    this.customerTier,
    this.nbApiCalls,
    this.organizationId,
    this.resourceId,
    this.resourceVersion,
    this.serviceAccountId,
    this.serviceTier,
    this.timeBucket,
    this.timestamp,
    this.untracked,
    this.usageType,
    this.userAgent,
    this.userId,
    this.value,
    this.workspaceId,
  });

  /// API key ID.
  final String? apiKeyId;

  /// Inference region.
  final String? apiZone;

  /// Customer-facing billing metric name.
  final String? billingDisplayName;

  /// Billing metric component.
  final String? billingGroup;

  /// Billing metric identifier.
  final String? billingMetric;

  /// Product source of the call.
  final String? callSource;

  /// Type of call within its source.
  final String? callType;

  /// Number of usage records in this row.
  final int? count;

  /// Customer ID for this row.
  final String? customerId;

  /// Customer tier.
  final String? customerTier;

  /// Number of distinct API calls.
  final int? nbApiCalls;

  /// Organization ID.
  final String? organizationId;

  /// ID of the resource the usage is attributed to, such as a workflow ID.
  final String? resourceId;

  /// Version of the resource the usage is attributed to, when the resource is versioned.
  final String? resourceVersion;

  /// Service account ID.
  final String? serviceAccountId;

  /// Service tier.
  final String? serviceTier;

  /// Start of the UTC time bucket, expressed using the request start timestamp's UTC offset.
  final String? timeBucket;

  /// Timestamp of an unbucketed usage row, expressed using the request start timestamp's UTC offset.
  final String? timestamp;

  /// Whether attribution was unavailable.
  final bool? untracked;

  /// Usage event type.
  final String? usageType;

  /// Harness identified from the request User-Agent header.
  final String? userAgent;

  /// User ID.
  final String? userId;

  /// Total usage value for this row.
  final int? value;

  /// Workspace ID.
  final String? workspaceId;

  /// Parses a [AdminUsageQueryRow] from JSON.
  factory AdminUsageQueryRow.fromJson(Map<String, dynamic> json) {
    return AdminUsageQueryRow(
      apiKeyId: json['api_key_id'] == null
          ? null
          : json['api_key_id'] as String,
      apiZone: json['api_zone'] == null ? null : json['api_zone'] as String,
      billingDisplayName: json['billing_display_name'] == null
          ? null
          : json['billing_display_name'] as String,
      billingGroup: json['billing_group'] == null
          ? null
          : json['billing_group'] as String,
      billingMetric: json['billing_metric'] == null
          ? null
          : json['billing_metric'] as String,
      callSource: json['call_source'] == null
          ? null
          : json['call_source'] as String,
      callType: json['call_type'] == null ? null : json['call_type'] as String,
      count: json['count'] == null ? null : json['count'] as int,
      customerId: json['customer_id'] == null
          ? null
          : json['customer_id'] as String,
      customerTier: json['customer_tier'] == null
          ? null
          : json['customer_tier'] as String,
      nbApiCalls: json['nb_api_calls'] == null
          ? null
          : json['nb_api_calls'] as int,
      organizationId: json['organization_id'] == null
          ? null
          : json['organization_id'] as String,
      resourceId: json['resource_id'] == null
          ? null
          : json['resource_id'] as String,
      resourceVersion: json['resource_version'] == null
          ? null
          : json['resource_version'] as String,
      serviceAccountId: json['service_account_id'] == null
          ? null
          : json['service_account_id'] as String,
      serviceTier: json['service_tier'] == null
          ? null
          : json['service_tier'] as String,
      timeBucket: json['time_bucket'] == null
          ? null
          : json['time_bucket'] as String,
      timestamp: json['timestamp'] == null ? null : json['timestamp'] as String,
      untracked: json['untracked'] == null ? null : json['untracked'] as bool,
      usageType: json['usage_type'] == null
          ? null
          : json['usage_type'] as String,
      userAgent: json['user_agent'] == null
          ? null
          : json['user_agent'] as String,
      userId: json['user_id'] == null ? null : json['user_id'] as String,
      value: json['value'] == null ? null : json['value'] as int,
      workspaceId: json['workspace_id'] == null
          ? null
          : json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'api_key_id': ?apiKeyId,
    'api_zone': ?apiZone,
    'billing_display_name': ?billingDisplayName,
    'billing_group': ?billingGroup,
    'billing_metric': ?billingMetric,
    'call_source': ?callSource,
    'call_type': ?callType,
    'count': ?count,
    'customer_id': ?customerId,
    'customer_tier': ?customerTier,
    'nb_api_calls': ?nbApiCalls,
    'organization_id': ?organizationId,
    'resource_id': ?resourceId,
    'resource_version': ?resourceVersion,
    'service_account_id': ?serviceAccountId,
    'service_tier': ?serviceTier,
    'time_bucket': ?timeBucket,
    'timestamp': ?timestamp,
    'untracked': ?untracked,
    'usage_type': ?usageType,
    'user_agent': ?userAgent,
    'user_id': ?userId,
    'value': ?value,
    'workspace_id': ?workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageQueryRow copyWith({
    Object? apiKeyId = unsetCopyWithValue,
    Object? apiZone = unsetCopyWithValue,
    Object? billingDisplayName = unsetCopyWithValue,
    Object? billingGroup = unsetCopyWithValue,
    Object? billingMetric = unsetCopyWithValue,
    Object? callSource = unsetCopyWithValue,
    Object? callType = unsetCopyWithValue,
    Object? count = unsetCopyWithValue,
    Object? customerId = unsetCopyWithValue,
    Object? customerTier = unsetCopyWithValue,
    Object? nbApiCalls = unsetCopyWithValue,
    Object? organizationId = unsetCopyWithValue,
    Object? resourceId = unsetCopyWithValue,
    Object? resourceVersion = unsetCopyWithValue,
    Object? serviceAccountId = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? timeBucket = unsetCopyWithValue,
    Object? timestamp = unsetCopyWithValue,
    Object? untracked = unsetCopyWithValue,
    Object? usageType = unsetCopyWithValue,
    Object? userAgent = unsetCopyWithValue,
    Object? userId = unsetCopyWithValue,
    Object? value = unsetCopyWithValue,
    Object? workspaceId = unsetCopyWithValue,
  }) => AdminUsageQueryRow(
    apiKeyId: apiKeyId == unsetCopyWithValue
        ? this.apiKeyId
        : apiKeyId as String?,
    apiZone: apiZone == unsetCopyWithValue ? this.apiZone : apiZone as String?,
    billingDisplayName: billingDisplayName == unsetCopyWithValue
        ? this.billingDisplayName
        : billingDisplayName as String?,
    billingGroup: billingGroup == unsetCopyWithValue
        ? this.billingGroup
        : billingGroup as String?,
    billingMetric: billingMetric == unsetCopyWithValue
        ? this.billingMetric
        : billingMetric as String?,
    callSource: callSource == unsetCopyWithValue
        ? this.callSource
        : callSource as String?,
    callType: callType == unsetCopyWithValue
        ? this.callType
        : callType as String?,
    count: count == unsetCopyWithValue ? this.count : count as int?,
    customerId: customerId == unsetCopyWithValue
        ? this.customerId
        : customerId as String?,
    customerTier: customerTier == unsetCopyWithValue
        ? this.customerTier
        : customerTier as String?,
    nbApiCalls: nbApiCalls == unsetCopyWithValue
        ? this.nbApiCalls
        : nbApiCalls as int?,
    organizationId: organizationId == unsetCopyWithValue
        ? this.organizationId
        : organizationId as String?,
    resourceId: resourceId == unsetCopyWithValue
        ? this.resourceId
        : resourceId as String?,
    resourceVersion: resourceVersion == unsetCopyWithValue
        ? this.resourceVersion
        : resourceVersion as String?,
    serviceAccountId: serviceAccountId == unsetCopyWithValue
        ? this.serviceAccountId
        : serviceAccountId as String?,
    serviceTier: serviceTier == unsetCopyWithValue
        ? this.serviceTier
        : serviceTier as String?,
    timeBucket: timeBucket == unsetCopyWithValue
        ? this.timeBucket
        : timeBucket as String?,
    timestamp: timestamp == unsetCopyWithValue
        ? this.timestamp
        : timestamp as String?,
    untracked: untracked == unsetCopyWithValue
        ? this.untracked
        : untracked as bool?,
    usageType: usageType == unsetCopyWithValue
        ? this.usageType
        : usageType as String?,
    userAgent: userAgent == unsetCopyWithValue
        ? this.userAgent
        : userAgent as String?,
    userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
    value: value == unsetCopyWithValue ? this.value : value as int?,
    workspaceId: workspaceId == unsetCopyWithValue
        ? this.workspaceId
        : workspaceId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageQueryRow &&
          runtimeType == other.runtimeType &&
          apiKeyId == other.apiKeyId &&
          apiZone == other.apiZone &&
          billingDisplayName == other.billingDisplayName &&
          billingGroup == other.billingGroup &&
          billingMetric == other.billingMetric &&
          callSource == other.callSource &&
          callType == other.callType &&
          count == other.count &&
          customerId == other.customerId &&
          customerTier == other.customerTier &&
          nbApiCalls == other.nbApiCalls &&
          organizationId == other.organizationId &&
          resourceId == other.resourceId &&
          resourceVersion == other.resourceVersion &&
          serviceAccountId == other.serviceAccountId &&
          serviceTier == other.serviceTier &&
          timeBucket == other.timeBucket &&
          timestamp == other.timestamp &&
          untracked == other.untracked &&
          usageType == other.usageType &&
          userAgent == other.userAgent &&
          userId == other.userId &&
          value == other.value &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    apiKeyId,
    apiZone,
    billingDisplayName,
    billingGroup,
    billingMetric,
    callSource,
    callType,
    count,
    customerId,
    customerTier,
    nbApiCalls,
    organizationId,
    resourceId,
    resourceVersion,
    serviceAccountId,
    serviceTier,
    timeBucket,
    timestamp,
    untracked,
    usageType,
    userAgent,
    userId,
    value,
    workspaceId,
  ]);

  @override
  String toString() =>
      'AdminUsageQueryRow('
      'apiKeyId: $apiKeyId, '
      'apiZone: $apiZone, '
      'billingDisplayName: $billingDisplayName, '
      'billingGroup: $billingGroup, '
      'billingMetric: $billingMetric, '
      'callSource: $callSource, '
      'callType: $callType, '
      'count: $count, '
      'customerId: $customerId, '
      'customerTier: $customerTier, '
      'nbApiCalls: $nbApiCalls, '
      'organizationId: $organizationId, '
      'resourceId: $resourceId, '
      'resourceVersion: $resourceVersion, '
      'serviceAccountId: $serviceAccountId, '
      'serviceTier: $serviceTier, '
      'timeBucket: $timeBucket, '
      'timestamp: $timestamp, '
      'untracked: $untracked, '
      'usageType: $usageType, '
      'userAgent: $userAgent, '
      'userId: $userId, '
      'value: $value, '
      'workspaceId: $workspaceId)';
}

/// Administrative usage query metadata.
@immutable
class AdminUsageQueryMetadata {
  /// Creates a [AdminUsageQueryMetadata].
  const AdminUsageQueryMetadata({
    required this.hasMore,
    required this.queryParams,
  });

  /// Whether another page of grouped rows is available.
  final bool hasMore;

  /// Normalized parameters used by the usage service.
  final AdminUsageQueryParameters queryParams;

  /// Parses a [AdminUsageQueryMetadata] from JSON.
  factory AdminUsageQueryMetadata.fromJson(Map<String, dynamic> json) {
    if (json['has_more'] == null) {
      throw const FormatException('AdminUsageQueryMetadata: missing has_more');
    }
    if (json['query_params'] == null) {
      throw const FormatException(
        'AdminUsageQueryMetadata: missing query_params',
      );
    }
    return AdminUsageQueryMetadata(
      hasMore: json['has_more'] as bool,
      queryParams: AdminUsageQueryParameters.fromJson(
        json['query_params'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'has_more': hasMore,
    'query_params': queryParams.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageQueryMetadata copyWith({
    bool? hasMore,
    AdminUsageQueryParameters? queryParams,
  }) => AdminUsageQueryMetadata(
    hasMore: hasMore ?? this.hasMore,
    queryParams: queryParams ?? this.queryParams,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageQueryMetadata &&
          runtimeType == other.runtimeType &&
          hasMore == other.hasMore &&
          queryParams == other.queryParams;

  @override
  int get hashCode => Object.hashAll([hasMore, queryParams]);

  @override
  String toString() =>
      'AdminUsageQueryMetadata('
      'hasMore: $hasMore, '
      'queryParams: $queryParams)';
}

/// Administrative model rate limits.
@immutable
class AdminModelRateLimits {
  /// Creates a [AdminModelRateLimits].
  const AdminModelRateLimits({
    required this.tokensPerMinute,
    required this.tokensPerMonth,
  });

  /// Maximum tokens allowed per minute.
  final int tokensPerMinute;

  /// Maximum tokens allowed per month.
  final int tokensPerMonth;

  /// Parses a [AdminModelRateLimits] from JSON.
  factory AdminModelRateLimits.fromJson(Map<String, dynamic> json) {
    if (json['tokens_per_minute'] == null) {
      throw const FormatException(
        'AdminModelRateLimits: missing tokens_per_minute',
      );
    }
    if (json['tokens_per_month'] == null) {
      throw const FormatException(
        'AdminModelRateLimits: missing tokens_per_month',
      );
    }
    return AdminModelRateLimits(
      tokensPerMinute: json['tokens_per_minute'] as int,
      tokensPerMonth: json['tokens_per_month'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'tokens_per_minute': tokensPerMinute,
    'tokens_per_month': tokensPerMonth,
  };

  /// Creates a copy with the given fields replaced.
  AdminModelRateLimits copyWith({int? tokensPerMinute, int? tokensPerMonth}) =>
      AdminModelRateLimits(
        tokensPerMinute: tokensPerMinute ?? this.tokensPerMinute,
        tokensPerMonth: tokensPerMonth ?? this.tokensPerMonth,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminModelRateLimits &&
          runtimeType == other.runtimeType &&
          tokensPerMinute == other.tokensPerMinute &&
          tokensPerMonth == other.tokensPerMonth;

  @override
  int get hashCode => Object.hashAll([tokensPerMinute, tokensPerMonth]);

  @override
  String toString() =>
      'AdminModelRateLimits('
      'tokensPerMinute: $tokensPerMinute, '
      'tokensPerMonth: $tokensPerMonth)';
}

/// Administrative spend limit context.
@immutable
class AdminSpendLimitContext {
  /// Creates a [AdminSpendLimitContext].
  const AdminSpendLimitContext({
    required this.completion,
    required this.currency,
    required this.lastPaymentFailure,
    required this.lastPaymentFailureProtection,
  });

  /// Completion usage and rate limits.
  final AdminUsageLimit completion;

  /// Currency used for usage and limit amounts.
  final String currency;

  /// Whether the latest payment attempt failed.
  final bool lastPaymentFailure;

  /// Whether payment failure protection is enabled.
  final bool? lastPaymentFailureProtection;

  /// Parses a [AdminSpendLimitContext] from JSON.
  factory AdminSpendLimitContext.fromJson(Map<String, dynamic> json) {
    if (json['completion'] == null) {
      throw const FormatException('AdminSpendLimitContext: missing completion');
    }
    if (json['currency'] == null) {
      throw const FormatException('AdminSpendLimitContext: missing currency');
    }
    if (json['last_payment_failure'] == null) {
      throw const FormatException(
        'AdminSpendLimitContext: missing last_payment_failure',
      );
    }
    if (!json.containsKey('last_payment_failure_protection')) {
      throw const FormatException(
        'AdminSpendLimitContext: missing last_payment_failure_protection',
      );
    }
    return AdminSpendLimitContext(
      completion: AdminUsageLimit.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      currency: json['currency'] as String,
      lastPaymentFailure: json['last_payment_failure'] as bool,
      lastPaymentFailureProtection:
          json['last_payment_failure_protection'] == null
          ? null
          : json['last_payment_failure_protection'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'completion': completion.toJson(),
    'currency': currency,
    'last_payment_failure': lastPaymentFailure,
    'last_payment_failure_protection': lastPaymentFailureProtection,
  };

  /// Creates a copy with the given fields replaced.
  AdminSpendLimitContext copyWith({
    AdminUsageLimit? completion,
    String? currency,
    bool? lastPaymentFailure,
    Object? lastPaymentFailureProtection = unsetCopyWithValue,
  }) => AdminSpendLimitContext(
    completion: completion ?? this.completion,
    currency: currency ?? this.currency,
    lastPaymentFailure: lastPaymentFailure ?? this.lastPaymentFailure,
    lastPaymentFailureProtection:
        lastPaymentFailureProtection == unsetCopyWithValue
        ? this.lastPaymentFailureProtection
        : lastPaymentFailureProtection as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminSpendLimitContext &&
          runtimeType == other.runtimeType &&
          completion == other.completion &&
          currency == other.currency &&
          lastPaymentFailure == other.lastPaymentFailure &&
          lastPaymentFailureProtection == other.lastPaymentFailureProtection;

  @override
  int get hashCode => Object.hashAll([
    completion,
    currency,
    lastPaymentFailure,
    lastPaymentFailureProtection,
  ]);

  @override
  String toString() =>
      'AdminSpendLimitContext('
      'completion: $completion, '
      'currency: $currency, '
      'lastPaymentFailure: $lastPaymentFailure, '
      'lastPaymentFailureProtection: $lastPaymentFailureProtection)';
}

/// Values for AdminBillingEventType.
enum AdminBillingEventType {
  /// Represents api_tokens.
  apiTokens('api_tokens'),

  /// Represents api_pages.
  apiPages('api_pages'),

  /// Represents api_audio_seconds.
  apiAudioSeconds('api_audio_seconds'),

  /// Represents api_audio_characters.
  apiAudioCharacters('api_audio_characters'),

  /// Represents api_connectors.
  apiConnectors('api_connectors'),

  /// Represents api_libraries_tokens.
  apiLibrariesTokens('api_libraries_tokens'),

  /// Represents api_libraries_pages.
  apiLibrariesPages('api_libraries_pages'),

  /// Represents api_libraries_audio.
  apiLibrariesAudio('api_libraries_audio'),

  /// Represents api_managed_index_storage_bytes.
  apiManagedIndexStorageBytes('api_managed_index_storage_bytes'),

  /// Represents api_managed_index_written_bytes.
  apiManagedIndexWrittenBytes('api_managed_index_written_bytes'),

  /// Represents api_managed_index_searches.
  apiManagedIndexSearches('api_managed_index_searches'),

  /// Represents deployment_tokens.
  deploymentTokens('deployment_tokens'),

  /// Represents gpu_hour.
  gpuHour('gpu_hour'),

  /// Represents reserved_instance.
  reservedInstance('reserved_instance'),

  /// Represents vibe_tokens.
  vibeTokens('vibe_tokens'),

  /// Represents vibe_connectors.
  vibeConnectors('vibe_connectors'),

  /// Represents vibe_pages.
  vibePages('vibe_pages'),

  /// Represents vibe_audio_seconds.
  vibeAudioSeconds('vibe_audio_seconds'),

  /// Represents vibe_audio_characters.
  vibeAudioCharacters('vibe_audio_characters'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminBillingEventType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminBillingEventType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminBilledServiceTier.
enum AdminBilledServiceTier {
  /// Represents standard.
  standard('standard'),

  /// Represents priority.
  priority('priority'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminBilledServiceTier(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminBilledServiceTier fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Administrative usage query parameters.
@immutable
class AdminUsageQueryParameters {
  /// Creates a [AdminUsageQueryParameters].
  const AdminUsageQueryParameters({
    this.apiKeyId,
    this.apiZone,
    this.billingDisplayName,
    this.billingGroup,
    this.billingMetric,
    this.customerId,
    required this.end,
    this.filters,
    this.groupBy,
    this.includeNbApiCalls,
    this.limit,
    this.offset,
    this.organizationId,
    this.serviceAccountId,
    this.serviceTier,
    required this.start,
    this.timeBucket,
    this.untracked,
    this.usageType,
    this.userId,
    this.workspaceIds,
  });

  /// API key IDs to include.
  final List<String>? apiKeyId;

  /// Inference regions to include.
  final List<String>? apiZone;

  /// Customer-facing billing metric names to include.
  final List<String>? billingDisplayName;

  /// Billing metric components to include.
  final List<String>? billingGroup;

  /// Billing metric identifiers to include.
  final List<String>? billingMetric;

  /// Customer scope derived from the authenticated Admin API key.
  final String? customerId;

  /// Exclusive end of the queried interval.
  final String end;

  /// Additional inclusion or exclusion filters applied to the query.
  final List<AdminUsageFilter>? filters;

  /// Dimensions used to group the returned usage rows.
  final List<String>? groupBy;

  /// Whether distinct API-call counts were requested.
  final bool? includeNbApiCalls;

  /// Applied row limit.
  final int? limit;

  /// Applied row offset.
  final int? offset;

  /// Organization IDs to include within the authenticated customer.
  final List<String>? organizationId;

  /// Service account IDs to include.
  final List<String>? serviceAccountId;

  /// Service tiers to include.
  final List<String>? serviceTier;

  /// Inclusive start of the queried interval.
  final String start;

  /// Time interval used to bucket grouped rows.
  final String? timeBucket;

  /// Applied attribution filter.
  final bool? untracked;

  /// Usage event types to include.
  final List<AdminUsageType>? usageType;

  /// User IDs to include.
  final List<String>? userId;

  /// Workspace IDs to include. Use null to include usage without a workspace.
  final List<String?>? workspaceIds;

  /// Parses a [AdminUsageQueryParameters] from JSON.
  factory AdminUsageQueryParameters.fromJson(Map<String, dynamic> json) {
    if (json['end'] == null) {
      throw const FormatException('AdminUsageQueryParameters: missing end');
    }
    if (json['start'] == null) {
      throw const FormatException('AdminUsageQueryParameters: missing start');
    }
    return AdminUsageQueryParameters(
      apiKeyId: json['api_key_id'] == null
          ? null
          : (json['api_key_id'] as List).map((item) => item as String).toList(),
      apiZone: json['api_zone'] == null
          ? null
          : (json['api_zone'] as List).map((item) => item as String).toList(),
      billingDisplayName: json['billing_display_name'] == null
          ? null
          : (json['billing_display_name'] as List)
                .map((item) => item as String)
                .toList(),
      billingGroup: json['billing_group'] == null
          ? null
          : (json['billing_group'] as List)
                .map((item) => item as String)
                .toList(),
      billingMetric: json['billing_metric'] == null
          ? null
          : (json['billing_metric'] as List)
                .map((item) => item as String)
                .toList(),
      customerId: json['customer_id'] == null
          ? null
          : json['customer_id'] as String,
      end: json['end'] as String,
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List)
                .map(
                  (item) =>
                      AdminUsageFilter.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      groupBy: json['group_by'] == null
          ? null
          : (json['group_by'] as List).map((item) => item as String).toList(),
      includeNbApiCalls: json['include_nb_api_calls'] == null
          ? null
          : json['include_nb_api_calls'] as bool,
      limit: json['limit'] == null ? null : json['limit'] as int,
      offset: json['offset'] == null ? null : json['offset'] as int,
      organizationId: json['organization_id'] == null
          ? null
          : (json['organization_id'] as List)
                .map((item) => item as String)
                .toList(),
      serviceAccountId: json['service_account_id'] == null
          ? null
          : (json['service_account_id'] as List)
                .map((item) => item as String)
                .toList(),
      serviceTier: json['service_tier'] == null
          ? null
          : (json['service_tier'] as List)
                .map((item) => item as String)
                .toList(),
      start: json['start'] as String,
      timeBucket: json['time_bucket'] == null
          ? null
          : json['time_bucket'] as String,
      untracked: json['untracked'] == null ? null : json['untracked'] as bool,
      usageType: json['usage_type'] == null
          ? null
          : (json['usage_type'] as List)
                .map((item) => AdminUsageType.fromJson(item as String))
                .toList(),
      userId: json['user_id'] == null
          ? null
          : (json['user_id'] as List).map((item) => item as String).toList(),
      workspaceIds: json['workspace_ids'] == null
          ? null
          : (json['workspace_ids'] as List)
                .map((item) => item as String?)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'api_key_id': ?apiKeyId,
    'api_zone': ?apiZone,
    'billing_display_name': ?billingDisplayName,
    'billing_group': ?billingGroup,
    'billing_metric': ?billingMetric,
    'customer_id': ?customerId,
    'end': end,
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
    'group_by': ?groupBy,
    'include_nb_api_calls': ?includeNbApiCalls,
    'limit': ?limit,
    'offset': ?offset,
    'organization_id': ?organizationId,
    'service_account_id': ?serviceAccountId,
    'service_tier': ?serviceTier,
    'start': start,
    'time_bucket': ?timeBucket,
    'untracked': ?untracked,
    if (usageType != null)
      'usage_type': usageType!.map((item) => item.toJson()).toList(),
    'user_id': ?userId,
    'workspace_ids': ?workspaceIds,
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageQueryParameters copyWith({
    Object? apiKeyId = unsetCopyWithValue,
    Object? apiZone = unsetCopyWithValue,
    Object? billingDisplayName = unsetCopyWithValue,
    Object? billingGroup = unsetCopyWithValue,
    Object? billingMetric = unsetCopyWithValue,
    Object? customerId = unsetCopyWithValue,
    String? end,
    Object? filters = unsetCopyWithValue,
    Object? groupBy = unsetCopyWithValue,
    Object? includeNbApiCalls = unsetCopyWithValue,
    Object? limit = unsetCopyWithValue,
    Object? offset = unsetCopyWithValue,
    Object? organizationId = unsetCopyWithValue,
    Object? serviceAccountId = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    String? start,
    Object? timeBucket = unsetCopyWithValue,
    Object? untracked = unsetCopyWithValue,
    Object? usageType = unsetCopyWithValue,
    Object? userId = unsetCopyWithValue,
    Object? workspaceIds = unsetCopyWithValue,
  }) => AdminUsageQueryParameters(
    apiKeyId: apiKeyId == unsetCopyWithValue
        ? this.apiKeyId
        : (apiKeyId as List?)?.cast<String>(),
    apiZone: apiZone == unsetCopyWithValue
        ? this.apiZone
        : (apiZone as List?)?.cast<String>(),
    billingDisplayName: billingDisplayName == unsetCopyWithValue
        ? this.billingDisplayName
        : (billingDisplayName as List?)?.cast<String>(),
    billingGroup: billingGroup == unsetCopyWithValue
        ? this.billingGroup
        : (billingGroup as List?)?.cast<String>(),
    billingMetric: billingMetric == unsetCopyWithValue
        ? this.billingMetric
        : (billingMetric as List?)?.cast<String>(),
    customerId: customerId == unsetCopyWithValue
        ? this.customerId
        : customerId as String?,
    end: end ?? this.end,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List?)?.cast<AdminUsageFilter>(),
    groupBy: groupBy == unsetCopyWithValue
        ? this.groupBy
        : (groupBy as List?)?.cast<String>(),
    includeNbApiCalls: includeNbApiCalls == unsetCopyWithValue
        ? this.includeNbApiCalls
        : includeNbApiCalls as bool?,
    limit: limit == unsetCopyWithValue ? this.limit : limit as int?,
    offset: offset == unsetCopyWithValue ? this.offset : offset as int?,
    organizationId: organizationId == unsetCopyWithValue
        ? this.organizationId
        : (organizationId as List?)?.cast<String>(),
    serviceAccountId: serviceAccountId == unsetCopyWithValue
        ? this.serviceAccountId
        : (serviceAccountId as List?)?.cast<String>(),
    serviceTier: serviceTier == unsetCopyWithValue
        ? this.serviceTier
        : (serviceTier as List?)?.cast<String>(),
    start: start ?? this.start,
    timeBucket: timeBucket == unsetCopyWithValue
        ? this.timeBucket
        : timeBucket as String?,
    untracked: untracked == unsetCopyWithValue
        ? this.untracked
        : untracked as bool?,
    usageType: usageType == unsetCopyWithValue
        ? this.usageType
        : (usageType as List?)?.cast<AdminUsageType>(),
    userId: userId == unsetCopyWithValue
        ? this.userId
        : (userId as List?)?.cast<String>(),
    workspaceIds: workspaceIds == unsetCopyWithValue
        ? this.workspaceIds
        : (workspaceIds as List?)?.cast<String?>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageQueryParameters &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(apiKeyId, other.apiKeyId) &&
          valuesDeepEqual(apiZone, other.apiZone) &&
          valuesDeepEqual(billingDisplayName, other.billingDisplayName) &&
          valuesDeepEqual(billingGroup, other.billingGroup) &&
          valuesDeepEqual(billingMetric, other.billingMetric) &&
          customerId == other.customerId &&
          end == other.end &&
          valuesDeepEqual(filters, other.filters) &&
          valuesDeepEqual(groupBy, other.groupBy) &&
          includeNbApiCalls == other.includeNbApiCalls &&
          limit == other.limit &&
          offset == other.offset &&
          valuesDeepEqual(organizationId, other.organizationId) &&
          valuesDeepEqual(serviceAccountId, other.serviceAccountId) &&
          valuesDeepEqual(serviceTier, other.serviceTier) &&
          start == other.start &&
          timeBucket == other.timeBucket &&
          untracked == other.untracked &&
          valuesDeepEqual(usageType, other.usageType) &&
          valuesDeepEqual(userId, other.userId) &&
          valuesDeepEqual(workspaceIds, other.workspaceIds);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(apiKeyId),
    valueDeepHashCode(apiZone),
    valueDeepHashCode(billingDisplayName),
    valueDeepHashCode(billingGroup),
    valueDeepHashCode(billingMetric),
    customerId,
    end,
    valueDeepHashCode(filters),
    valueDeepHashCode(groupBy),
    includeNbApiCalls,
    limit,
    offset,
    valueDeepHashCode(organizationId),
    valueDeepHashCode(serviceAccountId),
    valueDeepHashCode(serviceTier),
    start,
    timeBucket,
    untracked,
    valueDeepHashCode(usageType),
    valueDeepHashCode(userId),
    valueDeepHashCode(workspaceIds),
  ]);

  @override
  String toString() =>
      'AdminUsageQueryParameters('
      'apiKeyId: ${apiKeyId?.length}, '
      'apiZone: ${apiZone?.length}, '
      'billingDisplayName: ${billingDisplayName?.length}, '
      'billingGroup: ${billingGroup?.length}, '
      'billingMetric: ${billingMetric?.length}, '
      'customerId: $customerId, '
      'end: $end, '
      'filters: ${filters?.length}, '
      'groupBy: ${groupBy?.length}, '
      'includeNbApiCalls: $includeNbApiCalls, '
      'limit: $limit, '
      'offset: $offset, '
      'organizationId: ${organizationId?.length}, '
      'serviceAccountId: ${serviceAccountId?.length}, '
      'serviceTier: ${serviceTier?.length}, '
      'start: $start, '
      'timeBucket: $timeBucket, '
      'untracked: $untracked, '
      'usageType: ${usageType?.length}, '
      'userId: ${userId?.length}, '
      'workspaceIds: ${workspaceIds?.length})';
}

/// Administrative usage limit.
@immutable
class AdminUsageLimit {
  /// Creates a [AdminUsageLimit].
  const AdminUsageLimit({
    required this.monthlyLimitReached,
    this.noMonthlyLimit,
    this.totalUsage,
    this.usage,
    this.usageLimit,
    this.vibeUsage,
  });

  /// Whether the monthly usage limit has been reached.
  final bool monthlyLimitReached;

  /// Whether no monthly usage limit is configured.
  final bool? noMonthlyLimit;

  /// Total current usage counted against the limit.
  final double? totalUsage;

  /// Current usage counted against the limit.
  final double? usage;

  /// Current usage limit.
  final double? usageLimit;

  /// Current Vibe usage counted against the limit.
  final double? vibeUsage;

  /// Parses a [AdminUsageLimit] from JSON.
  factory AdminUsageLimit.fromJson(Map<String, dynamic> json) {
    if (json['monthly_limit_reached'] == null) {
      throw const FormatException(
        'AdminUsageLimit: missing monthly_limit_reached',
      );
    }
    return AdminUsageLimit(
      monthlyLimitReached: json['monthly_limit_reached'] as bool,
      noMonthlyLimit: json['no_monthly_limit'] == null
          ? null
          : json['no_monthly_limit'] as bool,
      totalUsage: json['total_usage'] == null
          ? null
          : (json['total_usage'] as num).toDouble(),
      usage: json['usage'] == null ? null : (json['usage'] as num).toDouble(),
      usageLimit: json['usage_limit'] == null
          ? null
          : (json['usage_limit'] as num).toDouble(),
      vibeUsage: json['vibe_usage'] == null
          ? null
          : (json['vibe_usage'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'monthly_limit_reached': monthlyLimitReached,
    'no_monthly_limit': ?noMonthlyLimit,
    'total_usage': ?totalUsage,
    'usage': ?usage,
    'usage_limit': ?usageLimit,
    'vibe_usage': ?vibeUsage,
  };

  /// Creates a copy with the given fields replaced.
  AdminUsageLimit copyWith({
    bool? monthlyLimitReached,
    Object? noMonthlyLimit = unsetCopyWithValue,
    Object? totalUsage = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? usageLimit = unsetCopyWithValue,
    Object? vibeUsage = unsetCopyWithValue,
  }) => AdminUsageLimit(
    monthlyLimitReached: monthlyLimitReached ?? this.monthlyLimitReached,
    noMonthlyLimit: noMonthlyLimit == unsetCopyWithValue
        ? this.noMonthlyLimit
        : noMonthlyLimit as bool?,
    totalUsage: totalUsage == unsetCopyWithValue
        ? this.totalUsage
        : (totalUsage as num?)?.toDouble(),
    usage: usage == unsetCopyWithValue
        ? this.usage
        : (usage as num?)?.toDouble(),
    usageLimit: usageLimit == unsetCopyWithValue
        ? this.usageLimit
        : (usageLimit as num?)?.toDouble(),
    vibeUsage: vibeUsage == unsetCopyWithValue
        ? this.vibeUsage
        : (vibeUsage as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUsageLimit &&
          runtimeType == other.runtimeType &&
          monthlyLimitReached == other.monthlyLimitReached &&
          noMonthlyLimit == other.noMonthlyLimit &&
          totalUsage == other.totalUsage &&
          usage == other.usage &&
          usageLimit == other.usageLimit &&
          vibeUsage == other.vibeUsage;

  @override
  int get hashCode => Object.hashAll([
    monthlyLimitReached,
    noMonthlyLimit,
    totalUsage,
    usage,
    usageLimit,
    vibeUsage,
  ]);

  @override
  String toString() =>
      'AdminUsageLimit('
      'monthlyLimitReached: $monthlyLimitReached, '
      'noMonthlyLimit: $noMonthlyLimit, '
      'totalUsage: $totalUsage, '
      'usage: $usage, '
      'usageLimit: $usageLimit, '
      'vibeUsage: $vibeUsage)';
}
