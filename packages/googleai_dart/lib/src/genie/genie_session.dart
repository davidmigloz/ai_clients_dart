import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:web_socket/web_socket.dart';

import '../errors/exceptions.dart';
import 'genie_events.dart';

enum _SessionState { open, completing, terminal, detached, failed }

/// A dedicated WebSocket session for one Genie 4 interaction.
///
/// Send one [GenieWorldSetup] before other input. Call [complete] or [cancel]
/// to stop server generation. [detach] only closes the local transport.
class GenieSession {
  /// The server interaction this connection was opened against.
  final String id;

  final WebSocket _socket;
  final String _credential;
  final Duration _completionTimeout;
  final _pending = Queue<GenieServerEvent>();
  late final StreamSubscription<WebSocketEvent> _subscription;
  StreamController<GenieServerEvent>? _receiver;
  _SessionState _state = _SessionState.open;
  GenieConnectionException? _failure;
  GenieTerminalEvent? _terminalEvent;
  Completer<void>? _completion;
  Future<void>? _closing;
  bool _worldStarted = false;
  bool _drainScheduled = false;

  GenieSession._(
    this._socket,
    this.id,
    this._credential,
    this._completionTimeout,
  );

  /// Attaches to a socket and sends the initial live interaction event.
  @internal
  static GenieSession attach(
    WebSocket socket,
    String id,
    String credential,
    Duration completionTimeout,
  ) {
    final session = GenieSession._(socket, id, credential, completionTimeout);
    session._subscription = socket.events.listen(
      session._onSocketEvent,
      onError: (Object _, StackTrace stackTrace) => session._fail(
        GenieConnectionException(
          message: 'The Genie WebSocket transport failed.',
          stackTrace: stackTrace,
        ),
      ),
      onDone: () => session._fail(
        const GenieConnectionException(
          message: 'The Genie WebSocket closed before a terminal event.',
        ),
      ),
    );
    session._write({'event_type': 'interaction.connect', 'id': id});
    return session;
  }

  bool get _canRead =>
      _state == _SessionState.open || _state == _SessionState.completing;

  /// Sends a single input event.
  void send(GenieInputEvent event) => _sendInputs([event], batch: false);

  /// Sends several input events as one ordered WebSocket batch.
  void sendBatch(List<GenieInputEvent> events) =>
      _sendInputs(events, batch: true);

  /// Sends a mid-session text prompt.
  void sendText(String text) => send(GenieTextInput(text));

  void _sendInputs(List<GenieInputEvent> events, {required bool batch}) {
    if (_state != _SessionState.open) {
      _throwControlError();
    }
    if (events.isEmpty) {
      throw ArgumentError('A Genie input batch must be nonempty.');
    }
    var started = _worldStarted;
    final payload = <Map<String, dynamic>>[];
    for (final event in events) {
      if (event is GenieWorldSetup) {
        if (started) {
          throw StateError('The Genie world has already been initialized.');
        }
        started = true;
      } else if (!started) {
        throw StateError(
          'Initialize the Genie world before sending other input.',
        );
      }
      payload.add(event.toJson());
    }
    _write(batch ? {'events': payload} : payload.single);
    _worldStarted = started;
  }

  /// Receives events in wire order. Only one subscription may be active at a time.
  /// Cancelling a subscription leaves the remote interaction running.
  Stream<GenieServerEvent> receive() {
    late final StreamController<GenieServerEvent> receiver;
    receiver = StreamController<GenieServerEvent>(
      sync: true,
      onListen: () {
        if (_receiver != null) {
          scheduleMicrotask(() {
            receiver.addError(
              StateError('Only one Genie receiver may be active at a time.'),
            );
            unawaited(receiver.close());
          });
          return;
        }
        _receiver = receiver;
        _scheduleDrain();
      },
      onResume: _scheduleDrain,
      onCancel: () {
        if (identical(_receiver, receiver)) _receiver = null;
      },
    );
    return receiver.stream;
  }

  /// Asks the server to finish the interaction and awaits its completion event.
  /// A timeout leaves the connection open so a late completion can arrive.
  Future<void> complete({Duration? timeout}) {
    if (_terminalEvent?.completed ?? false) return Future.value();
    _ensureControlAllowed();
    final wait = timeout ?? _completionTimeout;
    if (wait <= Duration.zero) throw ArgumentError('Timeout must be positive.');
    final existing = _completion;
    if (existing != null) return _waitForCompletion(existing, wait);

    final completion = _completion = Completer<void>();
    final result = _waitForCompletion(completion, wait);
    _state = _SessionState.completing;
    try {
      _write({'event_type': 'interaction.complete'});
    } on GenieConnectionException {
      // The failed send already settled the completion future.
    }
    return result;
  }

