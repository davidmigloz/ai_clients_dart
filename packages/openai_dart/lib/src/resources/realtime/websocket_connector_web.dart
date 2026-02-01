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
            'OpenAI Realtime API requires Authorization headers which are not '
            'supported by browser WebSocket connections. '
            'On web platforms, use ephemeral tokens obtained from the '
            'realtimeSessions.create() endpoint for authentication. '
            'Direct Realtime API connections with API keys are only '
            'supported on native platforms (server, CLI, mobile).',
        url: uri.toString(),
      );
    }
  }

  // Use the web_socket package for browser connections
  return WebSocket.connect(uri);
}
