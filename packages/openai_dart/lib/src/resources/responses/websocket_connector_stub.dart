import 'package:web_socket/web_socket.dart';

/// Responses connector for platforms without a WebSocket implementation.
Future<WebSocket> connectResponsesWebSocket(
  Uri uri, {
  Map<String, String>? headers,
}) => throw UnsupportedError(
  'Responses WebSocket connections are not supported on this platform.',
);
