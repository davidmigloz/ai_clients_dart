import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '_system_one_helpers.dart';

/// An answer to a System One question, dispatched by its `type` discriminator.
///
/// Variants: [SystemOneChoiceAnswer], [SystemOneNoulAnswer],
/// [SystemOneScoreAnswer], and [SystemOneUnknownAnswer].
@immutable
sealed class SystemOneAnswer {
  const SystemOneAnswer();

  /// Creates a choice answer.
  factory SystemOneAnswer.choice({
    required String choice,
    required Map<String, double> probabilities,
    required double confidence,
  }) = SystemOneChoiceAnswer;

  /// Creates an answer containing the probability of true.
  const factory SystemOneAnswer.noul({required double noul}) =
      SystemOneNoulAnswer;

  /// Creates a fractional score answer.
  factory SystemOneAnswer.score({
    required double score,
    required Map<String, String> legend,
    required Map<String, double> probabilities,
    required double confidence,
  }) = SystemOneScoreAnswer;

  /// Preserves an unfamiliar answer as raw JSON.
  factory SystemOneAnswer.unknown(Map<String, dynamic> rawJson) =
      SystemOneUnknownAnswer;

  /// Parses known answers and preserves unfamiliar discriminators.
  factory SystemOneAnswer.fromJson(Map<String, dynamic> json) =>
      switch (systemOneString(json['type'], 'SystemOneAnswer.type')) {
        'choice' => SystemOneChoiceAnswer.fromJson(json),
        'noul' => SystemOneNoulAnswer.fromJson(json),
        'score' => SystemOneScoreAnswer.fromJson(json),
        _ => SystemOneUnknownAnswer(json),
      };

  /// The required wire discriminator.
  String get type;

  /// Converts the answer to JSON.
  Map<String, dynamic> toJson();
}

/// The selected option and its probability distribution.
@immutable
class SystemOneChoiceAnswer extends SystemOneAnswer {
  /// Creates a choice answer and copies its probabilities.
  SystemOneChoiceAnswer({
    required this.choice,
    required Map<String, double> probabilities,
    required this.confidence,
  }) : probabilities = Map.unmodifiable(probabilities);

  /// Option key with the highest probability; ties use request option order.
  final String choice;

  /// Probabilities keyed by the request's option names.
  final Map<String, double> probabilities;

  /// Distribution concentration, rather than calibrated correctness.
  final double confidence;

  @override
  String get type => 'choice';

