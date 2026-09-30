import 'package:meta/meta.dart';

import '_system_one_helpers.dart';

/// Server-reported token usage for all questions in a System One request.
@immutable
class SystemOneUsage {
  /// Creates token usage.
  const SystemOneUsage({required this.inputTokens, required this.outputTokens});

  /// Sum of full rendered prompt lengths, including repeated shared context.
  final int inputTokens;

  /// Tokens generated internally for scoring, preparation, and retries.
  ///
  /// May exceed the question count and does not measure the JSON response size.
  final int outputTokens;

  /// Creates token usage from JSON.
  factory SystemOneUsage.fromJson(Map<String, dynamic> json) => SystemOneUsage(
    inputTokens: systemOneInt(
      json['input_tokens'],
      'SystemOneUsage.input_tokens',
    ),
    outputTokens: systemOneInt(
      json['output_tokens'],
      'SystemOneUsage.output_tokens',
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
  };

  /// Creates a copy with replaced counts.
  SystemOneUsage copyWith({int? inputTokens, int? outputTokens}) =>
      SystemOneUsage(
        inputTokens: inputTokens ?? this.inputTokens,
        outputTokens: outputTokens ?? this.outputTokens,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneUsage &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens;

  @override
  int get hashCode => Object.hash(inputTokens, outputTokens);

  @override
  String toString() =>
      'SystemOneUsage(inputTokens: $inputTokens, outputTokens: $outputTokens)';
}
