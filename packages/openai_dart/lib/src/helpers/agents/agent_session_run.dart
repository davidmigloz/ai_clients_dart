import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import '../../errors/exceptions.dart';
import '../../models/agents/agent_session_models.dart';
import '../../resources/agent_sessions_resource.dart';

/// One lazy follow-up observation on an idle durable session.
///
/// Prefer `client.agents.sessions.stream`. Exactly one input writer is required:
/// the service's input acceptance does not return a selected turn ID or lock the
/// session. Raw `sessions.events` remains the interface for steering active work.
///
/// [events] supports ordinary Stream consumption. Breaking/canceling it closes
/// local observation. To pull a few events and continue later, use [nextEvent]
/// sequentially instead; a Stream break cannot preserve a continuation.
/// [start] starts setup deliberately, otherwise the first consumption starts it.
/// A second progress driver, concurrent pull, or repeated external start rejects.
///
/// Original events retain arrival order. Delivery IDs use a 1,024-entry recent
/// window; queued progress has explicit count/byte limits. Overflow is a local
/// error, never silent loss or an invented backend failure. A selected root turn
/// ending followed by session idle, or session failure, ends observation. EOF
/// before that boundary is a local observation failure.
///
/// [abort]/[close] release local observation, not backend work or compute. No
/// cancellation input, session deletion, replay or reconnection is sent. Request
/// failures are retained as explicit causes of private [StreamException] values.
final class AgentSessionRun {
  /// Captures input/options without making any request.
  ///
  /// [input] is the existing string/message-array union. An empty item array is
  /// rejected by this helper only. Request-header idempotency keys win over the
  /// named key case-insensitively; otherwise one stable input-only key is made.
  /// Buffers default to 256 events and 1 MiB of encoded JSON. These are local
  /// retention limits, not wire limits or a limit on durable server history.
  AgentSessionRun({
    required this._sessions,
    required this.sessionId,
    required AgentSessionInitialInput input,
    String? idempotencyKey,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
    this.maxBufferedEvents = 256,
    this.maxBufferedBytes = 1024 * 1024,
  }) : _headers = Map<String, String>.unmodifiable(
         additionalHeaders ?? const {},
       ) {
    inputKey = _inputKey(_headers, idempotencyKey);
    if (!maxBufferedEvents.isFinite ||
        !maxBufferedBytes.isFinite ||
        maxBufferedEvents < 1 ||
        maxBufferedBytes < 1) {
      throw const FormatException(
        'Agent session run buffer limits must be positive',
      );
    }
    // Round-trip through strict immutable raw DTOs. No local metadata/callback is
    // serialized, and caller collections cannot change a later lazy submission.
    final captured = AgentSessionInitialInput.fromJson(input.toJson());
    final messages = switch (captured) {
      final AgentSessionInitialInputText value => [
        AgentSessionInputMessage(
          content: [AgentSessionInputContent.inputText(text: value.text)],
        ),
      ],
      final AgentSessionInitialInputItems value => value.items,
    };
    if (messages.isEmpty) {
      throw const FormatException('Agent session run input must not be empty');
    }
    _input = CreateAgentSessionEventsRequest(
      events: [AgentSessionInput.message(input: messages)],
    );
    _headers = Map<String, String>.unmodifiable({
      for (final entry in _headers.entries)
        if (entry.key.toLowerCase() != 'idempotency-key')
          entry.key: entry.value,
    });
    if (abortTrigger != null) {
      unawaited(
        abortTrigger.then<void>(
          (_) => abort(),
          onError: (Object error, StackTrace _) => abort(error),
        ),
      );
    }
  }

  final AgentSessionsResource _sessions;

  /// The selected durable session; never printed automatically.
  final String sessionId;

  /// The stable key for this input submission only, distinct from tool results.
  late final String inputKey;

  /// Maximum retained, not-yet-delivered original events.
  final int maxBufferedEvents;

  /// Maximum encoded JSON bytes retained in the progress queue.
  final int maxBufferedBytes;

