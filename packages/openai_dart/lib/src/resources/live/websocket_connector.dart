import 'package:web_socket/web_socket.dart';

export 'websocket_connector_common.dart' show LiveBrowserHeadersException;
export 'websocket_connector_stub.dart'
    if (dart.library.io) 'websocket_connector_io.dart'
    if (dart.library.js_interop) 'websocket_connector_web.dart';

/// Opens a Live socket. Native connectors support handshake headers.
///
/// Browser callers use a trusted backend proxy or a caller-owned media adapter.
typedef LiveWebSocketConnector =
    Future<WebSocket> Function(Uri uri, {Map<String, String>? headers});
