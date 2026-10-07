import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'decision_choice_value.dart';
import 'decision_helpers.dart';

/// An answer to one question in a Decisions request.
///
/// The variants are [PredicateDecisionAnswer], [ChoiceDecisionAnswer],
/// [ScoreDecisionAnswer], [RefusalDecisionAnswer], and [UnknownDecisionAnswer].
/// A refusal may occur alongside successful answers in the same response.
sealed class DecisionAnswer {
  /// Creates a [DecisionAnswer].
  const DecisionAnswer();

  /// Creates a predicate answer.
  const factory DecisionAnswer.predicate({
    required String? name,
    required double probability,
  }) = PredicateDecisionAnswer;

  /// Creates a choice answer with its complete probability distribution.
  factory DecisionAnswer.choice({
    required String? name,
    required DecisionChoiceValue choice,
    required double confidence,
    required List<DecisionChoiceProbability> probabilities,
  }) = ChoiceDecisionAnswer;

  /// Creates a score answer with its ordered level probabilities.
  factory DecisionAnswer.score({
    required String? name,
    required double score,
    required double confidence,
    required List<DecisionScoreProbability> probabilities,
  }) = ScoreDecisionAnswer;

  /// Creates an answer indicating that the question was declined.
  const factory DecisionAnswer.refusal({required String? name}) =
      RefusalDecisionAnswer;

  /// Creates a [DecisionAnswer] from JSON.
  ///
  /// Future answer types retain their complete payload as an
  /// [UnknownDecisionAnswer]. Malformed known answers throw [FormatException].
  factory DecisionAnswer.fromJson(Map<String, dynamic> json) {
    final type = requireDecisionString(json['type'], 'DecisionAnswer.type');
    return switch (type) {
      'predicate' => PredicateDecisionAnswer.fromJson(json),
      'choice' => ChoiceDecisionAnswer.fromJson(json),
      'score' => ScoreDecisionAnswer.fromJson(json),
      'refusal' => RefusalDecisionAnswer.fromJson(json),
      _ => UnknownDecisionAnswer(json),
    };
  }

  /// The answer's wire discriminator.
  String get type;

  /// The question's optional correlation name.
  ///
  /// Known answers always include this field, even when it is `null`.
  String? get name;

  /// Converts the answer to its JSON representation.
  Map<String, dynamic> toJson();
}

/// The probability that a predicate question is true.
@immutable
class PredicateDecisionAnswer extends DecisionAnswer {
  /// Creates a [PredicateDecisionAnswer].
  const PredicateDecisionAnswer({
    required this.name,
    required this.probability,
  });

  /// Creates a [PredicateDecisionAnswer] from JSON.
  factory PredicateDecisionAnswer.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'predicate', 'PredicateDecisionAnswer');
    return PredicateDecisionAnswer(
      name: requireNullableDecisionString(
        json,
        'name',
        'PredicateDecisionAnswer',
      ),
      probability: requireDecisionNumber(
        json['probability'],
        'PredicateDecisionAnswer.probability',
      ),
    );
  }

  @override
  String get type => 'predicate';

  @override
  final String? name;

  /// The reported probability that the predicate is true.
  final double probability;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'probability': probability,
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass `name: null` to clear the correlation name.
  PredicateDecisionAnswer copyWith({
    Object? name = unsetCopyWithValue,
    double? probability,
  }) => PredicateDecisionAnswer(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    probability: probability ?? this.probability,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredicateDecisionAnswer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          probability == other.probability;

  @override
  int get hashCode => Object.hash(name, probability);

  @override
  String toString() =>
      'PredicateDecisionAnswer(name: $name, probability: $probability)';
}

/// A selected choice and the reported probabilities of its alternatives.
@immutable
class ChoiceDecisionAnswer extends DecisionAnswer {
  /// Creates a [ChoiceDecisionAnswer], snapshotting [probabilities].
  ChoiceDecisionAnswer({
    required this.name,
    required this.choice,
    required this.confidence,
    required List<DecisionChoiceProbability> probabilities,
  }) : probabilities = List.unmodifiable(probabilities);

