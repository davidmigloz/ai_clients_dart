import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../config/function_call_output_status.dart';
import '../config/item_status.dart';
import '../config/message_phase.dart';
import '../config/message_role.dart';
import '../config/program_output_status.dart';
import '../config/tool_search_execution_type.dart';
import '../content/output_content.dart';
import '../multi_agent/agent_tag.dart';
import '../multi_agent/multi_agent_action.dart';
import '../tools/computer_action.dart';
import '../tools/response_tool.dart';
import '../tools/tool_call_caller.dart';
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
/// - [CompactionOutputItem] - Compacted conversation history
/// - [WebSearchCallOutputItem] - Web search tool calls
/// - [FileSearchCallOutputItem] - File search tool calls
/// - [CodeInterpreterCallOutputItem] - Code interpreter tool calls
/// - [ImageGenerationCallOutputItem] - Image generation tool calls
/// - [LocalShellCallOutputItem] - Local shell tool calls
/// - [LocalShellCallOutputResultItem] - Local shell tool call results
/// - [ShellCallOutputItem] - Shell tool calls
/// - [ShellCallOutputResultItem] - Shell tool call results
/// - [McpCallOutputItem] - MCP (Model Context Protocol) tool calls
/// - [ToolSearchCallOutputItem] - Tool search calls
/// - [ToolSearchOutputItem] - Tool search results
/// - [ComputerCallOutputItem] - Computer use tool calls
/// - [CustomToolCallItem] - Custom tool calls
/// - [CustomToolCallOutputItem] - Custom tool call outputs
/// - [AdditionalToolsOutputItem] - Additional tool definitions made available
///   mid-conversation
/// - [ProgramOutputItemResponse] - Programmatic tool calling source code
/// - [ProgramOutputResultItem] - Result of a programmatic tool calling
///   execution
/// - [AgentMessageOutputItem] - A message routed between agents (beta
///   multi-agent)
/// - [MultiAgentCallOutputItemResponse] - A multi-agent action call (beta
///   multi-agent)
/// - [MultiAgentCallOutputResultItem] - Output of a multi-agent action call
///   (beta multi-agent)
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
      'compaction' => CompactionOutputItem.fromJson(json),
      'web_search_call' => WebSearchCallOutputItem.fromJson(json),
      'file_search_call' => FileSearchCallOutputItem.fromJson(json),
      'code_interpreter_call' => CodeInterpreterCallOutputItem.fromJson(json),
      'image_generation_call' => ImageGenerationCallOutputItem.fromJson(json),
      'local_shell_call' => LocalShellCallOutputItem.fromJson(json),
      'local_shell_call_output' => LocalShellCallOutputResultItem.fromJson(
        json,
      ),
      'shell_call' => ShellCallOutputItem.fromJson(json),
      'shell_call_output' => ShellCallOutputResultItem.fromJson(json),
      'mcp_call' => McpCallOutputItem.fromJson(json),
      'tool_search_call' => ToolSearchCallOutputItem.fromJson(json),
      'tool_search_output' => ToolSearchOutputItem.fromJson(json),
      'computer_call' => ComputerCallOutputItem.fromJson(json),
      'custom_tool_call' => CustomToolCallItem.fromJson(json),
      'custom_tool_call_output' => CustomToolCallOutputItem.fromJson(json),
      'additional_tools' => AdditionalToolsOutputItem.fromJson(json),
      'program' => ProgramOutputItemResponse.fromJson(json),
      'program_output' => ProgramOutputResultItem.fromJson(json),
      'agent_message' => AgentMessageOutputItem.fromJson(json),
      'multi_agent_call' => MultiAgentCallOutputItemResponse.fromJson(json),
      'multi_agent_call_output' => MultiAgentCallOutputResultItem.fromJson(
        json,
      ),
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

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The role of the message.
  final MessageRole role;

  /// The content of the message.
  final List<OutputContent> content;

  /// Item status.
  final ItemStatus? status;

  /// The phase of the message.
  final MessagePhase? phase;

  /// Creates a [MessageOutputItem].
  const MessageOutputItem({
    required this.id,
    this.agent,
    required this.role,
    required this.content,
    this.status,
    this.phase,
  });

  /// Creates a [MessageOutputItem] from JSON.
  factory MessageOutputItem.fromJson(Map<String, dynamic> json) {
    return MessageOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => OutputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      phase: json['phase'] != null
          ? MessagePhase.fromJson(json['phase'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
    if (phase != null) 'phase': phase!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status &&
          phase == other.phase;

  @override
  int get hashCode =>
      Object.hash(id, agent, role, Object.hashAll(content), status, phase);

  @override
  String toString() =>
      'MessageOutputItem(id: $id, agent: $agent, role: $role, content: $content, status: $status, phase: $phase)';
}

/// A function call output item in the response.
@immutable
class FunctionCallOutputItemResponse extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this function call.
  final String callId;

  /// The function name.
  final String name;

  /// The function arguments as JSON string.
  final String arguments;

  /// The arguments parsed as a JSON map.
  ///
  /// Throws [FormatException] if [arguments] is not valid JSON or does not
  /// decode to a JSON object.
  Map<String, dynamic> get argumentsMap {
    final decoded = jsonDecode(arguments);
    if (decoded is! Map) {
      throw const FormatException(
        'Function call arguments must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  /// Item status.
  final ItemStatus? status;

  /// The namespace this function call belongs to.
  final String? namespace;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// The execution context that produced this tool call.
  final ToolCallCaller? caller;

  /// Creates a [FunctionCallOutputItemResponse].
  const FunctionCallOutputItemResponse({
    required this.id,
    this.agent,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
    this.namespace,
    this.createdBy,
    this.caller,
  });

  /// Creates a [FunctionCallOutputItemResponse] from JSON.
  factory FunctionCallOutputItemResponse.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputItemResponse(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      namespace: json['namespace'] as String?,
      createdBy: json['created_by'] as String?,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
    if (namespace != null) 'namespace': namespace,
    if (createdBy != null) 'created_by': createdBy,
    if (caller != null) 'caller': caller!.toJson(),
  };

  /// Converts to a [FunctionCallItem] for use as input.
  FunctionCallItem toFunctionCallItem() => FunctionCallItem(
    id: id,
    callId: callId,
    name: name,
    arguments: arguments,
    status: status,
    namespace: namespace,
    caller: caller,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          status == other.status &&
          namespace == other.namespace &&
          createdBy == other.createdBy &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    name,
    arguments,
    status,
    namespace,
    createdBy,
    caller,
  );

  @override
  String toString() =>
      'FunctionCallOutputItemResponse(id: $id, agent: $agent, callId: $callId, name: $name, arguments: $arguments, status: $status, namespace: $namespace, createdBy: $createdBy, caller: $caller)';
}

/// A reasoning item from reasoning models.
@immutable
class ReasoningItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

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
    this.agent,
    this.content,
    required this.summary,
    this.encryptedContent,
  });

  /// Creates a [ReasoningItem] from JSON.
  factory ReasoningItem.fromJson(Map<String, dynamic> json) {
    return ReasoningItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
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
    if (agent != null) 'agent': agent!.toJson(),
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
          agent == other.agent &&
          listsEqual(summary, other.summary) &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode =>
      Object.hash(id, agent, Object.hashAll(summary), encryptedContent);

  @override
  String toString() =>
      'ReasoningItem(id: $id, agent: $agent, content: $content, summary: $summary, encryptedContent: $encryptedContent)';
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

/// A compaction item emitted by `responses.compact`.
@immutable
class CompactionOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Encrypted compaction payload.
  final String encryptedContent;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// Creates a [CompactionOutputItem].
  const CompactionOutputItem({
    required this.id,
    this.agent,
    required this.encryptedContent,
    this.createdBy,
  });

  /// Creates a [CompactionOutputItem] from JSON.
  factory CompactionOutputItem.fromJson(Map<String, dynamic> json) {
    return CompactionOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      encryptedContent: json['encrypted_content'] as String,
      createdBy: json['created_by'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'encrypted_content': encryptedContent,
    if (createdBy != null) 'created_by': createdBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          encryptedContent == other.encryptedContent &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(id, agent, encryptedContent, createdBy);

  @override
  String toString() =>
      'CompactionOutputItem(id: $id, agent: $agent, encryptedContent: ${encryptedContent.length} chars, createdBy: $createdBy)';
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

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [WebSearchCallOutputItem].
  const WebSearchCallOutputItem({required this.id, this.agent, this.status});

  /// Creates a [WebSearchCallOutputItem] from JSON.
  factory WebSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return WebSearchCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, agent, status);

  @override
  String toString() =>
      'WebSearchCallOutputItem(id: $id, agent: $agent, status: $status)';
}

/// A file search call output item.
///
/// Returned when the model uses the [FileSearchTool].
@immutable
class FileSearchCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The search queries performed.
  final List<String>? queries;

  /// The search results.
  final List<Map<String, dynamic>>? results;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [FileSearchCallOutputItem].
  const FileSearchCallOutputItem({
    required this.id,
    this.agent,
    this.queries,
    this.results,
    this.status,
  });

  /// Creates a [FileSearchCallOutputItem] from JSON.
  factory FileSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return FileSearchCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
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
    if (agent != null) 'agent': agent!.toJson(),
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
          agent == other.agent &&
          listsEqual(queries, other.queries) &&
          listsEqual(results, other.results) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    queries != null ? Object.hashAll(queries!) : null,
    results != null ? Object.hashAll(results!) : null,
    status,
  );

  @override
  String toString() =>
      'FileSearchCallOutputItem(id: $id, agent: $agent, queries: $queries, results: $results, status: $status)';
}

/// Output from a code interpreter execution.
///
/// See [CodeInterpreterLogsOutput] and [CodeInterpreterImageOutput].
sealed class CodeInterpreterOutput {
  /// Creates a [CodeInterpreterOutput].
  const CodeInterpreterOutput();

  /// Creates a [CodeInterpreterOutput] from JSON.
  factory CodeInterpreterOutput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'logs' => CodeInterpreterLogsOutput.fromJson(json),
      'image' => CodeInterpreterImageOutput.fromJson(json),
      _ => throw FormatException('Unknown CodeInterpreterOutput type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Log output from code interpreter execution.
@immutable
class CodeInterpreterLogsOutput extends CodeInterpreterOutput {
  /// The log text output.
  final String logs;

  /// Creates a [CodeInterpreterLogsOutput].
  const CodeInterpreterLogsOutput({required this.logs});

  /// Creates a [CodeInterpreterLogsOutput] from JSON.
  factory CodeInterpreterLogsOutput.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterLogsOutput(logs: json['logs'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'logs', 'logs': logs};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterLogsOutput &&
          runtimeType == other.runtimeType &&
          logs == other.logs;

  @override
  int get hashCode => logs.hashCode;

  @override
  String toString() => 'CodeInterpreterLogsOutput(logs: $logs)';
}

/// Image output from code interpreter execution.
@immutable
class CodeInterpreterImageOutput extends CodeInterpreterOutput {
  /// The URL of the generated image.
  final String url;

  /// Creates a [CodeInterpreterImageOutput].
  const CodeInterpreterImageOutput({required this.url});

  /// Creates a [CodeInterpreterImageOutput] from JSON.
  factory CodeInterpreterImageOutput.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterImageOutput(url: json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'image', 'url': url};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterImageOutput &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'CodeInterpreterImageOutput(url: $url)';
}

/// A code interpreter call output item.
///
/// Returned when the model uses the [CodeInterpreterTool].
@immutable
class CodeInterpreterCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the container used to run the code.
  final String? containerId;

  /// The code that was executed.
  final String? code;

  /// The programming language (typically "python").
  final String? language;

  /// The execution outputs.
  final List<CodeInterpreterOutput>? outputs;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [CodeInterpreterCallOutputItem].
  const CodeInterpreterCallOutputItem({
    required this.id,
    this.agent,
    this.containerId,
    this.code,
    this.language,
    this.outputs,
    this.status,
  });

  /// Creates a [CodeInterpreterCallOutputItem] from JSON.
  factory CodeInterpreterCallOutputItem.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      containerId: json['container_id'] as String?,
      code: json['code'] as String?,
      language: json['language'] as String?,
      outputs: (json['outputs'] as List?)
          ?.map(
            (e) => CodeInterpreterOutput.fromJson(e as Map<String, dynamic>),
          )
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
    if (agent != null) 'agent': agent!.toJson(),
    if (containerId != null) 'container_id': containerId,
    if (code != null) 'code': code,
    if (language != null) 'language': language,
    if (outputs != null) 'outputs': outputs!.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          containerId == other.containerId &&
          code == other.code &&
          language == other.language &&
          listsEqual(outputs, other.outputs) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    containerId,
    code,
    language,
    outputs != null ? Object.hashAll(outputs!) : null,
    status,
  );

  @override
  String toString() =>
      'CodeInterpreterCallOutputItem(id: $id, agent: $agent, containerId: $containerId, code: $code, language: $language, outputs: $outputs, status: $status)';
}

/// An image generation call output item.
///
/// Returned when the model uses the [ImageGenerationTool].
@immutable
class ImageGenerationCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

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
    this.agent,
    this.prompt,
    this.revisedPrompt,
    this.result,
    this.status,
  });

  /// Creates an [ImageGenerationCallOutputItem] from JSON.
  factory ImageGenerationCallOutputItem.fromJson(Map<String, dynamic> json) {
    return ImageGenerationCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
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
    if (agent != null) 'agent': agent!.toJson(),
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
          agent == other.agent &&
          prompt == other.prompt &&
          revisedPrompt == other.revisedPrompt &&
          result == other.result &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, agent, prompt, revisedPrompt, result, status);

  @override
  String toString() =>
      'ImageGenerationCallOutputItem(id: $id, agent: $agent, prompt: $prompt, revisedPrompt: $revisedPrompt, result: ${result != null ? "[${result!.length} chars]" : null}, status: $status)';
}

