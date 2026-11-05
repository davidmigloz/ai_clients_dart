import 'package:meta/meta.dart';
import '../common/copy_with_sentinel.dart';
import '_account_helpers.dart';

/// Usage for one model, in the service-selected group order.
@immutable
class UsageGroup {
  /// Creates a model usage group.
  const UsageGroup({
    required this.model,
    required this.requestCount,
    this.usageUsd,
    this.inputTokens,
    this.cachedInputTokens,
    this.outputTokens,
  });

  /// Model name.
  final String model;

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

  /// Parses a model usage group, validating required fields.
  factory UsageGroup.fromJson(Map<String, dynamic> json) => UsageGroup(
    model: accountString(json['model'], 'UsageGroup.model'),
    requestCount: accountInt(json['request_count'], 'UsageGroup.request_count'),
    usageUsd: json['usage_usd'] == null
        ? null
        : accountDouble(json['usage_usd'], 'UsageGroup.usage_usd'),
    inputTokens: json['input_tokens'] == null
        ? null
        : accountInt(json['input_tokens'], 'UsageGroup.input_tokens'),
    cachedInputTokens: json['cached_input_tokens'] == null
        ? null
        : accountInt(
            json['cached_input_tokens'],
            'UsageGroup.cached_input_tokens',
          ),
    outputTokens: json['output_tokens'] == null
        ? null
        : accountInt(json['output_tokens'], 'UsageGroup.output_tokens'),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'request_count': requestCount,
    if (usageUsd != null) 'usage_usd': usageUsd,
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (cachedInputTokens != null) 'cached_input_tokens': cachedInputTokens,
    if (outputTokens != null) 'output_tokens': outputTokens,
  };

  /// Creates a copy; explicit null clears an optional field.
  UsageGroup copyWith({
    String? model,
    int? requestCount,
    Object? usageUsd = unsetCopyWithValue,
    Object? inputTokens = unsetCopyWithValue,
    Object? cachedInputTokens = unsetCopyWithValue,
    Object? outputTokens = unsetCopyWithValue,
  }) => UsageGroup(
    model: model ?? this.model,
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
      other is UsageGroup &&
          model == other.model &&
          requestCount == other.requestCount &&
          usageUsd == other.usageUsd &&
          inputTokens == other.inputTokens &&
          cachedInputTokens == other.cachedInputTokens &&
          outputTokens == other.outputTokens;

  @override
  int get hashCode => Object.hashAll([
    model,
    requestCount,
    usageUsd,
    inputTokens,
    cachedInputTokens,
    outputTokens,
  ]);

  @override
  String toString() =>
      'UsageGroup(model: $model, requestCount: $requestCount, usageUsd: $usageUsd, inputTokens: $inputTokens, cachedInputTokens: $cachedInputTokens, outputTokens: $outputTokens)';
}
