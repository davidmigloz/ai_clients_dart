import 'package:meta/meta.dart';

import '../responses/common/equality_helpers.dart';
import '../responses/config/function_call_status.dart';
import '../responses/config/item_status.dart';
import 'conversation_content.dart';
import 'conversation_message.dart';

/// An item stored in a conversation.
///
/// This sealed class hierarchy represents the different types of items
/// that can be stored in a conversation, including output item types
/// from the Responses API and conversation-specific types.
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
      _ => ConversationUnknownItem(type: type, data: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
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

  /// Creates a [ConversationMessageItem].
  const ConversationMessageItem({
    required this.id,
    required this.role,
    required this.content,
    this.status,
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
      other is ConversationMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, role, content, status);

  @override
  String toString() =>
      'ConversationMessageItem(id: $id, role: $role, content: $content, status: $status)';
}

/// A function call item in a conversation.
@immutable
class ConversationFunctionCallItem extends ConversationItem {
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

  /// Creates a [ConversationFunctionCallItem].
  const ConversationFunctionCallItem({
    required this.id,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
  });

  /// Creates a [ConversationFunctionCallItem] from JSON.
  factory ConversationFunctionCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationFunctionCallItem(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationFunctionCallItem &&
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
      'ConversationFunctionCallItem(id: $id, callId: $callId, name: $name, arguments: $arguments, status: $status)';
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
      Object.hash(id, content, summary, encryptedContent, status);

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
  /// Unique identifier.
  final String id;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [ConversationWebSearchCallItem].
  const ConversationWebSearchCallItem({required this.id, this.status});

  /// Creates a [ConversationWebSearchCallItem] from JSON.
  factory ConversationWebSearchCallItem.fromJson(Map<String, dynamic> json) {
    return ConversationWebSearchCallItem(
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
      other is ConversationWebSearchCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, status);

  @override
  String toString() =>
      'ConversationWebSearchCallItem(id: $id, status: $status)';
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
  int get hashCode => Object.hash(id, callId, output);

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
