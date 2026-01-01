import 'package:meta/meta.dart';

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

  /// Creates an [OcrRequest].
  const OcrRequest({
    this.model = 'mistral-ocr-latest',
    required this.document,
    this.id,
    this.pages,
    this.includeImageBase64,
    this.imageLimit,
    this.imageMinSize,
  });

  /// Creates an [OcrRequest] from a URL.
  factory OcrRequest.fromUrl({
    String model = 'mistral-ocr-latest',
    required String url,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.url(url),
    id: id,
    pages: pages,
    includeImageBase64: includeImageBase64,
  );

  /// Creates an [OcrRequest] from a file ID.
  factory OcrRequest.fromFile({
    String model = 'mistral-ocr-latest',
    required String fileId,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.file(fileId),
    id: id,
    pages: pages,
    includeImageBase64: includeImageBase64,
  );

  /// Creates an [OcrRequest] from base64-encoded data.
  factory OcrRequest.fromBase64({
    String model = 'mistral-ocr-latest',
    required String data,
    required String mimeType,
    String? id,
    List<int>? pages,
    bool? includeImageBase64,
  }) => OcrRequest(
    model: model,
    document: OcrDocument.base64(data: data, mimeType: mimeType),
    id: id,
    pages: pages,
    includeImageBase64: includeImageBase64,
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
  }) => OcrRequest(
    model: model ?? this.model,
    document: document ?? this.document,
    id: id ?? this.id,
    pages: pages ?? this.pages,
    includeImageBase64: includeImageBase64 ?? this.includeImageBase64,
    imageLimit: imageLimit ?? this.imageLimit,
    imageMinSize: imageMinSize ?? this.imageMinSize,
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
