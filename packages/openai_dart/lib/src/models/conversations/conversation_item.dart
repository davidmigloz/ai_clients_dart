import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import '../responses/config/configuration_update_reasoning.dart';
import '../responses/config/function_call_status.dart';
import '../responses/config/item_status.dart';
import '../responses/config/message_phase.dart';
import '../responses/config/tool_search_execution_type.dart';
import '../responses/config/web_search_call_status.dart';
import '../responses/items/item.dart'
    show ConfigurationUpdateItem, FunctionCallOutput, WebSearchCallItem;
import '../responses/items/web_search_action.dart';
import '../responses/items/web_search_result.dart';
import '../responses/multi_agent/agent_tag.dart';
import '../responses/tools/response_tool.dart';
import '../responses/tools/tool_call_caller.dart';
import 'conversation_content.dart';
import 'conversation_message.dart';

/// An item stored in a conversation.
///
/// This sealed class hierarchy represents the different types of items
/// that can be stored in a conversation, including output item types
/// from the Responses API and conversation-specific types.
/// [ConversationConfigurationUpdateItem] represents a stored reasoning update.
sealed class ConversationItem {
  /// Creates a [ConversationItem].
  const ConversationItem();

  /// Creates a [ConversationItem] from JSON.
  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => ConversationMessageItem.fromJson(json),
      'function_call' => ConversationFunctionCallItem.fromJson(json),
      'function_call_output' => ConversationFunctionCallOutputItem.fromJson(
        json,
      ),
      'reasoning' => ConversationReasoningItem.fromJson(json),
      'image_generation_call' => ConversationImageGenerationCallItem.fromJson(
        json,
      ),
      'local_shell_call' => ConversationLocalShellCallItem.fromJson(json),
      'local_shell_call_output' =>
        ConversationLocalShellCallOutputItem.fromJson(json),
      'mcp_list_tools' => ConversationMcpListToolsItem.fromJson(json),
      'mcp_approval_request' => ConversationMcpApprovalRequestItem.fromJson(
        json,
      ),
      'mcp_approval_response' => ConversationMcpApprovalResponseItem.fromJson(
        json,
      ),
      'mcp_call' => ConversationMcpCallItem.fromJson(json),
      'web_search_call' => ConversationWebSearchCallItem.fromJson(json),
      'file_search_call' => ConversationFileSearchCallItem.fromJson(json),
      'computer_call' => ConversationComputerCallItem.fromJson(json),
      'computer_call_output' => ConversationComputerCallOutputItem.fromJson(
        json,
      ),
      'code_interpreter_call' => ConversationCodeInterpreterCallItem.fromJson(
        json,
      ),
      'tool_search_call' => ConversationToolSearchCallItem.fromJson(json),
      'tool_search_output' => ConversationToolSearchOutputItem.fromJson(json),
      'compaction' => ConversationCompactionItem.fromJson(json),
      'custom_tool_call' => ConversationCustomToolCallItem.fromJson(json),
      'custom_tool_call_output' =>
        ConversationCustomToolCallOutputItem.fromJson(json),
      'additional_tools' => ConversationAdditionalToolsItem.fromJson(json),
      'configuration_update' => ConversationConfigurationUpdateItem.fromJson(
        json,
      ),
      _ => ConversationUnknownItem(type: type, data: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A stored reasoning configuration update in a conversation.
///
/// Persistence is managed by the server for subsequent responses in a
/// single-agent conversation.
@immutable
class ConversationConfigurationUpdateItem extends ConversationItem {
  /// The fixed item discriminator.
  String get type => 'configuration_update';

  /// The identifier of the stored item.
  final String id;

  /// The reasoning update, when supplied.
  final ConfigurationUpdateReasoning? reasoning;

  /// Agent metadata on the beta multi-agent protocol.
  final AgentTag? agent;

  /// Creates a [ConversationConfigurationUpdateItem].
  const ConversationConfigurationUpdateItem({
    required this.id,
    this.reasoning,
    this.agent,
  });

  /// Creates a [ConversationConfigurationUpdateItem] from JSON.
  factory ConversationConfigurationUpdateItem.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ConversationConfigurationUpdateItem';
    requireJsonType(json, 'configuration_update', context);
    final agent = json.containsKey('agent')
        ? requireJsonObject(json['agent'], '$context.agent')
        : null;
    return ConversationConfigurationUpdateItem(
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
  ConversationConfigurationUpdateItem copyWith({
    String? id,
    Object? reasoning = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ConversationConfigurationUpdateItem(
    id: id ?? this.id,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ConfigurationUpdateReasoning?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationConfigurationUpdateItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reasoning == other.reasoning &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, reasoning, agent);

  @override
  String toString() =>
      'ConversationConfigurationUpdateItem(type: $type, id: $id, reasoning: $reasoning, agent: $agent)';
}

/// A message item in a conversation.
@immutable
class ConversationMessageItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The role of the message.
  final ConversationRole role;

  /// The content of the message.
  final List<ConversationContent> content;

  /// Item status.
  final ItemStatus? status;

  /// The phase of the message.
  final MessagePhase? phase;

  /// Creates a [ConversationMessageItem].
  const ConversationMessageItem({
    required this.id,
    required this.role,
    required this.content,
    this.status,
    this.phase,
  });

  /// Creates a [ConversationMessageItem] from JSON.
  factory ConversationMessageItem.fromJson(Map<String, dynamic> json) {
    return ConversationMessageItem(
      id: json['id'] as String,
      role: ConversationRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => ConversationContent.fromJson(e as Map<String, dynamic>))
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
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
    if (phase != null) 'phase': phase!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status &&
          phase == other.phase;

  @override
  int get hashCode =>
      Object.hash(id, role, Object.hashAll(content), status, phase);

  @override
  String toString() =>
      'ConversationMessageItem(id: $id, role: $role, content: $content, status: $status, phase: $phase)';
}

/// A function call item in a conversation.
@immutable
class ConversationFunctionCallItem extends ConversationItem {
  /// The fixed item discriminator.
  String get type => 'function_call';

  /// Unique identifier.
  final String id;

  /// The original call ID used when returning the tool result.
  final String callId;

  /// The name of the tool being called.
  final String name;

  /// Opaque tool arguments.
  final String arguments;

  /// The namespace of the tool, when supplied.
  final String? namespace;

  /// Item status.
  final ItemStatus? status;

  /// The execution context that produced this call.
  final ToolCallCaller? caller;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// Whether the call runs asynchronously. Omission preserves the server default.
  final bool? async;

  /// The identifier of the entity that created this returned item.
  final String? createdBy;

  /// Creates a [ConversationFunctionCallItem].
  const ConversationFunctionCallItem({
    required this.id,
    required this.callId,
    required this.name,
    required this.arguments,
    this.namespace,
    this.status,
    this.caller,
    this.agent,
    this.async,
    this.createdBy,
  });

  /// Creates a [ConversationFunctionCallItem] from JSON.
  factory ConversationFunctionCallItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'function_call', 'ConversationFunctionCallItem');
    return ConversationFunctionCallItem(
      id: requireJsonString(json['id'], 'ConversationFunctionCallItem.id'),
      callId: requireJsonString(
        json['call_id'],
        'ConversationFunctionCallItem.call_id',
      ),
      name: requireJsonString(
        json['name'],
        'ConversationFunctionCallItem.name',
      ),
      arguments: requireJsonString(
        json['arguments'],
        'ConversationFunctionCallItem.arguments',
      ),
      namespace: json['namespace'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      async: optionalJsonBool(json, 'async', 'ConversationFunctionCallItem'),
      createdBy: optionalJsonString(
        json,
        'created_by',
        'ConversationFunctionCallItem',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call',
    'id': id,
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (namespace != null) 'namespace': namespace,
    if (status != null) 'status': status!.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
    if (async != null) 'async': async,
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Copies every field; explicit null clears an optional value.
  ConversationFunctionCallItem copyWith({
    String? id,
    String? callId,
    String? name,
    String? arguments,
    Object? namespace = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ConversationFunctionCallItem(
    id: id ?? this.id,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    status: status == unsetCopyWithValue ? this.status : status as ItemStatus?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
    createdBy: createdBy == unsetCopyWithValue
        ? this.createdBy
        : createdBy as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationFunctionCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          namespace == other.namespace &&
          status == other.status &&
          caller == other.caller &&
          agent == other.agent &&
          async == other.async &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    callId,
    name,
    arguments,
    namespace,
    status,
    caller,
    agent,
    async,
    createdBy,
  );

  @override
  String toString() =>
      'ConversationFunctionCallItem(id: $id, callId: $callId, name: $name, arguments: [${arguments.length} chars], namespace: $namespace, status: $status, caller: $caller, agent: $agent, async: $async, createdBy: $createdBy)';
}

/// A function call output item in a conversation.
@immutable
class ConversationFunctionCallOutputItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content (can be string or list).
  final Object output;

  /// The status of the function call.
  final FunctionCallStatus? status;

  /// Creates a [ConversationFunctionCallOutputItem].
  const ConversationFunctionCallOutputItem({
    required this.id,
    required this.callId,
    required this.output,
    this.status,
  });

  /// Creates a [ConversationFunctionCallOutputItem] from JSON.
  factory ConversationFunctionCallOutputItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationFunctionCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      output: json['output'],
      status: json['status'] != null
          ? FunctionCallStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call_output',
    'id': id,
    'call_id': callId,
    'output': output,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationFunctionCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, output, status);

  @override
  String toString() =>
      'ConversationFunctionCallOutputItem(id: $id, callId: $callId, output: $output, status: $status)';
}

/// A reasoning item in a conversation.
@immutable
class ConversationReasoningItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The reasoning content.
  final List<Map<String, dynamic>>? content;

  /// The reasoning summary.
  final List<ConversationSummaryTextContent> summary;

  /// Encrypted reasoning content (if requested via include).
  final String? encryptedContent;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationReasoningItem].
  const ConversationReasoningItem({
    required this.id,
    this.content,
    required this.summary,
    this.encryptedContent,
    this.status,
  });

  /// Creates a [ConversationReasoningItem] from JSON.
  factory ConversationReasoningItem.fromJson(Map<String, dynamic> json) {
    return ConversationReasoningItem(
      id: json['id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      summary: (json['summary'] as List)
          .map(
            (e) => ConversationSummaryTextContent.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      encryptedContent: json['encrypted_content'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'reasoning',
    'id': id,
    if (content != null) 'content': content,
    'summary': summary.map((e) => e.toJson()).toList(),
    if (encryptedContent != null) 'encrypted_content': encryptedContent,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationReasoningItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(summary, other.summary) &&
          encryptedContent == other.encryptedContent &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, Object.hashAll(summary), encryptedContent, status);

  @override
  String toString() => 'ConversationReasoningItem(id: $id, summary: $summary)';
}

/// An image generation call item in a conversation.
@immutable
class ConversationImageGenerationCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The prompt used for image generation.
  final String? prompt;

  /// The revised prompt (if applicable).
  final String? revisedPrompt;

  /// The generated image result (base64 or URL).
  final String? result;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationImageGenerationCallItem].
  const ConversationImageGenerationCallItem({
    required this.id,
    this.prompt,
    this.revisedPrompt,
    this.result,
    this.status,
  });

  /// Creates a [ConversationImageGenerationCallItem] from JSON.
  factory ConversationImageGenerationCallItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationImageGenerationCallItem(
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
      other is ConversationImageGenerationCallItem &&
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
      'ConversationImageGenerationCallItem(id: $id, prompt: $prompt, status: $status)';
}

/// A local shell call item in a conversation.
@immutable
class ConversationLocalShellCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID.
  final String callId;

  /// The action to perform.
  final Map<String, dynamic>? action;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationLocalShellCallItem].
  const ConversationLocalShellCallItem({
    required this.id,
    required this.callId,
    this.action,
    this.status,
  });

  /// Creates a [ConversationLocalShellCallItem] from JSON.
  factory ConversationLocalShellCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationLocalShellCallItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      action: json['action'] as Map<String, dynamic>?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'local_shell_call',
    'id': id,
    'call_id': callId,
    if (action != null) 'action': action,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationLocalShellCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, action, status);

  @override
  String toString() =>
      'ConversationLocalShellCallItem(id: $id, callId: $callId, status: $status)';
}

/// A local shell call output item in a conversation.
@immutable
class ConversationLocalShellCallOutputItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content.
  final Object output;

  /// Creates a [ConversationLocalShellCallOutputItem].
  const ConversationLocalShellCallOutputItem({
    required this.id,
    required this.callId,
    required this.output,
  });

  /// Creates a [ConversationLocalShellCallOutputItem] from JSON.
  factory ConversationLocalShellCallOutputItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationLocalShellCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      output: json['output'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'local_shell_call_output',
    'id': id,
    'call_id': callId,
    'output': output,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationLocalShellCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId;

  @override
  int get hashCode => Object.hash(id, callId, output);

  @override
  String toString() =>
      'ConversationLocalShellCallOutputItem(id: $id, callId: $callId)';
}

/// An MCP list tools item in a conversation.
@immutable
class ConversationMcpListToolsItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The server label.
  final String? serverLabel;

  /// The list of tools.
  final List<Map<String, dynamic>>? tools;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationMcpListToolsItem].
  const ConversationMcpListToolsItem({
    required this.id,
    this.serverLabel,
    this.tools,
    this.status,
  });

  /// Creates a [ConversationMcpListToolsItem] from JSON.
  factory ConversationMcpListToolsItem.fromJson(Map<String, dynamic> json) {
    return ConversationMcpListToolsItem(
      id: json['id'] as String,
      serverLabel: json['server_label'] as String?,
      tools: (json['tools'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_list_tools',
    'id': id,
    if (serverLabel != null) 'server_label': serverLabel,
    if (tools != null) 'tools': tools,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMcpListToolsItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverLabel == other.serverLabel &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, serverLabel, tools, status);

  @override
  String toString() =>
      'ConversationMcpListToolsItem(id: $id, serverLabel: $serverLabel, status: $status)';
}

/// An MCP approval request item in a conversation.
@immutable
class ConversationMcpApprovalRequestItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The server label.
  final String? serverLabel;

  /// The MCP call being requested.
  final Map<String, dynamic>? mcpCall;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationMcpApprovalRequestItem].
  const ConversationMcpApprovalRequestItem({
    required this.id,
    this.serverLabel,
    this.mcpCall,
    this.status,
  });

  /// Creates a [ConversationMcpApprovalRequestItem] from JSON.
  factory ConversationMcpApprovalRequestItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationMcpApprovalRequestItem(
      id: json['id'] as String,
      serverLabel: json['server_label'] as String?,
      mcpCall: json['mcp_call'] as Map<String, dynamic>?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_approval_request',
    'id': id,
    if (serverLabel != null) 'server_label': serverLabel,
    if (mcpCall != null) 'mcp_call': mcpCall,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMcpApprovalRequestItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverLabel == other.serverLabel &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, serverLabel, mcpCall, status);

  @override
  String toString() =>
      'ConversationMcpApprovalRequestItem(id: $id, serverLabel: $serverLabel, status: $status)';
}

/// An MCP approval response item in a conversation.
@immutable
class ConversationMcpApprovalResponseItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The approval request ID.
  final String? approvalRequestId;

  /// Whether the request was approved.
  final bool? approved;

  /// Creates a [ConversationMcpApprovalResponseItem].
  const ConversationMcpApprovalResponseItem({
    required this.id,
    this.approvalRequestId,
    this.approved,
  });

  /// Creates a [ConversationMcpApprovalResponseItem] from JSON.
  factory ConversationMcpApprovalResponseItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationMcpApprovalResponseItem(
      id: json['id'] as String,
      approvalRequestId: json['approval_request_id'] as String?,
      approved: json['approved'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_approval_response',
    'id': id,
    if (approvalRequestId != null) 'approval_request_id': approvalRequestId,
    if (approved != null) 'approved': approved,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMcpApprovalResponseItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          approvalRequestId == other.approvalRequestId &&
          approved == other.approved;

  @override
  int get hashCode => Object.hash(id, approvalRequestId, approved);

  @override
  String toString() =>
      'ConversationMcpApprovalResponseItem(id: $id, approved: $approved)';
}

/// An MCP call item in a conversation.
@immutable
class ConversationMcpCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID.
  final String callId;

  /// The server label.
  final String? serverLabel;

  /// The tool name.
  final String? name;

  /// The tool arguments.
  final String? arguments;

  /// The tool output.
  final String? output;

  /// The error (if any).
  final String? error;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationMcpCallItem].
  const ConversationMcpCallItem({
    required this.id,
    required this.callId,
    this.serverLabel,
    this.name,
    this.arguments,
    this.output,
    this.error,
    this.status,
  });

  /// Creates a [ConversationMcpCallItem] from JSON.
  factory ConversationMcpCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationMcpCallItem(
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
      other is ConversationMcpCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          name == other.name &&
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
      'ConversationMcpCallItem(id: $id, callId: $callId, name: $name, status: $status)';
}

/// A web search call item in a conversation.
@immutable
class ConversationWebSearchCallItem extends ConversationItem {
  /// The fixed item discriminator.
  String get type => 'web_search_call';

  /// Unique identifier.
  final String id;

  /// The beta multi-agent producer, when provided.
  final AgentTag? agent;

  /// Web search status, including searching and failed states.
  ///
  /// May be null for legacy or partial items.
  final WebSearchCallStatus? status;

  /// The action performed by the web search tool, when supplied.
  final WebSearchAction? action;

  /// Results included with `web_search_call.results`.
  ///
  /// Constructor lists are caller-owned for const compatibility and must not be
  /// mutated after construction. JSON parsing returns an unmodifiable list.
  final List<WebSearchResult>? results;

  /// Creates a [ConversationWebSearchCallItem].
  const ConversationWebSearchCallItem({
    required this.id,
    this.agent,
    this.status,
    this.action,
    this.results,
  });

  /// Creates a [ConversationWebSearchCallItem] from JSON.
  factory ConversationWebSearchCallItem.fromJson(Map<String, dynamic> json) {
    const context = 'ConversationWebSearchCallItem';
    requireJsonType(json, 'web_search_call', context);
    final agent = json['agent'] == null
        ? null
        : requireJsonObject(json['agent'], '$context.agent');
    final rawResults = json['results'];
    if (json.containsKey('results') && rawResults is! List) {
      throw const FormatException('$context.results: expected an array');
    }
    return ConversationWebSearchCallItem(
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
  ConversationWebSearchCallItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? action = unsetCopyWithValue,
    Object? results = unsetCopyWithValue,
  }) => ConversationWebSearchCallItem(
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
      other is ConversationWebSearchCallItem &&
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
      'ConversationWebSearchCallItem(type: $type, id: $id, agent: $agent, status: $status, action: $action, results: ${results == null ? 'null' : '${results!.length} items'})';
}

/// A file search call item in a conversation.
@immutable
class ConversationFileSearchCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The queries performed.
  final List<String>? queries;

  /// The search results.
  final List<Map<String, dynamic>>? results;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationFileSearchCallItem].
  const ConversationFileSearchCallItem({
    required this.id,
    this.queries,
    this.results,
    this.status,
  });

  /// Creates a [ConversationFileSearchCallItem] from JSON.
  factory ConversationFileSearchCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationFileSearchCallItem(
      id: json['id'] as String,
      queries: (json['queries'] as List?)?.map((e) => e as String).toList(),
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
      other is ConversationFileSearchCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, queries, results, status);

  @override
  String toString() =>
      'ConversationFileSearchCallItem(id: $id, status: $status)';
}

/// A computer call item in a conversation.
@immutable
class ConversationComputerCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID.
  final String callId;

  /// The action to perform.
  final Map<String, dynamic>? action;

  /// Pending safety checks.
  final List<Map<String, dynamic>>? pendingSafetyChecks;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationComputerCallItem].
  const ConversationComputerCallItem({
    required this.id,
    required this.callId,
    this.action,
    this.pendingSafetyChecks,
    this.status,
  });

  /// Creates a [ConversationComputerCallItem] from JSON.
  factory ConversationComputerCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationComputerCallItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      action: json['action'] as Map<String, dynamic>?,
      pendingSafetyChecks: (json['pending_safety_checks'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'computer_call',
    'id': id,
    'call_id': callId,
    if (action != null) 'action': action,
    if (pendingSafetyChecks != null)
      'pending_safety_checks': pendingSafetyChecks,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationComputerCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, callId, action, pendingSafetyChecks, status);

  @override
  String toString() =>
      'ConversationComputerCallItem(id: $id, callId: $callId, status: $status)';
}

/// A computer call output item in a conversation.
@immutable
class ConversationComputerCallOutputItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content.
  final Object output;

  /// Creates a [ConversationComputerCallOutputItem].
  const ConversationComputerCallOutputItem({
    required this.id,
    required this.callId,
    required this.output,
  });

  /// Creates a [ConversationComputerCallOutputItem] from JSON.
  factory ConversationComputerCallOutputItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationComputerCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      output: json['output'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'computer_call_output',
    'id': id,
    'call_id': callId,
    'output': output,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationComputerCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId;

  @override
  int get hashCode => Object.hash(id, callId);

  @override
  String toString() =>
      'ConversationComputerCallOutputItem(id: $id, callId: $callId)';
}

/// A code interpreter call item in a conversation.
@immutable
class ConversationCodeInterpreterCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The code being executed.
  final String? code;

  /// The language of the code.
  final String? language;

  /// The outputs from execution.
  final List<Map<String, dynamic>>? outputs;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationCodeInterpreterCallItem].
  const ConversationCodeInterpreterCallItem({
    required this.id,
    this.code,
    this.language,
    this.outputs,
    this.status,
  });

