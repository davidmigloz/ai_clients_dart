import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/cache_control.dart';
import '../sources/document_source.dart';
import '../sources/image_source.dart';
import '../tools/tool_caller.dart';
import 'content_block.dart';

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

  /// Creates a tool result block with a single text result.
  factory InputContentBlock.toolResultText({
    required String toolUseId,
    required String text,
    bool? isError,
    CacheControlEphemeral? cacheControl,
  }) = ToolResultInputBlock.text;

  /// Creates a server tool use block (for assistant messages).
  factory InputContentBlock.serverToolUse({
    required String id,
    required String name,
    required Map<String, dynamic> input,
    ToolCaller? caller,
    CacheControlEphemeral? cacheControl,
  }) = ServerToolUseInputBlock;

  /// Creates a web search tool result block.
  factory InputContentBlock.webSearchToolResult({
    required String toolUseId,
    required WebSearchResult content,
    ToolCaller? caller,
    CacheControlEphemeral? cacheControl,
  }) = WebSearchToolResultInputBlock;

  /// Creates a web fetch tool result block.
  factory InputContentBlock.webFetchToolResult({
    required String toolUseId,
    required Map<String, dynamic> content,
    ToolCaller? caller,
    CacheControlEphemeral? cacheControl,
  }) = WebFetchToolResultInputBlock;

  /// Creates a container upload block.
  factory InputContentBlock.containerUpload({
    required String fileId,
    CacheControlEphemeral? cacheControl,
  }) = ContainerUploadInputBlock;

  /// Creates a compaction block.
  factory InputContentBlock.compaction({
    required String? content,
    CacheControlEphemeral? cacheControl,
  }) = CompactionInputBlock;

  /// Creates an advisor tool result block (for multi-turn conversations).
  factory InputContentBlock.advisorToolResult({
    required String toolUseId,
    required AdvisorToolResultContent content,
    CacheControlEphemeral? cacheControl,
  }) = AdvisorToolResultInputBlock;

  /// Creates a tool reference block.
  factory InputContentBlock.toolReference({
    required String toolName,
    CacheControlEphemeral? cacheControl,
  }) = ToolReferenceInputBlock;

  /// Creates an [InputContentBlock] from JSON.
  factory InputContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => TextInputBlock.fromJson(json),
      'image' => ImageInputBlock.fromJson(json),
      'document' => DocumentInputBlock.fromJson(json),
      'tool_use' => ToolUseInputBlock.fromJson(json),
      'tool_result' => ToolResultInputBlock.fromJson(json),
      'server_tool_use' => ServerToolUseInputBlock.fromJson(json),
      'web_search_tool_result' => WebSearchToolResultInputBlock.fromJson(json),
      'web_fetch_tool_result' => WebFetchToolResultInputBlock.fromJson(json),
      'code_execution_tool_result' =>
        CodeExecutionToolResultInputBlock.fromJson(json),
      'bash_code_execution_tool_result' =>
        BashCodeExecutionToolResultInputBlock.fromJson(json),
      'text_editor_code_execution_tool_result' =>
        TextEditorCodeExecutionToolResultInputBlock.fromJson(json),
      'tool_search_tool_result' => ToolSearchToolResultInputBlock.fromJson(
        json,
      ),
      'container_upload' => ContainerUploadInputBlock.fromJson(json),
      'compaction' => CompactionInputBlock.fromJson(json),
      'tool_reference' => ToolReferenceInputBlock.fromJson(json),
      'advisor_tool_result' => AdvisorToolResultInputBlock.fromJson(json),
      _ => UnknownInputContentBlock.fromJson(json),
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

  /// Caller metadata for this tool invocation.
  final ToolCaller? caller;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ToolUseInputBlock].
  const ToolUseInputBlock({
    required this.id,
    required this.name,
    required this.input,
    this.caller,
    this.cacheControl,
  });

  /// Creates a [ToolUseInputBlock] from JSON.
  factory ToolUseInputBlock.fromJson(Map<String, dynamic> json) {
    return ToolUseInputBlock(
      id: json['id'] as String,
      name: json['name'] as String,
      input: json['input'] as Map<String, dynamic>,
      caller: json['caller'] != null
          ? ToolCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
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
    if (caller != null) 'caller': caller!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolUseInputBlock copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? input,
    Object? caller = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ToolUseInputBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      input: input ?? this.input,
      caller: caller == unsetCopyWithValue
          ? this.caller
          : caller as ToolCaller?,
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
          mapsEqual(input, other.input) &&
          caller == other.caller &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(id, name, mapHash(input), caller, cacheControl);

  @override
  String toString() =>
      'ToolUseInputBlock(id: $id, name: $name, input: $input, '
      'caller: $caller, cacheControl: $cacheControl)';
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

  /// Creates a [ToolResultInputBlock] with a single text result.
  factory ToolResultInputBlock.text({
    required String toolUseId,
    required String text,
    bool? isError,
    CacheControlEphemeral? cacheControl,
  }) {
    return ToolResultInputBlock(
      toolUseId: toolUseId,
      content: [ToolResultContent.text(text)],
      isError: isError,
      cacheControl: cacheControl,
    );
  }

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
          listsEqual(content, other.content) &&
          isError == other.isError &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(toolUseId, listHash(content), isError, cacheControl);

  @override
  String toString() =>
      'ToolResultInputBlock(toolUseId: $toolUseId, content: $content, '
      'isError: $isError, cacheControl: $cacheControl)';
}

/// Server tool use block for assistant messages in input.
@immutable
class ServerToolUseInputBlock extends InputContentBlock {
  /// Unique identifier for this tool use.
  final String id;

  /// Name of the server tool.
  final String name;

  /// Input parameters for the tool.
  final Map<String, dynamic> input;

  /// Caller metadata.
  final ToolCaller? caller;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ServerToolUseInputBlock].
  const ServerToolUseInputBlock({
    required this.id,
    required this.name,
    required this.input,
    this.caller,
    this.cacheControl,
  });

  /// Creates a [ServerToolUseInputBlock] from JSON.
  factory ServerToolUseInputBlock.fromJson(Map<String, dynamic> json) {
    return ServerToolUseInputBlock(
      id: json['id'] as String,
      name: json['name'] as String,
      input: (json['input'] as Map).cast<String, dynamic>(),
      caller: json['caller'] != null
          ? ToolCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'server_tool_use',
    'id': id,
    'name': name,
    'input': input,
    if (caller != null) 'caller': caller!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ServerToolUseInputBlock copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? input,
    Object? caller = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ServerToolUseInputBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      input: input ?? this.input,
      caller: caller == unsetCopyWithValue
          ? this.caller
          : caller as ToolCaller?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerToolUseInputBlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mapsEqual(input, other.input) &&
          caller == other.caller &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(id, name, mapHash(input), caller, cacheControl);

  @override
  String toString() =>
      'ServerToolUseInputBlock(id: $id, name: $name, input: $input, '
      'caller: $caller, cacheControl: $cacheControl)';
}

/// Web search tool result block in input.
@immutable
class WebSearchToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The search results content.
  final WebSearchResult content;

  /// Caller metadata.
  final ToolCaller? caller;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [WebSearchToolResultInputBlock].
  const WebSearchToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.caller,
    this.cacheControl,
  });

  /// Creates a [WebSearchToolResultInputBlock] from JSON.
  factory WebSearchToolResultInputBlock.fromJson(Map<String, dynamic> json) {
    return WebSearchToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: WebSearchResult.fromJson(json['content'] as Object),
      caller: json['caller'] != null
          ? ToolCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_tool_result',
    'tool_use_id': toolUseId,
    'content': content.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  WebSearchToolResultInputBlock copyWith({
    String? toolUseId,
    WebSearchResult? content,
    Object? caller = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return WebSearchToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      caller: caller == unsetCopyWithValue
          ? this.caller
          : caller as ToolCaller?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          content == other.content &&
          caller == other.caller &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, content, caller, cacheControl);

  @override
  String toString() =>
      'WebSearchToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, caller: $caller, cacheControl: $cacheControl)';
}

/// Web fetch tool result block in input.
@immutable
class WebFetchToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The result content payload.
  final Map<String, dynamic> content;

  /// Caller metadata.
  final ToolCaller? caller;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [WebFetchToolResultInputBlock].
  const WebFetchToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.caller,
    this.cacheControl,
  });

  /// Creates a [WebFetchToolResultInputBlock] from JSON.
  factory WebFetchToolResultInputBlock.fromJson(Map<String, dynamic> json) {
    return WebFetchToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as Map).cast<String, dynamic>(),
      caller: json['caller'] != null
          ? ToolCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_fetch_tool_result',
    'tool_use_id': toolUseId,
    'content': content,
    if (caller != null) 'caller': caller!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  WebFetchToolResultInputBlock copyWith({
    String? toolUseId,
    Map<String, dynamic>? content,
    Object? caller = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return WebFetchToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      caller: caller == unsetCopyWithValue
          ? this.caller
          : caller as ToolCaller?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          mapsEqual(content, other.content) &&
          caller == other.caller &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(toolUseId, mapHash(content), caller, cacheControl);

  @override
  String toString() =>
      'WebFetchToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, caller: $caller, cacheControl: $cacheControl)';
}

/// Code execution tool result block in input.
@immutable
class CodeExecutionToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The result content payload.
  final Map<String, dynamic> content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [CodeExecutionToolResultInputBlock].
  const CodeExecutionToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.cacheControl,
  });

  /// Creates a [CodeExecutionToolResultInputBlock] from JSON.
  factory CodeExecutionToolResultInputBlock.fromJson(
    Map<String, dynamic> json,
  ) {
    return CodeExecutionToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as Map).cast<String, dynamic>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'code_execution_tool_result',
    'tool_use_id': toolUseId,
    'content': content,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  CodeExecutionToolResultInputBlock copyWith({
    String? toolUseId,
    Map<String, dynamic>? content,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return CodeExecutionToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeExecutionToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          mapsEqual(content, other.content) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, mapHash(content), cacheControl);

  @override
  String toString() =>
      'CodeExecutionToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, cacheControl: $cacheControl)';
}