/// A local shell call output item.
@immutable
class LocalShellCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The local shell call ID.
  final String callId;

  /// Typed action payload to execute locally.
  final LocalShellExecAction action;

  /// Item status.
  final ItemStatus status;

  /// Creates a [LocalShellCallOutputItem].
  const LocalShellCallOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.status,
  });

  /// Creates a [LocalShellCallOutputItem] from JSON.
  factory LocalShellCallOutputItem.fromJson(Map<String, dynamic> json) {
    return LocalShellCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: LocalShellExecAction.fromJson(
        json['action'] as Map<String, dynamic>,
      ),
      status: ItemStatus.fromJson(json['status'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'local_shell_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'status': status.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, agent, callId, action, status);

  @override
  String toString() =>
      'LocalShellCallOutputItem(id: $id, agent: $agent, callId: $callId, status: $status)';
}

/// Typed action for a local shell call.
///
/// Matches the OpenAPI `LocalShellExecAction` schema and the Python SDK's
/// `LocalShellCallAction`.
@immutable
class LocalShellExecAction {
  /// Commands to execute.
  final List<String> command;

  /// Environment variables for the command.
  final Map<String, String> env;

  /// Optional timeout in milliseconds.
  final int? timeoutMs;

  /// Optional working directory.
  final String? workingDirectory;

  /// Optional user to execute as.
  final String? user;

  /// Creates a [LocalShellExecAction].
  const LocalShellExecAction({
    required this.command,
    this.env = const {},
    this.timeoutMs,
    this.workingDirectory,
    this.user,
  });

  /// Creates a [LocalShellExecAction] from JSON.
  factory LocalShellExecAction.fromJson(Map<String, dynamic> json) {
    return LocalShellExecAction(
      command: (json['command'] as List<dynamic>).cast<String>(),
      env: (json['env'] as Map<String, dynamic>).cast<String, String>(),
      timeoutMs: json['timeout_ms'] as int?,
      workingDirectory: json['working_directory'] as String?,
      user: json['user'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'exec',
    'command': command,
    'env': env,
    if (timeoutMs != null) 'timeout_ms': timeoutMs,
    if (workingDirectory != null) 'working_directory': workingDirectory,
    if (user != null) 'user': user,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellExecAction &&
          runtimeType == other.runtimeType &&
          listsEqual(command, other.command) &&
          mapsEqual(env, other.env) &&
          timeoutMs == other.timeoutMs &&
          workingDirectory == other.workingDirectory &&
          user == other.user;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(command),
    mapHash(env),
    timeoutMs,
    workingDirectory,
    user,
  );

  @override
  String toString() =>
      'LocalShellExecAction(command: $command, env: $env, timeoutMs: $timeoutMs, workingDirectory: $workingDirectory, user: $user)';
}

/// A shell call output item.
@immutable
class ShellCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The shell call ID.
  final String callId;

  /// Commands and execution options for this call.
  final ShellCallAction action;

  /// Item status.
  final ItemStatus status;

  /// The environment in which the shell call was executed.
  ///
  /// Can be a [LocalShellEnvironment], [ContainerReferenceEnvironment],
  /// or `null`.
  final ShellEnvironment? environment;

  /// The execution context that produced this tool call.
  final ToolCallCaller? caller;

  /// Creates a [ShellCallOutputItem].
  const ShellCallOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.status,
    this.environment,
    this.caller,
  });

  /// Creates a [ShellCallOutputItem] from JSON.
  factory ShellCallOutputItem.fromJson(Map<String, dynamic> json) {
    return ShellCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: ShellCallAction.fromJson(json['action'] as Map<String, dynamic>),
      status: ItemStatus.fromJson(json['status'] as String),
      environment: json['environment'] != null
          ? ShellEnvironment.fromJson(
              json['environment'] as Map<String, dynamic>,
            )
          : null,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'shell_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'status': status.toJson(),
    if (environment != null) 'environment': environment!.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          status == other.status &&
          environment == other.environment &&
          caller == other.caller;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, action, status, environment, caller);

  @override
  String toString() =>
      'ShellCallOutputItem(id: $id, agent: $agent, callId: $callId, status: $status, environment: $environment, caller: $caller)';
}

/// Shell call action payload.
@immutable
class ShellCallAction {
  /// Commands to execute.
  final List<String> commands;

  /// Optional timeout in milliseconds.
  final int? timeoutMs;

  /// Optional max output length.
  final int? maxOutputLength;

  /// Creates a [ShellCallAction].
  const ShellCallAction({
    required this.commands,
    this.timeoutMs,
    this.maxOutputLength,
  });

  /// Creates a [ShellCallAction] from JSON.
  factory ShellCallAction.fromJson(Map<String, dynamic> json) {
    return ShellCallAction(
      commands: (json['commands'] as List<dynamic>).cast<String>(),
      timeoutMs: json['timeout_ms'] as int?,
      maxOutputLength: json['max_output_length'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'commands': commands,
    if (timeoutMs != null) 'timeout_ms': timeoutMs,
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallAction &&
          runtimeType == other.runtimeType &&
          listsEqual(commands, other.commands) &&
          timeoutMs == other.timeoutMs &&
          maxOutputLength == other.maxOutputLength;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(commands), timeoutMs, maxOutputLength);

  @override
  String toString() =>
      'ShellCallAction(commands: $commands, timeoutMs: $timeoutMs, maxOutputLength: $maxOutputLength)';
}

/// The execution environment for a shell call.
///
/// See [LocalShellEnvironment] and [ContainerReferenceEnvironment].
sealed class ShellEnvironment {
  /// Creates a [ShellEnvironment].
  const ShellEnvironment();

  /// Creates a [ShellEnvironment] from JSON.
  factory ShellEnvironment.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'local' => const LocalShellEnvironment(),
      'container_reference' => ContainerReferenceEnvironment.fromJson(json),
      final type => throw FormatException(
        'Unknown ShellEnvironment type: $type',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A local environment for shell execution.
@immutable
class LocalShellEnvironment extends ShellEnvironment {
  /// Creates a [LocalShellEnvironment].
  const LocalShellEnvironment();

  /// Creates a [LocalShellEnvironment] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory LocalShellEnvironment.fromJson(Map<String, dynamic> json) =>
      const LocalShellEnvironment();

  @override
  Map<String, dynamic> toJson() => const {'type': 'local'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalShellEnvironment;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'LocalShellEnvironment()';
}

/// A container reference environment for shell execution.
@immutable
class ContainerReferenceEnvironment extends ShellEnvironment {
  /// The container ID.
  final String containerId;

  /// Creates a [ContainerReferenceEnvironment].
  const ContainerReferenceEnvironment({required this.containerId});

  /// Creates a [ContainerReferenceEnvironment] from JSON.
  factory ContainerReferenceEnvironment.fromJson(Map<String, dynamic> json) {
    return ContainerReferenceEnvironment(
      containerId: json['container_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'container_reference',
    'container_id': containerId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerReferenceEnvironment &&
          runtimeType == other.runtimeType &&
          containerId == other.containerId;

  @override
  int get hashCode => containerId.hashCode;

  @override
  String toString() =>
      'ContainerReferenceEnvironment(containerId: $containerId)';
}

/// A shell call output result item.
@immutable
class ShellCallOutputResultItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The shell call ID.
  final String callId;

  /// The status of the shell call output.
  final ItemStatus? status;

  /// Structured output chunks from the call.
  final List<ShellCallOutputContent> output;

  /// The max output length to preserve for follow-up turns.
  final int? maxOutputLength;

  /// The execution context that produced the tool call this output responds
  /// to.
  final ToolCallCaller? caller;

  /// Creates a [ShellCallOutputResultItem].
  const ShellCallOutputResultItem({
    required this.id,
    this.agent,
    required this.callId,
    this.status,
    required this.output,
    required this.maxOutputLength,
    this.caller,
  });

  /// Creates a [ShellCallOutputResultItem] from JSON.
  factory ShellCallOutputResultItem.fromJson(Map<String, dynamic> json) {
    return ShellCallOutputResultItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      output: (json['output'] as List<dynamic>)
          .map(
            (e) => ShellCallOutputContent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      maxOutputLength: json['max_output_length'] as int?,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'shell_call_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    if (status != null) 'status': status!.toJson(),
    'output': output.map((e) => e.toJson()).toList(),
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
    if (caller != null) 'caller': caller!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputResultItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          status == other.status &&
          listsEqual(output, other.output) &&
          maxOutputLength == other.maxOutputLength &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    status,
    Object.hashAll(output),
    maxOutputLength,
    caller,
  );

  @override
  String toString() =>
      'ShellCallOutputResultItem(id: $id, agent: $agent, callId: $callId, status: $status, output: ${output.length} chunks, caller: $caller)';
}

/// A single shell output chunk.
@immutable
class ShellCallOutputContent {
  /// Captured stdout.
  final String stdout;

  /// Captured stderr.
  final String stderr;

  /// Execution outcome for this chunk.
  final ShellCallOutcome outcome;

  /// Creates a [ShellCallOutputContent].
  const ShellCallOutputContent({
    required this.stdout,
    required this.stderr,
    required this.outcome,
  });

  /// Creates a [ShellCallOutputContent] from JSON.
  factory ShellCallOutputContent.fromJson(Map<String, dynamic> json) {
    return ShellCallOutputContent(
      stdout: json['stdout'] as String,
      stderr: json['stderr'] as String,
      outcome: ShellCallOutcome.fromJson(
        json['outcome'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'stdout': stdout,
    'stderr': stderr,
    'outcome': outcome.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputContent &&
          runtimeType == other.runtimeType &&
          stdout == other.stdout &&
          stderr == other.stderr &&
          outcome == other.outcome;

  @override
  int get hashCode => Object.hash(stdout, stderr, outcome);

  @override
  String toString() =>
      'ShellCallOutputContent(stdout: ${stdout.length} chars, stderr: ${stderr.length} chars, outcome: $outcome)';
}

/// Execution outcome for a shell call output chunk.
sealed class ShellCallOutcome {
  /// Creates a [ShellCallOutcome].
  const ShellCallOutcome();

  /// Creates a [ShellCallOutcome] from JSON.
  factory ShellCallOutcome.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'exit' => ShellCallExitOutcome.fromJson(json),
      'timeout' => ShellCallTimeoutOutcome.fromJson(json),
      _ => throw FormatException('Unknown ShellCallOutcome type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Normal shell call completion with an exit code.
@immutable
class ShellCallExitOutcome extends ShellCallOutcome {
  /// Exit code of the command.
  final int exitCode;

  /// Creates a [ShellCallExitOutcome].
  const ShellCallExitOutcome({required this.exitCode});

  /// Creates a [ShellCallExitOutcome] from JSON.
  factory ShellCallExitOutcome.fromJson(Map<String, dynamic> json) {
    return ShellCallExitOutcome(exitCode: json['exit_code'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'exit', 'exit_code': exitCode};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallExitOutcome &&
          runtimeType == other.runtimeType &&
          exitCode == other.exitCode;

  @override
  int get hashCode => exitCode.hashCode;

  @override
  String toString() => 'ShellCallExitOutcome(exitCode: $exitCode)';
}

/// Shell call timeout outcome.
@immutable
class ShellCallTimeoutOutcome extends ShellCallOutcome {
  /// Creates a [ShellCallTimeoutOutcome].
  const ShellCallTimeoutOutcome();

  /// Creates a [ShellCallTimeoutOutcome] from JSON.
  factory ShellCallTimeoutOutcome.fromJson(Map<String, dynamic> json) {
    if ((json['type'] as String?) != 'timeout') {
      throw const FormatException('Invalid type for ShellCallTimeoutOutcome');
    }
    return const ShellCallTimeoutOutcome();
  }

  @override
  Map<String, dynamic> toJson() => const {'type': 'timeout'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShellCallTimeoutOutcome;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ShellCallTimeoutOutcome()';
}

/// A local shell call output result item.
@immutable
class LocalShellCallOutputResultItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The local shell call ID.
  final String? callId;

  /// The serialized local shell output payload.
  final String output;

  /// The status of the local shell call output.
  final ItemStatus? status;

  /// Creates a [LocalShellCallOutputResultItem].
  const LocalShellCallOutputResultItem({
    required this.id,
    this.agent,
    required this.output,
    this.callId,
    this.status,
  });

  /// Creates a [LocalShellCallOutputResultItem] from JSON.
  factory LocalShellCallOutputResultItem.fromJson(Map<String, dynamic> json) {
    return LocalShellCallOutputResultItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String?,
      output: json['output'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'local_shell_call_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    'output': output,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellCallOutputResultItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          output == other.output &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, agent, callId, output, status);

  @override
  String toString() =>
      'LocalShellCallOutputResultItem(id: $id, agent: $agent, callId: $callId, status: $status)';
}

/// An MCP (Model Context Protocol) call output item.
///
/// Returned when the model uses the [McpTool].
@immutable
class McpCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

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
    this.agent,
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
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
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
    if (agent != null) 'agent': agent!.toJson(),
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
          agent == other.agent &&
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
    agent,
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
      'McpCallOutputItem(id: $id, agent: $agent, callId: $callId, serverLabel: $serverLabel, name: $name, arguments: $arguments, output: $output, error: $error, status: $status)';
}

/// A tool search call output item.
@immutable
class ToolSearchCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this tool search call.
  final String? callId;

  /// The execution type (server or client).
  final ToolSearchExecutionType execution;

  /// The arguments for the tool search.
  final Map<String, dynamic>? arguments;

  /// Item status.
  final ItemStatus? status;

  /// Who created this item.
  final String? createdBy;

  /// Creates a [ToolSearchCallOutputItem].
  const ToolSearchCallOutputItem({
    required this.id,
    this.agent,
    this.callId,
    required this.execution,
    this.arguments,
    this.status,
    this.createdBy,
  });

  /// Creates a [ToolSearchCallOutputItem] from JSON.
  factory ToolSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return ToolSearchCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String?,
      execution: ToolSearchExecutionType.fromJson(json['execution'] as String),
      arguments: json['arguments'] as Map<String, dynamic>?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    'execution': execution.toJson(),
    if (arguments != null) 'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          mapsDeepEqual(arguments, other.arguments) &&
          status == other.status &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    mapDeepHashCode(arguments),
    status,
    createdBy,
  );

  @override
  String toString() =>
      'ToolSearchCallOutputItem(id: $id, agent: $agent, callId: $callId, execution: $execution, status: $status)';
}

/// A tool search output item containing discovered tools.
@immutable
class ToolSearchOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this tool search output.
  final String? callId;

  /// The execution type (server or client).
  final ToolSearchExecutionType execution;

  /// The tools discovered by the search.
  final List<ResponseTool> tools;

  /// Item status.
  final FunctionCallOutputStatus? status;

  /// Who created this item.
  final String? createdBy;

  /// Creates a [ToolSearchOutputItem].
  const ToolSearchOutputItem({
    required this.id,
    this.agent,
    this.callId,
    required this.execution,
    required this.tools,
    this.status,
    this.createdBy,
  });

  /// Creates a [ToolSearchOutputItem] from JSON.
  factory ToolSearchOutputItem.fromJson(Map<String, dynamic> json) {
    return ToolSearchOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String?,
      execution: ToolSearchExecutionType.fromJson(json['execution'] as String),
      tools: (json['tools'] as List)
          .map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? FunctionCallOutputStatus.fromJson(json['status'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    'execution': execution.toJson(),
    'tools': tools.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          listsEqual(tools, other.tools) &&
          status == other.status &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    Object.hashAll(tools),
    status,
    createdBy,
  );

  @override
  String toString() =>
      'ToolSearchOutputItem(id: $id, agent: $agent, callId: $callId, execution: $execution, tools: $tools, status: $status)';
}

/// A computer use tool call output item.
@immutable
class ComputerCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this computer call.
  final String callId;

  /// The action to perform (legacy singular format).
  final ComputerAction? action;

  /// The actions to perform (batched format).
  final List<ComputerAction>? actions;

  /// Pending safety checks.
  final List<Map<String, dynamic>>? pendingSafetyChecks;

  /// Item status.
  final ItemStatus? status;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// Creates a [ComputerCallOutputItem].
  const ComputerCallOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    this.action,
    this.actions,
    this.pendingSafetyChecks,
    this.status,
    this.createdBy,
  }) : assert(
         action == null || actions == null,
         'Only one of action or actions may be set, not both.',
       );

  /// Creates a [ComputerCallOutputItem] from JSON.
  factory ComputerCallOutputItem.fromJson(Map<String, dynamic> json) {
    final hasActions = json['actions'] != null;
    return ComputerCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: !hasActions && json['action'] != null
          ? ComputerAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
      actions: hasActions
          ? (json['actions'] as List)
                .map((e) => ComputerAction.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      pendingSafetyChecks: (json['pending_safety_checks'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'computer_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    if (action != null) 'action': action!.toJson(),
    if (actions != null) 'actions': actions!.map((e) => e.toJson()).toList(),
    if (pendingSafetyChecks != null)
      'pending_safety_checks': pendingSafetyChecks,
    if (status != null) 'status': status!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          listsEqual(actions, other.actions) &&
          listOfMapsDeepEqual(pendingSafetyChecks, other.pendingSafetyChecks) &&
          status == other.status &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    action,
    actions != null ? Object.hashAll(actions!) : null,
    listOfMapsHashCode(pendingSafetyChecks),
    status,
    createdBy,
  );

  @override
  String toString() =>
      'ComputerCallOutputItem(id: $id, agent: $agent, callId: $callId, action: $action, actions: $actions, status: $status, createdBy: $createdBy)';
}

/// A custom tool call item.
@immutable
class CustomToolCallItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this custom tool call.
  final String callId;

  /// The name of the custom tool being called.
  final String name;

  /// The input for the custom tool call generated by the model.
  final String input;

  /// The input parsed as a JSON map.
  ///
  /// Throws [FormatException] if [input] is not valid JSON or does not
  /// decode to a JSON object.
  Map<String, dynamic> get inputMap {
    final decoded = jsonDecode(input);
    if (decoded is! Map) {
      throw const FormatException(
        'CustomToolCallItem.input must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  /// The namespace of the custom tool being called.
  final String? namespace;

  /// Item status.
  final ItemStatus? status;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// The execution context that produced this tool call.
  final ToolCallCaller? caller;

  /// Creates a [CustomToolCallItem].
  const CustomToolCallItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.name,
    required this.input,
    this.namespace,
    this.status,
    this.createdBy,
    this.caller,
  });

  /// Creates a [CustomToolCallItem] from JSON.
  factory CustomToolCallItem.fromJson(Map<String, dynamic> json) {
    return CustomToolCallItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      name: json['name'] as String,
      input: json['input'] as String,
      namespace: json['namespace'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'name': name,
    'input': input,
    if (namespace != null) 'namespace': namespace,
    if (status != null) 'status': status!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
    if (caller != null) 'caller': caller!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          name == other.name &&
          input == other.input &&
          namespace == other.namespace &&
          status == other.status &&
          createdBy == other.createdBy &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    name,
    input,
    namespace,
    status,
    createdBy,
    caller,
  );

  @override
  String toString() =>
      'CustomToolCallItem(id: $id, agent: $agent, callId: $callId, name: $name, input: $input, namespace: $namespace, status: $status, createdBy: $createdBy, caller: $caller)';
}

/// A custom tool call output item.
@immutable
class CustomToolCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this custom tool call output.
  final String callId;

  /// The output from the custom tool call.
  final FunctionCallOutput output;

  /// The status of the item.
  final FunctionCallOutputStatus? status;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// The execution context that produced the tool call this output responds
  /// to.
  final ToolCallCaller? caller;

  /// Creates a [CustomToolCallOutputItem].
  const CustomToolCallOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.output,
    this.status,
    this.createdBy,
    this.caller,
  });

  /// Creates a [CustomToolCallOutputItem] from JSON.
  factory CustomToolCallOutputItem.fromJson(Map<String, dynamic> json) {
    return CustomToolCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      status: json['status'] != null
          ? FunctionCallOutputStatus.fromJson(json['status'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'output': output.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
    if (caller != null) 'caller': caller!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          output == other.output &&
          status == other.status &&
          createdBy == other.createdBy &&
          caller == other.caller;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, output, status, createdBy, caller);

  @override
  String toString() =>
      'CustomToolCallOutputItem(id: $id, agent: $agent, callId: $callId, output: $output, status: $status, createdBy: $createdBy, caller: $caller)';
}

/// An additional tools output item.
///
/// Surfaces the additional tool definitions that were made available at this
/// point in the conversation.
@immutable
class AdditionalToolsOutputItem extends OutputItem {
  /// The unique ID of the additional tools item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The role that provided the additional tools.
  final MessageRole role;

  /// The additional tool definitions made available at this item.
  final List<ResponseTool> tools;

  /// Creates an [AdditionalToolsOutputItem].
  const AdditionalToolsOutputItem({
    required this.id,
    this.agent,
    required this.role,
    required this.tools,
  });

  /// Creates an [AdditionalToolsOutputItem] from JSON.
  factory AdditionalToolsOutputItem.fromJson(Map<String, dynamic> json) {
    return AdditionalToolsOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      role: MessageRole.fromJson(json['role'] as String),
      tools: (json['tools'] as List)
          .map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'additional_tools',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'role': role.toJson(),
    'tools': tools.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalToolsOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          role == other.role &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(id, agent, role, Object.hashAll(tools));

  @override
  String toString() =>
      'AdditionalToolsOutputItem(id: $id, agent: $agent, role: $role, tools: $tools)';
}

/// Programmatic tool calling source code, as an output item.
///
/// Mirrors the `Program` schema.
@immutable
class ProgramOutputItemResponse extends OutputItem {
  /// The unique ID of the program item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The stable call ID of the program item.
  final String callId;

  /// The JavaScript source executed by programmatic tool calling.
  final String code;

  /// Opaque program replay fingerprint that must be round-tripped.
  final String fingerprint;

  /// Creates a [ProgramOutputItemResponse].
  const ProgramOutputItemResponse({
    required this.id,
    this.agent,
    required this.callId,
    required this.code,
    required this.fingerprint,
  });

  /// Creates a [ProgramOutputItemResponse] from JSON.
  factory ProgramOutputItemResponse.fromJson(Map<String, dynamic> json) {
    return ProgramOutputItemResponse(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      code: json['code'] as String,
      fingerprint: json['fingerprint'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'program',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'code': code,
    'fingerprint': fingerprint,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramOutputItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          code == other.code &&
          fingerprint == other.fingerprint;

  @override
  int get hashCode => Object.hash(id, agent, callId, code, fingerprint);

  @override
  String toString() =>
      'ProgramOutputItemResponse(id: $id, agent: $agent, callId: $callId, code: $code, fingerprint: $fingerprint)';
}

/// The result of a programmatic tool calling execution, as an output item.
///
/// Mirrors the `ProgramOutput` schema.
@immutable
class ProgramOutputResultItem extends OutputItem {
  /// The unique ID of the program output item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID of the program item.
  final String callId;

  /// The result produced by the program item.
  final String result;

  /// The terminal status of the program output item.
  final ProgramOutputStatus status;

  /// Creates a [ProgramOutputResultItem].
  const ProgramOutputResultItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.result,
    required this.status,
  });

  /// Creates a [ProgramOutputResultItem] from JSON.
  factory ProgramOutputResultItem.fromJson(Map<String, dynamic> json) {
    return ProgramOutputResultItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      result: json['result'] as String,
      status: ProgramOutputStatus.fromJson(json['status'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'program_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'result': result,
    'status': status.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramOutputResultItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          result == other.result &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, agent, callId, result, status);

  @override
  String toString() =>
      'ProgramOutputResultItem(id: $id, agent: $agent, callId: $callId, result: $result, status: $status)';
}

/// A message routed between agents, as an output item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the `BetaAgentMessage`
/// schema.
@immutable
class AgentMessageOutputItem extends OutputItem {
  /// The unique ID of the agent message.
  final String id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The sending agent identity.
  final String author;

  /// The destination agent identity.
  final String recipient;

  /// Encrypted content sent between agents.
  final List<OutputContent> content;

  /// Creates an [AgentMessageOutputItem].
  const AgentMessageOutputItem({
    required this.id,
    this.agent,
    required this.author,
    required this.recipient,
    required this.content,
  });

  /// Creates an [AgentMessageOutputItem] from JSON.
  factory AgentMessageOutputItem.fromJson(Map<String, dynamic> json) {
    return AgentMessageOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      author: json['author'] as String,
      recipient: json['recipient'] as String,
      content: (json['content'] as List)
          .map((e) => OutputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'agent_message',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'author': author,
    'recipient': recipient,
    'content': content.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentMessageOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          author == other.author &&
          recipient == other.recipient &&
          listsEqual(content, other.content);

  @override
  int get hashCode =>
      Object.hash(id, agent, author, recipient, Object.hashAll(content));

  @override
  String toString() =>
      'AgentMessageOutputItem(id: $id, agent: $agent, author: $author, recipient: $recipient, content: $content)';
}

/// A multi-agent action call, as an output item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the `BetaMultiAgentCall`
/// schema.
@immutable
class MultiAgentCallOutputItemResponse extends OutputItem {
  /// The unique ID of the multi-agent call item.
  final String id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The unique ID linking this call to its output.
  final String callId;

  /// The multi-agent action to execute.
  final MultiAgentAction action;

  /// The JSON string of arguments generated for the action.
  final String arguments;

  /// Creates a [MultiAgentCallOutputItemResponse].
  const MultiAgentCallOutputItemResponse({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.arguments,
  });

  /// Creates a [MultiAgentCallOutputItemResponse] from JSON.
  factory MultiAgentCallOutputItemResponse.fromJson(Map<String, dynamic> json) {
    return MultiAgentCallOutputItemResponse(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: MultiAgentAction.fromJson(json['action'] as String),
      arguments: json['arguments'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'multi_agent_call',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentCallOutputItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(id, agent, callId, action, arguments);

  @override
  String toString() =>
      'MultiAgentCallOutputItemResponse(id: $id, agent: $agent, callId: $callId, action: $action, arguments: $arguments)';
}

/// The output of a multi-agent action call, as an output item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaMultiAgentCallOutput` schema.
@immutable
class MultiAgentCallOutputResultItem extends OutputItem {
  /// The unique ID of the multi-agent call output item.
  final String id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The unique ID of the multi-agent call.
  final String callId;

  /// The multi-agent action that produced this result.
  final MultiAgentAction action;

  /// Text output returned by the multi-agent action.
  final List<OutputTextContent> output;

  /// Creates a [MultiAgentCallOutputResultItem].
  const MultiAgentCallOutputResultItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.output,
  });

  /// Creates a [MultiAgentCallOutputResultItem] from JSON.
  factory MultiAgentCallOutputResultItem.fromJson(Map<String, dynamic> json) {
    return MultiAgentCallOutputResultItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: MultiAgentAction.fromJson(json['action'] as String),
      output: (json['output'] as List)
          .map((e) => OutputTextContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'multi_agent_call_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'output': output.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentCallOutputResultItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          listsEqual(output, other.output);

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, action, Object.hashAll(output));

  @override
  String toString() =>
      'MultiAgentCallOutputResultItem(id: $id, agent: $agent, callId: $callId, action: $action, output: $output)';
}
