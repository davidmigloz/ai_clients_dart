import 'dart:async';
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../../errors/exceptions.dart';
import '../../models/live/live_client_events.dart';
import '../../models/live/live_config.dart';
import '../../models/live/live_server_events.dart';
import 'live_data_channel.dart';
import 'websocket_connector_common.dart';

export 'live_data_channel.dart';
export 'websocket_connector.dart';

/// A malformed incoming frame or invalid outgoing command.
class LiveProtocolException implements Exception {
  /// Creates a value-safe protocol diagnostic with explicit caller cause.
  const LiveProtocolException({required this.kind, this.cause});

  /// Classification of the protocol failure, without frame contents.
  final String kind;

  /// Original failure, accessible explicitly and excluded from diagnostics.
  final Object? cause;

  @override
  String toString() => 'LiveProtocolException: $kind';
}

/// A socket failure, distinct from a Live server error event.
class LiveTransportException implements Exception {
  /// Creates a value-safe transport diagnostic.
  const LiveTransportException({required this.operation, this.cause});

  /// Operation which failed, without URL, header, frame or close-reason values.
  final String operation;

  /// Original failure, excluded from automatic diagnostics.
  final Object? cause;

  @override
  String toString() => 'LiveTransportException: $operation failed';
}

/// Opening frames exceeded the configured bounded event capacity.
class LiveEventBufferOverflowException implements Exception {
  /// Creates an explicit overflow result instead of silently dropping frames.
  const LiveEventBufferOverflowException(this.maxBufferedEvents);

  /// Maximum events and errors retained before the first subscriber.
  final int maxBufferedEvents;

  @override
  String toString() =>
      'LiveEventBufferOverflowException: opening buffer exceeded '
      '$maxBufferedEvents events';
}

/// The transport ended without a confirming session.closed event.
class LiveUnconfirmedCloseException implements Exception {
  /// Creates an unconfirmed finalization result.
  const LiveUnconfirmedCloseException();

  @override
  String toString() =>
      'LiveUnconfirmedCloseException: finalization unconfirmed';
}

/// Shared lifecycle of a primary, fork or trusted sideband Live connection.
///
/// One reader broadcasts received events to concurrent application taps. Early
/// events/errors are retained for the first listener only. Later listeners see
/// future events, with no history replay. A server error remains an ordinary
/// event. There is no reconnect, startup, audio, command or external action replay.
sealed class LiveConnection {
  /// Wraps a primary socket or a caller-authored data-channel adapter.
  ///
  /// With [ownsSocket] false, cleanup detaches this reader without closing the
  /// caller's socket/media. The adapter must implement the WebSocket event seam.
  factory LiveConnection.primary(
    WebSocket socket, {
    bool ownsSocket = true,
    int maxBufferedEvents = 1024,
    bool sessionAlreadyStarted = false,
    LiveSessionResourceParam? initialSession,
    Future<void>? abortTrigger,
    String? correlationId,
  }) => LivePrimaryConnection(
    socket,
    sessionAlreadyStarted: sessionAlreadyStarted,
    initialSession: initialSession,
    ownsSocket: ownsSocket,
    maxBufferedEvents: maxBufferedEvents,
    abortTrigger: abortTrigger,
    correlationId: correlationId,
  );

  /// Wraps a trusted sideband socket without sending startup or audio.
  factory LiveConnection.sideband(
    WebSocket socket, {
    bool ownsSocket = true,
    int maxBufferedEvents = 1024,
    LiveSessionResourceParam? initialSession,
    Future<void>? abortTrigger,
    String? correlationId,
  }) => LiveSidebandConnection(
    socket,
    initialSession: initialSession,
    ownsSocket: ownsSocket,
    maxBufferedEvents: maxBufferedEvents,
    abortTrigger: abortTrigger,
    correlationId: correlationId,
  );

  /// Wraps a fork socket; startup must use the distinct stored-session command.
  factory LiveConnection.fork(
    WebSocket socket, {
    bool ownsSocket = true,
    int maxBufferedEvents = 1024,
    LiveSessionResourceParam? initialSession,
    Future<void>? abortTrigger,
    String? correlationId,
  }) => LiveForkConnection(
    socket,
    ownsSocket: ownsSocket,
    maxBufferedEvents: maxBufferedEvents,
    initialSession: initialSession,
    abortTrigger: abortTrigger,
    correlationId: correlationId,
  );

