import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../config/function_call_output_status.dart';
import '../config/item_status.dart';
import '../config/message_phase.dart';
import '../config/message_role.dart';
import '../config/program_output_status.dart';
import '../config/tool_search_execution_type.dart';
import '../config/web_search_call_status.dart';
import '../content/output_content.dart';
import '../multi_agent/agent_tag.dart';
import '../multi_agent/multi_agent_action.dart';
import '../tools/computer_action.dart';
import '../tools/response_tool.dart';
import '../tools/shell_tool_environment.dart';
import '../tools/tool_call_caller.dart';
import 'item.dart';
import 'shell_call_helpers.dart';
import 'tool_search_item_helpers.dart';
import 'web_search_action.dart';
import 'web_search_result.dart';

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
/// - [McpListToolsOutputItem] - MCP tool discovery
/// - [McpApprovalRequestOutputItem] - MCP approval requests
/// - [McpApprovalResponseOutputItem] - MCP approval responses
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
      'mcp_list_tools' => McpListToolsOutputItem.fromJson(json),
      'mcp_approval_request' => McpApprovalRequestOutputItem.fromJson(json),
      'mcp_approval_response' => McpApprovalResponseOutputItem.fromJson(json),
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
  /// The fixed discriminator for this call item.
  String get type => 'function_call';

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

  /// Whether this call may finish after the model continues working.
  ///
  /// Omitted for calls whose execution mode was not supplied.
  final bool? async;

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
    this.async,
  });

  /// Creates a [FunctionCallOutputItemResponse] from JSON.
  factory FunctionCallOutputItemResponse.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'function_call', 'FunctionCallOutputItemResponse');
    return FunctionCallOutputItemResponse(
      async: optionalJsonBool(json, 'async', 'FunctionCallOutputItemResponse'),
      id: requireJsonString(json['id'], 'FunctionCallOutputItemResponse.id'),
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: requireJsonString(
        json['call_id'],
        'FunctionCallOutputItemResponse.call_id',
      ),
      name: requireJsonString(
        json['name'],
        'FunctionCallOutputItemResponse.name',
      ),
      arguments: requireJsonString(
        json['arguments'],
        'FunctionCallOutputItemResponse.arguments',
      ),
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
    if (async != null) 'async': async,
  };

  /// Converts to a [FunctionCallItem] for use as input.
  FunctionCallItem toFunctionCallItem() => FunctionCallItem(
    id: id,
    agent: agent,
    callId: callId,
    name: name,
    arguments: arguments,
    status: status,
    namespace: namespace,
    caller: caller,
    async: async,
  );

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  FunctionCallOutputItemResponse copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    String? name,
    String? arguments,
    Object? status = unsetCopyWithValue,
    Object? namespace = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => FunctionCallOutputItemResponse(
    id: id ?? this.id,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    status: status == unsetCopyWithValue ? this.status : status as ItemStatus?,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    createdBy: createdBy == unsetCopyWithValue
        ? this.createdBy
        : createdBy as String?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
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
          caller == other.caller &&
          async == other.async;

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
    async,
  );

  @override
  String toString() =>
      'FunctionCallOutputItemResponse(id: $id, agent: $agent, callId: $callId, name: $name, arguments: <redacted>, status: $status, namespace: $namespace, createdBy: $createdBy, caller: $caller, async: $async)';
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
  /// The fixed item discriminator.
  String get type => 'web_search_call';

  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Web search status, including searching and failed states.
  ///
  /// May be null for legacy or partial responses.
  final WebSearchCallStatus? status;

  /// The action performed by the web search tool, when supplied.
  final WebSearchAction? action;

  /// Results included with `web_search_call.results`.
  ///
  /// Constructor lists are caller-owned for const compatibility and must not be
  /// mutated after construction. JSON parsing returns an unmodifiable list.
  final List<WebSearchResult>? results;

  /// Creates a [WebSearchCallOutputItem].
  const WebSearchCallOutputItem({
    required this.id,
    this.agent,
    this.status,
    this.action,
    this.results,
  });

  /// Creates a [WebSearchCallOutputItem] from JSON.
  factory WebSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'WebSearchCallOutputItem';
    requireJsonType(json, 'web_search_call', context);
    final agent = json['agent'] == null
        ? null
        : requireJsonObject(json['agent'], '$context.agent');
    final rawResults = json['results'];
    if (json.containsKey('results') && rawResults is! List) {
      throw const FormatException('$context.results: expected an array');
    }
    return WebSearchCallOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: agent == null
          ? null
          : AgentTag(
              agentName: requireJsonString(
                agent['agent_name'],
                '$context.agent.agent_name',
              ),
            ),
      status: json['status'] != null
          ? WebSearchCallStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            )
          : null,
      action: json.containsKey('action')
          ? WebSearchAction.fromJson(
              requireJsonObject(json['action'], '$context.action'),
              context: '$context.action',
            )
          : null,
      results: rawResults is List
          ? List.unmodifiable([
              for (var i = 0; i < rawResults.length; i++)
                WebSearchResult.fromJson(
                  requireJsonObject(rawResults[i], '$context.results[$i]'),
                  context: '$context.results[$i]',
                ),
            ])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (action != null) 'action': action!.toJson(),
    if (results != null) 'results': results!.map((e) => e.toJson()).toList(),
  };

  /// Converts to request input while preserving every web-search call field.
  WebSearchCallItem toWebSearchCallItem() => WebSearchCallItem(
    id: id,
    agent: agent,
    status: status,
    action: action,
    results: results,
  );

  /// Copies every field; explicit null clears an optional value.
  WebSearchCallOutputItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? action = unsetCopyWithValue,
    Object? results = unsetCopyWithValue,
  }) => WebSearchCallOutputItem(
    id: id ?? this.id,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    status: status == unsetCopyWithValue
        ? this.status
        : status as WebSearchCallStatus?,
    action: action == unsetCopyWithValue
        ? this.action
        : action as WebSearchAction?,
    results: results == unsetCopyWithValue
        ? this.results
        : results as List<WebSearchResult>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          status == other.status &&
          action == other.action &&
          listsEqual(results, other.results);

  @override
  int get hashCode => Object.hash(id, agent, status, action, listHash(results));

  @override
  String toString() =>
      'WebSearchCallOutputItem(type: $type, id: $id, agent: $agent, status: $status, action: $action, results: ${results == null ? 'null' : '${results!.length} items'})';
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

/// A returned shell call with the exact resource contract.
@immutable
class ShellCallOutputItem extends OutputItem {
  /// The fixed item discriminator.
  String get type => 'shell_call';

  /// Unique identifier.
  final String id;

  /// The beta agent that produced this item; provider null normalizes to omission.
  final AgentTag? agent;

  /// The shell call identifier.
  final String callId;

  /// Commands and execution limits returned by the service.
  final ShellCallAction action;

  /// The status of this shell item.
  final ItemStatus status;

  /// Returned environment. This required JSON key may be null.
  final ShellEnvironment? environment;

  /// Optional nullable execution context.
  final ToolCallCaller? caller;

  /// Optional creator identifier. Explicit JSON null is invalid.
  final String? createdBy;

  /// Creates a [ShellCallOutputItem].
  const ShellCallOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.status,
    required this.environment,
    this.caller,
    this.createdBy,
  });

  /// Creates a [ShellCallOutputItem] from JSON.
  factory ShellCallOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallOutputItem';
    requireJsonType(json, 'shell_call', context);
    if (!json.containsKey('environment')) {
      throw const FormatException('$context.environment: required key missing');
    }
    return ShellCallOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: shellJsonAgent(json, context),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      action: ShellCallAction.fromJson(
        requireJsonObject(json['action'], '$context.action'),
        context: '$context.action',
      ),
      status: ItemStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      environment: json['environment'] == null
          ? null
          : ShellEnvironment.fromJson(
              requireJsonObject(json['environment'], '$context.environment'),
              context: '$context.environment',
            ),
      caller: shellJsonCaller(json, context),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'status': status.toJson(),
    'environment': environment?.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallOutputItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ShellCallAction? action,
    ItemStatus? status,
    Object? environment = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallOutputItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    action: action ?? this.action,
    status: status ?? this.status,
    environment: identical(environment, unsetCopyWithValue)
        ? this.environment
        : environment as ShellEnvironment?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  /// Converts to writable input, omitting returned-only creator metadata.
  ShellCallInputItem toShellCallInputItem() => ShellCallInputItem(
    id: id,
    agent: agent,
    callId: callId,
    action: action.toInput(),
    status: status,
    environment: environment?.toInput(),
    caller: caller,
  );

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
          caller == other.caller &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    action,
    status,
    environment,
    caller,
    createdBy,
  );

  @override
  String toString() =>
      'ShellCallOutputItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, action: $action, status: $status, environment: $environment, caller: ${caller == null ? 'null' : caller.runtimeType}, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
}

