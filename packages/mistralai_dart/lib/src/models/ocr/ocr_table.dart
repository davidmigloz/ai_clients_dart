import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'ocr_confidence_score.dart';

/// Represents a table extracted from a document page by OCR.
@immutable
class OcrTable {
  /// Unique table ID for the extracted table in a page.
  final String id;

  /// Content of the table in the given format.
  final String content;

  /// Format of the table (`'markdown'` or `'html'`).
  final String format;

  /// Per-word confidence scores for the table content.
  ///
  /// Returned when `confidenceScoresGranularity` is set to `'word'`.
  final List<OcrConfidenceScore>? wordConfidenceScores;

  /// Creates an [OcrTable].
  const OcrTable({
    required this.id,
    required this.content,
    required this.format,
    this.wordConfidenceScores,
  });

  /// Creates an [OcrTable] from JSON.
  factory OcrTable.fromJson(Map<String, dynamic> json) => OcrTable(
    id: json['id'] as String,
    content: json['content'] as String,
    format: json['format'] as String,
    wordConfidenceScores: (json['word_confidence_scores'] as List?)
        ?.map((e) => OcrConfidenceScore.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'format': format,
    if (wordConfidenceScores != null)
      'word_confidence_scores': wordConfidenceScores!
          .map((e) => e.toJson())
          .toList(),
  };

  /// Creates a copy with the specified fields replaced.
  OcrTable copyWith({
    String? id,
    String? content,
    String? format,
    List<OcrConfidenceScore>? wordConfidenceScores,
  }) => OcrTable(
    id: id ?? this.id,
    content: content ?? this.content,
    format: format ?? this.format,
    wordConfidenceScores: wordConfidenceScores ?? this.wordConfidenceScores,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrTable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          format == other.format &&
          listsEqual(wordConfidenceScores, other.wordConfidenceScores);

  @override
  int get hashCode =>
      Object.hash(id, content, format, listHash(wordConfidenceScores));

  @override
  String toString() =>
      'OcrTable(id: $id, format: $format, '
      'content: ${content.length} chars, '
      'wordConfidenceScores: ${wordConfidenceScores?.length ?? 0} items)';
}