  /// Borrows an already-started typed media data channel, owning only its tap.
  ///
  /// Caller signaling, media and other channel listeners remain caller-owned.
  /// No startup or audio append is admitted and cleanup cancels only this reader.
  static LivePrimaryConnection dataChannel(
    LiveDataChannel channel, {
    int maxBufferedEvents = 1024,
    LiveSessionResourceParam? initialSession,
    Future<void>? abortTrigger,
    String? correlationId,
  }) => LivePrimaryConnection(
    LiveDataChannelSocket(channel),
    ownsSocket: false,
    sessionAlreadyStarted: true,
    maxBufferedEvents: maxBufferedEvents,
    initialSession: initialSession,
    abortTrigger: abortTrigger,
    correlationId: correlationId,
  );

  LiveConnection._(
    this._socket,
    this._channel,
    this._correlationId, {
    required this.ownsSocket,
    required this.maxBufferedEvents,
    LiveSessionResourceParam? initialSession,
    Future<void>? abortTrigger,
  }) {
    if (!maxBufferedEvents.isFinite || maxBufferedEvents < 1) {
      throw ArgumentError('maxBufferedEvents must be positive.');
    }
    initialSession?.validate();
    _session = initialSession;
    _events = StreamController<LiveServerEvent>.broadcast(onListen: _drain);
    _reader = _socket.events.listen(
      _receive,
      onError: _receiveError,
      onDone: _peerDone,
    );
    if (abortTrigger != null) {
      unawaited(
        abortTrigger.then<void>(
          (_) => _abort(),
          onError: (Object _, StackTrace _) => _abort(),
        ),
      );
    }
  }

  final WebSocket _socket;
  final String _channel;
  final String? _correlationId;

  /// Whether cleanup owns and closes this socket.
  final bool ownsSocket;

  /// Capacity of the opening event/error buffer.
  final int maxBufferedEvents;
  late final StreamController<LiveServerEvent> _events;
  StreamSubscription<WebSocketEvent>? _reader;
  final List<_BufferedLiveEvent> _opening = [];
  final Completer<void> _done = Completer();
  final Completer<void> _startedSignal = Completer();
  final Completer<void> _finalSignal = Completer();
  LiveSessionStarted? _started;
  LiveSessionResourceParam? _session;
  LiveSessionCreateParams? _startupConfiguration;
  LiveSessionClosed? _final;
  double? _latestSeconds;
  bool _hasListened = false;
  bool _closed = false;
  bool _closingSession = false;
  bool _eventsClosed = false;
  LiveEventBufferOverflowException? _overflow;
  Future<void>? _shutdownFuture;
  Future<LiveSessionClosed>? _closeSessionFuture;
  int? _closeCode;
  String? _closeReason;

  /// Broadcast server events, including ordinary Live error events.
  Stream<LiveServerEvent> get events => _events.stream;

  /// Completes after reader/owned transport cleanup, regardless of listeners.
  Future<void> get done => _done.future;

  /// Whether local cleanup began or the peer closed the transport.
  bool get isClosed => _closed;

  /// Whether finalization has been requested or confirmed.
  bool get isClosing => _closingSession;

  /// True only after receiving session.closed, never from a socket close.
  bool get isFinalized => _final != null;

  /// Latest cumulative seconds, replaced rather than summed on each snapshot.
  double? get latestUsageSeconds => _latestSeconds;

  /// The confirmed final event, with its original final snapshot and reason.
  LiveSessionClosed? get finalEvent => _final;

  /// Latest primary or fork startup acknowledgment, if received.
  LiveSessionStarted? get startedEvent => _started;

  /// Latest received resolved session, or a supplied known initial snapshot.
  LiveSessionResourceParam? get currentSession => _session;

  bool get _canFinalize => true;

  /// Actual peer close code, if a close frame was observed.
  int? get closeCode => _closeCode;

  /// Actual peer reason, explicitly accessible and excluded from diagnostics.
  String? get closeReason => _closeReason;

