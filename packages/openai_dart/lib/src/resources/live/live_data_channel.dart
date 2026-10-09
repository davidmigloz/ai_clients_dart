import 'dart:async';
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

/// Typed JSON-message seam for an application-owned media data channel.
///
/// [messages] must be broadcast so application listeners and separate Live
/// connections never consume each other's messages. The caller translates native
/// RTC message/close/error callbacks into this stream and owns signaling/media.
/// This seam neither creates a peer connection nor exposes media closure.
abstract interface class LiveDataChannel {
  /// Broadcast text messages, errors, and channel completion from the caller.
  Stream<String> get messages;

  /// Submits a text message through the caller's already-open channel.
  void sendText(String message);
}

/// Non-owning socket facade for the typed borrowed data-channel seam.
///
/// Each [events] listener creates one independent [LiveDataChannel.messages]
/// tap. Canceling it detaches only that listener. [close] deliberately does not
/// close the data channel or caller media; LiveConnection uses ownsSocket false.
final class LiveDataChannelSocket implements WebSocket {
  /// Captures and checks one broadcast channel stream without subscribing.
  LiveDataChannelSocket(this.channel) : _messages = channel.messages {
    if (!_messages.isBroadcast) {
      throw ArgumentError('LiveDataChannel.messages must be broadcast.');
    }
  }

  /// The caller-owned channel, explicitly accessible by the application.
  final LiveDataChannel channel;
  final Stream<String> _messages;

  @override
  Stream<WebSocketEvent> get events =>
      _messages.map<WebSocketEvent>(TextDataReceived.new);

  @override
  String get protocol => '';

  @override
  void sendText(String message) => channel.sendText(message);

  @override
  void sendBytes(Uint8List bytes) =>
      throw UnsupportedError('Live data channels carry JSON text messages.');

  @override
  Future<void> close([int? code, String? reason]) async {}

  @override
  String toString() => 'LiveDataChannelSocket(borrowed)';
}
