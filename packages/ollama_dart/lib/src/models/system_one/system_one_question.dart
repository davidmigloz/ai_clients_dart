import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '_system_one_helpers.dart';
import 'system_one_content.dart';
import 'system_one_noul_criteria.dart';

/// A typed question about the shared state of a System One request.
///
/// Variants: [SystemOneChoiceQuestion], [SystemOneNoulQuestion],
/// [SystemOneScoreQuestion], and [SystemOneUnknownQuestion].
@immutable
sealed class SystemOneQuestion {
  const SystemOneQuestion();

  /// Asks the model to select one named option.
  factory SystemOneQuestion.choice({
    required SystemOneContent instructions,
    required Map<String, String?> criteria,
  }) = SystemOneChoiceQuestion;

  /// Asks for the probability that a condition is true.
  const factory SystemOneQuestion.noul({
    required SystemOneContent instructions,
    SystemOneNoulCriteria? criteria,
  }) = SystemOneNoulQuestion;

  /// Asks for a fractional score across ordered descriptions.
  factory SystemOneQuestion.score({
    required SystemOneContent instructions,
    required List<String> criteria,
  }) = SystemOneScoreQuestion;

  /// Preserves an unfamiliar question as raw JSON.
  factory SystemOneQuestion.unknown(Map<String, dynamic> rawJson) =
      SystemOneUnknownQuestion;

  /// Dispatches known question types and preserves unfamiliar types.
  factory SystemOneQuestion.fromJson(Map<String, dynamic> json) =>
      switch (systemOneString(json['type'], 'SystemOneQuestion.type')) {
        'choice' => SystemOneChoiceQuestion.fromJson(json),
        'noul' => SystemOneNoulQuestion.fromJson(json),
        'score' => SystemOneScoreQuestion.fromJson(json),
        _ => SystemOneUnknownQuestion(json),
      };

  /// The required wire discriminator.
  String get type;

  /// Converts the question to its API representation.
  Map<String, dynamic> toJson();
}

/// A choice question whose option order is retained during serialization.
@immutable
class SystemOneChoiceQuestion extends SystemOneQuestion {
  /// Creates a choice question and copies the ordered criteria.
  SystemOneChoiceQuestion({
    required this.instructions,
    required Map<String, String?> criteria,
  }) : criteria = Map.unmodifiable(criteria);

  /// Instructions describing the decision to make.
  final SystemOneContent instructions;

  /// Ordered option keys and descriptions; null uses the option key itself.
  ///
  /// Ties select the first option. The server requires 2–26 options.
  final Map<String, String?> criteria;

  @override
  String get type => 'choice';

