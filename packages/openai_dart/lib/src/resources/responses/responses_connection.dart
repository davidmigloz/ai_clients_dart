import 'dart:async';
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../../models/responses/create_response_request.dart';
import '../../models/responses/websocket/responses_create_event.dart';
import '../../models/responses/websocket/responses_server_event.dart';
import '../../models/responses/websocket/responses_steer_event.dart';
import 'websocket_connector_common.dart';

export 'websocket_connector.dart';

/// A malformed incoming or unserializable outgoing Responses WebSocket frame.
///
/// The frame's contents are deliberately excluded from diagnostics. Incoming
/// failures appear as errors on [ResponsesConnection.events]; they do not turn
/// into a response completion or close an otherwise usable connection. Outgoing
/// serialization failures are thrown before any socket write.
class ResponsesProtocolException implements Exception {
  /// Creates an identifiable protocol error without retaining a payload.
  const ResponsesProtocolException({required this.kind});

  /// Classification: `binary`, `invalid_json`, `non_object`, `invalid_event`,
  /// `invalid_create`, or `invalid_steer`.
  final String kind;

  @override
  String toString() => 'ResponsesProtocolException: $kind';
}

/// A Responses WebSocket socket failure, with redacted diagnostics.
class ResponsesTransportException implements Exception {
  /// Creates a redacted failure at the specified operation.
  const ResponsesTransportException({required this.operation});

  /// The failed operation: `receive`, `send`, `close`, or `cancel`.
  final String operation;

  @override
  String toString() => 'ResponsesTransportException: $operation failed';
}

/// The opening event buffer filled before the first subscriber attached.
///
/// Retained frames are delivered in order followed by this error and stream
/// completion. The socket is closed rather than silently dropping a frame.
class ResponsesEventBufferOverflowException implements Exception {
  /// Creates an overflow error for the configured event capacity.
  const ResponsesEventBufferOverflowException(this.maxBufferedEvents);

  /// Maximum number of retained events and errors before the first listener.
  final int maxBufferedEvents;

  @override
  String toString() =>
      'ResponsesEventBufferOverflowException: opening buffer exceeded '
      '$maxBufferedEvents events';
}

/// A caller-owned, persistent Responses WebSocket connection.
///
/// One socket reader emits interleaved lanes on a broadcast [events] stream.
/// Response completion and server error messages leave the socket open. A
/// listener's cancellation removes only that listener; explicitly await [close]
/// to release the transport. This connection does not automatically reconnect,
/// replay requests, queue sends, or cancel a model response.
class ResponsesConnection {
  /// Wraps an already-open socket and starts reading it immediately.
  ///
  /// Before the first event subscriber, up to [maxBufferedEvents] events or
  /// errors are retained. An overflow closes the socket with an observable
  /// [ResponsesEventBufferOverflowException]. Early events survive an early
  /// socket close and can still be read by the first subscriber afterward.
  ResponsesConnection(
    this._socket, {
    this.maxBufferedEvents = 1024,
    this.beta = false,
  }) {
    if (maxBufferedEvents <= 0) {
      throw ArgumentError.value(
        maxBufferedEvents,
        'maxBufferedEvents',
        'must be positive',
      );
    }
    _eventController = StreamController<ResponsesServerEvent>.broadcast(
      onListen: _drainOpeningBuffer,
    );
    _subscription = _socket.events.listen(
      _handleSocketEvent,
      onError: _handleSocketError,
      onDone: _handleSocketDone,
    );
  }

  final WebSocket _socket;

  /// Capacity of the initial event/error buffer.
  final int maxBufferedEvents;

  /// Whether this connection was opened with the beta multi-agent handshake.
  final bool beta;

  late final StreamController<ResponsesServerEvent> _eventController;
  StreamSubscription<WebSocketEvent>? _subscription;
  final List<_BufferedResponsesEvent> _openingBuffer = [];
  final Completer<void> _done = Completer();
  bool _hasListened = false;
  bool _closed = false;
  bool _eventStreamClosed = false;
  int? _closeCode;
  String? _closeReason;
  ResponsesEventBufferOverflowException? _overflow;
  Future<void>? _shutdownFuture;

  /// Interleaved server envelopes, including their optional `streamId`.
  ///
  /// The first subscriber receives the opening buffer. After it attaches,
  /// events are broadcast only to active subscribers, with no history replay
  /// for later listeners. Protocol/transport failures are stream errors;
  /// [ResponsesErrorEvent] is an ordinary server message.
  Stream<ResponsesServerEvent> get events => _eventController.stream;

