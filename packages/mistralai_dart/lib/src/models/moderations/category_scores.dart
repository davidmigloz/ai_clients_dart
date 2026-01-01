import 'package:meta/meta.dart';

/// Scores for each moderation category.
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

  /// Creates [CategoryScores].
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
  });

  /// Creates [CategoryScores] from JSON.
  factory CategoryScores.fromJson(Map<String, dynamic> json) => CategoryScores(
    sexual: (json['sexual'] as num?)?.toDouble() ?? 0.0,
    hate: (json['hate'] as num?)?.toDouble() ?? 0.0,
    violence: (json['violence'] as num?)?.toDouble() ?? 0.0,
    selfHarm: (json['self-harm'] as num?)?.toDouble() ?? 0.0,
    sexualMinors: (json['sexual/minors'] as num?)?.toDouble() ?? 0.0,
    hateThreatening: (json['hate/threatening'] as num?)?.toDouble() ?? 0.0,
    violenceGraphic: (json['violence/graphic'] as num?)?.toDouble() ?? 0.0,
    selfHarmIntent: (json['self-harm/intent'] as num?)?.toDouble() ?? 0.0,
    selfHarmInstructions:
        (json['self-harm/instructions'] as num?)?.toDouble() ?? 0.0,
    harassment: (json['harassment'] as num?)?.toDouble() ?? 0.0,
    harassmentThreatening:
        (json['harassment/threatening'] as num?)?.toDouble() ?? 0.0,
    pii: (json['pii'] as num?)?.toDouble(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
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
    if (pii != null) 'pii': pii,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryScores &&
          runtimeType == other.runtimeType &&
          sexual == other.sexual &&
          hate == other.hate &&
          violence == other.violence &&
          selfHarm == other.selfHarm;

  @override
  int get hashCode => Object.hash(
    sexual,
    hate,
    violence,
    selfHarm,
    sexualMinors,
    hateThreatening,
    violenceGraphic,
    selfHarmIntent,
    selfHarmInstructions,
    harassment,
    harassmentThreatening,
  );

  @override
  String toString() =>
      'CategoryScores(sexual: $sexual, hate: $hate, '
      'violence: $violence, harassment: $harassment)';
}
