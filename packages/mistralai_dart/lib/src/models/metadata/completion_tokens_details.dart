import 'package:meta/meta.dart';

/// Token usage details for the completion.
@immutable
class CompletionTokensDetails {
  /// Number of reasoning tokens generated for the completion.
  final int reasoningTokens;

  /// Creates a [CompletionTokensDetails].
  const CompletionTokensDetails({required this.reasoningTokens});

  /// Creates a [CompletionTokensDetails] from JSON.
  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) =>
      CompletionTokensDetails(
        reasoningTokens: json['reasoning_tokens'] as int? ?? 0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'reasoning_tokens': reasoningTokens};

  /// Creates a copy with the given fields replaced.
  CompletionTokensDetails copyWith({int? reasoningTokens}) =>
      CompletionTokensDetails(
        reasoningTokens: reasoningTokens ?? this.reasoningTokens,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionTokensDetails &&
          runtimeType == other.runtimeType &&
          reasoningTokens == other.reasoningTokens;

  @override
  int get hashCode => reasoningTokens.hashCode;

  @override
  String toString() =>
      'CompletionTokensDetails(reasoningTokens: $reasoningTokens)';
}
