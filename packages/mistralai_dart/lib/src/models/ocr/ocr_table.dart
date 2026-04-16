import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'ocr_confidence_score.dart';
import 'ocr_table_format.dart';

/// Represents a table extracted from a document page by OCR.
@immutable
class OcrTable {
  /// Unique table ID for the extracted table in a page.
  final String id;

  /// Content of the table in the given format.
  final String content;

  /// Format of the table.
  final OcrTableFormat format;

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
  factory OcrTable.fromJson(Map<String, dynamic> json) {
    final formatStr = json['format'] as String?;
    final format = OcrTableFormat.fromString(formatStr);
    if (format == null) {
      throw FormatException('Unknown OcrTableFormat: "$formatStr"');
    }
    return OcrTable(
      id: json['id'] as String,
      content: json['content'] as String,
      format: format,
      wordConfidenceScores: (json['word_confidence_scores'] as List?)
          ?.map((e) => OcrConfidenceScore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'format': format.value,
    if (wordConfidenceScores != null)
      'word_confidence_scores': wordConfidenceScores!
          .map((e) => e.toJson())
          .toList(),
  };

  /// Creates a copy with the specified fields replaced.
  OcrTable copyWith({
    String? id,
    String? content,
    OcrTableFormat? format,
    Object? wordConfidenceScores = unsetCopyWithValue,
  }) => OcrTable(
    id: id ?? this.id,
    content: content ?? this.content,
    format: format ?? this.format,
    wordConfidenceScores: wordConfidenceScores == unsetCopyWithValue
        ? this.wordConfidenceScores
        : wordConfidenceScores as List<OcrConfidenceScore>?,
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
