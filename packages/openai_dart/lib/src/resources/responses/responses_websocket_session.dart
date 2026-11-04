import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import '../../models/responses/create_response_request.dart';
import '../../models/responses/items/output_item.dart';
import '../../models/responses/response.dart';
import '../../models/responses/streaming/response_stream_event.dart';
import '../../models/responses/websocket/responses_create_event.dart';
import '../../models/responses/websocket/responses_server_event.dart';
import 'responses_connection.dart';

/// Application-selected retention budgets, independent of service limits.
///
/// Bytes count UTF-8 encoded JSON of parsed messages, excluding wire whitespace,
/// transport/decoder overhead and the connection's pre-session opening buffer.
/// [maxResponseBytes] also bounds cumulative consumed events per response, even
/// when the caller drains its lane continuously. Choose budgets for your output,
/// especially when using image or audio tools.
class ResponsesWebSocketLimits {
  /// Creates explicit positive budgets. Validation runs when attaching a session.
  const ResponsesWebSocketLimits({
    required this.maxLanes,
    required this.maxEventsPerLane,
    required this.maxEvents,
    required this.maxBytesPerLane,
    required this.maxBytes,
    required this.maxResponseBytes,
  });

  /// Maximum registered lane IDs, including the default and detached lanes.
  final int maxLanes;

  /// Maximum queued events in one lane.
  final int maxEventsPerLane;

  /// Maximum queued events across the session.
  final int maxEvents;

  /// Maximum queued JSON bytes in one lane.
  final int maxBytesPerLane;

  /// Maximum queued JSON bytes across the session.
  final int maxBytes;

  /// Maximum cumulative event JSON bytes consumed for one response.
  final int maxResponseBytes;

  void _validate() {
    for (final value in [
      maxLanes,
      maxEventsPerLane,
      maxEvents,
      maxBytesPerLane,
      maxBytes,
      maxResponseBytes,
    ]) {
      if (value <= 0 || !value.isFinite) {
        throw ArgumentError('WebSocket budgets must be positive and finite');
      }
    }
  }
}

/// A redacted session/lane failure. A server request error retains its [event].
class ResponsesWebSocketSessionException implements Exception {
  /// Creates a payload-free diagnostic, optionally retaining a server error.
  const ResponsesWebSocketSessionException({required this.kind, this.event});

  /// `cancelled`, `lane_detached`, `session_closed`, `unexpected_eof`,
  /// `buffer_limit`, `response_limit`, `request_error`, or `invalid_response`.
  final String kind;

  /// Original request-scoped server error, available for explicit inspection.
  final ResponsesErrorEvent? event;

  @override
  String toString() => 'ResponsesWebSocketSessionException: $kind';
}

final _sessions = Expando<ResponsesWebSocketSession>();
final _reservedLanes = Expando<Set<String?>>();

/// Opt-in ordered lane routing and final-response collection on an open socket.
///
/// Register lanes before sending. This helper owns one event subscription;
/// [close] detaches it and leaves the caller-owned [connection] open. Unregistered
/// events remain observable on the connection. Direct sends remain available,
/// but use each lane's sends to enforce one consumed response at a time.
///
/// Detached IDs remain reserved for the connection lifetime: a delayed automatic
/// steering successor can follow a terminal response. A slow lane exceeding its
/// own budget fails independently. Shared-budget pressure fails the largest
/// queued lane until within budget. Protocol/transport errors end this helper;
/// queued events can still be drained after normal EOF. No tools, retries or
/// continuation inputs are generated. Recovery-enabled connections are currently
/// rejected because lane sends must never enter a reconnect replay queue.
class ResponsesWebSocketSession {
  /// Attaches immediately to an existing non-recovering connection.
  ResponsesWebSocketSession(this.connection, {required this.limits}) {
    limits._validate();
    if (connection.isClosed) throw StateError('Responses connection is closed');
    if (connection.recovery != null) {
      throw ArgumentError('WebSocket sessions require recovery to be disabled');
    }
    if (_sessions[connection] != null) {
      throw StateError('Responses connection already has a session');
    }
    _sessions[connection] = this;
    _subscription = connection.events.listen(
      _dispatch,
      onError: (Object error, StackTrace _) => _fail(error),
      onDone: _end,
    );
  }

