import 'package:meta/meta.dart';

/// Token usage details for the prompt.
@immutable
class PromptTokensDetails {
  /// Number of cached tokens used in the prompt.
  final int cachedTokens;

  /// Creates a [PromptTokensDetails].
  const PromptTokensDetails({required this.cachedTokens});

  /// Creates a [PromptTokensDetails] from JSON.
  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) =>
      PromptTokensDetails(cachedTokens: json['cached_tokens'] as int? ?? 0);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'cached_tokens': cachedTokens};

  /// Creates a copy with the given fields replaced.
  PromptTokensDetails copyWith({int? cachedTokens}) =>
      PromptTokensDetails(cachedTokens: cachedTokens ?? this.cachedTokens);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptTokensDetails &&
          runtimeType == other.runtimeType &&
          cachedTokens == other.cachedTokens;

  @override
  int get hashCode => cachedTokens.hashCode;

  @override
  String toString() => 'PromptTokensDetails(cachedTokens: $cachedTokens)';
}
