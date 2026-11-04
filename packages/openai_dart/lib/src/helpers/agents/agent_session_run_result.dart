part of 'agent_session_run.dart';

/// Joins supplied assistant message text in content order, without I/O or phase
/// selection. Callers can supply commentary too; result collection filters it.
String agentSessionMessagesText(
  Iterable<AgentSessionAssistantMessageItemResource> messages,
) => messages
    .expand((message) => message.content)
    .map((content) => content.text)
    .join();

/// Detached completed coordinator turn and its final assistant messages.
///
/// This is a local result, not a wire DTO or a final-result HTTP endpoint.
/// [outputText] joins every collected message; [finalAnswer] selects the last
/// explicit final-answer message, falling back to the last legacy null phase.
@immutable
class AgentSessionRunResult {
  /// Copies source-supported snapshots and requires completed root-turn identity.
  AgentSessionRunResult({
    required AgentSessionTurn turn,
    required List<AgentSessionAssistantMessageItemResource> messages,
  }) : turn = AgentSessionTurn.fromJson(turn.toJson()),
       messages = List.unmodifiable(
         messages.map(
           (message) => AgentSessionAssistantMessageItemResource.fromJson(
             message.toJson(),
           ),
         ),
       ) {
    if (this.turn.status.value != 'completed' ||
        this.turn.subagentId != null ||
        this.messages.any(
          (message) =>
              message.turnId != this.turn.id ||
              message.status.value != 'completed' ||
              message.phase?.value == 'commentary',
        )) {
      throw const FormatException(
        'An Agent run result requires a completed root turn and matching final messages',
      );
    }
  }

  /// Actual completed root-turn snapshot, with legitimate received extras.
  final AgentSessionTurn turn;

  /// Completed selected-turn messages ordered by output index, with extras.
  final List<AgentSessionAssistantMessageItemResource> messages;

  /// Durable session identity from the completed turn; never synthesized.
  String get sessionId => turn.sessionId;

  /// Completed root turn identity; independent of environment/artifact lifetime.
  String get turnId => turn.id;

  /// Pure concatenation of all collected message text, with no added separator.
  String get outputText => agentSessionMessagesText(messages);

  /// Last explicit final answer, otherwise the last legacy null-phase message.
  AgentSessionAssistantMessageItemResource? get finalAnswer {
    for (final message in messages.reversed) {
      if (message.phase?.value == 'final_answer') return message;
    }
    for (final message in messages.reversed) {
      if (message.phase == null) return message;
    }
    return null;
  }

  /// Text of [finalAnswer], or an empty string when no final message exists.
  String get finalAnswerText =>
      finalAnswer == null ? '' : agentSessionMessagesText([finalAnswer!]);

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is AgentSessionRunResult &&
      turn == other.turn &&
      listsEqual(messages, other.messages);
  @override
  int get hashCode => Object.hash(runtimeType, turn, Object.hashAll(messages));
  @override
  String toString() => 'AgentSessionRunResult([REDACTED])';
}

/// Why local collection could not establish a successful completed result.
enum AgentSessionRunResultReason {
  /// The service reported selected turn/session failure.
  failed,

  /// The service reported selected turn cancellation.
  cancelled,

  /// Required actions need explicit application handling.
  requiresAction,

  /// No completed selected turn and idle boundary was established.
  incomplete,

  /// Observation/setup/input/result delivery failed; backend failure is unknown.
  observationFailed,

  /// A local collection retention budget was exceeded.
  collectionLimit,

  /// Received identity fields conflict; no safe result routing can be established.
  identityMismatch,
}