  /// Creates a [ChoiceDecisionAnswer] from JSON.
  factory ChoiceDecisionAnswer.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'choice', 'ChoiceDecisionAnswer');
    return ChoiceDecisionAnswer(
      name: requireNullableDecisionString(json, 'name', 'ChoiceDecisionAnswer'),
      choice: DecisionChoiceValue.fromJson(json['choice']),
      confidence: requireDecisionNumber(
        json['confidence'],
        'ChoiceDecisionAnswer.confidence',
      ),
      probabilities: parseDecisionObjects(
        json['probabilities'],
        DecisionChoiceProbability.fromJson,
        'ChoiceDecisionAnswer.probabilities',
      ),
    );
  }

  @override
  String get type => 'choice';

  @override
  final String? name;

  /// The selected string or boolean choice, retaining its primitive type.
  final DecisionChoiceValue choice;

  /// The reported confidence in the selected choice.
  final double confidence;

  /// The alternatives and their reported probabilities, in response order.
  final List<DecisionChoiceProbability> probabilities;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'choice': choice.toJson(),
    'confidence': confidence,
    'probabilities': probabilities.map((value) => value.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass `name: null` to clear the correlation name.
  ChoiceDecisionAnswer copyWith({
    Object? name = unsetCopyWithValue,
    DecisionChoiceValue? choice,
    double? confidence,
    List<DecisionChoiceProbability>? probabilities,
  }) => ChoiceDecisionAnswer(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    choice: choice ?? this.choice,
    confidence: confidence ?? this.confidence,
    probabilities: probabilities ?? this.probabilities,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoiceDecisionAnswer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          choice == other.choice &&
          confidence == other.confidence &&
          listsEqual(probabilities, other.probabilities);

  @override
  int get hashCode =>
      Object.hash(name, choice, confidence, Object.hashAll(probabilities));

  @override
  String toString() =>
      'ChoiceDecisionAnswer(name: $name, choice: $choice, confidence: $confidence, '
      'probabilities: ${probabilities.length} items)';
}

/// The reported probability of one string or boolean choice.
@immutable
class DecisionChoiceProbability {
  /// Creates a [DecisionChoiceProbability].
  const DecisionChoiceProbability({
    required this.value,
    required this.probability,
  });

  /// Creates a [DecisionChoiceProbability] from JSON.
  factory DecisionChoiceProbability.fromJson(Map<String, dynamic> json) =>
      DecisionChoiceProbability(
        value: DecisionChoiceValue.fromJson(json['value']),
        probability: requireDecisionNumber(
          json['probability'],
          'DecisionChoiceProbability.probability',
        ),
      );

  /// The choice value, with string and boolean values kept distinct.
  final DecisionChoiceValue value;

  /// The reported probability of this choice.
  final double probability;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'value': value.toJson(),
    'probability': probability,
  };

  /// Creates a copy with replaced values.
  DecisionChoiceProbability copyWith({
    DecisionChoiceValue? value,
    double? probability,
  }) => DecisionChoiceProbability(
    value: value ?? this.value,
    probability: probability ?? this.probability,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionChoiceProbability &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          probability == other.probability;

  @override
  int get hashCode => Object.hash(value, probability);

  @override
  String toString() =>
      'DecisionChoiceProbability(value: $value, probability: $probability)';
}

/// A score and the reported probabilities of the ordered score levels.
@immutable
class ScoreDecisionAnswer extends DecisionAnswer {
  /// Creates a [ScoreDecisionAnswer], snapshotting [probabilities].
  ScoreDecisionAnswer({
    required this.name,
    required this.score,
    required this.confidence,
    required List<DecisionScoreProbability> probabilities,
  }) : probabilities = List.unmodifiable(probabilities);

  /// Creates a [ScoreDecisionAnswer] from JSON.
  factory ScoreDecisionAnswer.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'score', 'ScoreDecisionAnswer');
    return ScoreDecisionAnswer(
      name: requireNullableDecisionString(json, 'name', 'ScoreDecisionAnswer'),
      score: requireDecisionNumber(json['score'], 'ScoreDecisionAnswer.score'),
      confidence: requireDecisionNumber(
        json['confidence'],
        'ScoreDecisionAnswer.confidence',
      ),
      probabilities: parseDecisionObjects(
        json['probabilities'],
        DecisionScoreProbability.fromJson,
        'ScoreDecisionAnswer.probabilities',
      ),
    );
  }

  @override
  String get type => 'score';

  @override
  final String? name;

  /// The reported numeric score, which may lie between integer level indices.
  final double score;

  /// The reported confidence in the score.
  final double confidence;

  /// The zero-based levels and their probabilities, in response order.
  final List<DecisionScoreProbability> probabilities;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'score': score,
    'confidence': confidence,
    'probabilities': probabilities.map((value) => value.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass `name: null` to clear the correlation name.
  ScoreDecisionAnswer copyWith({
    Object? name = unsetCopyWithValue,
    double? score,
    double? confidence,
    List<DecisionScoreProbability>? probabilities,
  }) => ScoreDecisionAnswer(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    score: score ?? this.score,
    confidence: confidence ?? this.confidence,
    probabilities: probabilities ?? this.probabilities,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreDecisionAnswer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          score == other.score &&
          confidence == other.confidence &&
          listsEqual(probabilities, other.probabilities);

  @override
  int get hashCode =>
      Object.hash(name, score, confidence, Object.hashAll(probabilities));

  @override
  String toString() =>
      'ScoreDecisionAnswer(name: $name, score: $score, confidence: $confidence, '
      'probabilities: ${probabilities.length} items)';
}

/// The reported probability of one ordered score level.
@immutable
class DecisionScoreProbability {
  /// Creates a [DecisionScoreProbability].
  const DecisionScoreProbability({
    required this.value,
    required this.label,
    required this.probability,
  });

  /// Creates a [DecisionScoreProbability] from JSON.
  factory DecisionScoreProbability.fromJson(Map<String, dynamic> json) =>
      DecisionScoreProbability(
        value: requireDecisionInt(
          json['value'],
          'DecisionScoreProbability.value',
        ),
        label: requireDecisionString(
          json['label'],
          'DecisionScoreProbability.label',
        ),
        probability: requireDecisionNumber(
          json['probability'],
          'DecisionScoreProbability.probability',
        ),
      );

  /// The zero-based index of the score level.
  final int value;

  /// The score level's label.
  final String label;

  /// The reported probability of this level.
  final double probability;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'probability': probability,
  };

  /// Creates a copy with replaced values.
  DecisionScoreProbability copyWith({
    int? value,
    String? label,
    double? probability,
  }) => DecisionScoreProbability(
    value: value ?? this.value,
    label: label ?? this.label,
    probability: probability ?? this.probability,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionScoreProbability &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label &&
          probability == other.probability;

  @override
  int get hashCode => Object.hash(value, label, probability);

  @override
  String toString() =>
      'DecisionScoreProbability(value: $value, label: $label, '
      'probability: $probability)';
}

/// A question that was declined without a disclosed refusal score.
@immutable
class RefusalDecisionAnswer extends DecisionAnswer {
  /// Creates a [RefusalDecisionAnswer].
  const RefusalDecisionAnswer({required this.name});

  /// Creates a [RefusalDecisionAnswer] from JSON.
  factory RefusalDecisionAnswer.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'refusal', 'RefusalDecisionAnswer');
    return RefusalDecisionAnswer(
      name: requireNullableDecisionString(
        json,
        'name',
        'RefusalDecisionAnswer',
      ),
    );
  }

  @override
  String get type => 'refusal';

  @override
  final String? name;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'name': name};

  /// Creates a copy with a replaced correlation name.
  ///
  /// Pass `name: null` to clear it.
  RefusalDecisionAnswer copyWith({Object? name = unsetCopyWithValue}) =>
      RefusalDecisionAnswer(
        name: name == unsetCopyWithValue ? this.name : name as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDecisionAnswer &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() => 'RefusalDecisionAnswer(name: $name)';
}