/// Commands and limits on a returned shell call.
///
/// Constructor lists are caller-owned for const compatibility. Parsed commands
/// are unmodifiable. Both nullable limits are required JSON keys.
@immutable
class ShellCallAction {
  /// Ordered commands to execute.
  final List<String> commands;

  /// Required nullable wall-clock timeout in milliseconds.
  final int? timeoutMs;

  /// Required nullable maximum output length.
  final int? maxOutputLength;

  /// Creates a [ShellCallAction]. Pass null explicitly for unset limits.
  const ShellCallAction({
    required this.commands,
    required this.timeoutMs,
    required this.maxOutputLength,
  });

  /// Creates a [ShellCallAction] from JSON.
  factory ShellCallAction.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallAction',
  }) => ShellCallAction(
    commands: shellJsonList(
      json['commands'],
      '$context.commands',
      requireJsonString,
    ),
    timeoutMs: shellRequiredNullableInt(json, 'timeout_ms', context),
    maxOutputLength: shellRequiredNullableInt(
      json,
      'max_output_length',
      context,
    ),
  );

  /// Converts to JSON, retaining both required nullable keys.
  Map<String, dynamic> toJson() => {
    'commands': commands,
    'timeout_ms': timeoutMs,
    'max_output_length': maxOutputLength,
  };

  /// Converts to the writable optional-limit action shape.
  ShellCallActionInput toInput() => ShellCallActionInput(
    commands: commands,
    timeoutMs: timeoutMs,
    maxOutputLength: maxOutputLength,
  );

  /// Creates a copy; explicit null clears either nullable limit.
  ShellCallAction copyWith({
    List<String>? commands,
    Object? timeoutMs = unsetCopyWithValue,
    Object? maxOutputLength = unsetCopyWithValue,
  }) => ShellCallAction(
    commands: commands ?? this.commands,
    timeoutMs: identical(timeoutMs, unsetCopyWithValue)
        ? this.timeoutMs
        : timeoutMs as int?,
    maxOutputLength: identical(maxOutputLength, unsetCopyWithValue)
        ? this.maxOutputLength
        : maxOutputLength as int?,
  );
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
      'ShellCallAction(commands: ${commands.length} commands, timeoutMs: $timeoutMs, maxOutputLength: $maxOutputLength)';
}

/// Returned shell environment: [LocalShellEnvironment],
/// [ContainerReferenceEnvironment], or [UnknownShellEnvironment].
sealed class ShellEnvironment {
  /// Creates a [ShellEnvironment].
  const ShellEnvironment();

  /// A local returned environment, which has no skills.
  const factory ShellEnvironment.local() = LocalShellEnvironment;

  /// An existing container.
  const factory ShellEnvironment.containerReference({
    required String containerId,
  }) = ContainerReferenceEnvironment;