/// Private local result failure with detached partial state and explicit cause.
/// An observation failure never claims the backend turn failed.
final class AgentSessionRunResultException implements Exception {
  AgentSessionRunResultException._(
    this.reason, {
    this.sessionId,
    AgentSessionTurn? turn,
    required List<AgentSessionAssistantMessageItemResource> messages,
    required List<AgentSessionRequiredAction> requiredActions,
    this.cause,
  }) : turn = turn == null ? null : AgentSessionTurn.fromJson(turn.toJson()),
       messages = List.unmodifiable(
         messages.map(
           (message) => AgentSessionAssistantMessageItemResource.fromJson(
             message.toJson(),
           ),
         ),
       ),
       requiredActions = List.unmodifiable(
         requiredActions.map(
           (action) => AgentSessionRequiredAction.fromJson(action.toJson()),
         ),
       );

  /// Original observation/request failure, for explicit inspection.
  final Object? cause;

  /// Local classification, independent of any inferred environment state.
  final AgentSessionRunResultReason reason;

  /// Known durable session identity, or null before creation identity.
  final String? sessionId;

  /// Available selected-turn snapshot, or null before selection.
  final AgentSessionTurn? turn;

  /// Available completed final messages, in output order.
  final List<AgentSessionAssistantMessageItemResource> messages;

  /// Latest observed required actions; historical actions are never replayed.
  final List<AgentSessionRequiredAction> requiredActions;

  /// Selected partial turn identity, when observed.
  String? get turnId => turn?.id;
  @override
  String toString() =>
      'AgentSessionRunResultException(reason: $reason, [REDACTED])';
}

/// Caller-owned JSON schema plus a synchronous local parser/validator.
/// The parser must validate its expected output; no validation runtime is inferred.
final class AgentSessionOutputBinding<T> {
  /// Captures a canonical format and local parser. The parser never enters JSON.
  AgentSessionOutputBinding({
    required AgentJsonSchemaFormat format,
    required this.parse,
  }) : format = AgentJsonSchemaFormat.fromJson(format.toJson());

  /// Canonical Agents JSON schema format, deeply detached.
  final AgentJsonSchemaFormat format;

  /// Validates one complete text block and constructs an application value.
  final T Function(String text) parse;
  @override
  String toString() => 'AgentSessionOutputBinding<$T>([REDACTED])';
}

/// Completed raw result plus its first parsed value after every block validates.
/// Raw snapshots are immutable; ownership of arbitrary [parsed] values belongs to
/// the caller's parser (prefer immutable application values).
final class AgentSessionParsedRunResult<T> extends AgentSessionRunResult {
  AgentSessionParsedRunResult._(AgentSessionRunResult result, this.parsed)
    : super(turn: result.turn, messages: result.messages);

  /// First parsed text value, returned only after all text blocks validate.
  final T parsed;
  @override
  bool operator ==(Object other) =>
      other is AgentSessionParsedRunResult<T> &&
      super == other &&
      parsed == other.parsed;
  @override
  int get hashCode => Object.hash(super.hashCode, parsed);
}

/// Parsing failed after successful hosted work. [result] remains available.
final class AgentSessionOutputParseException implements Exception {
  const AgentSessionOutputParseException._(this.result, this.cause);

  /// Original local validator error, never rendered automatically.
  final Object cause;

  /// Successfully completed raw result, unaffected by local validation failure.
  final AgentSessionRunResult result;
  @override
  String toString() => 'AgentSessionOutputParseException([REDACTED])';
}

/// Typed view of one run, sharing its observation, cursor and local dispatcher.
final class AgentSessionTypedRun<T> {
  AgentSessionTypedRun._(this._run, this._binding);
  final AgentSessionRun _run;
  final AgentSessionOutputBinding<T> _binding;
  Future<AgentSessionParsedRunResult<T>>? _result;

  /// Original progress stream; breaking cancels local observation.
  Stream<AgentSessionEvent> get events => _run.events;

  /// Known durable session, throwing before creation identity is observed.
  String get sessionId => _run.sessionId;

  /// Nullable canonical creation identity, never fabricated.
  String? get observedSessionId => _run.observedSessionId;

  /// Selected root-turn identity, when observed.
  String? get selectedTurnId => _run.selectedTurnId;

  /// Local handle lifecycle, independent of backend completion.
  bool get isClosed => _run.isClosed;

