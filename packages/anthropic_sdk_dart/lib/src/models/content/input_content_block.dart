import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/cache_control.dart';
import '../sources/document_source.dart';
import '../sources/image_source.dart';

/// Content block for input messages.
///
/// Input content blocks are used in user and assistant messages.
sealed class InputContentBlock {
  const InputContentBlock();

  /// Creates a text content block.
  factory InputContentBlock.text(
    String text, {
    CacheControlEphemeral? cacheControl,
  }) = TextInputBlock;

  /// Creates an image content block.
  factory InputContentBlock.image(
    ImageSource source, {
    CacheControlEphemeral? cacheControl,
  }) = ImageInputBlock;

  /// Creates a document content block.
  factory InputContentBlock.document(
    DocumentSource source, {
    String? title,
    CacheControlEphemeral? cacheControl,
  }) = DocumentInputBlock;

  /// Creates a tool use block (for assistant messages).
  factory InputContentBlock.toolUse({
    required String id,
    required String name,
    required Map<String, dynamic> input,
    CacheControlEphemeral? cacheControl,
  }) = ToolUseInputBlock;

  /// Creates a tool result block (for user messages).
  factory InputContentBlock.toolResult({
    required String toolUseId,
    List<ToolResultContent>? content,
    bool? isError,
    CacheControlEphemeral? cacheControl,
  }) = ToolResultInputBlock;

