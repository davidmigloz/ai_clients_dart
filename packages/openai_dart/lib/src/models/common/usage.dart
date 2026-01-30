import 'package:meta/meta.dart';

import 'copy_with_sentinel.dart';

/// Token usage statistics for a request.
///
/// This class provides detailed breakdown of tokens consumed by a request,
/// including prompt tokens, completion tokens, and any cached tokens.
///
/// ## Example
///
/// ```dart
/// final usage = response.usage;
/// if (usage != null) {
///   print('Prompt tokens: ${usage.promptTokens}');
///   print('Completion tokens: ${usage.completionTokens ?? 'N/A'}');
///   print('Total tokens: ${usage.totalTokens}');
/// }
/// ```
@immutable
class Usage {
  /// Creates a [Usage].
  const Usage({
    required this.promptTokens,
    this.completionTokens,
    required this.totalTokens,
    this.promptTokensDetails,
    this.completionTokensDetails,
  });

  /// Creates a [Usage] from JSON.
  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int?,
      totalTokens: json['total_tokens'] as int,
      promptTokensDetails: json['prompt_tokens_details'] != null
          ? PromptTokensDetails.fromJson(
              json['prompt_tokens_details'] as Map<String, dynamic>,
            )
          : null,
      completionTokensDetails: json['completion_tokens_details'] != null
          ? CompletionTokensDetails.fromJson(
              json['completion_tokens_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The number of tokens in the prompt.
  final int promptTokens;

  /// The number of tokens in the completion.
  ///
  /// May be null with some OpenAI-compatible providers that don't return
  /// completion token counts.
  final int? completionTokens;

  /// The total number of tokens used (prompt + completion).
  final int totalTokens;

  /// Detailed breakdown of prompt tokens.
  final PromptTokensDetails? promptTokensDetails;

  /// Detailed breakdown of completion tokens.
  final CompletionTokensDetails? completionTokensDetails;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt_tokens': promptTokens,
    if (completionTokens != null) 'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
    if (promptTokensDetails != null)
      'prompt_tokens_details': promptTokensDetails!.toJson(),
    if (completionTokensDetails != null)
      'completion_tokens_details': completionTokensDetails!.toJson(),
  };

  /// Creates a copy with replaced values.
  Usage copyWith({
    int? promptTokens,
    Object? completionTokens = unsetCopyWithValue,
    int? totalTokens,
    Object? promptTokensDetails = unsetCopyWithValue,
    Object? completionTokensDetails = unsetCopyWithValue,
  }) {
    return Usage(
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens == unsetCopyWithValue
          ? this.completionTokens
          : completionTokens as int?,
      totalTokens: totalTokens ?? this.totalTokens,
      promptTokensDetails: promptTokensDetails == unsetCopyWithValue
          ? this.promptTokensDetails
          : promptTokensDetails as PromptTokensDetails?,
      completionTokensDetails: completionTokensDetails == unsetCopyWithValue
          ? this.completionTokensDetails
          : completionTokensDetails as CompletionTokensDetails?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usage &&
          runtimeType == other.runtimeType &&
          promptTokens == other.promptTokens &&
          completionTokens == other.completionTokens &&
          totalTokens == other.totalTokens &&
          promptTokensDetails == other.promptTokensDetails &&
          completionTokensDetails == other.completionTokensDetails;

  @override
  int get hashCode => Object.hash(
    promptTokens,
    completionTokens,
    totalTokens,
    promptTokensDetails,
    completionTokensDetails,
  );

  @override
  String toString() =>
      'Usage(promptTokens: $promptTokens, completionTokens: $completionTokens, '
      'totalTokens: $totalTokens)';
}

/// Detailed breakdown of prompt tokens.
@immutable
class PromptTokensDetails {
  /// Creates a [PromptTokensDetails].
  const PromptTokensDetails({this.audioTokens, this.cachedTokens});

  /// Creates a [PromptTokensDetails] from JSON.
  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) {
    return PromptTokensDetails(
      audioTokens: json['audio_tokens'] as int?,
      cachedTokens: json['cached_tokens'] as int?,
    );
  }

  /// The number of audio tokens in the prompt.
  final int? audioTokens;

  /// The number of cached tokens in the prompt.
  final int? cachedTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (audioTokens != null) 'audio_tokens': audioTokens,
    if (cachedTokens != null) 'cached_tokens': cachedTokens,
  };

  /// Creates a copy with replaced values.
  PromptTokensDetails copyWith({
    Object? audioTokens = unsetCopyWithValue,
    Object? cachedTokens = unsetCopyWithValue,
  }) {
    return PromptTokensDetails(
      audioTokens: audioTokens == unsetCopyWithValue
          ? this.audioTokens
          : audioTokens as int?,
      cachedTokens: cachedTokens == unsetCopyWithValue
          ? this.cachedTokens
          : cachedTokens as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptTokensDetails &&
          runtimeType == other.runtimeType &&
          audioTokens == other.audioTokens &&
          cachedTokens == other.cachedTokens;

  @override
  int get hashCode => Object.hash(audioTokens, cachedTokens);

  @override
  String toString() =>
      'PromptTokensDetails(audioTokens: $audioTokens, cachedTokens: $cachedTokens)';
}

/// Detailed breakdown of completion tokens.
@immutable
class CompletionTokensDetails {
  /// Creates a [CompletionTokensDetails].
  const CompletionTokensDetails({
    this.audioTokens,
    this.reasoningTokens,
    this.acceptedPredictionTokens,
    this.rejectedPredictionTokens,
  });

  /// Creates a [CompletionTokensDetails] from JSON.
  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) {
    return CompletionTokensDetails(
      audioTokens: json['audio_tokens'] as int?,
      reasoningTokens: json['reasoning_tokens'] as int?,
      acceptedPredictionTokens: json['accepted_prediction_tokens'] as int?,
      rejectedPredictionTokens: json['rejected_prediction_tokens'] as int?,
    );
  }

  /// The number of audio tokens in the completion.
  final int? audioTokens;

  /// The number of reasoning tokens in the completion (for o1 models).
  final int? reasoningTokens;

  /// The number of accepted prediction tokens.
  final int? acceptedPredictionTokens;

  /// The number of rejected prediction tokens.
  final int? rejectedPredictionTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (audioTokens != null) 'audio_tokens': audioTokens,
    if (reasoningTokens != null) 'reasoning_tokens': reasoningTokens,
    if (acceptedPredictionTokens != null)
      'accepted_prediction_tokens': acceptedPredictionTokens,
    if (rejectedPredictionTokens != null)
      'rejected_prediction_tokens': rejectedPredictionTokens,
  };

  /// Creates a copy with replaced values.
  CompletionTokensDetails copyWith({
    Object? audioTokens = unsetCopyWithValue,
    Object? reasoningTokens = unsetCopyWithValue,
    Object? acceptedPredictionTokens = unsetCopyWithValue,
    Object? rejectedPredictionTokens = unsetCopyWithValue,
  }) {
    return CompletionTokensDetails(
      audioTokens: audioTokens == unsetCopyWithValue
          ? this.audioTokens
          : audioTokens as int?,
      reasoningTokens: reasoningTokens == unsetCopyWithValue
          ? this.reasoningTokens
          : reasoningTokens as int?,
      acceptedPredictionTokens: acceptedPredictionTokens == unsetCopyWithValue
          ? this.acceptedPredictionTokens
          : acceptedPredictionTokens as int?,
      rejectedPredictionTokens: rejectedPredictionTokens == unsetCopyWithValue
          ? this.rejectedPredictionTokens
          : rejectedPredictionTokens as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionTokensDetails &&
          runtimeType == other.runtimeType &&
          audioTokens == other.audioTokens &&
          reasoningTokens == other.reasoningTokens &&
          acceptedPredictionTokens == other.acceptedPredictionTokens &&
          rejectedPredictionTokens == other.rejectedPredictionTokens;

  @override
  int get hashCode => Object.hash(
    audioTokens,
    reasoningTokens,
    acceptedPredictionTokens,
    rejectedPredictionTokens,
  );

  @override
  String toString() =>
      'CompletionTokensDetails(audioTokens: $audioTokens, '
      'reasoningTokens: $reasoningTokens, '
      'acceptedPredictionTokens: $acceptedPredictionTokens, '
      'rejectedPredictionTokens: $rejectedPredictionTokens)';
}
