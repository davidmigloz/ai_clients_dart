import 'package:meta/meta.dart';
import '../common/copy_with_sentinel.dart';
import '_account_helpers.dart';

/// Recorded request counts and optional cost and token metrics.
@immutable
class UsageMetrics {
  /// Creates an usage metrics value.
  const UsageMetrics({
    required this.requestCount,
    this.usageUsd,
    this.inputTokens,
    this.cachedInputTokens,
    this.outputTokens,
  });

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

  /// Parses an usage metrics value, validating required fields.
  factory UsageMetrics.fromJson(Map<String, dynamic> json) => UsageMetrics(
    requestCount: accountInt(
      json['request_count'],
      'UsageMetrics.request_count',
    ),
    usageUsd: json['usage_usd'] == null
        ? null
        : accountDouble(json['usage_usd'], 'UsageMetrics.usage_usd'),
    inputTokens: json['input_tokens'] == null
        ? null
        : accountInt(json['input_tokens'], 'UsageMetrics.input_tokens'),
    cachedInputTokens: json['cached_input_tokens'] == null
        ? null
        : accountInt(
            json['cached_input_tokens'],
            'UsageMetrics.cached_input_tokens',
          ),
    outputTokens: json['output_tokens'] == null
        ? null
        : accountInt(json['output_tokens'], 'UsageMetrics.output_tokens'),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'request_count': requestCount,
    if (usageUsd != null) 'usage_usd': usageUsd,
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (cachedInputTokens != null) 'cached_input_tokens': cachedInputTokens,
    if (outputTokens != null) 'output_tokens': outputTokens,
  };

  /// Creates a copy; explicit null clears an optional field.
  UsageMetrics copyWith({
    int? requestCount,
    Object? usageUsd = unsetCopyWithValue,
    Object? inputTokens = unsetCopyWithValue,
    Object? cachedInputTokens = unsetCopyWithValue,
    Object? outputTokens = unsetCopyWithValue,
  }) => UsageMetrics(
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
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageMetrics &&
          requestCount == other.requestCount &&
          usageUsd == other.usageUsd &&
          inputTokens == other.inputTokens &&
          cachedInputTokens == other.cachedInputTokens &&
          outputTokens == other.outputTokens;

  @override
  int get hashCode => Object.hashAll([
    requestCount,
    usageUsd,
    inputTokens,
    cachedInputTokens,
    outputTokens,
  ]);

  @override
  String toString() =>
      'UsageMetrics(requestCount: $requestCount, usageUsd: $usageUsd, inputTokens: $inputTokens, cachedInputTokens: $cachedInputTokens, outputTokens: $outputTokens)';
}
