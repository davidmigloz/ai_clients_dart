import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'ocr_confidence_score.dart';

/// Confidence scores for an OCR page.
///
/// Contains aggregate page-level confidence metrics and optional per-word
/// scores when requested via `confidence_scores_granularity: 'word'`.
@immutable
class OcrPageConfidenceScores {
  /// Average confidence score across all words on the page, between 0 and 1.
  final double averagePageConfidenceScore;

  /// Minimum confidence score across all words on the page, between 0 and 1.
  final double minimumPageConfidenceScore;

  /// Per-word confidence scores.
  ///
  /// Returned when `confidenceScoresGranularity` is set to `'word'`.
  final List<OcrConfidenceScore>? wordConfidenceScores;

  /// Creates an [OcrPageConfidenceScores].
  const OcrPageConfidenceScores({
    required this.averagePageConfidenceScore,
    required this.minimumPageConfidenceScore,
    this.wordConfidenceScores,
  });

  /// Creates an [OcrPageConfidenceScores] from JSON.
  factory OcrPageConfidenceScores.fromJson(Map<String, dynamic> json) =>
      OcrPageConfidenceScores(
        averagePageConfidenceScore:
            (json['average_page_confidence_score'] as num).toDouble(),
        minimumPageConfidenceScore:
            (json['minimum_page_confidence_score'] as num).toDouble(),
        wordConfidenceScores: (json['word_confidence_scores'] as List?)
            ?.map((e) => OcrConfidenceScore.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'average_page_confidence_score': averagePageConfidenceScore,
    'minimum_page_confidence_score': minimumPageConfidenceScore,
    if (wordConfidenceScores != null)
      'word_confidence_scores': wordConfidenceScores!
          .map((e) => e.toJson())
          .toList(),
  };

  /// Creates a copy with the specified fields replaced.
  OcrPageConfidenceScores copyWith({
    double? averagePageConfidenceScore,
    double? minimumPageConfidenceScore,
    Object? wordConfidenceScores = unsetCopyWithValue,
  }) => OcrPageConfidenceScores(
    averagePageConfidenceScore:
        averagePageConfidenceScore ?? this.averagePageConfidenceScore,
    minimumPageConfidenceScore:
        minimumPageConfidenceScore ?? this.minimumPageConfidenceScore,
    wordConfidenceScores: wordConfidenceScores == unsetCopyWithValue
        ? this.wordConfidenceScores
        : wordConfidenceScores as List<OcrConfidenceScore>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrPageConfidenceScores &&
          runtimeType == other.runtimeType &&
          averagePageConfidenceScore == other.averagePageConfidenceScore &&
          minimumPageConfidenceScore == other.minimumPageConfidenceScore &&
          listsEqual(wordConfidenceScores, other.wordConfidenceScores);

  @override
  int get hashCode => Object.hash(
    averagePageConfidenceScore,
    minimumPageConfidenceScore,
    listHash(wordConfidenceScores),
  );

  @override
  String toString() =>
      'OcrPageConfidenceScores('
      'average: $averagePageConfidenceScore, '
      'minimum: $minimumPageConfidenceScore, '
      'wordScores: ${wordConfidenceScores?.length ?? 0} items)';
}
