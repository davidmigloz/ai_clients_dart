import 'package:meta/meta.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '_account_helpers.dart';
import 'usage_group.dart';
import 'usage_metrics.dart';

/// Usage totals, optional model groups, and any grouped remainder.
@immutable
class UsageSummary {
  /// Creates an usage summary.
  UsageSummary({
    required this.requestCount,
    this.usageUsd,
    this.inputTokens,
    this.cachedInputTokens,
    this.outputTokens,
    List<UsageGroup>? groups,
    this.remainder,
  }) : groups = groups == null ? null : List.unmodifiable(groups);

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

  /// Selected groups; present when grouping was requested, including empty lists.
  final List<UsageGroup>? groups;

  /// Combined usage outside the selected groups; omitted when empty.
  final UsageMetrics? remainder;

  /// Parses an usage summary, validating required fields.
  factory UsageSummary.fromJson(Map<String, dynamic> json) => UsageSummary(
    requestCount: accountInt(
      json['request_count'],
      'UsageSummary.request_count',
    ),
    usageUsd: json['usage_usd'] == null
        ? null
        : accountDouble(json['usage_usd'], 'UsageSummary.usage_usd'),
    inputTokens: json['input_tokens'] == null
        ? null
        : accountInt(json['input_tokens'], 'UsageSummary.input_tokens'),
    cachedInputTokens: json['cached_input_tokens'] == null
        ? null
        : accountInt(
            json['cached_input_tokens'],
            'UsageSummary.cached_input_tokens',
          ),
    outputTokens: json['output_tokens'] == null
        ? null
        : accountInt(json['output_tokens'], 'UsageSummary.output_tokens'),
    groups: json['groups'] == null
        ? null
        : accountList(
            json['groups'],
            'UsageSummary.groups',
            UsageGroup.fromJson,
          ),
    remainder: json['remainder'] == null
        ? null
        : UsageMetrics.fromJson(
            accountObject(json['remainder'], 'UsageSummary.remainder'),
          ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'request_count': requestCount,
    if (usageUsd != null) 'usage_usd': usageUsd,
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (cachedInputTokens != null) 'cached_input_tokens': cachedInputTokens,
    if (outputTokens != null) 'output_tokens': outputTokens,
    if (groups != null) 'groups': groups!.map((item) => item.toJson()).toList(),
    if (remainder != null) 'remainder': remainder!.toJson(),
  };

  /// Creates a copy; explicit null clears an optional field.
  UsageSummary copyWith({
    int? requestCount,
    Object? usageUsd = unsetCopyWithValue,
    Object? inputTokens = unsetCopyWithValue,
    Object? cachedInputTokens = unsetCopyWithValue,
    Object? outputTokens = unsetCopyWithValue,
    Object? groups = unsetCopyWithValue,
    Object? remainder = unsetCopyWithValue,
  }) => UsageSummary(
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
      other is UsageSummary &&
          requestCount == other.requestCount &&
          usageUsd == other.usageUsd &&
          inputTokens == other.inputTokens &&
          cachedInputTokens == other.cachedInputTokens &&
          outputTokens == other.outputTokens &&
          listsEqual(groups, other.groups) &&
          remainder == other.remainder;

  @override
  int get hashCode => Object.hashAll([
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
      'UsageSummary(requestCount: $requestCount, usageUsd: $usageUsd, inputTokens: $inputTokens, cachedInputTokens: $cachedInputTokens, outputTokens: $outputTokens, groups: $groups, remainder: $remainder)';
}
