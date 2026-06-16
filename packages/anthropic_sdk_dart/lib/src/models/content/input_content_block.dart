import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../messages/fallback_config.dart';
import '../metadata/cache_control.dart';
import '../sources/document_source.dart';
import '../sources/image_source.dart';
import '../tools/tool_caller.dart';
import 'citations_config.dart';
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
    String? context,
    RequestCitationsConfig? citations,
    CacheControlEphemeral? cacheControl,
  }) = DocumentInputBlock;

  /// Creates a search result content block.
  ///
  /// Supply your own cited search results (e.g. from a custom retrieval/RAG
  /// system) so the model can reference them and return `search_result_location`
  /// citations. Set [citations] to `RequestCitationsConfig(enabled: true)` to
  /// allow the model to cite this result.
  factory InputContentBlock.searchResult({
    required List<TextInputBlock> content,
    required String source,
    required String title,
    RequestCitationsConfig? citations,
    CacheControlEphemeral? cacheControl,
  }) = SearchResultInputBlock;

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

  /// Creates an MCP tool use block (for assistant messages).
  factory InputContentBlock.mcpToolUse({
    required String id,
    required String name,
    required String serverName,
    required Map<String, dynamic> input,
    CacheControlEphemeral? cacheControl,
  }) = MCPToolUseInputBlock;

  /// Creates an MCP tool result block (for user messages).
  factory InputContentBlock.mcpToolResult({
    required String toolUseId,
    MCPToolResultContent? content,
    bool? isError,
    CacheControlEphemeral? cacheControl,
  }) = MCPToolResultInputBlock;

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

  /// Creates a mid-conversation system block.
  ///
  /// Injects updated system instructions partway through a conversation (e.g.
  /// with Claude Opus 4.8) without requiring a user turn or disrupting prompt
  /// caching. The [content] holds the new system instruction as text blocks.
  factory InputContentBlock.midConversationSystem({
    required List<TextInputBlock> content,
    CacheControlEphemeral? cacheControl,
  }) = MidConversationSystemInputBlock;

  /// Creates a fallback block echoed back from a prior response.
  ///
  /// Callers should echo the assistant turn verbatim, including this block — its
  /// position is load-bearing for thinking verification across a fallback hop.
  factory InputContentBlock.fallback({
    required FallbackHopInfo from,
    required FallbackHopInfo to,
  }) = FallbackInputBlock;

  /// Creates an [InputContentBlock] from JSON.
  factory InputContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => TextInputBlock.fromJson(json),
      'image' => ImageInputBlock.fromJson(json),
      'document' => DocumentInputBlock.fromJson(json),
      'search_result' => SearchResultInputBlock.fromJson(json),
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
      'mcp_tool_use' => MCPToolUseInputBlock.fromJson(json),
      'mcp_tool_result' => MCPToolResultInputBlock.fromJson(json),
      'advisor_tool_result' => AdvisorToolResultInputBlock.fromJson(json),
      'mid_conv_system' => MidConversationSystemInputBlock.fromJson(json),
      'fallback' => FallbackInputBlock.fromJson(json),
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

  /// Citations attached to this text.
  ///
  /// Tells the model where spans of [text] were sourced from (e.g. when this
  /// block is part of a [SearchResultInputBlock]'s content), so it can cite
  /// them back in its response.
  final List<InputCitation>? citations;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [TextInputBlock].
  const TextInputBlock(this.text, {this.citations, this.cacheControl});

  /// Creates a [TextInputBlock] from JSON.
  factory TextInputBlock.fromJson(Map<String, dynamic> json) {
    return TextInputBlock(
      json['text'] as String,
      citations: (json['citations'] as List?)
          ?.map((e) => InputCitation.fromJson(e as Map<String, dynamic>))
          .toList(),
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
    if (citations != null)
      'citations': citations!.map((e) => e.toJson()).toList(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  TextInputBlock copyWith({
    String? text,
    Object? citations = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return TextInputBlock(
      text ?? this.text,
      citations: citations == unsetCopyWithValue
          ? this.citations
          : citations as List<InputCitation>?,
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
          listsEqual(citations, other.citations) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(text, listHash(citations), cacheControl);

  @override
  String toString() =>
      'TextInputBlock(text: [${text.length} chars], citations: $citations, '
      'cacheControl: $cacheControl)';
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

  /// Optional context about the document, passed to the model but not used for
  /// citations.
  final String? context;

  /// Citations configuration for this document.
  ///
  /// Set to `RequestCitationsConfig(enabled: true)` to let the model cite this
  /// document in its response.
  final RequestCitationsConfig? citations;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [DocumentInputBlock].
  const DocumentInputBlock(
    this.source, {
    this.title,
    this.context,
    this.citations,
    this.cacheControl,
  });

  /// Creates a [DocumentInputBlock] from JSON.
  factory DocumentInputBlock.fromJson(Map<String, dynamic> json) {
    return DocumentInputBlock(
      DocumentSource.fromJson(json['source'] as Map<String, dynamic>),
      title: json['title'] as String?,
      context: json['context'] as String?,
      citations: json['citations'] != null
          ? RequestCitationsConfig.fromJson(
              json['citations'] as Map<String, dynamic>,
            )
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
    'type': 'document',
    'source': source.toJson(),
    if (title != null) 'title': title,
    if (context != null) 'context': context,
    if (citations != null) 'citations': citations!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  DocumentInputBlock copyWith({
    DocumentSource? source,
    Object? title = unsetCopyWithValue,
    Object? context = unsetCopyWithValue,
    Object? citations = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return DocumentInputBlock(
      source ?? this.source,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      context: context == unsetCopyWithValue
          ? this.context
          : context as String?,
      citations: citations == unsetCopyWithValue
          ? this.citations
          : citations as RequestCitationsConfig?,
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
          context == other.context &&
          citations == other.citations &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(source, title, context, citations, cacheControl);

  @override
  String toString() =>
      'DocumentInputBlock(source: $source, title: $title, '
      'context: $context, citations: $citations, cacheControl: $cacheControl)';
}

/// Search result content block for input.
///
/// Lets you supply your own cited search results (e.g. from a custom
/// retrieval/RAG system) so the model can reference them and return
/// `search_result_location` citations. The [content] is the searchable text,
/// split into citable [TextInputBlock]s.
@immutable
class SearchResultInputBlock extends InputContentBlock {
  /// The searchable content of this result, as citable text blocks.
  final List<TextInputBlock> content;

  /// Source identifier for this result (e.g. a URL or document id).
  final String source;

  /// Display title for this result.
  final String title;

  /// Citations configuration for this result.
  ///
  /// Set to `RequestCitationsConfig(enabled: true)` to let the model cite this
  /// result in its response.
  final RequestCitationsConfig? citations;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [SearchResultInputBlock].
  const SearchResultInputBlock({
    required this.content,
    required this.source,
    required this.title,
    this.citations,
    this.cacheControl,
  });

  /// Creates a [SearchResultInputBlock] from JSON.
  factory SearchResultInputBlock.fromJson(Map<String, dynamic> json) {
    return SearchResultInputBlock(
      content: (json['content'] as List)
          .map((e) => TextInputBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      source: json['source'] as String,
      title: json['title'] as String,
      citations: json['citations'] != null
          ? RequestCitationsConfig.fromJson(
              json['citations'] as Map<String, dynamic>,
            )
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
    'type': 'search_result',
    'content': content.map((e) => e.toJson()).toList(),
    'source': source,
    'title': title,
    if (citations != null) 'citations': citations!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  SearchResultInputBlock copyWith({
    List<TextInputBlock>? content,
    String? source,
    String? title,
    Object? citations = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return SearchResultInputBlock(
      content: content ?? this.content,
      source: source ?? this.source,
      title: title ?? this.title,
      citations: citations == unsetCopyWithValue
          ? this.citations
          : citations as RequestCitationsConfig?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultInputBlock &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content) &&
          source == other.source &&
          title == other.title &&
          citations == other.citations &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(listHash(content), source, title, citations, cacheControl);

  @override
  String toString() =>
      'SearchResultInputBlock(content: $content, source: $source, '
      'title: $title, citations: $citations, cacheControl: $cacheControl)';
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

  /// Encrypted compaction payload for server-side context restoration.
  final String? encryptedContent;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [CompactionInputBlock].
  const CompactionInputBlock({
    required this.content,
    this.encryptedContent,
    this.cacheControl,
  });

  /// Creates a [CompactionInputBlock] from JSON.
  factory CompactionInputBlock.fromJson(Map<String, dynamic> json) {
    return CompactionInputBlock(
      content: json['content'] as String?,
      encryptedContent: json['encrypted_content'] as String?,
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
    if (encryptedContent != null) 'encrypted_content': encryptedContent,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  CompactionInputBlock copyWith({
    Object? content = unsetCopyWithValue,
    Object? encryptedContent = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return CompactionInputBlock(
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      encryptedContent: encryptedContent == unsetCopyWithValue
          ? this.encryptedContent
          : encryptedContent as String?,
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
          encryptedContent == other.encryptedContent &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(content, encryptedContent, cacheControl);

  @override
  String toString() =>
      'CompactionInputBlock(content: $content, '
      'encryptedContent: ${encryptedContent == null ? 'null' : '[${encryptedContent!.length} chars]'}, '
      'cacheControl: $cacheControl)';
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

/// A `fallback` block echoed back from a prior response.
///
/// Accepted in `messages[].content` and never rendered into the prompt. Callers
/// should echo the assistant turn verbatim, block included — its position is
/// load-bearing for thinking verification across a fallback hop.
@immutable
class FallbackInputBlock extends InputContentBlock {
  /// The model whose output ends at this point — the model that declined at
  /// this hop.
  final FallbackHopInfo from;

  /// The fallback model producing the content that follows this block.
  final FallbackHopInfo to;

  /// Creates a [FallbackInputBlock].
  const FallbackInputBlock({required this.from, required this.to});

  /// Object type. Always "fallback".
  String get type => 'fallback';

  /// Creates a [FallbackInputBlock] from JSON.
  factory FallbackInputBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'fallback') {
      throw FormatException(
        'FallbackInputBlock: expected type "fallback", got "$type"',
      );
    }
    return FallbackInputBlock(
      from: FallbackHopInfo.fromJson(json['from'] as Map<String, dynamic>),
      to: FallbackHopInfo.fromJson(json['to'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'from': from.toJson(),
    'to': to.toJson(),
  };

  /// Creates a copy with replaced values.
  FallbackInputBlock copyWith({FallbackHopInfo? from, FallbackHopInfo? to}) {
    return FallbackInputBlock(from: from ?? this.from, to: to ?? this.to);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FallbackInputBlock &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'FallbackInputBlock(from: $from, to: $to)';
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

/// MCP tool use block for assistant messages in input.
///
/// Used when round-tripping an assistant message containing an MCP tool call.
@immutable
class MCPToolUseInputBlock extends InputContentBlock {
  /// Unique identifier for this tool use.
  final String id;

  /// Name of the MCP tool being used.
  final String name;

  /// Name of the MCP server providing the tool.
  final String serverName;

  /// Input parameters for the tool.
  final Map<String, dynamic> input;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates an [MCPToolUseInputBlock].
  const MCPToolUseInputBlock({
    required this.id,
    required this.name,
    required this.serverName,
    required this.input,
    this.cacheControl,
  });

  /// Creates an [MCPToolUseInputBlock] from JSON.
  factory MCPToolUseInputBlock.fromJson(Map<String, dynamic> json) {
    return MCPToolUseInputBlock(
      id: json['id'] as String,
      name: json['name'] as String,
      serverName: json['server_name'] as String,
      input: (json['input'] as Map).cast<String, dynamic>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_tool_use',
    'id': id,
    'name': name,
    'server_name': serverName,
    'input': input,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  MCPToolUseInputBlock copyWith({
    String? id,
    String? name,
    String? serverName,
    Map<String, dynamic>? input,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return MCPToolUseInputBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      serverName: serverName ?? this.serverName,
      input: input ?? this.input,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolUseInputBlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          serverName == other.serverName &&
          mapsEqual(input, other.input) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(id, name, serverName, mapHash(input), cacheControl);

  @override
  String toString() =>
      'MCPToolUseInputBlock(id: $id, name: $name, '
      'serverName: $serverName, input: $input, '
      'cacheControl: $cacheControl)';
}

/// MCP tool result block for input messages.
///
/// Used when round-tripping a user message containing an MCP tool result.
@immutable
class MCPToolResultInputBlock extends InputContentBlock {
  /// The ID of the tool use this result corresponds to.
  final String toolUseId;

  /// The content of the tool result.
  final MCPToolResultContent? content;

  /// Whether this result represents an error.
  final bool? isError;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates an [MCPToolResultInputBlock].
  const MCPToolResultInputBlock({
    required this.toolUseId,
    this.content,
    this.isError,
    this.cacheControl,
  });

  /// Creates an [MCPToolResultInputBlock] from JSON.
  factory MCPToolResultInputBlock.fromJson(Map<String, dynamic> json) {
    return MCPToolResultInputBlock(
      toolUseId: json['tool_use_id'] as String,
      content: json['content'] != null
          ? MCPToolResultContent.fromJson(json['content'] as Object)
          : null,
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
    'type': 'mcp_tool_result',
    'tool_use_id': toolUseId,
    if (content != null) 'content': content!.toJson(),
    if (isError != null) 'is_error': isError,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  MCPToolResultInputBlock copyWith({
    String? toolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return MCPToolResultInputBlock(
      toolUseId: toolUseId ?? this.toolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as MCPToolResultContent?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolResultInputBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          content == other.content &&
          isError == other.isError &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(toolUseId, content, isError, cacheControl);

  @override
  String toString() =>
      'MCPToolResultInputBlock(toolUseId: $toolUseId, '
      'content: $content, isError: $isError, '
      'cacheControl: $cacheControl)';
}

/// Mid-conversation system content block for input.
///
/// Injects updated system instructions partway through a conversation (e.g.
/// with Claude Opus 4.8) without requiring a user turn or disrupting prompt
/// caching. The [content] holds the new system instruction as text blocks.
@immutable
class MidConversationSystemInputBlock extends InputContentBlock {
  /// System instruction text blocks.
  final List<TextInputBlock> content;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [MidConversationSystemInputBlock].
  const MidConversationSystemInputBlock({
    required this.content,
    this.cacheControl,
  });

  /// Creates a [MidConversationSystemInputBlock] from JSON.
  factory MidConversationSystemInputBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'mid_conv_system') {
      throw FormatException('Expected type "mid_conv_system", got "$type"');
    }
    final rawContent = json['content'];
    if (rawContent is! List) {
      throw FormatException(
        'mid_conv_system: "content" must be a List, '
        'got ${rawContent.runtimeType}',
      );
    }
    return MidConversationSystemInputBlock(
      content: rawContent.map((e) {
        if (e is! Map<String, dynamic>) {
          throw FormatException(
            'mid_conv_system content: expected Map, got ${e.runtimeType}',
          );
        }
        return TextInputBlock.fromJson(e);
      }).toList(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mid_conv_system',
    'content': content.map((e) => e.toJson()).toList(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  MidConversationSystemInputBlock copyWith({
    List<TextInputBlock>? content,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return MidConversationSystemInputBlock(
      content: content ?? this.content,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidConversationSystemInputBlock &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content) &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(listHash(content), cacheControl);

  @override
  String toString() =>
      'MidConversationSystemInputBlock(content: $content, '
      'cacheControl: $cacheControl)';
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

// ============================================================================
// Request Citations (per-citation location types)
// ============================================================================

/// A citation supplied on a request [TextInputBlock] (e.g. inside a
/// [SearchResultInputBlock]'s content) that tells the model where a span of
/// text was sourced from, so the model can cite it back in its response.
///
/// This is the request-side counterpart to the response-side `Citation` family.
/// Note the serialization difference: the spec marks the nullable
/// `title` / `document_title` keys as **required**, so they are always emitted
/// (as `null` when absent), unlike their response-side equivalents.
///
/// Dispatches on the `type` discriminator; unrecognized values fall back to
/// [UnknownInputCitation].
///
/// Subtypes:
/// - [CharLocationInputCitation] (`char_location`)
/// - [PageLocationInputCitation] (`page_location`)
/// - [ContentBlockLocationInputCitation] (`content_block_location`)
/// - [WebSearchResultLocationInputCitation] (`web_search_result_location`)
/// - [SearchResultLocationInputCitation] (`search_result_location`)
/// - [UnknownInputCitation] (forward-compatible fallback)
sealed class InputCitation {
  const InputCitation();

  /// Creates an [InputCitation] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownInputCitation].
  factory InputCitation.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'char_location' => CharLocationInputCitation.fromJson(json),
      'page_location' => PageLocationInputCitation.fromJson(json),
      'content_block_location' => ContentBlockLocationInputCitation.fromJson(
        json,
      ),
      'web_search_result_location' =>
        WebSearchResultLocationInputCitation.fromJson(json),
      'search_result_location' => SearchResultLocationInputCitation.fromJson(
        json,
      ),
      _ => UnknownInputCitation(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Request citation with character location (for plain text document sources).
@immutable
class CharLocationInputCitation extends InputCitation {
  /// The cited text.
  final String citedText;

  /// The document index.
  final int documentIndex;

  /// The document title (may be `null`; the key is always sent).
  final String? documentTitle;

  /// Start character offset.
  final int startCharIndex;

  /// End character offset.
  final int endCharIndex;

  /// Creates a [CharLocationInputCitation].
  const CharLocationInputCitation({
    required this.citedText,
    required this.documentIndex,
    required this.documentTitle,
    required this.startCharIndex,
    required this.endCharIndex,
  });

  /// Creates a [CharLocationInputCitation] from JSON.
  factory CharLocationInputCitation.fromJson(Map<String, dynamic> json) {
    return CharLocationInputCitation(
      citedText: json['cited_text'] as String,
      documentIndex: json['document_index'] as int,
      documentTitle: json['document_title'] as String?,
      startCharIndex: json['start_char_index'] as int,
      endCharIndex: json['end_char_index'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'char_location',
    'cited_text': citedText,
    'document_index': documentIndex,
    'document_title': documentTitle,
    'start_char_index': startCharIndex,
    'end_char_index': endCharIndex,
  };

  /// Creates a copy with replaced values.
  CharLocationInputCitation copyWith({
    String? citedText,
    int? documentIndex,
    Object? documentTitle = unsetCopyWithValue,
    int? startCharIndex,
    int? endCharIndex,
  }) {
    return CharLocationInputCitation(
      citedText: citedText ?? this.citedText,
      documentIndex: documentIndex ?? this.documentIndex,
      documentTitle: documentTitle == unsetCopyWithValue
          ? this.documentTitle
          : documentTitle as String?,
      startCharIndex: startCharIndex ?? this.startCharIndex,
      endCharIndex: endCharIndex ?? this.endCharIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharLocationInputCitation &&
          runtimeType == other.runtimeType &&
          citedText == other.citedText &&
          documentIndex == other.documentIndex &&
          documentTitle == other.documentTitle &&
          startCharIndex == other.startCharIndex &&
          endCharIndex == other.endCharIndex;

  @override
  int get hashCode => Object.hash(
    citedText,
    documentIndex,
    documentTitle,
    startCharIndex,
    endCharIndex,
  );

  @override
  String toString() =>
      'CharLocationInputCitation(citedText: [${citedText.length} chars], '
      'documentIndex: $documentIndex, documentTitle: $documentTitle, '
      'startCharIndex: $startCharIndex, endCharIndex: $endCharIndex)';
}

/// Request citation with page location (for PDF document sources).
@immutable
class PageLocationInputCitation extends InputCitation {
  /// The cited text.
  final String citedText;

  /// The document index.
  final int documentIndex;

  /// The document title (may be `null`; the key is always sent).
  final String? documentTitle;

  /// Start page number.
  final int startPageNumber;

  /// End page number.
  final int endPageNumber;

  /// Creates a [PageLocationInputCitation].
  const PageLocationInputCitation({
    required this.citedText,
    required this.documentIndex,
    required this.documentTitle,
    required this.startPageNumber,
    required this.endPageNumber,
  });

  /// Creates a [PageLocationInputCitation] from JSON.
  factory PageLocationInputCitation.fromJson(Map<String, dynamic> json) {
    return PageLocationInputCitation(
      citedText: json['cited_text'] as String,
      documentIndex: json['document_index'] as int,
      documentTitle: json['document_title'] as String?,
      startPageNumber: json['start_page_number'] as int,
      endPageNumber: json['end_page_number'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'page_location',
    'cited_text': citedText,
    'document_index': documentIndex,
    'document_title': documentTitle,
    'start_page_number': startPageNumber,
    'end_page_number': endPageNumber,
  };

  /// Creates a copy with replaced values.
  PageLocationInputCitation copyWith({
    String? citedText,
    int? documentIndex,
    Object? documentTitle = unsetCopyWithValue,
    int? startPageNumber,
    int? endPageNumber,
  }) {
    return PageLocationInputCitation(
      citedText: citedText ?? this.citedText,
      documentIndex: documentIndex ?? this.documentIndex,
      documentTitle: documentTitle == unsetCopyWithValue
          ? this.documentTitle
          : documentTitle as String?,
      startPageNumber: startPageNumber ?? this.startPageNumber,
      endPageNumber: endPageNumber ?? this.endPageNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageLocationInputCitation &&
          runtimeType == other.runtimeType &&
          citedText == other.citedText &&
          documentIndex == other.documentIndex &&
          documentTitle == other.documentTitle &&
          startPageNumber == other.startPageNumber &&
          endPageNumber == other.endPageNumber;

  @override
  int get hashCode => Object.hash(
    citedText,
    documentIndex,
    documentTitle,
    startPageNumber,
    endPageNumber,
  );

  @override
  String toString() =>
      'PageLocationInputCitation(citedText: [${citedText.length} chars], '
      'documentIndex: $documentIndex, documentTitle: $documentTitle, '
      'startPageNumber: $startPageNumber, endPageNumber: $endPageNumber)';
}

/// Request citation with content block location (block-indexed sources).
@immutable
class ContentBlockLocationInputCitation extends InputCitation {
  /// The cited text.
  final String citedText;

  /// The document index.
  final int documentIndex;

  /// The document title (may be `null`; the key is always sent).
  final String? documentTitle;

  /// Start content block index.
  final int startBlockIndex;

  /// End content block index.
  final int endBlockIndex;

  /// Creates a [ContentBlockLocationInputCitation].
  const ContentBlockLocationInputCitation({
    required this.citedText,
    required this.documentIndex,
    required this.documentTitle,
    required this.startBlockIndex,
    required this.endBlockIndex,
  });

  /// Creates a [ContentBlockLocationInputCitation] from JSON.
  factory ContentBlockLocationInputCitation.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentBlockLocationInputCitation(
      citedText: json['cited_text'] as String,
      documentIndex: json['document_index'] as int,
      documentTitle: json['document_title'] as String?,
      startBlockIndex: json['start_block_index'] as int,
      endBlockIndex: json['end_block_index'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'content_block_location',
    'cited_text': citedText,
    'document_index': documentIndex,
    'document_title': documentTitle,
    'start_block_index': startBlockIndex,
    'end_block_index': endBlockIndex,
  };

  /// Creates a copy with replaced values.
  ContentBlockLocationInputCitation copyWith({
    String? citedText,
    int? documentIndex,
    Object? documentTitle = unsetCopyWithValue,
    int? startBlockIndex,
    int? endBlockIndex,
  }) {
    return ContentBlockLocationInputCitation(
      citedText: citedText ?? this.citedText,
      documentIndex: documentIndex ?? this.documentIndex,
      documentTitle: documentTitle == unsetCopyWithValue
          ? this.documentTitle
          : documentTitle as String?,
      startBlockIndex: startBlockIndex ?? this.startBlockIndex,
      endBlockIndex: endBlockIndex ?? this.endBlockIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlockLocationInputCitation &&
          runtimeType == other.runtimeType &&
          citedText == other.citedText &&
          documentIndex == other.documentIndex &&
          documentTitle == other.documentTitle &&
          startBlockIndex == other.startBlockIndex &&
          endBlockIndex == other.endBlockIndex;

  @override
  int get hashCode => Object.hash(
    citedText,
    documentIndex,
    documentTitle,
    startBlockIndex,
    endBlockIndex,
  );

  @override
  String toString() =>
      'ContentBlockLocationInputCitation(citedText: [${citedText.length} chars], '
      'documentIndex: $documentIndex, documentTitle: $documentTitle, '
      'startBlockIndex: $startBlockIndex, endBlockIndex: $endBlockIndex)';
}

/// Request citation referencing a web search result.
@immutable
class WebSearchResultLocationInputCitation extends InputCitation {
  /// The cited text.
  final String citedText;

  /// Encrypted index for the citation.
  final String encryptedIndex;

  /// Title of the source (may be `null`; the key is always sent).
  final String? title;

  /// URL of the source.
  final String url;

  /// Creates a [WebSearchResultLocationInputCitation].
  const WebSearchResultLocationInputCitation({
    required this.citedText,
    required this.encryptedIndex,
    required this.title,
    required this.url,
  });

  /// Creates a [WebSearchResultLocationInputCitation] from JSON.
  factory WebSearchResultLocationInputCitation.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebSearchResultLocationInputCitation(
      citedText: json['cited_text'] as String,
      encryptedIndex: json['encrypted_index'] as String,
      title: json['title'] as String?,
      url: json['url'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_result_location',
    'cited_text': citedText,
    'encrypted_index': encryptedIndex,
    'title': title,
    'url': url,
  };

  /// Creates a copy with replaced values.
  WebSearchResultLocationInputCitation copyWith({
    String? citedText,
    String? encryptedIndex,
    Object? title = unsetCopyWithValue,
    String? url,
  }) {
    return WebSearchResultLocationInputCitation(
      citedText: citedText ?? this.citedText,
      encryptedIndex: encryptedIndex ?? this.encryptedIndex,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      url: url ?? this.url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchResultLocationInputCitation &&
          runtimeType == other.runtimeType &&
          citedText == other.citedText &&
          encryptedIndex == other.encryptedIndex &&
          title == other.title &&
          url == other.url;

  @override
  int get hashCode => Object.hash(citedText, encryptedIndex, title, url);

  @override
  String toString() =>
      'WebSearchResultLocationInputCitation('
      'citedText: [${citedText.length} chars], '
      'encryptedIndex: [${encryptedIndex.length} chars], '
      'title: $title, url: $url)';
}

/// Request citation referencing a range of blocks within a `search_result`
/// content block (for supplying your own cited search results, e.g. RAG).
@immutable
class SearchResultLocationInputCitation extends InputCitation {
  /// The cited text (the concatenated contents of the cited block range).
  final String citedText;

  /// 0-based index of the cited search result among all `search_result`
  /// content blocks in the request.
  final int searchResultIndex;

  /// Source identifier of the cited search result.
  final String source;

  /// Title of the cited search result (may be `null`; the key is always sent).
  final String? title;

  /// 0-based index of the first cited block in the source's content array.
  final int startBlockIndex;

  /// Exclusive 0-based end index of the cited block range.
  final int endBlockIndex;

  /// Creates a [SearchResultLocationInputCitation].
  const SearchResultLocationInputCitation({
    required this.citedText,
    required this.searchResultIndex,
    required this.source,
    required this.title,
    required this.startBlockIndex,
    required this.endBlockIndex,
  });

  /// Creates a [SearchResultLocationInputCitation] from JSON.
  factory SearchResultLocationInputCitation.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchResultLocationInputCitation(
      citedText: json['cited_text'] as String,
      searchResultIndex: json['search_result_index'] as int,
      source: json['source'] as String,
      title: json['title'] as String?,
      startBlockIndex: json['start_block_index'] as int,
      endBlockIndex: json['end_block_index'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'search_result_location',
    'cited_text': citedText,
    'search_result_index': searchResultIndex,
    'source': source,
    'title': title,
    'start_block_index': startBlockIndex,
    'end_block_index': endBlockIndex,
  };

  /// Creates a copy with replaced values.
  SearchResultLocationInputCitation copyWith({
    String? citedText,
    int? searchResultIndex,
    String? source,
    Object? title = unsetCopyWithValue,
    int? startBlockIndex,
    int? endBlockIndex,
  }) {
    return SearchResultLocationInputCitation(
      citedText: citedText ?? this.citedText,
      searchResultIndex: searchResultIndex ?? this.searchResultIndex,
      source: source ?? this.source,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      startBlockIndex: startBlockIndex ?? this.startBlockIndex,
      endBlockIndex: endBlockIndex ?? this.endBlockIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultLocationInputCitation &&
          runtimeType == other.runtimeType &&
          citedText == other.citedText &&
          searchResultIndex == other.searchResultIndex &&
          source == other.source &&
          title == other.title &&
          startBlockIndex == other.startBlockIndex &&
          endBlockIndex == other.endBlockIndex;

  @override
  int get hashCode => Object.hash(
    citedText,
    searchResultIndex,
    source,
    title,
    startBlockIndex,
    endBlockIndex,
  );

  @override
  String toString() =>
      'SearchResultLocationInputCitation('
      'citedText: [${citedText.length} chars], '
      'searchResultIndex: $searchResultIndex, source: $source, title: $title, '
      'startBlockIndex: $startBlockIndex, endBlockIndex: $endBlockIndex)';
}

/// Unrecognized request citation type — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownInputCitation extends InputCitation {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownInputCitation].
  const UnknownInputCitation({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownInputCitation &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownInputCitation(rawJson: $rawJson)';
}
