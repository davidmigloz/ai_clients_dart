import 'package:web_socket/web_socket.dart';

export 'websocket_connector_common.dart';
export 'websocket_connector_stub.dart'
    if (dart.library.io) 'websocket_connector_io.dart'
    if (dart.library.js_interop) 'websocket_connector_web.dart';

/// Opens one socket with per-attempt URL and freshly resolved headers.
///
/// Wrap the native connector in a closure to preserve custom transport options
/// such as a caller-owned HttpClient, compression or protocols across attempts.
typedef RealtimeWebSocketConnector =
    Future<WebSocket> Function(Uri uri, {Map<String, String>? headers});
