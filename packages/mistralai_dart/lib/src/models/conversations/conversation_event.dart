import 'package:meta/meta.dart';

import '../chat/message_content.dart';
import '../common/copy_with_sentinel.dart';
import '../common/deep_unmodifiable_json.dart';
import '../common/equality_helpers.dart';
import '../content/content_part.dart';
import '../metadata/usage_info.dart';
import 'confirmation_status.dart';

/// A typed event emitted by the Conversations API.
///
/// Events include [ConversationResponseStarted],
/// [ConversationResponseDone],
/// [ConversationResponseError],
/// [ConversationMessageDelta],
/// [ConversationFunctionCallDelta],
/// [ConversationToolExecutionStarted],
/// [ConversationToolExecutionDelta],
/// [ConversationToolExecutionDone],
/// [ConversationAgentHandoffStarted],
/// [ConversationAgentHandoffDone],
/// and [UnknownConversationEvent].
@immutable
sealed class ConversationEvent {
  /// Creates a conversation event.
  const ConversationEvent({this.createdAt, this.outputIndex});

  /// The wire event type.
  String get type;

  /// The event timestamp as returned by the service.
  final String? createdAt;

  /// Position of the affected entry in the response outputs.
  final int? outputIndex;

  /// Parses the event data object.
  factory ConversationEvent.fromJson(
    Map<String, dynamic> json,
  ) => switch (json['type']) {
    'conversation.response.started' => ConversationResponseStarted.fromJson(
      json,
    ),
    'conversation.response.done' => ConversationResponseDone.fromJson(json),
    'conversation.response.error' => ConversationResponseError.fromJson(json),
    'message.output.delta' => ConversationMessageDelta.fromJson(json),
    'function.call.delta' => ConversationFunctionCallDelta.fromJson(json),
    'tool.execution.started' => ConversationToolExecutionStarted.fromJson(json),
    'tool.execution.delta' => ConversationToolExecutionDelta.fromJson(json),
    'tool.execution.done' => ConversationToolExecutionDone.fromJson(json),
    'agent.handoff.started' => ConversationAgentHandoffStarted.fromJson(json),
    'agent.handoff.done' => ConversationAgentHandoffDone.fromJson(json),
    _ => UnknownConversationEvent(json),
  };

  /// Converts the event data to JSON.
  Map<String, dynamic> toJson();
}

/// The service started a response.
class ConversationResponseStarted extends ConversationEvent {
  /// Creates a [ConversationResponseStarted].
  const ConversationResponseStarted({
    required this.conversationId,
    super.createdAt,
  });

  @override
  String get type => 'conversation.response.started';

  /// Conversation ID.
  final String conversationId;

  /// Parses a [ConversationResponseStarted] from its data object.
  factory ConversationResponseStarted.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'conversation.response.started');
    return ConversationResponseStarted(
      conversationId: _required<String>(json, 'conversation_id'),
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'conversation_id': conversationId,
  };

  /// Creates a copy with the given fields replaced.
  ConversationResponseStarted copyWith({
    String? conversationId,
    Object? createdAt = unsetCopyWithValue,
  }) => ConversationResponseStarted(
    conversationId: conversationId ?? this.conversationId,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
  );

  @override
  String toString() =>
      'ConversationResponseStarted(conversationId: $conversationId, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationResponseStarted &&
          createdAt == other.createdAt &&
          conversationId == other.conversationId;

  @override
  int get hashCode => Object.hash(createdAt, conversationId);
}

/// The response completed.
class ConversationResponseDone extends ConversationEvent {
  /// Creates a [ConversationResponseDone].
  const ConversationResponseDone({required this.usage, super.createdAt});

  @override
  String get type => 'conversation.response.done';

  /// Token usage for the response.
  final UsageInfo usage;

  /// Parses a [ConversationResponseDone] from its data object.
  factory ConversationResponseDone.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'conversation.response.done');
    return ConversationResponseDone(
      usage: UsageInfo.fromJson(_required<Map<String, dynamic>>(json, 'usage')),
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'usage': usage.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ConversationResponseDone copyWith({
    UsageInfo? usage,
    Object? createdAt = unsetCopyWithValue,
  }) => ConversationResponseDone(
    usage: usage ?? this.usage,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
  );

  @override
  String toString() =>
      'ConversationResponseDone(usage: $usage, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationResponseDone &&
          createdAt == other.createdAt &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(createdAt, usage);
}

