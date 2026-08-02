import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/response_format.dart';
import 'ocr_confidence_scores_granularity.dart';
import 'ocr_document.dart';
import 'ocr_pages.dart';
import 'ocr_table_format.dart';

/// Request to process a document with OCR.
@immutable
class OcrRequest {
  /// The model to use for OCR processing.
  ///
  /// Use 'mistral-ocr-latest' for the best results.
  final String model;

  /// The document to process.
  final OcrDocument document;

  /// Specific pages to process.
  ///
  /// Accepts an explicit list of 0-indexed page numbers ([OcrPages.list]) or a
  /// comma-separated string of numbers and ranges ([OcrPages.string], e.g.
  /// `'0,2-4'`). If null, all pages are processed.
  final OcrPages? pages;

  /// Whether to include image base64 data in the response.
  ///
  /// Defaults to false.
  final bool? includeImageBase64;

  /// Whether to return paragraph-level bounding boxes for all content blocks.
  ///
  /// When `true`, each processed [OcrPage] includes a `blocks` list of
  /// [OcrBlock]s in reading order. Defaults to true.
  final bool? includeBlocks;

  /// Image limits for processing.
  final int? imageLimit;

  /// Image minimum size.
  final int? imageMinSize;

  /// Custom prompt for document annotation.
  final String? documentAnnotationPrompt;

  /// Format for extracted tables.
  final OcrTableFormat? tableFormat;

  /// Whether to extract page headers.
  final bool? extractHeader;

  /// Whether to extract page footers.
  final bool? extractFooter;

  /// Structured output format for extracting information from each
  /// extracted bounding box / image. Only json_schema is valid.
  final ResponseFormat? bboxAnnotationFormat;

  /// Structured output format for extracting information from the entire
  /// document. Only json_schema is valid.
  final ResponseFormat? documentAnnotationFormat;

  /// Granularity of confidence scores returned in the response.
  ///
  /// `word` returns per-word scores plus the page aggregate; `page` returns
  /// only the page aggregate. When omitted, no confidence scores are
  /// returned, which keeps the response payload small.
  final OcrConfidenceScoresGranularity? confidenceScoresGranularity;

  /// Creates an [OcrRequest].
  const OcrRequest({
    this.model = 'mistral-ocr-latest',
    required this.document,
    this.pages,
    this.includeImageBase64,
    this.includeBlocks,
    this.imageLimit,
    this.imageMinSize,
    this.documentAnnotationPrompt,
    this.tableFormat,
    this.extractHeader,
    this.extractFooter,
    this.bboxAnnotationFormat,
    this.documentAnnotationFormat,
    this.confidenceScoresGranularity,
  });

