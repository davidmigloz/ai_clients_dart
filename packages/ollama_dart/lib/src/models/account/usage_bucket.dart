import 'package:meta/meta.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '_account_helpers.dart';
import 'usage_group.dart';
import 'usage_metrics.dart';

/// Usage for one UTC hour or day, including empty and current periods.
@immutable
class UsageBucket {
  /// Creates an usage bucket.
  UsageBucket({
    required DateTime from,
    required DateTime until,
    this.partial,
    required this.requestCount,
    this.usageUsd,
    this.inputTokens,
    this.cachedInputTokens,
    this.outputTokens,
    List<UsageGroup>? groups,
    this.remainder,
  }) : from = from.toUtc(),
       until = until.toUtc(),
       groups = groups == null ? null : List.unmodifiable(groups);

  /// Start of the bucket in UTC, inclusive.
  final DateTime from;

  /// End of the bucket in UTC, exclusive.
  final DateTime until;

  /// Whether this hour or day is still in progress.
  final bool? partial;

  /// Number of recorded requests.
  final int requestCount;

  /// Total request value in USD, including plan-covered and purchased usage.
  final double? usageUsd;

  /// Recorded input tokens, including cached tokens.
  final int? inputTokens;

  /// Recorded cached input tokens, already included in inputTokens.
  final int? cachedInputTokens;

  /// Recorded output tokens.
  final int? outputTokens;

  /// Selected model groups in the same order as the full-range totals.
  final List<UsageGroup>? groups;

  /// Usage outside the selected model groups in this bucket.
  final UsageMetrics? remainder;

  /// Parses an usage bucket, validating required fields.
  factory UsageBucket.fromJson(Map<String, dynamic> json) => UsageBucket(
    from: accountDateTime(json['from'], 'UsageBucket.from'),
    until: accountDateTime(json['until'], 'UsageBucket.until'),
    partial: json['partial'] == null
        ? null
        : accountBool(json['partial'], 'UsageBucket.partial'),
    requestCount: accountInt(
      json['request_count'],
      'UsageBucket.request_count',
    ),
    usageUsd: json['usage_usd'] == null
        ? null
        : accountDouble(json['usage_usd'], 'UsageBucket.usage_usd'),
    inputTokens: json['input_tokens'] == null
        ? null
        : accountInt(json['input_tokens'], 'UsageBucket.input_tokens'),
    cachedInputTokens: json['cached_input_tokens'] == null
        ? null
        : accountInt(
            json['cached_input_tokens'],
            'UsageBucket.cached_input_tokens',
          ),
    outputTokens: json['output_tokens'] == null
        ? null
        : accountInt(json['output_tokens'], 'UsageBucket.output_tokens'),
    groups: json['groups'] == null
        ? null
        : accountList(
            json['groups'],
            'UsageBucket.groups',
            UsageGroup.fromJson,
          ),
    remainder: json['remainder'] == null
        ? null
        : UsageMetrics.fromJson(
            accountObject(json['remainder'], 'UsageBucket.remainder'),
          ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'from': from.toIso8601String(),
    'until': until.toIso8601String(),
    if (partial != null) 'partial': partial,
    'request_count': requestCount,
    if (usageUsd != null) 'usage_usd': usageUsd,
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (cachedInputTokens != null) 'cached_input_tokens': cachedInputTokens,
    if (outputTokens != null) 'output_tokens': outputTokens,
    if (groups != null) 'groups': groups!.map((item) => item.toJson()).toList(),
    if (remainder != null) 'remainder': remainder!.toJson(),
  };

  /// Creates a copy; explicit null clears an optional field.
  UsageBucket copyWith({
    DateTime? from,
    DateTime? until,
    Object? partial = unsetCopyWithValue,
    int? requestCount,
    Object? usageUsd = unsetCopyWithValue,
    Object? inputTokens = unsetCopyWithValue,
    Object? cachedInputTokens = unsetCopyWithValue,
    Object? outputTokens = unsetCopyWithValue,
    Object? groups = unsetCopyWithValue,
    Object? remainder = unsetCopyWithValue,
  }) => UsageBucket(
    from: from ?? this.from,
    until: until ?? this.until,
    partial: identical(partial, unsetCopyWithValue)
        ? this.partial
        : partial as bool?,
    requestCount: requestCount ?? this.requestCount,
    usageUsd: identical(usageUsd, unsetCopyWithValue)
        ? this.usageUsd
        : (usageUsd as num?)?.toDouble(),
    inputTokens: identical(inputTokens, unsetCopyWithValue)
        ? this.inputTokens
        : inputTokens as int?,
    cachedInputTokens: identical(cachedInputTokens, unsetCopyWithValue)
        ? this.cachedInputTokens
        : cachedInputTokens as int?,
    outputTokens: identical(outputTokens, unsetCopyWithValue)
        ? this.outputTokens
        : outputTokens as int?,
    groups: identical(groups, unsetCopyWithValue)
        ? this.groups
        : groups as List<UsageGroup>?,
    remainder: identical(remainder, unsetCopyWithValue)
        ? this.remainder
        : remainder as UsageMetrics?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageBucket &&
          from == other.from &&
          until == other.until &&
          partial == other.partial &&
          requestCount == other.requestCount &&
          usageUsd == other.usageUsd &&
          inputTokens == other.inputTokens &&
          cachedInputTokens == other.cachedInputTokens &&
          outputTokens == other.outputTokens &&
          listsEqual(groups, other.groups) &&
          remainder == other.remainder;

  @override
  int get hashCode => Object.hashAll([
    from,
    until,
    partial,
    requestCount,
    usageUsd,
    inputTokens,
    cachedInputTokens,
    outputTokens,
    listHash(groups),
    remainder,
  ]);

  @override
  String toString() =>
      'UsageBucket(from: $from, until: $until, partial: $partial, requestCount: $requestCount, usageUsd: $usageUsd, inputTokens: $inputTokens, cachedInputTokens: $cachedInputTokens, outputTokens: $outputTokens, groups: $groups, remainder: $remainder)';
}