  void _receive(WebSocketEvent frame) {
    if (_closed && frame is! CloseReceived) return;
    switch (frame) {
      case TextDataReceived(:final text):
        final Object? decoded;
        try {
          decoded = jsonDecode(text);
        } catch (error) {
          _emit(
            _BufferedLiveEvent.error(
              LiveProtocolException(kind: 'invalid_json', cause: error),
            ),
          );
          return;
        }
        if (decoded is! Map<String, dynamic>) {
          _emit(
            const _BufferedLiveEvent.error(
              LiveProtocolException(kind: 'non_object'),
            ),
          );
          return;
        }
        final LiveServerEvent event;
        try {
          event = LiveServerEvent.fromJson(decoded)
            ..validateForChannel(_channel == 'fork' ? 'primary' : _channel);
        } catch (error) {
          _emit(
            _BufferedLiveEvent.error(
              LiveProtocolException(kind: 'invalid_event', cause: error),
            ),
          );
          return;
        }
        if (event is LiveSessionStarted) {
          _started = event;
          _session = event.session;
          if (!_startedSignal.isCompleted) _startedSignal.complete();
        }
        if (event is LiveSessionUpdated) _session = event.session;
        if (event is LiveSessionUsageUpdated) {
          _latestSeconds = event.usage.seconds;
        }
        if (event is LiveSessionClosed) {
          _final = event;
          _session = event.session;
          _latestSeconds = event.usage.seconds;
          _closingSession = true;
          if (!_finalSignal.isCompleted) _finalSignal.complete();
        }
        _emit(_BufferedLiveEvent.event(event));
      case BinaryDataReceived():
        _emit(
          const _BufferedLiveEvent.error(LiveProtocolException(kind: 'binary')),
        );
      case CloseReceived(:final code, :final reason):
        _closeCode = code;
        _closeReason = reason;
        _peerDone();
    }
  }

  void _receiveError(Object error, StackTrace stackTrace) {
    if (_closed) return;
    _emit(
      _BufferedLiveEvent.error(
        LiveTransportException(operation: 'receive', cause: error),
        stackTrace,
      ),
    );
    _beginCleanup(closeSocket: true);
  }

  void _peerDone() {
    if (_closed) return;
    _beginCleanup(closeSocket: false);
  }

  void _abort() {
    if (_closed) return;
    _emit(
      _BufferedLiveEvent.error(
        AbortedException(
          message: 'Live connection aborted.',
          correlationId: _correlationId,
          timestamp: DateTime.now(),
          redactDiagnostics: true,
        ),
      ),
    );
    _beginCleanup(closeSocket: true);
  }

  void _beginCleanup({required bool closeSocket}) {
    unawaited(_shutdown(closeSocket: closeSocket).catchError((Object _) {}));
  }

  void _drain() {
    if (_hasListened || _eventsClosed) return;
    _hasListened = true;
    _opening
      ..forEach(_publish)
      ..clear();
    if (_overflow case final error?) _events.addError(error);
    if (_done.isCompleted) _finishEvents();
  }

  void _publish(_BufferedLiveEvent entry) {
    if (_eventsClosed) return;
    if (entry.error case final error?) {
      _events.addError(error, entry.stackTrace);
    } else {
      _events.add(entry.event!);
    }
  }

  void _emit(_BufferedLiveEvent entry) {
    if (_eventsClosed) return;
    if (_hasListened) {
      _publish(entry);
    } else if (_opening.length < maxBufferedEvents) {
      _opening.add(entry);
    } else {
      _overflow ??= LiveEventBufferOverflowException(maxBufferedEvents);
      _beginCleanup(closeSocket: true);
    }
  }

  void _ensureWritable({bool allowClosing = false}) {
    if (_closed) throw StateError('Live connection is closed.');
    if (_closingSession && !allowClosing) {
      throw StateError('Live session is closing.');
    }
  }

  void _write(LiveClientEvent command, {bool allowClosing = false}) {
    _ensureWritable(allowClosing: allowClosing);
    final String text;
    try {
      command.validate();
      _validateKnownSession(command);
      text = jsonEncode(command.toJson());
    } catch (error) {
      throw LiveProtocolException(kind: 'invalid_command', cause: error);
    }
    // Track closure before sendText, which may synchronously emit session.closed.
    if (command is LiveSessionCloseParam) _closingSession = true;
    try {
      _socket.sendText(text);
    } catch (error) {
      _beginCleanup(closeSocket: true);
      throw LiveTransportException(operation: 'send', cause: error);
    }
  }

