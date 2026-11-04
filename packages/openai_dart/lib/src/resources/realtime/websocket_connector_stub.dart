import 'package:web_socket/web_socket.dart';

/// Whether the platform default uses the browser WebSocket API.
const isRealtimeBrowserWebSocket = false;

/// Stub implementation for unsupported platforms.
Future<WebSocket> connectWebSocket(Uri uri, {Map<String, String>? headers}) {
  throw UnsupportedError(
    'WebSocket connections are not supported on this platform.',
  );
}
