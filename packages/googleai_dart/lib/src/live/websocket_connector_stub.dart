import 'package:web_socket/web_socket.dart';

/// Stub implementation for unsupported platforms.
Future<WebSocket> connectWebSocket(
  Uri uri, {
  Map<String, String>? headers,
  Future<void>? abort,
}) {
  throw UnsupportedError(
    'WebSocket connections are not supported on this platform.',
  );
}
