import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Scores for the possible labels of a configured classifier target.
@immutable
class ClassificationTargetResult {
  /// Scores keyed by classifier label.
  final Map<String, double> scores;

  /// Creates a target result.
  const ClassificationTargetResult({required this.scores});

  /// Decodes target scores from JSON.
  factory ClassificationTargetResult.fromJson(Map<String, dynamic> json) {
    final data = json['scores'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Expected classifier target scores');
    }
    return ClassificationTargetResult(
      scores: {
        for (final entry in data.entries)
          entry.key: (entry.value as num).toDouble(),
      },
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'scores': scores};

  /// Creates a copy with replaced scores.
  ClassificationTargetResult copyWith({Map<String, double>? scores}) =>
      ClassificationTargetResult(scores: scores ?? this.scores);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationTargetResult && mapsEqual(scores, other.scores);

  @override
  int get hashCode => mapHash(scores);

  @override
  String toString() => 'ClassificationTargetResult(scores: $scores)';
}