  /// Creates a [ConversationCodeInterpreterCallItem] from JSON.
  factory ConversationCodeInterpreterCallItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationCodeInterpreterCallItem(
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
      other is ConversationCodeInterpreterCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, code, language, outputs, status);

  @override
  String toString() =>
      'ConversationCodeInterpreterCallItem(id: $id, code: $code, status: $status)';
}

/// A tool search call item in a conversation.
@immutable
class ConversationToolSearchCallItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID.
  final String? callId;

  /// The execution type.
  final ToolSearchExecutionType? execution;

  /// The arguments.
  final Map<String, dynamic>? arguments;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationToolSearchCallItem].
  const ConversationToolSearchCallItem({
    required this.id,
    this.callId,
    this.execution,
    this.arguments,
    this.status,
  });

  /// Creates a [ConversationToolSearchCallItem] from JSON.
  factory ConversationToolSearchCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationToolSearchCallItem(
      id: json['id'] as String,
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
    'id': id,
    if (callId != null) 'call_id': callId,
    if (execution != null) 'execution': execution!.toJson(),
    if (arguments != null) 'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationToolSearchCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          execution == other.execution &&
          mapsDeepEqual(arguments, other.arguments) &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, callId, execution, mapDeepHashCode(arguments), status);

  @override
  String toString() =>
      'ConversationToolSearchCallItem(id: $id, callId: $callId, execution: $execution, status: $status)';
}

