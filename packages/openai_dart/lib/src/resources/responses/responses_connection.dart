import 'dart:async';
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../../models/responses/create_response_request.dart';
import '../../models/responses/items/item.dart';
import '../../models/responses/multi_agent/response_inject_event.dart';
import '../../models/responses/websocket/responses_create_event.dart';
import '../../models/responses/websocket/responses_server_event.dart';
import '../../models/responses/websocket/responses_steer_event.dart';
import 'responses_recovering_websocket.dart';
import 'responses_recovery.dart';
import 'websocket_connector_common.dart';

export 'responses_recovering_websocket.dart';
export 'responses_recovery.dart';
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
  /// `invalid_create`, `invalid_steer`, or `invalid_inject`.
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
/// to release the transport. By default it does not reconnect or queue sends.
/// An explicitly supplied [recovery] helper may reopen sockets and queue only
/// newly unsent frames; submitted work is never replayed. Closing the connection
/// does not cancel a model response.
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
    this.recovery,
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

  /// Opted-in recovery state and final unsent report, or null by default.
  final ResponsesRecovery? recovery;

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

  /// Final transport close code when a close notification was observed.
  ///
  /// Ordinary connections retain actual peer facts. Opted-in recovery reports
  /// final logical helper facts, including the requested explicit close code;
  /// interruption codes are available on [recovery]'s attempt context. Codes may
  /// include server or abnormal values which callers cannot send.
  int? get closeCode => _closeCode;

  /// Final transport close reason when a notification was observed.
  ///
  /// With opted-in recovery this is the final logical helper reason;
  /// interruption reasons are retained in the recovery attempt context.
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
    // Close notifications carry final transport facts: actual peer facts for
    // ordinary sockets, logical helper facts with recovery. Other data after
    // shutdown has begun is ignored.
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

  /// Sends one typed `response.create` frame or queues it during opted-in recovery.
  ///
  /// GA connections reject beta-only `multiAgent` configuration. Ordinary
  /// socket failures close the connection and throw [ResponsesTransportException].
  /// With recovery enabled, [ResponsesSendQueueOverflowException] rejects only
  /// the new frame and leaves recovery active. An attempted write failure closes
  /// the connection with [ResponsesDeliveryUnknownException]; it is never retried.
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
    } catch (failure) {
      if (recovery != null && failure is ResponsesSendQueueOverflowException) {
        // Overflow rejects only this newly unsent frame. Recovery and the
        // existing bounded queue remain usable.
        rethrow;
      }
      if (recovery != null && failure is ResponsesDeliveryUnknownException) {
        _emitError(failure);
        _shutdownInBackground(closeSocket: true);
        rethrow;
      }
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

  /// Sends one typed `response.steer` frame or queues it during opted-in recovery.
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
  /// Recovery queue rejection and attempted-write failures follow [send]'s
  /// explicit exception rules.
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

  /// Submits client-owned input to an active beta multi-agent response.
  ///
  /// The target response chooses the lane; an injection contains only `type`,
  /// `response_id` and `input`. Beta opt-in is required before any frame is
  /// serialized or written. The server validates its broad item union and
  /// currently accepts client-owned tool outputs which resume a waiting agent.
  ///
  /// Track each outstanding submission before calling this synchronous method.
  /// Keep reading until the response is terminal and every submission has a
  /// created or failed acknowledgement, including acknowledgements after
  /// response completion. This method does not execute tools, match submissions
  /// to acknowledgements, create continuations or replay attempted frames.
  /// Recovery queue rejection and attempted-write failures follow [send]'s
  /// explicit exception rules.
  void sendInject(ResponseInjectEvent event) {
    if (_closed) throw StateError('Responses WebSocket connection is closed');
    if (!beta) {
      throw ArgumentError(
        'response.inject requires a beta Responses connection',
      );
    }
    _sendFrame(event.toJson(), invalidFrameKind: 'invalid_inject');
  }

  /// Submits saved input items to the active response on its existing lane.
  ///
  /// Use the ID received in `response.created`. For an already-completed failure,
  /// the application may explicitly continue from the completed response with
  /// the returned uncommitted input, after collecting all acknowledgements.
  /// See [sendInject] for submission ownership and recovery rules.
  void inject({required String responseId, required List<Item> input}) =>
      sendInject(ResponseInjectEvent(responseId: responseId, input: input));

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
