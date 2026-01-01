import 'package:meta/meta.dart';

/// Represents a document for OCR processing.
///
/// A document can be specified by URL, base64 data, or file ID.
@immutable
sealed class OcrDocument {
  const OcrDocument();

  /// Creates a document from a URL.
  const factory OcrDocument.url(String url) = UrlDocument;

  /// Creates a document from base64-encoded data.
  const factory OcrDocument.base64({
    required String data,
    required String mimeType,
  }) = Base64Document;

  /// Creates a document from a file ID.
  const factory OcrDocument.file(String fileId) = FileDocument;

  /// Creates an [OcrDocument] from JSON.
  factory OcrDocument.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'document_url':
        return UrlDocument(json['document_url'] as String? ?? '');
      case 'base64':
        return Base64Document(
          data: json['data'] as String? ?? '',
          mimeType: json['mime_type'] as String? ?? 'application/pdf',
        );
      case 'file':
        return FileDocument(json['file_id'] as String? ?? '');
      default:
        // Try to infer from fields
        if (json.containsKey('document_url')) {
          return UrlDocument(json['document_url'] as String? ?? '');
        }
        if (json.containsKey('file_id')) {
          return FileDocument(json['file_id'] as String? ?? '');
        }
        if (json.containsKey('data')) {
          return Base64Document(
            data: json['data'] as String? ?? '',
            mimeType: json['mime_type'] as String? ?? 'application/pdf',
          );
        }
        throw FormatException('Unknown document type: $type');
    }
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A document specified by URL.
@immutable
class UrlDocument extends OcrDocument {
  /// The URL of the document.
  final String url;

  /// Creates a [UrlDocument].
  const UrlDocument(this.url);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'document_url',
    'document_url': url,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlDocument &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'UrlDocument(url: $url)';
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
  Map<String, dynamic> toJson() => {
    'type': 'base64',
    'data': data,
    'mime_type': mimeType,
  };

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