  /// Whether shutdown has begun or the peer has closed the socket.
  bool get isClosed => _closed;

  /// Actual peer/transport close code when a close notification was observed.
  ///
  /// This may include server or abnormal codes which callers cannot send.
  int? get closeCode => _closeCode;

  /// Actual peer/transport close reason when a notification was observed.
  ///
  /// A reason may contain service information; avoid logging it indiscriminately.
  String? get closeReason => _closeReason;

  /// Completes after socket reader teardown, independently of event listeners.
  ///
  /// Errors are reported on [events] (and an explicit [close] call can fail).
  /// This future completes normally even after transport failure. A paused or
  /// absent event subscriber never delays transport completion.
  Future<void> get done => _done.future;

  void _drainOpeningBuffer() {
    if (_hasListened) return;
    _hasListened = true;
    for (final buffered in _openingBuffer) {
      if (buffered.error case final error?) {
        _eventController.addError(error, buffered.stackTrace);
      } else {
        _eventController.add(buffered.event!);
      }
    }
    _openingBuffer.clear();
    if (_overflow case final overflow?) _eventController.addError(overflow);
    if (_done.isCompleted) _closeEventStream();
  }

  void _emit(_BufferedResponsesEvent entry) {
    if (_eventStreamClosed) return;
    if (_hasListened) {
      if (entry.error case final error?) {
        _eventController.addError(error, entry.stackTrace);
      } else {
        _eventController.add(entry.event!);
      }
      return;
    }
    if (_openingBuffer.length < maxBufferedEvents) {
      _openingBuffer.add(entry);
      return;
    }
    _overflow ??= ResponsesEventBufferOverflowException(maxBufferedEvents);
    _shutdownInBackground(closeSocket: true, code: 1000);
  }

  void _handleSocketEvent(WebSocketEvent event) {
    // Close notifications carry actual transport facts, including during an
    // explicit close. Other data after shutdown has begun is ignored.
    if (event case CloseReceived(:final code, :final reason)) {
      _closeCode = code;
      _closeReason = reason;
      _shutdownInBackground();
      return;
    }
    if (_closed) return;
    switch (event) {
      case TextDataReceived(:final text):
        _handleText(text);
      case BinaryDataReceived():
        _emitError(const ResponsesProtocolException(kind: 'binary'));
      case CloseReceived():
        break;
    }
  }

