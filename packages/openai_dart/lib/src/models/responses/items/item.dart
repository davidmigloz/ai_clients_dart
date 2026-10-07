import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../config/configuration_update_reasoning.dart';
import '../config/function_call_status.dart';
import '../config/item_status.dart';
import '../config/message_phase.dart';
import '../config/message_role.dart';
import '../config/program_output_status.dart';
import '../config/tool_search_execution_type.dart';
import '../config/web_search_call_status.dart';
import '../content/input_content.dart';
import '../content/output_content.dart';
import '../multi_agent/agent_tag.dart';
import '../multi_agent/multi_agent_action.dart';
import '../tools/response_tool.dart';
import '../tools/shell_tool_environment.dart';
import '../tools/tool_call_caller.dart';
import 'output_item.dart'
    show
        ShellCallAction,
        ShellCallOutcome,
        ShellCallOutputContent,
        ShellEnvironment;
import 'shell_call_helpers.dart';
import 'web_search_action.dart';
import 'web_search_result.dart';

/// Input item for a response request.
///
/// ## Supported Item Types
///
/// - [MessageItem] - A message from a user or assistant
/// - [FunctionCallItem] - A function call from the model
/// - [CustomToolCallInputItem] - A custom tool call replayed as input
/// - [WebSearchCallItem] - Web search actions and results retained in input history
/// - [ShellCallInputItem] - Writable shell call history
/// - [ShellCallOutputInputItem] - Writable shell results
/// - [ShellCallResourceItem] - A stored shell call returned by the resource
/// - [ShellCallOutputResourceItem] - Stored shell output returned by the resource
/// - [FunctionCallOutputItem] - Output from a function call
/// - [ItemReference] - A reference to another item
/// - [CustomToolCallOutputInputItem] - Output from a custom tool call
/// - [ToolSearchCallItemParam] - A tool search call
/// - [ToolSearchOutputItemParam] - Tool search results
/// - [CompactionTriggerItem] - Triggers compaction of the current context
/// - [AdditionalToolsItemParam] - Additional tool definitions made available
///   mid-conversation
/// - [ConfigurationUpdateItem] - Reasoning configuration for subsequent responses
/// - [ConfigurationUpdateItemResponse] - A stored configuration update returned
///   by the Responses input-items resource
/// - [ProgramItem] - Programmatic tool calling source code
/// - [ProgramOutputItem] - Result of a programmatic tool calling execution
/// - [AgentMessageItem] - A message routed between agents (beta multi-agent)
/// - [MultiAgentCallItem] - A multi-agent action call (beta multi-agent)
/// - [MultiAgentCallOutputItem] - Output of a multi-agent action call (beta
///   multi-agent)
sealed class Item {
  /// Creates an [Item].
  const Item();

