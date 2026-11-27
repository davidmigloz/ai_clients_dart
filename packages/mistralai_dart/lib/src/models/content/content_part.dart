import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Sealed class for content parts in chat messages.
///
/// Supports multimodal content including text, images, documents, files,
/// audio, references, thinking, and tool output content.
///
/// Variants:
/// - [TextContentPart] — Text content.
/// - [ImageUrlContentPart] — Image URL content.
/// - [DocumentUrlContentPart] — Document URL content.
/// - [ReferenceContentPart] — Reference IDs content.
/// - [FileContentPart] — File content by ID.
/// - [AudioContentPart] — Audio input content.
/// - [ThinkContentPart] — Thinking/reasoning content.
/// - [ToolFileContentPart] — File produced by a built-in tool.
/// - [ToolReferenceContentPart] — Reference produced by a built-in tool.
/// - [ResourceContentPart] — Resource URI and text or image content.
/// - [ResourceLinkContentPart] — Resource URI and optional metadata.
/// - [UnknownContentPart] — Unknown content type (forward compatibility).
sealed class ContentPart {
  const ContentPart();

  /// The type of this content part.
  String get type;

  /// Creates a [ContentPart] from JSON.
  factory ContentPart.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => TextContentPart.fromJson(json),
      'image_url' => ImageUrlContentPart.fromJson(json),
      'document_url' => DocumentUrlContentPart.fromJson(json),
      'reference' => ReferenceContentPart.fromJson(json),
      'file' => FileContentPart.fromJson(json),
      'input_audio' => AudioContentPart.fromJson(json),
      'thinking' => ThinkContentPart.fromJson(json),
      'tool_file' => ToolFileContentPart.fromJson(json),
      'tool_reference' => ToolReferenceContentPart.fromJson(json),
      'resource' => ResourceContentPart.fromJson(json),
      'resource_link' => ResourceLinkContentPart.fromJson(json),
      _ => UnknownContentPart(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  /// Creates a text content part.
  factory ContentPart.text(String text) => TextContentPart(text);

  /// Creates an image URL content part.
  factory ContentPart.imageUrl(String url) => ImageUrlContentPart(url);
}

/// A text or image payload embedded in a [ResourceContentPart].
///
/// [UnknownContentPart] keeps future payload kinds round-trippable.
sealed class ResourceChunkContent {
  /// Encodes the resource payload.
  Map<String, dynamic> toJson();
}

/// Text content part.
@immutable
class TextContentPart extends ContentPart implements ResourceChunkContent {
  @override
  String get type => 'text';

  /// The text content.
  final String text;

  /// Creates a [TextContentPart].
  const TextContentPart(this.text);