  void _handleText(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      _emitError(const ResponsesProtocolException(kind: 'invalid_json'));
      return;
    }
    if (decoded is! Map<String, dynamic>) {
      _emitError(const ResponsesProtocolException(kind: 'non_object'));
      return;
    }
    try {
      _emit(
        _BufferedResponsesEvent.event(ResponsesServerEvent.fromJson(decoded)),
      );
    } catch (_) {
      _emitError(const ResponsesProtocolException(kind: 'invalid_event'));
    }
  }

  void _emitError(Object error, [StackTrace? stackTrace]) =>
      _emit(_BufferedResponsesEvent.error(error, stackTrace));

  void _handleSocketError(Object _, StackTrace stackTrace) {
    if (_closed) return;
    _emitError(
      const ResponsesTransportException(operation: 'receive'),
      stackTrace,
    );
    _shutdownInBackground(closeSocket: true);
  }

  void _handleSocketDone() => _shutdownInBackground();

  void _shutdownInBackground({bool closeSocket = false, int? code}) {
    unawaited(
      _startShutdown(closeSocket: closeSocket, code: code).catchError((
        Object _,
      ) {
        // The error was already emitted onto events; background cleanup
        // must not create an additional unhandled asynchronous error.
      }),
    );
  }

  Future<void> _startShutdown({
    bool closeSocket = false,
    int? code,
    String? reason,
  }) {
    if (_shutdownFuture case final future?) return future;
    _closed = true;
    final completion = Completer<void>();
    _shutdownFuture = completion.future;
    unawaited(
      // A synchronous custom socket can signal closure inside listen(). Defer
      // teardown until its subscription has been assigned before canceling it.
      Future<void>.microtask(
        () => _shutdown(closeSocket, code, reason),
      ).then(completion.complete, onError: completion.completeError),
    );
    return completion.future;
  }

  Future<void> _shutdown(bool closeSocket, int? code, String? reason) async {
    ResponsesTransportException? failure;
    try {
      if (closeSocket) await _socket.close(code, reason);
    } catch (_) {
      failure = const ResponsesTransportException(operation: 'close');
      _emitError(failure);
    } finally {
      try {
        await _subscription?.cancel();
      } catch (_) {
        failure ??= const ResponsesTransportException(operation: 'cancel');
        _emitError(const ResponsesTransportException(operation: 'cancel'));
      } finally {
        _done.complete();
        if (_hasListened) _closeEventStream();
      }
    }
    if (failure != null) throw failure;
  }

  void _closeEventStream() {
    if (_eventStreamClosed) return;
    _eventStreamClosed = true;
    // A paused subscriber may delay the controller's close future. Its future
    // is intentionally independent from transport cleanup and done.
    unawaited(_eventController.close());
  }

  /// Sends one typed `response.create` frame immediately.
  ///
  /// GA connections reject beta-only `multiAgent` configuration. Send failures
  /// end the transport and are thrown as [ResponsesTransportException].
  void send(ResponsesCreateEvent event) {
    if (_closed) throw StateError('Responses WebSocket connection is closed');
    if (!beta && event.request.multiAgent != null) {
      throw ArgumentError('multiAgent requires a beta Responses connection');
    }
    final json = event.toJson();
    _sendFrame(json, invalidFrameKind: 'invalid_create');
  }

  void _sendFrame(
    Map<String, dynamic> json, {
    required String invalidFrameKind,
  }) {
    final String encoded;
    try {
      encoded = jsonEncode(json);
    } catch (_) {
      throw ResponsesProtocolException(kind: invalidFrameKind);
    }
    try {
      _socket.sendText(encoded);
    } catch (_) {
      const error = ResponsesTransportException(operation: 'send');
      _emitError(error);
      _shutdownInBackground(closeSocket: true);
      throw error;
    }
  }

  /// Sends a create frame, optionally selecting a lane or warming its context.
  ///
  /// [streamId] controls routing; the request's `previousResponseId` controls
  /// ancestry. [generate] is the guide-supported WebSocket warm-up extension.
  void create(
    CreateResponseRequest request, {
    String? streamId,
    bool? generate,
  }) => send(
    ResponsesCreateEvent(
      request: request,
      streamId: streamId,
      generate: generate,
    ),
  );

  /// Sends one typed `response.steer` frame immediately.
  ///
  /// The target response determines the lane. A steer contains only its type,
  /// parent response ID and user input. Acceptance queues server ownership;
  /// successor creation is the commit point. Keep reading original and successor
  /// events without sending another create or resending accepted input.
  ///
  /// If a pending message identifies tool results or approvals, return saved
  /// results with one explicit create per parent on its original lane. This
  /// method does not run tools, create successors, or replay after an unknown
  /// outcome. Lost acknowledgments and disconnects do not prove rejection.
  void sendSteer(ResponsesSteerEvent event) {
    if (_closed) throw StateError('Responses WebSocket connection is closed');
    _sendFrame(event.toJson(), invalidFrameKind: 'invalid_steer');
  }

  /// Queues user input for a continuation of the target response.
  ///
  /// Use the actual response ID received on this connection. Model and execution
  /// mode support is determined by the server; failures are ordinary typed
  /// steering messages. See [sendSteer] for continuation and ownership rules.
  void steer({
    required String previousResponseId,
    required ResponsesSteerInput input,
  }) => sendSteer(
    ResponsesSteerEvent(previousResponseId: previousResponseId, input: input),
  );

  /// Releases the socket and reader exactly once.
  ///
  /// Caller close codes must be 1000 or 3000–4999, and [reason] must be at most
  /// 123 UTF-8 bytes. A reason without a code uses normal-close code 1000.
  /// Concurrent calls share the same completion. Teardown and
  /// [done] still complete if the socket's close operation fails.
  Future<void> close([int? code, String? reason]) {
    validateResponsesClose(code, reason);
    return _startShutdown(
      closeSocket: true,
      code: reason != null ? code ?? 1000 : code,
      reason: reason,
    );
  }

  @override
  String toString() =>
      'ResponsesConnection(isClosed: $isClosed, beta: $beta, '
      'maxBufferedEvents: $maxBufferedEvents, closeCode: $closeCode)';
}

class _BufferedResponsesEvent {
  const _BufferedResponsesEvent.event(this.event)
    : error = null,
      stackTrace = null;

  const _BufferedResponsesEvent.error(this.error, this.stackTrace)
    : event = null;

  final ResponsesServerEvent? event;
  final Object? error;
  final StackTrace? stackTrace;
}
