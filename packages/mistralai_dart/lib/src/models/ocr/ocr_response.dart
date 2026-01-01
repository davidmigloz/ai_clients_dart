import 'package:meta/meta.dart';

import '../metadata/usage_info.dart';
import 'ocr_page.dart';

/// Response from OCR processing.
@immutable
class OcrResponse {
  /// Unique identifier for the response.
  final String id;

  /// Object type (always "ocr.response").
  final String object;

  /// The model used for processing.
  final String model;

  /// The processed pages with extracted text.
  final List<OcrPage> pages;

  /// Usage statistics.
  final UsageInfo? usage;

  /// Total number of pages in the document.
  final int? totalPages;

  /// Number of pages that were processed.
  final int? processedPages;

  /// Timestamp when processing was created.
  final DateTime? createdAt;

  /// Creates an [OcrResponse].
  const OcrResponse({
    required this.id,
    this.object = 'ocr.response',
    required this.model,
    required this.pages,
    this.usage,
    this.totalPages,
    this.processedPages,
    this.createdAt,
  });

  /// Creates an [OcrResponse] from JSON.
  factory OcrResponse.fromJson(Map<String, dynamic> json) => OcrResponse(
    id: json['id'] as String? ?? '',
    object: json['object'] as String? ?? 'ocr.response',
    model: json['model'] as String? ?? '',
    pages:
        (json['pages'] as List?)
            ?.map((e) => OcrPage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    usage: json['usage'] != null
        ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
        : null,
    totalPages: json['total_pages'] as int?,
    processedPages: json['processed_pages'] as int?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'model': model,
    'pages': pages.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (totalPages != null) 'total_pages': totalPages,
    if (processedPages != null) 'processed_pages': processedPages,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  /// Gets all extracted text as a single string.
  String get text => pages.map((p) => p.markdown).join('\n\n');

  /// Gets the markdown from a specific page.
  String? getPageText(int pageIndex) {
    final page = pages.where((p) => p.index == pageIndex).firstOrNull;
    return page?.markdown;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OcrResponse(id: $id, pages: ${pages.length})';
}
