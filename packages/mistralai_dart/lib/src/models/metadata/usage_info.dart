import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'prompt_tokens_details.dart';

/// Token usage information for a completion.
@immutable
class UsageInfo {
  /// Number of tokens in the prompt.
  final int promptTokens;

  /// Number of tokens in the completion.
  final int completionTokens;

  /// Total number of tokens (prompt + completion).
  final int totalTokens;

  /// Number of cached tokens used.
  final int? numCachedTokens;

  /// Number of audio seconds in the prompt.
  final int? promptAudioSeconds;

  /// Prompt token details (singular key variant).
  final PromptTokensDetails? promptTokenDetails;

  /// Prompt token details (plural key variant).
  final PromptTokensDetails? promptTokensDetails;

  /// Creates a [UsageInfo].
  const UsageInfo({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.numCachedTokens,
    this.promptAudioSeconds,
    this.promptTokenDetails,
    this.promptTokensDetails,
  });

  /// Creates a [UsageInfo] from JSON.
  factory UsageInfo.fromJson(Map<String, dynamic> json) => UsageInfo(
    promptTokens: json['prompt_tokens'] as int? ?? 0,
    completionTokens: json['completion_tokens'] as int? ?? 0,
    totalTokens: json['total_tokens'] as int? ?? 0,
    numCachedTokens: json['num_cached_tokens'] as int?,
    promptAudioSeconds: json['prompt_audio_seconds'] as int?,
    promptTokenDetails: json['prompt_token_details'] != null
        ? PromptTokensDetails.fromJson(
            json['prompt_token_details'] as Map<String, dynamic>,
          )
        : null,
    promptTokensDetails: json['prompt_tokens_details'] != null
        ? PromptTokensDetails.fromJson(
            json['prompt_tokens_details'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt_tokens': promptTokens,
    'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
    if (numCachedTokens != null) 'num_cached_tokens': numCachedTokens,
    if (promptAudioSeconds != null) 'prompt_audio_seconds': promptAudioSeconds,
    if (promptTokenDetails != null)
      'prompt_token_details': promptTokenDetails!.toJson(),
    if (promptTokensDetails != null)
      'prompt_tokens_details': promptTokensDetails!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  UsageInfo copyWith({
    int? promptTokens,
    int? completionTokens,
    int? totalTokens,
    Object? numCachedTokens = unsetCopyWithValue,
    Object? promptAudioSeconds = unsetCopyWithValue,
    Object? promptTokenDetails = unsetCopyWithValue,
    Object? promptTokensDetails = unsetCopyWithValue,
  }) => UsageInfo(
    promptTokens: promptTokens ?? this.promptTokens,
    completionTokens: completionTokens ?? this.completionTokens,
    totalTokens: totalTokens ?? this.totalTokens,
    numCachedTokens: numCachedTokens == unsetCopyWithValue
        ? this.numCachedTokens
        : numCachedTokens as int?,
    promptAudioSeconds: promptAudioSeconds == unsetCopyWithValue
        ? this.promptAudioSeconds
        : promptAudioSeconds as int?,
    promptTokenDetails: promptTokenDetails == unsetCopyWithValue
        ? this.promptTokenDetails
        : promptTokenDetails as PromptTokensDetails?,
    promptTokensDetails: promptTokensDetails == unsetCopyWithValue
        ? this.promptTokensDetails
        : promptTokensDetails as PromptTokensDetails?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageInfo &&
          runtimeType == other.runtimeType &&
          promptTokens == other.promptTokens &&
          completionTokens == other.completionTokens &&
          totalTokens == other.totalTokens &&
          numCachedTokens == other.numCachedTokens &&
          promptAudioSeconds == other.promptAudioSeconds &&
          promptTokenDetails == other.promptTokenDetails &&
          promptTokensDetails == other.promptTokensDetails;

  @override
  int get hashCode => Object.hash(
    promptTokens,
    completionTokens,
    totalTokens,
    numCachedTokens,
    promptAudioSeconds,
    promptTokenDetails,
    promptTokensDetails,
  );

  @override
  String toString() =>
      'UsageInfo(promptTokens: $promptTokens, '
      'completionTokens: $completionTokens, '
      'totalTokens: $totalTokens, '
      'numCachedTokens: $numCachedTokens, '
      'promptAudioSeconds: $promptAudioSeconds, '
      'promptTokenDetails: $promptTokenDetails, '
      'promptTokensDetails: $promptTokensDetails)';
}