/// A tool search output item in a conversation.
@immutable
class ConversationToolSearchOutputItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The call ID.
  final String? callId;

  /// The execution type.
  final ToolSearchExecutionType? execution;

  /// The discovered tools.
  final List<ResponseTool>? tools;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationToolSearchOutputItem].
  const ConversationToolSearchOutputItem({
    required this.id,
    this.callId,
    this.execution,
    this.tools,
    this.status,
  });

  /// Creates a [ConversationToolSearchOutputItem] from JSON.
  factory ConversationToolSearchOutputItem.fromJson(Map<String, dynamic> json) {
    return ConversationToolSearchOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String?,
      execution: json['execution'] != null
          ? ToolSearchExecutionType.fromJson(json['execution'] as String)
          : null,
      tools: (json['tools'] as List?)
          ?.map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search_output',
    'id': id,
    if (callId != null) 'call_id': callId,
    if (execution != null) 'execution': execution!.toJson(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationToolSearchOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          execution == other.execution &&
          listsEqual(tools, other.tools) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    callId,
    execution,
    tools != null ? Object.hashAll(tools!) : null,
    status,
  );

  @override
  String toString() =>
      'ConversationToolSearchOutputItem(id: $id, callId: $callId, execution: $execution, status: $status)';
}

/// A compaction item in a conversation.
@immutable
class ConversationCompactionItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// Encrypted compaction payload.
  final String encryptedContent;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// Creates a [ConversationCompactionItem].
  const ConversationCompactionItem({
    required this.id,
    required this.encryptedContent,
    this.createdBy,
  });

  /// Creates a [ConversationCompactionItem] from JSON.
  factory ConversationCompactionItem.fromJson(Map<String, dynamic> json) {
    return ConversationCompactionItem(
      id: json['id'] as String,
      encryptedContent: json['encrypted_content'] as String,
      createdBy: json['created_by'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction',
    'id': id,
    'encrypted_content': encryptedContent,
    if (createdBy != null) 'created_by': createdBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationCompactionItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          encryptedContent == other.encryptedContent &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(id, encryptedContent, createdBy);

  @override
  String toString() =>
      'ConversationCompactionItem(id: $id, encryptedContent: ${encryptedContent.length} chars)';
}

/// A custom tool call item in a conversation.
@immutable
class ConversationCustomToolCallItem extends ConversationItem {
  /// The fixed item discriminator.
  String get type => 'custom_tool_call';

  /// Unique identifier, when supplied.
  final String? id;

  /// The original call ID used when returning the tool result.
  final String callId;

  /// The name of the tool being called.
  final String name;

  /// Opaque tool input.
  final String input;

  /// The namespace of the tool, when supplied.
  final String? namespace;

  /// Item status.
  final ItemStatus? status;

  /// The execution context that produced this call.
  final ToolCallCaller? caller;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// Whether the call runs asynchronously. Omission preserves the server default.
  final bool? async;

  /// The identifier of the entity that created this returned item.
  final String? createdBy;

  /// Creates a [ConversationCustomToolCallItem].
  const ConversationCustomToolCallItem({
    this.id,
    required this.callId,
    required this.name,
    required this.input,
    this.namespace,
    this.status,
    this.caller,
    this.agent,
    this.async,
    this.createdBy,
  });

  /// Creates a [ConversationCustomToolCallItem] from JSON.
  factory ConversationCustomToolCallItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'custom_tool_call', 'ConversationCustomToolCallItem');
    return ConversationCustomToolCallItem(
      id: json['id'] as String?,
      callId: requireJsonString(
        json['call_id'],
        'ConversationCustomToolCallItem.call_id',
      ),
      name: requireJsonString(
        json['name'],
        'ConversationCustomToolCallItem.name',
      ),
      input: requireJsonString(
        json['input'],
        'ConversationCustomToolCallItem.input',
      ),
      namespace: json['namespace'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      async: optionalJsonBool(json, 'async', 'ConversationCustomToolCallItem'),
      createdBy: optionalJsonString(
        json,
        'created_by',
        'ConversationCustomToolCallItem',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call',
    if (id != null) 'id': id,
    'call_id': callId,
    'name': name,
    'input': input,
    if (namespace != null) 'namespace': namespace,
    if (status != null) 'status': status!.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
    if (async != null) 'async': async,
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Copies every field; explicit null clears an optional value.
  ConversationCustomToolCallItem copyWith({
    Object? id = unsetCopyWithValue,
    String? callId,
    String? name,
    String? input,
    Object? namespace = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ConversationCustomToolCallItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    input: input ?? this.input,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    status: status == unsetCopyWithValue ? this.status : status as ItemStatus?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
    createdBy: createdBy == unsetCopyWithValue
        ? this.createdBy
        : createdBy as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationCustomToolCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          name == other.name &&
          input == other.input &&
          namespace == other.namespace &&
          status == other.status &&
          caller == other.caller &&
          agent == other.agent &&
          async == other.async &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    callId,
    name,
    input,
    namespace,
    status,
    caller,
    agent,
    async,
    createdBy,
  );

  @override
  String toString() =>
      'ConversationCustomToolCallItem(id: $id, callId: $callId, name: $name, input: [${input.length} chars], namespace: $namespace, status: $status, caller: $caller, agent: $agent, async: $async, createdBy: $createdBy)';
}

/// A custom tool call output item in a conversation.
@immutable
class ConversationCustomToolCallOutputItem extends ConversationItem {
  /// Unique identifier.
  final String? id;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output from the custom tool call.
  final FunctionCallOutput output;

  /// The status of the item.
  final ItemStatus? status;

  /// Creates a [ConversationCustomToolCallOutputItem].
  const ConversationCustomToolCallOutputItem({
    this.id,
    required this.callId,
    required this.output,
    this.status,
  });

  /// Creates a [ConversationCustomToolCallOutputItem] from JSON.
  factory ConversationCustomToolCallOutputItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationCustomToolCallOutputItem(
      id: json['id'] as String?,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call_output',
    if (id != null) 'id': id,
    'call_id': callId,
    'output': output.toJson(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationCustomToolCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          output == other.output &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, output, status);

  @override
  String toString() =>
      'ConversationCustomToolCallOutputItem(id: $id, callId: $callId, status: $status)';
}

/// An additional tools item in a conversation.
///
/// Surfaces the additional tool definitions that were made available at this
/// point in the conversation.
@immutable
class ConversationAdditionalToolsItem extends ConversationItem {
  /// Unique identifier.
  final String id;

  /// The role that provided the additional tools.
  final ConversationRole role;

  /// The additional tool definitions made available at this item.
  final List<ResponseTool> tools;

  /// Creates a [ConversationAdditionalToolsItem].
  const ConversationAdditionalToolsItem({
    required this.id,
    required this.role,
    required this.tools,
  });

  /// Creates a [ConversationAdditionalToolsItem] from JSON.
  factory ConversationAdditionalToolsItem.fromJson(Map<String, dynamic> json) {
    return ConversationAdditionalToolsItem(
      id: json['id'] as String,
      role: ConversationRole.fromJson(json['role'] as String),
      tools: (json['tools'] as List)
          .map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'additional_tools',
    'id': id,
    'role': role.toJson(),
    'tools': tools.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdditionalToolsItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(id, role, Object.hashAll(tools));

  @override
  String toString() =>
      'ConversationAdditionalToolsItem(id: $id, role: $role, tools: $tools)';
}

/// An unknown item type (for forward compatibility).
@immutable
class ConversationUnknownItem extends ConversationItem {
  /// The item type.
  final String type;

  /// The raw JSON data.
  final Map<String, dynamic> data;

  /// Creates a [ConversationUnknownItem].
  const ConversationUnknownItem({required this.type, required this.data});

  @override
  Map<String, dynamic> toJson() => data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationUnknownItem &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ConversationUnknownItem(type: $type)';
}
