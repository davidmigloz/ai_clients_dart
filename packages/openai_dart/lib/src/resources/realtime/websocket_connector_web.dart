import 'package:web_socket/web_socket.dart';

import 'websocket_connector_common.dart';

/// Whether the platform default uses the browser WebSocket API.
const isRealtimeBrowserWebSocket = true;

/// Opens a headerless browser connection to a trusted backend proxy.
Future<WebSocket> connectWebSocket(Uri uri, {Map<String, String>? headers}) {
  validateRealtimeBrowserHandshake(uri, headers);
  return WebSocket.connect(uri);
}
