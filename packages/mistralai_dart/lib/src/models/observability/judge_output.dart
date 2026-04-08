import 'package:meta/meta.dart';

/// Output from a judge evaluation.
@immutable
class JudgeOutput {
  /// The analysis text from the judge.
  final String analysis;

  /// The answer (either a string classification or a numeric score).
  final Object answer;

  /// Creates a [JudgeOutput].
  const JudgeOutput({required this.analysis, required this.answer});

  /// Creates a [JudgeOutput] from JSON.
  factory JudgeOutput.fromJson(Map<String, dynamic> json) => JudgeOutput(
    analysis: json['analysis'] as String? ?? '',
    answer: json['answer'] ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'analysis': analysis, 'answer': answer};

  /// Returns the answer as a string, if it is a string.
  String? get answerAsString => answer is String ? answer as String : null;

  /// Returns the answer as a number, if it is a number.
  num? get answerAsNum => answer is num ? answer as num : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeOutput) return false;
    if (runtimeType != other.runtimeType) return false;
    return analysis == other.analysis && answer == other.answer;
  }

  @override
  int get hashCode => Object.hash(analysis, answer);

  @override
  String toString() => 'JudgeOutput(analysis: $analysis, answer: $answer)';
}
