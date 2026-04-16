import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'ocr_image.dart';
import 'ocr_page_confidence_scores.dart';
import 'ocr_page_dimensions.dart';
import 'ocr_table.dart';

/// Represents a processed page from OCR.
@immutable
class OcrPage {
  /// The page index (0-based).
  final int index;

  /// The extracted markdown text from the page.
  final String markdown;

  /// Images extracted from the page.
  final List<OcrImage> images;

  /// Dimensions of the page image (width, height, dpi).
  final OcrPageDimensions? dimensions;

  /// Tables extracted from the page.
  final List<OcrTable> tables;

  /// Header of the page.
  ///
  /// Populated when `extractHeader` is set to `true` in the request.
  final String? header;

  /// Footer of the page.
  ///
  /// Populated when `extractFooter` is set to `true` in the request.
  final String? footer;

  /// List of all hyperlinks in the page.
  final List<String> hyperlinks;

  /// Confidence scores for the page.
  ///
  /// Populated when `confidenceScoresGranularity` is set in the request.
  final OcrPageConfidenceScores? confidenceScores;

  /// Creates an [OcrPage].
  const OcrPage({
    required this.index,
    required this.markdown,
    this.images = const [],
    this.dimensions,
    this.tables = const [],
    this.header,
    this.footer,
    this.hyperlinks = const [],
    this.confidenceScores,
  });

  /// Creates an [OcrPage] from JSON.
  factory OcrPage.fromJson(Map<String, dynamic> json) => OcrPage(
    index: json['index'] as int? ?? 0,
    markdown: json['markdown'] as String? ?? '',
    images:
        (json['images'] as List?)
            ?.map((e) => OcrImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    dimensions: json['dimensions'] != null
        ? OcrPageDimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
        : null,
    tables:
        (json['tables'] as List?)
            ?.map((e) => OcrTable.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    header: json['header'] as String?,
    footer: json['footer'] as String?,
    hyperlinks: (json['hyperlinks'] as List?)?.cast<String>() ?? [],
    confidenceScores: json['confidence_scores'] != null
        ? OcrPageConfidenceScores.fromJson(
            json['confidence_scores'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    'markdown': markdown,
    if (images.isNotEmpty) 'images': images.map((e) => e.toJson()).toList(),
    if (dimensions != null) 'dimensions': dimensions!.toJson(),
    if (tables.isNotEmpty) 'tables': tables.map((e) => e.toJson()).toList(),
    if (header != null) 'header': header,
    if (footer != null) 'footer': footer,
    if (hyperlinks.isNotEmpty) 'hyperlinks': hyperlinks,
    if (confidenceScores != null)
      'confidence_scores': confidenceScores!.toJson(),
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  OcrPage copyWith({
    int? index,
    String? markdown,
    List<OcrImage>? images,
    Object? dimensions = unsetCopyWithValue,
    List<OcrTable>? tables,
    Object? header = unsetCopyWithValue,
    Object? footer = unsetCopyWithValue,
    List<String>? hyperlinks,
    Object? confidenceScores = unsetCopyWithValue,
  }) => OcrPage(
    index: index ?? this.index,
    markdown: markdown ?? this.markdown,
    images: images ?? this.images,
    dimensions: dimensions == unsetCopyWithValue
        ? this.dimensions
        : dimensions as OcrPageDimensions?,
    tables: tables ?? this.tables,
    header: header == unsetCopyWithValue ? this.header : header as String?,
    footer: footer == unsetCopyWithValue ? this.footer : footer as String?,
    hyperlinks: hyperlinks ?? this.hyperlinks,
    confidenceScores: confidenceScores == unsetCopyWithValue
        ? this.confidenceScores
        : confidenceScores as OcrPageConfidenceScores?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrPage &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          markdown == other.markdown &&
          listsEqual(images, other.images) &&
          dimensions == other.dimensions &&
          listsEqual(tables, other.tables) &&
          header == other.header &&
          footer == other.footer &&
          listsEqual(hyperlinks, other.hyperlinks) &&
          confidenceScores == other.confidenceScores;

  @override
  int get hashCode => Object.hash(
    index,
    markdown,
    listHash(images),
    dimensions,
    listHash(tables),
    header,
    footer,
    listHash(hyperlinks),
    confidenceScores,
  );

  @override
  String toString() =>
      'OcrPage(index: $index, markdown: ${markdown.length} chars, '
      'images: ${images.length} items, tables: ${tables.length} items)';
}
