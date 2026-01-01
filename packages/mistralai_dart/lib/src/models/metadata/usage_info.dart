import 'package:meta/meta.dart';

/// Token usage information for a completion.
@immutable
class UsageInfo {
  /// Number of tokens in the prompt.
  final int promptTokens;

  /// Number of tokens in the completion.
  final int completionTokens;

  /// Total number of tokens (prompt + completion).
  final int totalTokens;

  /// Creates a [UsageInfo].
  const UsageInfo({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  /// Creates a [UsageInfo] from JSON.
  factory UsageInfo.fromJson(Map<String, dynamic> json) => UsageInfo(
    promptTokens: json['prompt_tokens'] as int? ?? 0,
    completionTokens: json['completion_tokens'] as int? ?? 0,
    totalTokens: json['total_tokens'] as int? ?? 0,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt_tokens': promptTokens,
    'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageInfo &&
          runtimeType == other.runtimeType &&
          promptTokens == other.promptTokens &&
          completionTokens == other.completionTokens &&
          totalTokens == other.totalTokens;

  @override
  int get hashCode => Object.hash(promptTokens, completionTokens, totalTokens);

  @override
  String toString() =>
      'UsageInfo(promptTokens: $promptTokens, '
      'completionTokens: $completionTokens, '
      'totalTokens: $totalTokens)';
}
