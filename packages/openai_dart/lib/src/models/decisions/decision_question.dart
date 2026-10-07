import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'decision_choice_value.dart';
import 'decision_helpers.dart';

/// A predicate, fixed-choice classification, or ordered scoring question.
///
/// A Decisions request accepts 1–200 questions. Optional names correlate answers
/// with questions; unnamed questions are allowed.
@immutable
sealed class DecisionQuestion {
  const DecisionQuestion();

  /// Estimates whether the condition described by [instructions] is true.
  const factory DecisionQuestion.predicate({
    required String instructions,
    String? name,
  }) = PredicateDecisionQuestion;

  /// Classifies evidence into one of the 2–255 supplied [choices].
  factory DecisionQuestion.choice({
    required String instructions,
    required List<DecisionChoiceOption> choices,
    String? name,
  }) = ChoiceDecisionQuestion;

  /// Scores evidence against 2–10 ordered [levels], from lowest to highest.
  factory DecisionQuestion.score({
    required String instructions,
    required List<DecisionScoreLevel> levels,
    String? name,
  }) = ScoreDecisionQuestion;

  /// Reads a supported question, rejecting unknown request discriminators.
  factory DecisionQuestion.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'predicate' => PredicateDecisionQuestion.fromJson(json),
        'choice' => ChoiceDecisionQuestion.fromJson(json),
        'score' => ScoreDecisionQuestion.fromJson(json),
        _ => throw const FormatException(
          'DecisionQuestion: expected type "predicate", "choice", or "score"',
        ),
      };

  /// The question discriminator.
  String get type;

  /// The criteria to evaluate against the shared input.
  String get instructions;

  /// The optional correlation name echoed in the corresponding answer.
  String? get name;

  /// Converts the question to JSON, omitting absent names.
  Map<String, dynamic> toJson();
}

/// A question estimating the probability that a condition is true.
@immutable
class PredicateDecisionQuestion extends DecisionQuestion {
  /// Creates a predicate question.
  const PredicateDecisionQuestion({required this.instructions, this.name});

  @override
  final String instructions;

  @override
  final String? name;

  @override
  String get type => 'predicate';