  void _validateKnownSession(LiveClientEvent command) {
    final snapshot = _session;
    final known = snapshot != null || _startupConfiguration != null;
    if (!known) return;
    final mode = snapshot != null
        ? snapshot.delegation?.type ?? 'client'
        : _startupConfiguration?.delegation?.type ?? 'client';
    if (command is LiveForkSessionStartEvent && snapshot != null) {
      command.session.validateForSession(snapshot);
    }
    if (command is LiveSessionUpdateParam) {
      if (snapshot != null) {
        command.session.validateForSession(snapshot);
      } else if (command.session.hasDelegation &&
          (command.session.delegation?.type ?? 'client') != mode) {
        throw const FormatException(
          'LiveSessionUpdateParams.delegation: delegation owner is immutable',
        );
      }
    }
    if (mode == 'client' &&
        (command is LiveResponseCreateParam ||
            command is LiveResponseItemCreateParam)) {
      throw const FormatException(
        'Live command: Responses delegation required',
      );
    }
    final delegationId = switch (command) {
      LiveInstructionsAppendParam(:final delegationId) => delegationId,
      LiveThinkingAppendParam(:final delegationId) => delegationId,
      LiveCommentaryAppendParam(:final delegationId) => delegationId,
      _ => null,
    };
    if (mode == 'responses' && delegationId != null) {
      throw const FormatException(
        'Live command.delegation_id: client delegation required',
      );
    }
  }

  /// Requests session finalization, waits for session.closed, then releases this
  /// reader and an owned transport. An immediate peer event cannot be missed.
  ///
  /// [timeout] bounds final-event draining. [abortTrigger] stops waiting and
  /// releases local resources without claiming finalization. A premature peer
  /// close throws [LiveUnconfirmedCloseException]. Repeated calls share one
  /// finalization request; new work is rejected once closing begins.
  Future<LiveSessionClosed> closeSession({
    LiveSessionCloseParam? event,
    Duration timeout = const Duration(seconds: 30),
    Future<void>? abortTrigger,
  }) {
    _validateTimeout(timeout);
    if (_closeSessionFuture case final future?) return future;
    if (_final == null && !_canFinalize) {
      throw StateError(
        'Live session has not started; use close for local cleanup.',
      );
    }
    final command = (event ?? LiveSessionCloseParam())..validate();
    final sendNeeded = _final == null && !_closingSession;
    _closingSession = true;
    return _closeSessionFuture = _finalize(
      command,
      timeout,
      abortTrigger,
      sendNeeded,
    );
  }

  Future<LiveSessionClosed> _finalize(
    LiveSessionCloseParam event,
    Duration timeout,
    Future<void>? abortTrigger,
    bool sendNeeded,
  ) async {
    try {
      await _checkAbort(abortTrigger);
      if (_final == null) {
        if (_closed) throw const LiveUnconfirmedCloseException();
        if (sendNeeded) _write(event, allowClosing: true);
        await _wait(_finalSignal.future, timeout, abortTrigger, 'finalization');
      }
      return _final ?? (throw const LiveUnconfirmedCloseException());
    } finally {
      await close();
    }
  }

  /// Closes the local reader and owned transport without requesting session
  /// finalization. Borrowed adapters and their media stay caller-owned.
  Future<void> close({
    int? code = 1000,
    String? reason,
    Duration timeout = const Duration(seconds: 5),
  }) {
    validateLiveClose(code, reason);
    _validateTimeout(timeout);
    return _shutdown(
      closeSocket: true,
      code: code,
      reason: reason,
      timeout: timeout,
    );
  }

