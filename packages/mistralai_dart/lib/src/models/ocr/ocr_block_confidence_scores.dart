import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Confidence scores for a single OCR block.
///
/// Content scores can be absent for blocks without text. The type score can
/// still be available.
@immutable
class OcrBlockConfidenceScores {
  /// Mean confidence across the extracted content.
  final double? averageContentConfidenceScore;

  /// Lowest confidence among the extracted words.
  final double? minimumContentConfidenceScore;

  /// Confidence in the block's structural label.
  final double? blockTypeConfidenceScore;

  /// Creates the available scores for a block.
  const OcrBlockConfidenceScores({
    this.averageContentConfidenceScore,
    this.minimumContentConfidenceScore,
    this.blockTypeConfidenceScore,
  });

  /// Decodes block confidence scores from JSON.
  factory OcrBlockConfidenceScores.fromJson(Map<String, dynamic> json) =>
      OcrBlockConfidenceScores(
        averageContentConfidenceScore:
            (json['average_content_confidence_score'] as num?)?.toDouble(),
        minimumContentConfidenceScore:
            (json['minimum_content_confidence_score'] as num?)?.toDouble(),
        blockTypeConfidenceScore: (json['block_type_confidence_score'] as num?)
            ?.toDouble(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (averageContentConfidenceScore != null)
      'average_content_confidence_score': averageContentConfidenceScore,
    if (minimumContentConfidenceScore != null)
      'minimum_content_confidence_score': minimumContentConfidenceScore,
    if (blockTypeConfidenceScore != null)
      'block_type_confidence_score': blockTypeConfidenceScore,
  };

  /// Creates a copy with replaced values.
  OcrBlockConfidenceScores copyWith({
    Object? averageContentConfidenceScore = unsetCopyWithValue,
    Object? minimumContentConfidenceScore = unsetCopyWithValue,
    Object? blockTypeConfidenceScore = unsetCopyWithValue,
  }) => OcrBlockConfidenceScores(
    averageContentConfidenceScore:
        averageContentConfidenceScore == unsetCopyWithValue
        ? this.averageContentConfidenceScore
        : (averageContentConfidenceScore as num?)?.toDouble(),
    minimumContentConfidenceScore:
        minimumContentConfidenceScore == unsetCopyWithValue
        ? this.minimumContentConfidenceScore
        : (minimumContentConfidenceScore as num?)?.toDouble(),
    blockTypeConfidenceScore: blockTypeConfidenceScore == unsetCopyWithValue
        ? this.blockTypeConfidenceScore
        : (blockTypeConfidenceScore as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrBlockConfidenceScores &&
          averageContentConfidenceScore ==
              other.averageContentConfidenceScore &&
          minimumContentConfidenceScore ==
              other.minimumContentConfidenceScore &&
          blockTypeConfidenceScore == other.blockTypeConfidenceScore;

  @override
  int get hashCode => Object.hash(
    averageContentConfidenceScore,
    minimumContentConfidenceScore,
    blockTypeConfidenceScore,
  );

  @override
  String toString() =>
      'OcrBlockConfidenceScores('
      'averageContentConfidenceScore: $averageContentConfidenceScore, '
      'minimumContentConfidenceScore: $minimumContentConfidenceScore, '
      'blockTypeConfidenceScore: $blockTypeConfidenceScore)';
}