  Future<void> _waitForCompletion(
    Completer<void> completion,
    Duration timeout,
  ) => completion.future.timeout(
    timeout,
    onTimeout: () {
      throw const GenieConnectionException(
        message: 'Timed out awaiting Genie completion.',
      );
    },
  );

  /// Aborts server generation and closes the local transport.
  Future<void> cancel() async {
    if (_state == _SessionState.terminal) return;
    _ensureControlAllowed();
    _write({'event_type': 'interaction.cancel'});
    _finish(_SessionState.terminal);
    await _closeSocket();
  }

  /// Disconnects the local transport and discards unread events.
  /// This does not stop server generation or billing.
  Future<void> detach() async {
    if (_canRead) {
      try {
        _socket.sendText('{"event_type":"interaction.disconnect"}');
      } catch (_) {
        // The disconnect frame is best-effort when the transport has failed.
      }
      _pending.clear();
      _finish(_SessionState.detached);
    }
    await _closeSocket();
  }

  void _ensureControlAllowed() {
    if (!_canRead) _throwControlError();
  }

  Never _throwControlError() {
    final failure = _failure;
    if (failure != null) throw failure;
    throw StateError('The Genie session has ended.');
  }

  void _write(Map<String, dynamic> payload) {
    try {
      _socket.sendText(jsonEncode(payload));
    } catch (_, stackTrace) {
      final error = GenieConnectionException(
        message: 'Unable to send on the Genie WebSocket.',
        stackTrace: stackTrace,
      );
      _fail(error);
      throw error;
    }
  }

  void _onSocketEvent(WebSocketEvent event) {
    if (!_canRead) return;
    try {
      switch (event) {
        case TextDataReceived(:final text):
          _onFrame(text);
        case BinaryDataReceived(:final data):
          _onFrame(utf8.decode(data));
        case CloseReceived(:final code):
          _fail(
            GenieConnectionException(
              message: 'The Genie WebSocket closed before a terminal event.',
              closeCode: code,
            ),
          );
      }
    } catch (_, stackTrace) {
      _fail(
        GenieConnectionException(
          message: 'The Genie server sent an invalid event frame.',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void _onFrame(String text) {
    final decoded = jsonDecode(text);
    final events = switch (decoded) {
      {'events': final List<dynamic> batch} => batch,
      _ => [decoded],
    };
    for (final raw in events) {
      final json = raw as Map<String, dynamic>;
      final event = GenieServerEvent.fromJson({
        ...json,
        if (json['error'] != null) 'error': _redactDiagnostic(json['error']),
        if (json['status'] is Map) 'status': _redactDiagnostic(json['status']),
      });
      _pending.add(event);
      if (event is GenieTerminalEvent) {
        _terminalEvent = event;
        _finish(_SessionState.terminal);
        return;
      }
    }
    _scheduleDrain();
  }

  Object? _redactDiagnostic(Object? value) => switch (value) {
    final String text => text.replaceAll(_credential, '[redacted]'),
    final Map<String, dynamic> map => map.map(
      (key, value) => MapEntry(key, _redactDiagnostic(value)),
    ),
    final List<Object?> list => list.map(_redactDiagnostic).toList(),
    _ => value,
  };

  void _fail(GenieConnectionException error) {
    if (!_canRead) return;
    _failure = error;
    _finish(_SessionState.failed);
  }

  void _finish(_SessionState state) {
    _state = state;
    final completion = _completion;
    if (completion != null && !completion.isCompleted) {
      if (_terminalEvent?.completed ?? false) {
        completion.complete();
      } else {
        completion.completeError(
          _failure ??
              const GenieConnectionException(
                message: 'The Genie session ended without completion.',
              ),
        );
      }
    }
    _scheduleDrain();
    unawaited(_closeSocket());
  }

  void _scheduleDrain() {
    if (_receiver == null || _drainScheduled) return;
    _drainScheduled = true;
    scheduleMicrotask(() {
      _drainScheduled = false;
      final receiver = _receiver;
      if (receiver == null || receiver.isClosed || receiver.isPaused) return;
      // Keep unread events in the session so detach can discard them even
      // while the subscription is paused.
      while (_pending.isNotEmpty &&
          identical(_receiver, receiver) &&
          !receiver.isPaused) {
        receiver.add(_pending.removeFirst());
      }
      if (!_canRead && _pending.isEmpty && identical(_receiver, receiver)) {
        final failure = _failure;
        if (failure != null) receiver.addError(failure, failure.stackTrace);
        unawaited(receiver.close());
      }
    });
  }

  Future<void> _closeSocket() => _closing ??= _closeTransport();

  Future<void> _closeTransport() async {
    try {
      await _socket.close();
    } catch (_) {
      // A closed transport already has the desired state.
    } finally {
      await _subscription.cancel();
    }
  }
}
