import 'dart:convert';

import '../../errors/exceptions.dart';

/// Unsupported browser handshake headers, rejected before authentication.
class LiveBrowserHeadersException extends ConnectionException {
  /// Creates a diagnostic without retaining header values or a URL.
  LiveBrowserHeadersException(Iterable<String> headerNames)
    : super(
        message:
            'Browser Live WebSockets cannot set custom headers '
            '(received keys: ${headerNames.join(', ')}). '
            'Use trusted backend HTTP signaling with a caller-owned WebRTC '
            'data channel, or an authenticated backend WebSocket proxy.',
        redactDiagnostics: true,
      );
}

/// Rejects all nonempty browser header maps before invoking the browser API.
void validateLiveBrowserHandshake(Uri uri, Map<String, String>? headers) {
  if (headers != null && headers.isNotEmpty) {
    throw LiveBrowserHeadersException(headers.keys);
  }
  validateLiveWebSocketUri(uri);
}

/// Validates outbound close parameters without exposing the close reason.
void validateLiveClose(int? code, String? reason) {
  if (code != null &&
      (!code.isFinite || (code != 1000 && (code < 3000 || code > 4999)))) {
    throw ArgumentError('Live close code must be 1000 or in range 3000-4999.');
  }
  if (reason != null && utf8.encode(reason).length > 123) {
    throw ArgumentError('Live close reason must be at most 123 UTF-8 bytes.');
  }
}

/// Validates a connector URL without retaining its contents in diagnostics.
void validateLiveWebSocketUri(Uri uri) {
  if (!uri.isScheme('ws') && !uri.isScheme('wss')) {
    throw ArgumentError('Live WebSocket URL must use ws or wss.');
  }
}
