import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../config/item_status.dart';
import '../config/message_role.dart';
import '../content/output_content.dart';
import 'item.dart';

/// Output item from a response.
///
/// This is a sealed class hierarchy for different output item types.
///
/// ## Supported Types
///
/// - [MessageOutputItem] - Text messages from the assistant
/// - [FunctionCallOutputItemResponse] - Custom function calls
/// - [ReasoningItem] - Reasoning content from reasoning models
/// - [WebSearchCallOutputItem] - Web search tool calls
/// - [FileSearchCallOutputItem] - File search tool calls
/// - [CodeInterpreterCallOutputItem] - Code interpreter tool calls
/// - [ImageGenerationCallOutputItem] - Image generation tool calls
/// - [McpCallOutputItem] - MCP (Model Context Protocol) tool calls
sealed class OutputItem {
  /// Creates an [OutputItem].
  const OutputItem();

  /// Creates an [OutputItem] from JSON.
  factory OutputItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => MessageOutputItem.fromJson(json),
      'function_call' => FunctionCallOutputItemResponse.fromJson(json),
      'reasoning' => ReasoningItem.fromJson(json),
      'web_search_call' => WebSearchCallOutputItem.fromJson(json),
      'file_search_call' => FileSearchCallOutputItem.fromJson(json),
      'code_interpreter_call' => CodeInterpreterCallOutputItem.fromJson(json),
      'image_generation_call' => ImageGenerationCallOutputItem.fromJson(json),
      'mcp_call' => McpCallOutputItem.fromJson(json),
      _ => throw FormatException('Unknown OutputItem type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A message output item.
@immutable
class MessageOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The role of the message.
  final MessageRole role;

  /// The content of the message.
  final List<OutputContent> content;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [MessageOutputItem].
  const MessageOutputItem({
    required this.id,
    required this.role,
    required this.content,
    this.status,
  });

  /// Creates a [MessageOutputItem] from JSON.
  factory MessageOutputItem.fromJson(Map<String, dynamic> json) {
    return MessageOutputItem(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => OutputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message',
    'id': id,
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, role, content, status);

  @override
  String toString() =>
      'MessageOutputItem(id: $id, role: $role, content: $content, status: $status)';
}

/// A function call output item in the response.
@immutable
class FunctionCallOutputItemResponse extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The call ID for this function call.
  final String callId;

  /// The function name.
  final String name;

  /// The function arguments as JSON string.
  final String arguments;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [FunctionCallOutputItemResponse].
  const FunctionCallOutputItemResponse({
    required this.id,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
  });

  /// Creates a [FunctionCallOutputItemResponse] from JSON.
  factory FunctionCallOutputItemResponse.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputItemResponse(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call',
    'id': id,
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
  };

  /// Converts to a [FunctionCallItem] for use as input.
  FunctionCallItem toFunctionCallItem() => FunctionCallItem(
    id: id,
    callId: callId,
    name: name,
    arguments: arguments,
    status: status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, name, arguments, status);

  @override
  String toString() =>
      'FunctionCallOutputItemResponse(id: $id, callId: $callId, name: $name, arguments: $arguments, status: $status)';
}

/// A reasoning item from reasoning models.
@immutable
class ReasoningItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The reasoning content that was generated.
  ///
  /// Contains a list of content parts that make up the reasoning.
  final List<Map<String, dynamic>>? content;

  /// The reasoning summary content.
  final List<ReasoningSummaryContent> summary;

  /// Encrypted reasoning content (if requested via include).
  final String? encryptedContent;

  /// Creates a [ReasoningItem].
  const ReasoningItem({
    required this.id,
    this.content,
    required this.summary,
    this.encryptedContent,
  });

