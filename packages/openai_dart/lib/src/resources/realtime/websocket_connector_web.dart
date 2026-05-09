import 'package:web_socket/web_socket.dart';

import '../../errors/exceptions.dart';

/// Web implementation using the web_socket package.
///
/// Web browsers do not support custom headers on WebSocket connections,
/// so OpenAI API tokens cannot be passed via Authorization header.
/// In this case, an error is thrown with guidance.
Future<WebSocket> connectWebSocket(Uri uri, {Map<String, String>? headers}) {
  // Web browsers don't support custom headers on WebSocket connections
  if (headers != null && headers.isNotEmpty) {
    // Check if this is an Authorization header (required for OpenAI Realtime API)
    if (headers.containsKey('Authorization')) {
      throw ConnectionException(
        message:
            'OpenAI Realtime API requires Authorization headers, which the '
            'browser WebSocket API does not allow. The Realtime WebSocket '
            'transport is supported on server / CLI / mobile only. '
            'For browser-based realtime, use the WebRTC transport: open a '
            'peer connection client-side, generate an SDP offer, and POST '
            'it via `client.realtimeSessions.calls.create(...)` (the SDK '
            'handles the SDP answer + ephemeral auth). For SIP / phone '
            'integrations, use `realtimeSessions.calls.accept/refer/hangup`. '
            'Alternatively, route the WebSocket through a server-side '
            'proxy that can set the Authorization header on your behalf.',
        url: uri.toString(),
      );
    }
  }

  // Use the web_socket package for browser connections
  return WebSocket.connect(uri);
}
