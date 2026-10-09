import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../errors/exceptions.dart';
import '../models/agents/agent_session_models.dart';
import '../utils/streaming_parser.dart';

/// Decodes raw persistent observation without treating idle or turn events as EOF.
Stream<AgentSessionEvent> decodeAgentSessionEvents(Stream<Uint8List> bytes) =>
    _AgentSessionEventOperation(bytes).stream;

class _AgentSessionEventOperation {
  _AgentSessionEventOperation(this.bytes) {
    _controller = StreamController<AgentSessionEvent>(
      onListen: _start,
      onPause: () {
        _byteSubscription?.pause();
        _parserSubscription?.pause();
      },
      onResume: () {
        _parserSubscription?.resume();
        _byteSubscription?.resume();
      },
      onCancel: () {
        _cancelled = true;
        return _cleanup();
      },
    );
  }

  final Stream<Uint8List> bytes;
  late final StreamController<AgentSessionEvent> _controller;
  final _parserBytes = StreamController<List<int>>();
  StreamSubscription<Uint8List>? _byteSubscription;
  StreamSubscription<SseEvent>? _parserSubscription;
  Future<void>? _cleanupFuture;
  bool _cancelled = false;
  bool _settled = false;
  bool _parserBytesClosing = false;
  bool _controllerClosing = false;

  Stream<AgentSessionEvent> get stream => _controller.stream;

  void _start() {
    _parserSubscription = const SseParser()
        .parseRaw(_parserBytes.stream)
        .listen(
          _parseEvent,
          onError: (Object error, StackTrace stackTrace) {
            if (error is FormatException) {
              _fail(
                const ParseException(
                  message: 'Invalid Agents session SSE encoding',
                  cause: FormatException(
                    'Expected valid UTF-8 Agents session SSE',
                  ),
                ),
                stackTrace,
              );
            } else {
              _fail(error, stackTrace);
            }
          },
          onDone: _finish,
        );
    _byteSubscription = bytes.listen(
      (chunk) {
        if (!_settled && !_cancelled) _parserBytes.add(chunk);
      },
      onError: _fail,
      onDone: _closeParserBytes,
    );
  }

  void _parseEvent(SseEvent raw) {
    if (_settled || _cancelled) return;
    if (raw.isDone) {
      _finish();
      return;
    }
    try {
      final decoded = jsonDecode(raw.data);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      _controller.add(AgentSessionEvent.fromJson(decoded));
    } on FormatException catch (_, stackTrace) {
      _fail(
        ParseException(
          message: 'Invalid Agents session SSE event',
          responseBody: raw.data,
          cause: const FormatException('Expected a valid Agents session event'),
        ),
        stackTrace,
      );
    } on TypeError catch (_, stackTrace) {
      _fail(
        ParseException(
          message: 'Invalid Agents session SSE field type',
          responseBody: raw.data,
          cause: const FormatException('Invalid known field type'),
        ),
        stackTrace,
      );
    }
  }

  void _closeParserBytes() {
    if (!_parserBytesClosing) {
      _parserBytesClosing = true;
      unawaited(_parserBytes.close());
    }
  }

  void _closeController() {
    if (!_controllerClosing) {
      _controllerClosing = true;
      unawaited(_controller.close());
    }
  }

  Future<void> _cleanup() => _cleanupFuture ??= _cleanupSubscriptions();

  Future<void> _cleanupSubscriptions() async {
    // Release the request first; parser cancellation may be awaiting input.
    await _cancelAgentSessionSubscription(_byteSubscription);
    _closeParserBytes();
    await _cancelAgentSessionSubscription(_parserSubscription);
    _closeController();
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (_settled || _cancelled) return;
    _settled = true;
    _controller.addError(error, stackTrace);
    _closeController();
    unawaited(_cleanup());
  }

  void _finish() {
    if (_settled || _cancelled) return;
    _settled = true;
    _closeController();
    unawaited(_cleanup());
  }
}

Future<void> _cancelAgentSessionSubscription<T>(
  StreamSubscription<T>? subscription,
) async {
  try {
    await subscription?.cancel();
  } catch (_) {}
}