  /// Advances the shared controlled cursor.
  Future<AgentSessionEvent?> nextEvent() => _run.nextEvent();

  /// Deliberately starts the same lazy request/observation setup.
  Future<void> start() => _run.start();

  /// Aborts local observation; already performed effects remain.
  void abort([Object? reason]) => _run.abort(reason);

  /// Releases local observation only.
  Future<void> close() => _run.close();

  /// Cached success or failure; no repeated input, handlers or parser execution.
  Future<AgentSessionParsedRunResult<T>> finalResult() => _result ??= _parse();
  Future<AgentSessionParsedRunResult<T>> _parse() async {
    final raw = await _run.finalResult();
    try {
      T? first;
      var found = false;
      for (final message in raw.messages) {
        for (final block in message.content) {
          final value = _binding.parse(block.text);
          if (!found) {
            first = value;
            found = true;
          }
        }
      }
      if (!found) throw const FormatException('No completed Agent output text');
      return AgentSessionParsedRunResult<T>._(raw, first as T);
    } catch (error) {
      throw AgentSessionOutputParseException._(raw, error);
    }
  }

  @override
  String toString() => 'AgentSessionTypedRun<$T>([REDACTED])';
}

final class _AgentRunCollector {
  _AgentRunCollector(this.run, this.maxMessages, this.maxBytes);
  final AgentSessionRun run;
  final int maxMessages;
  final int maxBytes;
  AgentSessionTurn? turn;
  List<AgentSessionRequiredAction> actions = const [];
  final _messages =
      <String, (int, int, AgentSessionAssistantMessageItemResource)>{};
  var _messageBytes = 0;
  var _terminal = false;
  var _idle = false;
  var _sessionFailed = false;
  bool get ready => _terminal && _idle;

  List<AgentSessionAssistantMessageItemResource> get messages {
    final values = _messages.values.toList()
      ..sort((a, b) {
        final index = a.$1.compareTo(b.$1);
        return index == 0 ? a.$2.compareTo(b.$2) : index;
      });
    return values.map((value) => value.$3).toList();
  }

  void accept(AgentSessionEvent event) {
    if (ready) return;
    AgentSession? session;
    if (event is AgentSessionCreatedEvent) session = event.session;
    if (event is AgentSessionIdleEvent) session = event.session;
    if (event is AgentSessionInProgressEvent) session = event.session;
    if (event is AgentSessionRequiresActionEvent) session = event.session;
    if (event is AgentSessionFailedEvent) session = event.session;
    if (session != null) {
      _identity(session.id == run.observedSessionId);
      final next = session.requiredActions
          .map((action) => AgentSessionRequiredAction.fromJson(action.toJson()))
          .toList();
      _budget(turn, next, _messageBytes);
      actions = next;
      _sessionFailed |= event is AgentSessionFailedEvent;
      _idle |= event is AgentSessionIdleEvent && _terminal;
    }
    AgentSessionTurn? updated;
    String? outerSession;
    String? outerTurn;
    if (event is AgentSessionTurnCreatedEvent) {
      if (turn == null && event.turn.subagentId == null) {
        updated = event.turn;
        outerSession = event.sessionId;
        outerTurn = event.turnId;
      }
    } else if (event is AgentSessionTurnCompletedEvent) {
      if (event.turnId == turn?.id || event.turn.id == turn?.id) {
        updated = event.turn;
        outerSession = event.sessionId;
        outerTurn = event.turnId;
        _terminal = true;
      }
    } else if (event is AgentSessionTurnFailedEvent) {
      if (event.turnId == turn?.id || event.turn.id == turn?.id) {
        updated = event.turn;
        outerSession = event.sessionId;
        outerTurn = event.turnId;
        _terminal = true;
      }
    } else if (event is AgentSessionTurnCancelledEvent) {
      if (event.turnId == turn?.id || event.turn.id == turn?.id) {
        updated = event.turn;
        outerSession = event.sessionId;
        outerTurn = event.turnId;
        _terminal = true;
      }
    }
    if (updated != null) {
      _identity(
        outerSession == run.observedSessionId &&
            updated.sessionId == outerSession &&
            updated.id == outerTurn &&
            updated.subagentId == null &&
            (turn == null || updated.id == turn!.id),
      );
      final nextActions = _terminal
          ? const <AgentSessionRequiredAction>[]
          : actions;
      _budget(updated, nextActions, _messageBytes);
      turn = AgentSessionTurn.fromJson(updated.toJson());
      actions = nextActions;
    }
    if (event is AgentSessionTurnItemDoneEvent &&
        event.item is AgentSessionAssistantMessageItemResource) {
      final item = event.item as AgentSessionAssistantMessageItemResource;
      // The item's containing turn is authoritative; a forwarded child's event
      // may be associated with coordinator context in the outer envelope.
      if (turn == null || item.turnId != turn!.id) {
        return;
      }
      _identity(
        item.turnId == turn!.id &&
            (event.turnId == null || event.turnId == turn!.id) &&
            event.sessionId == run.observedSessionId,
      );
      if (item.status.value != 'completed' ||
          item.phase?.value == 'commentary' ||
          _messages.containsKey(item.id)) {
        return;
      }
      if (_messages.length >= maxMessages) {
        throw error(AgentSessionRunResultReason.collectionLimit);
      }
      final snapshot = AgentSessionAssistantMessageItemResource.fromJson(
        item.toJson(),
      );
      final bytes = utf8.encode(jsonEncode(snapshot.toJson())).length;
      _budget(turn, actions, _messageBytes + bytes);
      _messageBytes += bytes;
      _messages[item.id] = (event.outputIndex, _messages.length, snapshot);
    }
  }