/// A forward-compatible answer with an unrecognized discriminator.
///
/// Preserves the complete JSON payload, including nested unknown values.
@immutable
class UnknownDecisionAnswer extends DecisionAnswer {
  /// Creates an [UnknownDecisionAnswer] with a defensive JSON snapshot.
  UnknownDecisionAnswer(Map<String, dynamic> rawJson)
    : type = requireDecisionString(
        rawJson['type'],
        'UnknownDecisionAnswer.type',
      ),
      rawJson = _freezeDecisionJsonMap(rawJson);

  /// Creates an [UnknownDecisionAnswer] from JSON.
  factory UnknownDecisionAnswer.fromJson(Map<String, dynamic> json) =>
      UnknownDecisionAnswer(json);

  @override
  final String type;

  @override
  String? get name {
    final value = rawJson['name'];
    return value is String ? value : null;
  }

  /// The original payload, with recursively unmodifiable maps and lists.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  /// Creates a copy with a replaced raw payload.
  UnknownDecisionAnswer copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownDecisionAnswer(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDecisionAnswer &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownDecisionAnswer(type: $type)';
}

Map<String, dynamic> _freezeDecisionJsonMap(Map<String, dynamic> value) =>
    Map.unmodifiable(
      value.map(
        (key, nested) => MapEntry(key, _freezeDecisionJsonValue(nested)),
      ),
    );

Object? _freezeDecisionJsonValue(Object? value) => switch (value) {
  final Map<String, dynamic> map => _freezeDecisionJsonMap(map),
  final List<dynamic> list => List<Object?>.unmodifiable(
    list.map(_freezeDecisionJsonValue),
  ),
  _ => value,
};
