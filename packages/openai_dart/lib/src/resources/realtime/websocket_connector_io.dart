import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

import '../../errors/exceptions.dart';
import 'websocket_connector_common.dart';

/// Whether the platform default uses the browser WebSocket API.
const isRealtimeBrowserWebSocket = false;

/// Opens a native Realtime WebSocket with custom handshake header support.
///
/// Compression is disabled, following the official SDK's native default.
/// The native implementation does not impose a message-size limit.
Future<WebSocket> connectWebSocket(
  Uri uri, {
  Map<String, String>? headers,
  Iterable<String>? protocols,
  io.CompressionOptions compression = io.CompressionOptions.compressionOff,
  io.HttpClient? customClient,
}) async {
  validateRealtimeWebSocketUri(uri);
  try {
    final socket = await io.WebSocket.connect(
      uri.toString(),
      headers: headers,
      protocols: protocols,
      compression: compression,
      customClient: customClient,
    );
    return _RealtimeNativeWebSocket(socket);
  } catch (_) {
    throw const ConnectionException(
      message: 'Realtime WebSocket handshake failed.',
    );
  }
}

class _RealtimeNativeWebSocket implements WebSocket {
  _RealtimeNativeWebSocket(this._socket) {
    _subscription = _socket.listen(
      _handleData,
      onError: (Object _, StackTrace stackTrace) {
        if (_events.isClosed) return;
        _events.addError(
          WebSocketException('Realtime WebSocket transport failed.'),
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
    validateRealtimeClose(code, reason);
    if (_closeFuture case final future?) return future;
    if (_closed) return Future.value();
    _closing = true;
    return _closeFuture = _close(reason != null ? code ?? 1000 : code, reason);
  }

  Future<void> _close(int? code, String? reason) async {
    try {
      await _socket.close(code, reason);
      await _transportDone.future;
    } catch (_) {
      try {
        await _subscription.cancel();
      } catch (_) {
        // The close failure below is redacted regardless of cancellation's
        // platform-specific error. Terminal notification still happens.
      } finally {
        _handleDone();
      }
      throw WebSocketException('Realtime WebSocket close failed.');
    }
  }
}