  /// Creates a [ReasoningItem] from JSON.
  factory ReasoningItem.fromJson(Map<String, dynamic> json) {
    return ReasoningItem(
      id: json['id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      summary: (json['summary'] as List)
          .map(
            (e) => ReasoningSummaryContent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      encryptedContent: json['encrypted_content'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'reasoning',
    'id': id,
    if (content != null) 'content': content,
    'summary': summary.map((e) => e.toJson()).toList(),
    if (encryptedContent != null) 'encrypted_content': encryptedContent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(summary, other.summary) &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode => Object.hash(id, summary, encryptedContent);

  @override
  String toString() =>
      'ReasoningItem(id: $id, content: $content, summary: $summary, encryptedContent: $encryptedContent)';
}

/// Content within a reasoning summary.
@immutable
class ReasoningSummaryContent {
  /// The summary text.
  final String text;

  /// Creates a [ReasoningSummaryContent].
  const ReasoningSummaryContent({required this.text});

  /// Creates a [ReasoningSummaryContent] from JSON.
  factory ReasoningSummaryContent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryContent(text: json['text'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': 'summary_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ReasoningSummaryContent(text: $text)';
}

// ============================================================
// Built-in Tool Output Items
// ============================================================

/// A web search call output item.
///
/// Returned when the model uses the [WebSearchTool].
@immutable
class WebSearchCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [WebSearchCallOutputItem].
  const WebSearchCallOutputItem({required this.id, this.status});

  /// Creates a [WebSearchCallOutputItem] from JSON.
  factory WebSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return WebSearchCallOutputItem(
      id: json['id'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_call',
    'id': id,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, status);

  @override
  String toString() => 'WebSearchCallOutputItem(id: $id, status: $status)';
}

/// A file search call output item.
///
/// Returned when the model uses the [FileSearchTool].
@immutable
class FileSearchCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The search queries performed.
  final List<String>? queries;

  /// The search results.
  final List<Map<String, dynamic>>? results;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [FileSearchCallOutputItem].
  const FileSearchCallOutputItem({
    required this.id,
    this.queries,
    this.results,
    this.status,
  });

  /// Creates a [FileSearchCallOutputItem] from JSON.
  factory FileSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return FileSearchCallOutputItem(
      id: json['id'] as String,
      queries: (json['queries'] as List?)?.cast<String>(),
      results: (json['results'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_search_call',
    'id': id,
    if (queries != null) 'queries': queries,
    if (results != null) 'results': results,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(queries, other.queries) &&
          listsEqual(results, other.results) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, queries, results, status);

  @override
  String toString() =>
      'FileSearchCallOutputItem(id: $id, queries: $queries, results: $results, status: $status)';
}

/// A code interpreter call output item.
///
/// Returned when the model uses the [CodeInterpreterTool].
@immutable
class CodeInterpreterCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The code that was executed.
  final String? code;

  /// The programming language (typically "python").
  final String? language;

  /// The execution outputs.
  final List<Map<String, dynamic>>? outputs;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [CodeInterpreterCallOutputItem].
  const CodeInterpreterCallOutputItem({
    required this.id,
    this.code,
    this.language,
    this.outputs,
    this.status,
  });

  /// Creates a [CodeInterpreterCallOutputItem] from JSON.
  factory CodeInterpreterCallOutputItem.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterCallOutputItem(
      id: json['id'] as String,
      code: json['code'] as String?,
      language: json['language'] as String?,
      outputs: (json['outputs'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'code_interpreter_call',
    'id': id,
    if (code != null) 'code': code,
    if (language != null) 'language': language,
    if (outputs != null) 'outputs': outputs,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          language == other.language &&
          listsEqual(outputs, other.outputs) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, code, language, outputs, status);

  @override
  String toString() =>
      'CodeInterpreterCallOutputItem(id: $id, code: $code, language: $language, outputs: $outputs, status: $status)';
}

/// An image generation call output item.
///
/// Returned when the model uses the [ImageGenerationTool].
@immutable
class ImageGenerationCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The original prompt used for generation.
  final String? prompt;

  /// The revised prompt (may be modified by the model).
  final String? revisedPrompt;

  /// The generated image result (base64 or URL depending on configuration).
  final String? result;

  /// Item status.
  final ItemStatus? status;

  /// Creates an [ImageGenerationCallOutputItem].
  const ImageGenerationCallOutputItem({
    required this.id,
    this.prompt,
    this.revisedPrompt,
    this.result,
    this.status,
  });

  /// Creates an [ImageGenerationCallOutputItem] from JSON.
  factory ImageGenerationCallOutputItem.fromJson(Map<String, dynamic> json) {
    return ImageGenerationCallOutputItem(
      id: json['id'] as String,
      prompt: json['prompt'] as String?,
      revisedPrompt: json['revised_prompt'] as String?,
      result: json['result'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_generation_call',
    'id': id,
    if (prompt != null) 'prompt': prompt,
    if (revisedPrompt != null) 'revised_prompt': revisedPrompt,
    if (result != null) 'result': result,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          prompt == other.prompt &&
          revisedPrompt == other.revisedPrompt &&
          result == other.result &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, prompt, revisedPrompt, result, status);

  @override
  String toString() =>
      'ImageGenerationCallOutputItem(id: $id, prompt: $prompt, revisedPrompt: $revisedPrompt, result: ${result != null ? "[${result!.length} chars]" : null}, status: $status)';
}

/// An MCP (Model Context Protocol) call output item.
///
/// Returned when the model uses the [McpTool].
@immutable
class McpCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The call ID for this MCP call.
  final String callId;

  /// The server label identifying the MCP server.
  final String? serverLabel;

  /// The name of the MCP tool called.
  final String? name;

  /// The arguments passed to the tool (JSON string).
  final String? arguments;

  /// The output from the tool call.
  final String? output;

  /// Error message if the call failed.
  final String? error;

  /// Item status.
  final ItemStatus? status;

  /// Creates an [McpCallOutputItem].
  const McpCallOutputItem({
    required this.id,
    required this.callId,
    this.serverLabel,
    this.name,
    this.arguments,
    this.output,
    this.error,
    this.status,
  });

  /// Creates an [McpCallOutputItem] from JSON.
  factory McpCallOutputItem.fromJson(Map<String, dynamic> json) {
    return McpCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      serverLabel: json['server_label'] as String?,
      name: json['name'] as String?,
      arguments: json['arguments'] as String?,
      output: json['output'] as String?,
      error: json['error'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_call',
    'id': id,
    'call_id': callId,
    if (serverLabel != null) 'server_label': serverLabel,
    if (name != null) 'name': name,
    if (arguments != null) 'arguments': arguments,
    if (output != null) 'output': output,
    if (error != null) 'error': error,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          serverLabel == other.serverLabel &&
          name == other.name &&
          arguments == other.arguments &&
          output == other.output &&
          error == other.error &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    callId,
    serverLabel,
    name,
    arguments,
    output,
    error,
    status,
  );

  @override
  String toString() =>
      'McpCallOutputItem(id: $id, callId: $callId, serverLabel: $serverLabel, name: $name, arguments: $arguments, output: $output, error: $error, status: $status)';
}