  /// Creates an [InputContentBlock] from JSON.
  factory InputContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => TextInputBlock.fromJson(json),
      'image' => ImageInputBlock.fromJson(json),
      'document' => DocumentInputBlock.fromJson(json),
      'tool_use' => ToolUseInputBlock.fromJson(json),
      'tool_result' => ToolResultInputBlock.fromJson(json),
      _ => throw FormatException('Unknown InputContentBlock type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text content block for input.
@immutable
class TextInputBlock extends InputContentBlock {
  /// The text content.
  final String text;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [TextInputBlock].
  const TextInputBlock(this.text, {this.cacheControl});

  /// Creates a [TextInputBlock] from JSON.
  factory TextInputBlock.fromJson(Map<String, dynamic> json) {
    return TextInputBlock(
      json['text'] as String,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text',
    'text': text,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  TextInputBlock copyWith({
    String? text,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return TextInputBlock(
      text ?? this.text,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextInputBlock &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(text, cacheControl);

  @override
  String toString() =>
      'TextInputBlock(text: [${text.length} chars], cacheControl: $cacheControl)';
}

/// Image content block for input.
@immutable
class ImageInputBlock extends InputContentBlock {
  /// The image source.
  final ImageSource source;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates an [ImageInputBlock].
  const ImageInputBlock(this.source, {this.cacheControl});

  /// Creates an [ImageInputBlock] from JSON.
  factory ImageInputBlock.fromJson(Map<String, dynamic> json) {
    return ImageInputBlock(
      ImageSource.fromJson(json['source'] as Map<String, dynamic>),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image',
    'source': source.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ImageInputBlock copyWith({
    ImageSource? source,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ImageInputBlock(
      source ?? this.source,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageInputBlock &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(source, cacheControl);

  @override
  String toString() =>
      'ImageInputBlock(source: $source, cacheControl: $cacheControl)';
}

/// Document content block for input.
@immutable
class DocumentInputBlock extends InputContentBlock {
  /// The document source.
  final DocumentSource source;

  /// Optional title for the document.
  final String? title;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [DocumentInputBlock].
  const DocumentInputBlock(this.source, {this.title, this.cacheControl});

  /// Creates a [DocumentInputBlock] from JSON.
  factory DocumentInputBlock.fromJson(Map<String, dynamic> json) {
    return DocumentInputBlock(
      DocumentSource.fromJson(json['source'] as Map<String, dynamic>),
      title: json['title'] as String?,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'document',
    'source': source.toJson(),
    if (title != null) 'title': title,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  DocumentInputBlock copyWith({
    DocumentSource? source,
    Object? title = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return DocumentInputBlock(
      source ?? this.source,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentInputBlock &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          title == other.title &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(source, title, cacheControl);

  @override
  String toString() =>
      'DocumentInputBlock(source: $source, title: $title, '
      'cacheControl: $cacheControl)';
}

/// Tool use block for assistant messages in input.
@immutable
class ToolUseInputBlock extends InputContentBlock {
  /// Unique identifier for this tool use.
  final String id;

  /// Name of the tool being used.
  final String name;

  /// Input parameters for the tool.
  final Map<String, dynamic> input;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ToolUseInputBlock].
  const ToolUseInputBlock({
    required this.id,
    required this.name,
    required this.input,
    this.cacheControl,
  });

  /// Creates a [ToolUseInputBlock] from JSON.
  factory ToolUseInputBlock.fromJson(Map<String, dynamic> json) {
    return ToolUseInputBlock(
      id: json['id'] as String,
      name: json['name'] as String,
      input: json['input'] as Map<String, dynamic>,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_use',
    'id': id,
    'name': name,
    'input': input,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolUseInputBlock copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? input,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ToolUseInputBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      input: input ?? this.input,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolUseInputBlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          _mapsEqual(input, other.input) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(id, name, input, cacheControl);

  @override
  String toString() =>
      'ToolUseInputBlock(id: $id, name: $name, input: $input, '
      'cacheControl: $cacheControl)';
}

/// Content type for tool results.
sealed class ToolResultContent {
  const ToolResultContent();

  /// Creates a text result.
  factory ToolResultContent.text(String text) = ToolResultTextContent;

  /// Creates an image result.
  factory ToolResultContent.image(ImageSource source) = ToolResultImageContent;

  /// Creates a [ToolResultContent] from JSON.
  factory ToolResultContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => ToolResultTextContent.fromJson(json),
      'image' => ToolResultImageContent.fromJson(json),
      _ => throw FormatException('Unknown ToolResultContent type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text content for tool results.
@immutable
class ToolResultTextContent extends ToolResultContent {
  /// The text content.
  final String text;

  /// Creates a [ToolResultTextContent].
  const ToolResultTextContent(this.text);

  /// Creates a [ToolResultTextContent] from JSON.
  factory ToolResultTextContent.fromJson(Map<String, dynamic> json) {
    return ToolResultTextContent(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolResultTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ToolResultTextContent(text: [${text.length} chars])';
}

/// Image content for tool results.
@immutable
class ToolResultImageContent extends ToolResultContent {
  /// The image source.
  final ImageSource source;

  /// Creates a [ToolResultImageContent].
  const ToolResultImageContent(this.source);

  /// Creates a [ToolResultImageContent] from JSON.
  factory ToolResultImageContent.fromJson(Map<String, dynamic> json) {
    return ToolResultImageContent(
      ImageSource.fromJson(json['source'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'image', 'source': source.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolResultImageContent &&
          runtimeType == other.runtimeType &&
          source == other.source;

  @override
  int get hashCode => source.hashCode;

  @override
  String toString() => 'ToolResultImageContent(source: $source)';
}

/// Tool result block for user messages.
@immutable
class ToolResultInputBlock extends InputContentBlock {
  /// The ID of the tool use this result is for.
  final String toolUseId;

  /// The result content (can be text, images, or mixed).
  final List<ToolResultContent>? content;

  /// Whether this result represents an error.
  final bool? isError;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ToolResultInputBlock].
  const ToolResultInputBlock({
    required this.toolUseId,
    this.content,
    this.isError,
    this.cacheControl,
  });

  /// Creates a [ToolResultInputBlock] from JSON.
  factory ToolResultInputBlock.fromJson(Map<String, dynamic> json) {
    return ToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => ToolResultContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      isError: json['is_error'] as bool?,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_result',
    'tool_use_id': toolUseId,
    if (content != null) 'content': content!.map((e) => e.toJson()).toList(),
    if (isError != null) 'is_error': isError,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolResultInputBlock copyWith({
    String? toolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<ToolResultContent>?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          _listsEqual(content, other.content) &&
          isError == other.isError &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, content, isError, cacheControl);

  @override
  String toString() =>
      'ToolResultInputBlock(toolUseId: $toolUseId, content: $content, '
      'isError: $isError, cacheControl: $cacheControl)';
}

bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapsEqual<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
