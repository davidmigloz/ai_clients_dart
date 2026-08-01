import 'package:meta/meta.dart';

/// Cumulative token usage for a Dream across every pipeline stage.
@immutable
class DreamUsage {
  /// Total uncached input tokens consumed across every pipeline stage.
  final int inputTokens;

  /// Total output tokens generated across every pipeline stage.
  final int outputTokens;

  /// Total tokens read from prompt cache.
  final int cacheReadInputTokens;

  /// Total tokens used to create prompt-cache entries (sum of all TTL tiers).
  final int cacheCreationInputTokens;

  /// Creates a [DreamUsage].
  const DreamUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.cacheReadInputTokens,
    required this.cacheCreationInputTokens,
  });

  /// Creates a [DreamUsage] from JSON.
  factory DreamUsage.fromJson(Map<String, dynamic> json) {
    return DreamUsage(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int,
      cacheCreationInputTokens: json['cache_creation_input_tokens'] as int,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'cache_read_input_tokens': cacheReadInputTokens,
    'cache_creation_input_tokens': cacheCreationInputTokens,
  };

  /// Creates a copy with replaced values.
  DreamUsage copyWith({
    int? inputTokens,
    int? outputTokens,
    int? cacheReadInputTokens,
    int? cacheCreationInputTokens,
  }) {
    return DreamUsage(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      cacheReadInputTokens: cacheReadInputTokens ?? this.cacheReadInputTokens,
      cacheCreationInputTokens:
          cacheCreationInputTokens ?? this.cacheCreationInputTokens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamUsage &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          cacheCreationInputTokens == other.cacheCreationInputTokens;

  @override
  int get hashCode => Object.hash(
    inputTokens,
    outputTokens,
    cacheReadInputTokens,
    cacheCreationInputTokens,
  );

  @override
  String toString() =>
      'DreamUsage('
      'inputTokens: $inputTokens, '
      'outputTokens: $outputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'cacheCreationInputTokens: $cacheCreationInputTokens)';
}