  /// Creates an [Item] from JSON.
  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => MessageItem.fromJson(json),
      'function_call' => FunctionCallItem.fromJson(json),
      'custom_tool_call' => CustomToolCallInputItem.fromJson(json),
      'web_search_call' => WebSearchCallItem.fromJson(json),
      'shell_call' => ShellCallInputItem.fromJson(json),
      'shell_call_output' => ShellCallOutputInputItem.fromJson(json),
      'function_call_output' => FunctionCallOutputItem.fromJson(json),
      'custom_tool_call_output' => CustomToolCallOutputInputItem.fromJson(json),
      'item_reference' => ItemReference.fromJson(json),
      'tool_search_call' => ToolSearchCallItemParam.fromJson(json),
      'tool_search_output' => ToolSearchOutputItemParam.fromJson(json),
      'compaction_trigger' => CompactionTriggerItem.fromJson(json),
      'additional_tools' => AdditionalToolsItemParam.fromJson(json),
      'configuration_update' => ConfigurationUpdateItem.fromJson(json),
      'program' => ProgramItem.fromJson(json),
      'program_output' => ProgramOutputItem.fromJson(json),
      'agent_message' => AgentMessageItem.fromJson(json),
      'multi_agent_call' => MultiAgentCallItem.fromJson(json),
      'multi_agent_call_output' => MultiAgentCallOutputItem.fromJson(json),
      _ => throw FormatException('Unknown Item type: $type'),
    };
  }

  /// Creates an item returned by the Responses input-items resource.
  ///
  /// Shell calls/results and stored configuration updates use distinct returned
  /// contracts; use each model's conversion helper for writable replay.
  factory Item.fromResourceJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'configuration_update' => ConfigurationUpdateItemResponse.fromJson(
          json,
        ),
        'shell_call' => ShellCallResourceItem.fromJson(json),
        'shell_call_output' => ShellCallOutputResourceItem.fromJson(json),
        _ => Item.fromJson(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A web search call retained in Responses input history.
///
/// The canonical input and input-resource unions share this exact call shape.
@immutable
class WebSearchCallItem extends Item {
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

  /// Creates a [WebSearchCallItem].
  const WebSearchCallItem({
    required this.id,
    this.agent,
    this.status,
    this.action,
    this.results,
  });

  /// Creates a [WebSearchCallItem] from JSON.
  factory WebSearchCallItem.fromJson(Map<String, dynamic> json) {
    const context = 'WebSearchCallItem';
    requireJsonType(json, 'web_search_call', context);
    final agent = json['agent'] == null
        ? null
        : requireJsonObject(json['agent'], '$context.agent');
    final rawResults = json['results'];
    if (json.containsKey('results') && rawResults is! List) {
      throw const FormatException('$context.results: expected an array');
    }
    return WebSearchCallItem(
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

  /// Copies every field; explicit null clears an optional value.
  WebSearchCallItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? action = unsetCopyWithValue,
    Object? results = unsetCopyWithValue,
  }) => WebSearchCallItem(
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
      other is WebSearchCallItem &&
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
      'WebSearchCallItem(type: $type, id: $id, agent: $agent, status: $status, action: $action, results: ${results == null ? 'null' : '${results!.length} items'})';
}

/// Changes reasoning configuration for subsequent responses in a conversation.
///
/// Keep request-level reasoning stable when changing effort with this item to
/// preserve the cached prefix. Persistence is managed by the server and currently
/// applies to single-agent conversations.
@immutable
class ConfigurationUpdateItem extends Item {
  /// The fixed item discriminator.
  String get type => 'configuration_update';

  /// Optional item identifier. Parsed null is normalized to omission.
  final String? id;

  /// Reasoning fields to update. When supplied, the JSON object must be nonnull.
  final ConfigurationUpdateReasoning? reasoning;

  /// Agent metadata on the beta multi-agent protocol.
  ///
  /// Retained for contextual replay. Configuration persistence is currently
  /// supported only in single-agent conversations.
  final AgentTag? agent;

  /// Creates a [ConfigurationUpdateItem].
  const ConfigurationUpdateItem({this.id, this.reasoning, this.agent});

  /// Creates a [ConfigurationUpdateItem] from JSON.
  factory ConfigurationUpdateItem.fromJson(Map<String, dynamic> json) {
    const context = 'ConfigurationUpdateItem';
    requireJsonType(json, 'configuration_update', context);
    final agent = json['agent'] == null
        ? null
        : requireJsonObject(json['agent'], '$context.agent');
    return ConfigurationUpdateItem(
      id: optionalJsonString(json, 'id', context, nullable: true),
      reasoning: json.containsKey('reasoning')
          ? ConfigurationUpdateReasoning.fromJson(
              requireJsonObject(json['reasoning'], '$context.reasoning'),
              context: '$context.reasoning',
            )
          : null,
      agent: agent == null
          ? null
          : AgentTag(
              agentName: requireJsonString(
                agent['agent_name'],
                '$context.agent.agent_name',
              ),
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Copies every field; explicit null clears an optional value.
  ConfigurationUpdateItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ConfigurationUpdateItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ConfigurationUpdateReasoning?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationUpdateItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reasoning == other.reasoning &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, reasoning, agent);

  @override
  String toString() =>
      'ConfigurationUpdateItem(type: $type, id: $id, reasoning: $reasoning, agent: $agent)';
}

/// A stored configuration update returned by the Responses input-items resource.
///
/// The returned item requires [id]; request input [ConfigurationUpdateItem] does
/// not. This is an input-resource item rather than a response output item.
@immutable
class ConfigurationUpdateItemResponse extends Item {
  /// The fixed item discriminator.
  String get type => 'configuration_update';

  /// The identifier of the stored configuration update.
  final String id;

  /// The reasoning update, when supplied.
  final ConfigurationUpdateReasoning? reasoning;

  /// Agent metadata on the beta multi-agent protocol.
  final AgentTag? agent;

  /// Creates a [ConfigurationUpdateItemResponse].
  const ConfigurationUpdateItemResponse({
    required this.id,
    this.reasoning,
    this.agent,
  });

  /// Creates a [ConfigurationUpdateItemResponse] from JSON.
  factory ConfigurationUpdateItemResponse.fromJson(Map<String, dynamic> json) {
    const context = 'ConfigurationUpdateItemResponse';
    requireJsonType(json, 'configuration_update', context);
    final agent = json.containsKey('agent')
        ? requireJsonObject(json['agent'], '$context.agent')
        : null;
    return ConfigurationUpdateItemResponse(
      id: requireJsonString(json['id'], '$context.id'),
      reasoning: json.containsKey('reasoning')
          ? ConfigurationUpdateReasoning.fromJson(
              requireJsonObject(json['reasoning'], '$context.reasoning'),
              context: '$context.reasoning',
            )
          : null,
      agent: agent == null
          ? null
          : AgentTag(
              agentName: requireJsonString(
                agent['agent_name'],
                '$context.agent.agent_name',
              ),
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Converts to request input while preserving every input-supported field.
  ConfigurationUpdateItem toConfigurationUpdateItem() =>
      ConfigurationUpdateItem(id: id, reasoning: reasoning, agent: agent);

  /// Copies every field; explicit null clears an optional value.
  ConfigurationUpdateItemResponse copyWith({
    String? id,
    Object? reasoning = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ConfigurationUpdateItemResponse(
    id: id ?? this.id,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ConfigurationUpdateReasoning?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationUpdateItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reasoning == other.reasoning &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, reasoning, agent);

  @override
  String toString() =>
      'ConfigurationUpdateItemResponse(type: $type, id: $id, reasoning: $reasoning, agent: $agent)';
}

/// A message item in a conversation.
@immutable
class MessageItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The role of the message.
  final MessageRole role;

  /// The content of the message.
  final List<InputContent> content;

  /// Item status (for output items).
  final ItemStatus? status;

  /// The phase of the message.
  final MessagePhase? phase;

  /// Creates a [MessageItem].
  const MessageItem({
    this.id,
    this.agent,
    required this.role,
    required this.content,
    this.status,
    this.phase,
  });

  /// Creates a user message.
  factory MessageItem.user(List<InputContent> content) =>
      MessageItem(role: MessageRole.user, content: content);

  /// Creates a user message with simple text.
  factory MessageItem.userText(String text) =>
      MessageItem(role: MessageRole.user, content: [InputContent.text(text)]);

  /// Creates a system message.
  factory MessageItem.system(List<InputContent> content) =>
      MessageItem(role: MessageRole.system, content: content);

  /// Creates a system message with simple text.
  factory MessageItem.systemText(String text) =>
      MessageItem(role: MessageRole.system, content: [InputContent.text(text)]);

  /// Creates a developer message.
  factory MessageItem.developer(List<InputContent> content) =>
      MessageItem(role: MessageRole.developer, content: content);

  /// Creates a developer message with simple text.
  factory MessageItem.developerText(String text) => MessageItem(
    role: MessageRole.developer,
    content: [InputContent.text(text)],
  );

  /// Creates an assistant message.
  factory MessageItem.assistant(List<InputContent> content) =>
      MessageItem(role: MessageRole.assistant, content: content);

  /// Creates an assistant message with simple text.
  ///
  /// Uses [AssistantTextContent] which serializes as `output_text`,
  /// as required by the API for assistant messages in multi-turn conversations.
  factory MessageItem.assistantText(String text) => MessageItem(
    role: MessageRole.assistant,
    content: [InputContent.assistantText(text)],
  );

  /// Creates a [MessageItem] from JSON.
  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
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
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
    if (phase != null) 'phase': phase!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageItem &&
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
      'MessageItem(id: $id, agent: $agent, role: $role, content: $content, status: $status, phase: $phase)';
}

/// A function call item.
@immutable
class FunctionCallItem extends Item {
  /// The fixed discriminator for this call item.
  String get type => 'function_call';

  /// Unique identifier.
  final String? id;

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
        'FunctionCallItem.arguments must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  /// Item status (for output items).
  final ItemStatus? status;

  /// The namespace this function call belongs to.
  final String? namespace;

  /// The execution context that produced this tool call.
  final ToolCallCaller? caller;

  /// Whether this call may finish after the model continues working.
  ///
  /// Omitted for calls whose execution mode was not supplied.
  final bool? async;

  /// Creates a [FunctionCallItem].
  const FunctionCallItem({
    this.id,
    this.agent,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
    this.namespace,
    this.caller,
    this.async,
  });

  /// Creates a [FunctionCallItem] from JSON.
  factory FunctionCallItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'function_call', 'FunctionCallItem');
    return FunctionCallItem(
      async: optionalJsonBool(json, 'async', 'FunctionCallItem'),
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: requireJsonString(json['call_id'], 'FunctionCallItem.call_id'),
      name: requireJsonString(json['name'], 'FunctionCallItem.name'),
      arguments: requireJsonString(
        json['arguments'],
        'FunctionCallItem.arguments',
      ),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      namespace: json['namespace'] as String?,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
    if (namespace != null) 'namespace': namespace,
    if (caller != null) 'caller': caller!.toJson(),
    if (async != null) 'async': async,
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  FunctionCallItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    String? name,
    String? arguments,
    Object? status = unsetCopyWithValue,
    Object? namespace = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => FunctionCallItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    status: status == unsetCopyWithValue ? this.status : status as ItemStatus?,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          status == other.status &&
          namespace == other.namespace &&
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
    caller,
    async,
  );

  @override
  String toString() =>
      'FunctionCallItem(id: $id, agent: $agent, callId: $callId, name: $name, arguments: <redacted>, status: $status, namespace: $namespace, caller: $caller, async: $async)';
}

/// A custom tool call replayed as input to a response.
///
/// The application executes the tool and returns its result using the original
/// [callId]. An [async] call lets the model continue before that result arrives.
/// Output-only status and creator metadata do not belong to this input shape.
@immutable
class CustomToolCallInputItem extends Item {
  /// The fixed discriminator for this call item.
  String get type => 'custom_tool_call';

  /// Unique identifier, when this call has already been recorded.
  final String? id;

  /// The agent that produced this item on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The identifier used to match this call to its result.
  final String callId;

  /// The name of the custom tool.
  final String name;

  /// The tool input. Its format is defined by the application.
  final String input;

  /// The namespace containing the custom tool.
  final String? namespace;

  /// The execution context that produced the call.
  final ToolCallCaller? caller;

  /// Whether this call may finish after the model continues working.
  final bool? async;

  /// Creates a [CustomToolCallInputItem].
  const CustomToolCallInputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.name,
    required this.input,
    this.namespace,
    this.caller,
    this.async,
  });

  /// Creates a [CustomToolCallInputItem] from JSON.
  factory CustomToolCallInputItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'custom_tool_call', 'CustomToolCallInputItem');
    return CustomToolCallInputItem(
      id: optionalJsonString(json, 'id', 'CustomToolCallInputItem'),
      agent: json['agent'] != null
          ? AgentTag.fromJson(
              requireJsonObject(json['agent'], 'CustomToolCallInputItem.agent'),
            )
          : null,
      callId: requireJsonString(
        json['call_id'],
        'CustomToolCallInputItem.call_id',
      ),
      name: requireJsonString(json['name'], 'CustomToolCallInputItem.name'),
      input: requireJsonString(json['input'], 'CustomToolCallInputItem.input'),
      namespace: optionalJsonString(
        json,
        'namespace',
        'CustomToolCallInputItem',
      ),
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(
              requireJsonObject(
                json['caller'],
                'CustomToolCallInputItem.caller',
              ),
            )
          : null,
      async: optionalJsonBool(json, 'async', 'CustomToolCallInputItem'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'name': name,
    'input': input,
    if (namespace != null) 'namespace': namespace,
    if (caller != null) 'caller': caller!.toJson(),
    if (async != null) 'async': async,
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  CustomToolCallInputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    String? name,
    String? input,
    Object? namespace = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => CustomToolCallInputItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    input: input ?? this.input,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolCallInputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          name == other.name &&
          input == other.input &&
          namespace == other.namespace &&
          caller == other.caller &&
          async == other.async;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, name, input, namespace, caller, async);

  @override
  String toString() =>
      'CustomToolCallInputItem(id: $id, agent: $agent, callId: $callId, '
      'name: $name, input: <redacted>, namespace: $namespace, '
      'caller: $caller, async: $async)';
}

/// The output of a function call.
///
/// Can be either a simple string or a list of content items.
sealed class FunctionCallOutput {
  /// Creates a [FunctionCallOutput].
  const FunctionCallOutput();

  /// Creates a [FunctionCallOutput] from JSON.
  factory FunctionCallOutput.fromJson(Object json) {
    if (json is String) {
      return FunctionCallOutputString(json);
    }
    if (json is List) {
      return FunctionCallOutputContent(
        json
            .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid FunctionCallOutput format: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// A string output from a function call.
@immutable
class FunctionCallOutputString extends FunctionCallOutput {
  /// The string output.
  final String value;

  /// Creates a [FunctionCallOutputString].
  const FunctionCallOutputString(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'FunctionCallOutputString($value)';
}

/// A list of content items output from a function call.
@immutable
class FunctionCallOutputContent extends FunctionCallOutput {
  /// The content items.
  final List<InputContent> content;

  /// Creates a [FunctionCallOutputContent].
  const FunctionCallOutputContent(this.content);

  @override
  Object toJson() => content.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputContent &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content);

  @override
  int get hashCode => Object.hashAll(content);

  @override
  String toString() => 'FunctionCallOutputContent($content)';
}

/// A function call output item.
@immutable
class FunctionCallOutputItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content.
  final FunctionCallOutput output;

  /// The status of the function call.
  final FunctionCallStatus? status;

  /// The execution context that produced the tool call this output responds
  /// to.
  final ToolCallCaller? caller;

  /// Creates a [FunctionCallOutputItem].
  const FunctionCallOutputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.output,
    this.status,
    this.caller,
  });

  /// Creates a [FunctionCallOutputItem] with a simple string output.
  factory FunctionCallOutputItem.string({
    String? id,
    AgentTag? agent,
    required String callId,
    required String output,
    FunctionCallStatus? status,
    ToolCallCaller? caller,
  }) {
    return FunctionCallOutputItem(
      id: id,
      agent: agent,
      callId: callId,
      output: FunctionCallOutputString(output),
      status: status,
      caller: caller,
    );
  }

  /// Creates a [FunctionCallOutputItem] from JSON.
  factory FunctionCallOutputItem.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      status: json['status'] != null
          ? FunctionCallStatus.fromJson(json['status'] as String)
          : null,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call_output',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'output': output.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  FunctionCallOutputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    FunctionCallOutput? output,
    Object? status = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
  }) {
    return FunctionCallOutputItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
      callId: callId ?? this.callId,
      output: output ?? this.output,
      status: status == unsetCopyWithValue
          ? this.status
          : status as FunctionCallStatus?,
      caller: caller == unsetCopyWithValue
          ? this.caller
          : caller as ToolCallCaller?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          output == other.output &&
          status == other.status &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(id, agent, callId, output, status, caller);

  @override
  String toString() =>
      'FunctionCallOutputItem(id: $id, agent: $agent, callId: $callId, output: $output, status: $status, caller: $caller)';
}

/// Reference to a previously created item.
@immutable
class ItemReference extends Item {
  /// The ID of the referenced item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Creates an [ItemReference].
  const ItemReference({required this.id, this.agent});

  /// Creates an [ItemReference] from JSON.
  factory ItemReference.fromJson(Map<String, dynamic> json) {
    return ItemReference(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'item_reference',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemReference &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, agent);

  @override
  String toString() => 'ItemReference(id: $id, agent: $agent)';
}

/// Triggers compaction of the current context.
///
/// Compacts the current context. Must be the final input item in the list.
@immutable
class CompactionTriggerItem extends Item {
  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Creates a [CompactionTriggerItem].
  const CompactionTriggerItem({this.agent});

  /// Creates a [CompactionTriggerItem] from JSON.
  factory CompactionTriggerItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'compaction_trigger') {
      throw FormatException('Expected type "compaction_trigger", got "$type"');
    }
    return CompactionTriggerItem(
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction_trigger',
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionTriggerItem &&
          runtimeType == other.runtimeType &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(runtimeType, agent);

  @override
  String toString() => 'CompactionTriggerItem(agent: $agent)';
}

/// A custom tool call output input item.
@immutable
class CustomToolCallOutputInputItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output from the custom tool call.
  final FunctionCallOutput output;

  /// The execution context that produced the tool call this output responds
  /// to.
  final ToolCallCaller? caller;

  /// Creates a [CustomToolCallOutputInputItem].
  const CustomToolCallOutputInputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.output,
    this.caller,
  });

  /// Creates a [CustomToolCallOutputInputItem] with a simple string output.
  factory CustomToolCallOutputInputItem.string({
    String? id,
    AgentTag? agent,
    required String callId,
    required String output,
    ToolCallCaller? caller,
  }) {
    return CustomToolCallOutputInputItem(
      id: id,
      agent: agent,
      callId: callId,
      output: FunctionCallOutputString(output),
      caller: caller,
    );
  }

  /// Creates a [CustomToolCallOutputInputItem] from JSON.
  factory CustomToolCallOutputInputItem.fromJson(Map<String, dynamic> json) {
    return CustomToolCallOutputInputItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call_output',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'output': output.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolCallOutputInputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          output == other.output &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(id, agent, callId, output, caller);

  @override
  String toString() =>
      'CustomToolCallOutputInputItem(id: $id, agent: $agent, callId: $callId, output: $output, caller: $caller)';
}

/// A tool search call input item.
@immutable
class ToolSearchCallItemParam extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this tool search call.
  final String? callId;

  /// The execution type (server or client).
  final ToolSearchExecutionType? execution;

  /// The arguments for the tool search.
  final Map<String, dynamic>? arguments;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ToolSearchCallItemParam].
  const ToolSearchCallItemParam({
    this.id,
    this.agent,
    this.callId,
    this.execution,
    this.arguments,
    this.status,
  });

  /// Creates a [ToolSearchCallItemParam] from JSON.
  factory ToolSearchCallItemParam.fromJson(Map<String, dynamic> json) {
    return ToolSearchCallItemParam(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String?,
      execution: json['execution'] != null
          ? ToolSearchExecutionType.fromJson(json['execution'] as String)
          : null,
      arguments: json['arguments'] as Map<String, dynamic>?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search_call',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    if (execution != null) 'execution': execution!.toJson(),
    if (arguments != null) 'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchCallItemParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          mapsDeepEqual(arguments, other.arguments) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    mapDeepHashCode(arguments),
    status,
  );

  @override
  String toString() =>
      'ToolSearchCallItemParam(id: $id, agent: $agent, callId: $callId, execution: $execution, status: $status)';
}

/// A tool search output input item.
@immutable
class ToolSearchOutputItemParam extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this tool search output.
  final String? callId;

  /// The execution type (server or client).
  final ToolSearchExecutionType? execution;

  /// The tools discovered by the search.
  final List<ResponseTool> tools;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ToolSearchOutputItemParam].
  const ToolSearchOutputItemParam({
    this.id,
    this.agent,
    this.callId,
    this.execution,
    required this.tools,
    this.status,
  });

  /// Creates a [ToolSearchOutputItemParam] from JSON.
  factory ToolSearchOutputItemParam.fromJson(Map<String, dynamic> json) {
    return ToolSearchOutputItemParam(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String?,
      execution: json['execution'] != null
          ? ToolSearchExecutionType.fromJson(json['execution'] as String)
          : null,
      tools: (json['tools'] as List)
          .map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search_output',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    if (execution != null) 'execution': execution!.toJson(),
    'tools': tools.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchOutputItemParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          listsEqual(tools, other.tools) &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, execution, Object.hashAll(tools), status);

  @override
  String toString() =>
      'ToolSearchOutputItemParam(id: $id, agent: $agent, callId: $callId, execution: $execution, tools: $tools, status: $status)';
}

/// An additional tools input item.
///
/// Makes a list of additional tool definitions available mid-conversation.
/// Only the `developer` role is supported.
@immutable
class AdditionalToolsItemParam extends Item {
  /// Unique identifier of this additional tools item.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// A list of additional tools made available at this item.
  final List<ResponseTool> tools;

  /// Creates an [AdditionalToolsItemParam].
  const AdditionalToolsItemParam({this.id, this.agent, required this.tools});

  /// Creates an [AdditionalToolsItemParam] from JSON.
  factory AdditionalToolsItemParam.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'additional_tools') {
      throw FormatException('Expected type "additional_tools", got "$type"');
    }
    // Only the `developer` role is supported (spec const). Reject other values
    // when present rather than silently normalizing them on re-serialization.
    final role = json['role'] as String?;
    if (role != null && role != 'developer') {
      throw FormatException(
        'Expected "additional_tools" role "developer", got "$role"',
      );
    }
    return AdditionalToolsItemParam(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      tools: (json['tools'] as List)
          .map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'additional_tools',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    // Only the `developer` role is supported for this item.
    'role': 'developer',
    'tools': tools.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalToolsItemParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(id, agent, Object.hashAll(tools));

  @override
  String toString() =>
      'AdditionalToolsItemParam(id: $id, agent: $agent, tools: $tools)';
}

/// Programmatic tool calling source code, as an input item.
///
/// Mirrors the `ProgramItemParam` schema.
@immutable
class ProgramItem extends Item {
  /// The unique ID of this program item.
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

  /// Creates a [ProgramItem].
  const ProgramItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.code,
    required this.fingerprint,
  });

  /// Creates a [ProgramItem] from JSON.
  factory ProgramItem.fromJson(Map<String, dynamic> json) {
    return ProgramItem(
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
      other is ProgramItem &&
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
      'ProgramItem(id: $id, agent: $agent, callId: $callId, code: $code, fingerprint: $fingerprint)';
}

/// The result of a programmatic tool calling execution, as an input item.
///
/// Mirrors the `ProgramOutputItemParam` schema.
@immutable
class ProgramOutputItem extends Item {
  /// The unique ID of this program output item.
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

  /// The terminal status of the program output.
  final ProgramOutputStatus status;

  /// Creates a [ProgramOutputItem].
  const ProgramOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.result,
    required this.status,
  });

  /// Creates a [ProgramOutputItem] from JSON.
  factory ProgramOutputItem.fromJson(Map<String, dynamic> json) {
    return ProgramOutputItem(
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
      other is ProgramOutputItem &&
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
      'ProgramOutputItem(id: $id, agent: $agent, callId: $callId, result: $result, status: $status)';
}

/// A message routed between agents, as an input item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaAgentMessageItemParam` schema.
@immutable
class AgentMessageItem extends Item {
  /// The unique ID of this agent message item.
  final String? id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The sending agent identity.
  final String author;

  /// The destination agent identity.
  final String recipient;

  /// Plaintext, image, or encrypted content sent between agents.
  final List<InputContent> content;

  /// Creates an [AgentMessageItem].
  const AgentMessageItem({
    this.id,
    this.agent,
    required this.author,
    required this.recipient,
    required this.content,
  });

  /// Creates an [AgentMessageItem] from JSON.
  factory AgentMessageItem.fromJson(Map<String, dynamic> json) {
    return AgentMessageItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      author: json['author'] as String,
      recipient: json['recipient'] as String,
      content: (json['content'] as List)
          .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'agent_message',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'author': author,
    'recipient': recipient,
    'content': content.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentMessageItem &&
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
      'AgentMessageItem(id: $id, agent: $agent, author: $author, recipient: $recipient, content: $content)';
}

/// A multi-agent action call, as an input item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaMultiAgentCallItemParam` schema.
@immutable
class MultiAgentCallItem extends Item {
  /// The unique ID of this multi-agent call.
  final String? id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The unique ID linking this call to its output.
  final String callId;

  /// The multi-agent action that was executed.
  final MultiAgentAction action;

  /// The action arguments as a JSON string.
  final String arguments;

  /// Creates a [MultiAgentCallItem].
  const MultiAgentCallItem({
    this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.arguments,
  });

  /// Creates a [MultiAgentCallItem] from JSON.
  factory MultiAgentCallItem.fromJson(Map<String, dynamic> json) {
    return MultiAgentCallItem(
      id: json['id'] as String?,
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
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentCallItem &&
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
      'MultiAgentCallItem(id: $id, agent: $agent, callId: $callId, action: $action, arguments: $arguments)';
}

/// The output of a multi-agent action call, as an input item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaMultiAgentCallOutputItemParam` schema.
@immutable
class MultiAgentCallOutputItem extends Item {
  /// The unique ID of this multi-agent call output.
  final String? id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The unique ID of the multi-agent call.
  final String callId;

  /// The multi-agent action that produced this result.
  final MultiAgentAction action;

  /// Text output returned by the multi-agent action.
  final List<OutputTextContent> output;

  /// Creates a [MultiAgentCallOutputItem].
  const MultiAgentCallOutputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.output,
  });

  /// Creates a [MultiAgentCallOutputItem] from JSON.
  factory MultiAgentCallOutputItem.fromJson(Map<String, dynamic> json) {
    return MultiAgentCallOutputItem(
      id: json['id'] as String?,
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
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'output': output.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentCallOutputItem &&
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
      'MultiAgentCallOutputItem(id: $id, agent: $agent, callId: $callId, action: $action, output: $output)';
}

/// A returned shell call with the exact resource contract.
@immutable
class ShellCallResourceItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call';

  /// Unique identifier.
  final String id;

  /// Optional beta agent metadata. Explicit JSON null is invalid.
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

  /// Creates a [ShellCallResourceItem].
  const ShellCallResourceItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.status,
    required this.environment,
    this.caller,
    this.createdBy,
  });

  /// Creates a [ShellCallResourceItem] from JSON.
  factory ShellCallResourceItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallResourceItem';
    requireJsonType(json, 'shell_call', context);
    if (!json.containsKey('environment')) {
      throw const FormatException('$context.environment: required key missing');
    }
    return ShellCallResourceItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: shellJsonAgent(json, context, nullable: false),
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
  ShellCallResourceItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ShellCallAction? action,
    ItemStatus? status,
    Object? environment = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallResourceItem(
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
      other is ShellCallResourceItem &&
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
      'ShellCallResourceItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, action: $action, status: $status, environment: $environment, caller: ${caller == null ? 'null' : caller.runtimeType}, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
}

/// A returned shell result with the exact resource contract.
@immutable
class ShellCallOutputResourceItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call_output';

  /// Unique identifier.
  final String id;

  /// Optional beta agent metadata. Explicit JSON null is invalid.
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

  /// Creates a [ShellCallOutputResourceItem].
  const ShellCallOutputResourceItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.status,
    required this.output,
    required this.maxOutputLength,
    this.caller,
    this.createdBy,
  });

  /// Creates a [ShellCallOutputResourceItem] from JSON.
  factory ShellCallOutputResourceItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallOutputResourceItem';
    requireJsonType(json, 'shell_call_output', context);
    return ShellCallOutputResourceItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: shellJsonAgent(json, context, nullable: false),
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
  ShellCallOutputResourceItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ItemStatus? status,
    List<ShellCallOutputContent>? output,
    Object? maxOutputLength = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallOutputResourceItem(
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
      other is ShellCallOutputResourceItem &&
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
      'ShellCallOutputResourceItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, status: $status, output: ${output.length} chunks, maxOutputLength: $maxOutputLength, caller: ${caller == null ? 'null' : caller.runtimeType}, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
}

ShellToolEnvironment? _shellInputEnvironment(Object? value, String context) {
  if (value == null) return null;
  final json = requireJsonObject(value, context);
  final type = requireJsonString(json['type'], '$context.type');
  if (type == 'container_auto') {
    throw FormatException(
      '$context.type: container_auto is not permitted in call input',
    );
  }
  try {
    return ShellToolEnvironment.fromJson(json);
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}

/// Commands and optional nullable limits in a writable shell call.
@immutable
class ShellCallActionInput {
  /// An immutable snapshot of ordered commands.
  final List<String> commands;

  /// Optional nullable timeout in milliseconds; null normalizes to omission.
  final int? timeoutMs;

  /// Optional nullable maximum output length; null normalizes to omission.
  final int? maxOutputLength;

  /// Creates a [ShellCallActionInput], taking a command snapshot.
  ShellCallActionInput({
    required List<String> commands,
    this.timeoutMs,
    this.maxOutputLength,
  }) : commands = List<String>.unmodifiable(commands);

  /// Creates a [ShellCallActionInput] from JSON.
  factory ShellCallActionInput.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallActionInput',
  }) => ShellCallActionInput(
    commands: shellJsonList(
      json['commands'],
      '$context.commands',
      requireJsonString,
    ),
    timeoutMs: shellOptionalNullableInt(json, 'timeout_ms', context),
    maxOutputLength: shellOptionalNullableInt(
      json,
      'max_output_length',
      context,
    ),
  );

  /// Converts to JSON, omitting unset request limits.
  Map<String, dynamic> toJson() => {
    'commands': commands,
    if (timeoutMs != null) 'timeout_ms': timeoutMs,
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
  };

  /// Creates a copy; explicit null clears either limit.
  ShellCallActionInput copyWith({
    List<String>? commands,
    Object? timeoutMs = unsetCopyWithValue,
    Object? maxOutputLength = unsetCopyWithValue,
  }) => ShellCallActionInput(
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
      other is ShellCallActionInput &&
          listsEqual(commands, other.commands) &&
          timeoutMs == other.timeoutMs &&
          maxOutputLength == other.maxOutputLength;
  @override
  int get hashCode =>
      Object.hash(Object.hashAll(commands), timeoutMs, maxOutputLength);
  @override
  String toString() =>
      'ShellCallActionInput(commands: ${commands.length} commands, timeoutMs: $timeoutMs, maxOutputLength: $maxOutputLength)';
}

/// Writable stdout/stderr/outcome content; returned created_by is omitted.
@immutable
class ShellCallOutputContentInput {
  /// Captured standard output.
  final String stdout;

  /// Captured standard error.
  final String stderr;

  /// The exit or timeout outcome.
  final ShellCallOutcome outcome;

  /// Creates a [ShellCallOutputContentInput].
  const ShellCallOutputContentInput({
    required this.stdout,
    required this.stderr,
    required this.outcome,
  });

  /// Creates a [ShellCallOutputContentInput] from JSON.
  factory ShellCallOutputContentInput.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallOutputContentInput',
  }) => ShellCallOutputContentInput(
    stdout: requireJsonString(json['stdout'], '$context.stdout'),
    stderr: requireJsonString(json['stderr'], '$context.stderr'),
    outcome: ShellCallOutcome.fromJson(
      requireJsonObject(json['outcome'], '$context.outcome'),
      context: '$context.outcome',
    ),
  );

  /// Converts to JSON without read-only creator metadata.
  Map<String, dynamic> toJson() => {
    'stdout': stdout,
    'stderr': stderr,
    'outcome': outcome.toJson(),
  };

  /// Creates a copy with replacements.
  ShellCallOutputContentInput copyWith({
    String? stdout,
    String? stderr,
    ShellCallOutcome? outcome,
  }) => ShellCallOutputContentInput(
    stdout: stdout ?? this.stdout,
    stderr: stderr ?? this.stderr,
    outcome: outcome ?? this.outcome,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputContentInput &&
          stdout == other.stdout &&
          stderr == other.stderr &&
          outcome == other.outcome;
  @override
  int get hashCode => Object.hash(stdout, stderr, outcome);
  @override
  String toString() =>
      'ShellCallOutputContentInput(stdout: ${stdout.length} chars, stderr: ${stderr.length} chars, outcome: $outcome)';
}

