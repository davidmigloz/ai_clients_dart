import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_tool.dart' show AgentEvaluatedPermission;
import '../outcomes/rubric.dart';
import '../sessions/session.dart' show SessionAgent;
import 'telemetry.dart';

/// Server-sent event in a managed agents session.
///
/// Variants:
/// - [AgentMessageEvent] — agent response with text content.
/// - [AgentThinkingEvent] — agent thinking progress signal.
/// - [AgentToolUseEvent] — agent built-in tool invocation.
/// - [AgentToolResultEvent] — result of a built-in tool execution.
/// - [AgentMcpToolUseEvent] — agent MCP tool invocation.
/// - [AgentMcpToolResultEvent] — result of an MCP tool execution.
/// - [AgentCustomToolUseEvent] — agent custom tool invocation.
/// - [AgentThreadContextCompactedEvent] — context compaction occurred.
/// - [AgentThreadMessageReceivedEvent] — a peer agent thread sent this thread a message.
/// - [AgentThreadMessageSentEvent] — this thread sent a peer agent thread a message.
/// - [UserMessageEvent] — user message.
/// - [SystemMessageEvent] — mid-conversation system message.
/// - [UserInterruptEvent] — user interrupt.
/// - [UserToolConfirmationEvent] — user tool confirmation.
/// - [UserCustomToolResultEvent] — user custom tool result.
/// - [UserToolResultEvent] — user tool result.
/// - [SessionStatusRunningEvent] — session is running.
/// - [SessionStatusIdleEvent] — session is idle.
/// - [SessionStatusRescheduledEvent] — session rescheduled.
/// - [SessionStatusTerminatedEvent] — session terminated.
/// - [SessionThreadCreatedEvent] — a thread was created within the session.
/// - [SessionThreadStatusRunningEvent] — a thread is running.
/// - [SessionThreadStatusIdleEvent] — a thread is idle.
/// - [SessionThreadStatusRescheduledEvent] — a thread was rescheduled.
/// - [SessionThreadStatusTerminatedEvent] — a thread terminated.
/// - [SessionErrorEvent] — session error.
/// - [SessionDeletedEvent] — session deleted.
/// - [SessionUpdatedEvent] — an UpdateSession request changed a field.
/// - [SpanModelRequestStartEvent] — model request started.
/// - [SpanModelRequestEndEvent] — model request completed.
/// - [SpanOutcomeEvaluationStartEvent] — outcome evaluation cycle began.
/// - [SpanOutcomeEvaluationOngoingEvent] — outcome evaluation heartbeat.
/// - [SpanOutcomeEvaluationEndEvent] — outcome evaluation cycle completed.
/// - [UserDefineOutcomeEvent] — echo of a `user.define_outcome` input event.
/// - [UnknownSessionEvent] — unrecognized event type.
sealed class SessionEvent {
  const SessionEvent();

