import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'ocr_page.dart';
import 'ocr_usage_info.dart';

/// Response from OCR processing.
@immutable
class OcrResponse {
  /// The model used for processing.
  final String model;

  /// The processed pages with extracted text.
  final List<OcrPage> pages;

  /// Usage statistics for the OCR request.
  final OcrUsageInfo? usageInfo;

  /// Formatted annotation response when `documentAnnotationFormat` is set.
  ///
  /// Contains the structured output as a JSON string.
  final String? documentAnnotation;

  /// Creates an [OcrResponse].
  const OcrResponse({
    required this.model,
    required this.pages,
    this.usageInfo,
    this.documentAnnotation,
  });

  /// Creates an [OcrResponse] from JSON.
  factory OcrResponse.fromJson(Map<String, dynamic> json) => OcrResponse(
    model: json['model'] as String? ?? '',
    pages:
        (json['pages'] as List?)
            ?.map((e) => OcrPage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    usageInfo: json['usage_info'] != null
        ? OcrUsageInfo.fromJson(json['usage_info'] as Map<String, dynamic>)
        : null,
    documentAnnotation: json['document_annotation'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'pages': pages.map((e) => e.toJson()).toList(),
    if (usageInfo != null) 'usage_info': usageInfo!.toJson(),
    if (documentAnnotation != null) 'document_annotation': documentAnnotation,
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
          model == other.model &&
          listsEqual(pages, other.pages) &&
          usageInfo == other.usageInfo &&
          documentAnnotation == other.documentAnnotation;

  @override
  int get hashCode =>
      Object.hash(model, listHash(pages), usageInfo, documentAnnotation);

  @override
  String toString() => 'OcrResponse(model: $model, pages: ${pages.length})';
}
