import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/function_call_status.dart';
import '../config/item_status.dart';
import '../config/message_phase.dart';
import '../config/message_role.dart';
import '../config/program_output_status.dart';
import '../config/tool_search_execution_type.dart';
import '../content/input_content.dart';
import '../content/output_content.dart';
import '../multi_agent/agent_tag.dart';
import '../multi_agent/multi_agent_action.dart';
import '../tools/response_tool.dart';
import '../tools/tool_call_caller.dart';

/// Input item for a response request.
///
/// ## Supported Item Types
///
/// - [MessageItem] - A message from a user or assistant
/// - [FunctionCallItem] - A function call from the model
/// - [FunctionCallOutputItem] - Output from a function call
/// - [ItemReference] - A reference to another item
/// - [CustomToolCallOutputInputItem] - Output from a custom tool call
/// - [ToolSearchCallItemParam] - A tool search call
/// - [ToolSearchOutputItemParam] - Tool search results
/// - [CompactionTriggerItem] - Triggers compaction of the current context
/// - [AdditionalToolsItemParam] - Additional tool definitions made available
///   mid-conversation
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
      'function_call_output' => FunctionCallOutputItem.fromJson(json),
      'custom_tool_call_output' => CustomToolCallOutputInputItem.fromJson(json),
      'item_reference' => ItemReference.fromJson(json),
      'tool_search_call' => ToolSearchCallItemParam.fromJson(json),
      'tool_search_output' => ToolSearchOutputItemParam.fromJson(json),
      'compaction_trigger' => CompactionTriggerItem.fromJson(json),
      'additional_tools' => AdditionalToolsItemParam.fromJson(json),
      'program' => ProgramItem.fromJson(json),
      'program_output' => ProgramOutputItem.fromJson(json),
      'agent_message' => AgentMessageItem.fromJson(json),
      'multi_agent_call' => MultiAgentCallItem.fromJson(json),
      'multi_agent_call_output' => MultiAgentCallOutputItem.fromJson(json),
      _ => throw FormatException('Unknown Item type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
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
  });

  /// Creates a [FunctionCallItem] from JSON.
  factory FunctionCallItem.fromJson(Map<String, dynamic> json) {
    return FunctionCallItem(
      id: json['id'] as String?,
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
  };

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
    caller,
  );

  @override
  String toString() =>
      'FunctionCallItem(id: $id, agent: $agent, callId: $callId, name: $name, arguments: $arguments, status: $status, namespace: $namespace, caller: $caller)';
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
