import 'dart:convert';

import 'package:meta/meta.dart';

import '../chat/message_content.dart';
import '../common/copy_with_sentinel.dart';
import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';
import '../tools/tool_call.dart';
import 'confirmation_status.dart';

/// A sealed class representing an entry in a conversation.
///
/// Conversation entries represent different types of interactions in a
/// conversation. The variants are [MessageInputEntry], [MessageOutputEntry],
/// [FunctionCallEntry], [FunctionResultEntry], [ToolExecutionEntry],
/// [AgentHandoffEntry], and [UnknownConversationEntry].
@immutable
sealed class ConversationEntry {
  /// Creates a [ConversationEntry].
  const ConversationEntry({this.object, this.createdAt, this.completedAt});

  /// The object tag supplied for this entry.
  final String? object;

  /// When this entry was created, as an ISO 8601 timestamp.
  final String? createdAt;

  /// When this entry completed, as an ISO 8601 timestamp.
  final String? completedAt;

  Map<String, dynamic> _metadataJson() => {
    'object': ?object,
    'created_at': ?createdAt,
    'completed_at': ?completedAt,
  };

  /// The type of this entry.
  String get type;

  /// Creates a [ConversationEntry] from JSON.
  factory ConversationEntry.fromJson(Map<String, dynamic> json) {
    final type = _optionalText(json['type']);
    return switch (type) {
      'message.input' => MessageInputEntry.fromJson(json),
      'message.output' => MessageOutputEntry.fromJson(json),
      'function.call' => FunctionCallEntry.fromJson(json),
      'function.result' => FunctionResultEntry.fromJson(json),
      'tool.execution' => ToolExecutionEntry.fromJson(json),
      'agent.handoff' => AgentHandoffEntry.fromJson(json),
      _ => UnknownConversationEntry(json),
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

/// An input message entry.
@immutable
class MessageInputEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// Message text. In structured content this joins the text parts.
  String get content => messageContent.text ?? '';

  /// Full content including any non-text parts.
  MessageContent get messageContent =>
      _messageContent ?? MessageContent.text(_content!);

  final String? _content;
  final MessageContent? _messageContent;

  /// The role of the message sender.
  final String role;

  /// Whether this input is an assistant prefix.
  final bool? prefix;

  /// Creates a [MessageInputEntry].
  const MessageInputEntry({
    this.id,
    required String this._content,
    this.role = 'user',
    this.prefix,
    super.object,
    super.createdAt,
    super.completedAt,
  }) : _messageContent = null;

  /// Creates a [MessageInputEntry] with typed content.
  const MessageInputEntry.structured({
    this.id,
    required MessageContent content,
    this.role = 'user',
    this.prefix,
    super.object,
    super.createdAt,
    super.completedAt,
  }) : _content = null,
       _messageContent = content;

  @override
  String get type => 'message.input';

  /// Creates a [MessageInputEntry] from JSON.
  factory MessageInputEntry.fromJson(Map<String, dynamic> json) {
    return MessageInputEntry.structured(
      id: json['id'] as String?,
      content: MessageContent.fromJson(json['content'] as Object? ?? ''),
      role: json['role'] as String? ?? 'user',
      prefix: json['prefix'] as bool?,
      object: json['object'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ..._metadataJson(),
      'role': role,
      'content': messageContent.toJson(),
      if (id != null) 'id': id,
      'prefix': ?prefix,
    };
  }

  /// Creates a copy with the given fields replaced.
  MessageInputEntry copyWith({
    String? id,
    String? content,
    String? role,
    MessageContent? messageContent,
    Object? prefix = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
  }) {
    return MessageInputEntry.structured(
      id: id ?? this.id,
      content:
          messageContent ??
          (content == null
              ? this.messageContent
              : MessageContent.text(content)),
      role: role ?? this.role,
      prefix: prefix == unsetCopyWithValue ? this.prefix : prefix as bool?,
      object: object == unsetCopyWithValue ? this.object : object as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageInputEntry &&
          id == other.id &&
          messageContent == other.messageContent &&
          role == other.role &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          prefix == other.prefix;

  @override
  int get hashCode => Object.hash(
    id,
    messageContent,
    role,
    object,
    createdAt,
    completedAt,
    prefix,
  );

  @override
  String toString() =>
      'MessageInputEntry(role: $role, content: ${content.length} chars)';
}

/// An output message entry.
@immutable
class MessageOutputEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// Message text. In structured content this joins the text parts.
  String get content => messageContent.text ?? '';

  /// Full content including any non-text parts.
  MessageContent get messageContent =>
      _messageContent ?? MessageContent.text(_content!);

  final String? _content;
  final MessageContent? _messageContent;

  /// The role of the message sender.
  final String role;

  /// Tool calls made by the assistant.
  final List<ToolCall>? toolCalls;

  /// ID of the agent that generated the message.
  final String? agentId;

  /// Model that generated the message.
  final String? model;

  /// Creates a [MessageOutputEntry].
  const MessageOutputEntry({
    this.id,
    required String this._content,
    this.role = 'assistant',
    this.toolCalls,
    this.agentId,
    this.model,
    super.object,
    super.createdAt,
    super.completedAt,
  }) : _messageContent = null;

  /// Creates a [MessageOutputEntry] with typed content.
  const MessageOutputEntry.structured({
    this.id,
    required MessageContent content,
    this.role = 'assistant',
    this.toolCalls,
    this.agentId,
    this.model,
    super.object,
    super.createdAt,
    super.completedAt,
  }) : _content = null,
       _messageContent = content;

  @override
  String get type => 'message.output';

  /// Creates a [MessageOutputEntry] from JSON.
  factory MessageOutputEntry.fromJson(Map<String, dynamic> json) {
    return MessageOutputEntry.structured(
      id: json['id'] as String?,
      content: MessageContent.fromJson(json['content'] as Object? ?? ''),
      role: json['role'] as String? ?? 'assistant',
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      agentId: json['agent_id'] as String?,
      model: json['model'] as String?,
      object: json['object'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ..._metadataJson(),
      'role': role,
      'content': messageContent.toJson(),
      if (id != null) 'id': id,
      if (toolCalls != null)
        'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
      'agent_id': ?agentId,
      'model': ?model,
    };
  }

  /// Creates a copy with the given fields replaced.
  MessageOutputEntry copyWith({
    String? id,
    String? content,
    String? role,
    List<ToolCall>? toolCalls,
    MessageContent? messageContent,
    Object? agentId = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
  }) {
    return MessageOutputEntry.structured(
      id: id ?? this.id,
      content:
          messageContent ??
          (content == null
              ? this.messageContent
              : MessageContent.text(content)),
      role: role ?? this.role,
      toolCalls: toolCalls ?? this.toolCalls,
      agentId: agentId == unsetCopyWithValue
          ? this.agentId
          : agentId as String?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      object: object == unsetCopyWithValue ? this.object : object as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageOutputEntry &&
          id == other.id &&
          messageContent == other.messageContent &&
          role == other.role &&
          listsEqual(toolCalls, other.toolCalls) &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          agentId == other.agentId &&
          model == other.model;

  @override
  int get hashCode => Object.hash(
    id,
    messageContent,
    role,
    listHash(toolCalls),
    object,
    createdAt,
    completedAt,
    agentId,
    model,
  );

  @override
  String toString() =>
      'MessageOutputEntry(role: $role, content: ${content.length} chars)';
}

/// A function invocation request.
@immutable
class FunctionCallEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The name of the function to call.
  final String name;

  /// The arguments to pass to the function (JSON string).
  String get arguments =>
      argumentsObject == null ? _textArguments : jsonEncode(argumentsObject);

  final String _textArguments;

  /// The ID of the tool call.
  final String? callId;

  /// The wire tool-call identifier.
  String? get toolCallId => callId;

  /// The ID of the agent that made this call.
  final String? agentId;

  /// The confirmation status of this tool call.
  final ConfirmationStatus? confirmationStatus;

  /// The model used for this function call.
  final String? model;

  /// Structured arguments, when the API uses the object form.
  final Map<String, dynamic>? argumentsObject;

  /// Creates a [FunctionCallEntry].
  const FunctionCallEntry({
    this.id,
    required this.name,
    required String arguments,
    this.callId,
    this.agentId,
    this.confirmationStatus,
    this.model,
    this.argumentsObject,
    super.object,
    super.createdAt,
    super.completedAt,
  }) : _textArguments = arguments;

  @override
  String get type => 'function.call';

  /// Creates a [FunctionCallEntry] from JSON.
  factory FunctionCallEntry.fromJson(Map<String, dynamic> json) {
    return FunctionCallEntry(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      arguments: json['arguments'] is String ? json['arguments'] as String : '',
      callId: json['tool_call_id'] as String? ?? json['call_id'] as String?,
      agentId: json['agent_id'] as String?,
      confirmationStatus: json['confirmation_status'] != null
          ? ConfirmationStatus.fromJson(json['confirmation_status'] as String)
          : null,
      model: json['model'] as String?,
      argumentsObject: json['arguments'] is Map<String, dynamic>
          ? json['arguments'] as Map<String, dynamic>
          : null,
      object: json['object'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ..._metadataJson(),
      'name': name,
      'arguments': argumentsObject ?? arguments,
      if (id != null) 'id': id,
      if (callId != null) 'tool_call_id': callId,
      if (agentId != null) 'agent_id': agentId,
      if (confirmationStatus != null)
        'confirmation_status': confirmationStatus!.toJson(),
      if (model != null) 'model': model,
    };
  }

  /// Creates a copy with the given fields replaced.
  FunctionCallEntry copyWith({
    String? id,
    String? name,
    String? arguments,
    String? callId,
    String? agentId,
    ConfirmationStatus? confirmationStatus,
    String? model,
    Object? argumentsObject = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
  }) {
    return FunctionCallEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      callId: callId ?? this.callId,
      agentId: agentId ?? this.agentId,
      confirmationStatus: confirmationStatus ?? this.confirmationStatus,
      model: model ?? this.model,
      argumentsObject: argumentsObject == unsetCopyWithValue
          ? (arguments == null ? this.argumentsObject : null)
          : (argumentsObject as Map?)?.cast<String, dynamic>(),
      object: object == unsetCopyWithValue ? this.object : object as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallEntry &&
          id == other.id &&
          name == other.name &&
          (argumentsObject != null || arguments == other.arguments) &&
          callId == other.callId &&
          agentId == other.agentId &&
          confirmationStatus == other.confirmationStatus &&
          model == other.model &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          mapsDeepEqual(argumentsObject, other.argumentsObject);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    argumentsObject == null ? arguments : null,
    callId,
    agentId,
    confirmationStatus,
    model,
    object,
    createdAt,
    completedAt,
    mapDeepHashCode(argumentsObject),
  );

  @override
  String toString() => 'FunctionCallEntry(name: $name)';
}

/// A function result entry.
@immutable
class FunctionResultEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The ID of the tool call this result corresponds to.
  final String callId;

  /// The wire tool-call identifier.
  String get toolCallId => callId;

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
    super.object,
    super.createdAt,
    super.completedAt,
  });

  @override
  String get type => 'function.result';

  /// Creates a [FunctionResultEntry] from JSON.
  factory FunctionResultEntry.fromJson(Map<String, dynamic> json) {
    return FunctionResultEntry(
      id: json['id'] as String?,
      callId:
          json['tool_call_id'] as String? ?? json['call_id'] as String? ?? '',
      result: json['result'] as String? ?? '',
      isError: json['is_error'] as bool?,
      object: json['object'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ..._metadataJson(),
      'tool_call_id': callId,
      'result': result,
      if (id != null) 'id': id,
    };
  }

  /// Creates a copy with the given fields replaced.
  FunctionResultEntry copyWith({
    String? id,
    String? callId,
    String? result,
    bool? isError,
    Object? object = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
  }) {
    return FunctionResultEntry(
      id: id ?? this.id,
      callId: callId ?? this.callId,
      result: result ?? this.result,
      isError: isError ?? this.isError,
      object: object == unsetCopyWithValue ? this.object : object as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionResultEntry &&
          id == other.id &&
          callId == other.callId &&
          result == other.result &&
          isError == other.isError &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      Object.hash(id, callId, result, isError, object, createdAt, completedAt);

  @override
  String toString() => 'FunctionResultEntry(callId: $callId)';
}

/// A completed or pending tool execution.
@immutable
class ToolExecutionEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The type of tool executed.
  final String toolType;

  /// Name of the tool that ran.
  String get name => toolType;

  /// The input to the tool.
  Map<String, dynamic>? get input => _input ?? _decodeToolArguments(arguments);
  final Map<String, dynamic>? _input;

  /// The output from the tool.
  Map<String, dynamic>? get output => _output ?? info;
  final Map<String, dynamic>? _output;

  /// The status of the execution.
  final String? status;

  /// The ID of the agent that initiated the tool execution.
  final String? agentId;

  /// The model used for this tool execution.
  final String? model;

  /// The raw argument string supplied to the tool.
  final String? arguments;

  /// Additional execution details supplied by the tool.
  final Map<String, dynamic>? info;

  /// Creates a [ToolExecutionEntry].
  const ToolExecutionEntry({
    this.id,
    required this.toolType,
    this._input,
    this._output,
    this.status,
    this.agentId,
    this.model,
    this.arguments,
    this.info,
    super.object,
    super.createdAt,
    super.completedAt,
  });

  @override
  String get type => 'tool.execution';

  /// Creates a [ToolExecutionEntry] from JSON.
  factory ToolExecutionEntry.fromJson(Map<String, dynamic> json) {
    return ToolExecutionEntry(
      id: json['id'] as String?,
      toolType: json['name'] as String? ?? json['tool_type'] as String? ?? '',
      input: json['input'] as Map<String, dynamic>?,
      output: json['output'] as Map<String, dynamic>?,
      status: json['status'] as String?,
      agentId: json['agent_id'] as String?,
      model: json['model'] as String?,
      arguments: json['arguments'] as String?,
      info: json['info'] as Map<String, dynamic>?,
      object: json['object'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ..._metadataJson(),
      'name': toolType,
      'arguments': arguments ?? jsonEncode(_input ?? const <String, dynamic>{}),
      'info': ?(info ?? _output),
      if (id != null) 'id': id,

      if (agentId != null) 'agent_id': agentId,
      if (model != null) 'model': model,
    };
  }

  /// Creates a copy with the given fields replaced.
  ToolExecutionEntry copyWith({
    String? id,
    String? toolType,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    String? status,
    String? agentId,
    String? model,
    Object? arguments = unsetCopyWithValue,
    Object? info = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
  }) {
    return ToolExecutionEntry(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      input: input ?? _input,
      output: output ?? _output,
      status: status ?? this.status,
      agentId: agentId ?? this.agentId,
      model: model ?? this.model,
      arguments: arguments == unsetCopyWithValue
          ? (input == null ? this.arguments : null)
          : arguments as String?,
      info: info == unsetCopyWithValue
          ? (output == null ? this.info : null)
          : (info as Map?)?.cast<String, dynamic>(),
      object: object == unsetCopyWithValue ? this.object : object as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolExecutionEntry &&
          id == other.id &&
          toolType == other.toolType &&
          mapsDeepEqual(input, other.input) &&
          mapsDeepEqual(output, other.output) &&
          status == other.status &&
          agentId == other.agentId &&
          model == other.model &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          arguments == other.arguments &&
          mapsDeepEqual(info, other.info);

  @override
  int get hashCode => Object.hash(
    id,
    toolType,
    mapDeepHashCode(input),
    mapDeepHashCode(output),
    status,
    agentId,
    model,
    object,
    createdAt,
    completedAt,
    arguments,
    mapDeepHashCode(info),
  );

  @override
  String toString() => 'ToolExecutionEntry(toolType: $toolType)';
}

/// A handoff between agents.
@immutable
class AgentHandoffEntry extends ConversationEntry {
  /// The unique identifier for this entry.
  final String? id;

  /// The ID of the agent to hand off to.
  final String targetAgentId;

  /// The wire identifier of the receiving agent.
  String get nextAgentId => targetAgentId;

  /// The reason for the handoff.
  final String? reason;

  /// Additional context for the handoff.
  final Map<String, dynamic>? context;

  /// ID of the agent that initiated the handoff.
  final String? previousAgentId;

  /// Name of the agent that initiated the handoff.
  final String? previousAgentName;

  /// Name of the agent receiving the handoff.
  final String? nextAgentName;

  /// Creates an [AgentHandoffEntry].
  const AgentHandoffEntry({
    this.id,
    required this.targetAgentId,
    this.reason,
    this.context,
    this.previousAgentId,
    this.previousAgentName,
    this.nextAgentName,
    super.object,
    super.createdAt,
    super.completedAt,
  });

  @override
  String get type => 'agent.handoff';

  /// Creates an [AgentHandoffEntry] from JSON.
  factory AgentHandoffEntry.fromJson(Map<String, dynamic> json) {
    return AgentHandoffEntry(
      id: json['id'] as String?,
      targetAgentId:
          json['next_agent_id'] as String? ??
          json['target_agent_id'] as String? ??
          '',
      reason: json['reason'] as String?,
      context: json['context'] as Map<String, dynamic>?,
      previousAgentId: json['previous_agent_id'] as String?,
      previousAgentName: json['previous_agent_name'] as String?,
      nextAgentName: json['next_agent_name'] as String?,
      object: json['object'] as String?,
      createdAt: json['created_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      ..._metadataJson(),
      'next_agent_id': targetAgentId,
      if (id != null) 'id': id,

      'previous_agent_id': ?previousAgentId,
      'previous_agent_name': ?previousAgentName,
      'next_agent_name': ?nextAgentName,
    };
  }

  /// Creates a copy with the given fields replaced.
  AgentHandoffEntry copyWith({
    String? id,
    String? targetAgentId,
    String? reason,
    Map<String, dynamic>? context,
    Object? previousAgentId = unsetCopyWithValue,
    Object? previousAgentName = unsetCopyWithValue,
    Object? nextAgentName = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? completedAt = unsetCopyWithValue,
  }) {
    return AgentHandoffEntry(
      id: id ?? this.id,
      targetAgentId: targetAgentId ?? this.targetAgentId,
      reason: reason ?? this.reason,
      context: context ?? this.context,
      previousAgentId: previousAgentId == unsetCopyWithValue
          ? this.previousAgentId
          : previousAgentId as String?,
      previousAgentName: previousAgentName == unsetCopyWithValue
          ? this.previousAgentName
          : previousAgentName as String?,
      nextAgentName: nextAgentName == unsetCopyWithValue
          ? this.nextAgentName
          : nextAgentName as String?,
      object: object == unsetCopyWithValue ? this.object : object as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentHandoffEntry &&
          id == other.id &&
          targetAgentId == other.targetAgentId &&
          reason == other.reason &&
          mapsDeepEqual(context, other.context) &&
          object == other.object &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          previousAgentId == other.previousAgentId &&
          previousAgentName == other.previousAgentName &&
          nextAgentName == other.nextAgentName;

  @override
  int get hashCode => Object.hash(
    id,
    targetAgentId,
    reason,
    mapDeepHashCode(context),
    object,
    createdAt,
    completedAt,
    previousAgentId,
    previousAgentName,
    nextAgentName,
  );

  @override
  String toString() => 'AgentHandoffEntry(targetAgentId: $targetAgentId)';
}

/// A future entry type retained as an open JSON object.
class UnknownConversationEntry extends ConversationEntry {
  /// Creates a forward-compatible entry from a wire payload.
  UnknownConversationEntry(Map<String, dynamic> json)
    : rawJson = deepUnmodifiableJson(json)! as Map<String, dynamic>,
      super(
        object: _optionalText(json['object']),
        createdAt: _optionalText(json['created_at']),
        completedAt: _optionalText(json['completed_at']),
      );

  /// Original payload.
  final Map<String, dynamic> rawJson;

  @override
  String get type => _optionalText(rawJson['type']) ?? 'unknown';

  @override
  Map<String, dynamic> toJson() => {...rawJson};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownConversationEntry &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownConversationEntry(type: $type)';
}

String? _optionalText(Object? value) => value is String ? value : null;

Map<String, dynamic>? _decodeToolArguments(String? text) {
  if (text == null) return null;
  try {
    final value = jsonDecode(text);
    return value is Map<String, dynamic> ? value : null;
  } on FormatException {
    return null;
  }
}
