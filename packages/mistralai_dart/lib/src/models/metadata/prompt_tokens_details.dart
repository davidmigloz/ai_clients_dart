import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Token usage details for the prompt.
@immutable
class PromptTokensDetails {
  /// Number of cached tokens used in the prompt.
  final int cachedTokens;

  /// Number of input audio tokens, when reported.
  final int? audioTokens;

  /// Creates a [PromptTokensDetails].
  const PromptTokensDetails({required this.cachedTokens, this.audioTokens});

  /// Creates a [PromptTokensDetails] from JSON.
  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) =>
      PromptTokensDetails(
        cachedTokens: json['cached_tokens'] as int? ?? 0,
        audioTokens: json['audio_tokens'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'cached_tokens': cachedTokens,
    if (audioTokens != null) 'audio_tokens': audioTokens,
  };

  /// Creates a copy with the given fields replaced.
  PromptTokensDetails copyWith({
    int? cachedTokens,
    Object? audioTokens = unsetCopyWithValue,
  }) => PromptTokensDetails(
    cachedTokens: cachedTokens ?? this.cachedTokens,
    audioTokens: audioTokens == unsetCopyWithValue
        ? this.audioTokens
        : audioTokens as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptTokensDetails &&
          runtimeType == other.runtimeType &&
          cachedTokens == other.cachedTokens &&
          audioTokens == other.audioTokens;

  @override
  int get hashCode => Object.hash(cachedTokens, audioTokens);

  @override
  String toString() =>
      'PromptTokensDetails(cachedTokens: $cachedTokens, audioTokens: $audioTokens)';
}
