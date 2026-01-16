import 'package:meta/meta.dart';

/// Token usage statistics.
@immutable
class Usage {
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

  /// Creates a [Usage].
  const Usage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    this.inputTokensDetails,
    this.outputTokensDetails,
  });

  /// Creates a [Usage] from JSON.
  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
      inputTokensDetails: json['input_tokens_details'] != null
          ? InputTokensDetails.fromJson(
              json['input_tokens_details'] as Map<String, dynamic>,
            )
          : null,
      outputTokensDetails: json['output_tokens_details'] != null
          ? OutputTokensDetails.fromJson(
              json['output_tokens_details'] as Map<String, dynamic>,
            )
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
      other is Usage &&
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
      'Usage(inputTokens: $inputTokens, outputTokens: $outputTokens, totalTokens: $totalTokens)';
}

/// Detailed breakdown of input tokens.
@immutable
class InputTokensDetails {
  /// Tokens from cached content.
  final int? cachedTokens;

  /// Creates an [InputTokensDetails].
  const InputTokensDetails({this.cachedTokens});

  /// Creates an [InputTokensDetails] from JSON.
  factory InputTokensDetails.fromJson(Map<String, dynamic> json) {
    return InputTokensDetails(cachedTokens: json['cached_tokens'] as int?);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (cachedTokens != null) 'cached_tokens': cachedTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputTokensDetails &&
          runtimeType == other.runtimeType &&
          cachedTokens == other.cachedTokens;

  @override
  int get hashCode => cachedTokens.hashCode;

  @override
  String toString() => 'InputTokensDetails(cachedTokens: $cachedTokens)';
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