  Future<void> _shutdown({
    required bool closeSocket,
    int? code = 1000,
    String? reason,
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (_shutdownFuture case final future?) return future;
    _closed = true;
    if (!_startedSignal.isCompleted) _startedSignal.complete();
    if (!_finalSignal.isCompleted) _finalSignal.complete();
    return _shutdownFuture = _cleanup(closeSocket, code, reason, timeout);
  }

  Future<void> _cleanup(
    bool closeSocket,
    int? code,
    String? reason,
    Duration timeout,
  ) async {
    Object? failure;
    final clock = Stopwatch()..start();
    Future<void> bounded(Future<void> operation) {
      final remaining = timeout - clock.elapsed;
      if (remaining <= Duration.zero) {
        unawaited(operation.catchError((Object _) {}));
        return Future.error(TimeoutException('Live cleanup timed out.'));
      }
      return operation.timeout(remaining);
    }

    try {
      if (closeSocket && ownsSocket) {
        await bounded(_socket.close(code, reason));
      }
    } catch (error) {
      failure = error;
    } finally {
      try {
        if (_reader != null) await bounded(_reader!.cancel());
      } catch (error) {
        failure ??= error;
      }
      _reader = null;
      if (!_done.isCompleted) _done.complete();
      if (_hasListened) _finishEvents();
    }
    if (failure != null) {
      throw LiveTransportException(operation: 'close', cause: failure);
    }
  }

  void _finishEvents() {
    if (_eventsClosed) return;
    _eventsClosed = true;
    unawaited(_events.close());
  }

  @override
  String toString() =>
      'LiveConnection(channel: $_channel, '
      'isClosed: $isClosed, isFinalized: $isFinalized)';
}

/// A primary writer with explicit startup and acknowledgment gating.
final class LivePrimaryConnection extends LiveConnection {
  /// Reads a primary socket immediately. Borrowed adapters set ownsSocket false.
  /// For a confirmed HTTP-started media data channel, explicitly set
  /// sessionAlreadyStarted true; start is then forbidden and no startup is sent.
  LivePrimaryConnection(
    WebSocket socket, {
    super.ownsSocket = true,
    super.maxBufferedEvents = 1024,
    this.sessionAlreadyStarted = false,
    super.initialSession,
    super.abortTrigger,
    String? correlationId,
  }) : super._(socket, 'primary', correlationId);

  /// Caller confirms that HTTP signaling already started this media session.
  final bool sessionAlreadyStarted;
  @override
  bool get _canFinalize =>
      sessionAlreadyStarted || (_startupSent && _started != null);

  bool _startupSent = false;

  /// Writes one of the 11 primary commands. Startup is sent exactly once;
  /// ordinary work waits for the session.started acknowledgment.
  void send(LiveClientEvent event) {
    _ensureWritable();
    if (sessionAlreadyStarted && event is LiveInputAudioAppendEvent) {
      throw const LiveProtocolException(kind: 'media_audio_append');
    }
    if (event is LiveForkSessionStartEvent) {
      throw const LiveProtocolException(kind: 'fork_start_on_primary');
    }
    if (event is LiveSessionStartEvent) {
      if (_startupSent || sessionAlreadyStarted) {
        throw StateError(
          'Live startup was already sent or media session already started.',
        );
      }
      _startupConfiguration = event.session;
      _startupSent = true;
      _write(event);
      return;
    }
    if (!sessionAlreadyStarted && (!_startupSent || _started == null)) {
      throw StateError('Live session has not started.');
    }
    _write(event);
  }

  /// Explicitly sends session.start and waits for session.started before work.
  Future<LiveSessionStarted> start(
    LiveSessionStartEvent event, {
    Duration timeout = const Duration(seconds: 30),
    Future<void>? abortTrigger,
  }) async {
    _validateTimeout(timeout);
    try {
      await _checkAbort(abortTrigger);
      send(event);
      await _wait(_startedSignal.future, timeout, abortTrigger, 'startup');
      return _started ??
          (throw const LiveTransportException(operation: 'startup_closed'));
    } on AbortedException {
      await close();
      rethrow;
    } on LiveTransportException {
      await close();
      rethrow;
    }
  }
}

/// A stored-session fork writer with distinct startup and acknowledgment gating.
///
/// All ordinary commands reuse the primary protocol after session.started. No
/// application state, audio, external actions or startup are replayed implicitly.
final class LiveForkConnection extends LiveConnection {
  /// Reads a fork socket immediately without sending startup.
  LiveForkConnection(
    WebSocket socket, {
    super.ownsSocket = true,
    super.maxBufferedEvents = 1024,
    super.initialSession,
    super.abortTrigger,
    String? correlationId,
  }) : super._(socket, 'fork', correlationId);

