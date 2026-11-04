import '../decisions/decision_choice_value.dart';
import '../decisions/decision_question.dart';
import 'live_decision_items.dart';
import 'live_json_helpers.dart';

/// Live-specific question instructions: text or nonempty multimodal parts.
///
/// Live permits different image/JSON and aggregate limits from standalone
/// Decisions. Variants are [LiveTextDecisionInstructions] and
/// [LivePartsDecisionInstructions].
sealed class LiveDecisionInstructions extends LiveJsonModel {
  /// Creates instructions.
  const LiveDecisionInstructions();

  /// Uses text without imposing the standalone Decisions aggregate limit.
  const factory LiveDecisionInstructions.text(String text) =
      LiveTextDecisionInstructions;

  /// Uses ordered input text/image/JSON parts, retaining future part metadata.
  factory LiveDecisionInstructions.parts(List<LiveDecisionContentPart> parts) =
      LivePartsDecisionInstructions;

  /// Reads the native Live instructions union.
  factory LiveDecisionInstructions.fromJson(Object? value) {
    if (value is String) return LiveTextDecisionInstructions(value);
    return LivePartsDecisionInstructions([
      for (final part in requireLiveList(value, 'LiveDecisionInstructions'))
        LiveDecisionContentPart.fromJson(
          requireLiveObject(part, 'LiveDecisionInstructions.part'),
        ),
    ]);
  }
}

/// Plain text criteria for a Live question.
class LiveTextDecisionInstructions extends LiveDecisionInstructions {
  /// Retains exact text, including empty strings permitted by the schema.
  const LiveTextDecisionInstructions(this.text);

  /// The original criteria.
  final String text;

  @override
  String toJson() => text;

  /// Replaces criteria.
  LiveTextDecisionInstructions copyWith({String? text}) =>
      LiveTextDecisionInstructions(text ?? this.text);
}

/// Ordered multimodal criteria for a Live question.
class LivePartsDecisionInstructions extends LiveDecisionInstructions {
  /// Snapshots the nonempty part sequence and validates allowed part kinds.
  LivePartsDecisionInstructions(List<LiveDecisionContentPart> parts)
    : parts = List.unmodifiable(parts) {
    validate();
  }

  /// Immutable part sequence; Live has no standalone aggregate part-count cap.
  final List<LiveDecisionContentPart> parts;

  @override
  void validate() {
    if (parts.isEmpty) {
      throw const FormatException(
        'LiveDecisionInstructions.parts: expected nonempty parts',
      );
    }
    for (final part in parts) {
      if (!const {
        'input_text',
        'input_image',
        'input_json',
      }.contains(part.type)) {
        throw const FormatException(
          'LiveDecisionInstructions.parts: unsupported part',
        );
      }
      part.validate();
    }
  }

  @override
  List<Map<String, dynamic>> toJson() => [
    for (final part in parts) part.toJson(),
  ];

  /// Replaces the immutable part sequence.
  LivePartsDecisionInstructions copyWith({
    List<LiveDecisionContentPart>? parts,
  }) => LivePartsDecisionInstructions(parts ?? this.parts);
}