  /// Caller-owned transport. Close it explicitly after detaching the session.
  final ResponsesConnection connection;

  /// Local retention budgets.
  final ResponsesWebSocketLimits limits;

  final Map<String?, ResponsesWebSocketLane> _lanes = {};
  late final StreamSubscription<ResponsesServerEvent> _subscription;
  int _events = 0;
  int _bytes = 0;
  bool _ended = false;
  bool _closed = false;
  Future<void>? _closing;

  /// Registers an ordered named lane, or the default lane when omitted.
  ///
  /// Reuse the returned object across sequential turns. An ID cannot be
  /// registered twice, even after detach or helper recreation on the same socket.
  ResponsesWebSocketLane lane([String? streamId]) {
    if (_closed || _ended) throw StateError('WebSocket session has ended');
    if (streamId != null &&
        (streamId.length > 256 ||
            !RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(streamId) ||
            streamId.codeUnits.any((unit) => unit > 127 || unit < 32))) {
      throw ArgumentError('Invalid Responses WebSocket stream ID');
    }
    final reserved = _reservedLanes[connection] ??= <String?>{};
    if (reserved.contains(streamId)) throw StateError('Lane ID is reserved');
    if (reserved.length >= limits.maxLanes) {
      throw const ResponsesWebSocketSessionException(kind: 'buffer_limit');
    }
    reserved.add(streamId);
    return _lanes[streamId] = ResponsesWebSocketLane._(this, streamId);
  }

  void _dispatch(ResponsesServerEvent event) {
    if (_ended || _closed) return;
    final lane = _lanes[event.streamId];
    if (lane == null || lane._error != null) return;
    final int size;
    try {
      size = utf8
          .encode(
            jsonEncode(event.rawJson.isEmpty ? event.toJson() : event.rawJson),
          )
          .length;
    } catch (_) {
      lane._fail(
        const ResponsesWebSocketSessionException(kind: 'invalid_response'),
      );
      return;
    }
    if (lane._queue.length >= limits.maxEventsPerLane ||
        lane._bytes + size > limits.maxBytesPerLane) {
      lane._fail(
        const ResponsesWebSocketSessionException(kind: 'buffer_limit'),
      );
      return;
    }
    lane._queue.add(_QueuedEvent(event, size));
    lane._bytes += size;
    _events++;
    _bytes += size;
    if (event.type == 'response.created') {
      lane._receivedGeneration++;
      lane._inFlight = true;
    }
    while (_events > limits.maxEvents || _bytes > limits.maxBytes) {
      final queued = _lanes.values.where((entry) => entry._queue.isNotEmpty);
      queued
          .reduce(
            (a, b) =>
                (_bytes > limits.maxBytes
                    ? a._bytes >= b._bytes
                    : a._queue.length >= b._queue.length)
                ? a
                : b,
          )
          ._fail(
            const ResponsesWebSocketSessionException(kind: 'buffer_limit'),
          );
    }
    lane._notify();
  }

  void _release(ResponsesWebSocketLane lane) {
    _events -= lane._queue.length;
    _bytes -= lane._bytes;
    lane._queue.clear();
    lane._bytes = 0;
  }

  void _end() {
    if (_ended) return;
    _ended = true;
    _sessions[connection] = null;
    for (final lane in _lanes.values) {
      lane._notify();
    }
  }

  void _fail(Object error) {
    if (_ended) return;
    for (final lane in _lanes.values) {
      lane._fail(error);
    }
    _end();
    unawaited(_subscription.cancel());
  }

  /// Releases all retained events, accumulators and the helper's reader.
  /// The transport remains open and lane IDs stay reserved on it.
  Future<void> close() {
    if (_closing != null) return _closing!;
    _closed = true;
    for (final lane in _lanes.values) {
      lane._fail(
        const ResponsesWebSocketSessionException(kind: 'session_closed'),
      );
    }
    _end();
    return _closing = _subscription.cancel();
  }
}