  /// Creates a choice answer from JSON.
  factory SystemOneChoiceAnswer.fromJson(Map<String, dynamic> json) {
    systemOneDiscriminator(json, 'choice', 'SystemOneChoiceAnswer');
    return SystemOneChoiceAnswer(
      choice: systemOneString(json['choice'], 'SystemOneChoiceAnswer.choice'),
      probabilities: systemOneProbabilities(
        json['probabilities'],
        'SystemOneChoiceAnswer.probabilities',
      ),
      confidence: systemOneDouble(
        json['confidence'],
        'SystemOneChoiceAnswer.confidence',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'choice': choice,
    'probabilities': probabilities,
    'confidence': confidence,
  };

  /// Creates a copy with replaced values.
  SystemOneChoiceAnswer copyWith({
    String? choice,
    Map<String, double>? probabilities,
    double? confidence,
  }) => SystemOneChoiceAnswer(
    choice: choice ?? this.choice,
    probabilities: probabilities ?? this.probabilities,
    confidence: confidence ?? this.confidence,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneChoiceAnswer &&
          choice == other.choice &&
          mapsEqual(probabilities, other.probabilities) &&
          confidence == other.confidence;

  @override
  int get hashCode => Object.hash(choice, mapHash(probabilities), confidence);

  @override
  String toString() =>
      'SystemOneChoiceAnswer(choice: $choice, '
      'probabilities: ${probabilities.length} entries, confidence: $confidence)';
}

/// The probability of true among the false and true candidates.
@immutable
class SystemOneNoulAnswer extends SystemOneAnswer {
  /// Creates a Noul answer.
  const SystemOneNoulAnswer({required this.noul});

  /// Probability of true, rather than a Boolean.
  final double noul;

  @override
  String get type => 'noul';

  /// Creates a Noul answer from JSON.
  factory SystemOneNoulAnswer.fromJson(Map<String, dynamic> json) {
    systemOneDiscriminator(json, 'noul', 'SystemOneNoulAnswer');
    return SystemOneNoulAnswer(
      noul: systemOneDouble(json['noul'], 'SystemOneNoulAnswer.noul'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'noul': noul};

  /// Creates a copy with a replaced probability.
  SystemOneNoulAnswer copyWith({double? noul}) =>
      SystemOneNoulAnswer(noul: noul ?? this.noul);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneNoulAnswer && noul == other.noul;

  @override
  int get hashCode => noul.hashCode;

  @override
  String toString() => 'SystemOneNoulAnswer(noul: $noul)';
}

/// A probability-weighted average of zero-based criterion indices.
@immutable
class SystemOneScoreAnswer extends SystemOneAnswer {
  /// Creates a score answer and copies its legend and probabilities.
  SystemOneScoreAnswer({
    required this.score,
    required Map<String, String> legend,
    required Map<String, double> probabilities,
    required this.confidence,
  }) : legend = Map.unmodifiable(legend),
       probabilities = Map.unmodifiable(probabilities);

  /// Fractional score on the zero-based rubric; not normalized to 0–1.
  final double score;

  /// Criterion descriptions keyed by zero-based indices as strings.
  final Map<String, String> legend;

  /// Criterion probabilities keyed by zero-based indices as strings.
  final Map<String, double> probabilities;

  /// Distribution concentration, rather than calibrated correctness.
  final double confidence;

  @override
  String get type => 'score';

  /// Creates a score answer from JSON.
  factory SystemOneScoreAnswer.fromJson(Map<String, dynamic> json) {
    systemOneDiscriminator(json, 'score', 'SystemOneScoreAnswer');
    return SystemOneScoreAnswer(
      score: systemOneDouble(json['score'], 'SystemOneScoreAnswer.score'),
      legend: systemOneStringMap(json['legend'], 'SystemOneScoreAnswer.legend'),
      probabilities: systemOneProbabilities(
        json['probabilities'],
        'SystemOneScoreAnswer.probabilities',
      ),
      confidence: systemOneDouble(
        json['confidence'],
        'SystemOneScoreAnswer.confidence',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'score': score,
    'legend': legend,
    'probabilities': probabilities,
    'confidence': confidence,
  };

  /// Creates a copy with replaced values.
  SystemOneScoreAnswer copyWith({
    double? score,
    Map<String, String>? legend,
    Map<String, double>? probabilities,
    double? confidence,
  }) => SystemOneScoreAnswer(
    score: score ?? this.score,
    legend: legend ?? this.legend,
    probabilities: probabilities ?? this.probabilities,
    confidence: confidence ?? this.confidence,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneScoreAnswer &&
          score == other.score &&
          mapsEqual(legend, other.legend) &&
          mapsEqual(probabilities, other.probabilities) &&
          confidence == other.confidence;

  @override
  int get hashCode =>
      Object.hash(score, mapHash(legend), mapHash(probabilities), confidence);

  @override
  String toString() =>
      'SystemOneScoreAnswer(score: $score, legend: ${legend.length} entries, '
      'probabilities: ${probabilities.length} entries, confidence: $confidence)';
}

/// An unfamiliar answer preserved for forward compatibility.
@immutable
class SystemOneUnknownAnswer extends SystemOneAnswer {
  /// Copies and freezes the complete raw payload.
  SystemOneUnknownAnswer(Map<String, dynamic> rawJson)
    : rawJson = systemOneUnknownJson(rawJson, 'SystemOneUnknownAnswer');

  /// Complete immutable answer JSON, including unfamiliar fields.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  /// Creates an unfamiliar answer from JSON.
  factory SystemOneUnknownAnswer.fromJson(Map<String, dynamic> json) =>
      SystemOneUnknownAnswer(json);

  @override
  Map<String, dynamic> toJson() => {...rawJson};

  /// Creates a copy with a replaced raw payload.
  SystemOneUnknownAnswer copyWith({Map<String, dynamic>? rawJson}) =>
      SystemOneUnknownAnswer(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneUnknownAnswer && mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() =>
      'SystemOneUnknownAnswer(rawJson: ${rawJson.length} entries)';
}
