import '../copy_with_sentinel.dart';
import 'decision_input.dart';

/// A question to evaluate against the shared input.
///
/// Known question types are [NoulQuestion], [ChoiceQuestion], and
/// [ScoreQuestion]. [UnknownDecisionQuestion] preserves future question types.
sealed class DecisionQuestion {
  const DecisionQuestion();

  /// The wire discriminator identifying the question type.
  String get type;

  /// Creates a binary question.
  const factory DecisionQuestion.noul({
    required DecisionInstructions instructions,
    NoulCriteria? criteria,
  }) = NoulQuestion;

  /// Creates a single-select question over a map of choices.
  const factory DecisionQuestion.choice({
    required DecisionInstructions instructions,
    required Map<String, String> criteria,
  }) = ChoiceQuestion;

  /// Creates a question with rubric levels ordered from lowest to highest.
  const factory DecisionQuestion.score({
    required DecisionInstructions instructions,
    required List<String> criteria,
  }) = ScoreQuestion;

  /// Parses a question, preserving unrecognized types.
  factory DecisionQuestion.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'noul' => NoulQuestion.fromJson(json),
        'choice' => ChoiceQuestion.fromJson(json),
        'score' => ScoreQuestion.fromJson(json),
        final String type => UnknownDecisionQuestion(type, json),
        _ => throw const FormatException('DecisionQuestion: missing type'),
      };

  /// Converts the question to its wire representation.
  Map<String, dynamic> toJson();
}

/// A binary true-or-false question.
final class NoulQuestion extends DecisionQuestion {
  @override
  String get type => 'noul';

  /// Instructions for evaluating the question.
  final DecisionInstructions instructions;

  /// Optional descriptions of the true and false outcomes.
  final NoulCriteria? criteria;

  /// Creates a binary question.
  const NoulQuestion({required this.instructions, this.criteria});

  /// Parses a binary question.
  factory NoulQuestion.fromJson(Map<String, dynamic> json) {
    _expectQuestionType(json, 'noul');
    return NoulQuestion(
      instructions: DecisionInstructions.fromJson(json['instructions']),
      criteria: switch (json['criteria']) {
        null => null,
        final Map<String, dynamic> criteria => NoulCriteria.fromJson(criteria),
        _ => throw const FormatException('NoulQuestion: invalid criteria'),
      },
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions.toJson(),
    if (criteria != null) 'criteria': criteria!.toJson(),
  };

  /// Returns a copy with the supplied fields replaced.
  NoulQuestion copyWith({
    DecisionInstructions? instructions,
    Object? criteria = unsetCopyWithValue,
  }) => NoulQuestion(
    instructions: instructions ?? this.instructions,
    criteria: criteria == unsetCopyWithValue
        ? this.criteria
        : criteria as NoulCriteria?,
  );
}

/// Descriptions of the true and false outcomes for a [NoulQuestion].
final class NoulCriteria {
  /// Criteria for a true outcome.
  final String? trueDescription;

  /// Criteria for a false outcome.
  final String? falseDescription;

  /// Creates optional criteria for each outcome.
  const NoulCriteria({this.trueDescription, this.falseDescription});

  /// Parses the optional criteria.
  factory NoulCriteria.fromJson(Map<String, dynamic> json) => NoulCriteria(
    trueDescription: json['true_description'] as String?,
    falseDescription: json['false_description'] as String?,
  );

  /// Converts the criteria to their wire representation.
  Map<String, dynamic> toJson() => {
    if (trueDescription != null) 'true_description': trueDescription,
    if (falseDescription != null) 'false_description': falseDescription,
  };

  /// Returns a copy with the supplied fields replaced.
  NoulCriteria copyWith({
    Object? trueDescription = unsetCopyWithValue,
    Object? falseDescription = unsetCopyWithValue,
  }) => NoulCriteria(
    trueDescription: trueDescription == unsetCopyWithValue
        ? this.trueDescription
        : trueDescription as String?,
    falseDescription: falseDescription == unsetCopyWithValue
        ? this.falseDescription
        : falseDescription as String?,
  );
}

/// A single-select question over mutually exclusive choices.
final class ChoiceQuestion extends DecisionQuestion {
  @override
  String get type => 'choice';

