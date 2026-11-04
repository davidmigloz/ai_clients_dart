import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

import 'responses_recovery.dart';
import 'websocket_connector_common.dart';

/// Observable state for an opted-in Responses socket recovery helper.
///
/// [events] broadcasts changes to current listeners. [lastEvent], [currentAttempt]
/// and [done] make current and final state available without a listener. Listener
/// cancellation is local and does not cancel recovery; close the owning connection
/// to stop preparation, waiting or dialing. Socket reopening does not restore
/// server conversation state or commit a previously submitted frame.
class ResponsesRecovery {
  ResponsesRecovery._();

  final StreamController<ResponsesRecoveryEvent> _events =
      StreamController<ResponsesRecoveryEvent>.broadcast();
  final Completer<ResponsesRecoveryClosed> _done = Completer();
  bool _isRecovering = false;
  bool _isClosed = false;
  int _queuedBytes = 0;
  int _queuedMessages = 0;
  ResponsesReconnectContext? _currentAttempt;
  ResponsesRecoveryEvent? _lastEvent;
  ResponsesRecoveryClosed? _closed;
  late List<ResponsesUnsentMessage> Function() _takePending;
  late void Function() _flushPending;

  /// Detaches currently pending frames in FIFO order without attempting them.
  /// The terminal [closed] report remains available independently.
  List<ResponsesUnsentMessage> takePending() => _takePending();

  /// Attempts pending frames once, after explicit application reconciliation.
  /// Throws while disconnected, after closure, or if delivery becomes unknown.
  /// New sends on an open socket are independent of the retained pending queue.
  void flushPending() => _flushPending();

  /// Recovery changes, with no replay for later subscribers.
  Stream<ResponsesRecoveryEvent> get events => _events.stream;

  /// Whether preparation, delay, handshake or FIFO flush is in progress.
  bool get isRecovering => _isRecovering;

  /// Whether this logical socket has permanently closed.
  bool get isClosed => _isClosed;

  /// Bytes of frames never handed to a socket (UTF-8 for text).
  int get queuedBytes => _queuedBytes;

  /// Number of frames which have never been handed to a socket.
  int get queuedMessages => _queuedMessages;

  /// The current or most recent attempt, including its planned delay.
  ResponsesReconnectContext? get currentAttempt => _currentAttempt;

  /// Most recent lifecycle notification, retained for late observers.
  ResponsesRecoveryEvent? get lastEvent => _lastEvent;

  /// Final report, available after permanent closure.
  ResponsesRecoveryClosed? get closed => _closed;

  /// Final never-attempted frames, in FIFO order, or an empty list while open.
  List<ResponsesUnsentMessage> get unsentMessages =>
      _closed?.unsentMessages ?? const [];

  /// Completes with the final report without waiting for event listeners.
  Future<ResponsesRecoveryClosed> get done => _done.future;

  void _emit(ResponsesRecoveryEvent event) {
    if (_isClosed) return;
    _lastEvent = event;
    _events.add(event);
  }

  void _finish(ResponsesRecoveryClosed report) {
    if (_isClosed) return;
    _closed = report;
    _lastEvent = report;
    _isClosed = true;
    _isRecovering = false;
    _queuedBytes = 0;
    _queuedMessages = 0;
    _events.add(report);
    _done.complete(report);
    // Paused/absent lifecycle listeners must never delay transport teardown.
    unawaited(_events.close());
  }

  @override
  String toString() =>
      'ResponsesRecovery(isRecovering: $isRecovering, isClosed: $isClosed, '
      'queuedMessages: $queuedMessages, queuedBytes: $queuedBytes)';
}