  /// Reads a predicate question with a required discriminator and instructions.
  factory PredicateDecisionQuestion.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'predicate', 'PredicateDecisionQuestion');
    return PredicateDecisionQuestion(
      instructions: requireDecisionString(
        json['instructions'],
        'PredicateDecisionQuestion.instructions',
      ),
      name: optionalDecisionString(json, 'name', 'PredicateDecisionQuestion'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions,
    if (name != null) 'name': name,
  };

  /// Creates a copy, allowing [name] to be explicitly cleared with null.
  PredicateDecisionQuestion copyWith({
    String? instructions,
    Object? name = unsetCopyWithValue,
  }) => PredicateDecisionQuestion(
    instructions: instructions ?? this.instructions,
    name: identical(name, unsetCopyWithValue) ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredicateDecisionQuestion &&
          runtimeType == other.runtimeType &&
          instructions == other.instructions &&
          name == other.name;

  @override
  int get hashCode => Object.hash(runtimeType, instructions, name);

  @override
  String toString() =>
      'PredicateDecisionQuestion(type: $type, '
      'instructions: $instructions, name: $name)';
}

/// A question selecting one of a fixed set of typed options.
@immutable
class ChoiceDecisionQuestion extends DecisionQuestion {
  /// Creates a choice question with an unmodifiable copy of [choices].
  ChoiceDecisionQuestion({
    required this.instructions,
    required List<DecisionChoiceOption> choices,
    this.name,
  }) : choices = List.unmodifiable(choices);

  @override
  final String instructions;

  /// The ordered classification options. The API accepts 2–255 choices.
  final List<DecisionChoiceOption> choices;

  @override
  final String? name;

  @override
  String get type => 'choice';

  /// Reads a choice question with required instructions and choices.
  factory ChoiceDecisionQuestion.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'choice', 'ChoiceDecisionQuestion');
    return ChoiceDecisionQuestion(
      instructions: requireDecisionString(
        json['instructions'],
        'ChoiceDecisionQuestion.instructions',
      ),
      choices: parseDecisionObjects(
        json['choices'],
        DecisionChoiceOption.fromJson,
        'ChoiceDecisionQuestion.choices',
      ),
      name: optionalDecisionString(json, 'name', 'ChoiceDecisionQuestion'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions,
    'choices': [for (final choice in choices) choice.toJson()],
    if (name != null) 'name': name,
  };

  /// Creates a copy, allowing [name] to be explicitly cleared with null.
  ChoiceDecisionQuestion copyWith({
    String? instructions,
    List<DecisionChoiceOption>? choices,
    Object? name = unsetCopyWithValue,
  }) => ChoiceDecisionQuestion(
    instructions: instructions ?? this.instructions,
    choices: choices ?? this.choices,
    name: identical(name, unsetCopyWithValue) ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoiceDecisionQuestion &&
          runtimeType == other.runtimeType &&
          instructions == other.instructions &&
          listsEqual(choices, other.choices) &&
          name == other.name;

  @override
  int get hashCode =>
      Object.hash(runtimeType, instructions, listHash(choices), name);

  @override
  String toString() =>
      'ChoiceDecisionQuestion(type: $type, '
      'instructions: $instructions, choices: ${choices.length} items, name: $name)';
}

/// A question rating evidence against ordered scoring levels.
@immutable
class ScoreDecisionQuestion extends DecisionQuestion {
  /// Creates a score question with an unmodifiable copy of [levels].
  ScoreDecisionQuestion({
    required this.instructions,
    required List<DecisionScoreLevel> levels,
    this.name,
  }) : levels = List.unmodifiable(levels);

  @override
  final String instructions;

  /// Ordered levels from lowest to highest. The API accepts 2–10 levels.
  ///
  /// Level indices begin at zero; the answer can be a fractional weighted score.
  final List<DecisionScoreLevel> levels;

  @override
  final String? name;

  @override
  String get type => 'score';

  /// Reads a score question with required instructions and levels.
  factory ScoreDecisionQuestion.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'score', 'ScoreDecisionQuestion');
    return ScoreDecisionQuestion(
      instructions: requireDecisionString(
        json['instructions'],
        'ScoreDecisionQuestion.instructions',
      ),
      levels: parseDecisionObjects(
        json['levels'],
        DecisionScoreLevel.fromJson,
        'ScoreDecisionQuestion.levels',
      ),
      name: optionalDecisionString(json, 'name', 'ScoreDecisionQuestion'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions,
    'levels': [for (final level in levels) level.toJson()],
    if (name != null) 'name': name,
  };

  /// Creates a copy, allowing [name] to be explicitly cleared with null.
  ScoreDecisionQuestion copyWith({
    String? instructions,
    List<DecisionScoreLevel>? levels,
    Object? name = unsetCopyWithValue,
  }) => ScoreDecisionQuestion(
    instructions: instructions ?? this.instructions,
    levels: levels ?? this.levels,
    name: identical(name, unsetCopyWithValue) ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreDecisionQuestion &&
          runtimeType == other.runtimeType &&
          instructions == other.instructions &&
          listsEqual(levels, other.levels) &&
          name == other.name;

  @override
  int get hashCode =>
      Object.hash(runtimeType, instructions, listHash(levels), name);

  @override
  String toString() =>
      'ScoreDecisionQuestion(type: $type, '
      'instructions: $instructions, levels: ${levels.length} items, name: $name)';
}

/// A typed option in a choice question.
@immutable
class DecisionChoiceOption {
  /// Creates a classification option.
  const DecisionChoiceOption({required this.value, this.description});

  /// The string or boolean value returned when this option is selected.
  final DecisionChoiceValue value;

  /// Optional criteria describing the option.
  final String? description;

  /// Reads an option, preserving the primitive value's JSON type.
  factory DecisionChoiceOption.fromJson(Map<String, dynamic> json) =>
      DecisionChoiceOption(
        value: DecisionChoiceValue.fromJson(json['value']),
        description: optionalDecisionString(
          json,
          'description',
          'DecisionChoiceOption',
        ),
      );

  /// Converts the option to JSON, omitting an absent description.
  Map<String, dynamic> toJson() => {
    'value': value.toJson(),
    if (description != null) 'description': description,
  };

  /// Creates a copy, allowing [description] to be explicitly cleared with null.
  DecisionChoiceOption copyWith({
    DecisionChoiceValue? value,
    Object? description = unsetCopyWithValue,
  }) => DecisionChoiceOption(
    value: value ?? this.value,
    description: identical(description, unsetCopyWithValue)
        ? this.description
        : description as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionChoiceOption &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          description == other.description;

  @override
  int get hashCode => Object.hash(runtimeType, value, description);

  @override
  String toString() =>
      'DecisionChoiceOption(value: $value, description: $description)';
}

/// One ordered level in a scoring rubric.
@immutable
class DecisionScoreLevel {
  /// Creates a scoring level.
  const DecisionScoreLevel({required this.label, this.description});

  /// The level label.
  final String label;

  /// Optional criteria distinguishing this level from adjacent levels.
  final String? description;

  /// Reads a scoring level with a required label.
  factory DecisionScoreLevel.fromJson(Map<String, dynamic> json) =>
      DecisionScoreLevel(
        label: requireDecisionString(json['label'], 'DecisionScoreLevel.label'),
        description: optionalDecisionString(
          json,
          'description',
          'DecisionScoreLevel',
        ),
      );

  /// Converts the level to JSON, omitting an absent description.
  Map<String, dynamic> toJson() => {
    'label': label,
    if (description != null) 'description': description,
  };

  /// Creates a copy, allowing [description] to be explicitly cleared with null.
  DecisionScoreLevel copyWith({
    String? label,
    Object? description = unsetCopyWithValue,
  }) => DecisionScoreLevel(
    label: label ?? this.label,
    description: identical(description, unsetCopyWithValue)
        ? this.description
        : description as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionScoreLevel &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          description == other.description;

  @override
  int get hashCode => Object.hash(runtimeType, label, description);

  @override
  String toString() =>
      'DecisionScoreLevel(label: $label, description: $description)';
}