/// One bounded, sequential view of a session. Use one consumer at a time.
///
/// A cancelled wait releases its reader without consuming another event or
/// discarding accumulated output. Resume on this same lane. Detaching the lane
/// does not cancel server work or close the connection. Request errors, invalid
/// accumulation and budget failures end that local lane; restore application
/// context on a new lane or connection rather than replaying attempted work.
class ResponsesWebSocketLane {
  ResponsesWebSocketLane._(this._session, this.streamId);

  final ResponsesWebSocketSession _session;

  /// Routing identity; null means the protocol's default lane.
  final String? streamId;

  final Queue<_QueuedEvent> _queue = Queue();
  final Map<int, OutputItem> _output = {};
  Completer<void>? _wake;
  Exception? _error;
  Response? _finalResponse;
  String? _responseId;
  int _bytes = 0;
  int _responseBytes = 0;
  int _receivedGeneration = 0;
  int _consumedGeneration = 0;
  bool _reading = false;
  bool _inFlight = false;

  /// Last collected terminal response, including failed/incomplete results.
  Response? get finalResponse => _finalResponse;

  /// Sends one create on this lane. Conversation ancestry remains explicit.
  void send(ResponsesCreateEvent event) {
    if (_error != null || _session._ended || _session._closed) {
      throw StateError('WebSocket lane is not active');
    }
    if (event.streamId != null && event.streamId != streamId) {
      throw ArgumentError('Create stream ID does not match its lane');
    }
    if (_inFlight) {
      throw StateError('Consume the current response before creating another');
    }
    final routed = event.copyWith(streamId: streamId);
    if (!_session.connection.beta && routed.request.multiAgent != null) {
      throw ArgumentError('multiAgent requires a beta Responses connection');
    }
    // Validate before reserving the lane. An attempted transport write is never
    // replayed; transport errors still propagate through the connection.
    jsonEncode(routed.toJson());
    _reset();
    _inFlight = true;
    try {
      _session.connection.send(routed);
    } catch (error) {
      _fail(error);
      rethrow;
    }
  }

  /// Creates output or warms context with `generate: false`.
  void create(CreateResponseRequest request, {bool? generate}) =>
      send(ResponsesCreateEvent(request: request, generate: generate));

  /// Consumes one event in wire order, updating the final-response collector.
  /// Cancellation leaves queued events and partial accumulation available.
  Future<ResponsesServerEvent> receive({Future<void>? abortTrigger}) =>
      _consume(_receive, abortTrigger);

  /// Consumes remaining events until the next terminal response.
  ///
  /// Finalized items fill omitted/null terminal output; explicit empty output
  /// stays empty. Deltas are delivered by [receive] and are not guessed into
  /// missing items. Request errors throw with their original server event.
  Future<Response> getFinalResponse({Future<void>? abortTrigger}) => _consume((
    cancel,
  ) async {
    if (cancel.cancelled) {
      throw const ResponsesWebSocketSessionException(kind: 'cancelled');
    }
    if (_error != null) throw _error!;
    if (_finalResponse != null && _receivedGeneration == _consumedGeneration) {
      return _finalResponse!;
    }
    while (true) {
      final event = await _receive(cancel);
      if (event.type == 'response.completed' ||
          event.type == 'response.failed' ||
          event.type == 'response.incomplete') {
        return _finalResponse!;
      }
    }
  }, abortTrigger);

  Future<T> _consume<T>(
    Future<T> Function(_Cancellation) action,
    Future<void>? trigger,
  ) async {
    if (_reading) throw StateError('A WebSocket lane already has a reader');
    _reading = true;
    final cancel = _Cancellation();
    if (trigger != null) {
      unawaited(
        trigger.then(
          (_) => cancel.cancel(),
          onError: (Object _, StackTrace _) => cancel.cancel(),
        ),
      );
    }
    try {
      // Observe already-completed cancellation before dequeueing an event.
      await Future<void>.value();
      return await action(cancel);
    } finally {
      cancel.cancel();
      _notify();
      _reading = false;
    }
  }

