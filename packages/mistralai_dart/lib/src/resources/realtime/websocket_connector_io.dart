import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

/// Whether the platform is a browser.
const isRealtimeBrowser = false;

/// Opens a native socket with handshake headers and subprotocols.
Future<WebSocket> connectRealtimeWebSocket(
  Uri url, {
  required Map<String, String> headers,
  required List<String> protocols,
}) async {
  final socket = await io.WebSocket.connect(
    url.toString(),
    headers: headers,
    protocols: protocols.isEmpty ? null : protocols,
    compression: io.CompressionOptions.compressionOff,
  );
  if (socket.protocol != null && !protocols.contains(socket.protocol)) {
    await socket.close(1002);
    throw WebSocketException('The server selected an unexpected subprotocol.');
  }
  return _NativeSocket(socket);
}

// dart:io supports handshake headers; the package:web_socket factory does not.
final class _NativeSocket implements WebSocket {
  _NativeSocket(this._socket) {
    _reader = _socket.listen(
      (frame) {
        if (_events.isClosed) return;
        switch (frame) {
          case final String text:
            _events.add(TextDataReceived(text));
          case final List<int> bytes:
            _events.add(BinaryDataReceived(Uint8List.fromList(bytes)));
        }
      },
      onError: (Object _, StackTrace stackTrace) {
        if (_events.isClosed) return;
        _events.addError(
          WebSocketException('Realtime transport failed.'),
          stackTrace,
        );
      },
      onDone: () {
        if (_events.isClosed) return;
        _events.add(
          CloseReceived(_socket.closeCode, _socket.closeReason ?? ''),
        );
        unawaited(_events.close());
      },
    );
  }

  final io.WebSocket _socket;
  final _events = StreamController<WebSocketEvent>();
  late final StreamSubscription<dynamic> _reader;
  Future<void>? _closing;

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => _socket.protocol ?? '';

  @override
  void sendText(String text) => _socket.add(text);

  @override
  void sendBytes(Uint8List bytes) => _socket.add(bytes);

  @override
  Future<void> close([int? code, String? reason]) =>
      _closing ??= _close(code, reason);

  Future<void> _close(int? code, String? reason) async {
    try {
      await _socket.close(code, reason);
    } finally {
      await _reader.cancel();
      unawaited(_events.close());
    }
  }
}
