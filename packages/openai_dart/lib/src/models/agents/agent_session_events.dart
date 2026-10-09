part of 'agent_session_models.dart';

/// An event emitted by a Managed Agents session.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionEvent extends AgentJsonModel {
  const AgentSessionEvent();

  /// Parses a known contract or detached future received value.
  factory AgentSessionEvent.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(json['type'], 'AgentSessionEvent.type')) {
      'agent.output.command_execution_output.delta' =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(json),
      'agent.session.created' => AgentSessionCreatedEvent.fromJson(json),
      'agent.session.environment.connected' =>
        AgentSessionEnvironmentConnectedEvent.fromJson(json),
      'agent.session.environment.disconnected' =>
        AgentSessionEnvironmentDisconnectedEvent.fromJson(json),
      'agent.session.environment.expired' =>
        AgentSessionEnvironmentExpiredEvent.fromJson(json),
      'agent.session.environment.failed' =>
        AgentSessionEnvironmentFailedEvent.fromJson(json),
      'agent.session.environment.pending' =>
        AgentSessionEnvironmentPendingEvent.fromJson(json),
      'agent.session.environment.ready' =>
        AgentSessionEnvironmentReadyEvent.fromJson(json),
      'agent.session.environment.reset' =>
        AgentSessionEnvironmentResetEvent.fromJson(json),
      'agent.session.environment.suspended' =>
        AgentSessionEnvironmentSuspendedEvent.fromJson(json),
      'agent.session.failed' => AgentSessionFailedEvent.fromJson(json),
      'agent.session.idle' => AgentSessionIdleEvent.fromJson(json),
      'agent.session.in_progress' => AgentSessionInProgressEvent.fromJson(json),
      'agent.session.requires_action' =>
        AgentSessionRequiresActionEvent.fromJson(json),
      'agent.session.subagent.active' =>
        AgentSessionSubagentActiveEvent.fromJson(json),
      'agent.session.subagent.closed' =>
        AgentSessionSubagentClosedEvent.fromJson(json),
      'agent.session.subagent.created' =>
        AgentSessionSubagentCreatedEvent.fromJson(json),
      'agent.session.turn.cancelled' => AgentSessionTurnCancelledEvent.fromJson(
        json,
      ),
      'agent.session.turn.completed' => AgentSessionTurnCompletedEvent.fromJson(
        json,
      ),
      'agent.session.turn.content_part.added' =>
        AgentSessionTurnContentPartAddedEvent.fromJson(json),
      'agent.session.turn.content_part.done' =>
        AgentSessionTurnContentPartDoneEvent.fromJson(json),
      'agent.session.turn.created' => AgentSessionTurnCreatedEvent.fromJson(
        json,
      ),
      'agent.session.turn.failed' => AgentSessionTurnFailedEvent.fromJson(json),
      'agent.session.turn.in_progress' =>
        AgentSessionTurnInProgressEvent.fromJson(json),
      'agent.session.turn.item.added' =>
        AgentSessionTurnItemAddedEvent.fromJson(json),
      'agent.session.turn.item.done' => AgentSessionTurnItemDoneEvent.fromJson(
        json,
      ),
      'agent.session.turn.output_text.delta' =>
        AgentSessionTurnOutputTextDeltaEvent.fromJson(json),
      'agent.session.turn.output_text.done' =>
        AgentSessionTurnOutputTextDoneEvent.fromJson(json),
      'agent.session.turn.reasoning_summary_part.added' =>
        AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(json),
      'agent.session.turn.reasoning_summary_part.done' =>
        AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(json),
      'agent.session.turn.reasoning_summary_text.delta' =>
        AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(json),
      'agent.session.turn.reasoning_summary_text.done' =>
        AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(json),
      'error' => AgentSessionErrorEvent.fromJson(json),
      _ => UnknownAgentSessionEvent.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `agent.output.command_execution_output.delta` contract.
  factory AgentSessionEvent.agentOutputCommandExecutionOutputDelta({
    required String delta,
    required String eventId,
    required String itemId,
    required int outputIndex,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionAgentOutputCommandExecutionOutputDeltaEvent;

  /// Builds the `agent.session.created` contract.
  factory AgentSessionEvent.created({
    required String eventId,
    required AgentSession session,
    Map<String, dynamic> rawJson,
  }) = AgentSessionCreatedEvent;

  /// Builds the `agent.session.environment.connected` contract.
  factory AgentSessionEvent.environmentConnected({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentConnectedEvent;

  /// Builds the `agent.session.environment.disconnected` contract.
  factory AgentSessionEvent.environmentDisconnected({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentDisconnectedEvent;

  /// Builds the `agent.session.environment.expired` contract.
  factory AgentSessionEvent.environmentExpired({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentExpiredEvent;

  /// Builds the `agent.session.environment.failed` contract.
  factory AgentSessionEvent.environmentFailed({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentFailedEvent;

  /// Builds the `agent.session.environment.pending` contract.
  factory AgentSessionEvent.environmentPending({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentPendingEvent;

  /// Builds the `agent.session.environment.ready` contract.
  factory AgentSessionEvent.environmentReady({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentReadyEvent;

  /// Builds the `agent.session.environment.reset` contract.
  factory AgentSessionEvent.environmentReset({
    required String environmentId,
    required String eventId,
    required int resetCount,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentResetEvent;

  /// Builds the `agent.session.environment.suspended` contract.
  factory AgentSessionEvent.environmentSuspended({
    required AgentSessionEnvironmentStateResource environment,
    required String eventId,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentSuspendedEvent;

  /// Builds the `agent.session.failed` contract.
  factory AgentSessionEvent.failed({
    required String eventId,
    required AgentSession session,
    Map<String, dynamic> rawJson,
  }) = AgentSessionFailedEvent;

  /// Builds the `agent.session.idle` contract.
  factory AgentSessionEvent.idle({
    required String eventId,
    required AgentSession session,
    Map<String, dynamic> rawJson,
  }) = AgentSessionIdleEvent;

  /// Builds the `agent.session.in_progress` contract.
  factory AgentSessionEvent.inProgress({
    required String eventId,
    required AgentSession session,
    Map<String, dynamic> rawJson,
  }) = AgentSessionInProgressEvent;

  /// Builds the `agent.session.requires_action` contract.
  factory AgentSessionEvent.requiresAction({
    required String eventId,
    required AgentSession session,
    Map<String, dynamic> rawJson,
  }) = AgentSessionRequiresActionEvent;

  /// Builds the `agent.session.subagent.active` contract.
  factory AgentSessionEvent.subagentActive({
    required String eventId,
    required AgentSessionSubagent subagent,
    Map<String, dynamic> rawJson,
  }) = AgentSessionSubagentActiveEvent;

  /// Builds the `agent.session.subagent.closed` contract.
  factory AgentSessionEvent.subagentClosed({
    required String eventId,
    required AgentSessionSubagent subagent,
    Map<String, dynamic> rawJson,
  }) = AgentSessionSubagentClosedEvent;

  /// Builds the `agent.session.subagent.created` contract.
  factory AgentSessionEvent.subagentCreated({
    required String eventId,
    required AgentSessionSubagent subagent,
    Map<String, dynamic> rawJson,
  }) = AgentSessionSubagentCreatedEvent;

  /// Builds the `agent.session.turn.cancelled` contract.
  factory AgentSessionEvent.turnCancelled({
    required String eventId,
    required String sessionId,
    required AgentSessionTurn turn,
    required String turnId,
    required AgentSessionTokenUsageResource? usage,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnCancelledEvent;

  /// Builds the `agent.session.turn.completed` contract.
  factory AgentSessionEvent.turnCompleted({
    required String eventId,
    required String sessionId,
    required AgentSessionTurn turn,
    required String turnId,
    required AgentSessionTokenUsageResource? usage,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnCompletedEvent;

  /// Builds the `agent.session.turn.content_part.added` contract.
  factory AgentSessionEvent.turnContentPartAdded({
    required int contentIndex,
    required String eventId,
    required String itemId,
    required int outputIndex,
    required AgentSessionOutputTextResource part,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnContentPartAddedEvent;

  /// Builds the `agent.session.turn.content_part.done` contract.
  factory AgentSessionEvent.turnContentPartDone({
    required int contentIndex,
    required String eventId,
    required String itemId,
    required int outputIndex,
    required AgentSessionOutputTextResource part,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnContentPartDoneEvent;

  /// Builds the `agent.session.turn.created` contract.
  factory AgentSessionEvent.turnCreated({
    required String eventId,
    required String sessionId,
    required AgentSessionTurn turn,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnCreatedEvent;

  /// Builds the `agent.session.turn.failed` contract.
  factory AgentSessionEvent.turnFailed({
    required String eventId,
    required String sessionId,
    required AgentSessionTurn turn,
    required String turnId,
    required AgentSessionTokenUsageResource? usage,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnFailedEvent;

  /// Builds the `agent.session.turn.in_progress` contract.
  factory AgentSessionEvent.turnInProgress({
    required String eventId,
    required String sessionId,
    required AgentSessionTurn turn,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnInProgressEvent;

  /// Builds the `agent.session.turn.item.added` contract.
  factory AgentSessionEvent.turnItemAdded({
    required String eventId,
    required AgentSessionTurnItem item,
    required int? outputIndex,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnItemAddedEvent;

  /// Builds the `agent.session.turn.item.done` contract.
  factory AgentSessionEvent.turnItemDone({
    required String eventId,
    required AgentSessionOutputItem item,
    required int outputIndex,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnItemDoneEvent;

  /// Builds the `agent.session.turn.output_text.delta` contract.
  factory AgentSessionEvent.turnOutputTextDelta({
    required int contentIndex,
    required String delta,
    required String eventId,
    required String itemId,
    required int outputIndex,
    required String sessionId,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnOutputTextDeltaEvent;

  /// Builds the `agent.session.turn.output_text.done` contract.
  factory AgentSessionEvent.turnOutputTextDone({
    required int contentIndex,
    required String eventId,
    required String itemId,
    required int outputIndex,
    required String sessionId,
    required String text,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnOutputTextDoneEvent;

  /// Builds the `agent.session.turn.reasoning_summary_part.added` contract.
  factory AgentSessionEvent.turnReasoningSummaryPartAdded({
    required String eventId,
    required String itemId,
    required int outputIndex,
    required AgentSessionSummaryTextResource part,
    required String sessionId,
    required int summaryIndex,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnReasoningSummaryPartAddedEvent;

  /// Builds the `agent.session.turn.reasoning_summary_part.done` contract.
  factory AgentSessionEvent.turnReasoningSummaryPartDone({
    required String eventId,
    required String itemId,
    required int outputIndex,
    required AgentSessionSummaryTextResource part,
    required String sessionId,
    required String? status,
    required int summaryIndex,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnReasoningSummaryPartDoneEvent;

  /// Builds the `agent.session.turn.reasoning_summary_text.delta` contract.
  factory AgentSessionEvent.turnReasoningSummaryTextDelta({
    required String delta,
    required String eventId,
    required String itemId,
    required int outputIndex,
    required String sessionId,
    required int summaryIndex,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnReasoningSummaryTextDeltaEvent;

  /// Builds the `agent.session.turn.reasoning_summary_text.done` contract.
  factory AgentSessionEvent.turnReasoningSummaryTextDone({
    required String eventId,
    required String itemId,
    required int outputIndex,
    required String sessionId,
    required int summaryIndex,
    required String text,
    required String? turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionTurnReasoningSummaryTextDoneEvent;

  /// Builds the `error` contract.
  factory AgentSessionEvent.error({
    required AgentSessionErrorResource error,
    required String eventId,
    required String sessionId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionErrorEvent;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionEvent extends AgentSessionEvent {
  const UnknownAgentSessionEvent._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionEvent.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionEvent.type',
    );
    if (const [
      'agent.output.command_execution_output.delta',
      'agent.session.created',
      'agent.session.environment.connected',
      'agent.session.environment.disconnected',
      'agent.session.environment.expired',
      'agent.session.environment.failed',
      'agent.session.environment.pending',
      'agent.session.environment.ready',
      'agent.session.environment.reset',
      'agent.session.environment.suspended',
      'agent.session.failed',
      'agent.session.idle',
      'agent.session.in_progress',
      'agent.session.requires_action',
      'agent.session.subagent.active',
      'agent.session.subagent.closed',
      'agent.session.subagent.created',
      'agent.session.turn.cancelled',
      'agent.session.turn.completed',
      'agent.session.turn.content_part.added',
      'agent.session.turn.content_part.done',
      'agent.session.turn.created',
      'agent.session.turn.failed',
      'agent.session.turn.in_progress',
      'agent.session.turn.item.added',
      'agent.session.turn.item.done',
      'agent.session.turn.output_text.delta',
      'agent.session.turn.output_text.done',
      'agent.session.turn.reasoning_summary_part.added',
      'agent.session.turn.reasoning_summary_part.done',
      'agent.session.turn.reasoning_summary_text.delta',
      'agent.session.turn.reasoning_summary_text.done',
      'error',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionEvent: expected a future discriminator',
      );
    }
    return UnknownAgentSessionEvent._(
      snapshotAgentJson(json, 'UnknownAgentSessionEvent'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionEvent copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionEvent.fromJson(rawJson ?? this.rawJson);
}

/// Emitted when command execution produces an output delta.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionAgentOutputCommandExecutionOutputDeltaEvent
    extends AgentSessionEvent {
  /// Creates a validated [AgentSessionAgentOutputCommandExecutionOutputDeltaEvent].
  AgentSessionAgentOutputCommandExecutionOutputDeltaEvent({
    required this.delta,
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'delta',
         'event_id',
         'item_id',
         'output_index',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent') {
    validate();
  }

  /// The output text that was appended.
  final String delta;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the command execution item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.output.command_execution_output.delta`.
  @override
  String get type => 'agent.output.command_execution_output.delta';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionAgentOutputCommandExecutionOutputDeltaEvent] with contextual, payload-free errors.
  factory AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.output.command_execution_output.delta',
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent',
    );
    return AgentSessionAgentOutputCommandExecutionOutputDeltaEvent(
      delta: requiredAgentValue(
        json,
        'delta',
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.delta',
        requireAgentString,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'delta',
            'event_id',
            'item_id',
            'output_index',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      delta,
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.delta',
      min: 0,
    );
    validateAgentLength(
      eventId,
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'delta': delta,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionAgentOutputCommandExecutionOutputDeltaEvent copyWith({
    String? delta,
    String? eventId,
    String? itemId,
    int? outputIndex,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionAgentOutputCommandExecutionOutputDeltaEvent(
    delta: delta ?? this.delta,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session is created.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionCreatedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionCreatedEvent].
  AgentSessionCreatedEvent({
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session',
         'type',
       ], 'AgentSessionCreatedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The session that was created.
  final AgentSession session;

  /// The type of the object. Always `agent.session.created`.
  @override
  String get type => 'agent.session.created';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionCreatedEvent] with contextual, payload-free errors.
  factory AgentSessionCreatedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.created',
      'AgentSessionCreatedEvent',
    );
    return AgentSessionCreatedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionCreatedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      session: requiredAgentValue(
        json,
        'session',
        'AgentSessionCreatedEvent.session',
        (value, context) =>
            AgentSession.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'session', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(eventId, 'AgentSessionCreatedEvent.eventId', min: 0);
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session': session.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionCreatedEvent copyWith({
    String? eventId,
    AgentSession? session,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionCreatedEvent(
    eventId: eventId ?? this.eventId,
    session: session ?? this.session,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session environment connects.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentConnectedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentConnectedEvent].
  AgentSessionEnvironmentConnectedEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentConnectedEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.connected`.
  @override
  String get type => 'agent.session.environment.connected';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentConnectedEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentConnectedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.connected',
      'AgentSessionEnvironmentConnectedEvent',
    );
    return AgentSessionEnvironmentConnectedEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentConnectedEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentConnectedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentConnectedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentConnectedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentConnectedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentConnectedEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentConnectedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentConnectedEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentConnectedEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentConnectedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session environment disconnects.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentDisconnectedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentDisconnectedEvent].
  AgentSessionEnvironmentDisconnectedEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentDisconnectedEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.disconnected`.
  @override
  String get type => 'agent.session.environment.disconnected';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentDisconnectedEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentDisconnectedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.disconnected',
      'AgentSessionEnvironmentDisconnectedEvent',
    );
    return AgentSessionEnvironmentDisconnectedEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentDisconnectedEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentDisconnectedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentDisconnectedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentDisconnectedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentDisconnectedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentDisconnectedEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentDisconnectedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentDisconnectedEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentDisconnectedEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentDisconnectedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted after a suspended hosted session environment and its checkpoint expire.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentExpiredEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentExpiredEvent].
  AgentSessionEnvironmentExpiredEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentExpiredEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.expired`.
  @override
  String get type => 'agent.session.environment.expired';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentExpiredEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentExpiredEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.expired',
      'AgentSessionEnvironmentExpiredEvent',
    );
    return AgentSessionEnvironmentExpiredEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentExpiredEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentExpiredEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentExpiredEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentExpiredEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentExpiredEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentExpiredEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentExpiredEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentExpiredEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentExpiredEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentExpiredEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session environment fails.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentFailedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentFailedEvent].
  AgentSessionEnvironmentFailedEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentFailedEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.failed`.
  @override
  String get type => 'agent.session.environment.failed';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentFailedEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentFailedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.failed',
      'AgentSessionEnvironmentFailedEvent',
    );
    return AgentSessionEnvironmentFailedEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentFailedEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentFailedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentFailedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentFailedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentFailedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentFailedEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentFailedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentFailedEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentFailedEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentFailedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted while a session environment is being prepared.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentPendingEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentPendingEvent].
  AgentSessionEnvironmentPendingEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentPendingEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.pending`.
  @override
  String get type => 'agent.session.environment.pending';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentPendingEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentPendingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.pending',
      'AgentSessionEnvironmentPendingEvent',
    );
    return AgentSessionEnvironmentPendingEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentPendingEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentPendingEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentPendingEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentPendingEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentPendingEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentPendingEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentPendingEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentPendingEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentPendingEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentPendingEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a hosted session environment is ready to connect.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentReadyEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentReadyEvent].
  AgentSessionEnvironmentReadyEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentReadyEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.ready`.
  @override
  String get type => 'agent.session.environment.ready';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentReadyEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentReadyEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.ready',
      'AgentSessionEnvironmentReadyEvent',
    );
    return AgentSessionEnvironmentReadyEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentReadyEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentReadyEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentReadyEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentReadyEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentReadyEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentReadyEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentReadyEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentReadyEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentReadyEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentReadyEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted after a hosted sandbox is replaced. Conversation history survives; changes to the previous sandbox's files and processes do not.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentResetEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentResetEvent].
  AgentSessionEnvironmentResetEvent({
    required this.environmentId,
    required this.eventId,
    required this.resetCount,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment_id',
         'event_id',
         'reset_count',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentResetEvent') {
    validate();
  }

  /// The stable environment ID, retained across sandbox replacements.
  final String environmentId;

  /// The unique ID of the event.
  final String eventId;

  /// Monotonically increasing reset number. Repeated notifications share this number.
  final int resetCount;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The associated turn, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.reset`.
  @override
  String get type => 'agent.session.environment.reset';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentResetEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentResetEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.reset',
      'AgentSessionEnvironmentResetEvent',
    );
    return AgentSessionEnvironmentResetEvent(
      environmentId: requiredAgentValue(
        json,
        'environment_id',
        'AgentSessionEnvironmentResetEvent.environmentId',
        requireAgentString,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentResetEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      resetCount: requiredAgentValue(
        json,
        'reset_count',
        'AgentSessionEnvironmentResetEvent.resetCount',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentResetEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentResetEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment_id',
            'event_id',
            'reset_count',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      environmentId,
      'AgentSessionEnvironmentResetEvent.environmentId',
      min: 0,
    );
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentResetEvent.eventId',
      min: 0,
    );
    validateAgentInt(
      resetCount,
      'AgentSessionEnvironmentResetEvent.resetCount',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentResetEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentResetEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment_id': environmentId,
    'event_id': eventId,
    'reset_count': resetCount,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentResetEvent copyWith({
    String? environmentId,
    String? eventId,
    int? resetCount,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentResetEvent(
    environmentId: environmentId ?? this.environmentId,
    eventId: eventId ?? this.eventId,
    resetCount: resetCount ?? this.resetCount,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentResetEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted after an idle hosted session environment is checkpointed and stopped.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentSuspendedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionEnvironmentSuspendedEvent].
  AgentSessionEnvironmentSuspendedEvent({
    required this.environment,
    required this.eventId,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment',
         'event_id',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionEnvironmentSuspendedEvent') {
    validate();
  }

  /// The current environment state.
  final AgentSessionEnvironmentStateResource environment;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.environment.suspended`.
  @override
  String get type => 'agent.session.environment.suspended';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentSuspendedEvent] with contextual, payload-free errors.
  factory AgentSessionEnvironmentSuspendedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.environment.suspended',
      'AgentSessionEnvironmentSuspendedEvent',
    );
    return AgentSessionEnvironmentSuspendedEvent(
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSessionEnvironmentSuspendedEvent.environment',
        (value, context) => AgentSessionEnvironmentStateResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionEnvironmentSuspendedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionEnvironmentSuspendedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionEnvironmentSuspendedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment',
            'event_id',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    environment.validate();
    validateAgentLength(
      eventId,
      'AgentSessionEnvironmentSuspendedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionEnvironmentSuspendedEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionEnvironmentSuspendedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment': environment.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentSuspendedEvent copyWith({
    AgentSessionEnvironmentStateResource? environment,
    String? eventId,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentSuspendedEvent(
    environment: environment ?? this.environment,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionEnvironmentSuspendedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session fails.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionFailedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionFailedEvent].
  AgentSessionFailedEvent({
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session',
         'type',
       ], 'AgentSessionFailedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The failed session.
  final AgentSession session;

  /// The type of the object. Always `agent.session.failed`.
  @override
  String get type => 'agent.session.failed';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionFailedEvent] with contextual, payload-free errors.
  factory AgentSessionFailedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.failed',
      'AgentSessionFailedEvent',
    );
    return AgentSessionFailedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionFailedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      session: requiredAgentValue(
        json,
        'session',
        'AgentSessionFailedEvent.session',
        (value, context) =>
            AgentSession.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'session', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(eventId, 'AgentSessionFailedEvent.eventId', min: 0);
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session': session.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionFailedEvent copyWith({
    String? eventId,
    AgentSession? session,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionFailedEvent(
    eventId: eventId ?? this.eventId,
    session: session ?? this.session,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session becomes idle.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionIdleEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionIdleEvent].
  AgentSessionIdleEvent({
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session',
         'type',
       ], 'AgentSessionIdleEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The session that became idle.
  final AgentSession session;

  /// The type of the object. Always `agent.session.idle`.
  @override
  String get type => 'agent.session.idle';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionIdleEvent] with contextual, payload-free errors.
  factory AgentSessionIdleEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.idle',
      'AgentSessionIdleEvent',
    );
    return AgentSessionIdleEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionIdleEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      session: requiredAgentValue(
        json,
        'session',
        'AgentSessionIdleEvent.session',
        (value, context) =>
            AgentSession.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'session', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(eventId, 'AgentSessionIdleEvent.eventId', min: 0);
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session': session.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionIdleEvent copyWith({
    String? eventId,
    AgentSession? session,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionIdleEvent(
    eventId: eventId ?? this.eventId,
    session: session ?? this.session,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session starts processing a turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionInProgressEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionInProgressEvent].
  AgentSessionInProgressEvent({
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session',
         'type',
       ], 'AgentSessionInProgressEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The session that started processing.
  final AgentSession session;

  /// The type of the object. Always `agent.session.in_progress`.
  @override
  String get type => 'agent.session.in_progress';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionInProgressEvent] with contextual, payload-free errors.
  factory AgentSessionInProgressEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.in_progress',
      'AgentSessionInProgressEvent',
    );
    return AgentSessionInProgressEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionInProgressEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      session: requiredAgentValue(
        json,
        'session',
        'AgentSessionInProgressEvent.session',
        (value, context) =>
            AgentSession.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'session', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(eventId, 'AgentSessionInProgressEvent.eventId', min: 0);
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session': session.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInProgressEvent copyWith({
    String? eventId,
    AgentSession? session,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionInProgressEvent(
    eventId: eventId ?? this.eventId,
    session: session ?? this.session,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a session is waiting for one or more required actions.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionRequiresActionEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionRequiresActionEvent].
  AgentSessionRequiresActionEvent({
    required this.eventId,
    required this.session,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session',
         'type',
       ], 'AgentSessionRequiresActionEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The session and its current required actions.
  final AgentSession session;

  /// The type of the object. Always `agent.session.requires_action`.
  @override
  String get type => 'agent.session.requires_action';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionRequiresActionEvent] with contextual, payload-free errors.
  factory AgentSessionRequiresActionEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.requires_action',
      'AgentSessionRequiresActionEvent',
    );
    return AgentSessionRequiresActionEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionRequiresActionEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      session: requiredAgentValue(
        json,
        'session',
        'AgentSessionRequiresActionEvent.session',
        (value, context) =>
            AgentSession.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'session', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionRequiresActionEvent.eventId',
      min: 0,
    );
    session.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session': session.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionRequiresActionEvent copyWith({
    String? eventId,
    AgentSession? session,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionRequiresActionEvent(
    eventId: eventId ?? this.eventId,
    session: session ?? this.session,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a closed subagent successfully resumes.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSubagentActiveEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionSubagentActiveEvent].
  AgentSessionSubagentActiveEvent({
    required this.eventId,
    required this.subagent,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'subagent',
         'type',
       ], 'AgentSessionSubagentActiveEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The subagent that resumed.
  final AgentSessionSubagent subagent;

  /// The type of the object. Always `agent.session.subagent.active`.
  @override
  String get type => 'agent.session.subagent.active';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSubagentActiveEvent] with contextual, payload-free errors.
  factory AgentSessionSubagentActiveEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.subagent.active',
      'AgentSessionSubagentActiveEvent',
    );
    return AgentSessionSubagentActiveEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionSubagentActiveEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      subagent: requiredAgentValue(
        json,
        'subagent',
        'AgentSessionSubagentActiveEvent.subagent',
        (value, context) =>
            AgentSessionSubagent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'subagent', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionSubagentActiveEvent.eventId',
      min: 0,
    );
    subagent.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'subagent': subagent.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSubagentActiveEvent copyWith({
    String? eventId,
    AgentSessionSubagent? subagent,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSubagentActiveEvent(
    eventId: eventId ?? this.eventId,
    subagent: subagent ?? this.subagent,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a subagent is closed.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSubagentClosedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionSubagentClosedEvent].
  AgentSessionSubagentClosedEvent({
    required this.eventId,
    required this.subagent,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'subagent',
         'type',
       ], 'AgentSessionSubagentClosedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The subagent that was closed.
  final AgentSessionSubagent subagent;

  /// The type of the object. Always `agent.session.subagent.closed`.
  @override
  String get type => 'agent.session.subagent.closed';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSubagentClosedEvent] with contextual, payload-free errors.
  factory AgentSessionSubagentClosedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.subagent.closed',
      'AgentSessionSubagentClosedEvent',
    );
    return AgentSessionSubagentClosedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionSubagentClosedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      subagent: requiredAgentValue(
        json,
        'subagent',
        'AgentSessionSubagentClosedEvent.subagent',
        (value, context) =>
            AgentSessionSubagent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'subagent', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionSubagentClosedEvent.eventId',
      min: 0,
    );
    subagent.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'subagent': subagent.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSubagentClosedEvent copyWith({
    String? eventId,
    AgentSessionSubagent? subagent,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSubagentClosedEvent(
    eventId: eventId ?? this.eventId,
    subagent: subagent ?? this.subagent,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a subagent is created.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSubagentCreatedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionSubagentCreatedEvent].
  AgentSessionSubagentCreatedEvent({
    required this.eventId,
    required this.subagent,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'subagent',
         'type',
       ], 'AgentSessionSubagentCreatedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The subagent that was created.
  final AgentSessionSubagent subagent;

  /// The type of the object. Always `agent.session.subagent.created`.
  @override
  String get type => 'agent.session.subagent.created';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSubagentCreatedEvent] with contextual, payload-free errors.
  factory AgentSessionSubagentCreatedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.subagent.created',
      'AgentSessionSubagentCreatedEvent',
    );
    return AgentSessionSubagentCreatedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionSubagentCreatedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      subagent: requiredAgentValue(
        json,
        'subagent',
        'AgentSessionSubagentCreatedEvent.subagent',
        (value, context) =>
            AgentSessionSubagent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['event_id', 'subagent', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionSubagentCreatedEvent.eventId',
      min: 0,
    );
    subagent.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'subagent': subagent.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSubagentCreatedEvent copyWith({
    String? eventId,
    AgentSessionSubagent? subagent,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSubagentCreatedEvent(
    eventId: eventId ?? this.eventId,
    subagent: subagent ?? this.subagent,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a turn is cancelled.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnCancelledEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnCancelledEvent].
  AgentSessionTurnCancelledEvent({
    required this.eventId,
    required this.sessionId,
    required this.turn,
    required this.turnId,
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session_id',
         'turn',
         'turn_id',
         'type',
         'usage',
       ], 'AgentSessionTurnCancelledEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The cancelled turn.
  final AgentSessionTurn turn;

  /// The ID of the turn associated with the event.
  final String turnId;

  /// The type of the object. Always `agent.session.turn.cancelled`.
  @override
  String get type => 'agent.session.turn.cancelled';

  /// Token usage by the root agent during the turn, when available.
  final AgentSessionTokenUsageResource? usage;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnCancelledEvent] with contextual, payload-free errors.
  factory AgentSessionTurnCancelledEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.cancelled',
      'AgentSessionTurnCancelledEvent',
    );
    return AgentSessionTurnCancelledEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnCancelledEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnCancelledEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turn: requiredAgentValue(
        json,
        'turn',
        'AgentSessionTurnCancelledEvent.turn',
        (value, context) =>
            AgentSessionTurn.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnCancelledEvent.turnId',
        requireAgentString,
        nullable: false,
      )!,
      usage: requiredAgentValue(
        json,
        'usage',
        'AgentSessionTurnCancelledEvent.usage',
        (value, context) => AgentSessionTokenUsageResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'session_id',
            'turn',
            'turn_id',
            'type',
            'usage',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnCancelledEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnCancelledEvent.sessionId',
      min: 0,
    );
    turn.validate();
    validateAgentLength(
      turnId,
      'AgentSessionTurnCancelledEvent.turnId',
      min: 0,
    );
    if (usage != null) {
      usage!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session_id': sessionId,
    'turn': turn.toJson(),
    'turn_id': turnId,
    'type': type,
    'usage': usage?.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnCancelledEvent copyWith({
    String? eventId,
    String? sessionId,
    AgentSessionTurn? turn,
    String? turnId,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnCancelledEvent(
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turn: turn ?? this.turn,
    turnId: turnId ?? this.turnId,
    usage: copyAgentValue<AgentSessionTokenUsageResource>(
      usage,
      this.usage,
      'AgentSessionTurnCancelledEvent.usage',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a turn completes.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnCompletedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnCompletedEvent].
  AgentSessionTurnCompletedEvent({
    required this.eventId,
    required this.sessionId,
    required this.turn,
    required this.turnId,
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session_id',
         'turn',
         'turn_id',
         'type',
         'usage',
       ], 'AgentSessionTurnCompletedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The completed turn.
  final AgentSessionTurn turn;

  /// The ID of the turn associated with the event.
  final String turnId;

  /// The type of the object. Always `agent.session.turn.completed`.
  @override
  String get type => 'agent.session.turn.completed';

  /// Token usage by the root agent during the turn, when available.
  final AgentSessionTokenUsageResource? usage;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnCompletedEvent] with contextual, payload-free errors.
  factory AgentSessionTurnCompletedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.completed',
      'AgentSessionTurnCompletedEvent',
    );
    return AgentSessionTurnCompletedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnCompletedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnCompletedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turn: requiredAgentValue(
        json,
        'turn',
        'AgentSessionTurnCompletedEvent.turn',
        (value, context) =>
            AgentSessionTurn.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnCompletedEvent.turnId',
        requireAgentString,
        nullable: false,
      )!,
      usage: requiredAgentValue(
        json,
        'usage',
        'AgentSessionTurnCompletedEvent.usage',
        (value, context) => AgentSessionTokenUsageResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'session_id',
            'turn',
            'turn_id',
            'type',
            'usage',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnCompletedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnCompletedEvent.sessionId',
      min: 0,
    );
    turn.validate();
    validateAgentLength(
      turnId,
      'AgentSessionTurnCompletedEvent.turnId',
      min: 0,
    );
    if (usage != null) {
      usage!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session_id': sessionId,
    'turn': turn.toJson(),
    'turn_id': turnId,
    'type': type,
    'usage': usage?.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnCompletedEvent copyWith({
    String? eventId,
    String? sessionId,
    AgentSessionTurn? turn,
    String? turnId,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnCompletedEvent(
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turn: turn ?? this.turn,
    turnId: turnId ?? this.turnId,
    usage: copyAgentValue<AgentSessionTokenUsageResource>(
      usage,
      this.usage,
      'AgentSessionTurnCompletedEvent.usage',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when an output text content part is added.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnContentPartAddedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnContentPartAddedEvent].
  AgentSessionTurnContentPartAddedEvent({
    required this.contentIndex,
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.part,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'content_index',
         'event_id',
         'item_id',
         'output_index',
         'part',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionTurnContentPartAddedEvent') {
    validate();
  }

  /// The index of the content part in the message.
  final int contentIndex;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the message item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The initial content part.
  final AgentSessionOutputTextResource part;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.content_part.added`.
  @override
  String get type => 'agent.session.turn.content_part.added';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnContentPartAddedEvent] with contextual, payload-free errors.
  factory AgentSessionTurnContentPartAddedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.content_part.added',
      'AgentSessionTurnContentPartAddedEvent',
    );
    return AgentSessionTurnContentPartAddedEvent(
      contentIndex: requiredAgentValue(
        json,
        'content_index',
        'AgentSessionTurnContentPartAddedEvent.contentIndex',
        requireAgentInt,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnContentPartAddedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnContentPartAddedEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnContentPartAddedEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      part: requiredAgentValue(
        json,
        'part',
        'AgentSessionTurnContentPartAddedEvent.part',
        (value, context) => AgentSessionOutputTextResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnContentPartAddedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnContentPartAddedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content_index',
            'event_id',
            'item_id',
            'output_index',
            'part',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(
      contentIndex,
      'AgentSessionTurnContentPartAddedEvent.contentIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      eventId,
      'AgentSessionTurnContentPartAddedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnContentPartAddedEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnContentPartAddedEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    part.validate();
    validateAgentLength(
      sessionId,
      'AgentSessionTurnContentPartAddedEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnContentPartAddedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content_index': contentIndex,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'part': part.toJson(),
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnContentPartAddedEvent copyWith({
    int? contentIndex,
    String? eventId,
    String? itemId,
    int? outputIndex,
    AgentSessionOutputTextResource? part,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnContentPartAddedEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    part: part ?? this.part,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnContentPartAddedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when an output content part is complete.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnContentPartDoneEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnContentPartDoneEvent].
  AgentSessionTurnContentPartDoneEvent({
    required this.contentIndex,
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.part,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'content_index',
         'event_id',
         'item_id',
         'output_index',
         'part',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionTurnContentPartDoneEvent') {
    validate();
  }

  /// The index of the content part in the message.
  final int contentIndex;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the message item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The completed content part.
  final AgentSessionOutputTextResource part;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.content_part.done`.
  @override
  String get type => 'agent.session.turn.content_part.done';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnContentPartDoneEvent] with contextual, payload-free errors.
  factory AgentSessionTurnContentPartDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.content_part.done',
      'AgentSessionTurnContentPartDoneEvent',
    );
    return AgentSessionTurnContentPartDoneEvent(
      contentIndex: requiredAgentValue(
        json,
        'content_index',
        'AgentSessionTurnContentPartDoneEvent.contentIndex',
        requireAgentInt,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnContentPartDoneEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnContentPartDoneEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnContentPartDoneEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      part: requiredAgentValue(
        json,
        'part',
        'AgentSessionTurnContentPartDoneEvent.part',
        (value, context) => AgentSessionOutputTextResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnContentPartDoneEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnContentPartDoneEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content_index',
            'event_id',
            'item_id',
            'output_index',
            'part',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(
      contentIndex,
      'AgentSessionTurnContentPartDoneEvent.contentIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      eventId,
      'AgentSessionTurnContentPartDoneEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnContentPartDoneEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnContentPartDoneEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    part.validate();
    validateAgentLength(
      sessionId,
      'AgentSessionTurnContentPartDoneEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnContentPartDoneEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content_index': contentIndex,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'part': part.toJson(),
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnContentPartDoneEvent copyWith({
    int? contentIndex,
    String? eventId,
    String? itemId,
    int? outputIndex,
    AgentSessionOutputTextResource? part,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnContentPartDoneEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    part: part ?? this.part,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnContentPartDoneEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a turn is created.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnCreatedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnCreatedEvent].
  AgentSessionTurnCreatedEvent({
    required this.eventId,
    required this.sessionId,
    required this.turn,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session_id',
         'turn',
         'turn_id',
         'type',
       ], 'AgentSessionTurnCreatedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The turn at the time it was created.
  final AgentSessionTurn turn;

  /// The ID of the turn associated with the event.
  final String turnId;

  /// The type of the object. Always `agent.session.turn.created`.
  @override
  String get type => 'agent.session.turn.created';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnCreatedEvent] with contextual, payload-free errors.
  factory AgentSessionTurnCreatedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.created',
      'AgentSessionTurnCreatedEvent',
    );
    return AgentSessionTurnCreatedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnCreatedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnCreatedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turn: requiredAgentValue(
        json,
        'turn',
        'AgentSessionTurnCreatedEvent.turn',
        (value, context) =>
            AgentSessionTurn.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnCreatedEvent.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'session_id',
            'turn',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnCreatedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnCreatedEvent.sessionId',
      min: 0,
    );
    turn.validate();
    validateAgentLength(turnId, 'AgentSessionTurnCreatedEvent.turnId', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session_id': sessionId,
    'turn': turn.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnCreatedEvent copyWith({
    String? eventId,
    String? sessionId,
    AgentSessionTurn? turn,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnCreatedEvent(
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turn: turn ?? this.turn,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a turn fails.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnFailedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnFailedEvent].
  AgentSessionTurnFailedEvent({
    required this.eventId,
    required this.sessionId,
    required this.turn,
    required this.turnId,
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session_id',
         'turn',
         'turn_id',
         'type',
         'usage',
       ], 'AgentSessionTurnFailedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The failed turn.
  final AgentSessionTurn turn;

  /// The ID of the turn associated with the event.
  final String turnId;

  /// The type of the object. Always `agent.session.turn.failed`.
  @override
  String get type => 'agent.session.turn.failed';

  /// Token usage by the root agent during the turn, when available.
  final AgentSessionTokenUsageResource? usage;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnFailedEvent] with contextual, payload-free errors.
  factory AgentSessionTurnFailedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.failed',
      'AgentSessionTurnFailedEvent',
    );
    return AgentSessionTurnFailedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnFailedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnFailedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turn: requiredAgentValue(
        json,
        'turn',
        'AgentSessionTurnFailedEvent.turn',
        (value, context) =>
            AgentSessionTurn.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnFailedEvent.turnId',
        requireAgentString,
        nullable: false,
      )!,
      usage: requiredAgentValue(
        json,
        'usage',
        'AgentSessionTurnFailedEvent.usage',
        (value, context) => AgentSessionTokenUsageResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'session_id',
            'turn',
            'turn_id',
            'type',
            'usage',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(eventId, 'AgentSessionTurnFailedEvent.eventId', min: 0);
    validateAgentLength(
      sessionId,
      'AgentSessionTurnFailedEvent.sessionId',
      min: 0,
    );
    turn.validate();
    validateAgentLength(turnId, 'AgentSessionTurnFailedEvent.turnId', min: 0);
    if (usage != null) {
      usage!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session_id': sessionId,
    'turn': turn.toJson(),
    'turn_id': turnId,
    'type': type,
    'usage': usage?.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnFailedEvent copyWith({
    String? eventId,
    String? sessionId,
    AgentSessionTurn? turn,
    String? turnId,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnFailedEvent(
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turn: turn ?? this.turn,
    turnId: turnId ?? this.turnId,
    usage: copyAgentValue<AgentSessionTokenUsageResource>(
      usage,
      this.usage,
      'AgentSessionTurnFailedEvent.usage',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a turn starts running.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnInProgressEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnInProgressEvent].
  AgentSessionTurnInProgressEvent({
    required this.eventId,
    required this.sessionId,
    required this.turn,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'session_id',
         'turn',
         'turn_id',
         'type',
       ], 'AgentSessionTurnInProgressEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The turn at the time it started running.
  final AgentSessionTurn turn;

  /// The ID of the turn associated with the event.
  final String turnId;

  /// The type of the object. Always `agent.session.turn.in_progress`.
  @override
  String get type => 'agent.session.turn.in_progress';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnInProgressEvent] with contextual, payload-free errors.
  factory AgentSessionTurnInProgressEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.in_progress',
      'AgentSessionTurnInProgressEvent',
    );
    return AgentSessionTurnInProgressEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnInProgressEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnInProgressEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turn: requiredAgentValue(
        json,
        'turn',
        'AgentSessionTurnInProgressEvent.turn',
        (value, context) =>
            AgentSessionTurn.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnInProgressEvent.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'session_id',
            'turn',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnInProgressEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnInProgressEvent.sessionId',
      min: 0,
    );
    turn.validate();
    validateAgentLength(
      turnId,
      'AgentSessionTurnInProgressEvent.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'session_id': sessionId,
    'turn': turn.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnInProgressEvent copyWith({
    String? eventId,
    String? sessionId,
    AgentSessionTurn? turn,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnInProgressEvent(
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    turn: turn ?? this.turn,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when an item is added to a turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnItemAddedEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnItemAddedEvent].
  AgentSessionTurnItemAddedEvent({
    required this.eventId,
    required this.item,
    required this.outputIndex,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'item',
         'output_index',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionTurnItemAddedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The item that was added.
  final AgentSessionTurnItem item;

  /// The index of the item in the turn output, when the item is agent output.
  final int? outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.item.added`.
  @override
  String get type => 'agent.session.turn.item.added';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnItemAddedEvent] with contextual, payload-free errors.
  factory AgentSessionTurnItemAddedEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.item.added',
      'AgentSessionTurnItemAddedEvent',
    );
    return AgentSessionTurnItemAddedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnItemAddedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      item: requiredAgentValue(
        json,
        'item',
        'AgentSessionTurnItemAddedEvent.item',
        (value, context) =>
            AgentSessionTurnItem.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnItemAddedEvent.outputIndex',
        requireAgentInt,
        nullable: true,
      ),
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnItemAddedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnItemAddedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'item',
            'output_index',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnItemAddedEvent.eventId',
      min: 0,
    );
    item.validate();
    if (outputIndex != null) {
      validateAgentInt(
        outputIndex!,
        'AgentSessionTurnItemAddedEvent.outputIndex',
        min: 0,
        max: 4294967295,
      );
    }
    validateAgentLength(
      sessionId,
      'AgentSessionTurnItemAddedEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnItemAddedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'item': item.toJson(),
    'output_index': outputIndex,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnItemAddedEvent copyWith({
    String? eventId,
    AgentSessionTurnItem? item,
    Object? outputIndex = unsetCopyWithValue,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnItemAddedEvent(
    eventId: eventId ?? this.eventId,
    item: item ?? this.item,
    outputIndex: copyAgentValue<int>(
      outputIndex,
      this.outputIndex,
      'AgentSessionTurnItemAddedEvent.outputIndex',
    ),
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnItemAddedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when an output item is complete.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnItemDoneEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnItemDoneEvent].
  AgentSessionTurnItemDoneEvent({
    required this.eventId,
    required this.item,
    required this.outputIndex,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'item',
         'output_index',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionTurnItemDoneEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The completed output item.
  final AgentSessionOutputItem item;

  /// The index of the output item in the turn output.
  final int outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.item.done`.
  @override
  String get type => 'agent.session.turn.item.done';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnItemDoneEvent] with contextual, payload-free errors.
  factory AgentSessionTurnItemDoneEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.item.done',
      'AgentSessionTurnItemDoneEvent',
    );
    return AgentSessionTurnItemDoneEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnItemDoneEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      item: requiredAgentValue(
        json,
        'item',
        'AgentSessionTurnItemDoneEvent.item',
        (value, context) =>
            AgentSessionOutputItem.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnItemDoneEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnItemDoneEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnItemDoneEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'item',
            'output_index',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnItemDoneEvent.eventId',
      min: 0,
    );
    item.validate();
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnItemDoneEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnItemDoneEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnItemDoneEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'item': item.toJson(),
    'output_index': outputIndex,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnItemDoneEvent copyWith({
    String? eventId,
    AgentSessionOutputItem? item,
    int? outputIndex,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnItemDoneEvent(
    eventId: eventId ?? this.eventId,
    item: item ?? this.item,
    outputIndex: outputIndex ?? this.outputIndex,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnItemDoneEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when text is appended to an output text content part.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnOutputTextDeltaEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnOutputTextDeltaEvent].
  AgentSessionTurnOutputTextDeltaEvent({
    required this.contentIndex,
    required this.delta,
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.sessionId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'content_index',
         'delta',
         'event_id',
         'item_id',
         'output_index',
         'session_id',
         'turn_id',
         'type',
       ], 'AgentSessionTurnOutputTextDeltaEvent') {
    validate();
  }

  /// The index of the content part in the message.
  final int contentIndex;

  /// The text that was appended.
  final String delta;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the message item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.output_text.delta`.
  @override
  String get type => 'agent.session.turn.output_text.delta';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnOutputTextDeltaEvent] with contextual, payload-free errors.
  factory AgentSessionTurnOutputTextDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.output_text.delta',
      'AgentSessionTurnOutputTextDeltaEvent',
    );
    return AgentSessionTurnOutputTextDeltaEvent(
      contentIndex: requiredAgentValue(
        json,
        'content_index',
        'AgentSessionTurnOutputTextDeltaEvent.contentIndex',
        requireAgentInt,
        nullable: false,
      )!,
      delta: requiredAgentValue(
        json,
        'delta',
        'AgentSessionTurnOutputTextDeltaEvent.delta',
        requireAgentString,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnOutputTextDeltaEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnOutputTextDeltaEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnOutputTextDeltaEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnOutputTextDeltaEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnOutputTextDeltaEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content_index',
            'delta',
            'event_id',
            'item_id',
            'output_index',
            'session_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(
      contentIndex,
      'AgentSessionTurnOutputTextDeltaEvent.contentIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      delta,
      'AgentSessionTurnOutputTextDeltaEvent.delta',
      min: 0,
    );
    validateAgentLength(
      eventId,
      'AgentSessionTurnOutputTextDeltaEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnOutputTextDeltaEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnOutputTextDeltaEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnOutputTextDeltaEvent.sessionId',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnOutputTextDeltaEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content_index': contentIndex,
    'delta': delta,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'session_id': sessionId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnOutputTextDeltaEvent copyWith({
    int? contentIndex,
    String? delta,
    String? eventId,
    String? itemId,
    int? outputIndex,
    String? sessionId,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnOutputTextDeltaEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    delta: delta ?? this.delta,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sessionId: sessionId ?? this.sessionId,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnOutputTextDeltaEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when an output text content part is complete.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnOutputTextDoneEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnOutputTextDoneEvent].
  AgentSessionTurnOutputTextDoneEvent({
    required this.contentIndex,
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.sessionId,
    required this.text,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'content_index',
         'event_id',
         'item_id',
         'output_index',
         'session_id',
         'text',
         'turn_id',
         'type',
       ], 'AgentSessionTurnOutputTextDoneEvent') {
    validate();
  }

  /// The index of the content part in the message.
  final int contentIndex;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the message item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The complete output text.
  final String text;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.output_text.done`.
  @override
  String get type => 'agent.session.turn.output_text.done';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnOutputTextDoneEvent] with contextual, payload-free errors.
  factory AgentSessionTurnOutputTextDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.output_text.done',
      'AgentSessionTurnOutputTextDoneEvent',
    );
    return AgentSessionTurnOutputTextDoneEvent(
      contentIndex: requiredAgentValue(
        json,
        'content_index',
        'AgentSessionTurnOutputTextDoneEvent.contentIndex',
        requireAgentInt,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnOutputTextDoneEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnOutputTextDoneEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnOutputTextDoneEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnOutputTextDoneEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionTurnOutputTextDoneEvent.text',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnOutputTextDoneEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content_index',
            'event_id',
            'item_id',
            'output_index',
            'session_id',
            'text',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(
      contentIndex,
      'AgentSessionTurnOutputTextDoneEvent.contentIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      eventId,
      'AgentSessionTurnOutputTextDoneEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnOutputTextDoneEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnOutputTextDoneEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnOutputTextDoneEvent.sessionId',
      min: 0,
    );
    validateAgentLength(
      text,
      'AgentSessionTurnOutputTextDoneEvent.text',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnOutputTextDoneEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content_index': contentIndex,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'session_id': sessionId,
    'text': text,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnOutputTextDoneEvent copyWith({
    int? contentIndex,
    String? eventId,
    String? itemId,
    int? outputIndex,
    String? sessionId,
    String? text,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnOutputTextDoneEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sessionId: sessionId ?? this.sessionId,
    text: text ?? this.text,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnOutputTextDoneEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a reasoning summary content part is added.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnReasoningSummaryPartAddedEvent
    extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnReasoningSummaryPartAddedEvent].
  AgentSessionTurnReasoningSummaryPartAddedEvent({
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.part,
    required this.sessionId,
    required this.summaryIndex,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'item_id',
         'output_index',
         'part',
         'session_id',
         'summary_index',
         'turn_id',
         'type',
       ], 'AgentSessionTurnReasoningSummaryPartAddedEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the reasoning item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The initial summary part.
  final AgentSessionSummaryTextResource part;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The index of the summary content part.
  final int summaryIndex;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.reasoning_summary_part.added`.
  @override
  String get type => 'agent.session.turn.reasoning_summary_part.added';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnReasoningSummaryPartAddedEvent] with contextual, payload-free errors.
  factory AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.reasoning_summary_part.added',
      'AgentSessionTurnReasoningSummaryPartAddedEvent',
    );
    return AgentSessionTurnReasoningSummaryPartAddedEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      part: requiredAgentValue(
        json,
        'part',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.part',
        (value, context) => AgentSessionSummaryTextResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      summaryIndex: requiredAgentValue(
        json,
        'summary_index',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.summaryIndex',
        requireAgentInt,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnReasoningSummaryPartAddedEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'item_id',
            'output_index',
            'part',
            'session_id',
            'summary_index',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnReasoningSummaryPartAddedEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnReasoningSummaryPartAddedEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnReasoningSummaryPartAddedEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    part.validate();
    validateAgentLength(
      sessionId,
      'AgentSessionTurnReasoningSummaryPartAddedEvent.sessionId',
      min: 0,
    );
    validateAgentInt(
      summaryIndex,
      'AgentSessionTurnReasoningSummaryPartAddedEvent.summaryIndex',
      min: 0,
      max: 4294967295,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnReasoningSummaryPartAddedEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'part': part.toJson(),
    'session_id': sessionId,
    'summary_index': summaryIndex,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnReasoningSummaryPartAddedEvent copyWith({
    String? eventId,
    String? itemId,
    int? outputIndex,
    AgentSessionSummaryTextResource? part,
    String? sessionId,
    int? summaryIndex,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnReasoningSummaryPartAddedEvent(
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    part: part ?? this.part,
    sessionId: sessionId ?? this.sessionId,
    summaryIndex: summaryIndex ?? this.summaryIndex,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnReasoningSummaryPartAddedEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a reasoning summary part is complete.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnReasoningSummaryPartDoneEvent
    extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnReasoningSummaryPartDoneEvent].
  AgentSessionTurnReasoningSummaryPartDoneEvent({
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.part,
    required this.sessionId,
    required this.status,
    required this.summaryIndex,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'item_id',
         'output_index',
         'part',
         'session_id',
         'status',
         'summary_index',
         'turn_id',
         'type',
       ], 'AgentSessionTurnReasoningSummaryPartDoneEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the reasoning item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The completed summary part.
  final AgentSessionSummaryTextResource part;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// Present as `incomplete` when summary generation was interrupted.
  final String? status;

  /// The index of the summary part.
  final int summaryIndex;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.reasoning_summary_part.done`.
  @override
  String get type => 'agent.session.turn.reasoning_summary_part.done';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnReasoningSummaryPartDoneEvent] with contextual, payload-free errors.
  factory AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.reasoning_summary_part.done',
      'AgentSessionTurnReasoningSummaryPartDoneEvent',
    );
    return AgentSessionTurnReasoningSummaryPartDoneEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      part: requiredAgentValue(
        json,
        'part',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.part',
        (value, context) => AgentSessionSummaryTextResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.status',
        requireAgentString,
        nullable: true,
      ),
      summaryIndex: requiredAgentValue(
        json,
        'summary_index',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.summaryIndex',
        requireAgentInt,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnReasoningSummaryPartDoneEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'item_id',
            'output_index',
            'part',
            'session_id',
            'status',
            'summary_index',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    part.validate();
    validateAgentLength(
      sessionId,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.sessionId',
      min: 0,
    );
    if (status != null) {
      validateAgentEnum(status!, [
        'incomplete',
      ], 'AgentSessionTurnReasoningSummaryPartDoneEvent.status');
      validateAgentLength(
        status!,
        'AgentSessionTurnReasoningSummaryPartDoneEvent.status',
        min: 0,
      );
    }
    validateAgentInt(
      summaryIndex,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.summaryIndex',
      min: 0,
      max: 4294967295,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnReasoningSummaryPartDoneEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'part': part.toJson(),
    'session_id': sessionId,
    'status': status,
    'summary_index': summaryIndex,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnReasoningSummaryPartDoneEvent copyWith({
    String? eventId,
    String? itemId,
    int? outputIndex,
    AgentSessionSummaryTextResource? part,
    String? sessionId,
    Object? status = unsetCopyWithValue,
    int? summaryIndex,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnReasoningSummaryPartDoneEvent(
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    part: part ?? this.part,
    sessionId: sessionId ?? this.sessionId,
    status: copyAgentValue<String>(
      status,
      this.status,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.status',
    ),
    summaryIndex: summaryIndex ?? this.summaryIndex,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnReasoningSummaryPartDoneEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when text is appended to a reasoning summary.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnReasoningSummaryTextDeltaEvent
    extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnReasoningSummaryTextDeltaEvent].
  AgentSessionTurnReasoningSummaryTextDeltaEvent({
    required this.delta,
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.sessionId,
    required this.summaryIndex,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'delta',
         'event_id',
         'item_id',
         'output_index',
         'session_id',
         'summary_index',
         'turn_id',
         'type',
       ], 'AgentSessionTurnReasoningSummaryTextDeltaEvent') {
    validate();
  }

  /// The summary text that was appended.
  final String delta;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the reasoning item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The index of the summary content part.
  final int summaryIndex;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.reasoning_summary_text.delta`.
  @override
  String get type => 'agent.session.turn.reasoning_summary_text.delta';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnReasoningSummaryTextDeltaEvent] with contextual, payload-free errors.
  factory AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.reasoning_summary_text.delta',
      'AgentSessionTurnReasoningSummaryTextDeltaEvent',
    );
    return AgentSessionTurnReasoningSummaryTextDeltaEvent(
      delta: requiredAgentValue(
        json,
        'delta',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.delta',
        requireAgentString,
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      summaryIndex: requiredAgentValue(
        json,
        'summary_index',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.summaryIndex',
        requireAgentInt,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'delta',
            'event_id',
            'item_id',
            'output_index',
            'session_id',
            'summary_index',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      delta,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.delta',
      min: 0,
    );
    validateAgentLength(
      eventId,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.sessionId',
      min: 0,
    );
    validateAgentInt(
      summaryIndex,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.summaryIndex',
      min: 0,
      max: 4294967295,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnReasoningSummaryTextDeltaEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'delta': delta,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'session_id': sessionId,
    'summary_index': summaryIndex,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnReasoningSummaryTextDeltaEvent copyWith({
    String? delta,
    String? eventId,
    String? itemId,
    int? outputIndex,
    String? sessionId,
    int? summaryIndex,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnReasoningSummaryTextDeltaEvent(
    delta: delta ?? this.delta,
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sessionId: sessionId ?? this.sessionId,
    summaryIndex: summaryIndex ?? this.summaryIndex,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnReasoningSummaryTextDeltaEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a reasoning summary content part is complete.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnReasoningSummaryTextDoneEvent
    extends AgentSessionEvent {
  /// Creates a validated [AgentSessionTurnReasoningSummaryTextDoneEvent].
  AgentSessionTurnReasoningSummaryTextDoneEvent({
    required this.eventId,
    required this.itemId,
    required this.outputIndex,
    required this.sessionId,
    required this.summaryIndex,
    required this.text,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'event_id',
         'item_id',
         'output_index',
         'session_id',
         'summary_index',
         'text',
         'turn_id',
         'type',
       ], 'AgentSessionTurnReasoningSummaryTextDoneEvent') {
    validate();
  }

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the reasoning item.
  final String itemId;

  /// The index of the item in the turn output.
  final int outputIndex;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The index of the summary content part.
  final int summaryIndex;

  /// The complete reasoning summary text.
  final String text;

  /// The ID of the turn associated with the event, when applicable.
  final String? turnId;

  /// The type of the object. Always `agent.session.turn.reasoning_summary_text.done`.
  @override
  String get type => 'agent.session.turn.reasoning_summary_text.done';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnReasoningSummaryTextDoneEvent] with contextual, payload-free errors.
  factory AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent.session.turn.reasoning_summary_text.done',
      'AgentSessionTurnReasoningSummaryTextDoneEvent',
    );
    return AgentSessionTurnReasoningSummaryTextDoneEvent(
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      itemId: requiredAgentValue(
        json,
        'item_id',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.itemId',
        requireAgentString,
        nullable: false,
      )!,
      outputIndex: requiredAgentValue(
        json,
        'output_index',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.outputIndex',
        requireAgentInt,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      summaryIndex: requiredAgentValue(
        json,
        'summary_index',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.summaryIndex',
        requireAgentInt,
        nullable: false,
      )!,
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.text',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionTurnReasoningSummaryTextDoneEvent.turnId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'event_id',
            'item_id',
            'output_index',
            'session_id',
            'summary_index',
            'text',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      eventId,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.eventId',
      min: 0,
    );
    validateAgentLength(
      itemId,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.itemId',
      min: 0,
    );
    validateAgentInt(
      outputIndex,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.outputIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      sessionId,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.sessionId',
      min: 0,
    );
    validateAgentInt(
      summaryIndex,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.summaryIndex',
      min: 0,
      max: 4294967295,
    );
    validateAgentLength(
      text,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.text',
      min: 0,
    );
    if (turnId != null) {
      validateAgentLength(
        turnId!,
        'AgentSessionTurnReasoningSummaryTextDoneEvent.turnId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'event_id': eventId,
    'item_id': itemId,
    'output_index': outputIndex,
    'session_id': sessionId,
    'summary_index': summaryIndex,
    'text': text,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnReasoningSummaryTextDoneEvent copyWith({
    String? eventId,
    String? itemId,
    int? outputIndex,
    String? sessionId,
    int? summaryIndex,
    String? text,
    Object? turnId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnReasoningSummaryTextDoneEvent(
    eventId: eventId ?? this.eventId,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sessionId: sessionId ?? this.sessionId,
    summaryIndex: summaryIndex ?? this.summaryIndex,
    text: text ?? this.text,
    turnId: copyAgentValue<String>(
      turnId,
      this.turnId,
      'AgentSessionTurnReasoningSummaryTextDoneEvent.turnId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Emitted when a turn or session fails.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionErrorEvent extends AgentSessionEvent {
  /// Creates a validated [AgentSessionErrorEvent].
  AgentSessionErrorEvent({
    required this.error,
    required this.eventId,
    required this.sessionId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'error',
         'event_id',
         'session_id',
         'type',
       ], 'AgentSessionErrorEvent') {
    validate();
  }

  /// The error that occurred.
  final AgentSessionErrorResource error;

  /// The unique ID of the event.
  final String eventId;

  /// The ID of the session associated with the event.
  final String sessionId;

  /// The type of the object. Always `error`.
  @override
  String get type => 'error';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionErrorEvent] with contextual, payload-free errors.
  factory AgentSessionErrorEvent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'error', 'AgentSessionErrorEvent');
    return AgentSessionErrorEvent(
      error: requiredAgentValue(
        json,
        'error',
        'AgentSessionErrorEvent.error',
        (value, context) => AgentSessionErrorResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      eventId: requiredAgentValue(
        json,
        'event_id',
        'AgentSessionErrorEvent.eventId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionErrorEvent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'error',
            'event_id',
            'session_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    error.validate();
    validateAgentLength(eventId, 'AgentSessionErrorEvent.eventId', min: 0);
    validateAgentLength(sessionId, 'AgentSessionErrorEvent.sessionId', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'error': error.toJson(),
    'event_id': eventId,
    'session_id': sessionId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionErrorEvent copyWith({
    AgentSessionErrorResource? error,
    String? eventId,
    String? sessionId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionErrorEvent(
    error: error ?? this.error,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId ?? this.sessionId,
    rawJson: rawJson ?? this.rawJson,
  );
}
