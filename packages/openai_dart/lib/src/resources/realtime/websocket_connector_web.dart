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
            'On web platforms, obtain an ephemeral client secret '
            'server-side via realtimeSessions.createClientSecret(...) '
            '(or createTranscriptionClientSecret(...) for transcription) '
            'and use the returned `ek_…` value as the bearer token. '
            'Direct Realtime API connections with the main API key are '
            'only supported on native platforms (server, CLI, mobile).',
        url: uri.toString(),
      );
    }
  }

  // Use the web_socket package for browser connections
  return WebSocket.connect(uri);
}
