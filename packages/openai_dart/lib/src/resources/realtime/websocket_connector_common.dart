import 'dart:convert';

import '../../errors/exceptions.dart';

/// Browser rejection of unsupported handshake headers, before any dial.
class RealtimeBrowserHeadersException extends ConnectionException {
  /// Lists header names without exposing their values or the connection URL.
  RealtimeBrowserHeadersException(Iterable<String> headerNames)
    : super(
        message:
            'Browser WebSockets cannot set custom headers '
            '(received keys: ${headerNames.join(', ')}). '
            'Use WebRTC via client.realtimeSessions.calls.create(...) or '
            'an authenticated backend WebSocket proxy.',
      );
}

/// Rejects every custom browser header, regardless of its spelling.
void validateRealtimeBrowserHandshake(Uri uri, Map<String, String>? headers) {
  if (headers != null && headers.isNotEmpty) {
    throw RealtimeBrowserHeadersException(headers.keys);
  }
  validateRealtimeWebSocketUri(uri);
}

/// Validates a URL without including credentials or query values in diagnostics.
void validateRealtimeWebSocketUri(Uri uri) {
  if ((!uri.isScheme('ws') && !uri.isScheme('wss')) ||
      uri.host.isEmpty ||
      uri.hasFragment) {
    throw ArgumentError(
      'Realtime WebSocket URL must use ws or wss, have a host and no fragment.',
    );
  }
}

/// Validates caller close parameters using UTF-8 byte length.
void validateRealtimeClose(int? code, String? reason) {
  if (code != null && code != 1000 && (code < 3000 || code > 4999)) {
    throw ArgumentError('code must be 1000 or in range 3000-4999.');
  }
  if (reason != null && utf8.encode(reason).length > 123) {
    throw ArgumentError('reason must be at most 123 UTF-8 bytes.');
  }
}