  /// Creates a [SessionEvent] from JSON.
  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'agent.message' => AgentMessageEvent.fromJson(json),
      'agent.thinking' => AgentThinkingEvent.fromJson(json),
      'agent.tool_use' => AgentToolUseEvent.fromJson(json),
      'agent.tool_result' => AgentToolResultEvent.fromJson(json),
      'agent.mcp_tool_use' => AgentMcpToolUseEvent.fromJson(json),
      'agent.mcp_tool_result' => AgentMcpToolResultEvent.fromJson(json),
      'agent.custom_tool_use' => AgentCustomToolUseEvent.fromJson(json),
      'agent.thread_context_compacted' =>
        AgentThreadContextCompactedEvent.fromJson(json),
      'agent.thread_message_received' =>
        AgentThreadMessageReceivedEvent.fromJson(json),
      'agent.thread_message_sent' => AgentThreadMessageSentEvent.fromJson(json),
      'user.message' => UserMessageEvent.fromJson(json),
      'system.message' => SystemMessageEvent.fromJson(json),
      'user.interrupt' => UserInterruptEvent.fromJson(json),
      'user.tool_confirmation' => UserToolConfirmationEvent.fromJson(json),
      'user.custom_tool_result' => UserCustomToolResultEvent.fromJson(json),
      'user.tool_result' => UserToolResultEvent.fromJson(json),
      'session.status_running' => SessionStatusRunningEvent.fromJson(json),
      'session.status_idle' => SessionStatusIdleEvent.fromJson(json),
      'session.status_rescheduled' => SessionStatusRescheduledEvent.fromJson(
        json,
      ),
      'session.status_terminated' => SessionStatusTerminatedEvent.fromJson(
        json,
      ),
      'session.thread_created' => SessionThreadCreatedEvent.fromJson(json),
      'session.thread_status_running' =>
        SessionThreadStatusRunningEvent.fromJson(json),
      'session.thread_status_idle' => SessionThreadStatusIdleEvent.fromJson(
        json,
      ),
      'session.thread_status_rescheduled' =>
        SessionThreadStatusRescheduledEvent.fromJson(json),
      'session.thread_status_terminated' =>
        SessionThreadStatusTerminatedEvent.fromJson(json),
      'session.error' => SessionErrorEvent.fromJson(json),
      'session.deleted' => SessionDeletedEvent.fromJson(json),
      'session.updated' => SessionUpdatedEvent.fromJson(json),
      'span.model_request_start' => SpanModelRequestStartEvent.fromJson(json),
      'span.model_request_end' => SpanModelRequestEndEvent.fromJson(json),
      'span.outcome_evaluation_start' =>
        SpanOutcomeEvaluationStartEvent.fromJson(json),
      'span.outcome_evaluation_ongoing' =>
        SpanOutcomeEvaluationOngoingEvent.fromJson(json),
      'span.outcome_evaluation_end' => SpanOutcomeEvaluationEndEvent.fromJson(
        json,
      ),
      'user.define_outcome' => UserDefineOutcomeEvent.fromJson(json),
      _ => UnknownSessionEvent(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

// ---------------------------------------------------------------------------
// Agent events
// ---------------------------------------------------------------------------

/// An agent response event with text content.
@immutable
class AgentMessageEvent extends SessionEvent {
  /// The event type, always 'agent.message'.
  String get type => 'agent.message';

  /// Unique identifier for this event.
  final String id;

  /// Array of text blocks comprising the agent response.
  final List<Map<String, dynamic>> content;

  /// Timestamp when this response was generated.
  final BetaTimestamp processedAt;

  /// Creates an [AgentMessageEvent].
  const AgentMessageEvent({
    required this.id,
    required this.content,
    required this.processedAt,
  });

  /// Creates an [AgentMessageEvent] from JSON.
  factory AgentMessageEvent.fromJson(Map<String, dynamic> json) {
    return AgentMessageEvent(
      id: json['id'] as String,
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'content': content,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentMessageEvent copyWith({
    String? id,
    List<Map<String, dynamic>>? content,
    BetaTimestamp? processedAt,
  }) {
    return AgentMessageEvent(
      id: id ?? this.id,
      content: content ?? this.content,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentMessageEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listOfMapsDeepEqual(content, other.content) &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, listOfMapsHashCode(content), processedAt);

  @override
  String toString() =>
      'AgentMessageEvent(id: $id, content: $content, '
      'processedAt: $processedAt)';
}

/// Agent thinking progress signal.
@immutable
class AgentThinkingEvent extends SessionEvent {
  /// The event type, always 'agent.thinking'.
  String get type => 'agent.thinking';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when this thinking was produced.
  final BetaTimestamp processedAt;

  /// Creates an [AgentThinkingEvent].
  const AgentThinkingEvent({required this.id, required this.processedAt});

  /// Creates an [AgentThinkingEvent] from JSON.
  factory AgentThinkingEvent.fromJson(Map<String, dynamic> json) {
    return AgentThinkingEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentThinkingEvent copyWith({String? id, BetaTimestamp? processedAt}) {
    return AgentThinkingEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentThinkingEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() => 'AgentThinkingEvent(id: $id, processedAt: $processedAt)';
}

/// Agent built-in tool invocation event.
@immutable
class AgentToolUseEvent extends SessionEvent {
  /// The event type, always 'agent.tool_use'.
  String get type => 'agent.tool_use';

  /// Unique identifier for this event.
  final String id;

  /// Name of the agent tool being used.
  final String name;

  /// Input parameters for the tool call.
  final Map<String, dynamic> input;

  /// The evaluated permission policy for this tool invocation.
  final AgentEvaluatedPermission? evaluatedPermission;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates an [AgentToolUseEvent].
  const AgentToolUseEvent({
    required this.id,
    required this.name,
    required this.input,
    this.evaluatedPermission,
    required this.processedAt,
    this.sessionThreadId,
  });

  /// Creates an [AgentToolUseEvent] from JSON.
  factory AgentToolUseEvent.fromJson(Map<String, dynamic> json) {
    return AgentToolUseEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      input: json['input'] as Map<String, dynamic>,
      evaluatedPermission: json['evaluated_permission'] != null
          ? AgentEvaluatedPermission.fromJson(
              json['evaluated_permission'] as String,
            )
          : null,
      processedAt: DateTime.parse(json['processed_at'] as String),
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'input': input,
    if (evaluatedPermission != null)
      'evaluated_permission': evaluatedPermission!.toJson(),
    'processed_at': processedAt.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  AgentToolUseEvent copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? input,
    Object? evaluatedPermission = unsetCopyWithValue,
    BetaTimestamp? processedAt,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return AgentToolUseEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      input: input ?? this.input,
      evaluatedPermission: evaluatedPermission == unsetCopyWithValue
          ? this.evaluatedPermission
          : evaluatedPermission as AgentEvaluatedPermission?,
      processedAt: processedAt ?? this.processedAt,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolUseEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mapsDeepEqual(input, other.input) &&
          evaluatedPermission == other.evaluatedPermission &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mapDeepHashCode(input),
    evaluatedPermission,
    processedAt,
    sessionThreadId,
  );

  @override
  String toString() =>
      'AgentToolUseEvent(id: $id, name: $name, input: $input, '
      'evaluatedPermission: $evaluatedPermission, '
      'processedAt: $processedAt, '
      'sessionThreadId: $sessionThreadId)';
}

/// Result of a built-in agent tool execution.
@immutable
class AgentToolResultEvent extends SessionEvent {
  /// The event type, always 'agent.tool_result'.
  String get type => 'agent.tool_result';

  /// Unique identifier for this event.
  final String id;

  /// The id of the agent.tool_use event this result corresponds to.
  final String toolUseId;

  /// The result content returned by the tool.
  final List<Map<String, dynamic>>? content;

  /// Whether the tool execution resulted in an error.
  final bool? isError;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates an [AgentToolResultEvent].
  const AgentToolResultEvent({
    required this.id,
    required this.toolUseId,
    this.content,
    this.isError,
    required this.processedAt,
  });

  /// Creates an [AgentToolResultEvent] from JSON.
  factory AgentToolResultEvent.fromJson(Map<String, dynamic> json) {
    return AgentToolResultEvent(
      id: json['id'] as String,
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isError: json['is_error'] as bool?,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'tool_use_id': toolUseId,
    if (content != null) 'content': content,
    if (isError != null) 'is_error': isError,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentToolResultEvent copyWith({
    String? id,
    String? toolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    BetaTimestamp? processedAt,
  }) {
    return AgentToolResultEvent(
      id: id ?? this.id,
      toolUseId: toolUseId ?? this.toolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<Map<String, dynamic>>?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolResultEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          toolUseId == other.toolUseId &&
          listOfMapsDeepEqual(content, other.content) &&
          isError == other.isError &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(
    id,
    toolUseId,
    listOfMapsHashCode(content),
    isError,
    processedAt,
  );

  @override
  String toString() =>
      'AgentToolResultEvent(id: $id, toolUseId: $toolUseId, '
      'content: $content, isError: $isError, processedAt: $processedAt)';
}

/// Agent MCP tool invocation event.
@immutable
class AgentMcpToolUseEvent extends SessionEvent {
  /// The event type, always 'agent.mcp_tool_use'.
  String get type => 'agent.mcp_tool_use';

  /// Unique identifier for this event.
  final String id;

  /// Name of the MCP server providing the tool.
  final String mcpServerName;

  /// Name of the MCP tool being used.
  final String name;

  /// Input parameters for the tool call.
  final Map<String, dynamic> input;

  /// The evaluated permission policy for this tool invocation.
  final AgentEvaluatedPermission? evaluatedPermission;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates an [AgentMcpToolUseEvent].
  const AgentMcpToolUseEvent({
    required this.id,
    required this.mcpServerName,
    required this.name,
    required this.input,
    this.evaluatedPermission,
    required this.processedAt,
    this.sessionThreadId,
  });

  /// Creates an [AgentMcpToolUseEvent] from JSON.
  factory AgentMcpToolUseEvent.fromJson(Map<String, dynamic> json) {
    return AgentMcpToolUseEvent(
      id: json['id'] as String,
      mcpServerName: json['mcp_server_name'] as String,
      name: json['name'] as String,
      input: json['input'] as Map<String, dynamic>,
      evaluatedPermission: json['evaluated_permission'] != null
          ? AgentEvaluatedPermission.fromJson(
              json['evaluated_permission'] as String,
            )
          : null,
      processedAt: DateTime.parse(json['processed_at'] as String),
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'mcp_server_name': mcpServerName,
    'name': name,
    'input': input,
    if (evaluatedPermission != null)
      'evaluated_permission': evaluatedPermission!.toJson(),
    'processed_at': processedAt.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  AgentMcpToolUseEvent copyWith({
    String? id,
    String? mcpServerName,
    String? name,
    Map<String, dynamic>? input,
    Object? evaluatedPermission = unsetCopyWithValue,
    BetaTimestamp? processedAt,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return AgentMcpToolUseEvent(
      id: id ?? this.id,
      mcpServerName: mcpServerName ?? this.mcpServerName,
      name: name ?? this.name,
      input: input ?? this.input,
      evaluatedPermission: evaluatedPermission == unsetCopyWithValue
          ? this.evaluatedPermission
          : evaluatedPermission as AgentEvaluatedPermission?,
      processedAt: processedAt ?? this.processedAt,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentMcpToolUseEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mcpServerName == other.mcpServerName &&
          name == other.name &&
          mapsDeepEqual(input, other.input) &&
          evaluatedPermission == other.evaluatedPermission &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(
    id,
    mcpServerName,
    name,
    mapDeepHashCode(input),
    evaluatedPermission,
    processedAt,
    sessionThreadId,
  );

  @override
  String toString() =>
      'AgentMcpToolUseEvent(id: $id, mcpServerName: $mcpServerName, '
      'name: $name, input: $input, '
      'evaluatedPermission: $evaluatedPermission, '
      'processedAt: $processedAt, '
      'sessionThreadId: $sessionThreadId)';
}

/// Result of an MCP tool execution.
@immutable
class AgentMcpToolResultEvent extends SessionEvent {
  /// The event type, always 'agent.mcp_tool_result'.
  String get type => 'agent.mcp_tool_result';

  /// Unique identifier for this event.
  final String id;

  /// The id of the agent.mcp_tool_use event this result corresponds to.
  final String mcpToolUseId;

  /// The result content returned by the tool.
  final List<Map<String, dynamic>>? content;

  /// Whether the tool execution resulted in an error.
  final bool? isError;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates an [AgentMcpToolResultEvent].
  const AgentMcpToolResultEvent({
    required this.id,
    required this.mcpToolUseId,
    this.content,
    this.isError,
    required this.processedAt,
  });

  /// Creates an [AgentMcpToolResultEvent] from JSON.
  factory AgentMcpToolResultEvent.fromJson(Map<String, dynamic> json) {
    return AgentMcpToolResultEvent(
      id: json['id'] as String,
      mcpToolUseId: json['mcp_tool_use_id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isError: json['is_error'] as bool?,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'mcp_tool_use_id': mcpToolUseId,
    if (content != null) 'content': content,
    if (isError != null) 'is_error': isError,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentMcpToolResultEvent copyWith({
    String? id,
    String? mcpToolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    BetaTimestamp? processedAt,
  }) {
    return AgentMcpToolResultEvent(
      id: id ?? this.id,
      mcpToolUseId: mcpToolUseId ?? this.mcpToolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<Map<String, dynamic>>?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentMcpToolResultEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mcpToolUseId == other.mcpToolUseId &&
          listOfMapsDeepEqual(content, other.content) &&
          isError == other.isError &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(
    id,
    mcpToolUseId,
    listOfMapsHashCode(content),
    isError,
    processedAt,
  );

  @override
  String toString() =>
      'AgentMcpToolResultEvent(id: $id, mcpToolUseId: $mcpToolUseId, '
      'content: $content, isError: $isError, processedAt: $processedAt)';
}

/// Agent custom tool invocation event.
@immutable
class AgentCustomToolUseEvent extends SessionEvent {
  /// The event type, always 'agent.custom_tool_use'.
  String get type => 'agent.custom_tool_use';

  /// Unique identifier for this event.
  final String id;

  /// Name of the custom tool being called.
  final String name;

  /// Input parameters for the tool call.
  final Map<String, dynamic> input;

  /// Timestamp when this tool use was processed.
  final BetaTimestamp processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates an [AgentCustomToolUseEvent].
  const AgentCustomToolUseEvent({
    required this.id,
    required this.name,
    required this.input,
    required this.processedAt,
    this.sessionThreadId,
  });

  /// Creates an [AgentCustomToolUseEvent] from JSON.
  factory AgentCustomToolUseEvent.fromJson(Map<String, dynamic> json) {
    return AgentCustomToolUseEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      input: json['input'] as Map<String, dynamic>,
      processedAt: DateTime.parse(json['processed_at'] as String),
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'input': input,
    'processed_at': processedAt.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  AgentCustomToolUseEvent copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? input,
    BetaTimestamp? processedAt,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return AgentCustomToolUseEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      input: input ?? this.input,
      processedAt: processedAt ?? this.processedAt,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentCustomToolUseEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mapsDeepEqual(input, other.input) &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mapDeepHashCode(input),
    processedAt,
    sessionThreadId,
  );

  @override
  String toString() =>
      'AgentCustomToolUseEvent(id: $id, name: $name, input: $input, '
      'processedAt: $processedAt, sessionThreadId: $sessionThreadId)';
}

/// Context compaction (summarization) occurred during the session.
@immutable
class AgentThreadContextCompactedEvent extends SessionEvent {
  /// The event type, always 'agent.thread_context_compacted'.
  String get type => 'agent.thread_context_compacted';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when compaction was processed.
  final BetaTimestamp processedAt;

  /// Creates an [AgentThreadContextCompactedEvent].
  const AgentThreadContextCompactedEvent({
    required this.id,
    required this.processedAt,
  });

  /// Creates an [AgentThreadContextCompactedEvent] from JSON.
  factory AgentThreadContextCompactedEvent.fromJson(Map<String, dynamic> json) {
    return AgentThreadContextCompactedEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentThreadContextCompactedEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
  }) {
    return AgentThreadContextCompactedEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentThreadContextCompactedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() =>
      'AgentThreadContextCompactedEvent(id: $id, '
      'processedAt: $processedAt)';
}

// ---------------------------------------------------------------------------
// User events
// ---------------------------------------------------------------------------

/// A user message event.
@immutable
class UserMessageEvent extends SessionEvent {
  /// The event type, always 'user.message'.
  String get type => 'user.message';

  /// Unique identifier for this event.
  final String id;

  /// Array of content blocks comprising the user message.
  final List<Map<String, dynamic>> content;

  /// Timestamp when the agent finished processing this message.
  final BetaTimestamp? processedAt;

  /// Creates a [UserMessageEvent].
  const UserMessageEvent({
    required this.id,
    required this.content,
    this.processedAt,
  });

  /// Creates a [UserMessageEvent] from JSON.
  factory UserMessageEvent.fromJson(Map<String, dynamic> json) {
    return UserMessageEvent(
      id: json['id'] as String,
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'content': content,
    if (processedAt != null)
      'processed_at': processedAt!.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  UserMessageEvent copyWith({
    String? id,
    List<Map<String, dynamic>>? content,
    Object? processedAt = unsetCopyWithValue,
  }) {
    return UserMessageEvent(
      id: id ?? this.id,
      content: content ?? this.content,
      processedAt: processedAt == unsetCopyWithValue
          ? this.processedAt
          : processedAt as BetaTimestamp?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessageEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listOfMapsDeepEqual(content, other.content) &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, listOfMapsHashCode(content), processedAt);

  @override
  String toString() =>
      'UserMessageEvent(id: $id, content: $content, '
      'processedAt: $processedAt)';
}

/// A mid-conversation system message event.
///
/// Carries system-role content that is appended to the session as a
/// `role: "system"` turn.
@immutable
class SystemMessageEvent extends SessionEvent {
  /// The event type, always 'system.message'.
  String get type => 'system.message';

  /// Unique identifier for this event.
  final String id;

  /// System content blocks. Text-only.
  final List<Map<String, dynamic>> content;

  /// Timestamp when this system message was processed.
  final BetaTimestamp? processedAt;

  /// Creates a [SystemMessageEvent].
  const SystemMessageEvent({
    required this.id,
    required this.content,
    this.processedAt,
  });

  /// Creates a [SystemMessageEvent] from JSON.
  factory SystemMessageEvent.fromJson(Map<String, dynamic> json) {
    return SystemMessageEvent(
      id: json['id'] as String,
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'content': content,
    if (processedAt != null)
      'processed_at': processedAt!.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SystemMessageEvent copyWith({
    String? id,
    List<Map<String, dynamic>>? content,
    Object? processedAt = unsetCopyWithValue,
  }) {
    return SystemMessageEvent(
      id: id ?? this.id,
      content: content ?? this.content,
      processedAt: processedAt == unsetCopyWithValue
          ? this.processedAt
          : processedAt as BetaTimestamp?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessageEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listOfMapsDeepEqual(content, other.content) &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, listOfMapsHashCode(content), processedAt);

  @override
  String toString() =>
      'SystemMessageEvent(id: $id, content: $content, '
      'processedAt: $processedAt)';
}

/// An interrupt event that pauses agent execution.
@immutable
class UserInterruptEvent extends SessionEvent {
  /// The event type, always 'user.interrupt'.
  String get type => 'user.interrupt';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when the interrupt was processed.
  final BetaTimestamp? processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates a [UserInterruptEvent].
  const UserInterruptEvent({
    required this.id,
    this.processedAt,
    this.sessionThreadId,
  });

  /// Creates a [UserInterruptEvent] from JSON.
  factory UserInterruptEvent.fromJson(Map<String, dynamic> json) {
    return UserInterruptEvent(
      id: json['id'] as String,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (processedAt != null)
      'processed_at': processedAt!.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  UserInterruptEvent copyWith({
    String? id,
    Object? processedAt = unsetCopyWithValue,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return UserInterruptEvent(
      id: id ?? this.id,
      processedAt: processedAt == unsetCopyWithValue
          ? this.processedAt
          : processedAt as BetaTimestamp?,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInterruptEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(id, processedAt, sessionThreadId);

  @override
  String toString() =>
      'UserInterruptEvent(id: $id, processedAt: $processedAt, '
      'sessionThreadId: $sessionThreadId)';
}

/// Confirmation result for tool execution.
enum UserToolConfirmationResult {
  /// Tool execution is allowed.
  allow('allow'),

  /// Tool execution is denied.
  deny('deny'),

  /// Unknown result — fallback for unrecognized values.
  unknown('unknown');

  const UserToolConfirmationResult(this.value);

  /// JSON value for this result.
  final String value;

  /// Parses a [UserToolConfirmationResult] from JSON.
  static UserToolConfirmationResult fromJson(String value) => switch (value) {
    'allow' => UserToolConfirmationResult.allow,
    'deny' => UserToolConfirmationResult.deny,
    _ => UserToolConfirmationResult.unknown,
  };

  /// Converts to JSON.
  String toJson() => value;
}

/// A tool confirmation event that approves or denies a pending tool execution.
@immutable
class UserToolConfirmationEvent extends SessionEvent {
  /// The event type, always 'user.tool_confirmation'.
  String get type => 'user.tool_confirmation';

  /// Unique identifier for this event.
  final String id;

  /// The id of the tool_use or mcp_tool_use event this corresponds to.
  final String toolUseId;

  /// The confirmation result: 'allow' or 'deny'.
  final UserToolConfirmationResult result;

  /// Optional message providing context for a 'deny' decision.
  final String? denyMessage;

  /// Timestamp when the confirmation was processed.
  final BetaTimestamp? processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates a [UserToolConfirmationEvent].
  const UserToolConfirmationEvent({
    required this.id,
    required this.toolUseId,
    required this.result,
    this.denyMessage,
    this.processedAt,
    this.sessionThreadId,
  });

  /// Creates a [UserToolConfirmationEvent] from JSON.
  factory UserToolConfirmationEvent.fromJson(Map<String, dynamic> json) {
    return UserToolConfirmationEvent(
      id: json['id'] as String,
      toolUseId: json['tool_use_id'] as String,
      result: UserToolConfirmationResult.fromJson(json['result'] as String),
      denyMessage: json['deny_message'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'tool_use_id': toolUseId,
    'result': result.toJson(),
    if (denyMessage != null) 'deny_message': denyMessage,
    if (processedAt != null)
      'processed_at': processedAt!.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  UserToolConfirmationEvent copyWith({
    String? id,
    String? toolUseId,
    UserToolConfirmationResult? result,
    Object? denyMessage = unsetCopyWithValue,
    Object? processedAt = unsetCopyWithValue,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return UserToolConfirmationEvent(
      id: id ?? this.id,
      toolUseId: toolUseId ?? this.toolUseId,
      result: result ?? this.result,
      denyMessage: denyMessage == unsetCopyWithValue
          ? this.denyMessage
          : denyMessage as String?,
      processedAt: processedAt == unsetCopyWithValue
          ? this.processedAt
          : processedAt as BetaTimestamp?,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserToolConfirmationEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          toolUseId == other.toolUseId &&
          result == other.result &&
          denyMessage == other.denyMessage &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(
    id,
    toolUseId,
    result,
    denyMessage,
    processedAt,
    sessionThreadId,
  );

  @override
  String toString() =>
      'UserToolConfirmationEvent(id: $id, toolUseId: $toolUseId, '
      'result: $result, denyMessage: $denyMessage, '
      'processedAt: $processedAt, sessionThreadId: $sessionThreadId)';
}

/// Custom tool result event sent by the client.
@immutable
class UserCustomToolResultEvent extends SessionEvent {
  /// The event type, always 'user.custom_tool_result'.
  String get type => 'user.custom_tool_result';

  /// Unique identifier for this event.
  final String id;

  /// The id of the agent.custom_tool_use event this result corresponds to.
  final String customToolUseId;

  /// The result content returned by the tool.
  final List<Map<String, dynamic>>? content;

  /// Whether the tool execution resulted in an error.
  final bool? isError;

  /// Timestamp when this result was processed.
  final BetaTimestamp? processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates a [UserCustomToolResultEvent].
  const UserCustomToolResultEvent({
    required this.id,
    required this.customToolUseId,
    this.content,
    this.isError,
    this.processedAt,
    this.sessionThreadId,
  });

  /// Creates a [UserCustomToolResultEvent] from JSON.
  factory UserCustomToolResultEvent.fromJson(Map<String, dynamic> json) {
    return UserCustomToolResultEvent(
      id: json['id'] as String,
      customToolUseId: json['custom_tool_use_id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isError: json['is_error'] as bool?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'custom_tool_use_id': customToolUseId,
    if (content != null) 'content': content,
    if (isError != null) 'is_error': isError,
    if (processedAt != null)
      'processed_at': processedAt!.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  UserCustomToolResultEvent copyWith({
    String? id,
    String? customToolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? processedAt = unsetCopyWithValue,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return UserCustomToolResultEvent(
      id: id ?? this.id,
      customToolUseId: customToolUseId ?? this.customToolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<Map<String, dynamic>>?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      processedAt: processedAt == unsetCopyWithValue
          ? this.processedAt
          : processedAt as BetaTimestamp?,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCustomToolResultEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customToolUseId == other.customToolUseId &&
          listOfMapsDeepEqual(content, other.content) &&
          isError == other.isError &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(
    id,
    customToolUseId,
    listOfMapsHashCode(content),
    isError,
    processedAt,
    sessionThreadId,
  );

  @override
  String toString() =>
      'UserCustomToolResultEvent(id: $id, '
      'customToolUseId: $customToolUseId, content: $content, '
      'isError: $isError, processedAt: $processedAt, '
      'sessionThreadId: $sessionThreadId)';
}

/// Tool result event sent by the client for a generic tool use.
@immutable
class UserToolResultEvent extends SessionEvent {
  /// The event type, always 'user.tool_result'.
  String get type => 'user.tool_result';

  /// Unique identifier for this event.
  final String id;

  /// The id of the tool_use event this result corresponds to.
  final String toolUseId;

  /// The result content returned by the tool.
  final List<Map<String, dynamic>>? content;

  /// Whether the tool execution resulted in an error.
  final bool? isError;

  /// Timestamp when this result was processed.
  final BetaTimestamp? processedAt;

  /// ID of the session thread this event belongs to, if any.
  final String? sessionThreadId;

  /// Creates a [UserToolResultEvent].
  const UserToolResultEvent({
    required this.id,
    required this.toolUseId,
    this.content,
    this.isError,
    this.processedAt,
    this.sessionThreadId,
  });

  /// Creates a [UserToolResultEvent] from JSON.
  factory UserToolResultEvent.fromJson(Map<String, dynamic> json) {
    return UserToolResultEvent(
      id: json['id'] as String,
      toolUseId: json['tool_use_id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isError: json['is_error'] as bool?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      sessionThreadId: json['session_thread_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'tool_use_id': toolUseId,
    if (content != null) 'content': content,
    if (isError != null) 'is_error': isError,
    if (processedAt != null)
      'processed_at': processedAt!.toUtc().toIso8601String(),
    if (sessionThreadId != null) 'session_thread_id': sessionThreadId,
  };

  /// Creates a copy with replaced values.
  UserToolResultEvent copyWith({
    String? id,
    String? toolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? processedAt = unsetCopyWithValue,
    Object? sessionThreadId = unsetCopyWithValue,
  }) {
    return UserToolResultEvent(
      id: id ?? this.id,
      toolUseId: toolUseId ?? this.toolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<Map<String, dynamic>>?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      processedAt: processedAt == unsetCopyWithValue
          ? this.processedAt
          : processedAt as BetaTimestamp?,
      sessionThreadId: sessionThreadId == unsetCopyWithValue
          ? this.sessionThreadId
          : sessionThreadId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserToolResultEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          toolUseId == other.toolUseId &&
          listOfMapsDeepEqual(content, other.content) &&
          isError == other.isError &&
          processedAt == other.processedAt &&
          sessionThreadId == other.sessionThreadId;

  @override
  int get hashCode => Object.hash(
    id,
    toolUseId,
    listOfMapsHashCode(content),
    isError,
    processedAt,
    sessionThreadId,
  );

  @override
  String toString() =>
      'UserToolResultEvent(id: $id, toolUseId: $toolUseId, '
      'content: $content, isError: $isError, processedAt: $processedAt, '
      'sessionThreadId: $sessionThreadId)';
}

// ---------------------------------------------------------------------------
// Session status events
// ---------------------------------------------------------------------------

/// Session is actively running and the agent is working.
@immutable
class SessionStatusRunningEvent extends SessionEvent {
  /// The event type, always 'session.status_running'.
  String get type => 'session.status_running';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp of status change.
  final BetaTimestamp processedAt;

  /// Creates a [SessionStatusRunningEvent].
  const SessionStatusRunningEvent({
    required this.id,
    required this.processedAt,
  });

  /// Creates a [SessionStatusRunningEvent] from JSON.
  factory SessionStatusRunningEvent.fromJson(Map<String, dynamic> json) {
    return SessionStatusRunningEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionStatusRunningEvent copyWith({String? id, BetaTimestamp? processedAt}) {
    return SessionStatusRunningEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusRunningEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() =>
      'SessionStatusRunningEvent(id: $id, processedAt: $processedAt)';
}

/// The reason the session transitioned to idle.
///
/// Variants:
/// - [SessionEndTurn] — agent completed its turn naturally.
/// - [SessionRequiresAction] — agent is waiting on blocking user input.
/// - [SessionRetriesExhausted] — turn ended because retry budget exhausted.
/// - [UnknownSessionStopReason] — unrecognized stop reason.
sealed class SessionStopReason {
  const SessionStopReason();

  /// Creates a [SessionStopReason] from JSON.
  factory SessionStopReason.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'end_turn' => SessionEndTurn.fromJson(json),
      'requires_action' => SessionRequiresAction.fromJson(json),
      'retries_exhausted' => SessionRetriesExhausted.fromJson(json),
      _ => UnknownSessionStopReason(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The agent completed its turn naturally.
@immutable
class SessionEndTurn extends SessionStopReason {
  /// The type, always 'end_turn'.
  String get type => 'end_turn';

  /// Creates a [SessionEndTurn].
  const SessionEndTurn();

  /// Creates a [SessionEndTurn] from JSON.
  factory SessionEndTurn.fromJson(Map<String, dynamic> _) {
    return const SessionEndTurn();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEndTurn && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SessionEndTurn()';
}

/// The agent is idle waiting on blocking user-input events.
@immutable
class SessionRequiresAction extends SessionStopReason {
  /// The type, always 'requires_action'.
  String get type => 'requires_action';

  /// The ids of events the agent is blocked on.
  final List<String> eventIds;

  /// Creates a [SessionRequiresAction].
  const SessionRequiresAction({required this.eventIds});

  /// Creates a [SessionRequiresAction] from JSON.
  factory SessionRequiresAction.fromJson(Map<String, dynamic> json) {
    return SessionRequiresAction(
      eventIds: (json['event_ids'] as List).map((e) => e as String).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'event_ids': eventIds};

  /// Creates a copy with replaced values.
  SessionRequiresAction copyWith({List<String>? eventIds}) {
    return SessionRequiresAction(eventIds: eventIds ?? this.eventIds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRequiresAction &&
          runtimeType == other.runtimeType &&
          listsEqual(eventIds, other.eventIds);

  @override
  int get hashCode => listHash(eventIds);

  @override
  String toString() => 'SessionRequiresAction(eventIds: $eventIds)';
}

/// The turn ended because the retry budget was exhausted.
@immutable
class SessionRetriesExhausted extends SessionStopReason {
  /// The type, always 'retries_exhausted'.
  String get type => 'retries_exhausted';

  /// Creates a [SessionRetriesExhausted].
  const SessionRetriesExhausted();

  /// Creates a [SessionRetriesExhausted] from JSON.
  factory SessionRetriesExhausted.fromJson(Map<String, dynamic> _) {
    return const SessionRetriesExhausted();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRetriesExhausted && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SessionRetriesExhausted()';
}

/// Unrecognized stop reason — preserves raw JSON.
@immutable
class UnknownSessionStopReason extends SessionStopReason {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSessionStopReason].
  const UnknownSessionStopReason({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSessionStopReason &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSessionStopReason(rawJson: $rawJson)';
}

/// Session is idle, awaiting user input.
@immutable
class SessionStatusIdleEvent extends SessionEvent {
  /// The event type, always 'session.status_idle'.
  String get type => 'session.status_idle';

  /// Unique identifier for this event.
  final String id;

  /// The reason the session transitioned to idle.
  final SessionStopReason stopReason;

  /// Timestamp of status change.
  final BetaTimestamp processedAt;

  /// Creates a [SessionStatusIdleEvent].
  const SessionStatusIdleEvent({
    required this.id,
    required this.stopReason,
    required this.processedAt,
  });

  /// Creates a [SessionStatusIdleEvent] from JSON.
  factory SessionStatusIdleEvent.fromJson(Map<String, dynamic> json) {
    return SessionStatusIdleEvent(
      id: json['id'] as String,
      stopReason: SessionStopReason.fromJson(
        json['stop_reason'] as Map<String, dynamic>,
      ),
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'stop_reason': stopReason.toJson(),
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionStatusIdleEvent copyWith({
    String? id,
    SessionStopReason? stopReason,
    BetaTimestamp? processedAt,
  }) {
    return SessionStatusIdleEvent(
      id: id ?? this.id,
      stopReason: stopReason ?? this.stopReason,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusIdleEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          stopReason == other.stopReason &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, stopReason, processedAt);

  @override
  String toString() =>
      'SessionStatusIdleEvent(id: $id, stopReason: $stopReason, '
      'processedAt: $processedAt)';
}

/// Session rescheduled after recovering from an error.
@immutable
class SessionStatusRescheduledEvent extends SessionEvent {
  /// The event type, always 'session.status_rescheduled'.
  String get type => 'session.status_rescheduled';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp of status change.
  final BetaTimestamp processedAt;

  /// Creates a [SessionStatusRescheduledEvent].
  const SessionStatusRescheduledEvent({
    required this.id,
    required this.processedAt,
  });

  /// Creates a [SessionStatusRescheduledEvent] from JSON.
  factory SessionStatusRescheduledEvent.fromJson(Map<String, dynamic> json) {
    return SessionStatusRescheduledEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionStatusRescheduledEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
  }) {
    return SessionStatusRescheduledEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusRescheduledEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() =>
      'SessionStatusRescheduledEvent(id: $id, processedAt: $processedAt)';
}

/// Session has terminated.
@immutable
class SessionStatusTerminatedEvent extends SessionEvent {
  /// The event type, always 'session.status_terminated'.
  String get type => 'session.status_terminated';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp of status change.
  final BetaTimestamp processedAt;

  /// Creates a [SessionStatusTerminatedEvent].
  const SessionStatusTerminatedEvent({
    required this.id,
    required this.processedAt,
  });

  /// Creates a [SessionStatusTerminatedEvent] from JSON.
  factory SessionStatusTerminatedEvent.fromJson(Map<String, dynamic> json) {
    return SessionStatusTerminatedEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionStatusTerminatedEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
  }) {
    return SessionStatusTerminatedEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusTerminatedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() =>
      'SessionStatusTerminatedEvent(id: $id, processedAt: $processedAt)';
}

/// An error event during session execution.
@immutable
class SessionErrorEvent extends SessionEvent {
  /// The event type, always 'session.error'.
  String get type => 'session.error';

  /// Unique identifier for this event.
  final String id;

  /// The error details.
  final Map<String, dynamic> error;

  /// Timestamp when the error occurred.
  final BetaTimestamp processedAt;

  /// Creates a [SessionErrorEvent].
  const SessionErrorEvent({
    required this.id,
    required this.error,
    required this.processedAt,
  });

  /// Creates a [SessionErrorEvent] from JSON.
  factory SessionErrorEvent.fromJson(Map<String, dynamic> json) {
    return SessionErrorEvent(
      id: json['id'] as String,
      error: json['error'] as Map<String, dynamic>,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'error': error,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionErrorEvent copyWith({
    String? id,
    Map<String, dynamic>? error,
    BetaTimestamp? processedAt,
  }) {
    return SessionErrorEvent(
      id: id ?? this.id,
      error: error ?? this.error,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionErrorEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mapsDeepEqual(error, other.error) &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, mapDeepHashCode(error), processedAt);

  @override
  String toString() =>
      'SessionErrorEvent(id: $id, error: $error, '
      'processedAt: $processedAt)';
}

/// Session has been deleted.
@immutable
class SessionDeletedEvent extends SessionEvent {
  /// The event type, always 'session.deleted'.
  String get type => 'session.deleted';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when the session was deleted.
  final BetaTimestamp processedAt;

  /// Creates a [SessionDeletedEvent].
  const SessionDeletedEvent({required this.id, required this.processedAt});

  /// Creates a [SessionDeletedEvent] from JSON.
  factory SessionDeletedEvent.fromJson(Map<String, dynamic> json) {
    return SessionDeletedEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionDeletedEvent copyWith({String? id, BetaTimestamp? processedAt}) {
    return SessionDeletedEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionDeletedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() =>
      'SessionDeletedEvent(id: $id, processedAt: $processedAt)';
}

/// Emitted when an UpdateSession request changed at least one field.
@immutable
class SessionUpdatedEvent extends SessionEvent {
  /// The event type, always 'session.updated'.
  String get type => 'session.updated';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when the update was processed.
  final BetaTimestamp processedAt;

  /// The updated agent configuration, if the agent changed.
  final SessionAgent? agent;

  /// The updated session metadata, if it changed.
  final Map<String, String>? metadata;

  /// The updated session title, if it changed.
  final String? title;

  /// Creates a [SessionUpdatedEvent].
  const SessionUpdatedEvent({
    required this.id,
    required this.processedAt,
    this.agent,
    this.metadata,
    this.title,
  });

  /// Creates a [SessionUpdatedEvent] from JSON.
  factory SessionUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return SessionUpdatedEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
      agent: json['agent'] != null
          ? SessionAgent.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      title: json['title'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
    if (agent != null) 'agent': agent!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (title != null) 'title': title,
  };

  /// Creates a copy with replaced values.
  SessionUpdatedEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
    Object? agent = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
  }) {
    return SessionUpdatedEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
      agent: agent == unsetCopyWithValue ? this.agent : agent as SessionAgent?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUpdatedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt &&
          agent == other.agent &&
          mapsEqual(metadata, other.metadata) &&
          title == other.title;

  @override
  int get hashCode =>
      Object.hash(id, processedAt, agent, mapHash(metadata), title);

  @override
  String toString() =>
      'SessionUpdatedEvent(id: $id, processedAt: $processedAt, '
      'agent: $agent, metadata: $metadata, title: $title)';
}

// ---------------------------------------------------------------------------
// Span events
// ---------------------------------------------------------------------------

/// Model request started.
@immutable
class SpanModelRequestStartEvent extends SessionEvent {
  /// The event type, always 'span.model_request_start'.
  String get type => 'span.model_request_start';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when the model request started.
  final BetaTimestamp processedAt;

  /// Creates a [SpanModelRequestStartEvent].
  const SpanModelRequestStartEvent({
    required this.id,
    required this.processedAt,
  });

  /// Creates a [SpanModelRequestStartEvent] from JSON.
  factory SpanModelRequestStartEvent.fromJson(Map<String, dynamic> json) {
    return SpanModelRequestStartEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SpanModelRequestStartEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
  }) {
    return SpanModelRequestStartEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanModelRequestStartEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, processedAt);

  @override
  String toString() =>
      'SpanModelRequestStartEvent(id: $id, processedAt: $processedAt)';
}

/// Model request completed.
@immutable
class SpanModelRequestEndEvent extends SessionEvent {
  /// The event type, always 'span.model_request_end'.
  String get type => 'span.model_request_end';

  /// Unique identifier for this event.
  final String id;

  /// Whether the model request resulted in an error.
  final bool? isError;

  /// Token usage for this model request.
  final SpanModelUsage? modelUsage;

  /// The id of the corresponding span.model_request_start event.
  final String modelRequestStartId;

  /// Timestamp when the model request completed.
  final BetaTimestamp processedAt;

  /// Creates a [SpanModelRequestEndEvent].
  const SpanModelRequestEndEvent({
    required this.id,
    this.isError,
    this.modelUsage,
    required this.modelRequestStartId,
    required this.processedAt,
  });

  /// Creates a [SpanModelRequestEndEvent] from JSON.
  factory SpanModelRequestEndEvent.fromJson(Map<String, dynamic> json) {
    return SpanModelRequestEndEvent(
      id: json['id'] as String,
      isError: json['is_error'] as bool?,
      modelUsage: json['model_usage'] != null
          ? SpanModelUsage.fromJson(json['model_usage'] as Map<String, dynamic>)
          : null,
      modelRequestStartId: json['model_request_start_id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (isError != null) 'is_error': isError,
    if (modelUsage != null) 'model_usage': modelUsage!.toJson(),
    'model_request_start_id': modelRequestStartId,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SpanModelRequestEndEvent copyWith({
    String? id,
    Object? isError = unsetCopyWithValue,
    Object? modelUsage = unsetCopyWithValue,
    String? modelRequestStartId,
    BetaTimestamp? processedAt,
  }) {
    return SpanModelRequestEndEvent(
      id: id ?? this.id,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      modelUsage: modelUsage == unsetCopyWithValue
          ? this.modelUsage
          : modelUsage as SpanModelUsage?,
      modelRequestStartId: modelRequestStartId ?? this.modelRequestStartId,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanModelRequestEndEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isError == other.isError &&
          modelUsage == other.modelUsage &&
          modelRequestStartId == other.modelRequestStartId &&
          processedAt == other.processedAt;

  @override
  int get hashCode =>
      Object.hash(id, isError, modelUsage, modelRequestStartId, processedAt);

  @override
  String toString() =>
      'SpanModelRequestEndEvent(id: $id, isError: $isError, '
      'modelUsage: $modelUsage, '
      'modelRequestStartId: $modelRequestStartId, '
      'processedAt: $processedAt)';
}

// ---------------------------------------------------------------------------
// Session thread events
// ---------------------------------------------------------------------------

/// A thread was created within the session.
@immutable
class SessionThreadCreatedEvent extends SessionEvent {
  /// The event type, always 'session.thread_created'.
  String get type => 'session.thread_created';

  /// Unique identifier for this event.
  final String id;

  /// Name of the agent owning the thread.
  final String agentName;

  /// ID of the session thread that was created.
  final String sessionThreadId;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates a [SessionThreadCreatedEvent].
  const SessionThreadCreatedEvent({
    required this.id,
    required this.agentName,
    required this.sessionThreadId,
    required this.processedAt,
  });

  /// Creates a [SessionThreadCreatedEvent] from JSON.
  factory SessionThreadCreatedEvent.fromJson(Map<String, dynamic> json) {
    return SessionThreadCreatedEvent(
      id: json['id'] as String,
      agentName: json['agent_name'] as String,
      sessionThreadId: json['session_thread_id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'agent_name': agentName,
    'session_thread_id': sessionThreadId,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionThreadCreatedEvent copyWith({
    String? id,
    String? agentName,
    String? sessionThreadId,
    BetaTimestamp? processedAt,
  }) {
    return SessionThreadCreatedEvent(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      sessionThreadId: sessionThreadId ?? this.sessionThreadId,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThreadCreatedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agentName == other.agentName &&
          sessionThreadId == other.sessionThreadId &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, agentName, sessionThreadId, processedAt);

  @override
  String toString() =>
      'SessionThreadCreatedEvent(id: $id, agentName: $agentName, '
      'sessionThreadId: $sessionThreadId, processedAt: $processedAt)';
}

/// Thread is actively running.
@immutable
class SessionThreadStatusRunningEvent extends SessionEvent {
  /// The event type, always 'session.thread_status_running'.
  String get type => 'session.thread_status_running';

  /// Unique identifier for this event.
  final String id;

  /// Name of the agent owning the thread.
  final String agentName;

  /// ID of the session thread whose status changed.
  final String sessionThreadId;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates a [SessionThreadStatusRunningEvent].
  const SessionThreadStatusRunningEvent({
    required this.id,
    required this.agentName,
    required this.sessionThreadId,
    required this.processedAt,
  });

  /// Creates a [SessionThreadStatusRunningEvent] from JSON.
  factory SessionThreadStatusRunningEvent.fromJson(Map<String, dynamic> json) {
    return SessionThreadStatusRunningEvent(
      id: json['id'] as String,
      agentName: json['agent_name'] as String,
      sessionThreadId: json['session_thread_id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'agent_name': agentName,
    'session_thread_id': sessionThreadId,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionThreadStatusRunningEvent copyWith({
    String? id,
    String? agentName,
    String? sessionThreadId,
    BetaTimestamp? processedAt,
  }) {
    return SessionThreadStatusRunningEvent(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      sessionThreadId: sessionThreadId ?? this.sessionThreadId,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThreadStatusRunningEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agentName == other.agentName &&
          sessionThreadId == other.sessionThreadId &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, agentName, sessionThreadId, processedAt);

  @override
  String toString() =>
      'SessionThreadStatusRunningEvent(id: $id, agentName: $agentName, '
      'sessionThreadId: $sessionThreadId, processedAt: $processedAt)';
}

/// Thread became idle, awaiting more input.
@immutable
class SessionThreadStatusIdleEvent extends SessionEvent {
  /// The event type, always 'session.thread_status_idle'.
  String get type => 'session.thread_status_idle';

  /// Unique identifier for this event.
  final String id;

  /// Name of the agent owning the thread.
  final String agentName;

  /// ID of the session thread whose status changed.
  final String sessionThreadId;

  /// The reason the thread transitioned to idle.
  final SessionStopReason stopReason;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates a [SessionThreadStatusIdleEvent].
  const SessionThreadStatusIdleEvent({
    required this.id,
    required this.agentName,
    required this.sessionThreadId,
    required this.stopReason,
    required this.processedAt,
  });

  /// Creates a [SessionThreadStatusIdleEvent] from JSON.
  factory SessionThreadStatusIdleEvent.fromJson(Map<String, dynamic> json) {
    return SessionThreadStatusIdleEvent(
      id: json['id'] as String,
      agentName: json['agent_name'] as String,
      sessionThreadId: json['session_thread_id'] as String,
      stopReason: SessionStopReason.fromJson(
        json['stop_reason'] as Map<String, dynamic>,
      ),
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'agent_name': agentName,
    'session_thread_id': sessionThreadId,
    'stop_reason': stopReason.toJson(),
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionThreadStatusIdleEvent copyWith({
    String? id,
    String? agentName,
    String? sessionThreadId,
    SessionStopReason? stopReason,
    BetaTimestamp? processedAt,
  }) {
    return SessionThreadStatusIdleEvent(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      sessionThreadId: sessionThreadId ?? this.sessionThreadId,
      stopReason: stopReason ?? this.stopReason,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThreadStatusIdleEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agentName == other.agentName &&
          sessionThreadId == other.sessionThreadId &&
          stopReason == other.stopReason &&
          processedAt == other.processedAt;

  @override
  int get hashCode =>
      Object.hash(id, agentName, sessionThreadId, stopReason, processedAt);

  @override
  String toString() =>
      'SessionThreadStatusIdleEvent(id: $id, agentName: $agentName, '
      'sessionThreadId: $sessionThreadId, stopReason: $stopReason, '
      'processedAt: $processedAt)';
}

/// Thread rescheduled after recovering from an error.
@immutable
class SessionThreadStatusRescheduledEvent extends SessionEvent {
  /// The event type, always 'session.thread_status_rescheduled'.
  String get type => 'session.thread_status_rescheduled';

  /// Unique identifier for this event.
  final String id;

  /// Name of the agent owning the thread.
  final String agentName;

  /// ID of the session thread whose status changed.
  final String sessionThreadId;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates a [SessionThreadStatusRescheduledEvent].
  const SessionThreadStatusRescheduledEvent({
    required this.id,
    required this.agentName,
    required this.sessionThreadId,
    required this.processedAt,
  });

  /// Creates a [SessionThreadStatusRescheduledEvent] from JSON.
  factory SessionThreadStatusRescheduledEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return SessionThreadStatusRescheduledEvent(
      id: json['id'] as String,
      agentName: json['agent_name'] as String,
      sessionThreadId: json['session_thread_id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'agent_name': agentName,
    'session_thread_id': sessionThreadId,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionThreadStatusRescheduledEvent copyWith({
    String? id,
    String? agentName,
    String? sessionThreadId,
    BetaTimestamp? processedAt,
  }) {
    return SessionThreadStatusRescheduledEvent(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      sessionThreadId: sessionThreadId ?? this.sessionThreadId,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThreadStatusRescheduledEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agentName == other.agentName &&
          sessionThreadId == other.sessionThreadId &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, agentName, sessionThreadId, processedAt);

  @override
  String toString() =>
      'SessionThreadStatusRescheduledEvent(id: $id, agentName: $agentName, '
      'sessionThreadId: $sessionThreadId, processedAt: $processedAt)';
}

/// Thread terminated.
@immutable
class SessionThreadStatusTerminatedEvent extends SessionEvent {
  /// The event type, always 'session.thread_status_terminated'.
  String get type => 'session.thread_status_terminated';

  /// Unique identifier for this event.
  final String id;

  /// Name of the agent owning the thread.
  final String agentName;

  /// ID of the session thread whose status changed.
  final String sessionThreadId;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates a [SessionThreadStatusTerminatedEvent].
  const SessionThreadStatusTerminatedEvent({
    required this.id,
    required this.agentName,
    required this.sessionThreadId,
    required this.processedAt,
  });

  /// Creates a [SessionThreadStatusTerminatedEvent] from JSON.
  factory SessionThreadStatusTerminatedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return SessionThreadStatusTerminatedEvent(
      id: json['id'] as String,
      agentName: json['agent_name'] as String,
      sessionThreadId: json['session_thread_id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'agent_name': agentName,
    'session_thread_id': sessionThreadId,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SessionThreadStatusTerminatedEvent copyWith({
    String? id,
    String? agentName,
    String? sessionThreadId,
    BetaTimestamp? processedAt,
  }) {
    return SessionThreadStatusTerminatedEvent(
      id: id ?? this.id,
      agentName: agentName ?? this.agentName,
      sessionThreadId: sessionThreadId ?? this.sessionThreadId,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThreadStatusTerminatedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agentName == other.agentName &&
          sessionThreadId == other.sessionThreadId &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(id, agentName, sessionThreadId, processedAt);

  @override
  String toString() =>
      'SessionThreadStatusTerminatedEvent(id: $id, agentName: $agentName, '
      'sessionThreadId: $sessionThreadId, processedAt: $processedAt)';
}

// ---------------------------------------------------------------------------
// Cross-thread message events
// ---------------------------------------------------------------------------

/// A peer agent thread sent this thread a message.
@immutable
class AgentThreadMessageReceivedEvent extends SessionEvent {
  /// The event type, always 'agent.thread_message_received'.
  String get type => 'agent.thread_message_received';

  /// Unique identifier for this event.
  final String id;

  /// ID of the session thread that sent the message.
  final String fromSessionThreadId;

  /// Name of the agent that owns the sending thread. May be `null` if the
  /// sender isn't a named agent.
  final String? fromAgentName;

  /// Message content blocks delivered by the peer thread.
  final List<Map<String, dynamic>> content;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates an [AgentThreadMessageReceivedEvent].
  const AgentThreadMessageReceivedEvent({
    required this.id,
    required this.fromSessionThreadId,
    this.fromAgentName,
    required this.content,
    required this.processedAt,
  });

  /// Creates an [AgentThreadMessageReceivedEvent] from JSON.
  factory AgentThreadMessageReceivedEvent.fromJson(Map<String, dynamic> json) {
    return AgentThreadMessageReceivedEvent(
      id: json['id'] as String,
      fromSessionThreadId: json['from_session_thread_id'] as String,
      fromAgentName: json['from_agent_name'] as String?,
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'from_session_thread_id': fromSessionThreadId,
    if (fromAgentName != null) 'from_agent_name': fromAgentName,
    'content': content,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentThreadMessageReceivedEvent copyWith({
    String? id,
    String? fromSessionThreadId,
    Object? fromAgentName = unsetCopyWithValue,
    List<Map<String, dynamic>>? content,
    BetaTimestamp? processedAt,
  }) {
    return AgentThreadMessageReceivedEvent(
      id: id ?? this.id,
      fromSessionThreadId: fromSessionThreadId ?? this.fromSessionThreadId,
      fromAgentName: fromAgentName == unsetCopyWithValue
          ? this.fromAgentName
          : fromAgentName as String?,
      content: content ?? this.content,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentThreadMessageReceivedEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fromSessionThreadId == other.fromSessionThreadId &&
          fromAgentName == other.fromAgentName &&
          listOfMapsDeepEqual(content, other.content) &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(
    id,
    fromSessionThreadId,
    fromAgentName,
    listOfMapsHashCode(content),
    processedAt,
  );

  @override
  String toString() =>
      'AgentThreadMessageReceivedEvent(id: $id, '
      'fromSessionThreadId: $fromSessionThreadId, '
      'fromAgentName: $fromAgentName, '
      'content: ${content.length} items, '
      'processedAt: $processedAt)';
}

/// This thread sent a peer agent thread a message.
@immutable
class AgentThreadMessageSentEvent extends SessionEvent {
  /// The event type, always 'agent.thread_message_sent'.
  String get type => 'agent.thread_message_sent';

  /// Unique identifier for this event.
  final String id;

  /// ID of the session thread that received the message.
  final String toSessionThreadId;

  /// Name of the agent that owns the recipient thread. May be `null` if the
  /// recipient isn't a named agent.
  final String? toAgentName;

  /// Message content blocks delivered to the peer thread.
  final List<Map<String, dynamic>> content;

  /// Timestamp when this event was processed.
  final BetaTimestamp processedAt;

  /// Creates an [AgentThreadMessageSentEvent].
  const AgentThreadMessageSentEvent({
    required this.id,
    required this.toSessionThreadId,
    this.toAgentName,
    required this.content,
    required this.processedAt,
  });

  /// Creates an [AgentThreadMessageSentEvent] from JSON.
  factory AgentThreadMessageSentEvent.fromJson(Map<String, dynamic> json) {
    return AgentThreadMessageSentEvent(
      id: json['id'] as String,
      toSessionThreadId: json['to_session_thread_id'] as String,
      toAgentName: json['to_agent_name'] as String?,
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'to_session_thread_id': toSessionThreadId,
    if (toAgentName != null) 'to_agent_name': toAgentName,
    'content': content,
    'processed_at': processedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  AgentThreadMessageSentEvent copyWith({
    String? id,
    String? toSessionThreadId,
    Object? toAgentName = unsetCopyWithValue,
    List<Map<String, dynamic>>? content,
    BetaTimestamp? processedAt,
  }) {
    return AgentThreadMessageSentEvent(
      id: id ?? this.id,
      toSessionThreadId: toSessionThreadId ?? this.toSessionThreadId,
      toAgentName: toAgentName == unsetCopyWithValue
          ? this.toAgentName
          : toAgentName as String?,
      content: content ?? this.content,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentThreadMessageSentEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          toSessionThreadId == other.toSessionThreadId &&
          toAgentName == other.toAgentName &&
          listOfMapsDeepEqual(content, other.content) &&
          processedAt == other.processedAt;

  @override
  int get hashCode => Object.hash(
    id,
    toSessionThreadId,
    toAgentName,
    listOfMapsHashCode(content),
    processedAt,
  );

  @override
  String toString() =>
      'AgentThreadMessageSentEvent(id: $id, '
      'toSessionThreadId: $toSessionThreadId, '
      'toAgentName: $toAgentName, '
      'content: ${content.length} items, '
      'processedAt: $processedAt)';
}

// ---------------------------------------------------------------------------
// Outcome evaluation events
// ---------------------------------------------------------------------------

/// Emitted when an outcome evaluation cycle begins.
@immutable
class SpanOutcomeEvaluationStartEvent extends SessionEvent {
  /// The event type, always 'span.outcome_evaluation_start'.
  String get type => 'span.outcome_evaluation_start';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when outcome evaluation started.
  final BetaTimestamp processedAt;

  /// 0-indexed revision cycle being evaluated.
  final int iteration;

  /// The `outc_` ID of the outcome being evaluated.
  final String outcomeId;

  /// Creates a [SpanOutcomeEvaluationStartEvent].
  const SpanOutcomeEvaluationStartEvent({
    required this.id,
    required this.processedAt,
    required this.iteration,
    required this.outcomeId,
  });

  /// Creates a [SpanOutcomeEvaluationStartEvent] from JSON.
  factory SpanOutcomeEvaluationStartEvent.fromJson(Map<String, dynamic> json) {
    return SpanOutcomeEvaluationStartEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
      iteration: json['iteration'] as int,
      outcomeId: json['outcome_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
    'iteration': iteration,
    'outcome_id': outcomeId,
  };

  /// Creates a copy with replaced values.
  SpanOutcomeEvaluationStartEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
    int? iteration,
    String? outcomeId,
  }) {
    return SpanOutcomeEvaluationStartEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
      iteration: iteration ?? this.iteration,
      outcomeId: outcomeId ?? this.outcomeId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanOutcomeEvaluationStartEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt &&
          iteration == other.iteration &&
          outcomeId == other.outcomeId;

  @override
  int get hashCode => Object.hash(id, processedAt, iteration, outcomeId);

  @override
  String toString() =>
      'SpanOutcomeEvaluationStartEvent(id: $id, processedAt: $processedAt, '
      'iteration: $iteration, outcomeId: $outcomeId)';
}

/// Periodic heartbeat emitted while an outcome evaluation cycle is in progress.
@immutable
class SpanOutcomeEvaluationOngoingEvent extends SessionEvent {
  /// The event type, always 'span.outcome_evaluation_ongoing'.
  String get type => 'span.outcome_evaluation_ongoing';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when this heartbeat was emitted.
  final BetaTimestamp processedAt;

  /// 0-indexed revision cycle being evaluated.
  final int iteration;

  /// The `outc_` ID of the outcome being evaluated.
  final String outcomeId;

  /// Creates a [SpanOutcomeEvaluationOngoingEvent].
  const SpanOutcomeEvaluationOngoingEvent({
    required this.id,
    required this.processedAt,
    required this.iteration,
    required this.outcomeId,
  });

  /// Creates a [SpanOutcomeEvaluationOngoingEvent] from JSON.
  factory SpanOutcomeEvaluationOngoingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return SpanOutcomeEvaluationOngoingEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
      iteration: json['iteration'] as int,
      outcomeId: json['outcome_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
    'iteration': iteration,
    'outcome_id': outcomeId,
  };

  /// Creates a copy with replaced values.
  SpanOutcomeEvaluationOngoingEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
    int? iteration,
    String? outcomeId,
  }) {
    return SpanOutcomeEvaluationOngoingEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
      iteration: iteration ?? this.iteration,
      outcomeId: outcomeId ?? this.outcomeId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanOutcomeEvaluationOngoingEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt &&
          iteration == other.iteration &&
          outcomeId == other.outcomeId;

  @override
  int get hashCode => Object.hash(id, processedAt, iteration, outcomeId);

  @override
  String toString() =>
      'SpanOutcomeEvaluationOngoingEvent(id: $id, processedAt: $processedAt, '
      'iteration: $iteration, outcomeId: $outcomeId)';
}

/// Emitted when an outcome evaluation cycle completes. Carries the verdict and
/// aggregate token usage.
@immutable
class SpanOutcomeEvaluationEndEvent extends SessionEvent {
  /// The event type, always 'span.outcome_evaluation_end'.
  String get type => 'span.outcome_evaluation_end';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when outcome evaluation ended.
  final BetaTimestamp processedAt;

  /// The id of the corresponding `span.outcome_evaluation_start` event.
  final String outcomeEvaluationStartId;

  /// 0-indexed revision cycle being evaluated.
  final int iteration;

  /// Evaluation verdict (e.g. `satisfied`, `needs_revision`, `failed`).
  final String result;

  /// Human-readable explanation of the verdict.
  final String explanation;

  /// Aggregate token usage for this evaluation cycle.
  final SpanModelUsage usage;

  /// The `outc_` ID of the outcome being evaluated.
  final String outcomeId;

  /// Creates a [SpanOutcomeEvaluationEndEvent].
  const SpanOutcomeEvaluationEndEvent({
    required this.id,
    required this.processedAt,
    required this.outcomeEvaluationStartId,
    required this.iteration,
    required this.result,
    required this.explanation,
    required this.usage,
    required this.outcomeId,
  });

  /// Creates a [SpanOutcomeEvaluationEndEvent] from JSON.
  factory SpanOutcomeEvaluationEndEvent.fromJson(Map<String, dynamic> json) {
    return SpanOutcomeEvaluationEndEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
      outcomeEvaluationStartId: json['outcome_evaluation_start_id'] as String,
      iteration: json['iteration'] as int,
      result: json['result'] as String,
      explanation: json['explanation'] as String,
      usage: SpanModelUsage.fromJson(json['usage'] as Map<String, dynamic>),
      outcomeId: json['outcome_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
    'outcome_evaluation_start_id': outcomeEvaluationStartId,
    'iteration': iteration,
    'result': result,
    'explanation': explanation,
    'usage': usage.toJson(),
    'outcome_id': outcomeId,
  };

  /// Creates a copy with replaced values.
  SpanOutcomeEvaluationEndEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
    String? outcomeEvaluationStartId,
    int? iteration,
    String? result,
    String? explanation,
    SpanModelUsage? usage,
    String? outcomeId,
  }) {
    return SpanOutcomeEvaluationEndEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
      outcomeEvaluationStartId:
          outcomeEvaluationStartId ?? this.outcomeEvaluationStartId,
      iteration: iteration ?? this.iteration,
      result: result ?? this.result,
      explanation: explanation ?? this.explanation,
      usage: usage ?? this.usage,
      outcomeId: outcomeId ?? this.outcomeId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanOutcomeEvaluationEndEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt &&
          outcomeEvaluationStartId == other.outcomeEvaluationStartId &&
          iteration == other.iteration &&
          result == other.result &&
          explanation == other.explanation &&
          usage == other.usage &&
          outcomeId == other.outcomeId;

  @override
  int get hashCode => Object.hash(
    id,
    processedAt,
    outcomeEvaluationStartId,
    iteration,
    result,
    explanation,
    usage,
    outcomeId,
  );

  @override
  String toString() =>
      'SpanOutcomeEvaluationEndEvent(id: $id, processedAt: $processedAt, '
      'outcomeEvaluationStartId: $outcomeEvaluationStartId, '
      'iteration: $iteration, result: $result, explanation: $explanation, '
      'usage: $usage, outcomeId: $outcomeId)';
}

/// Echo of a `user.define_outcome` input event. Carries the server-generated
/// `outcomeId` that subsequent `span.outcome_evaluation_*` events reference.
@immutable
class UserDefineOutcomeEvent extends SessionEvent {
  /// The event type, always 'user.define_outcome'.
  String get type => 'user.define_outcome';

  /// Unique identifier for this event.
  final String id;

  /// Timestamp when the outcome was accepted.
  final BetaTimestamp processedAt;

  /// Server-generated `outc_` ID for this outcome.
  final String outcomeId;

  /// What the agent should produce. Copied from the input event.
  final String description;

  /// Evaluate-then-revise cycles before giving up. Default 3, max 20.
  final int? maxIterations;

  /// How to grade the outcome.
  final Rubric rubric;

  /// Creates a [UserDefineOutcomeEvent].
  const UserDefineOutcomeEvent({
    required this.id,
    required this.processedAt,
    required this.outcomeId,
    required this.description,
    required this.maxIterations,
    required this.rubric,
  });

  /// Creates a [UserDefineOutcomeEvent] from JSON.
  factory UserDefineOutcomeEvent.fromJson(Map<String, dynamic> json) {
    return UserDefineOutcomeEvent(
      id: json['id'] as String,
      processedAt: DateTime.parse(json['processed_at'] as String),
      outcomeId: json['outcome_id'] as String,
      description: json['description'] as String,
      maxIterations: json['max_iterations'] as int?,
      rubric: Rubric.fromJson(json['rubric'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'processed_at': processedAt.toUtc().toIso8601String(),
    'outcome_id': outcomeId,
    'description': description,
    'max_iterations': maxIterations,
    'rubric': rubric.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For the nullable field [maxIterations], pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass `null`
  /// explicitly to set the field to null.
  UserDefineOutcomeEvent copyWith({
    String? id,
    BetaTimestamp? processedAt,
    String? outcomeId,
    String? description,
    Object? maxIterations = unsetCopyWithValue,
    Rubric? rubric,
  }) {
    return UserDefineOutcomeEvent(
      id: id ?? this.id,
      processedAt: processedAt ?? this.processedAt,
      outcomeId: outcomeId ?? this.outcomeId,
      description: description ?? this.description,
      maxIterations: maxIterations == unsetCopyWithValue
          ? this.maxIterations
          : maxIterations as int?,
      rubric: rubric ?? this.rubric,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDefineOutcomeEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          processedAt == other.processedAt &&
          outcomeId == other.outcomeId &&
          description == other.description &&
          maxIterations == other.maxIterations &&
          rubric == other.rubric;

  @override
  int get hashCode => Object.hash(
    id,
    processedAt,
    outcomeId,
    description,
    maxIterations,
    rubric,
  );

  @override
  String toString() =>
      'UserDefineOutcomeEvent(id: $id, processedAt: $processedAt, '
      'outcomeId: $outcomeId, description: $description, '
      'maxIterations: $maxIterations, rubric: $rubric)';
}

// ---------------------------------------------------------------------------
// Unknown fallback
// ---------------------------------------------------------------------------

/// Unrecognized session event — preserves raw JSON.
@immutable
class UnknownSessionEvent extends SessionEvent {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSessionEvent].
  const UnknownSessionEvent({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSessionEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSessionEvent(rawJson: $rawJson)';
}
