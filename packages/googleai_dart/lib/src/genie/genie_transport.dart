import 'dart:async';
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

import 'genie_webrtc_peer.dart';

/// One connection carrying the shared Genie event protocol.
abstract interface class GenieTransport {
  /// The transport name used in diagnostics.
  String get name;

  /// The maximum encoded control message size, if limited.
  int? get maxMessageSize;

  /// Incoming text, binary, and close events.
  Stream<WebSocketEvent> get events;

  /// Sends one complete JSON control message.
  void sendText(String message);

  /// Flushes outgoing control messages and releases the connection.
  Future<void> close();
}

/// Adapts the WebSocket transport to the shared session.
class GenieSocketTransport implements GenieTransport {
  final WebSocket _socket;

  /// Wraps an established WebSocket.
  GenieSocketTransport(this._socket);

  @override
  String get name => 'WebSocket';

  @override
  int? get maxMessageSize => null;

  @override
  Stream<WebSocketEvent> get events => _socket.events;

  @override
  void sendText(String message) => _socket.sendText(message);

  @override
  Future<void> close() => _socket.close();
}

/// Adapts the WebRTC data channel to the shared session.
class GenieRtcTransport implements GenieTransport {
  final GenieWebRtcPeer _peer;
  final GenieWebRtcDataChannel _channel;

  /// Wraps an established data channel and its owning peer.
  GenieRtcTransport(this._peer, this._channel);

  @override
  String get name => 'WebRTC data channel';

  @override
  int get maxMessageSize {
    final size = _channel.maxMessageSize;
    return size == null || size <= 0 ? 65536 : size;
  }

  @override
  Stream<WebSocketEvent> get events => _channel.messages.map(
    (frame) => switch (frame) {
      String() => TextDataReceived(frame),
      Uint8List() => BinaryDataReceived(frame),
      _ => throw const FormatException('Invalid Genie data-channel frame.'),
    },
  );

  @override
  void sendText(String message) => _channel.sendText(message);

  @override
  Future<void> close() async {
    try {
      await _channel.flush().timeout(const Duration(milliseconds: 550));
    } finally {
      await _peer.close();
    }
  }
}