/// A native string/boolean choice and its optional description.
class LiveDecisionChoiceParam extends LiveJsonModel {
  /// Creates a choice without narrowing future receive-only metadata.
  LiveDecisionChoiceParam({
    required this.value,
    this.description,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionChoiceParam',
         knownKeys: _keys,
       );

  static const _keys = {'value', 'description'};

  /// Type-preserving primitive classification value.
  final DecisionChoiceValue value;

  /// Optional criteria; null omits this nonnullable-on-wire field.
  final String? description;

  /// Immutable finite future metadata, with typed fields authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses a native Live choice; optional descriptions are nonnull when present.
  factory LiveDecisionChoiceParam.fromJson(Map<String, dynamic> json) =>
      LiveDecisionChoiceParam(
        value: DecisionChoiceValue.fromJson(json['value']),
        description: optionalLiveValue(
          json,
          'description',
          'LiveDecisionChoiceParam',
          requireLiveString,
        ),
        rawJson: json,
      );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'value': value.toJson(),
    'description': ?description,
  });

  /// Copies all fields; null clears the description.
  LiveDecisionChoiceParam copyWith({
    DecisionChoiceValue? value,
    Object? description = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionChoiceParam(
    value: value ?? this.value,
    description: copyLiveValue<String>(
      description,
      this.description,
      'LiveDecisionChoiceParam.description',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An ordered Live scoring level and optional description.
class LiveDecisionScoreLevelParam extends LiveJsonModel {
  /// Creates a scoring level.
  LiveDecisionScoreLevelParam({
    required this.label,
    this.description,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionScoreLevelParam',
         knownKeys: _keys,
       );

  static const _keys = {'label', 'description'};

  /// Level label; no extra standalone length policy is imposed.
  final String label;

  /// Optional criteria, omitted when cleared.
  final String? description;

  /// Immutable finite future metadata.
  final Map<String, dynamic> rawJson;

  /// Parses a Live level.
  factory LiveDecisionScoreLevelParam.fromJson(Map<String, dynamic> json) =>
      LiveDecisionScoreLevelParam(
        label: requireLiveString(
          json['label'],
          'LiveDecisionScoreLevelParam.label',
        ),
        description: optionalLiveValue(
          json,
          'description',
          'LiveDecisionScoreLevelParam',
          requireLiveString,
        ),
        rawJson: json,
      );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'label': label,
    'description': ?description,
  });

  /// Copies all fields; null clears the description.
  LiveDecisionScoreLevelParam copyWith({
    String? label,
    Object? description = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionScoreLevelParam(
    label: label ?? this.label,
    description: copyLiveValue<String>(
      description,
      this.description,
      'LiveDecisionScoreLevelParam.description',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A native Live predicate, choice or score question.
///
/// Variants are [LiveDecisionPredicateQuestionParam],
/// [LiveDecisionChoiceQuestionParam] and [LiveDecisionScoreQuestionParam].
/// Use [fromDecisionQuestion] to adapt already constructed standalone criteria;
/// native decoding retains Live's distinct constraints and future metadata.
sealed class LiveDecisionQuestion extends LiveJsonModel {
  /// Creates common immutable question state.
  const LiveDecisionQuestion._({
    required this.instructions,
    this.name,
    required this.rawJson,
  });

  /// Creates predicate criteria.
  factory LiveDecisionQuestion.predicate({
    required LiveDecisionInstructions instructions,
    String? name,
    Map<String, dynamic> rawJson,
  }) = LiveDecisionPredicateQuestionParam;

  /// Creates classification criteria.
  factory LiveDecisionQuestion.choice({
    required LiveDecisionInstructions instructions,
    required List<LiveDecisionChoiceParam> choices,
    String? name,
    Map<String, dynamic> rawJson,
  }) = LiveDecisionChoiceQuestionParam;

  /// Creates scoring criteria.
  factory LiveDecisionQuestion.score({
    required LiveDecisionInstructions instructions,
    required List<LiveDecisionScoreLevelParam> levels,
    String? name,
    Map<String, dynamic> rawJson,
  }) = LiveDecisionScoreQuestionParam;

  /// Parses all three native request branches without a standalone conversion.
  factory LiveDecisionQuestion.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'predicate' => LiveDecisionPredicateQuestionParam.fromJson(json),
      'choice' => LiveDecisionChoiceQuestionParam.fromJson(json),
      'score' => LiveDecisionScoreQuestionParam.fromJson(json),
      _ => throw const FormatException(
        'LiveDecisionQuestion.type: unsupported question',
      ),
    };
  }

  /// Adapts a standalone question while validating the Live wire contract.
  factory LiveDecisionQuestion.fromDecisionQuestion(
    DecisionQuestion question,
  ) => LiveDecisionQuestion.fromJson(question.toJson());

  /// Fixed branch discriminator.
  String get type;

  /// Required string/parts criteria.
  final LiveDecisionInstructions instructions;

  /// Optional answer correlation name.
  final String? name;

  /// Immutable finite future metadata.
  final Map<String, dynamic> rawJson;

  @override
  void validate() => instructions.validate();

  @override
  Map<String, dynamic> toJson();
}

/// Native Live predicate question.
class LiveDecisionPredicateQuestionParam extends LiveDecisionQuestion {
  /// Creates and validates predicate criteria, snapshotting supplied sequences.
  LiveDecisionPredicateQuestionParam({
    required super.instructions,
    super.name,
    Map<String, dynamic> rawJson = const {},
  }) : super._(
         rawJson: snapshotLiveJson(
           rawJson,
           'LiveDecisionPredicateQuestionParam',
           knownKeys: _keys,
         ),
       ) {
    validate();
  }

  static const _keys = {'type', 'name', 'instructions'};

  @override
  String get type => 'predicate';

  /// Reads the exact native branch with contextual field errors.
  factory LiveDecisionPredicateQuestionParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(json, 'predicate', 'LiveDecisionPredicateQuestionParam');
    return LiveDecisionPredicateQuestionParam(
      instructions: LiveDecisionInstructions.fromJson(json['instructions']),
      name: optionalLiveValue(
        json,
        'name',
        'LiveDecisionPredicateQuestionParam',
        requireLiveString,
      ),
      rawJson: json,
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'type': type,
    'instructions': instructions.toJson(),
    'name': ?name,
  });

  /// Copies every field; null clears the optional name.
  LiveDecisionPredicateQuestionParam copyWith({
    LiveDecisionInstructions? instructions,
    Object? name = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionPredicateQuestionParam(
    instructions: instructions ?? this.instructions,
    name: copyLiveValue<String>(
      name,
      this.name,
      'LiveDecisionPredicateQuestionParam.name',
    ),

    rawJson: rawJson ?? this.rawJson,
  );
}

/// Native Live choice question.
class LiveDecisionChoiceQuestionParam extends LiveDecisionQuestion {
  /// Creates and validates choice criteria, snapshotting supplied sequences.
  LiveDecisionChoiceQuestionParam({
    required super.instructions,
    super.name,
    required List<LiveDecisionChoiceParam> choices,
    Map<String, dynamic> rawJson = const {},
  }) : choices = List.unmodifiable(choices),
       super._(
         rawJson: snapshotLiveJson(
           rawJson,
           'LiveDecisionChoiceQuestionParam',
           knownKeys: _keys,
         ),
       ) {
    validate();
  }

  static const _keys = {'type', 'name', 'instructions', 'choices'};

  /// Immutable ordered choices.
  final List<LiveDecisionChoiceParam> choices;

  @override
  String get type => 'choice';

  /// Reads the exact native branch with contextual field errors.
  factory LiveDecisionChoiceQuestionParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'choice', 'LiveDecisionChoiceQuestionParam');
    return LiveDecisionChoiceQuestionParam(
      instructions: LiveDecisionInstructions.fromJson(json['instructions']),
      name: optionalLiveValue(
        json,
        'name',
        'LiveDecisionChoiceQuestionParam',
        requireLiveString,
      ),
      choices: [
        for (final entry in requireLiveList(
          json['choices'],
          'LiveDecisionChoiceQuestionParam.choices',
        ))
          LiveDecisionChoiceParam.fromJson(
            requireLiveObject(entry, 'LiveDecisionChoiceQuestionParam.choices'),
          ),
      ],
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    if (choices.length < 2 || choices.length > 255) {
      throw const FormatException(
        'LiveDecisionChoiceQuestionParam.choices: expected 2–255 entries',
      );
    }
    for (final entry in choices) {
      entry.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'type': type,
    'instructions': instructions.toJson(),
    'name': ?name,
    'choices': [for (final entry in choices) entry.toJson()],
  });

  /// Copies every field; null clears the optional name.
  LiveDecisionChoiceQuestionParam copyWith({
    LiveDecisionInstructions? instructions,
    Object? name = liveUnset,
    List<LiveDecisionChoiceParam>? choices,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionChoiceQuestionParam(
    instructions: instructions ?? this.instructions,
    name: copyLiveValue<String>(
      name,
      this.name,
      'LiveDecisionChoiceQuestionParam.name',
    ),
    choices: choices ?? this.choices,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Native Live score question.
class LiveDecisionScoreQuestionParam extends LiveDecisionQuestion {
  /// Creates and validates score criteria, snapshotting supplied sequences.
  LiveDecisionScoreQuestionParam({
    required super.instructions,
    super.name,
    required List<LiveDecisionScoreLevelParam> levels,
    Map<String, dynamic> rawJson = const {},
  }) : levels = List.unmodifiable(levels),
       super._(
         rawJson: snapshotLiveJson(
           rawJson,
           'LiveDecisionScoreQuestionParam',
           knownKeys: _keys,
         ),
       ) {
    validate();
  }

  static const _keys = {'type', 'name', 'instructions', 'levels'};

  /// Immutable ordered levels.
  final List<LiveDecisionScoreLevelParam> levels;

  @override
  String get type => 'score';

  /// Reads the exact native branch with contextual field errors.
  factory LiveDecisionScoreQuestionParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'score', 'LiveDecisionScoreQuestionParam');
    return LiveDecisionScoreQuestionParam(
      instructions: LiveDecisionInstructions.fromJson(json['instructions']),
      name: optionalLiveValue(
        json,
        'name',
        'LiveDecisionScoreQuestionParam',
        requireLiveString,
      ),
      levels: [
        for (final entry in requireLiveList(
          json['levels'],
          'LiveDecisionScoreQuestionParam.levels',
        ))
          LiveDecisionScoreLevelParam.fromJson(
            requireLiveObject(entry, 'LiveDecisionScoreQuestionParam.levels'),
          ),
      ],
      rawJson: json,
    );
  }

  @override
  void validate() {
    super.validate();
    if (levels.length < 2 || levels.length > 10) {
      throw const FormatException(
        'LiveDecisionScoreQuestionParam.levels: expected 2–10 entries',
      );
    }
    for (final entry in levels) {
      entry.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'type': type,
    'instructions': instructions.toJson(),
    'name': ?name,
    'levels': [for (final entry in levels) entry.toJson()],
  });

  /// Copies every field; null clears the optional name.
  LiveDecisionScoreQuestionParam copyWith({
    LiveDecisionInstructions? instructions,
    Object? name = liveUnset,
    List<LiveDecisionScoreLevelParam>? levels,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionScoreQuestionParam(
    instructions: instructions ?? this.instructions,
    name: copyLiveValue<String>(
      name,
      this.name,
      'LiveDecisionScoreQuestionParam.name',
    ),
    levels: levels ?? this.levels,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Enforces the separate native Live group bound, without a 400-question request.
void validateLiveDecisionQuestions(
  List<LiveDecisionQuestion> questions,
  String context,
) {
  if (questions.isEmpty || questions.length > 64) {
    throw FormatException('$context: expected 1–64 questions');
  }
  for (final question in questions) {
    question.validate();
  }
}

/// Questions evaluated using the current transcript and shared Decision items.
class LiveDecisionQuestionsInputParam extends LiveJsonModel {
  /// Creates one native Live group with 1–64 ordered questions.
  LiveDecisionQuestionsInputParam({
    required List<LiveDecisionQuestion> questions,
    Map<String, dynamic> rawJson = const {},
  }) : questions = List.unmodifiable(questions),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionQuestionsInputParam',
         knownKeys: _keys,
       ) {
    validate();
  }

  static const _keys = {'questions'};

  /// Immutable native question group.
  final List<LiveDecisionQuestion> questions;

  /// Immutable finite future metadata.
  final Map<String, dynamic> rawJson;

  /// Parses a Live group independently from standalone request limits.
  factory LiveDecisionQuestionsInputParam.fromJson(Map<String, dynamic> json) =>
      LiveDecisionQuestionsInputParam(
        questions: [
          for (final question in requireLiveList(
            json['questions'],
            'LiveDecisionQuestionsInputParam.questions',
          ))
            LiveDecisionQuestion.fromJson(
              requireLiveObject(
                question,
                'LiveDecisionQuestionsInputParam.questions',
              ),
            ),
        ],
        rawJson: json,
      );

  @override
  void validate() => validateLiveDecisionQuestions(
    questions,
    'LiveDecisionQuestionsInputParam.questions',
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'questions': [for (final question in questions) question.toJson()],
  });

  /// Replaces every field, snapshotting the new question sequence.
  LiveDecisionQuestionsInputParam copyWith({
    List<LiveDecisionQuestion>? questions,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionQuestionsInputParam(
    questions: questions ?? this.questions,
    rawJson: rawJson ?? this.rawJson,
  );
}
