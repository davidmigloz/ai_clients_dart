import 'package:web_socket/web_socket.dart';

export 'websocket_connector_stub.dart'
    if (dart.library.io) 'websocket_connector_io.dart'
    if (dart.library.js_interop) 'websocket_connector_web.dart';

/// Opens a WebSocket with resolved handshake parameters.
///
/// Browser authentication uses [protocols] without custom [headers].
typedef RealtimeWebSocketConnector =
    Future<WebSocket> Function(
      Uri url, {
      required Map<String, String> headers,
      required List<String> protocols,
    });