  /// Creates a [ShellEnvironment] from JSON.
  factory ShellEnvironment.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellEnvironment',
  }) {
    final type = requireJsonString(json['type'], '$context.type');
    return switch (type) {
      'local' => LocalShellEnvironment.fromJson(json, context: context),
      'container_reference' => ContainerReferenceEnvironment.fromJson(
        json,
        context: context,
      ),
      'container_auto' => throw FormatException(
        '$context.type: container_auto is not a returned shell environment',
      ),
      _ => UnknownShellEnvironment(type: type, rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  /// Converts to the writable local/reference request environment shape.
  ShellToolEnvironment toInput();
}

/// A returned local environment; local skills belong only to request shapes.
@immutable
class LocalShellEnvironment extends ShellEnvironment {
  /// The fixed discriminator.
  String get type => 'local';

  /// Creates a [LocalShellEnvironment].
  const LocalShellEnvironment();

  /// Creates a [LocalShellEnvironment] from JSON.
  factory LocalShellEnvironment.fromJson(
    Map<String, dynamic> json, {
    String context = 'LocalShellEnvironment',
  }) {
    requireJsonType(json, 'local', context);
    return const LocalShellEnvironment();
  }
  @override
  Map<String, dynamic> toJson() => {'type': type};
  @override
  LocalShellToolEnvironment toInput() => LocalShellToolEnvironment();

  /// Creates a copy.
  LocalShellEnvironment copyWith() => const LocalShellEnvironment();
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellEnvironment && runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
  @override
  String toString() => 'LocalShellEnvironment()';
}

/// A returned reference to an existing container.
@immutable
class ContainerReferenceEnvironment extends ShellEnvironment {
  /// The fixed discriminator.
  String get type => 'container_reference';

  /// The container identifier.
  final String containerId;

  /// Creates a [ContainerReferenceEnvironment].
  const ContainerReferenceEnvironment({required this.containerId});

  /// Creates a [ContainerReferenceEnvironment] from JSON.
  factory ContainerReferenceEnvironment.fromJson(
    Map<String, dynamic> json, {
    String context = 'ContainerReferenceEnvironment',
  }) {
    requireJsonType(json, 'container_reference', context);
    return ContainerReferenceEnvironment(
      containerId: requireJsonString(
        json['container_id'],
        '$context.container_id',
      ),
    );
  }
  @override
  Map<String, dynamic> toJson() => {'type': type, 'container_id': containerId};
  @override
  ContainerReferenceShellToolEnvironment toInput() =>
      ContainerReferenceShellToolEnvironment(containerId: containerId);

  /// Creates a copy with a replacement container ID.
  ContainerReferenceEnvironment copyWith({String? containerId}) =>
      ContainerReferenceEnvironment(
        containerId: containerId ?? this.containerId,
      );
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

/// A future returned shell environment with immutable JSON metadata.
@immutable
class UnknownShellEnvironment extends ShellEnvironment {
  /// The future discriminator.
  final String type;

  /// A recursively unmodifiable snapshot including the current discriminator.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownShellEnvironment].
  UnknownShellEnvironment({
    required this.type,
    required Map<String, dynamic> rawJson,
  }) : rawJson = freezeJsonObject({...rawJson, 'type': type}) {
    if (type == 'container_auto') {
      throw ArgumentError.value(
        type,
        'type',
        'container_auto is not a returned shell environment',
      );
    }
  }
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};
  @override
  ShellToolEnvironment toInput() => ShellToolEnvironment.fromJson(toJson());

  /// Creates a copy with replaced metadata or discriminator.
  UnknownShellEnvironment copyWith({
    String? type,
    Map<String, dynamic>? rawJson,
  }) => UnknownShellEnvironment(
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownShellEnvironment &&
          type == other.type &&
          mapsDeepEqual(rawJson, other.rawJson);
  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(rawJson));
  @override
  String toString() =>
      'UnknownShellEnvironment(type: $type, rawJson: ${rawJson.length} keys)';
}

/// A single returned shell output chunk.
@immutable
class ShellCallOutputContent {
  /// Captured standard output.
  final String stdout;

  /// Captured standard error.
  final String stderr;

  /// Exit or timeout outcome.
  final ShellCallOutcome outcome;

  /// Optional creator identifier; explicit JSON null is invalid.
  final String? createdBy;

  /// Creates a [ShellCallOutputContent].
  const ShellCallOutputContent({
    required this.stdout,
    required this.stderr,
    required this.outcome,
    this.createdBy,
  });

  /// Creates a [ShellCallOutputContent] from JSON.
  factory ShellCallOutputContent.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallOutputContent',
  }) => ShellCallOutputContent(
    stdout: requireJsonString(json['stdout'], '$context.stdout'),
    stderr: requireJsonString(json['stderr'], '$context.stderr'),
    outcome: ShellCallOutcome.fromJson(
      requireJsonObject(json['outcome'], '$context.outcome'),
      context: '$context.outcome',
    ),
    createdBy: optionalJsonString(json, 'created_by', context),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'stdout': stdout,
    'stderr': stderr,
    'outcome': outcome.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Converts to writable content, omitting returned-only creator metadata.
  ShellCallOutputContentInput toInput() => ShellCallOutputContentInput(
    stdout: stdout,
    stderr: stderr,
    outcome: outcome,
  );

  /// Creates a copy; explicit null clears the creator identifier.
  ShellCallOutputContent copyWith({
    String? stdout,
    String? stderr,
    ShellCallOutcome? outcome,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallOutputContent(
    stdout: stdout ?? this.stdout,
    stderr: stderr ?? this.stderr,
    outcome: outcome ?? this.outcome,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputContent &&
          runtimeType == other.runtimeType &&
          stdout == other.stdout &&
          stderr == other.stderr &&
          outcome == other.outcome &&
          createdBy == other.createdBy;
  @override
  int get hashCode => Object.hash(stdout, stderr, outcome, createdBy);
  @override
  String toString() =>
      'ShellCallOutputContent(stdout: ${stdout.length} chars, stderr: ${stderr.length} chars, outcome: $outcome, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
}

/// Shell outcome: [ShellCallExitOutcome], [ShellCallTimeoutOutcome],
/// or [UnknownShellCallOutcome].
sealed class ShellCallOutcome {
  /// Creates a [ShellCallOutcome].
  const ShellCallOutcome();

  /// A normal exit with the process code.
  const factory ShellCallOutcome.exit({required int exitCode}) =
      ShellCallExitOutcome;

  /// A timeout.
  const factory ShellCallOutcome.timeout() = ShellCallTimeoutOutcome;

  /// Creates a [ShellCallOutcome] from JSON.
  factory ShellCallOutcome.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallOutcome',
  }) {
    final type = requireJsonString(json['type'], '$context.type');
    return switch (type) {
      'exit' => ShellCallExitOutcome.fromJson(json, context: context),
      'timeout' => ShellCallTimeoutOutcome.fromJson(json, context: context),
      _ => UnknownShellCallOutcome(type: type, rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A completed command with its required exit code.
@immutable
class ShellCallExitOutcome extends ShellCallOutcome {
  /// The fixed discriminator.
  String get type => 'exit';

  /// Process exit code.
  final int exitCode;

  /// Creates a [ShellCallExitOutcome].
  const ShellCallExitOutcome({required this.exitCode});

  /// Creates a [ShellCallExitOutcome] from JSON.
  factory ShellCallExitOutcome.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallExitOutcome',
  }) {
    requireJsonType(json, 'exit', context);
    return ShellCallExitOutcome(
      exitCode: requireJsonInt(json['exit_code'], '$context.exit_code'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {'type': type, 'exit_code': exitCode};

  /// Creates a copy with a replacement exit code.
  ShellCallExitOutcome copyWith({int? exitCode}) =>
      ShellCallExitOutcome(exitCode: exitCode ?? this.exitCode);
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

/// A command exceeding its configured time limit.
@immutable
class ShellCallTimeoutOutcome extends ShellCallOutcome {
  /// The fixed discriminator.
  String get type => 'timeout';

  /// Creates a [ShellCallTimeoutOutcome].
  const ShellCallTimeoutOutcome();

  /// Creates a [ShellCallTimeoutOutcome] from JSON.
  factory ShellCallTimeoutOutcome.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallTimeoutOutcome',
  }) {
    requireJsonType(json, 'timeout', context);
    return const ShellCallTimeoutOutcome();
  }
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy.
  ShellCallTimeoutOutcome copyWith() => const ShellCallTimeoutOutcome();
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallTimeoutOutcome && runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
  @override
  String toString() => 'ShellCallTimeoutOutcome()';
}

/// A future shell outcome with recursively immutable raw metadata.
@immutable
class UnknownShellCallOutcome extends ShellCallOutcome {
  /// The future discriminator.
  final String type;

  /// A recursively unmodifiable JSON snapshot including the discriminator.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownShellCallOutcome].
  UnknownShellCallOutcome({
    required this.type,
    required Map<String, dynamic> rawJson,
  }) : rawJson = freezeJsonObject({...rawJson, 'type': type});
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Creates a copy with replaced discriminator or metadata.
  UnknownShellCallOutcome copyWith({
    String? type,
    Map<String, dynamic>? rawJson,
  }) => UnknownShellCallOutcome(
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownShellCallOutcome &&
          type == other.type &&
          mapsDeepEqual(rawJson, other.rawJson);
  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(rawJson));
  @override
  String toString() =>
      'UnknownShellCallOutcome(type: $type, rawJson: ${rawJson.length} keys)';
}

/// A returned shell result with the exact resource contract.
@immutable
class ShellCallOutputResultItem extends OutputItem {
  /// The fixed item discriminator.
  String get type => 'shell_call_output';

  /// Unique identifier.
  final String id;

  /// The beta agent that produced this item; provider null normalizes to omission.
  final AgentTag? agent;

  /// The shell call identifier.
  final String callId;

  /// The status of this shell item.
  final ItemStatus status;

  /// Returned output chunks. Constructor lists are caller-owned for const compatibility; parsed lists are unmodifiable.
  final List<ShellCallOutputContent> output;

  /// Output limit. This required JSON key may be null.
  final int? maxOutputLength;

  /// Optional nullable execution context.
  final ToolCallCaller? caller;

  /// Optional creator identifier. Explicit JSON null is invalid.
  final String? createdBy;

  /// Creates a [ShellCallOutputResultItem].
  const ShellCallOutputResultItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.status,
    required this.output,
    required this.maxOutputLength,
    this.caller,
    this.createdBy,
  });

  /// Creates a [ShellCallOutputResultItem] from JSON.
  factory ShellCallOutputResultItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallOutputResultItem';
    requireJsonType(json, 'shell_call_output', context);
    return ShellCallOutputResultItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: shellJsonAgent(json, context),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      status: ItemStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      output: shellJsonList(
        json['output'],
        '$context.output',
        (value, path) => ShellCallOutputContent.fromJson(
          requireJsonObject(value, path),
          context: path,
        ),
      ),
      maxOutputLength: shellRequiredNullableInt(
        json,
        'max_output_length',
        context,
      ),
      caller: shellJsonCaller(json, context),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'status': status.toJson(),
    'output': output.map((chunk) => chunk.toJson()).toList(),
    'max_output_length': maxOutputLength,
    if (caller != null) 'caller': caller!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallOutputResultItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ItemStatus? status,
    List<ShellCallOutputContent>? output,
    Object? maxOutputLength = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallOutputResultItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    status: status ?? this.status,
    output: output ?? this.output,
    maxOutputLength: identical(maxOutputLength, unsetCopyWithValue)
        ? this.maxOutputLength
        : maxOutputLength as int?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  /// Converts to writable input, omitting returned-only creator metadata.
  ShellCallOutputInputItem toShellCallOutputInputItem() =>
      ShellCallOutputInputItem(
        id: id,
        agent: agent,
        callId: callId,
        status: status,
        output: List<ShellCallOutputContentInput>.unmodifiable(
          output.map((chunk) => chunk.toInput()),
        ),
        maxOutputLength: maxOutputLength,
        caller: caller,
      );

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
          caller == other.caller &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    status,
    Object.hashAll(output),
    maxOutputLength,
    caller,
    createdBy,
  );

  @override
  String toString() =>
      'ShellCallOutputResultItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, status: $status, output: ${output.length} chunks, maxOutputLength: $maxOutputLength, caller: ${caller == null ? 'null' : caller.runtimeType}, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
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

/// A status reported by an MCP call.
enum McpCallStatus {
  /// The call is in progress.
  inProgress('in_progress'),

  /// The server is executing the call.
  calling('calling'),

  /// The call completed.
  completed('completed'),

  /// The call did not complete.
  incomplete('incomplete'),

  /// The call failed.
  failed('failed');

  /// Native JSON value.
  final String value;
  const McpCallStatus(this.value);

  /// Parses a native value.
  static McpCallStatus fromJson(String value) =>
      McpCallStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => throw FormatException('Unknown MCP call status: $value'),
      );

  /// Returns the native value.
  String toJson() => value;
}

/// An error returned by an MCP call.
sealed class McpCallError {
  /// Creates an error.
  const McpCallError();

  /// Parses a native MCP error.
  factory McpCallError.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'mcp_protocol_error' => McpProtocolError.fromJson(json),
        'mcp_tool_execution_error' => McpToolExecutionError.fromJson(json),
        'http_error' => McpHttpError.fromJson(json),
        _ => throw const FormatException('Unknown MCP call error type.'),
      };

  /// Serializes the error.
  Map<String, dynamic> toJson();
}

Object? _requiredMcpValue(Map<String, dynamic> json, String key) {
  if (!json.containsKey(key)) throw FormatException('Missing MCP field: $key');
  return toolSearchReturnedArguments({'arguments': json[key]}, 'MCP.$key');
}

Object? _optionalMcpValue(Object? value) =>
    toolSearchReturnedArguments({'arguments': value}, 'MCP');

/// An MCP protocol error.
@immutable
class McpProtocolError extends McpCallError {
  /// The native `code` field.
  final int code;

  /// The native `message` field.
  final String message;

  /// Creates a [McpProtocolError].
  const McpProtocolError({required this.code, required this.message});

  /// Parses native JSON.
  factory McpProtocolError.fromJson(Map<String, dynamic> json) {
    const context = 'McpProtocolError';
    requireJsonType(json, 'mcp_protocol_error', context);

    return McpProtocolError(
      code: requireJsonInt(json['code'], '$context.code'),
      message: requireJsonString(json['message'], '$context.message'),
    );
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_protocol_error',
    'code': code,
    'message': message,
  };

  /// Copies this value with updated fields.
  McpProtocolError copyWith({int? code, String? message}) => McpProtocolError(
    code: code ?? this.code,
    message: message ?? this.message,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpProtocolError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;
  @override
  int get hashCode => Object.hashAll([code, message]);
  @override
  String toString() => 'McpProtocolError(code: $code)';
}

/// An HTTP error from an MCP server.
@immutable
class McpHttpError extends McpCallError {
  /// The native `code` field.
  final int code;

  /// The native `message` field.
  final String message;

  /// Creates a [McpHttpError].
  const McpHttpError({required this.code, required this.message});

  /// Parses native JSON.
  factory McpHttpError.fromJson(Map<String, dynamic> json) {
    const context = 'McpHttpError';
    requireJsonType(json, 'http_error', context);

    return McpHttpError(
      code: requireJsonInt(json['code'], '$context.code'),
      message: requireJsonString(json['message'], '$context.message'),
    );
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'http_error',
    'code': code,
    'message': message,
  };

  /// Copies this value with updated fields.
  McpHttpError copyWith({int? code, String? message}) =>
      McpHttpError(code: code ?? this.code, message: message ?? this.message);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpHttpError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;
  @override
  int get hashCode => Object.hashAll([code, message]);
  @override
  String toString() => 'McpHttpError(code: $code)';
}

/// An MCP tool execution error.
@immutable
class McpToolExecutionError extends McpCallError {
  /// The native `content` field.
  final Object? content;

  /// Creates a [McpToolExecutionError].
  /// Caller-owned collections must not be mutated after construction.
  /// Parsed JSON is an unmodifiable snapshot.
  const McpToolExecutionError({required this.content});

  /// Parses native JSON.
  factory McpToolExecutionError.fromJson(Map<String, dynamic> json) {
    const context = 'McpToolExecutionError';
    requireJsonType(json, 'mcp_tool_execution_error', context);

    return McpToolExecutionError(content: _requiredMcpValue(json, 'content'));
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_tool_execution_error',
    'content': content,
  };

  /// Copies this value; nullable fields can be explicitly cleared.
  McpToolExecutionError copyWith({Object? content = unsetCopyWithValue}) =>
      McpToolExecutionError(
        content: content == unsetCopyWithValue ? this.content : content,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolExecutionError &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual({'v': content}, {'v': other.content});
  @override
  int get hashCode => Object.hashAll([
    mapDeepHashCode({'v': content}),
  ]);
  @override
  String toString() => 'McpToolExecutionError(hasContent: ${content != null})';
}

/// An MCP call returned by the Responses API.
@immutable
class McpCallOutputItem extends OutputItem {
  /// The native `id` field.
  final String id;

  /// The native `arguments` field.
  final String arguments;

  /// The native `name` field.
  final String name;

  /// The native `server_label` field.
  final String serverLabel;

  /// The native `agent` field.
  final AgentTag? agent;

  /// The native `approval_request_id` field.
  final String? approvalRequestId;

  /// The native `error` field.
  final McpCallError? error;

  /// The native `output` field.
  final String? output;

  /// The native `status` field.
  final McpCallStatus? status;

  /// Creates a [McpCallOutputItem].
  const McpCallOutputItem({
    required this.id,
    required this.arguments,
    required this.name,
    required this.serverLabel,
    this.agent,
    this.approvalRequestId,
    this.error,
    this.output,
    this.status,
  });

  /// Parses native JSON.
  factory McpCallOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'McpCallOutputItem';
    requireJsonType(json, 'mcp_call', context);

    return McpCallOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      arguments: requireJsonString(json['arguments'], '$context.arguments'),
      name: requireJsonString(json['name'], '$context.name'),
      serverLabel: requireJsonString(
        json['server_label'],
        '$context.server_label',
      ),
      agent: toolSearchJsonAgent(json, context, nullable: true),
      approvalRequestId: optionalJsonString(
        json,
        'approval_request_id',
        context,
        nullable: true,
      ),
      error: json['error'] == null
          ? null
          : McpCallError.fromJson(
              requireJsonObject(json['error'], '$context.error'),
            ),
      output: optionalJsonString(json, 'output', context, nullable: true),
      status: json['status'] == null
          ? null
          : McpCallStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            ),
    );
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_call',
    'id': id,
    'arguments': arguments,
    'name': name,
    'server_label': serverLabel,
    if (agent != null) 'agent': agent!.toJson(),
    if (approvalRequestId != null) 'approval_request_id': approvalRequestId,
    if (error != null) 'error': error!.toJson(),
    if (output != null) 'output': output,
    if (status != null) 'status': status!.toJson(),
  };

  /// Copies this value; nullable fields can be explicitly cleared.
  McpCallOutputItem copyWith({
    String? id,
    String? arguments,
    String? name,
    String? serverLabel,
    Object? agent = unsetCopyWithValue,
    Object? approvalRequestId = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Object? output = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) => McpCallOutputItem(
    id: id ?? this.id,
    arguments: arguments ?? this.arguments,
    name: name ?? this.name,
    serverLabel: serverLabel ?? this.serverLabel,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    approvalRequestId: approvalRequestId == unsetCopyWithValue
        ? this.approvalRequestId
        : approvalRequestId as String?,
    error: error == unsetCopyWithValue ? this.error : error as McpCallError?,
    output: output == unsetCopyWithValue ? this.output : output as String?,
    status: status == unsetCopyWithValue
        ? this.status
        : status as McpCallStatus?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          arguments == other.arguments &&
          name == other.name &&
          serverLabel == other.serverLabel &&
          agent == other.agent &&
          approvalRequestId == other.approvalRequestId &&
          error == other.error &&
          output == other.output &&
          status == other.status;
  @override
  int get hashCode => Object.hashAll([
    id,
    arguments,
    name,
    serverLabel,
    agent,
    approvalRequestId,
    error,
    output,
    status,
  ]);
  @override
  String toString() =>
      'McpCallOutputItem(status: $status, hasError: ${error != null})';
}

/// A discovered MCP tool and its input schema.
@immutable
class McpToolDescriptor {
  /// The native `name` field.
  final String name;

  /// The native `input_schema` field.
  final Object? inputSchema;

  /// The native `annotations` field.
  final Object? annotations;

  /// The native `description` field.
  final String? description;

  /// Creates a [McpToolDescriptor].
  /// Caller-owned collections must not be mutated after construction.
  /// Parsed JSON is an unmodifiable snapshot.
  const McpToolDescriptor({
    required this.name,
    required this.inputSchema,
    this.annotations,
    this.description,
  });

  /// Parses native JSON.
  factory McpToolDescriptor.fromJson(Map<String, dynamic> json) {
    const context = 'McpToolDescriptor';

    return McpToolDescriptor(
      name: requireJsonString(json['name'], '$context.name'),
      inputSchema: _requiredMcpValue(json, 'input_schema'),
      annotations: _optionalMcpValue(json['annotations']),
      description: optionalJsonString(
        json,
        'description',
        context,
        nullable: true,
      ),
    );
  }

  /// Serializes native JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'input_schema': inputSchema,
    if (annotations != null) 'annotations': annotations,
    if (description != null) 'description': description,
  };

  /// Copies this value; nullable fields can be explicitly cleared.
  McpToolDescriptor copyWith({
    String? name,
    Object? inputSchema = unsetCopyWithValue,
    Object? annotations = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
  }) => McpToolDescriptor(
    name: name ?? this.name,
    inputSchema: inputSchema == unsetCopyWithValue
        ? this.inputSchema
        : inputSchema,
    annotations: annotations == unsetCopyWithValue
        ? this.annotations
        : annotations,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolDescriptor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mapsDeepEqual({'v': inputSchema}, {'v': other.inputSchema}) &&
          mapsDeepEqual({'v': annotations}, {'v': other.annotations}) &&
          description == other.description;
  @override
  int get hashCode => Object.hashAll([
    name,
    mapDeepHashCode({'v': inputSchema}),
    mapDeepHashCode({'v': annotations}),
    description,
  ]);
  @override
  String toString() =>
      'McpToolDescriptor(hasDescription: ${description != null})';
}

/// A discovered list of MCP tools.
@immutable
class McpListToolsOutputItem extends OutputItem {
  /// The native `id` field.
  final String id;

  /// The native `server_label` field.
  final String serverLabel;

  /// The native `tools` field.
  final List<McpToolDescriptor> tools;

  /// The native `agent` field.
  final AgentTag? agent;

  /// The native `error` field.
  final String? error;

  /// Creates a [McpListToolsOutputItem].
  /// Caller-owned collections must not be mutated after construction.
  /// Parsed JSON is an unmodifiable snapshot.
  const McpListToolsOutputItem({
    required this.id,
    required this.serverLabel,
    required this.tools,
    this.agent,
    this.error,
  });

  /// Parses native JSON.
  factory McpListToolsOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'McpListToolsOutputItem';
    requireJsonType(json, 'mcp_list_tools', context);
    final rawTools = json['tools'];
    if (rawTools is! List) {
      throw const FormatException('$context.tools: expected an array');
    }
    return McpListToolsOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      serverLabel: requireJsonString(
        json['server_label'],
        '$context.server_label',
      ),
      tools: List<McpToolDescriptor>.unmodifiable(
        rawTools.map(
          (e) => McpToolDescriptor.fromJson(
            requireJsonObject(e, '$context.tools'),
          ),
        ),
      ),
      agent: toolSearchJsonAgent(json, context, nullable: true),
      error: optionalJsonString(json, 'error', context, nullable: true),
    );
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_list_tools',
    'id': id,
    'server_label': serverLabel,
    'tools': tools.map((e) => e.toJson()).toList(),
    if (agent != null) 'agent': agent!.toJson(),
    if (error != null) 'error': error,
  };

  /// Copies this value; nullable fields can be explicitly cleared.
  McpListToolsOutputItem copyWith({
    String? id,
    String? serverLabel,
    List<McpToolDescriptor>? tools,
    Object? agent = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
  }) => McpListToolsOutputItem(
    id: id ?? this.id,
    serverLabel: serverLabel ?? this.serverLabel,
    tools: tools ?? this.tools,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    error: error == unsetCopyWithValue ? this.error : error as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpListToolsOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverLabel == other.serverLabel &&
          listsEqual(tools, other.tools) &&
          agent == other.agent &&
          error == other.error;
  @override
  int get hashCode =>
      Object.hashAll([id, serverLabel, listHash(tools), agent, error]);
  @override
  String toString() =>
      'McpListToolsOutputItem(toolCount: ${tools.length}, hasError: ${error != null})';
}

/// A provider request for approval of an MCP tool call.
@immutable
class McpApprovalRequestOutputItem extends OutputItem {
  /// The native `id` field.
  final String id;

  /// The native `arguments` field.
  final String arguments;

  /// The native `name` field.
  final String name;

  /// The native `server_label` field.
  final String serverLabel;

  /// The native `agent` field.
  final AgentTag? agent;

  /// Creates a [McpApprovalRequestOutputItem].
  const McpApprovalRequestOutputItem({
    required this.id,
    required this.arguments,
    required this.name,
    required this.serverLabel,
    this.agent,
  });

  /// Parses native JSON.
  factory McpApprovalRequestOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'McpApprovalRequestOutputItem';
    requireJsonType(json, 'mcp_approval_request', context);

    return McpApprovalRequestOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      arguments: requireJsonString(json['arguments'], '$context.arguments'),
      name: requireJsonString(json['name'], '$context.name'),
      serverLabel: requireJsonString(
        json['server_label'],
        '$context.server_label',
      ),
      agent: toolSearchJsonAgent(json, context, nullable: true),
    );
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_approval_request',
    'id': id,
    'arguments': arguments,
    'name': name,
    'server_label': serverLabel,
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Copies this value; nullable fields can be explicitly cleared.
  McpApprovalRequestOutputItem copyWith({
    String? id,
    String? arguments,
    String? name,
    String? serverLabel,
    Object? agent = unsetCopyWithValue,
  }) => McpApprovalRequestOutputItem(
    id: id ?? this.id,
    arguments: arguments ?? this.arguments,
    name: name ?? this.name,
    serverLabel: serverLabel ?? this.serverLabel,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpApprovalRequestOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          arguments == other.arguments &&
          name == other.name &&
          serverLabel == other.serverLabel &&
          agent == other.agent;
  @override
  int get hashCode => Object.hashAll([id, arguments, name, serverLabel, agent]);
  @override
  String toString() => 'McpApprovalRequestOutputItem(pending: true)';
}

/// A provider echo of an MCP approval decision.
@immutable
class McpApprovalResponseOutputItem extends OutputItem {
  /// The native `id` field.
  final String id;

  /// The native `approval_request_id` field.
  final String approvalRequestId;

  /// The native `approve` field.
  final bool approve;

  /// The native `agent` field.
  final AgentTag? agent;

  /// The native `reason` field.
  final String? reason;

  /// Creates a [McpApprovalResponseOutputItem].
  const McpApprovalResponseOutputItem({
    required this.id,
    required this.approvalRequestId,
    required this.approve,
    this.agent,
    this.reason,
  });

  /// Parses native JSON.
  factory McpApprovalResponseOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'McpApprovalResponseOutputItem';
    requireJsonType(json, 'mcp_approval_response', context);
    final approve = json['approve'];
    if (approve is! bool) {
      throw const FormatException('$context.approve: expected a boolean');
    }
    return McpApprovalResponseOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      approvalRequestId: requireJsonString(
        json['approval_request_id'],
        '$context.approval_request_id',
      ),
      approve: approve,
      agent: toolSearchJsonAgent(json, context, nullable: true),
      reason: optionalJsonString(json, 'reason', context, nullable: true),
    );
  }

  /// Serializes native JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_approval_response',
    'id': id,
    'approval_request_id': approvalRequestId,
    'approve': approve,
    if (agent != null) 'agent': agent!.toJson(),
    if (reason != null) 'reason': reason,
  };

  /// Copies this value; nullable fields can be explicitly cleared.
  McpApprovalResponseOutputItem copyWith({
    String? id,
    String? approvalRequestId,
    bool? approve,
    Object? agent = unsetCopyWithValue,
    Object? reason = unsetCopyWithValue,
  }) => McpApprovalResponseOutputItem(
    id: id ?? this.id,
    approvalRequestId: approvalRequestId ?? this.approvalRequestId,
    approve: approve ?? this.approve,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    reason: reason == unsetCopyWithValue ? this.reason : reason as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpApprovalResponseOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          approvalRequestId == other.approvalRequestId &&
          approve == other.approve &&
          agent == other.agent &&
          reason == other.reason;
  @override
  int get hashCode =>
      Object.hashAll([id, approvalRequestId, approve, agent, reason]);
  @override
  String toString() => 'McpApprovalResponseOutputItem(approved: $approve)';
}