  CreateAgentSessionEventsRequest? _input;
  Map<String, String> _headers;
  final _queue = Queue<_RunDelivery>();
  final _recentIds = <String>{};
  final _abortSignal = Completer<void>();
  final _stopped = Completer<void>();
  Completer<void>? _changed;
  Completer<void>? _ready;
  Future<void>? _startFuture;
  Future<void>? _cleanupFuture;
  StreamSubscription<AgentSessionEvent>? _subscription;
  Object? _failure;
  StackTrace? _failureStack;
  String? _driver;
  String? _selectedTurnId;
  var _queueBytes = 0;
  var _pulling = false;
  var _requestStarted = false;
  var _subscribed = false;
  var _boundarySeen = false;
  var _terminalDelivered = false;
  var _turnEnded = false;
  var _cancelRequested = false;
  var _closed = false;
  var _pauseDepth = 0;
  var _cursorPaused = false;

  /// First coordinator turn observed by this invocation, or null before selection.
  String? get selectedTurnId => _selectedTurnId;

  /// Whether this local handle has closed or failed. Backend lifecycle is separate.
  bool get isClosed => _closed;

  /// Single-use Stream adapter. Break/take/cancel closes local observation.
  late final Stream<AgentSessionEvent> events = _RunEvents(this);

  /// Deliberately starts retrieve -> subscribe-ready -> one normalized input.
  ///
  /// Completion means input acceptance, not turn completion. An externally
  /// repeated start rejects; internal cursor advancement reuses the same setup.
  Future<void> start() {
    if (_startFuture != null) {
      throw StateError('An Agent session run can only be started once');
    }
    return _ensureStarted();
  }

  /// Pulls the next original event, or null after the observed terminal boundary.
  ///
  /// Calls must be sequential. This controlled cursor can pause and continue
  /// between pulls; never combine it with [events].
  Future<AgentSessionEvent?> nextEvent() {
    if (_driver != null && _driver != 'pull') {
      throw StateError('An Agent session run has only one progress driver');
    }
    if (_pulling) {
      throw StateError('Concurrent Agent session pulls are not supported');
    }
    _driver = 'pull';
    _pulling = true;
    return _advance()
        .then((event) {
          if (event != null && !_terminalDelivered && _failure == null) {
            _cursorPaused = true;
            _pauseSource(null);
          }
          return event;
        })
        .whenComplete(() => _pulling = false);
  }

  Future<void> _ensureStarted() => _startFuture ??= _begin();

  Future<void> _begin() async {
    // Let a completed external abort win before authentication or any request.
    await Future<void>.value();
    try {
      _throwFailure();
      _requestStarted = true;
      final current = await _race(
        _sessions.retrieve(
          sessionId,
          additionalHeaders: _headers,
          abortTrigger: _abortSignal.future,
        ),
      );
      _throwFailure();
      if (current.status.value != 'idle') {
        throw StateError(
          'sessions.stream requires an idle session; use sessions.events.stream for active work',
        );
      }
      _ready = Completer<void>();
      _subscribed = true;
      _subscription = _sessions.events
          .stream(
            sessionId,
            additionalHeaders: _headers,
            abortTrigger: _abortSignal.future,
            onReady: () {
              if (!_ready!.isCompleted) _ready!.complete();
            },
          )
          .listen(
            _accept,
            onError: _sourceError,
            onDone: () {
              if (!_boundarySeen && _failure == null) {
                _fail(
                  const StreamException(
                    message:
                        'Session observation ended before the selected turn reached idle or failed',
                    redactDiagnostics: true,
                  ),
                  StackTrace.current,
                );
              }
            },
          );
      for (var pause = 0; pause < _pauseDepth; pause++) {
        _subscription!.pause();
      }
      if (_cancelRequested) unawaited(_cleanup());
      await _race(_ready!.future);
      _throwFailure();
      await _race(
        _sessions.events.create(
          sessionId,
          _input!,
          idempotencyKey: inputKey,
          additionalHeaders: _headers,
          abortTrigger: _abortSignal.future,
        ),
      );
      _throwFailure();
      _input = null;
    } catch (error, stack) {
      _fail(error, stack);
      _discardQueue();
      _throwFailure();
    }
  }

  Future<T> _race<T>(Future<T> operation) => Future.any([
    operation,
    _stopped.future.then<T>((_) {
      _throwFailure();
      throw const StreamException(
        message: 'Agent session observation stopped during setup',
        redactDiagnostics: true,
      );
    }),
  ]);

