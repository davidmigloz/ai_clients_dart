import 'package:web_socket/web_socket.dart';

/// Whether the default connector is subject to browser header limits.
const isLiveBrowserWebSocket = false;

/// Live connector for platforms without a WebSocket implementation.
Future<WebSocket> connectLiveWebSocket(
  Uri uri, {
  Map<String, String>? headers,
}) => throw UnsupportedError(
  'Live WebSocket connections are not supported on this platform.',
);
