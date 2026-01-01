import 'package:meta/meta.dart';

import '../tools/tool_call.dart';

/// A sealed class representing an entry in a conversation.
///
/// Conversation entries represent different types of interactions in a
/// conversation, including user messages, assistant messages, tool calls,
/// and tool results.
@immutable
sealed class ConversationEntry {
  /// Creates a [ConversationEntry].
  const ConversationEntry();

  /// The type of this entry.
  String get type;

  /// Creates a [ConversationEntry] from JSON.
  factory ConversationEntry.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'message.input' => MessageInputEntry.fromJson(json),
      'message.output' => MessageOutputEntry.fromJson(json),
      'function.call' => FunctionCallEntry.fromJson(json),
      'function.result' => FunctionResultEntry.fromJson(json),
      'tool.execution' => ToolExecutionEntry.fromJson(json),
      'agent.handoff' => AgentHandoffEntry.fromJson(json),
      _ => MessageInputEntry.fromJson(json), // Default fallback
    };
  }

  /// Converts this entry to JSON.
  Map<String, dynamic> toJson();

  /// Creates a user message entry.
  factory ConversationEntry.userMessage(String content, {String? id}) =>
      MessageInputEntry(content: content, id: id);

  /// Creates an assistant message entry.
  factory ConversationEntry.assistantMessage(
    String content, {
    String? id,
    List<ToolCall>? toolCalls,
  }) => MessageOutputEntry(content: content, id: id, toolCalls: toolCalls);
}

/// An input message entry (typically from the user).
@immutable
class MessageInputEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The content of the message.
  final String content;

  /// The role of the message sender.
  final String role;

  /// Creates a [MessageInputEntry].
  const MessageInputEntry({this.id, required this.content, this.role = 'user'});

  @override
  String get type => 'message.input';

  /// Creates a [MessageInputEntry] from JSON.
  factory MessageInputEntry.fromJson(Map<String, dynamic> json) {
    return MessageInputEntry(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'role': role,
      'content': content,
      if (id != null) 'id': id,
    };
  }

  /// Creates a copy with the given fields replaced.
  MessageInputEntry copyWith({String? id, String? content, String? role}) {
    return MessageInputEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageInputEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content;

  @override
  int get hashCode => Object.hash(id, content);

  @override
  String toString() =>
      'MessageInputEntry(role: $role, content: ${content.length} chars)';
}