/// Writable shell call history with the request parameter contract.
@immutable
class ShellCallInputItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call';

  /// Optional nullable id.
  final String? id;

  /// Optional nullable agent.
  final AgentTag? agent;

  /// Required call id.
  final String callId;

  /// Required action.
  final ShellCallActionInput action;

  /// Optional nullable status.
  final ItemStatus? status;

  /// Local/reference only. A container_auto definition cannot be replayed here.
  final ShellToolEnvironment? environment;

  /// Optional nullable caller.
  final ToolCallCaller? caller;

  /// Creates a [ShellCallInputItem].
  const ShellCallInputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.action,
    this.status,
    this.environment,
    this.caller,
  });

  /// Creates a [ShellCallInputItem] from JSON.
  factory ShellCallInputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallInputItem';
    requireJsonType(json, 'shell_call', context);
    return ShellCallInputItem(
      id: optionalJsonString(json, 'id', context, nullable: true),
      agent: shellJsonAgent(json, context),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      action: ShellCallActionInput.fromJson(
        requireJsonObject(json['action'], '$context.action'),
        context: '$context.action',
      ),
      status: json['status'] == null
          ? null
          : ItemStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            ),
      environment: _shellInputEnvironment(
        json['environment'],
        '$context.environment',
      ),
      caller: shellJsonCaller(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final environmentJson = environment?.toJson();
    if (environmentJson?['type'] == 'container_auto') {
      throw ArgumentError.value(
        environment,
        'environment',
        'ShellCallInputItem accepts only local/reference environments',
      );
    }
    return {
      'type': type,
      if (id != null) 'id': id,
      if (agent != null) 'agent': agent!.toJson(),
      'call_id': callId,
      'action': action.toJson(),
      if (status != null) 'status': status!.toJson(),
      if (environment != null) 'environment': environmentJson,
      if (caller != null) 'caller': caller!.toJson(),
    };
  }

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallInputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ShellCallActionInput? action,
    Object? status = unsetCopyWithValue,
    Object? environment = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
  }) => ShellCallInputItem(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    action: action ?? this.action,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
    environment: identical(environment, unsetCopyWithValue)
        ? this.environment
        : environment as ShellToolEnvironment?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallInputItem &&
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
      'ShellCallInputItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, action: $action, status: $status, environment: $environment, caller: ${caller == null ? 'null' : caller.runtimeType})';
}