/// The service reported an error inside the response stream.
class ConversationResponseError extends ConversationEvent {
  /// Creates a [ConversationResponseError].
  const ConversationResponseError({
    required this.message,
    required this.code,
    super.createdAt,
  });

  @override
  String get type => 'conversation.response.error';

  /// Error message.
  final String message;

  /// Service error code.
  final int code;

  /// Parses a [ConversationResponseError] from its data object.
  factory ConversationResponseError.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'conversation.response.error');
    return ConversationResponseError(
      message: _required<String>(json, 'message'),
      code: _required<int>(json, 'code'),
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'message': message,
    'code': code,
  };

  /// Creates a copy with the given fields replaced.
  ConversationResponseError copyWith({
    String? message,
    int? code,
    Object? createdAt = unsetCopyWithValue,
  }) => ConversationResponseError(
    message: message ?? this.message,
    code: code ?? this.code,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
  );

  @override
  String toString() =>
      'ConversationResponseError(message: ${message.length} characters, code: $code, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationResponseError &&
          createdAt == other.createdAt &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(createdAt, message, code);
}

/// An incremental assistant message update.
class ConversationMessageDelta extends ConversationEvent {
  /// Creates a [ConversationMessageDelta].
  const ConversationMessageDelta({
    required this.id,
    required this.content,
    this.contentIndex,
    this.agentId,
    this.model,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'message.output.delta';

  /// Message entry ID.
  final String id;

  /// The text or single content part in this update.
  final MessageContent content;

  /// Text in this update, if it contains text.
  String? get text => content.text;

  /// Position of the item in the message content.
  final int? contentIndex;

  /// Agent producing this output.
  final String? agentId;

  /// Model producing this output.
  final String? model;

  /// The role on an output update.
  String get role => 'assistant';

  /// Parses a [ConversationMessageDelta] from its data object.
  factory ConversationMessageDelta.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'message.output.delta');
    if (json['role'] case final value? when value != 'assistant') {
      throw FormatException('Unexpected conversation message role: $value.');
    }
    return ConversationMessageDelta(
      id: _required<String>(json, 'id'),
      content: _decodeOutputContent(json['content']),
      contentIndex: json['content_index'] as int?,
      agentId: json['agent_id'] as String?,
      model: json['model'] as String?,
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'role': role,
    'id': id,
    'content': switch (content) {
      MessagePartsContent(:final parts) when parts.length == 1 =>
        parts.single.toJson(),
      _ => content.toJson(),
    },
    'content_index': ?contentIndex,
    'agent_id': ?agentId,
    'model': ?model,
  };

  /// Creates a copy with the given fields replaced.
  ConversationMessageDelta copyWith({
    String? id,
    MessageContent? content,
    Object? contentIndex = unsetCopyWithValue,
    Object? agentId = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationMessageDelta(
    id: id ?? this.id,
    content: content ?? this.content,
    contentIndex: contentIndex == unsetCopyWithValue
        ? this.contentIndex
        : contentIndex as int?,
    agentId: agentId == unsetCopyWithValue ? this.agentId : agentId as String?,
    model: model == unsetCopyWithValue ? this.model : model as String?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationMessageDelta(id: $id, content: $content, contentIndex: $contentIndex, agentId: $agentId, model: $model, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessageDelta &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          content == other.content &&
          contentIndex == other.contentIndex &&
          agentId == other.agentId &&
          model == other.model;

  @override
  int get hashCode => Object.hash(
    createdAt,
    outputIndex,
    id,
    content,
    contentIndex,
    agentId,
    model,
  );
}

/// A function call update from the conversation.
class ConversationFunctionCallDelta extends ConversationEvent {
  /// Creates a [ConversationFunctionCallDelta].
  const ConversationFunctionCallDelta({
    required this.id,
    required this.name,
    required this.toolCallId,
    required this.arguments,
    this.confirmationStatus,
    this.agentId,
    this.model,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'function.call.delta';

  /// Entry ID.
  final String id;

  /// Name of the requested function.
  final String name;

  /// ID to use when returning a tool result.
  final String toolCallId;

  /// JSON string containing complete or partial function arguments.
  final String arguments;

  /// Whether confirmation is needed or has been decided.
  final ConfirmationStatus? confirmationStatus;

  /// Agent that requested the function.
  final String? agentId;

  /// Model that requested the function.
  final String? model;

  /// Parses a [ConversationFunctionCallDelta] from its data object.
  factory ConversationFunctionCallDelta.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'function.call.delta');
    return ConversationFunctionCallDelta(
      id: _required<String>(json, 'id'),
      name: _required<String>(json, 'name'),
      toolCallId: _required<String>(json, 'tool_call_id'),
      arguments: _required<String>(json, 'arguments'),
      confirmationStatus: json['confirmation_status'] == null
          ? null
          : ConfirmationStatus.fromJson(json['confirmation_status'] as String),
      agentId: json['agent_id'] as String?,
      model: json['model'] as String?,
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'id': id,
    'name': name,
    'tool_call_id': toolCallId,
    'arguments': arguments,
    'confirmation_status': ?confirmationStatus?.value,
    'agent_id': ?agentId,
    'model': ?model,
  };

  /// Creates a copy with the given fields replaced.
  ConversationFunctionCallDelta copyWith({
    String? id,
    String? name,
    String? toolCallId,
    String? arguments,
    Object? confirmationStatus = unsetCopyWithValue,
    Object? agentId = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationFunctionCallDelta(
    id: id ?? this.id,
    name: name ?? this.name,
    toolCallId: toolCallId ?? this.toolCallId,
    arguments: arguments ?? this.arguments,
    confirmationStatus: confirmationStatus == unsetCopyWithValue
        ? this.confirmationStatus
        : confirmationStatus as ConfirmationStatus?,
    agentId: agentId == unsetCopyWithValue ? this.agentId : agentId as String?,
    model: model == unsetCopyWithValue ? this.model : model as String?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationFunctionCallDelta(id: $id, name: $name, toolCallId: $toolCallId, arguments: ${arguments.length} characters, confirmationStatus: $confirmationStatus, agentId: $agentId, model: $model, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationFunctionCallDelta &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          name == other.name &&
          toolCallId == other.toolCallId &&
          arguments == other.arguments &&
          confirmationStatus == other.confirmationStatus &&
          agentId == other.agentId &&
          model == other.model;

  @override
  int get hashCode => Object.hash(
    createdAt,
    outputIndex,
    id,
    name,
    toolCallId,
    arguments,
    confirmationStatus,
    agentId,
    model,
  );
}

/// A built-in tool started executing.
class ConversationToolExecutionStarted extends ConversationEvent {
  /// Creates a [ConversationToolExecutionStarted].
  const ConversationToolExecutionStarted({
    required this.id,
    required this.name,
    required this.arguments,
    this.agentId,
    this.model,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'tool.execution.started';

  /// Entry ID.
  final String id;

  /// Name of the executed tool.
  final String name;

  /// Tool arguments.
  final String arguments;

  /// Agent that requested the tool.
  final String? agentId;

  /// Model that requested the tool.
  final String? model;

  /// Parses a [ConversationToolExecutionStarted] from its data object.
  factory ConversationToolExecutionStarted.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'tool.execution.started');
    return ConversationToolExecutionStarted(
      id: _required<String>(json, 'id'),
      name: _required<String>(json, 'name'),
      arguments: _required<String>(json, 'arguments'),
      agentId: json['agent_id'] as String?,
      model: json['model'] as String?,
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'id': id,
    'name': name,
    'arguments': arguments,
    'agent_id': ?agentId,
    'model': ?model,
  };

  /// Creates a copy with the given fields replaced.
  ConversationToolExecutionStarted copyWith({
    String? id,
    String? name,
    String? arguments,
    Object? agentId = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationToolExecutionStarted(
    id: id ?? this.id,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    agentId: agentId == unsetCopyWithValue ? this.agentId : agentId as String?,
    model: model == unsetCopyWithValue ? this.model : model as String?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationToolExecutionStarted(id: $id, name: $name, arguments: ${arguments.length} characters, agentId: $agentId, model: $model, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationToolExecutionStarted &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          name == other.name &&
          arguments == other.arguments &&
          agentId == other.agentId &&
          model == other.model;

  @override
  int get hashCode =>
      Object.hash(createdAt, outputIndex, id, name, arguments, agentId, model);
}

/// An incremental update from a built-in tool.
class ConversationToolExecutionDelta extends ConversationEvent {
  /// Creates a [ConversationToolExecutionDelta].
  const ConversationToolExecutionDelta({
    required this.id,
    required this.name,
    required this.arguments,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'tool.execution.delta';

  /// Entry ID.
  final String id;

  /// Name of the executed tool.
  final String name;

  /// Complete or partial tool arguments.
  final String arguments;

  /// Parses a [ConversationToolExecutionDelta] from its data object.
  factory ConversationToolExecutionDelta.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'tool.execution.delta');
    return ConversationToolExecutionDelta(
      id: _required<String>(json, 'id'),
      name: _required<String>(json, 'name'),
      arguments: _required<String>(json, 'arguments'),
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'id': id,
    'name': name,
    'arguments': arguments,
  };

  /// Creates a copy with the given fields replaced.
  ConversationToolExecutionDelta copyWith({
    String? id,
    String? name,
    String? arguments,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationToolExecutionDelta(
    id: id ?? this.id,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationToolExecutionDelta(id: $id, name: $name, arguments: ${arguments.length} characters, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationToolExecutionDelta &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          name == other.name &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(createdAt, outputIndex, id, name, arguments);
}

/// A built-in tool completed.
class ConversationToolExecutionDone extends ConversationEvent {
  /// Creates a [ConversationToolExecutionDone].
  const ConversationToolExecutionDone({
    required this.id,
    required this.name,
    this.info,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'tool.execution.done';

  /// Entry ID.
  final String id;

  /// Name of the executed tool.
  final String name;

  /// Additional results or details supplied by the tool.
  final Map<String, dynamic>? info;

  /// Parses a [ConversationToolExecutionDone] from its data object.
  factory ConversationToolExecutionDone.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'tool.execution.done');
    return ConversationToolExecutionDone(
      id: _required<String>(json, 'id'),
      name: _required<String>(json, 'name'),
      info: json['info'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'id': id,
    'name': name,
    'info': ?info,
  };

  /// Creates a copy with the given fields replaced.
  ConversationToolExecutionDone copyWith({
    String? id,
    String? name,
    Object? info = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationToolExecutionDone(
    id: id ?? this.id,
    name: name ?? this.name,
    info: info == unsetCopyWithValue
        ? this.info
        : info as Map<String, dynamic>?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationToolExecutionDone(id: $id, name: $name, info: ${info?.keys.toList()}, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationToolExecutionDone &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          name == other.name &&
          mapsDeepEqual(info, other.info);

  @override
  int get hashCode =>
      Object.hash(createdAt, outputIndex, id, name, mapDeepHashCode(info));
}

/// An agent began handing off a conversation.
class ConversationAgentHandoffStarted extends ConversationEvent {
  /// Creates a [ConversationAgentHandoffStarted].
  const ConversationAgentHandoffStarted({
    required this.id,
    required this.previousAgentId,
    required this.previousAgentName,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'agent.handoff.started';

  /// Entry ID.
  final String id;

  /// ID of the departing agent.
  final String previousAgentId;

  /// Name of the departing agent.
  final String previousAgentName;

  /// Parses a [ConversationAgentHandoffStarted] from its data object.
  factory ConversationAgentHandoffStarted.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'agent.handoff.started');
    return ConversationAgentHandoffStarted(
      id: _required<String>(json, 'id'),
      previousAgentId: _required<String>(json, 'previous_agent_id'),
      previousAgentName: _required<String>(json, 'previous_agent_name'),
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'id': id,
    'previous_agent_id': previousAgentId,
    'previous_agent_name': previousAgentName,
  };

  /// Creates a copy with the given fields replaced.
  ConversationAgentHandoffStarted copyWith({
    String? id,
    String? previousAgentId,
    String? previousAgentName,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationAgentHandoffStarted(
    id: id ?? this.id,
    previousAgentId: previousAgentId ?? this.previousAgentId,
    previousAgentName: previousAgentName ?? this.previousAgentName,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationAgentHandoffStarted(id: $id, previousAgentId: $previousAgentId, previousAgentName: $previousAgentName, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAgentHandoffStarted &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          previousAgentId == other.previousAgentId &&
          previousAgentName == other.previousAgentName;

  @override
  int get hashCode => Object.hash(
    createdAt,
    outputIndex,
    id,
    previousAgentId,
    previousAgentName,
  );
}

/// The next agent took over the conversation.
class ConversationAgentHandoffDone extends ConversationEvent {
  /// Creates a [ConversationAgentHandoffDone].
  const ConversationAgentHandoffDone({
    required this.id,
    required this.nextAgentId,
    required this.nextAgentName,
    super.createdAt,
    super.outputIndex,
  });

  @override
  String get type => 'agent.handoff.done';

  /// Entry ID.
  final String id;

  /// ID of the receiving agent.
  final String nextAgentId;

  /// Name of the receiving agent.
  final String nextAgentName;

  /// Parses a [ConversationAgentHandoffDone] from its data object.
  factory ConversationAgentHandoffDone.fromJson(Map<String, dynamic> json) {
    _checkType(json, 'agent.handoff.done');
    return ConversationAgentHandoffDone(
      id: _required<String>(json, 'id'),
      nextAgentId: _required<String>(json, 'next_agent_id'),
      nextAgentName: _required<String>(json, 'next_agent_name'),
      createdAt: json['created_at'] as String?,
      outputIndex: json['output_index'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'created_at': ?createdAt,
    'output_index': ?outputIndex,
    'id': id,
    'next_agent_id': nextAgentId,
    'next_agent_name': nextAgentName,
  };

  /// Creates a copy with the given fields replaced.
  ConversationAgentHandoffDone copyWith({
    String? id,
    String? nextAgentId,
    String? nextAgentName,
    Object? createdAt = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
  }) => ConversationAgentHandoffDone(
    id: id ?? this.id,
    nextAgentId: nextAgentId ?? this.nextAgentId,
    nextAgentName: nextAgentName ?? this.nextAgentName,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    outputIndex: outputIndex == unsetCopyWithValue
        ? this.outputIndex
        : outputIndex as int?,
  );

  @override
  String toString() =>
      'ConversationAgentHandoffDone(id: $id, nextAgentId: $nextAgentId, nextAgentName: $nextAgentName, createdAt: $createdAt, outputIndex: $outputIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAgentHandoffDone &&
          createdAt == other.createdAt &&
          outputIndex == other.outputIndex &&
          id == other.id &&
          nextAgentId == other.nextAgentId &&
          nextAgentName == other.nextAgentName;

  @override
  int get hashCode =>
      Object.hash(createdAt, outputIndex, id, nextAgentId, nextAgentName);
}

/// A newer event preserved without discarding its JSON payload.
class UnknownConversationEvent extends ConversationEvent {
  /// Creates a representation of a future event.
  UnknownConversationEvent(Map<String, dynamic> rawJson)
    : rawJson = deepUnmodifiableJson(rawJson)! as Map<String, dynamic>,
      super(
        createdAt: _optional<String>(rawJson['created_at']),
        outputIndex: _optional<int>(rawJson['output_index']),
      );

  /// The original event data.
  final Map<String, dynamic> rawJson;

  @override
  String get type => _optional<String>(rawJson['type']) ?? 'unknown';

  @override
  Map<String, dynamic> toJson() => {...rawJson};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownConversationEvent &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);
}

T _required<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! T) {
    throw FormatException('Expected conversation event field "$key" as $T.');
  }
  return value;
}

void _checkType(Map<String, dynamic> json, String expected) {
  final type = json['type'];
  if (type != null && type != expected) {
    throw FormatException('Expected conversation event type "$expected".');
  }
}

MessageContent _decodeOutputContent(Object? value) => switch (value) {
  final Map<String, dynamic> part => MessageContent.parts([
    ContentPart.fromJson(part),
  ]),
  final String text => MessageContent.text(text),
  final List<Object?> parts => MessageContent.fromJson(parts),
  _ => throw const FormatException(
    'Missing or invalid conversation output content.',
  ),
};

T? _optional<T>(Object? value) => value is T ? value : null;