/// An opt-in logical WebSocket that replaces interrupted physical sockets.
///
/// Only newly unsent text or binary frames queue during recovery. The queue is a strict
/// byte bound, including its first frame (UTF-8 for text). Every record is removed just
/// before its one write attempt. A failed attempted write permanently closes
/// this helper and reports unknown delivery separately from never-attempted
/// frames. No submitted create, steer, injection or audio frame is replayed.
/// Manual queues require explicit application reconciliation and flushing.
///
/// [reconnect] must return an open socket and refresh credentials for every call.
/// It receives the preparation decision, whose maps are snapshotted before the
/// delay. A late socket returned after explicit close is disposed. [delay] and
/// [random] are optional deterministic seams; random values must be in 0..1.
/// Delays use whole milliseconds (submillisecond configuration is truncated),
/// then round the jittered value to milliseconds, following the Node helper.
class ResponsesRecoveringWebSocket implements WebSocket {
  /// Wraps an already-open socket; the initial handshake is not retried here.
  ResponsesRecoveringWebSocket(
    WebSocket socket, {
    required this.options,
    required this._reconnect,
    this._delay,
    double Function()? random,
    this.manualQueue = false,
    this.lifetimeRetries = false,
    Set<int>? recoverableCloseCodes,
    this._onDisconnect,
    this._beforeFlush,
  }) : _socket = socket,
       _protocol = socket.protocol,
       _random = random ?? Random().nextDouble,
       _recoverableCodes = Set.unmodifiable(
         recoverableCloseCodes ??
             const {1001, 1005, 1006, 1011, 1012, 1013, 1015},
       ) {
    options.validate();
    _events = StreamController<WebSocketEvent>(onListen: _listenInitial);
    recovery._takePending = _takePending;
    recovery._flushPending = _flushPending;
  }

  /// Validated retry and strict queue limits.
  final ResponsesReconnectOptions options;

  /// Retains newly unsent frames until an explicit flush or detach.
  final bool manualQueue;

  /// Applies the retry limit across the logical connection's whole lifetime.
  final bool lifetimeRetries;

  late final Set<int> _recoverableCodes;
  final void Function()? _onDisconnect;
  final void Function()? _beforeFlush;
  int _totalAttempts = 0;
  late ResponsesDeliveryUnknownException _lastDeliveryUnknown;

  /// Caller-observable recovery state and final never-attempted report.
  final ResponsesRecovery recovery = ResponsesRecovery._();

  final Future<WebSocket> Function(ResponsesReconnectDecision) _reconnect;
  final Future<void> Function(Duration)? _delay;
  final double Function() _random;
  final Queue<ResponsesUnsentMessage> _queue = Queue();
  final Set<Completer<Object?>> _waiting = {};
  late final StreamController<WebSocketEvent> _events;
  WebSocket? _socket;
  StreamSubscription<WebSocketEvent>? _subscription;
  String _protocol;
  Timer? _timer;
  int _generation = 0;
  bool _listening = false;
  bool _flushing = false;
  bool _closed = false;
  int _lastCloseCode = 1006;
  int? _lastPhysicalCloseCode;
  String? _lastCloseReason;
  Future<void>? _closeFuture;
  static final Object _cancelledSignal = Object();

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => _protocol;

  void _listenInitial() {
    if (_listening || _closed) return;
    _listening = true;
    if (_socket case final socket?) {
      try {
        _bind(socket);
      } catch (_) {
        _finish(cause: 'setup_failed');
      }
    }
  }

  void _bind(WebSocket socket) {
    final generation = ++_generation;
    _socket = socket;
    _protocol = socket.protocol;
    final subscription = socket.events.listen(
      (event) {
        if (_closed || generation != _generation) return;
        if (event case CloseReceived(:final code, :final reason)) {
          _disconnected(socket, code, reason);
        } else {
          _events.add(event);
        }
      },
      onError: (Object _, StackTrace _) {
        if (_closed || generation != _generation) return;
        // The actual following close code determines admission to recovery.
        // Retrying immediately could preempt a protocol or policy close.
        recovery._emit(
          const ResponsesRecoveryTransportError(operation: 'receive'),
        );
      },
      onDone: () {
        if (_closed || generation != _generation) return;
        _disconnected(socket, null, null);
      },
    );
    // A custom synchronous stream can close inside listen(). Its returned
    // subscription then belongs to a retired generation and must be cancelled.
    if (_closed || generation != _generation) {
      _cancelSubscription(subscription);
    } else {
      _subscription = subscription;
    }
  }