  /// Creates a choice question from JSON.
  factory SystemOneChoiceQuestion.fromJson(Map<String, dynamic> json) {
    systemOneDiscriminator(json, 'choice', 'SystemOneChoiceQuestion');
    final criteria = systemOneObject(
      json['criteria'],
      'SystemOneChoiceQuestion.criteria',
    );
    return SystemOneChoiceQuestion(
      instructions: SystemOneContent.fromJson(
        json['instructions'],
        context: 'SystemOneChoiceQuestion.instructions',
      ),
      criteria: {
        for (final entry in criteria.entries)
          entry.key: entry.value == null
              ? null
              : systemOneString(
                  entry.value,
                  'SystemOneChoiceQuestion.criteria.${entry.key}',
                ),
      },
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions.toJson(),
    'criteria': criteria,
  };

  /// Creates a copy with replaced values.
  SystemOneChoiceQuestion copyWith({
    SystemOneContent? instructions,
    Map<String, String?>? criteria,
  }) => SystemOneChoiceQuestion(
    instructions: instructions ?? this.instructions,
    criteria: criteria ?? this.criteria,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneChoiceQuestion &&
          instructions == other.instructions &&
          systemOneOrderedMapsEqual(criteria, other.criteria);

  @override
  int get hashCode =>
      Object.hash(instructions, systemOneOrderedMapHash(criteria));

  @override
  String toString() =>
      'SystemOneChoiceQuestion(instructions: $instructions, '
      'criteria: ${criteria.length} entries)';
}

/// A Noul question returning the probability of the true outcome.
@immutable
class SystemOneNoulQuestion extends SystemOneQuestion {
  /// Creates a Noul question with optional outcome descriptions.
  const SystemOneNoulQuestion({required this.instructions, this.criteria});

  /// Instructions describing the condition to evaluate.
  final SystemOneContent instructions;

  /// Optional outcome descriptions; omitted when null.
  final SystemOneNoulCriteria? criteria;

  @override
  String get type => 'noul';

  /// Creates a Noul question from JSON.
  factory SystemOneNoulQuestion.fromJson(Map<String, dynamic> json) {
    systemOneDiscriminator(json, 'noul', 'SystemOneNoulQuestion');
    return SystemOneNoulQuestion(
      instructions: SystemOneContent.fromJson(
        json['instructions'],
        context: 'SystemOneNoulQuestion.instructions',
      ),
      criteria: json.containsKey('criteria')
          ? SystemOneNoulCriteria.fromJson(
              systemOneObject(
                json['criteria'],
                'SystemOneNoulQuestion.criteria',
              ),
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions.toJson(),
    if (criteria != null) 'criteria': criteria!.toJson(),
  };

  /// Creates a copy; passing null clears the optional criteria.
  SystemOneNoulQuestion copyWith({
    SystemOneContent? instructions,
    Object? criteria = unsetCopyWithValue,
  }) => SystemOneNoulQuestion(
    instructions: instructions ?? this.instructions,
    criteria: criteria == unsetCopyWithValue
        ? this.criteria
        : criteria as SystemOneNoulCriteria?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneNoulQuestion &&
          instructions == other.instructions &&
          criteria == other.criteria;

  @override
  int get hashCode => Object.hash(instructions, criteria);

  @override
  String toString() =>
      'SystemOneNoulQuestion(instructions: $instructions, criteria: $criteria)';
}

/// A score question with criterion descriptions ordered from lowest to highest.
@immutable
class SystemOneScoreQuestion extends SystemOneQuestion {
  /// Creates a score question and copies the ordered criteria.
  SystemOneScoreQuestion({
    required this.instructions,
    required List<String> criteria,
  }) : criteria = List.unmodifiable(criteria);

  /// Instructions describing the rubric to evaluate.
  final SystemOneContent instructions;

  /// Descriptions ordered from index zero upwards; the server requires 2–26.
  final List<String> criteria;

  @override
  String get type => 'score';

  /// Creates a score question from JSON.
  factory SystemOneScoreQuestion.fromJson(Map<String, dynamic> json) {
    systemOneDiscriminator(json, 'score', 'SystemOneScoreQuestion');
    final criteria = json['criteria'];
    if (criteria is! List<Object?>) {
      throw const FormatException(
        'SystemOneScoreQuestion.criteria must be an array',
      );
    }
    return SystemOneScoreQuestion(
      instructions: SystemOneContent.fromJson(
        json['instructions'],
        context: 'SystemOneScoreQuestion.instructions',
      ),
      criteria: [
        for (var i = 0; i < criteria.length; i++)
          systemOneString(criteria[i], 'SystemOneScoreQuestion.criteria[$i]'),
      ],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'instructions': instructions.toJson(),
    'criteria': criteria,
  };

  /// Creates a copy with replaced values.
  SystemOneScoreQuestion copyWith({
    SystemOneContent? instructions,
    List<String>? criteria,
  }) => SystemOneScoreQuestion(
    instructions: instructions ?? this.instructions,
    criteria: criteria ?? this.criteria,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneScoreQuestion &&
          instructions == other.instructions &&
          listsEqual(criteria, other.criteria);

  @override
  int get hashCode => Object.hash(instructions, listHash(criteria));

  @override
  String toString() =>
      'SystemOneScoreQuestion(instructions: $instructions, '
      'criteria: ${criteria.length} items)';
}

/// An unfamiliar question preserved for forward compatibility.
@immutable
class SystemOneUnknownQuestion extends SystemOneQuestion {
  /// Copies and freezes the complete raw payload.
  SystemOneUnknownQuestion(Map<String, dynamic> rawJson)
    : rawJson = systemOneUnknownJson(rawJson, 'SystemOneUnknownQuestion');

  /// Complete immutable question JSON, including unfamiliar fields.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  /// Creates an unfamiliar question from JSON.
  factory SystemOneUnknownQuestion.fromJson(Map<String, dynamic> json) =>
      SystemOneUnknownQuestion(json);

  @override
  Map<String, dynamic> toJson() => {...rawJson};

  /// Creates a copy with a replaced raw payload.
  SystemOneUnknownQuestion copyWith({Map<String, dynamic>? rawJson}) =>
      SystemOneUnknownQuestion(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneUnknownQuestion &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() =>
      'SystemOneUnknownQuestion(rawJson: ${rawJson.length} entries)';
}