  void _accept(AgentSessionEvent event) {
    if (_failure != null || _boundarySeen || _closed) return;
    try {
      final json = event.toJson();
      final eventId = json['event_id'];
      if (eventId is String) {
        if (_recentIds.contains(eventId)) return;
        if (_recentIds.length == 1024) _recentIds.remove(_recentIds.first);
        _recentIds.add(eventId);
      }
      final bytes = utf8.encode(jsonEncode(json)).length;
      if (_queue.length >= maxBufferedEvents ||
          _queueBytes + bytes > maxBufferedBytes) {
        throw const StreamException(
          message: 'Agent session run progress buffer exceeded its local limit',
          redactDiagnostics: true,
        );
      }
      if (event is AgentSessionTurnCreatedEvent &&
          event.turn.subagentId == null &&
          _selectedTurnId == null) {
        _selectedTurnId = event.turnId;
      }
      if ((event is AgentSessionTurnCompletedEvent &&
                  event.turnId == _selectedTurnId ||
              event is AgentSessionTurnFailedEvent &&
                  event.turnId == _selectedTurnId ||
              event is AgentSessionTurnCancelledEvent &&
                  event.turnId == _selectedTurnId) &&
          _selectedTurnId != null) {
        _turnEnded = true;
      }
      final terminal =
          event is AgentSessionFailedEvent ||
          (event is AgentSessionIdleEvent && _turnEnded);
      _queue.add(_RunDelivery(event, bytes, terminal: terminal));
      _queueBytes += bytes;
      if (terminal) {
        _boundarySeen = true;
        unawaited(_cleanup());
      }
      _wake();
    } catch (error, stack) {
      _fail(error, stack);
    }
  }

  Future<AgentSessionEvent?> _advance() async {
    if (_cursorPaused) {
      _cursorPaused = false;
      _resumeSource();
    }
    await _ensureStarted();
    while (true) {
      if (_terminalDelivered) {
        _closed = true;
        _releaseCapturedState();
        await _cleanup();
        return null;
      }
      if (_queue.isNotEmpty) {
        final next = _queue.removeFirst();
        _queueBytes -= next.bytes;
        _terminalDelivered = next.terminal;
        return next.event;
      }
      _throwFailure();
      final change = _changed ??= Completer<void>();
      await change.future;
    }
  }

  void _throwFailure() {
    if (_failure case final error?) {
      Error.throwWithStackTrace(error, _failureStack ?? StackTrace.current);
    }
  }

  void _sourceError(Object error, StackTrace stack) {
    // A validated source boundary is authoritative even while the separate
    // input-acceptance Future is pending. Genuine input failures use _fail.
    if (_boundarySeen) return;
    _fail(error, stack);
  }

  void _fail(Object error, StackTrace stack) {
    if (_failure != null) return;
    _failure =
        error is StreamException && error.redactDiagnostics ||
            error is AbortedException && error.redactDiagnostics
        ? error
        : StreamException(
            message: 'Agent session run observation failed',
            cause: error,
            redactDiagnostics: true,
          );
    _failureStack = stack;
    if (!_stopped.isCompleted) _stopped.complete();
    if (!_abortSignal.isCompleted) _abortSignal.complete();
    if (_ready != null && !_ready!.isCompleted) _ready!.complete();
    _releaseCapturedState();
    _closed = true;
    _wake();
    unawaited(_cleanup());
  }

  void _wake() {
    final changed = _changed;
    _changed = null;
    if (changed != null && !changed.isCompleted) changed.complete();
  }

  /// Aborts only local requests/observation. An optional reason is caller-readable
  /// through the private abort exception's cause; it is never printed by default.
  void abort([Object? reason]) {
    if (_terminalDelivered) {
      _closed = true;
      _releaseCapturedState();
      unawaited(_cleanup());
      return;
    }
    if (_failure == null) {
      _failure = AbortedException(
        message: 'Agent session run observation aborted',
        stage: !_requestStarted
            ? AbortionStage.beforeRequest
            : _subscribed
            ? AbortionStage.duringStream
            : AbortionStage.duringRequest,
        cause: reason,
        redactDiagnostics: true,
      );
      _failureStack = StackTrace.current;
    }
    _closed = true;
    if (!_stopped.isCompleted) _stopped.complete();
    if (!_abortSignal.isCompleted) _abortSignal.complete();
    if (_ready != null && !_ready!.isCompleted) _ready!.complete();
    _discardQueue();
    _releaseCapturedState();
    _wake();
    unawaited(_cleanup());
  }

