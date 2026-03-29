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

/// Text content part.
@immutable
class TextContentPart extends ContentPart {
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
class ImageUrlContentPart extends ContentPart {
  @override
  String get type => 'image_url';

  /// The URL of the image.
  ///
  /// Can be a web URL (https://) or a base64 data URL
  /// (data:image/jpeg;base64,...).
  final String url;

  /// Creates an [ImageUrlContentPart].
  const ImageUrlContentPart(this.url);

  /// Creates an [ImageUrlContentPart] from JSON.
  factory ImageUrlContentPart.fromJson(Map<String, dynamic> json) {
    // Handle nested format: {"image_url": {"url": "..."}}
    final imageUrl = json['image_url'];
    if (imageUrl is Map<String, dynamic>) {
      return ImageUrlContentPart(imageUrl['url'] as String? ?? '');
    }
    // Handle flat format: {"image_url": "..."}
    return ImageUrlContentPart(imageUrl as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': {'url': url},
  };

  /// Creates a copy with the given fields replaced.
  ImageUrlContentPart copyWith({String? url}) =>
      ImageUrlContentPart(url ?? this.url);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUrlContentPart &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => Object.hash(type, url);

  @override
  String toString() => 'ImageUrlContentPart(url: $url)';
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

  /// Creates a [ThinkContentPart].
  const ThinkContentPart({required this.thinking, required this.closed});

  /// Creates a [ThinkContentPart] from JSON.
  factory ThinkContentPart.fromJson(Map<String, dynamic> json) =>
      ThinkContentPart(
        thinking:
            (json['thinking'] as List?)
                ?.map((e) => ContentPart.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const <ContentPart>[],
        closed: json['closed'] as bool? ?? true,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'thinking': thinking.map((e) => e.toJson()).toList(),
    'closed': closed,
  };

  /// Creates a copy with the given fields replaced.
  ThinkContentPart copyWith({List<ContentPart>? thinking, bool? closed}) =>
      ThinkContentPart(
        thinking: thinking ?? this.thinking,
        closed: closed ?? this.closed,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkContentPart &&
          runtimeType == other.runtimeType &&
          listsEqual(thinking, other.thinking) &&
          closed == other.closed;

  @override
  int get hashCode => Object.hash(type, Object.hashAll(thinking), closed);

  @override
  String toString() =>
      'ThinkContentPart(thinking: ${thinking.length} parts, closed: $closed)';
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

/// Unknown content part for forward compatibility.
///
/// Wraps the raw JSON map when the content type is not recognized.
@immutable
class UnknownContentPart extends ContentPart {
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