  void _identity(bool valid) {
    if (!valid) throw error(AgentSessionRunResultReason.identityMismatch);
  }

  void _budget(
    AgentSessionTurn? nextTurn,
    List<AgentSessionRequiredAction> nextActions,
    int messageBytes,
  ) {
    final stateBytes = utf8
        .encode(
          jsonEncode({
            'turn': nextTurn?.toJson(),
            'actions': nextActions.map((a) => a.toJson()).toList(),
          }),
        )
        .length;
    if (messageBytes + stateBytes > maxBytes) {
      throw error(AgentSessionRunResultReason.collectionLimit);
    }
  }

  bool get hasUnhandledAction =>
      !ready &&
      actions.any(
        (action) =>
            action is! AgentSessionFunctionCallRequiredAction ||
            !run._dispatcher.canHandle(action.name),
      );
  void checkAction({bool checkRequiredActions = true}) {
    if (_sessionFailed || turn?.status.value == 'failed') {
      throw error(AgentSessionRunResultReason.failed);
    }
    if (turn?.status.value == 'cancelled') {
      throw error(AgentSessionRunResultReason.cancelled);
    }
    if (checkRequiredActions &&
        !ready &&
        actions.any(
          (action) =>
              action is! AgentSessionFunctionCallRequiredAction ||
              !run._dispatcher.canHandle(action.name),
        )) {
      throw error(AgentSessionRunResultReason.requiresAction);
    }
  }

  AgentSessionRunResult finish() {
    checkAction();
    if (!ready || turn?.status.value != 'completed') {
      throw error(AgentSessionRunResultReason.incomplete);
    }
    _identity(
      turn!.id == run.selectedTurnId &&
          turn!.sessionId == run.observedSessionId,
    );
    return AgentSessionRunResult(turn: turn!, messages: messages);
  }

  AgentSessionRunResultException error(
    AgentSessionRunResultReason reason, [
    Object? cause,
  ]) => AgentSessionRunResultException._(
    reason,
    sessionId: run.observedSessionId,
    turn: turn,
    messages: messages,
    requiredActions: actions,
    cause: cause,
  );
  void release() {
    turn = null;
    actions = const [];
    _messages.clear();
    _messageBytes = 0;
  }
}