/// Bash code execution tool result block in input.
@immutable
class BashCodeExecutionToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The result content payload.
  final Map<String, dynamic> content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [BashCodeExecutionToolResultInputBlock].
  const BashCodeExecutionToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.cacheControl,
  });

  /// Creates a [BashCodeExecutionToolResultInputBlock] from JSON.
  factory BashCodeExecutionToolResultInputBlock.fromJson(
    Map<String, dynamic> json,
  ) {
    return BashCodeExecutionToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as Map).cast<String, dynamic>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'bash_code_execution_tool_result',
    'tool_use_id': toolUseId,
    'content': content,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  BashCodeExecutionToolResultInputBlock copyWith({
    String? toolUseId,
    Map<String, dynamic>? content,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return BashCodeExecutionToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BashCodeExecutionToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          mapsEqual(content, other.content) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, mapHash(content), cacheControl);

  @override
  String toString() =>
      'BashCodeExecutionToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, cacheControl: $cacheControl)';
}

/// Text-editor code execution tool result block in input.
@immutable
class TextEditorCodeExecutionToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The result content payload.
  final Map<String, dynamic> content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [TextEditorCodeExecutionToolResultInputBlock].
  const TextEditorCodeExecutionToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.cacheControl,
  });

  /// Creates a [TextEditorCodeExecutionToolResultInputBlock] from JSON.
  factory TextEditorCodeExecutionToolResultInputBlock.fromJson(
    Map<String, dynamic> json,
  ) {
    return TextEditorCodeExecutionToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as Map).cast<String, dynamic>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text_editor_code_execution_tool_result',
    'tool_use_id': toolUseId,
    'content': content,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  TextEditorCodeExecutionToolResultInputBlock copyWith({
    String? toolUseId,
    Map<String, dynamic>? content,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return TextEditorCodeExecutionToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorCodeExecutionToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          mapsEqual(content, other.content) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, mapHash(content), cacheControl);

  @override
  String toString() =>
      'TextEditorCodeExecutionToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, cacheControl: $cacheControl)';
}

