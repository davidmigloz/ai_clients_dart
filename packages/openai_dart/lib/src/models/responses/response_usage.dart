import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Token usage statistics for a response.
@immutable
class ResponseUsage {
  /// Total input tokens.
  final int inputTokens;

  /// Total output tokens.
  final int outputTokens;

  /// Total tokens (input + output).
  final int totalTokens;

  /// Detailed input token breakdown.
  final InputTokensDetails? inputTokensDetails;

  /// Detailed output token breakdown.
  final OutputTokensDetails? outputTokensDetails;

  /// Creates a [ResponseUsage].
  const ResponseUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    this.inputTokensDetails,
    this.outputTokensDetails,
  });

  /// Creates a [ResponseUsage] from JSON.
  ///
  /// Also accepts Chat Completions usage field names returned by some
  /// OpenAI-compatible providers. Non-null Responses fields take precedence.
  factory ResponseUsage.fromJson(Map<String, dynamic> json) {
    final inputDetails =
        json['input_tokens_details'] ?? json['prompt_tokens_details'];
    final outputDetails =
        json['output_tokens_details'] ??
        json['completion_tokens_details'] ??
        (json['reasoning_tokens'] != null
            ? {'reasoning_tokens': json['reasoning_tokens']}
            : null);

    return ResponseUsage(
      inputTokens: (json['input_tokens'] ?? json['prompt_tokens']) as int,
      outputTokens: (json['output_tokens'] ?? json['completion_tokens']) as int,
      totalTokens: json['total_tokens'] as int,
      inputTokensDetails: inputDetails != null
          ? InputTokensDetails.fromJson(inputDetails as Map<String, dynamic>)
          : null,
      outputTokensDetails: outputDetails != null
          ? OutputTokensDetails.fromJson(outputDetails as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'total_tokens': totalTokens,
    if (inputTokensDetails != null)
      'input_tokens_details': inputTokensDetails!.toJson(),
    if (outputTokensDetails != null)
      'output_tokens_details': outputTokensDetails!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseUsage &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          totalTokens == other.totalTokens &&
          inputTokensDetails == other.inputTokensDetails &&
          outputTokensDetails == other.outputTokensDetails;

  @override
  int get hashCode => Object.hash(
    inputTokens,
    outputTokens,
    totalTokens,
    inputTokensDetails,
    outputTokensDetails,
  );

  @override
  String toString() =>
      'ResponseUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, totalTokens: $totalTokens)';
}

/// Detailed breakdown of input tokens.
@immutable
class InputTokensDetails {
  /// Tokens from cached content.
  final int? cachedTokens;

  /// Tokens written to the prompt cache.
  ///
  /// May be absent on older responses and compatible provider payloads.
  final int? cacheWriteTokens;

  /// Per-retention cache writes, when the server supplies the breakdown.
  final CacheWriteTokensDetails? cacheWriteTokensDetails;

  /// Creates an [InputTokensDetails].
  const InputTokensDetails({
    this.cachedTokens,
    this.cacheWriteTokens,
    this.cacheWriteTokensDetails,
  });

  /// Creates an [InputTokensDetails] from JSON.
  factory InputTokensDetails.fromJson(Map<String, dynamic> json) {
    return InputTokensDetails(
      cachedTokens: json['cached_tokens'] as int?,
      cacheWriteTokens: json['cache_write_tokens'] as int?,
      cacheWriteTokensDetails: json['cache_write_tokens_details'] == null
          ? null
          : CacheWriteTokensDetails.fromJson(
              json['cache_write_tokens_details'] as Map<String, dynamic>,
            ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (cachedTokens != null) 'cached_tokens': cachedTokens,
    if (cacheWriteTokens != null) 'cache_write_tokens': cacheWriteTokens,
    if (cacheWriteTokensDetails != null)
      'cache_write_tokens_details': cacheWriteTokensDetails!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  InputTokensDetails copyWith({
    Object? cachedTokens = unsetCopyWithValue,
    Object? cacheWriteTokens = unsetCopyWithValue,
    Object? cacheWriteTokensDetails = unsetCopyWithValue,
  }) => InputTokensDetails(
    cachedTokens: cachedTokens == unsetCopyWithValue
        ? this.cachedTokens
        : cachedTokens as int?,
    cacheWriteTokens: cacheWriteTokens == unsetCopyWithValue
        ? this.cacheWriteTokens
        : cacheWriteTokens as int?,
    cacheWriteTokensDetails:
        identical(cacheWriteTokensDetails, unsetCopyWithValue)
        ? this.cacheWriteTokensDetails
        : cacheWriteTokensDetails as CacheWriteTokensDetails?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputTokensDetails &&
          runtimeType == other.runtimeType &&
          cachedTokens == other.cachedTokens &&
          cacheWriteTokens == other.cacheWriteTokens &&
          cacheWriteTokensDetails == other.cacheWriteTokensDetails;

  @override
  int get hashCode =>
      Object.hash(cachedTokens, cacheWriteTokens, cacheWriteTokensDetails);

  @override
  String toString() =>
      'InputTokensDetails(cachedTokens: $cachedTokens, '
      'cacheWriteTokens: $cacheWriteTokens, '
      'cacheWriteTokensDetails: $cacheWriteTokensDetails)';
}

/// Prompt cache writes grouped by retention window.
@immutable
final class CacheWriteTokensDetails {
  /// Input tokens written with 30-minute retention.
  final int ttl30mTokens;

  /// Input tokens written with 12-hour retention.
  final int ttl12hTokens;

  /// Creates a breakdown with both required counts.
  const CacheWriteTokensDetails({
    required this.ttl30mTokens,
    required this.ttl12hTokens,
  });

  /// Parses the required counts.
  factory CacheWriteTokensDetails.fromJson(Map<String, dynamic> json) =>
      CacheWriteTokensDetails(
        ttl30mTokens: json['ttl_30m_tokens'] as int,
        ttl12hTokens: json['ttl_12h_tokens'] as int,
      );

  /// Returns the wire counts.
  Map<String, dynamic> toJson() => {
    'ttl_30m_tokens': ttl30mTokens,
    'ttl_12h_tokens': ttl12hTokens,
  };

  /// Copies the breakdown with replacement counts.
  CacheWriteTokensDetails copyWith({int? ttl30mTokens, int? ttl12hTokens}) =>
      CacheWriteTokensDetails(
        ttl30mTokens: ttl30mTokens ?? this.ttl30mTokens,
        ttl12hTokens: ttl12hTokens ?? this.ttl12hTokens,
      );

  @override
  bool operator ==(Object other) =>
      other is CacheWriteTokensDetails &&
      ttl30mTokens == other.ttl30mTokens &&
      ttl12hTokens == other.ttl12hTokens;

  @override
  int get hashCode => Object.hash(ttl30mTokens, ttl12hTokens);

  @override
  String toString() =>
      'CacheWriteTokensDetails(ttl30mTokens: $ttl30mTokens, ttl12hTokens: $ttl12hTokens)';
}

/// Detailed breakdown of output tokens.
@immutable
class OutputTokensDetails {
  /// Tokens used for reasoning.
  final int? reasoningTokens;

  /// Creates an [OutputTokensDetails].
  const OutputTokensDetails({this.reasoningTokens});

  /// Creates an [OutputTokensDetails] from JSON.
  factory OutputTokensDetails.fromJson(Map<String, dynamic> json) {
    return OutputTokensDetails(
      reasoningTokens: json['reasoning_tokens'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (reasoningTokens != null) 'reasoning_tokens': reasoningTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTokensDetails &&
          runtimeType == other.runtimeType &&
          reasoningTokens == other.reasoningTokens;

  @override
  int get hashCode => reasoningTokens.hashCode;

  @override
  String toString() => 'OutputTokensDetails(reasoningTokens: $reasoningTokens)';
}