/// A tool search call output item.
@immutable
class ToolSearchCallOutputItem extends OutputItem {
  /// The fixed item discriminator.
  String get type => 'tool_search_call';

  /// Unique identifier.
  final String id;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The search call identifier; returned items always serialize its key.
  final String? callId;

  /// The server or client execution type.
  final ToolSearchExecutionType execution;

  /// Search arguments. Returned arguments can be any JSON value.
  final Object? arguments;

  /// The item status.
  final ItemStatus status;

  /// The actor that created this item, when provided.
  final String? createdBy;

  /// Creates a [ToolSearchCallOutputItem].
  ///
  /// Const construction retains caller-owned collections. Do not mutate them
  /// while this value is used as a map key or set member. Parsed collections
  /// are recursively unmodifiable snapshots.
  const ToolSearchCallOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.execution,
    required this.arguments,
    required this.status,
    this.createdBy,
  });

  /// Creates a [ToolSearchCallOutputItem] from contextual tool-search JSON.
  factory ToolSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ToolSearchCallOutputItem';
    requireJsonType(json, 'tool_search_call', context);
    return ToolSearchCallOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: toolSearchJsonAgent(json, context),
      callId: toolSearchRequiredCallId(json, context),
      execution: ToolSearchExecutionType.fromJson(
        requireJsonString(json['execution'], '$context.execution'),
      ),
      arguments: toolSearchReturnedArguments(json, context),
      status: ItemStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'execution': execution.toJson(),
    'arguments': arguments,
    'status': status.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy with nullable fields explicitly clearable.
  ToolSearchCallOutputItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? callId = unsetCopyWithValue,
    ToolSearchExecutionType? execution,
    Object? arguments = unsetCopyWithValue,
    ItemStatus? status,
    Object? createdBy = unsetCopyWithValue,
  }) => ToolSearchCallOutputItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: identical(callId, unsetCopyWithValue)
        ? this.callId
        : callId as String?,
    execution: execution ?? this.execution,
    arguments: identical(arguments, unsetCopyWithValue)
        ? this.arguments
        : arguments,
    status: status ?? this.status,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          toolSearchArgumentsEqual(arguments, other.arguments) &&
          status == other.status &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    toolSearchArgumentsHash(arguments),
    status,
    createdBy,
  );

  @override
  String toString() =>
      'ToolSearchCallOutputItem(id: $id, agent: ${toolSearchActorSummary(agent?.agentName)}, callId: $callId, execution: $execution, arguments: ${toolSearchArgumentsSummary(arguments)}, status: $status, createdBy: ${toolSearchActorSummary(createdBy)})';
}