  void _disconnected(WebSocket socket, int? code, String? reason) {
    _lastPhysicalCloseCode = code;
    _lastCloseCode = code ?? 1006;
    _lastCloseReason = reason;
    _retire(socket);
    if (!_recoverableCodes.contains(_lastCloseCode)) {
      _finish(code: code, reason: reason, cause: 'nonrecoverable_close');
      return;
    }
    if (options.maxAttempts == 0) {
      _finish(code: code, reason: reason, cause: 'reconnect_disabled');
      return;
    }
    final wasRecovering = recovery.isRecovering;
    recovery._isRecovering = true;
    try {
      _onDisconnect?.call();
    } catch (_) {
      _finish(code: code, reason: reason, cause: 'preparation_failed');
      return;
    }
    if (!wasRecovering) unawaited(_recover());
  }

  void _retire(WebSocket socket) {
    ++_generation;
    _socket = null;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) _cancelSubscription(subscription);
    _disposeSocket(socket);
  }

  Future<void> _recover() async {
    final cap = options.maxDelay.inMilliseconds;
    var baseDelay = min(options.initialDelay.inMilliseconds, cap);
    if (lifetimeRetries && baseDelay > 0) {
      for (var i = 0; i < _totalAttempts && baseDelay < cap; i++) {
        baseDelay = baseDelay > cap ~/ 2 ? cap : baseDelay * 2;
      }
    }
    for (
      var interruptionAttempt = 1;
      interruptionAttempt <= options.maxAttempts;
      interruptionAttempt++
    ) {
      if (_closed) return;
      if (lifetimeRetries && _totalAttempts >= options.maxAttempts) break;
      final attempt = lifetimeRetries ? ++_totalAttempts : interruptionAttempt;
      final Duration plannedDelay;
      try {
        final jitter = _random();
        if (!jitter.isFinite || jitter < 0 || jitter > 1) {
          throw ArgumentError('Recovery random value must be in 0..1');
        }
        plannedDelay = Duration(
          milliseconds: (baseDelay * (0.75 + jitter * 0.25)).round(),
        );
        // Bound before multiplying; zero-delay runs and arbitrarily many
        // attempts must not encounter 0*Infinity or integer overflow.
        baseDelay = baseDelay > cap ~/ 2 ? cap : baseDelay * 2;
      } catch (_) {
        _finish(
          code: _lastPhysicalCloseCode,
          reason: _lastCloseReason,
          cause: 'retry_configuration_failed',
        );
        return;
      }
      final context = ResponsesReconnectContext(
        attempt: attempt,
        maxAttempts: options.maxAttempts,
        delay: plannedDelay,
        closeCode: _lastCloseCode,
        closeReason: _lastCloseReason,
      );
      recovery._currentAttempt = context;
      final ResponsesReconnectDecision decision;
      try {
        final preparation = Future<ResponsesReconnectDecision>.sync(() {
          final result = options.onReconnecting(context);
          if (result is Future<ResponsesReconnectDecision>) {
            return result.then((value) => value.snapshot());
          }
          // Capture direct callback values before a scheduled caller microtask
          // can mutate their const-compatible, caller-owned maps.
          return result.snapshot();
        });
        final result = await _orClosed(preparation);
        if (identical(result, _cancelledSignal)) return;
        decision = result! as ResponsesReconnectDecision;
      } catch (_) {
        if (!_closed) {
          _finish(
            code: _lastPhysicalCloseCode,
            reason: _lastCloseReason,
            cause: 'preparation_failed',
          );
        }
        return;
      }
      if (_closed) return;
      if (decision.isAborted) {
        _finish(
          code: _lastPhysicalCloseCode,
          reason: _lastCloseReason,
          cause: 'preparation_aborted',
        );
        return;
      }
      recovery._emit(ResponsesRecoveryReconnecting(context));
      try {
        final waited = await _orClosed(_wait(plannedDelay));
        if (identical(waited, _cancelledSignal)) return;
      } catch (_) {
        if (!_closed) {
          _finish(
            code: _lastPhysicalCloseCode,
            reason: _lastCloseReason,
            cause: 'delay_failed',
          );
        }
        return;
      }
      if (_closed) return;
      WebSocket? candidate;
      var disposed = false;
      void disposeLate(WebSocket socket) {
        if (disposed) return;
        disposed = true;
        _disposeSocket(socket);
      }

      try {
        final opening = Future<WebSocket>.sync(() => _reconnect(decision));
        // Both late success and late failure are consumed after cancellation.
        unawaited(
          opening.then((socket) {
            if (_closed) disposeLate(socket);
          }, onError: (Object _, StackTrace _) {}),
        );
        final result = await _orClosed(opening);
        if (identical(result, _cancelledSignal)) return;
        candidate = result! as WebSocket;
        if (_closed) {
          disposeLate(candidate);
          return;
        }
        _bind(candidate);
        if (_closed) return;
        if (!identical(_socket, candidate)) continue;
        if (!manualQueue && !_flush(candidate)) return;
        if (_closed) return;
        if (!identical(_socket, candidate)) continue;
        recovery._isRecovering = false;
        recovery._emit(ResponsesRecoveryReconnected(attempt));
        return;
      } catch (_) {
        if (_closed) return;
        if (candidate != null && identical(_socket, candidate)) {
          _retire(candidate);
        }
        recovery._emit(
          const ResponsesRecoveryTransportError(operation: 'handshake'),
        );
      }
    }
    if (!_closed) {
      _finish(
        code: _lastPhysicalCloseCode,
        reason: _lastCloseReason,
        cause: 'exhausted',
      );
    }
  }

  Future<Object?> _orClosed(Future<Object?> operation) {
    final completion = Completer<Object?>();
    if (_closed) {
      completion.complete(_cancelledSignal);
    } else {
      _waiting.add(completion);
    }
    // Remove completed races instead of accumulating listeners on a lifetime
    // cancellation future across successful reconnects. Late failures remain
    // consumed after the close side has already completed the race.
    unawaited(
      operation.then(
        (value) {
          if (_waiting.remove(completion)) completion.complete(value);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_waiting.remove(completion)) {
            completion.completeError(error, stackTrace);
          }
        },
      ),
    );
    return completion.future;
  }

  Future<void> _wait(Duration delay) {
    if (_delay case final wait?) return wait(delay);
    final completion = Completer<void>();
    _timer = Timer(delay, completion.complete);
    return completion.future;
  }

  void _enqueue(ResponsesUnsentMessage message) {
    if (options.maxQueueBytes == 0 ||
        _queue.length >= options.maxQueueMessages ||
        recovery.queuedBytes + message.byteLength > options.maxQueueBytes) {
      final error = ResponsesSendQueueOverflowException(
        frameBytes: message.byteLength,
        maxQueueBytes: options.maxQueueBytes,
        queuedBytes: recovery.queuedBytes,
        maxQueueMessages: options.maxQueueMessages,
        queuedMessages: _queue.length,
      );
      recovery._emit(
        ResponsesRecoveryQueueOverflow(
          frameBytes: error.frameBytes,
          maxQueueBytes: error.maxQueueBytes,
          queuedBytes: error.queuedBytes,
          maxQueueMessages: error.maxQueueMessages,
          queuedMessages: error.queuedMessages,
        ),
      );
      throw error;
    }
    _queue.add(message);
    recovery._queuedBytes += message.byteLength;
    recovery._queuedMessages = _queue.length;
  }

  bool _flush(WebSocket socket) {
    _flushing = true;
    try {
      while (!_closed && identical(_socket, socket) && _queue.isNotEmpty) {
        // Charge the never-attempted remainder even during a reentrant send.
        final next = _queue.removeFirst();
        recovery._queuedBytes -= next.byteLength;
        recovery._queuedMessages = _queue.length;
        try {
          if (next.isBinary) {
            socket.sendBytes(next.bytes);
          } else {
            socket.sendText(next.text);
          }
        } catch (_) {
          _deliveryUnknown(next.byteLength, 'flush');
          return false;
        }
      }
      return true;
    } finally {
      _flushing = false;
    }
  }

  ResponsesDeliveryUnknownException _deliveryUnknown(
    int bytes,
    String operation,
  ) {
    final error = ResponsesDeliveryUnknownException(
      frameBytes: bytes,
      operation: operation,
    );
    _lastDeliveryUnknown = error;
    recovery._emit(
      ResponsesRecoveryDeliveryUnknown(frameBytes: bytes, operation: operation),
    );
    _finish(cause: 'delivery_unknown');
    return error;
  }

  @override
  void sendText(String text) {
    if (_closed) throw WebSocketConnectionClosed();
    if (recovery.isRecovering || _flushing) {
      _enqueue(ResponsesUnsentMessage.fromText(text));
      return;
    }
    final socket = _socket;
    if (socket == null) throw WebSocketConnectionClosed();
    try {
      socket.sendText(text);
    } catch (_) {
      throw _deliveryUnknown(
        ResponsesUnsentMessage.fromText(text).byteLength,
        'send',
      );
    }
  }

  @override
  void sendBytes(Uint8List bytes) {
    if (_closed) throw WebSocketConnectionClosed();
    final frame = ResponsesUnsentMessage.fromBytes(bytes);
    if (recovery.isRecovering || _flushing) {
      _enqueue(frame);
      return;
    }
    final socket = _socket;
    if (socket == null) throw WebSocketConnectionClosed();
    try {
      socket.sendBytes(frame.bytes);
    } catch (_) {
      throw _deliveryUnknown(frame.byteLength, 'send');
    }
  }

  List<ResponsesUnsentMessage> _takePending() {
    final result = List<ResponsesUnsentMessage>.unmodifiable(_queue);
    _queue.clear();
    recovery._queuedBytes = 0;
    recovery._queuedMessages = 0;
    return result;
  }

  void _flushPending() {
    if (_flushing) throw StateError('A pending flush is already in progress.');
    if (_closed || recovery.isRecovering || _socket == null) {
      throw StateError('Pending frames require an open connection.');
    }
    _beforeFlush?.call();
    if (_closed || recovery.isRecovering || _socket == null) {
      throw StateError('Connection changed during pending reconciliation.');
    }
    final socket = _socket!;
    if (!_flush(socket)) {
      final event = recovery.lastEvent;
      if (recovery.closed?.cause == 'delivery_unknown') {
        throw _lastDeliveryUnknown;
      }
      throw StateError(
        'Connection closed during pending flush: ${event.runtimeType}.',
      );
    }
    if (_closed || !identical(_socket, socket)) {
      throw StateError('Connection changed during pending flush.');
    }
  }

  void _finish({int? code, String? reason, required String cause}) {
    if (_closed) return;
    _closed = true;
    ++_generation;
    _timer?.cancel();
    for (final waiting in _waiting) {
      waiting.complete(_cancelledSignal);
    }
    _waiting.clear();
    final socket = _socket;
    final subscription = _subscription;
    _socket = null;
    _subscription = null;
    final unsent = List<ResponsesUnsentMessage>.unmodifiable(_queue);
    _queue.clear();
    recovery._finish(
      ResponsesRecoveryClosed(
        code: code,
        reason: reason,
        cause: cause,
        unsentMessages: unsent,
      ),
    );
    _events.add(CloseReceived(code, reason ?? ''));
    unawaited(_events.close());
    if (subscription != null) _cancelSubscription(subscription);
    if (socket != null) _disposeSocket(socket);
  }

  void _cancelSubscription(StreamSubscription<WebSocketEvent> subscription) {
    unawaited(
      Future<void>.sync(subscription.cancel).catchError((Object _) {
        recovery._emit(
          const ResponsesRecoveryTransportError(operation: 'cancel'),
        );
      }),
    );
  }

  void _disposeSocket(WebSocket socket) {
    unawaited(
      Future<void>.sync(() => socket.close(1000)).catchError((Object _) {
        recovery._emit(
          const ResponsesRecoveryTransportError(operation: 'close'),
        );
      }),
    );
  }

  @override
  Future<void> close([int? code, String? reason]) {
    validateResponsesClose(code, reason);
    if (_closeFuture case final future?) return future;
    final socket = _socket;
    // Physical close is initiated explicitly below, rather than by _finish.
    _socket = null;
    _finish(code: code ?? 1000, reason: reason, cause: 'explicit_close');
    if (socket == null) return _closeFuture = Future.value();
    return _closeFuture =
        Future<void>.sync(
          () => socket.close(reason != null ? code ?? 1000 : code, reason),
        ).catchError((Object _) {
          throw WebSocketException('Responses recovery close failed.');
        });
  }

  @override
  String toString() =>
      'ResponsesRecoveringWebSocket(isClosed: $_closed, recovery: $recovery)';
}
