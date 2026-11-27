import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Scores returned by a moderation model.
///
/// Read [scores] or index this object using the exact API category names.
/// The named getters retain the original legacy moderation categories.
///
/// Each score is between 0.0 and 1.0, with higher values indicating
/// higher confidence that the content belongs to that category.
@immutable
class CategoryScores {
  /// Sexual content score.
  final double sexual;

  /// Hate speech score.
  final double hate;

  /// Violence content score.
  final double violence;

  /// Self-harm content score.
  final double selfHarm;

  /// Sexual content involving minors score.
  final double sexualMinors;

  /// Hate speech with threatening language score.
  final double hateThreatening;

  /// Graphic violence score.
  final double violenceGraphic;

  /// Self-harm intent score.
  final double selfHarmIntent;

  /// Self-harm instructions score.
  final double selfHarmInstructions;

  /// Harassment score.
  final double harassment;

  /// Threatening harassment score.
  final double harassmentThreatening;

  /// Personal Identifiable Information (PII) score.
  final double? pii;

  final Map<String, double>? _wireScores;

  /// Creates legacy category scores.
  const CategoryScores({
    required this.sexual,
    required this.hate,
    required this.violence,
    required this.selfHarm,
    required this.sexualMinors,
    required this.hateThreatening,
    required this.violenceGraphic,
    required this.selfHarmIntent,
    required this.selfHarmInstructions,
    required this.harassment,
    required this.harassmentThreatening,
    this.pii,
  }) : _wireScores = null;

  /// Creates an empty set of scores.
  const CategoryScores.empty()
    : _wireScores = const {},
      sexual = 0.0,
      hate = 0.0,
      violence = 0.0,
      selfHarm = 0.0,
      sexualMinors = 0.0,
      hateThreatening = 0.0,
      violenceGraphic = 0.0,
      selfHarmIntent = 0.0,
      selfHarmInstructions = 0.0,
      harassment = 0.0,
      harassmentThreatening = 0.0,
      pii = null;

  CategoryScores._fromScores(Map<String, double> scores)
    : _wireScores = Map.unmodifiable(scores),
      sexual = scores['sexual'] ?? 0.0,
      hate = scores['hate'] ?? 0.0,
      violence = scores['violence'] ?? 0.0,
      selfHarm = scores['self-harm'] ?? 0.0,
      sexualMinors = scores['sexual/minors'] ?? 0.0,
      hateThreatening = scores['hate/threatening'] ?? 0.0,
      violenceGraphic = scores['violence/graphic'] ?? 0.0,
      selfHarmIntent = scores['self-harm/intent'] ?? 0.0,
      selfHarmInstructions = scores['self-harm/instructions'] ?? 0.0,
      harassment = scores['harassment'] ?? 0.0,
      harassmentThreatening = scores['harassment/threatening'] ?? 0.0,
      pii = scores['pii'];

  /// Creates [CategoryScores] from the exact category names in the response.
  factory CategoryScores.fromJson(Map<String, dynamic> json) =>
      CategoryScores._fromScores({
        for (final entry in json.entries)
          if (entry.value != null) entry.key: (entry.value as num).toDouble(),
      });

  /// Scores keyed by the category names returned by the API.
  Map<String, double> get scores =>
      _wireScores ??
      Map.unmodifiable({
        'sexual': sexual,
        'hate': hate,
        'violence': violence,
        'self-harm': selfHarm,
        'sexual/minors': sexualMinors,
        'hate/threatening': hateThreatening,
        'violence/graphic': violenceGraphic,
        'self-harm/intent': selfHarmIntent,
        'self-harm/instructions': selfHarmInstructions,
        'harassment': harassment,
        'harassment/threatening': harassmentThreatening,
        'pii': ?pii,
      });

  /// Returns the score for an exact API category name, when reported.
  double? operator [](String category) => scores[category];

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {...scores};

  /// Creates a copy with replaced scores.
  CategoryScores copyWith({Map<String, double>? scores}) =>
      scores == null ? this : CategoryScores._fromScores(scores);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryScores && mapsEqual(scores, other.scores);

  @override
  int get hashCode => mapHash(scores);

  @override
  String toString() => 'CategoryScores(scores: $scores)';
}
