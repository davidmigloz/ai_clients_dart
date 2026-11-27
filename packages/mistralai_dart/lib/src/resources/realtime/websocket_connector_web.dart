import 'package:web_socket/web_socket.dart';

/// Whether the platform is a browser.
const isRealtimeBrowser = true;

/// Opens a browser socket with the provided subprotocols.
Future<WebSocket> connectRealtimeWebSocket(
  Uri url, {
  required Map<String, String> headers,
  required List<String> protocols,
}) {
  if (headers.isNotEmpty) {
    throw UnsupportedError('Browser WebSockets cannot use custom headers.');
  }
  return WebSocket.connect(url, protocols: protocols);
}
