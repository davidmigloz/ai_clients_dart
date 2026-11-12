import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../content/input_content_block.dart';

/// Source for document content.
///
/// Supply PDF data or URLs, plain text, custom content, or uploaded files.
sealed class DocumentSource {
  const DocumentSource();

  /// Creates a base64-encoded PDF source.
  factory DocumentSource.base64Pdf(String data) = Base64PdfSource;

  /// Creates a plain text source.
  factory DocumentSource.text(String data) = PlainTextSource;

  /// Creates a custom content document from a single string.
  factory DocumentSource.content(String text) = ContentBlockDocumentSource.text;

  /// Creates a custom content document from text and image blocks.
  factory DocumentSource.contentBlocks(List<InputContentBlock> blocks) =
      ContentBlockDocumentSource.blocks;

  /// Creates a URL-based PDF source.
  factory DocumentSource.url(String url) = UrlPdfSource;

  /// Creates a source referencing an uploaded file.
  factory DocumentSource.file(String fileId) = FileDocumentSource;

  /// Creates a [DocumentSource] from JSON.
  factory DocumentSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'base64' => Base64PdfSource.fromJson(json),
      'text' => PlainTextSource.fromJson(json),
      'content' => ContentBlockDocumentSource.fromJson(json),
      'url' => UrlPdfSource.fromJson(json),
      'file' => FileDocumentSource.fromJson(json),
      _ => throw FormatException('Unknown DocumentSource type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Base64-encoded PDF document source.
@immutable
class Base64PdfSource extends DocumentSource {
  /// The source type, always 'base64'.
  String get type => 'base64';

  /// The media type, always 'application/pdf'.
  String get mediaType => 'application/pdf';

  /// Base64-encoded PDF data.
  final String data;

  /// Creates a [Base64PdfSource].
  const Base64PdfSource(this.data);

  /// Creates a [Base64PdfSource] from JSON.
  factory Base64PdfSource.fromJson(Map<String, dynamic> json) {
    return Base64PdfSource(json['data'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
    'media_type': mediaType,
  };

  /// Creates a copy with replaced values.
  Base64PdfSource copyWith({String? data}) {
    return Base64PdfSource(data ?? this.data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Base64PdfSource &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Base64PdfSource(data: [${data.length} chars])';
}

/// Plain text document source.
@immutable
class PlainTextSource extends DocumentSource {
  /// The source type, always 'text'.
  String get type => 'text';

  /// The media type, always 'text/plain'.
  String get mediaType => 'text/plain';

  /// Plain text data.
  final String data;

  /// Creates a [PlainTextSource].
  const PlainTextSource(this.data);

  /// Creates a [PlainTextSource] from JSON.
  factory PlainTextSource.fromJson(Map<String, dynamic> json) {
    return PlainTextSource(json['data'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
    'media_type': mediaType,
  };

  /// Creates a copy with replaced values.
  PlainTextSource copyWith({String? data}) {
    return PlainTextSource(data ?? this.data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlainTextSource &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'PlainTextSource(data: [${data.length} chars])';
}

/// URL-based PDF document source.
@immutable
class UrlPdfSource extends DocumentSource {
  /// The source type, always 'url'.
  String get type => 'url';

  /// URL of the PDF document.
  final String url;

  /// Creates a [UrlPdfSource].
  const UrlPdfSource(this.url);

  /// Creates a [UrlPdfSource] from JSON.
  factory UrlPdfSource.fromJson(Map<String, dynamic> json) {
    return UrlPdfSource(json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'url': url};

  /// Creates a copy with replaced values.
  UrlPdfSource copyWith({String? url}) {
    return UrlPdfSource(url ?? this.url);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlPdfSource &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'UrlPdfSource(url: $url)';
}

/// Document source referencing a file uploaded through the Files API.
@immutable
class FileDocumentSource extends DocumentSource {
  /// The source type, always 'file'.
  String get type => 'file';

  /// The uploaded file's ID.
  final String fileId;

  /// Creates a [FileDocumentSource].
  const FileDocumentSource(this.fileId);

  /// Creates a [FileDocumentSource] from JSON.
  factory FileDocumentSource.fromJson(Map<String, dynamic> json) {
    return FileDocumentSource(json['file_id'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  /// Creates a copy with replaced values.
  FileDocumentSource copyWith({String? fileId}) {
    return FileDocumentSource(fileId ?? this.fileId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDocumentSource &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FileDocumentSource(fileId: $fileId)';
}

/// Custom content document whose text blocks define the citation boundaries.
///
/// Content can be one string or an ordered list of text and image blocks.
/// Claude can cite text but does not generate citations for images.
@immutable
final class ContentBlockDocumentSource extends DocumentSource {
  /// Creates a source with one unchunked text string.
  const ContentBlockDocumentSource.text(String this.text) : blocks = null;

  /// Creates a source whose blocks are each passed through as a single chunk.
  ///
  /// Accepts [TextInputBlock] and [ImageInputBlock] entries.
  ContentBlockDocumentSource.blocks(List<InputContentBlock> blocks)
    : text = null,
      blocks = List.unmodifiable(blocks) {
    for (final block in blocks) {
      if (block is! TextInputBlock && block is! ImageInputBlock) {
        throw ArgumentError('Custom documents accept text and image blocks');
      }
    }
  }

  /// Parses a string or ordered content blocks.
  factory ContentBlockDocumentSource.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'content') {
      throw const FormatException('Expected a custom content document source');
    }
    return switch (json['content']) {
      final String value => ContentBlockDocumentSource.text(value),
      final List<Object?> values => ContentBlockDocumentSource.blocks([
        for (final value in values) _parseBlock(value),
      ]),
      _ => throw const FormatException(
        'Expected a custom document string or blocks',
      ),
    };
  }

  /// The source discriminator.
  String get type => 'content';

  /// Content when it was supplied as a single string.
  final String? text;

  /// Ordered content when it was supplied as blocks.
  final List<InputContentBlock>? blocks;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'content': text ?? [for (final block in blocks!) block.toJson()],
  };

  /// Copies the source, optionally replacing its content representation.
  ContentBlockDocumentSource copyWith({
    String? text,
    List<InputContentBlock>? blocks,
  }) {
    if (text != null && blocks != null) {
      throw ArgumentError('Specify text or blocks for a custom document');
    }
    if (text != null) return ContentBlockDocumentSource.text(text);
    if (blocks != null) return ContentBlockDocumentSource.blocks(blocks);
    return this;
  }

  static InputContentBlock _parseBlock(Object? block) => switch (block) {
    final Map<String, dynamic> json when json['type'] == 'text' =>
      TextInputBlock.fromJson(json),
    final Map<String, dynamic> json when json['type'] == 'image' =>
      ImageInputBlock.fromJson(json),
    _ => throw const FormatException(
      'Custom documents accept text and image blocks',
    ),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlockDocumentSource &&
          text == other.text &&
          listsEqual(blocks, other.blocks);

  @override
  int get hashCode => Object.hash(text, listHash(blocks));

  @override
  String toString() =>
      'ContentBlockDocumentSource(textLength: ${text?.length}, '
      'blockCount: ${blocks?.length})';
}