  bool _startupSent = false;
  @override
  bool get _canFinalize => _startupSent && _started != null;

  /// Sends one of the 11 fork commands; a primary startup is always rejected.
  void send(LiveClientEvent event) {
    _ensureWritable();
    if (event is LiveSessionStartEvent) {
      throw const LiveProtocolException(kind: 'primary_start_on_fork');
    }
    if (event is LiveForkSessionStartEvent) {
      if (_startupSent) throw StateError('Live fork startup was already sent.');
      event.validate();
      final overrides = event.session.toJson();
      if (overrides.keys.any(
        (key) => !const {'audio', 'delegation', 'store'}.contains(key),
      )) {
        throw const LiveProtocolException(kind: 'unsupported_fork_override');
      }
      final audio = event.session.audio?.toJson();
      if (audio != null && audio.keys.any((key) => key != 'format')) {
        throw const LiveProtocolException(
          kind: 'unsupported_fork_audio_override',
        );
      }
      _validateKnownSession(event);
      _startupSent = true;
      _write(event);
      return;
    }
    if (!_startupSent || _started == null) {
      throw StateError('Live fork session has not started.');
    }
    _write(event);
  }

  /// Explicitly starts the fork and waits for its new session acknowledgment.
  Future<LiveSessionStarted> start(
    LiveForkSessionStartEvent event, {
    Duration timeout = const Duration(seconds: 30),
    Future<void>? abortTrigger,
  }) async {
    _validateTimeout(timeout);
    try {
      await _checkAbort(abortTrigger);
      send(event);
      await _wait(_startedSignal.future, timeout, abortTrigger, 'fork_startup');
      return _started ??
          (throw const LiveTransportException(
            operation: 'fork_startup_closed',
          ));
    } on AbortedException {
      await close();
      rethrow;
    } on LiveTransportException {
      await close();
      rethrow;
    }
  }
}

/// A sideband writer whose public send type excludes startup and audio append.
final class LiveSidebandConnection extends LiveConnection {
  /// Reads an open sideband immediately; borrowed adapters retain socket ownership.
  /// An optional initialSession supplies a known resolved delegation mode.
  LiveSidebandConnection(
    WebSocket socket, {
    super.ownsSocket = true,
    super.maxBufferedEvents = 1024,
    super.initialSession,
    super.abortTrigger,
    String? correlationId,
  }) : super._(socket, 'sideband', correlationId);

  /// Writes one of the nine commands on an already-running trusted sideband.
  void send(LiveSidebandClientEvent event) => _write(event);
}

class _BufferedLiveEvent {
  const _BufferedLiveEvent.event(this.event) : error = null, stackTrace = null;
  const _BufferedLiveEvent.error(this.error, [this.stackTrace]) : event = null;
  final LiveServerEvent? event;
  final Object? error;
  final StackTrace? stackTrace;
}

Future<void> _checkAbort(Future<void>? trigger) async {
  if (trigger == null) return;
  var aborted = false;
  unawaited(
    trigger.then<void>(
      (_) => aborted = true,
      onError: (Object _, StackTrace _) => aborted = true,
    ),
  );
  await Future<void>.value();
  if (aborted) {
    throw const AbortedException(
      message: 'Live operation aborted.',
      redactDiagnostics: true,
    );
  }
}

Future<void> _wait(
  Future<void> signal,
  Duration timeout,
  Future<void>? trigger,
  String operation,
) async {
  final aborted = Completer<void>();
  if (trigger != null) {
    unawaited(
      trigger.then<void>(
        (_) => aborted.complete(),
        onError: (Object _, StackTrace _) => aborted.complete(),
      ),
    );
  }
  final outcome =
      await Future.any<bool>([
        signal.then((_) => false),
        aborted.future.then((_) => true),
      ]).timeout(
        timeout,
        onTimeout: () =>
            throw LiveTransportException(operation: '${operation}_timeout'),
      );
  if (outcome) {
    throw const AbortedException(
      message: 'Live operation aborted.',
      redactDiagnostics: true,
    );
  }
}

void _validateTimeout(Duration timeout) {
  if (!timeout.inMicroseconds.isFinite || timeout <= Duration.zero) {
    throw ArgumentError('timeout must be finite and positive.');
  }
}
