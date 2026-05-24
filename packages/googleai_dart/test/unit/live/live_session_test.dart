import 'dart:async';
import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

/// A fake [WebSocket] whose [close] behavior is configurable, used to exercise
/// [LiveSession.close] without a real connection.
class _FakeWebSocket implements WebSocket {
  _FakeWebSocket({this.throwOnClose = false});

  /// When true, [close] throws [WebSocketConnectionClosed], mimicking the
  /// web_socket package contract for an already-closed connection.
  final bool throwOnClose;

  final StreamController<WebSocketEvent> _events =
      StreamController<WebSocketEvent>.broadcast();

  int closeCallCount = 0;

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => '';

  @override
  void sendBytes(Uint8List b) {}

  @override
  void sendText(String s) {}

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCallCount++;
    if (throwOnClose) {
      throw WebSocketConnectionClosed();
    }
    if (!_events.isClosed) {
      await _events.close();
    }
  }
}

void main() {
  group('LiveSession.close', () {
    test('completes normally for an open connection', () async {
      final socket = _FakeWebSocket();
      final session = LiveSession.fromWebSocket(socket);

      await session.close();

      expect(socket.closeCallCount, 1);
      expect(session.isConnected, isFalse);
      // The message stream is closed afterwards.
      await expectLater(session.messages, emitsDone);
    });

    test('is idempotent when the connection is already closed '
        '(swallows WebSocketConnectionClosed)', () async {
      // Server closed the connection first, so the socket throws on close().
      final socket = _FakeWebSocket(throwOnClose: true);
      final session = LiveSession.fromWebSocket(socket);

      // Must not rethrow the WebSocketConnectionClosed from the socket.
      await expectLater(session.close(), completes);

      expect(socket.closeCallCount, 1);
      expect(session.isConnected, isFalse);
      // The message controller is still torn down despite the socket throwing.
      await expectLater(session.messages, emitsDone);
    });

    test('can be called more than once without throwing', () async {
      final socket = _FakeWebSocket();
      final session = LiveSession.fromWebSocket(socket);

      await session.close();
      await expectLater(session.close(), completes);
    });
  });
}
