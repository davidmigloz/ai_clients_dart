import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'ocr_block.dart';
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

  /// Aggregate (and optionally per-word) confidence scores for this page.
  ///
  /// Populated when [OcrRequest.confidenceScoresGranularity] is set
  /// (either [OcrConfidenceScoresGranularity.word] or
  /// [OcrConfidenceScoresGranularity.page]); `null` otherwise.
  final OcrPageConfidenceScores? confidenceScores;

  /// Paragraph-level content blocks with bounding boxes, in reading order.
  ///
  /// Populated when [OcrRequest.includeBlocks] is set to `true` in the request;
  /// `null` otherwise.
  final List<OcrBlock>? blocks;

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
    this.blocks,
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
    blocks: (json['blocks'] as List?)
        ?.map((e) => OcrBlock.fromJson(e as Map<String, dynamic>))
        .toList(),
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
    if (blocks != null) 'blocks': blocks!.map((e) => e.toJson()).toList(),
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
    Object? blocks = unsetCopyWithValue,
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
    blocks: blocks == unsetCopyWithValue
        ? this.blocks
        : blocks as List<OcrBlock>?,
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
          confidenceScores == other.confidenceScores &&
          listsEqual(blocks, other.blocks);

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
    listHash(blocks),
  );

  @override
  String toString() =>
      'OcrPage(index: $index, markdown: ${markdown.length} chars, '
      'images: ${images.length} items, tables: ${tables.length} items)';
}
