import 'package:meta/meta.dart';

import '../metadata/response_format.dart';
import 'ocr_document.dart';

/// Request to process a document with OCR.
@immutable
class OcrRequest {
  /// The model to use for OCR processing.
  ///
  /// Use 'mistral-ocr-latest' for the best results.
  final String model;

  /// The document to process.
  final OcrDocument document;

  /// Unique identifier for the request.
  final String? id;

  /// Specific pages to process (0-indexed).
  ///
  /// If null, all pages are processed.
  final List<int>? pages;

  /// Whether to include image base64 data in the response.
  ///
  /// Defaults to false.
  final bool? includeImageBase64;

  /// Image limits for processing.
  final int? imageLimit;

  /// Image minimum size.
  final int? imageMinSize;

  /// Custom prompt for document annotation.
  final String? documentAnnotationPrompt;

  /// Granularity level for confidence scores.
  ///
  /// Set to `'page'` to get aggregate statistics (average and minimum) per
  /// page, or `'word'` to also get per-word scores on each page and table.
  /// Defaults to null (no confidence scores returned).
  final String? confidenceScoresGranularity;

  /// Format for extracted tables (`'markdown'` or `'html'`).
  final String? tableFormat;

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

  /// Creates an [OcrRequest].
  const OcrRequest({
    this.model = 'mistral-ocr-latest',
    required this.document,
    this.id,
    this.pages,
    this.includeImageBase64,
    this.imageLimit,
    this.imageMinSize,
    this.documentAnnotationPrompt,
    this.confidenceScoresGranularity,
    this.tableFormat,
    this.extractHeader,
    this.extractFooter,
    this.bboxAnnotationFormat,
    this.documentAnnotationFormat,
  });

  /// Creates an [OcrRequest] from a URL.
  factory OcrRequest.fromUrl({
    String model = 'mistral-ocr-latest',
    required String url,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
    String? confidenceScoresGranularity,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.url(url),
    id: id,
    pages: pages,
    includeImageBase64: includeImageBase64,
    confidenceScoresGranularity: confidenceScoresGranularity,
  );

  /// Creates an [OcrRequest] from a file ID.
  factory OcrRequest.fromFile({
    String model = 'mistral-ocr-latest',
    required String fileId,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
    String? confidenceScoresGranularity,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.file(fileId),
    id: id,
    pages: pages,
    includeImageBase64: includeImageBase64,
    confidenceScoresGranularity: confidenceScoresGranularity,
  );

  /// Creates an [OcrRequest] from base64-encoded data.
  factory OcrRequest.fromBase64({
    String model = 'mistral-ocr-latest',
    required String data,
    required String mimeType,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
    String? confidenceScoresGranularity,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.base64(data: data, mimeType: mimeType),
    id: id,
    pages: pages,
    includeImageBase64: includeImageBase64,
    confidenceScoresGranularity: confidenceScoresGranularity,
  );

  /// Creates an [OcrRequest] from JSON.
  factory OcrRequest.fromJson(Map<String, dynamic> json) => OcrRequest(
    model: json['model'] as String? ?? 'mistral-ocr-latest',
    document: OcrDocument.fromJson(json['document'] as Map<String, dynamic>),
    id: json['id'] as String?,
    pages: (json['pages'] as List?)?.cast<int>(),
    includeImageBase64: json['include_image_base64'] as bool?,
    imageLimit: json['image_limit'] as int?,
    imageMinSize: json['image_min_size'] as int?,
    documentAnnotationPrompt: json['document_annotation_prompt'] as String?,
    confidenceScoresGranularity:
        json['confidence_scores_granularity'] as String?,
    tableFormat: json['table_format'] as String?,
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
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'document': document.toJson(),
    if (id != null) 'id': id,
    if (pages != null) 'pages': pages,
    if (includeImageBase64 != null) 'include_image_base64': includeImageBase64,
    if (imageLimit != null) 'image_limit': imageLimit,
    if (imageMinSize != null) 'image_min_size': imageMinSize,
    if (documentAnnotationPrompt != null)
      'document_annotation_prompt': documentAnnotationPrompt,
    if (confidenceScoresGranularity != null)
      'confidence_scores_granularity': confidenceScoresGranularity,
    if (tableFormat != null) 'table_format': tableFormat,
    if (extractHeader != null) 'extract_header': extractHeader,
    if (extractFooter != null) 'extract_footer': extractFooter,
    if (bboxAnnotationFormat != null)
      'bbox_annotation_format': bboxAnnotationFormat!.toJson(),
    if (documentAnnotationFormat != null)
      'document_annotation_format': documentAnnotationFormat!.toJson(),
  };

  /// Creates a copy with the specified fields replaced.
  OcrRequest copyWith({
    String? model,
    OcrDocument? document,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
    int? imageLimit,
    int? imageMinSize,
    String? documentAnnotationPrompt,
    String? confidenceScoresGranularity,
    String? tableFormat,
    bool? extractHeader,
    bool? extractFooter,
    ResponseFormat? bboxAnnotationFormat,
    ResponseFormat? documentAnnotationFormat,
  }) => OcrRequest(
    model: model ?? this.model,
    document: document ?? this.document,
    id: id ?? this.id,
    pages: pages ?? this.pages,
    includeImageBase64: includeImageBase64 ?? this.includeImageBase64,
    imageLimit: imageLimit ?? this.imageLimit,
    imageMinSize: imageMinSize ?? this.imageMinSize,
    documentAnnotationPrompt:
        documentAnnotationPrompt ?? this.documentAnnotationPrompt,
    confidenceScoresGranularity:
        confidenceScoresGranularity ?? this.confidenceScoresGranularity,
    tableFormat: tableFormat ?? this.tableFormat,
    extractHeader: extractHeader ?? this.extractHeader,
    extractFooter: extractFooter ?? this.extractFooter,
    bboxAnnotationFormat: bboxAnnotationFormat ?? this.bboxAnnotationFormat,
    documentAnnotationFormat:
        documentAnnotationFormat ?? this.documentAnnotationFormat,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          document == other.document;

  @override
  int get hashCode => Object.hash(model, document);

  @override
  String toString() => 'OcrRequest(model: $model, document: $document)';
}