  /// Creates a [TextContentPart] from JSON.
  factory TextContentPart.fromJson(Map<String, dynamic> json) =>
      TextContentPart(json['text'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Creates a copy with the given fields replaced.
  TextContentPart copyWith({String? text}) =>
      TextContentPart(text ?? this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContentPart &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => Object.hash(type, text);

  @override
  String toString() => 'TextContentPart(text: $text)';
}

/// Image URL content part for vision models.
@immutable
class ImageUrlContentPart extends ContentPart implements ResourceChunkContent {
  @override
  String get type => 'image_url';

  /// The URL of the image.
  ///
  /// Can be a web URL (https://) or a base64 data URL
  /// (data:image/jpeg;base64,...).
  final String url;

  /// Optional image detail. Current values are `low`, `auto`, and `high`.
  final String? detail;

  /// Creates an [ImageUrlContentPart].
  const ImageUrlContentPart(this.url) : detail = null;

  /// Creates an image URL with a detail preference.
  const ImageUrlContentPart.withDetail(this.url, {required this.detail});

  /// Creates an [ImageUrlContentPart] from JSON.
  factory ImageUrlContentPart.fromJson(Map<String, dynamic> json) {
    // Handle nested format: {"image_url": {"url": "..."}}
    final imageUrl = json['image_url'];
    if (imageUrl is Map<String, dynamic>) {
      return ImageUrlContentPart.withDetail(
        imageUrl['url'] as String? ?? '',
        detail: imageUrl['detail'] as String?,
      );
    }
    // Handle flat format: {"image_url": "..."}
    return ImageUrlContentPart(imageUrl as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': {'url': url, if (detail != null) 'detail': detail},
  };

  /// Creates a copy with the given fields replaced.
  ImageUrlContentPart copyWith({
    String? url,
    Object? detail = unsetCopyWithValue,
  }) => ImageUrlContentPart.withDetail(
    url ?? this.url,
    detail: detail == unsetCopyWithValue ? this.detail : detail as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUrlContentPart &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(type, url, detail);

  @override
  String toString() => 'ImageUrlContentPart(url: $url, detail: $detail)';
}

/// Document URL content part.
@immutable
class DocumentUrlContentPart extends ContentPart {
  @override
  String get type => 'document_url';

  /// The URL of the document.
  final String documentUrl;

  /// An optional name for the document.
  final String? documentName;

  /// Creates a [DocumentUrlContentPart].
  const DocumentUrlContentPart({required this.documentUrl, this.documentName});

  /// Creates a [DocumentUrlContentPart] from JSON.
  factory DocumentUrlContentPart.fromJson(Map<String, dynamic> json) =>
      DocumentUrlContentPart(
        documentUrl: json['document_url'] as String? ?? '',
        documentName: json['document_name'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'document_url': documentUrl,
    if (documentName != null) 'document_name': documentName,
  };

  /// Creates a copy with the given fields replaced.
  DocumentUrlContentPart copyWith({
    String? documentUrl,
    Object? documentName = unsetCopyWithValue,
  }) => DocumentUrlContentPart(
    documentUrl: documentUrl ?? this.documentUrl,
    documentName: documentName == unsetCopyWithValue
        ? this.documentName
        : documentName as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentUrlContentPart &&
          runtimeType == other.runtimeType &&
          documentUrl == other.documentUrl &&
          documentName == other.documentName;

  @override
  int get hashCode => Object.hash(type, documentUrl, documentName);

  @override
  String toString() =>
      'DocumentUrlContentPart(documentUrl: $documentUrl, '
      'documentName: $documentName)';
}

/// Reference content part containing reference IDs.
@immutable
class ReferenceContentPart extends ContentPart {
  @override
  String get type => 'reference';

  /// The list of reference IDs.
  final List<int> referenceIds;

  /// Creates a [ReferenceContentPart].
  const ReferenceContentPart({required this.referenceIds});

  /// Creates a [ReferenceContentPart] from JSON.
  factory ReferenceContentPart.fromJson(Map<String, dynamic> json) =>
      ReferenceContentPart(
        referenceIds:
            (json['reference_ids'] as List?)?.cast<int>() ?? const <int>[],
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'reference_ids': referenceIds,
  };

  /// Creates a copy with the given fields replaced.
  ReferenceContentPart copyWith({List<int>? referenceIds}) =>
      ReferenceContentPart(referenceIds: referenceIds ?? this.referenceIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceContentPart &&
          runtimeType == other.runtimeType &&
          listsEqual(referenceIds, other.referenceIds);

  @override
  int get hashCode => Object.hash(type, Object.hashAll(referenceIds));

  @override
  String toString() => 'ReferenceContentPart(referenceIds: $referenceIds)';
}

/// File content part referencing a file by ID.
@immutable
class FileContentPart extends ContentPart {
  @override
  String get type => 'file';

  /// The file identifier.
  final String fileId;

  /// Creates a [FileContentPart].
  const FileContentPart({required this.fileId});

  /// Creates a [FileContentPart] from JSON.
  factory FileContentPart.fromJson(Map<String, dynamic> json) =>
      FileContentPart(fileId: json['file_id'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  /// Creates a copy with the given fields replaced.
  FileContentPart copyWith({String? fileId}) =>
      FileContentPart(fileId: fileId ?? this.fileId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileContentPart &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => Object.hash(type, fileId);

  @override
  String toString() => 'FileContentPart(fileId: $fileId)';
}

/// Audio input content part.
@immutable
class AudioContentPart extends ContentPart {
  @override
  String get type => 'input_audio';

  /// The audio data (base64-encoded or URL).
  final String inputAudio;

  /// Creates an [AudioContentPart].
  const AudioContentPart({required this.inputAudio});

  /// Creates an [AudioContentPart] from JSON.
  factory AudioContentPart.fromJson(Map<String, dynamic> json) =>
      AudioContentPart(inputAudio: json['input_audio'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'type': type, 'input_audio': inputAudio};

  /// Creates a copy with the given fields replaced.
  AudioContentPart copyWith({String? inputAudio}) =>
      AudioContentPart(inputAudio: inputAudio ?? this.inputAudio);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioContentPart &&
          runtimeType == other.runtimeType &&
          inputAudio == other.inputAudio;

  @override
  int get hashCode => Object.hash(type, inputAudio);

  @override
  String toString() =>
      'AudioContentPart(inputAudio: ${inputAudio.length} chars)';
}

/// Thinking/reasoning content part.
@immutable
class ThinkContentPart extends ContentPart {
  @override
  String get type => 'thinking';

  /// The thinking content parts.
  final List<ContentPart> thinking;

  /// Whether the thinking block is closed.
  final bool closed;

  /// An opaque signature for the thinking block, when provided by the API.
  final String? signature;

  /// Creates a [ThinkContentPart].
  const ThinkContentPart({
    required this.thinking,
    required this.closed,
    this.signature,
  });

  /// Creates a [ThinkContentPart] from JSON.
  factory ThinkContentPart.fromJson(Map<String, dynamic> json) =>
      ThinkContentPart(
        thinking:
            (json['thinking'] as List?)
                ?.map((e) => ContentPart.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <ContentPart>[],
        closed: json['closed'] as bool? ?? true,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'thinking': thinking.map((e) => e.toJson()).toList(),
    'closed': closed,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with the given fields replaced.
  ThinkContentPart copyWith({
    List<ContentPart>? thinking,
    bool? closed,
    Object? signature = unsetCopyWithValue,
  }) => ThinkContentPart(
    thinking: thinking ?? this.thinking,
    closed: closed ?? this.closed,
    signature: signature == unsetCopyWithValue
        ? this.signature
        : signature as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkContentPart &&
          runtimeType == other.runtimeType &&
          listsEqual(thinking, other.thinking) &&
          closed == other.closed &&
          signature == other.signature;

  @override
  int get hashCode =>
      Object.hash(type, Object.hashAll(thinking), closed, signature);

  @override
  String toString() =>
      'ThinkContentPart(thinking: ${thinking.length} parts, closed: $closed, '
      'signature: ${signature == null ? null : '[${signature!.length} chars]'})';
}

/// File content part produced by a built-in tool (e.g. code interpreter).
@immutable
class ToolFileContentPart extends ContentPart {
  @override
  String get type => 'tool_file';

  /// The built-in tool that produced this file (e.g. "code_interpreter").
  final String tool;

  /// The file identifier.
  final String fileId;

  /// An optional file name.
  final String? fileName;

  /// An optional file MIME type.
  final String? fileType;

  /// Creates a [ToolFileContentPart].
  const ToolFileContentPart({
    required this.tool,
    required this.fileId,
    this.fileName,
    this.fileType,
  });

  /// Creates a [ToolFileContentPart] from JSON.
  factory ToolFileContentPart.fromJson(Map<String, dynamic> json) =>
      ToolFileContentPart(
        tool: json['tool'] as String? ?? '',
        fileId: json['file_id'] as String? ?? '',
        fileName: json['file_name'] as String?,
        fileType: json['file_type'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'tool': tool,
    'file_id': fileId,
    if (fileName != null) 'file_name': fileName,
    if (fileType != null) 'file_type': fileType,
  };

  /// Creates a copy with the given fields replaced.
  ToolFileContentPart copyWith({
    String? tool,
    String? fileId,
    Object? fileName = unsetCopyWithValue,
    Object? fileType = unsetCopyWithValue,
  }) => ToolFileContentPart(
    tool: tool ?? this.tool,
    fileId: fileId ?? this.fileId,
    fileName: fileName == unsetCopyWithValue
        ? this.fileName
        : fileName as String?,
    fileType: fileType == unsetCopyWithValue
        ? this.fileType
        : fileType as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolFileContentPart &&
          runtimeType == other.runtimeType &&
          tool == other.tool &&
          fileId == other.fileId &&
          fileName == other.fileName &&
          fileType == other.fileType;

  @override
  int get hashCode => Object.hash(type, tool, fileId, fileName, fileType);

  @override
  String toString() =>
      'ToolFileContentPart(tool: $tool, fileId: $fileId, '
      'fileName: $fileName, fileType: $fileType)';
}

/// Reference content part produced by a built-in tool (e.g. web search).
@immutable
class ToolReferenceContentPart extends ContentPart {
  @override
  String get type => 'tool_reference';

  /// The built-in tool that produced this reference (e.g. "web_search").
  final String tool;

  /// The title of the reference.
  final String title;

  /// An optional URL for the reference.
  final String? url;

  /// An optional description of the reference.
  final String? description;

  /// An optional favicon URL.
  final String? favicon;

  /// Creates a [ToolReferenceContentPart].
  const ToolReferenceContentPart({
    required this.tool,
    required this.title,
    this.url,
    this.description,
    this.favicon,
  });

  /// Creates a [ToolReferenceContentPart] from JSON.
  factory ToolReferenceContentPart.fromJson(Map<String, dynamic> json) =>
      ToolReferenceContentPart(
        tool: json['tool'] as String? ?? '',
        title: json['title'] as String? ?? '',
        url: json['url'] as String?,
        description: json['description'] as String?,
        favicon: json['favicon'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'tool': tool,
    'title': title,
    if (url != null) 'url': url,
    if (description != null) 'description': description,
    if (favicon != null) 'favicon': favicon,
  };

  /// Creates a copy with the given fields replaced.
  ToolReferenceContentPart copyWith({
    String? tool,
    String? title,
    Object? url = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? favicon = unsetCopyWithValue,
  }) => ToolReferenceContentPart(
    tool: tool ?? this.tool,
    title: title ?? this.title,
    url: url == unsetCopyWithValue ? this.url : url as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    favicon: favicon == unsetCopyWithValue ? this.favicon : favicon as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolReferenceContentPart &&
          runtimeType == other.runtimeType &&
          tool == other.tool &&
          title == other.title &&
          url == other.url &&
          description == other.description &&
          favicon == other.favicon;

  @override
  int get hashCode => Object.hash(type, tool, title, url, description, favicon);

  @override
  String toString() =>
      'ToolReferenceContentPart(tool: $tool, title: $title, '
      'url: $url, description: $description, favicon: $favicon)';
}

/// Text or an image associated with a resource URI.
@immutable
class ResourceContentPart extends ContentPart {
  /// Creates an embedded resource part.
  const ResourceContentPart({required this.uri, required this.content});

  @override
  String get type => 'resource';

  /// Resource identifier.
  final String uri;

  /// Inline text or image. Future types retain their raw JSON.
  final ResourceChunkContent content;

  /// Parses a resource chunk.
  factory ResourceContentPart.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != null && type != 'resource') {
      throw FormatException('ResourceContentPart: unexpected type "$type"');
    }
    final uri = json['uri'] as String?;
    final value = json['content'] as Map<String, dynamic>?;
    if (uri == null || value == null) {
      throw const FormatException(
        'ResourceContentPart requires uri and content',
      );
    }
    final ResourceChunkContent content = switch (value['type']) {
      'text' => TextContentPart.fromJson(value),
      'image_url' => ImageUrlContentPart.fromJson(value),
      _ => UnknownContentPart(value),
    };
    return ResourceContentPart(uri: uri, content: content);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'uri': uri,
    'content': content.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ResourceContentPart copyWith({String? uri, ResourceChunkContent? content}) =>
      ResourceContentPart(
        uri: uri ?? this.uri,
        content: content ?? this.content,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceContentPart &&
          uri == other.uri &&
          content == other.content;

  @override
  int get hashCode => Object.hash(uri, content);

  @override
  String toString() => 'ResourceContentPart(uri: $uri, content: $content)';
}

/// A link to a resource, with optional primitive-valued metadata.
@immutable
class ResourceLinkContentPart extends ContentPart {
  /// Creates a resource link.
  const ResourceLinkContentPart({required this.uri, this.metadata});

  @override
  String get type => 'resource_link';

  /// Resource identifier.
  final String uri;

  /// Metadata values are strings, numbers or booleans.
  final Map<String, Object>? metadata;

  /// Parses a resource-link chunk.
  factory ResourceLinkContentPart.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != null && type != 'resource_link') {
      throw FormatException('ResourceLinkContentPart: unexpected type "$type"');
    }
    final uri = json['uri'] as String?;
    if (uri == null) {
      throw const FormatException('ResourceLinkContentPart requires uri');
    }
    final metadata = json['metadata'] as Map<String, dynamic>?;
    if (metadata != null) {
      _validateResourceLinkMetadata(metadata);
    }
    return ResourceLinkContentPart(
      uri: uri,
      metadata: metadata?.cast<String, Object>(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final metadata = this.metadata;
    if (metadata != null) {
      _validateResourceLinkMetadata(metadata);
    }
    return {'type': type, 'uri': uri, 'metadata': ?metadata};
  }

  /// Creates a copy with the given fields replaced.
  ResourceLinkContentPart copyWith({
    String? uri,
    Object? metadata = unsetCopyWithValue,
  }) => ResourceLinkContentPart(
    uri: uri ?? this.uri,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : metadata as Map<String, Object>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceLinkContentPart &&
          uri == other.uri &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(uri, mapHash(metadata));

  @override
  String toString() =>
      'ResourceLinkContentPart(uri: $uri, metadata: ${metadata?.length})';
}

void _validateResourceLinkMetadata(Map<String, Object?> metadata) {
  for (final entry in metadata.entries) {
    final value = entry.value;
    if (value is! String && value is! num && value is! bool) {
      throw FormatException(
        'Unsupported resource-link metadata at "${entry.key}"',
      );
    }
  }
}

/// Unknown content part for forward compatibility.
///
/// Wraps the raw JSON map when the content type is not recognized.
@immutable
class UnknownContentPart extends ContentPart implements ResourceChunkContent {
  @override
  String get type => _raw['type'] as String? ?? 'unknown';

  /// The raw JSON data.
  final Map<String, dynamic> _raw;

  /// Creates an [UnknownContentPart].
  UnknownContentPart(Map<String, dynamic> raw)
    : _raw = Map<String, dynamic>.unmodifiable(raw);

  /// The raw JSON data.
  Map<String, dynamic> get raw => _raw;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownContentPart &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() => 'UnknownContentPart(type: $type)';
}
