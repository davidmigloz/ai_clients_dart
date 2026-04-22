import 'package:meta/meta.dart';

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

  /// Creates an [OcrTable].
  const OcrTable({
    required this.id,
    required this.content,
    required this.format,
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
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'format': format.value,
  };

  /// Creates a copy with the specified fields replaced.
  OcrTable copyWith({String? id, String? content, OcrTableFormat? format}) =>
      OcrTable(
        id: id ?? this.id,
        content: content ?? this.content,
        format: format ?? this.format,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrTable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          format == other.format;

  @override
  int get hashCode => Object.hash(id, content, format);

  @override
  String toString() =>
      'OcrTable(id: $id, format: $format, '
      'content: ${content.length} chars)';
}