  /// Instructions for evaluating the question.
  final DecisionInstructions instructions;

  /// Maps 2 to 255 option IDs to descriptions. Empty descriptions are valid.
  final Map<String, String> criteria;

  /// Creates a question with named choices.
  const ChoiceQuestion({required this.instructions, required this.criteria});

  /// Parses a single-select question.
  factory ChoiceQuestion.fromJson(Map<String, dynamic> json) {
    _expectQuestionType(json, 'choice');
    final criteria = json['criteria'];
    if (criteria is! Map<String, dynamic> ||
        !_validCriterionCount(criteria.length) ||
        criteria.values.any((value) => value is! String)) {
      throw const FormatException(
        'ChoiceQuestion: invalid or missing criteria',
      );
    }
    return ChoiceQuestion(
      instructions: DecisionInstructions.fromJson(json['instructions']),
      criteria: Map<String, String>.from(criteria),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    if (!_validCriterionCount(criteria.length)) {
      throw ArgumentError.value(
        criteria.length,
        'criteria.length',
        'Expected 2 to 255 choices',
      );
    }
    return {
      'type': type,
      'instructions': instructions.toJson(),
      'criteria': criteria,
    };
  }

  /// Returns a copy with the supplied fields replaced.
  ChoiceQuestion copyWith({
    DecisionInstructions? instructions,
    Map<String, String>? criteria,
  }) => ChoiceQuestion(
    instructions: instructions ?? this.instructions,
    criteria: criteria ?? this.criteria,
  );
}

/// A scoring question with discrete, ordered rubric levels.
final class ScoreQuestion extends DecisionQuestion {
  @override
  String get type => 'score';

  /// Instructions for evaluating the question.
  final DecisionInstructions instructions;

  /// Descriptions of 2 to 255 levels from the lowest to the highest score.
  final List<String> criteria;

  /// Creates a question with a scoring rubric.
  const ScoreQuestion({required this.instructions, required this.criteria});

  /// Parses a scoring question.
  factory ScoreQuestion.fromJson(Map<String, dynamic> json) {
    _expectQuestionType(json, 'score');
    final criteria = json['criteria'];
    if (criteria is! List<dynamic> ||
        !_validCriterionCount(criteria.length) ||
        criteria.any((value) => value is! String || value.isEmpty)) {
      throw const FormatException('ScoreQuestion: invalid or missing criteria');
    }
    return ScoreQuestion(
      instructions: DecisionInstructions.fromJson(json['instructions']),
      criteria: List<String>.from(criteria),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    if (!_validCriterionCount(criteria.length) ||
        criteria.any((value) => value.isEmpty)) {
      throw ArgumentError('Expected 2 to 255 non-empty rubric levels');
    }
    return {
      'type': type,
      'instructions': instructions.toJson(),
      'criteria': criteria,
    };
  }

  /// Returns a copy with the supplied fields replaced.
  ScoreQuestion copyWith({
    DecisionInstructions? instructions,
    List<String>? criteria,
  }) => ScoreQuestion(
    instructions: instructions ?? this.instructions,
    criteria: criteria ?? this.criteria,
  );
}

bool _validCriterionCount(int count) => count >= 2 && count <= 255;

void _expectQuestionType(Map<String, dynamic> json, String type) {
  if (json['type'] != type) {
    throw FormatException('Expected a Decisions question of type "$type"');
  }
}

/// A question with a type this version of the SDK does not recognize.
final class UnknownDecisionQuestion extends DecisionQuestion {
  @override
  final String type;

  /// The original question payload.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown question preserving its payload.
  const UnknownDecisionQuestion(this.type, this.rawJson);

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};
}
