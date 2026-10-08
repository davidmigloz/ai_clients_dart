import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

import '../../errors/exceptions.dart';
import 'websocket_connector_common.dart';

/// Whether the default connector is subject to browser header limits.
const isLiveBrowserWebSocket = false;

/// Opens a native Live WebSocket with custom handshake header support.
Future<WebSocket> connectLiveWebSocket(
  Uri uri, {
  Map<String, String>? headers,
}) async {
  validateLiveWebSocketUri(uri);
  try {
    final socket = await io.WebSocket.connect(uri.toString(), headers: headers);
    return _LiveNativeWebSocket(socket);
  } catch (error) {
    throw ConnectionException(
      message: 'Live WebSocket handshake failed.',
      url: uri.toString(),
      cause: error,
      redactDiagnostics: true,
    );
  }
}

class _LiveNativeWebSocket implements WebSocket {
  _LiveNativeWebSocket(this._socket) {
    _subscription = _socket.listen(
      _handleData,
      onError: (Object error, StackTrace stackTrace) {
        if (_events.isClosed) return;
        _events.addError(
          ConnectionException(
            message: 'Live WebSocket transport failed.',
            cause: error,
            redactDiagnostics: true,
          ),
          stackTrace,
        );
      },
      onDone: _handleDone,
    );
  }

  final io.WebSocket _socket;
  final StreamController<WebSocketEvent> _events = StreamController();
  final Completer<void> _transportDone = Completer();
  late final StreamSubscription<dynamic> _subscription;
  bool _closed = false;
  bool _closing = false;
  Future<void>? _closeFuture;

  void _handleData(dynamic data) {
    if (_events.isClosed) return;
    switch (data) {
      case final String text:
        _events.add(TextDataReceived(text));
      case final List<int> bytes:
        _events.add(BinaryDataReceived(Uint8List.fromList(bytes)));
    }
  }

  void _handleDone() {
    if (_closed) return;
    _closed = true;
    _events.add(CloseReceived(_socket.closeCode, _socket.closeReason ?? ''));
    unawaited(_events.close());
    _transportDone.complete();
  }

  void _ensureOpen() {
    if (_closed || _closing) throw WebSocketConnectionClosed();
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => _socket.protocol ?? '';

  @override
  void sendBytes(Uint8List bytes) {
    _ensureOpen();
    _socket.add(bytes);
  }

  @override
  void sendText(String text) {
    _ensureOpen();
    _socket.add(text);
  }

  @override
  Future<void> close([int? code, String? reason]) {
    validateLiveClose(code, reason);
    if (_closeFuture case final future?) return future;
    if (_closed) return Future.value();
    _closing = true;
    return _closeFuture = _close(reason != null ? code ?? 1000 : code, reason);
  }

  Future<void> _close(int? code, String? reason) async {
    try {
      await _socket.close(code, reason);
      await _transportDone.future;
    } catch (error) {
      try {
        await _subscription.cancel();
      } catch (_) {
        // The close failure below is redacted regardless of cancellation's
        // platform-specific error. Terminal notification still happens.
      } finally {
        _handleDone();
      }
      throw ConnectionException(
        message: 'Live WebSocket close failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
  }
}
