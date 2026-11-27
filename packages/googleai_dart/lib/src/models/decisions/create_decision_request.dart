import 'decision_input.dart';
import 'decision_question.dart';

/// A batch of questions to evaluate against shared input.
final class CreateDecisionRequest {
  /// The model ID, such as `gemini-decision-1`.
  final String model;

  /// The context evaluated for all questions.
  final DecisionInput input;

  /// Questions keyed by caller-supplied IDs. The API accepts 1 to 1,000.
  final Map<String, DecisionQuestion> questions;

  /// Creates a decision request.
  const CreateDecisionRequest({
    required this.model,
    required this.input,
    required this.questions,
  });

  /// Parses a decision request.
  factory CreateDecisionRequest.fromJson(Map<String, dynamic> json) {
    final model = json['model'];
    final questions = json['questions'];
    if (model is! String) {
      throw const FormatException('CreateDecisionRequest: missing model');
    }
    if (questions is! Map<String, dynamic> ||
        !_validQuestionCount(questions.length) ||
        questions.values.any((value) => value is! Map<String, dynamic>)) {
      throw const FormatException(
        'CreateDecisionRequest: invalid or missing questions',
      );
    }
    return CreateDecisionRequest(
      model: model,
      input: DecisionInput.fromJson(json['input']),
      questions: questions.map(
        (key, value) => MapEntry(
          key,
          DecisionQuestion.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// Converts the request to its wire representation.
  Map<String, dynamic> toJson() {
    if (!_validQuestionCount(questions.length)) {
      throw ArgumentError.value(
        questions.length,
        'questions.length',
        'Expected 1 to 1,000 questions',
      );
    }
    return {
      'model': model,
      'input': input.toJson(),
      'questions': questions.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  static bool _validQuestionCount(int count) => count >= 1 && count <= 1000;

  /// Returns a copy with the supplied fields replaced.
  CreateDecisionRequest copyWith({
    String? model,
    DecisionInput? input,
    Map<String, DecisionQuestion>? questions,
  }) => CreateDecisionRequest(
    model: model ?? this.model,
    input: input ?? this.input,
    questions: questions ?? this.questions,
  );
}
