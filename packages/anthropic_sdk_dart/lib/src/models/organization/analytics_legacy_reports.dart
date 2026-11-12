part of 'analytics_reports.dart';

/// A time bucket returned by a legacy report.
final class AnalyticsTimeBucket<T> extends AnalyticsResponseRecord {
  /// Parses the bounds and the reported results.
  AnalyticsTimeBucket.fromJson(
    super.json,
    T Function(Map<String, dynamic>) decode,
  ) : startingAt = _requiredReportTime(json, 'starting_at'),
      endingAt = _requiredReportTime(json, 'ending_at'),
      results = List.unmodifiable(
        requiredOrganizationField<List<Object?>>(
          json,
          'results',
          'Time bucket',
        ).cast<Map<String, dynamic>>().map(decode),
      );

  /// Inclusive start of this bucket.
  final DateTime startingAt;

  /// Exclusive end of this bucket.
  final DateTime endingAt;

  /// Results within the bucket.
  final List<T> results;
}

/// Token usage from a legacy time bucket or per-user report.
final class LegacyAnalyticsUsageRow extends AnalyticsResponseRecord {
  /// Parses a row whose dimensions and metrics share the same wire object.
  LegacyAnalyticsUsageRow.fromJson(super.json)
    : usage = AnalyticsUsageMetrics.fromJson(_metricFields(json, _usageKeys)),
      group = AnalyticsDimensions.fromJson(_groupFields(json, _usageKeys)),
      startingAt = _optionalReportTime(json['starting_at']),
      endingAt = _optionalReportTime(json['ending_at']);

  /// Token and server tool counts.
  final AnalyticsUsageMetrics usage;

  /// Report dimensions, including the actor for a per-user report.
  final AnalyticsDimensions group;

  /// Row bucket start, available on per-user reports with a bucket width.
  final DateTime? startingAt;

  /// Row bucket end, available on per-user reports with a bucket width.
  final DateTime? endingAt;
}

/// Cost from a legacy time bucket or per-user report.
final class LegacyAnalyticsCostRow extends AnalyticsResponseRecord {
  /// Parses a row whose dimensions and metrics share the same wire object.
  LegacyAnalyticsCostRow.fromJson(super.json)
    : cost = AnalyticsCostMetrics.fromJson(_metricFields(json, _costKeys)),
      group = AnalyticsDimensions.fromJson(_groupFields(json, _costKeys)),
      startingAt = _optionalReportTime(json['starting_at']),
      endingAt = _optionalReportTime(json['ending_at']);

  /// Decimal amounts and currency.
  final AnalyticsCostMetrics cost;

  /// Report dimensions, including the actor for a per-user report.
  final AnalyticsDimensions group;

  /// Row bucket start, available on per-user reports with a bucket width.
  final DateTime? startingAt;

  /// Row bucket end, available on per-user reports with a bucket width.
  final DateTime? endingAt;
}

const _usageKeys = {
  'cache_creation',
  'cache_read_input_tokens',
  'output_tokens',
  'requests',
  'server_tool_use',
  'total_tokens',
  'uncached_input_tokens',
};

const _costKeys = {'amount', 'currency', 'list_amount', 'requests'};

Map<String, dynamic> _metricFields(
  Map<String, dynamic> json,
  Set<String> keys,
) => {
  for (final entry in json.entries)
    if (keys.contains(entry.key)) entry.key: entry.value,
};

Map<String, dynamic> _groupFields(
  Map<String, dynamic> json,
  Set<String> keys,
) => {
  for (final entry in json.entries)
    if (!keys.contains(entry.key) &&
        entry.key != 'starting_at' &&
        entry.key != 'ending_at')
      entry.key: entry.value,
};