/// A tool search output item containing discovered tools.
@immutable
class ToolSearchOutputItem extends OutputItem {
  /// The fixed item discriminator.
  String get type => 'tool_search_output';

  /// Unique identifier.
  final String id;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The search call identifier; returned items always serialize its key.
  final String? callId;

  /// The server or client execution type.
  final ToolSearchExecutionType execution;

  /// The complete discovered tool definitions, including empty results.
  final List<ResponseTool> tools;

  /// The item status.
  final FunctionCallOutputStatus status;

  /// The actor that created this item, when provided.
  final String? createdBy;

  /// Creates a [ToolSearchOutputItem].
  ///
  /// Const construction retains caller-owned collections. Do not mutate them
  /// while this value is used as a map key or set member. Parsed collections
  /// are recursively unmodifiable snapshots.
  const ToolSearchOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.execution,
    required this.tools,
    required this.status,
    this.createdBy,
  });

  /// Creates a [ToolSearchOutputItem] from contextual tool-search JSON.
  factory ToolSearchOutputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ToolSearchOutputItem';
    requireJsonType(json, 'tool_search_output', context);
    return ToolSearchOutputItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: toolSearchJsonAgent(json, context),
      callId: toolSearchRequiredCallId(json, context),
      execution: ToolSearchExecutionType.fromJson(
        requireJsonString(json['execution'], '$context.execution'),
      ),
      tools: toolSearchJsonTools(json['tools'], '$context.tools'),
      status: FunctionCallOutputStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'execution': execution.toJson(),
    'tools': tools.map((tool) => tool.toToolSearchOutputJson()).toList(),
    'status': status.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy with nullable fields explicitly clearable.
  ToolSearchOutputItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? callId = unsetCopyWithValue,
    ToolSearchExecutionType? execution,
    List<ResponseTool>? tools,
    FunctionCallOutputStatus? status,
    Object? createdBy = unsetCopyWithValue,
  }) => ToolSearchOutputItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: identical(callId, unsetCopyWithValue)
        ? this.callId
        : callId as String?,
    execution: execution ?? this.execution,
    tools: tools ?? this.tools,
    status: status ?? this.status,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

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
      'ToolSearchOutputItem(id: $id, agent: ${toolSearchActorSummary(agent?.agentName)}, callId: $callId, execution: $execution, tools: ${tools.length} items, status: $status, createdBy: ${toolSearchActorSummary(createdBy)})';
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
  });

  /// Creates a [ComputerCallOutputItem] from JSON.
  factory ComputerCallOutputItem.fromJson(Map<String, dynamic> json) {
    final hasActions = json['actions'] != null;
    return ComputerCallOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: json['action'] != null
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
  /// The fixed discriminator for this call item.
  String get type => 'custom_tool_call';

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

  /// Whether this call may finish after the model continues working.
  ///
  /// Omitted for calls whose execution mode was not supplied.
  final bool? async;

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
    this.async,
  });

  /// Creates a [CustomToolCallItem] from JSON.
  factory CustomToolCallItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'custom_tool_call', 'CustomToolCallItem');
    return CustomToolCallItem(
      async: optionalJsonBool(json, 'async', 'CustomToolCallItem'),
      id: requireJsonString(json['id'], 'CustomToolCallItem.id'),
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: requireJsonString(json['call_id'], 'CustomToolCallItem.call_id'),
      name: requireJsonString(json['name'], 'CustomToolCallItem.name'),
      input: requireJsonString(json['input'], 'CustomToolCallItem.input'),
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
    if (async != null) 'async': async,
  };

  /// Converts this call to its supported input/replay shape.
  ///
  /// Output-only [status] and [createdBy] are not part of that input schema.
  CustomToolCallInputItem toCustomToolCallInputItem() =>
      CustomToolCallInputItem(
        id: id,
        agent: agent,
        callId: callId,
        name: name,
        input: input,
        namespace: namespace,
        caller: caller,
        async: async,
      );

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  CustomToolCallItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    String? name,
    String? input,
    Object? namespace = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => CustomToolCallItem(
    id: id ?? this.id,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    input: input ?? this.input,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    status: status == unsetCopyWithValue ? this.status : status as ItemStatus?,
    createdBy: createdBy == unsetCopyWithValue
        ? this.createdBy
        : createdBy as String?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

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
          caller == other.caller &&
          async == other.async;

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
    async,
  );

  @override
  String toString() =>
      'CustomToolCallItem(id: $id, agent: $agent, callId: $callId, name: $name, input: <redacted>, namespace: $namespace, status: $status, createdBy: $createdBy, caller: $caller, async: $async)';
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
