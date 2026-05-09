import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'ocr_confidence_score.dart';

/// Aggregate confidence scores for an OCR-processed page.
///
/// Returned on `OcrPage.confidenceScores` when the request was made with
/// `confidenceScoresGranularity` set to `word` or `page`.
///
/// [averagePageConfidenceScore] and [minimumPageConfidenceScore] are always
/// populated. [wordConfidenceScores] is only populated when granularity is
/// `word`.
@immutable
class OcrPageConfidenceScores {
  /// Average reliability score across all OCR-extracted text on the page
  /// (0.0 to 1.0).
  final double averagePageConfidenceScore;

  /// Minimum reliability score across all OCR-extracted text on the page
  /// (0.0 to 1.0).
  final double minimumPageConfidenceScore;

  /// Per-span confidence scores for the page's extracted text.
  ///
  /// Populated when [OcrRequest.confidenceScoresGranularity] is set to
  /// [OcrConfidenceScoresGranularity.word]; `null` otherwise.
  final List<OcrConfidenceScore>? wordConfidenceScores;

  /// Creates an [OcrPageConfidenceScores].
  const OcrPageConfidenceScores({
    required this.averagePageConfidenceScore,
    required this.minimumPageConfidenceScore,
    this.wordConfidenceScores,
  });

  /// Creates an [OcrPageConfidenceScores] from JSON.
  ///
  /// Throws a [FormatException] if either of the required aggregate scores
  /// is missing or null.
  factory OcrPageConfidenceScores.fromJson(Map<String, dynamic> json) {
    final avg = json['average_page_confidence_score'];
    if (avg is! num) {
      throw const FormatException(
        'OcrPageConfidenceScores: missing required field '
        '"average_page_confidence_score"',
      );
    }
    final min = json['minimum_page_confidence_score'];
    if (min is! num) {
      throw const FormatException(
        'OcrPageConfidenceScores: missing required field '
        '"minimum_page_confidence_score"',
      );
    }
    return OcrPageConfidenceScores(
      averagePageConfidenceScore: avg.toDouble(),
      minimumPageConfidenceScore: min.toDouble(),
      wordConfidenceScores: (json['word_confidence_scores'] as List?)
          ?.map((e) => OcrConfidenceScore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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
  ///
  /// Pass `null` explicitly to clear nullable fields.
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
      'wordConfidenceScores: ${wordConfidenceScores?.length ?? 0} items)';
}
