import 'package:meta/meta.dart';

import '../content/content_part.dart';

/// Represents a document for OCR processing.
///
/// A document can be specified by a [UrlDocument], [ImageDocument],
/// [Base64Document], or [FileDocument].
@immutable
sealed class OcrDocument {
  const OcrDocument();

  /// Creates a document from a URL.
  const factory OcrDocument.url(String url) = UrlDocument;

  /// Creates a named document from a URL.
  const factory OcrDocument.namedUrl(
    String url, {
    required String documentName,
  }) = UrlDocument;

  /// Creates a document from an image URL or image data URL.
  const factory OcrDocument.image(ImageUrlContentPart image) = ImageDocument;

  /// Creates a document from base64-encoded data.
  const factory OcrDocument.base64({
    required String data,
    required String mimeType,
  }) = Base64Document;

  /// Creates a document from a file ID.
  const factory OcrDocument.file(String fileId) = FileDocument;

  /// Creates an [OcrDocument] from JSON.
  factory OcrDocument.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'document_url' ||
        (type == null && json.containsKey('document_url'))) {
      final url = json['document_url'] as String?;
      if (url == null) {
        throw const FormatException('OCR document URL is required');
      }
      final documentName = json['document_name'] as String?;
      return (documentName == null
              ? _base64DataUrl(url, image: false)
              : null) ??
          UrlDocument(url, documentName: documentName);
    }
    if (type == 'image_url' ||
        (type == null && json.containsKey('image_url'))) {
      final image = ImageUrlContentPart.fromJson(json);
      if (image.url.isEmpty) {
        throw const FormatException('OCR image URL is required');
      }
      return (image.detail == null
              ? _base64DataUrl(image.url, image: true)
              : null) ??
          ImageDocument(image);
    }
    if (type == 'file' || (type == null && json.containsKey('file_id'))) {
      final id = json['file_id'] as String?;
      if (id == null) throw const FormatException('OCR file ID is required');
      return FileDocument(id);
    }
    if (type == 'base64' || (type == null && json.containsKey('data'))) {
      final data = json['data'] as String?;
      if (data == null) {
        throw const FormatException('OCR base64 data is required');
      }
      return Base64Document(
        data: data,
        mimeType: json['mime_type'] as String? ?? 'application/pdf',
      );
    }
    throw FormatException('Unknown OCR document type: $type');
  }

  static Base64Document? _base64DataUrl(String url, {required bool image}) {
    final prefix = url.indexOf(';base64,');
    if (!url.startsWith('data:') || prefix <= 5) return null;
    final mimeType = url.substring(5, prefix);
    if (_isImageMimeType(mimeType) != image) return null;
    return Base64Document(mimeType: mimeType, data: url.substring(prefix + 8));
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A document specified by URL.
@immutable
class UrlDocument extends OcrDocument {
  /// The URL of the document.
  final String url;

  /// Optional source document filename.
  final String? documentName;

  /// Creates a [UrlDocument].
  const UrlDocument(this.url, {this.documentName});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'document_url',
    'document_url': url,
    if (documentName != null) 'document_name': documentName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlDocument &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          documentName == other.documentName;

  @override
  int get hashCode => Object.hash(url, documentName);

  @override
  String toString() => 'UrlDocument(documentName: $documentName)';
}

/// A document specified by base64-encoded data.
@immutable
class Base64Document extends OcrDocument {
  /// The base64-encoded document data.
  final String data;

  /// The MIME type of the document (e.g., 'application/pdf', 'image/png').
  final String mimeType;

  /// Creates a [Base64Document].
  const Base64Document({required this.data, required this.mimeType});

  @override
  Map<String, dynamic> toJson() {
    final url = 'data:$mimeType;base64,$data';
    return _isImageMimeType(mimeType)
        ? {'type': 'image_url', 'image_url': url}
        : {'type': 'document_url', 'document_url': url};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Base64Document &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          mimeType == other.mimeType;

  @override
  int get hashCode => Object.hash(data, mimeType);

  @override
  String toString() =>
      'Base64Document(mimeType: $mimeType, data: ${data.length} chars)';
}

/// A document specified by an image URL or data URL.
@immutable
class ImageDocument extends OcrDocument {
  /// Image URL and optional detail.
  final ImageUrlContentPart image;

  /// Creates a document from an image.
  const ImageDocument(this.image);

  @override
  Map<String, dynamic> toJson() => image.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ImageDocument && image == other.image;

  @override
  int get hashCode => image.hashCode;

  @override
  String toString() => 'ImageDocument(detail: ${image.detail})';
}

/// A document specified by file ID.
@immutable
class FileDocument extends OcrDocument {
  /// The ID of the uploaded file.
  final String fileId;

  /// Creates a [FileDocument].
  const FileDocument(this.fileId);

  @override
  Map<String, dynamic> toJson() => {'type': 'file', 'file_id': fileId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDocument &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FileDocument(fileId: $fileId)';
}

bool _isImageMimeType(String mimeType) =>
    mimeType.toLowerCase().startsWith('image/');
