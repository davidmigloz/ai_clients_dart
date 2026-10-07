import 'package:web_socket/web_socket.dart';

export 'websocket_connector_common.dart' show ResponsesBrowserHeadersException;
export 'websocket_connector_stub.dart'
    if (dart.library.io) 'websocket_connector_io.dart'
    if (dart.library.js_interop) 'websocket_connector_web.dart';

/// Opens a Responses WebSocket, with handshake headers on native platforms.
///
/// A browser connector must reject nonempty [headers]. Browser applications
/// should use an authenticated backend proxy with a headerless client socket.
typedef ResponsesWebSocketConnector =
    Future<WebSocket> Function(Uri uri, {Map<String, String>? headers});