/// Tool-search tool result block in input.
@immutable
class ToolSearchToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The result content payload.
  final Map<String, dynamic> content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ToolSearchToolResultInputBlock].
  const ToolSearchToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.cacheControl,
  });

  /// Creates a [ToolSearchToolResultInputBlock] from JSON.
  factory ToolSearchToolResultInputBlock.fromJson(Map<String, dynamic> json) {
    return ToolSearchToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as Map).cast<String, dynamic>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search_tool_result',
    'tool_use_id': toolUseId,
    'content': content,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolSearchToolResultInputBlock copyWith({
    String? toolUseId,
    Map<String, dynamic>? content,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ToolSearchToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          mapsEqual(content, other.content) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, mapHash(content), cacheControl);

  @override
  String toString() =>
      'ToolSearchToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, cacheControl: $cacheControl)';
}

/// Container upload block in input.
@immutable
class ContainerUploadInputBlock extends InputContentBlock {
  /// Uploaded file id.
  final String fileId;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ContainerUploadInputBlock].
  const ContainerUploadInputBlock({required this.fileId, this.cacheControl});

  /// Creates a [ContainerUploadInputBlock] from JSON.
  factory ContainerUploadInputBlock.fromJson(Map<String, dynamic> json) {
    return ContainerUploadInputBlock(
      fileId: json['file_id'] as String,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'container_upload',
    'file_id': fileId,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ContainerUploadInputBlock copyWith({
    String? fileId,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ContainerUploadInputBlock(
      fileId: fileId ?? this.fileId,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerUploadInputBlock &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(fileId, cacheControl);

  @override
  String toString() =>
      'ContainerUploadInputBlock(fileId: $fileId, '
      'cacheControl: $cacheControl)';
}

/// Compaction block in input (beta).
///
/// Round-trip this block from response to request to preserve compacted
/// context across compaction boundaries.
@immutable
class CompactionInputBlock extends InputContentBlock {
  /// Compaction summary content.
  ///
  /// When `null`, represents a failed compaction and is treated as a no-op.
  final String? content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [CompactionInputBlock].
  const CompactionInputBlock({required this.content, this.cacheControl});

  /// Creates a [CompactionInputBlock] from JSON.
  factory CompactionInputBlock.fromJson(Map<String, dynamic> json) {
    return CompactionInputBlock(
      content: json['content'] as String?,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction',
    'content': content,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  CompactionInputBlock copyWith({
    Object? content = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return CompactionInputBlock(
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionInputBlock &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(content, cacheControl);

  @override
  String toString() =>
      'CompactionInputBlock(content: $content, cacheControl: $cacheControl)';
}

/// Tool reference block in input.
@immutable
class ToolReferenceInputBlock extends InputContentBlock {
  /// Referenced tool name.
  final String toolName;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ToolReferenceInputBlock].
  const ToolReferenceInputBlock({required this.toolName, this.cacheControl});

  /// Creates a [ToolReferenceInputBlock] from JSON.
  factory ToolReferenceInputBlock.fromJson(Map<String, dynamic> json) {
    return ToolReferenceInputBlock(
      toolName: json['tool_name'] as String,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_reference',
    'tool_name': toolName,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolReferenceInputBlock copyWith({
    String? toolName,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ToolReferenceInputBlock(
      toolName: toolName ?? this.toolName,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolReferenceInputBlock &&
          runtimeType == other.runtimeType &&
          toolName == other.toolName &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolName, cacheControl);

  @override
  String toString() =>
      'ToolReferenceInputBlock(toolName: $toolName, '
      'cacheControl: $cacheControl)';
}

/// Advisor tool result block in input (for multi-turn conversations).
///
/// Pass advisor tool result blocks verbatim from the assistant's response
/// back to the API on subsequent turns.
@immutable
class AdvisorToolResultInputBlock extends InputContentBlock {
  /// The ID of the related tool use.
  final String toolUseId;

  /// The advisor's response content.
  final AdvisorToolResultContent content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates an [AdvisorToolResultInputBlock].
  const AdvisorToolResultInputBlock({
    required this.toolUseId,
    required this.content,
    this.cacheControl,
  });

  /// Creates an [AdvisorToolResultInputBlock] from JSON.
  factory AdvisorToolResultInputBlock.fromJson(Map<String, dynamic> json) {
    return AdvisorToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: AdvisorToolResultContent.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'advisor_tool_result',
    'tool_use_id': toolUseId,
    'content': content.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  AdvisorToolResultInputBlock copyWith({
    String? toolUseId,
    AdvisorToolResultContent? content,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return AdvisorToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content ?? this.content,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          content == other.content &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, content, cacheControl);

  @override
  String toString() =>
      'AdvisorToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, cacheControl: $cacheControl)';
}

/// Forward-compatible fallback for unknown input content block types.
///
/// Preserves the raw JSON so unrecognized blocks from assistant responses
/// can be round-tripped back to the API without data loss.
@immutable
class UnknownInputContentBlock extends InputContentBlock {
  /// The raw JSON for this unknown input content block.
  final Map<String, dynamic> raw;

  /// Creates an [UnknownInputContentBlock].
  UnknownInputContentBlock({required Map<String, dynamic> raw})
    : raw = Map.unmodifiable(raw);

  /// Creates an [UnknownInputContentBlock] from JSON.
  factory UnknownInputContentBlock.fromJson(Map<String, dynamic> json) {
    return UnknownInputContentBlock(raw: json);
  }

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownInputContentBlock &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);

  @override
  String toString() => 'UnknownInputContentBlock(raw: ${raw.length} entries)';
}