  Future<ResponsesServerEvent> _receive(_Cancellation cancel) async {
    while (true) {
      if (cancel.cancelled) {
        throw const ResponsesWebSocketSessionException(kind: 'cancelled');
      }
      if (_error != null) throw _error!;
      if (_queue.isNotEmpty) {
        final queued = _queue.removeFirst();
        _bytes -= queued.size;
        _session._bytes -= queued.size;
        _session._events--;
        try {
          _accumulate(queued.event, queued.size);
        } catch (error) {
          _fail(error);
          rethrow;
        }
        return queued.event;
      }
      if (_session._ended) {
        const error = ResponsesWebSocketSessionException(
          kind: 'unexpected_eof',
        );
        _fail(error);
        throw error;
      }
      _wake ??= Completer<void>();
      await Future.any([_wake!.future, cancel.done.future]);
    }
  }

  void _reset() {
    _output.clear();
    _responseBytes = 0;
    _finalResponse = null;
    _responseId = null;
  }

  void _accumulate(ResponsesServerEvent envelope, int size) {
    if (envelope.type == 'response.created') {
      _reset();
      _consumedGeneration++;
      _inFlight = true;
    }
    if (envelope is ResponsesErrorEvent) {
      throw ResponsesWebSocketSessionException(
        kind: 'request_error',
        event: envelope,
      );
    }
    _responseBytes += size;
    if (_responseBytes > _session.limits.maxResponseBytes) {
      throw const ResponsesWebSocketSessionException(kind: 'response_limit');
    }
    if (envelope is! ResponsesStreamEvent) return;
    final event = envelope.event;
    if (event is ResponseCreatedEvent) _responseId = event.response.id;
    if (event is OutputItemDoneEvent) {
      if (event.outputIndex < 0) {
        throw const ResponsesWebSocketSessionException(
          kind: 'invalid_response',
        );
      }
      final rawItem = envelope.rawJson['item'];
      _output[event.outputIndex] = rawItem is Map<String, dynamic>
          ? OutputItem.fromJson(rawItem)
          : event.item;
    }
    final Response? terminal = switch (event) {
      ResponseCompletedEvent(:final response) => response,
      ResponseFailedEvent(:final response) => response,
      ResponseIncompleteEvent(:final response) => response,
      _ => null,
    };
    if (terminal == null) return;
    if (_responseId != null && _responseId != terminal.id) {
      throw const ResponsesWebSocketSessionException(kind: 'invalid_response');
    }
    final raw = envelope.rawJson['response'];
    final fill = raw is Map<String, dynamic> && raw['output'] == null;
    final indices = _output.keys.toList()..sort();
    _finalResponse = terminal.copyWith(
      output: List<OutputItem>.unmodifiable(
        fill ? indices.map((index) => _output[index]!) : terminal.output,
      ),
    );
    _output.clear();
    _responseBytes = 0;
    _inFlight = _receivedGeneration > _consumedGeneration;
  }

  void _notify() {
    final wake = _wake;
    _wake = null;
    if (wake != null && !wake.isCompleted) wake.complete();
  }

  void _fail(Object error) {
    _error ??= error is Exception
        ? error
        : const ResponsesWebSocketSessionException(kind: 'invalid_response');
    _session._release(this);
    _reset();
    _notify();
  }

  /// Releases this lane's retained state and wakes any blocked reader.
  void close() =>
      _fail(const ResponsesWebSocketSessionException(kind: 'lane_detached'));
}

class _QueuedEvent {
  const _QueuedEvent(this.event, this.size);
  final ResponsesServerEvent event;
  final int size;
}

class _Cancellation {
  bool cancelled = false;
  final Completer<void> done = Completer();
  void cancel() {
    if (cancelled) return;
    cancelled = true;
    done.complete();
  }
}
