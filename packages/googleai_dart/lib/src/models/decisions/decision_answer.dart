/// A calibrated answer to a decision question.
///
/// Known answer types are [NoulAnswer], [ChoiceAnswer], and [ScoreAnswer].
/// [UnknownDecisionAnswer] preserves future answer types.
sealed class DecisionAnswer {
  const DecisionAnswer();

  /// The wire discriminator identifying the answer type.
  String get type;

  /// Parses an answer, preserving unrecognized types.
  factory DecisionAnswer.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'noul' => NoulAnswer.fromJson(json),
        'choice' => ChoiceAnswer.fromJson(json),
        'score' => ScoreAnswer.fromJson(json),
        final String type => UnknownDecisionAnswer(type, json),
        _ => throw const FormatException('DecisionAnswer: missing type'),
      };

  /// Converts the answer to its wire representation.
  Map<String, dynamic> toJson();
}

/// The calibrated probability of a binary question being true.
final class NoulAnswer extends DecisionAnswer {
  @override
  String get type => 'noul';

  /// The probability of the true outcome.
  final double noul;

  /// The probability of the more likely outcome.
  final double confidence;

  /// Creates a binary answer.
  const NoulAnswer({required this.noul, required this.confidence});

  /// Parses a binary answer.
  factory NoulAnswer.fromJson(Map<String, dynamic> json) {
    _expectAnswerType(json, 'noul');
    return NoulAnswer(
      noul: _readNumber(json, 'noul'),
      confidence: _readNumber(json, 'confidence'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'noul': noul,
    'confidence': confidence,
  };

  /// Returns a copy with the supplied fields replaced.
  NoulAnswer copyWith({double? noul, double? confidence}) => NoulAnswer(
    noul: noul ?? this.noul,
    confidence: confidence ?? this.confidence,
  );
}

/// The winning choice and its probability distribution.
final class ChoiceAnswer extends DecisionAnswer {
  @override
  String get type => 'choice';

  /// The ID of the most likely choice.
  final String choice;

  /// Probabilities keyed by option ID.
  final Map<String, double> probabilities;

  /// The probability of the winning choice.
  final double confidence;

  /// Creates a single-select answer.
  const ChoiceAnswer({
    required this.choice,
    required this.probabilities,
    required this.confidence,
  });

  /// Parses a single-select answer.
  factory ChoiceAnswer.fromJson(Map<String, dynamic> json) {
    _expectAnswerType(json, 'choice');
    final choice = json['choice'];
    if (choice is! String) {
      throw const FormatException('ChoiceAnswer: invalid or missing choice');
    }
    return ChoiceAnswer(
      choice: choice,
      probabilities: _readProbabilities(json['probabilities']),
      confidence: _readNumber(json, 'confidence'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'choice': choice,
    'probabilities': probabilities,
    'confidence': confidence,
  };

  /// Returns a copy with the supplied fields replaced.
  ChoiceAnswer copyWith({
    String? choice,
    Map<String, double>? probabilities,
    double? confidence,
  }) => ChoiceAnswer(
    choice: choice ?? this.choice,
    probabilities: probabilities ?? this.probabilities,
    confidence: confidence ?? this.confidence,
  );
}

/// The weighted score and the probability distribution for its rubric levels.
final class ScoreAnswer extends DecisionAnswer {
  @override
  String get type => 'score';

  /// The expected score over the rubric levels.
  final double score;

  /// Probabilities keyed by the string representation of each rubric index.
  final Map<String, double> probabilities;

  /// Rubric descriptions keyed by the string representation of each index.
  final Map<String, String> legend;

  /// The maximum probability across the rubric levels.
  final double confidence;

  /// Creates an answer with a rubric score.
  const ScoreAnswer({
    required this.score,
    required this.probabilities,
    required this.legend,
    required this.confidence,
  });

  /// Parses a rubric score answer.
  factory ScoreAnswer.fromJson(Map<String, dynamic> json) {
    _expectAnswerType(json, 'score');
    final legend = json['legend'];
    if (legend is! Map<String, dynamic> ||
        legend.values.any((value) => value is! String)) {
      throw const FormatException('ScoreAnswer: invalid or missing legend');
    }
    return ScoreAnswer(
      score: _readNumber(json, 'score'),
      probabilities: _readProbabilities(json['probabilities']),
      legend: Map<String, String>.from(legend),
      confidence: _readNumber(json, 'confidence'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'score': score,
    'probabilities': probabilities,
    'legend': legend,
    'confidence': confidence,
  };

  /// Returns a copy with the supplied fields replaced.
  ScoreAnswer copyWith({
    double? score,
    Map<String, double>? probabilities,
    Map<String, String>? legend,
    double? confidence,
  }) => ScoreAnswer(
    score: score ?? this.score,
    probabilities: probabilities ?? this.probabilities,
    legend: legend ?? this.legend,
    confidence: confidence ?? this.confidence,
  );
}

void _expectAnswerType(Map<String, dynamic> json, String type) {
  if (json['type'] != type) {
    throw FormatException('Expected a Decisions answer of type "$type"');
  }
}

double _readNumber(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! num) {
    throw FormatException('DecisionAnswer: invalid or missing $field');
  }
  return value.toDouble();
}

Map<String, double> _readProbabilities(Object? json) {
  if (json is! Map<String, dynamic> ||
      json.values.any((value) => value is! num)) {
    throw const FormatException(
      'DecisionAnswer: invalid or missing probabilities',
    );
  }
  return json.map((key, value) => MapEntry(key, (value as num).toDouble()));
}

/// An answer with a type this version of the SDK does not recognize.
final class UnknownDecisionAnswer extends DecisionAnswer {
  @override
  final String type;

  /// The original answer payload.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown answer preserving its payload.
  const UnknownDecisionAnswer(this.type, this.rawJson);

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};
}