/// One Claude Code user or API key's usage for a UTC day.
final class ClaudeCodeUsageRow extends AnalyticsResponseRecord {
  /// Parses a Claude Code usage row.
  ClaudeCodeUsageRow.fromJson(super.json)
    : actor = AnalyticsActor.fromJson(_reportObject(json, 'actor')),
      date = _requiredReportTime(json, 'date'),
      coreMetrics = ClaudeCodeCoreMetrics.fromJson(
        _reportObject(json, 'core_metrics'),
      ),
      models = List.unmodifiable(
        requiredOrganizationField<List<Object?>>(
          json,
          'model_breakdown',
          'Claude Code usage',
        ).cast<Map<String, dynamic>>().map(ClaudeCodeModelUsage.fromJson),
      ),
      toolActions = Map.unmodifiable(
        _reportObject(json, 'tool_actions').map(
          (tool, value) => MapEntry(
            tool,
            ClaudeCodeToolActions.fromJson(value as Map<String, dynamic>),
          ),
        ),
      );

  /// The user or API key that performed the actions.
  final AnalyticsActor actor;

  /// Midnight UTC for the reported day.
  final DateTime date;

  /// Productivity counters.
  final ClaudeCodeCoreMetrics coreMetrics;

  /// Token and estimated cost breakdown by model.
  final List<ClaudeCodeModelUsage> models;

  /// Acceptance and rejection counts by tool.
  final Map<String, ClaudeCodeToolActions> toolActions;

  /// Organization that owns the usage.
  String get organizationId => rawJson['organization_id'] as String;

  /// Customer type, such as `api` or `subscription`.
  String get customerType => rawJson['customer_type'] as String;

  /// Subscription tier when applicable.
  String? get subscriptionType => rawJson['subscription_type'] as String?;

  /// Environment used for the reported actions.
  String get terminalType => rawJson['terminal_type'] as String;

  /// Whether this row describes remote Claude Code sessions.
  bool get isRemote => rawJson['is_remote'] as bool;
}

/// Claude Code's activity and productivity counters.
final class ClaudeCodeCoreMetrics extends AnalyticsResponseRecord {
  /// Parses the counters.
  ClaudeCodeCoreMetrics.fromJson(super.json);

  Map<String, dynamic> get _linesOfCode =>
      _reportObject(rawJson, 'lines_of_code');

  /// Number of sessions.
  int get sessions => rawJson['num_sessions'] as int;

  /// Commits made by Claude Code.
  int get commits => rawJson['commits_by_claude_code'] as int;

  /// Pull requests made by Claude Code.
  int get pullRequests => rawJson['pull_requests_by_claude_code'] as int;

  /// Lines added by Claude Code.
  int get linesAdded => _linesOfCode['added'] as int;

  /// Lines removed by Claude Code.
  int get linesRemoved => _linesOfCode['removed'] as int;
}

/// Per-model usage from the Claude Code usage report.
final class ClaudeCodeModelUsage extends AnalyticsResponseRecord {
  /// Parses the token and cost breakdown.
  ClaudeCodeModelUsage.fromJson(super.json);

  Map<String, dynamic> get _tokens => _reportObject(rawJson, 'tokens');
  Map<String, dynamic> get _cost => _reportObject(rawJson, 'estimated_cost');

  /// Model identifier.
  String get model => rawJson['model'] as String;

  /// Input token count.
  int get inputTokens => _tokens['input'] as int;

  /// Output token count.
  int get outputTokens => _tokens['output'] as int;

  /// Cache creation token count.
  int get cacheCreationTokens => _tokens['cache_creation'] as int;

  /// Cache read token count.
  int get cacheReadTokens => _tokens['cache_read'] as int;

  /// Estimated cost in whole minor currency units.
  int get estimatedCost => _cost['amount'] as int;

  /// Currency for the estimated cost.
  String get currency => _cost['currency'] as String;
}

/// Counts of accepted and rejected Claude Code actions for a tool.
final class ClaudeCodeToolActions extends AnalyticsResponseRecord {
  /// Parses the tool counters.
  ClaudeCodeToolActions.fromJson(super.json);

  /// Number of accepted actions.
  int get accepted => rawJson['accepted'] as int;

  /// Number of rejected actions.
  int get rejected => rawJson['rejected'] as int;
}