  /// Creates an [OcrRequest] from a URL.
  factory OcrRequest.fromUrl({
    String model = 'mistral-ocr-latest',
    required String url,
    OcrPages? pages,
    bool? includeImageBase64,
    bool? includeBlocks,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.url(url),
    pages: pages,
    includeImageBase64: includeImageBase64,
    includeBlocks: includeBlocks,
  );

  /// Creates an [OcrRequest] from a file ID.
  factory OcrRequest.fromFile({
    String model = 'mistral-ocr-latest',
    required String fileId,
    OcrPages? pages,
    bool? includeImageBase64,
    bool? includeBlocks,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.file(fileId),
    pages: pages,
    includeImageBase64: includeImageBase64,
    includeBlocks: includeBlocks,
  );

  /// Creates an [OcrRequest] from base64-encoded data.
  factory OcrRequest.fromBase64({
    String model = 'mistral-ocr-latest',
    required String data,
    required String mimeType,
    OcrPages? pages,
    bool? includeImageBase64,
    bool? includeBlocks,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.base64(data: data, mimeType: mimeType),
    pages: pages,
    includeImageBase64: includeImageBase64,
    includeBlocks: includeBlocks,
  );

  /// Creates an [OcrRequest] from JSON.
  factory OcrRequest.fromJson(Map<String, dynamic> json) => OcrRequest(
    model: json['model'] as String? ?? 'mistral-ocr-latest',
    document: OcrDocument.fromJson(json['document'] as Map<String, dynamic>),
    pages: json['pages'] != null
        ? OcrPages.fromJson(json['pages'] as Object)
        : null,
    includeImageBase64: json['include_image_base64'] as bool?,
    includeBlocks: json['include_blocks'] as bool?,
    imageLimit: json['image_limit'] as int?,
    imageMinSize: json['image_min_size'] as int?,
    documentAnnotationPrompt: json['document_annotation_prompt'] as String?,
    tableFormat: OcrTableFormat.fromString(json['table_format'] as String?),
    extractHeader: json['extract_header'] as bool?,
    extractFooter: json['extract_footer'] as bool?,
    bboxAnnotationFormat: json['bbox_annotation_format'] != null
        ? ResponseFormat.fromJson(
            json['bbox_annotation_format'] as Map<String, dynamic>,
          )
        : null,
    documentAnnotationFormat: json['document_annotation_format'] != null
        ? ResponseFormat.fromJson(
            json['document_annotation_format'] as Map<String, dynamic>,
          )
        : null,
    confidenceScoresGranularity: OcrConfidenceScoresGranularity.fromString(
      json['confidence_scores_granularity'] as String?,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'document': document.toJson(),
    if (pages != null) 'pages': pages!.toJson(),
    if (includeImageBase64 != null) 'include_image_base64': includeImageBase64,
    if (includeBlocks != null) 'include_blocks': includeBlocks,
    if (imageLimit != null) 'image_limit': imageLimit,
    if (imageMinSize != null) 'image_min_size': imageMinSize,
    if (documentAnnotationPrompt != null)
      'document_annotation_prompt': documentAnnotationPrompt,
    if (tableFormat != null) 'table_format': tableFormat!.value,
    if (extractHeader != null) 'extract_header': extractHeader,
    if (extractFooter != null) 'extract_footer': extractFooter,
    if (bboxAnnotationFormat != null)
      'bbox_annotation_format': bboxAnnotationFormat!.toJson(),
    if (documentAnnotationFormat != null)
      'document_annotation_format': documentAnnotationFormat!.toJson(),
    if (confidenceScoresGranularity != null)
      'confidence_scores_granularity': confidenceScoresGranularity!.value,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  OcrRequest copyWith({
    String? model,
    OcrDocument? document,
    Object? pages = unsetCopyWithValue,
    Object? includeImageBase64 = unsetCopyWithValue,
    Object? includeBlocks = unsetCopyWithValue,
    Object? imageLimit = unsetCopyWithValue,
    Object? imageMinSize = unsetCopyWithValue,
    Object? documentAnnotationPrompt = unsetCopyWithValue,
    Object? tableFormat = unsetCopyWithValue,
    Object? extractHeader = unsetCopyWithValue,
    Object? extractFooter = unsetCopyWithValue,
    Object? bboxAnnotationFormat = unsetCopyWithValue,
    Object? documentAnnotationFormat = unsetCopyWithValue,
    Object? confidenceScoresGranularity = unsetCopyWithValue,
  }) => OcrRequest(
    model: model ?? this.model,
    document: document ?? this.document,
    pages: pages == unsetCopyWithValue ? this.pages : pages as OcrPages?,
    includeImageBase64: includeImageBase64 == unsetCopyWithValue
        ? this.includeImageBase64
        : includeImageBase64 as bool?,
    includeBlocks: includeBlocks == unsetCopyWithValue
        ? this.includeBlocks
        : includeBlocks as bool?,
    imageLimit: imageLimit == unsetCopyWithValue
        ? this.imageLimit
        : imageLimit as int?,
    imageMinSize: imageMinSize == unsetCopyWithValue
        ? this.imageMinSize
        : imageMinSize as int?,
    documentAnnotationPrompt: documentAnnotationPrompt == unsetCopyWithValue
        ? this.documentAnnotationPrompt
        : documentAnnotationPrompt as String?,
    tableFormat: tableFormat == unsetCopyWithValue
        ? this.tableFormat
        : tableFormat as OcrTableFormat?,
    extractHeader: extractHeader == unsetCopyWithValue
        ? this.extractHeader
        : extractHeader as bool?,
    extractFooter: extractFooter == unsetCopyWithValue
        ? this.extractFooter
        : extractFooter as bool?,
    bboxAnnotationFormat: bboxAnnotationFormat == unsetCopyWithValue
        ? this.bboxAnnotationFormat
        : bboxAnnotationFormat as ResponseFormat?,
    documentAnnotationFormat: documentAnnotationFormat == unsetCopyWithValue
        ? this.documentAnnotationFormat
        : documentAnnotationFormat as ResponseFormat?,
    confidenceScoresGranularity:
        confidenceScoresGranularity == unsetCopyWithValue
        ? this.confidenceScoresGranularity
        : confidenceScoresGranularity as OcrConfidenceScoresGranularity?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          document == other.document &&
          pages == other.pages &&
          includeImageBase64 == other.includeImageBase64 &&
          includeBlocks == other.includeBlocks &&
          imageLimit == other.imageLimit &&
          imageMinSize == other.imageMinSize &&
          documentAnnotationPrompt == other.documentAnnotationPrompt &&
          tableFormat == other.tableFormat &&
          extractHeader == other.extractHeader &&
          extractFooter == other.extractFooter &&
          bboxAnnotationFormat == other.bboxAnnotationFormat &&
          documentAnnotationFormat == other.documentAnnotationFormat &&
          confidenceScoresGranularity == other.confidenceScoresGranularity;

  @override
  int get hashCode => Object.hash(
    model,
    document,
    pages,
    includeImageBase64,
    includeBlocks,
    imageLimit,
    imageMinSize,
    documentAnnotationPrompt,
    tableFormat,
    extractHeader,
    extractFooter,
    bboxAnnotationFormat,
    documentAnnotationFormat,
    confidenceScoresGranularity,
  );

  @override
  String toString() => 'OcrRequest(model: $model, document: $document)';
}
