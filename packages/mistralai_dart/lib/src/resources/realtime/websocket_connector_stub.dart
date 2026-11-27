import 'package:web_socket/web_socket.dart';

/// Whether the platform is a browser.
const isRealtimeBrowser = false;

/// Attempts to open a WebSocket on an unsupported platform.
Future<WebSocket> connectRealtimeWebSocket(
  Uri url, {
  required Map<String, String> headers,
  required List<String> protocols,
}) => throw UnsupportedError('Realtime WebSockets are unavailable.');
