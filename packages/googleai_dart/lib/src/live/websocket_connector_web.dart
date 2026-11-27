import 'package:web_socket/web_socket.dart';

import '../errors/exceptions.dart';

/// Browser WebSockets cannot send custom upgrade headers.
Future<WebSocket> connectWebSocket(Uri uri, {Map<String, String>? headers}) {
  if (headers != null && headers.isNotEmpty) {
    final authorization = headers['Authorization'];
    final message = authorization != null && authorization.startsWith('Token ')
        ? 'Browser Live connections require a Gemini ephemeral token in the '
              'query. Use connect(accessToken: ...) or an '
              'EphemeralTokenProvider with query placement.'
        : 'Vertex AI Live requires OAuth headers, which browser WebSockets '
              'cannot send. Use a native client or connect to the Gemini '
              'Developer API with a short-lived ephemeral token.';
    throw LiveConnectionException(message: message);
  }
  return WebSocket.connect(uri);
}