/// An output message entry (typically from the assistant).
@immutable
class MessageOutputEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The content of the message.
  final String content;

  /// The role of the message sender.
  final String role;

  /// Tool calls made by the assistant.
  final List<ToolCall>? toolCalls;

  /// Creates a [MessageOutputEntry].
  const MessageOutputEntry({
    this.id,
    required this.content,
    this.role = 'assistant',
    this.toolCalls,
  });

  @override
  String get type => 'message.output';

  /// Creates a [MessageOutputEntry] from JSON.
  factory MessageOutputEntry.fromJson(Map<String, dynamic> json) {
    return MessageOutputEntry(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      role: json['role'] as String? ?? 'assistant',
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'role': role,
      'content': content,
      if (id != null) 'id': id,
      if (toolCalls != null)
        'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy with the given fields replaced.
  MessageOutputEntry copyWith({
    String? id,
    String? content,
    String? role,
    List<ToolCall>? toolCalls,
  }) {
    return MessageOutputEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      toolCalls: toolCalls ?? this.toolCalls,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageOutputEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content;

  @override
  int get hashCode => Object.hash(id, content);

  @override
  String toString() =>
      'MessageOutputEntry(role: $role, content: ${content.length} chars)';
}

/// A function call entry representing a tool invocation request.
@immutable
class FunctionCallEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The name of the function to call.
  final String name;

  /// The arguments to pass to the function (JSON string).
  final String arguments;

  /// The ID of the tool call.
  final String? callId;

  /// Creates a [FunctionCallEntry].
  const FunctionCallEntry({
    this.id,
    required this.name,
    required this.arguments,
    this.callId,
  });

  @override
  String get type => 'function.call';

  /// Creates a [FunctionCallEntry] from JSON.
  factory FunctionCallEntry.fromJson(Map<String, dynamic> json) {
    return FunctionCallEntry(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      arguments: json['arguments'] as String? ?? '',
      callId: json['call_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'arguments': arguments,
      if (id != null) 'id': id,
      if (callId != null) 'call_id': callId,
    };
  }

  /// Creates a copy with the given fields replaced.
  FunctionCallEntry copyWith({
    String? id,
    String? name,
    String? arguments,
    String? callId,
  }) {
    return FunctionCallEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      callId: callId ?? this.callId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'FunctionCallEntry(name: $name)';
}

/// A function result entry representing the output of a tool execution.
@immutable
class FunctionResultEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The ID of the tool call this result corresponds to.
  final String callId;

  /// The result of the function execution.
  final String result;

  /// Whether the function execution resulted in an error.
  final bool? isError;

  /// Creates a [FunctionResultEntry].
  const FunctionResultEntry({
    this.id,
    required this.callId,
    required this.result,
    this.isError,
  });

  @override
  String get type => 'function.result';

  /// Creates a [FunctionResultEntry] from JSON.
  factory FunctionResultEntry.fromJson(Map<String, dynamic> json) {
    return FunctionResultEntry(
      id: json['id'] as String?,
      callId: json['call_id'] as String? ?? '',
      result: json['result'] as String? ?? '',
      isError: json['is_error'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'call_id': callId,
      'result': result,
      if (id != null) 'id': id,
      if (isError != null) 'is_error': isError,
    };
  }

  /// Creates a copy with the given fields replaced.
  FunctionResultEntry copyWith({
    String? id,
    String? callId,
    String? result,
    bool? isError,
  }) {
    return FunctionResultEntry(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      result: result ?? this.result,
      isError: isError ?? this.isError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionResultEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId;

  @override
  int get hashCode => Object.hash(id, callId);

  @override
  String toString() => 'FunctionResultEntry(callId: $callId)';
}

/// A tool execution entry representing the complete lifecycle of a tool use.
@immutable
class ToolExecutionEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The type of tool executed.
  final String toolType;

  /// The input to the tool.
  final Map<String, dynamic>? input;

  /// The output from the tool.
  final Map<String, dynamic>? output;

  /// The status of the execution.
  final String? status;

  /// Creates a [ToolExecutionEntry].
  const ToolExecutionEntry({
    this.id,
    required this.toolType,
    this.input,
    this.output,
    this.status,
  });

  @override
  String get type => 'tool.execution';

  /// Creates a [ToolExecutionEntry] from JSON.
  factory ToolExecutionEntry.fromJson(Map<String, dynamic> json) {
    return ToolExecutionEntry(
      id: json['id'] as String?,
      toolType: json['tool_type'] as String? ?? '',
      input: json['input'] as Map<String, dynamic>?,
      output: json['output'] as Map<String, dynamic>?,
      status: json['status'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'tool_type': toolType,
      if (id != null) 'id': id,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (status != null) 'status': status,
    };
  }

  /// Creates a copy with the given fields replaced.
  ToolExecutionEntry copyWith({
    String? id,
    String? toolType,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    String? status,
  }) {
    return ToolExecutionEntry(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      input: input ?? this.input,
      output: output ?? this.output,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolExecutionEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          toolType == other.toolType;

  @override
  int get hashCode => Object.hash(id, toolType);

  @override
  String toString() => 'ToolExecutionEntry(toolType: $toolType)';
}

/// An agent handoff entry for transferring control between agents.
@immutable
class AgentHandoffEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The ID of the agent to hand off to.
  final String targetAgentId;

  /// The reason for the handoff.
  final String? reason;

  /// Additional context for the handoff.
  final Map<String, dynamic>? context;

  /// Creates an [AgentHandoffEntry].
  const AgentHandoffEntry({
    this.id,
    required this.targetAgentId,
    this.reason,
    this.context,
  });

  @override
  String get type => 'agent.handoff';

  /// Creates an [AgentHandoffEntry] from JSON.
  factory AgentHandoffEntry.fromJson(Map<String, dynamic> json) {
    return AgentHandoffEntry(
      id: json['id'] as String?,
      targetAgentId: json['target_agent_id'] as String? ?? '',
      reason: json['reason'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'target_agent_id': targetAgentId,
      if (id != null) 'id': id,
      if (reason != null) 'reason': reason,
      if (context != null) 'context': context,
    };
  }

  /// Creates a copy with the given fields replaced.
  AgentHandoffEntry copyWith({
    String? id,
    String? targetAgentId,
    String? reason,
    Map<String, dynamic>? context,
  }) {
    return AgentHandoffEntry(
      id: id ?? this.id,
      targetAgentId: targetAgentId ?? this.targetAgentId,
      reason: reason ?? this.reason,
      context: context ?? this.context,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentHandoffEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          targetAgentId == other.targetAgentId;

  @override
  int get hashCode => Object.hash(id, targetAgentId);

  @override
  String toString() => 'AgentHandoffEntry(targetAgentId: $targetAgentId)';
}