/// Writable shell results with the request parameter contract.
@immutable
class ShellCallOutputInputItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call_output';

  /// Optional nullable id.
  final String? id;

  /// Optional nullable agent.
  final AgentTag? agent;

  /// Required call id.
  final String callId;

  /// Optional nullable status.
  final ItemStatus? status;

  /// Required output.
  final List<ShellCallOutputContentInput> output;

  /// Optional nullable max output length.
  final int? maxOutputLength;

  /// Optional nullable caller.
  final ToolCallCaller? caller;

  /// Creates a [ShellCallOutputInputItem].
  ShellCallOutputInputItem({
    this.id,
    this.agent,
    required this.callId,
    this.status,
    required List<ShellCallOutputContentInput> output,
    this.maxOutputLength,
    this.caller,
  }) : output = List<ShellCallOutputContentInput>.unmodifiable(output);

  /// Creates a [ShellCallOutputInputItem] from JSON.
  factory ShellCallOutputInputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallOutputInputItem';
    requireJsonType(json, 'shell_call_output', context);
    return ShellCallOutputInputItem(
      id: optionalJsonString(json, 'id', context, nullable: true),
      agent: shellJsonAgent(json, context),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      status: json['status'] == null
          ? null
          : ItemStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            ),
      output: shellJsonList(
        json['output'],
        '$context.output',
        (value, path) => ShellCallOutputContentInput.fromJson(
          requireJsonObject(value, path),
          context: path,
        ),
      ),
      maxOutputLength: shellOptionalNullableInt(
        json,
        'max_output_length',
        context,
      ),
      caller: shellJsonCaller(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    if (status != null) 'status': status!.toJson(),
    'output': output.map((chunk) => chunk.toJson()).toList(),
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
    if (caller != null) 'caller': caller!.toJson(),
  };

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallOutputInputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    Object? status = unsetCopyWithValue,
    List<ShellCallOutputContentInput>? output,
    Object? maxOutputLength = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
  }) => ShellCallOutputInputItem(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
    output: output ?? this.output,
    maxOutputLength: identical(maxOutputLength, unsetCopyWithValue)
        ? this.maxOutputLength
        : maxOutputLength as int?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputInputItem &&
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
      'ShellCallOutputInputItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, status: $status, output: ${output.length} chunks, maxOutputLength: $maxOutputLength, caller: ${caller == null ? 'null' : caller.runtimeType})';
}