  /// Closes only local observation. Durable cancellation remains an explicit raw
  /// input operation. Caller-owned HTTP transports are never closed by this run.
  Future<void> close() async {
    abort();
    await _cleanup();
  }

  void _discardQueue() {
    _queue.clear();
    _queueBytes = 0;
  }

  void _releaseCapturedState() {
    _input = null;
    _headers = const {};
    _recentIds.clear();
  }

  Future<void> _cleanup() {
    _cancelRequested = true;
    final subscription = _subscription;
    if (subscription == null) return Future<void>.value();
    return _cleanupFuture ??= () async {
      try {
        await subscription.cancel();
      } catch (_) {
        /* Preserve the selected outcome. */
      } finally {
        if (identical(_subscription, subscription)) _subscription = null;
      }
    }();
  }

  void _pauseSource(Future<void>? resumeSignal) {
    _pauseDepth++;
    _subscription?.pause();
    if (resumeSignal != null) {
      unawaited(
        resumeSignal.then<void>(
          (_) => _resumeSource(),
          onError: (Object _, StackTrace _) => _resumeSource(),
        ),
      );
    }
  }

  void _resumeSource() {
    if (_pauseDepth > 0) {
      _pauseDepth--;
      _subscription?.resume();
    }
  }

  void _claimStream() {
    if (_driver != null) {
      throw StateError('An Agent session run can only be consumed once');
    }
    _driver = 'stream';
  }

  Stream<AgentSessionEvent> _iterate() async* {
    try {
      while (true) {
        final event = await _advance();
        if (event == null) return;
        yield event;
      }
    } finally {
      await close();
    }
  }

  @override
  String toString() => 'AgentSessionRun([REDACTED])';
}

final class _RunDelivery {
  const _RunDelivery(this.event, this.bytes, {required this.terminal});
  final AgentSessionEvent event;
  final int bytes;
  final bool terminal;
}

final class _RunEvents extends Stream<AgentSessionEvent> {
  _RunEvents(this.run);
  final AgentSessionRun run;
  @override
  StreamSubscription<AgentSessionEvent> listen(
    void Function(AgentSessionEvent)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    run._claimStream();
    return _RunSubscription(
      run,
      run._iterate().listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      ),
    );
  }
}

final class _RunSubscription implements StreamSubscription<AgentSessionEvent> {
  _RunSubscription(this.run, this.inner);
  final AgentSessionRun run;
  final StreamSubscription<AgentSessionEvent> inner;
  Future<void>? _cancelFuture;
  @override
  Future<void> cancel() {
    // Wake a pending generator pull before waiting for generator cancellation.
    run.abort();
    return _cancelFuture ??= () async {
      try {
        await inner.cancel();
      } on AbortedException {
        // An async generator canceled while awaiting setup can return its own
        // local abort as the cancellation result. Cancellation itself succeeds.
      }
      await run.close();
    }();
  }

  @override
  void onData(void Function(AgentSessionEvent)? handleData) =>
      inner.onData(handleData);
  @override
  void onError(Function? handleError) => inner.onError(handleError);
  @override
  void onDone(void Function()? handleDone) => inner.onDone(handleDone);
  @override
  void pause([Future<void>? resumeSignal]) {
    run._pauseSource(resumeSignal);
    inner.pause(resumeSignal);
  }

  @override
  void resume() {
    run._resumeSource();
    inner.resume();
  }

  @override
  bool get isPaused => inner.isPaused;
  @override
  Future<E> asFuture<E>([E? futureValue]) => inner.asFuture<E>(futureValue);
}

String _inputKey(Map<String, String>? headers, String? named) {
  String? key;
  for (final entry in headers?.entries ?? const <MapEntry<String, String>>[]) {
    if (entry.key.toLowerCase() == 'idempotency-key') key = entry.value;
  }
  key ??= named;
  if (key != null) {
    if (key.runes.isEmpty || key.runes.length > 256) {
      throw const FormatException(
        'Agent session run input key must have 1–256 characters',
      );
    }
    return key;
  }
  final random = Random.secure();
  return 'agent-input-${base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256))).replaceAll('=', '')}';
}
