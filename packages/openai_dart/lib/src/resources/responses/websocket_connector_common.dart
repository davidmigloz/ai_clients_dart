import 'dart:convert';

import '../../errors/exceptions.dart';

/// Browser rejection of unsupported handshake headers, before any dial.
///
/// Diagnostics expose header names only and never their values or the URL.
class ResponsesBrowserHeadersException extends ConnectionException {
  /// Creates a safe diagnostic listing the supplied header names.
  ResponsesBrowserHeadersException(Iterable<String> headerNames)
    : super(
        message:
            'Browser WebSockets cannot set custom headers '
            '(received keys: ${headerNames.join(', ')}). '
            'Use an authenticated backend WebSocket proxy for the Responses API, '
            'and open a headerless connection to that proxy.',
      );
}

/// Validates a browser handshake before invoking the browser WebSocket API.
void validateResponsesBrowserHandshake(Uri uri, Map<String, String>? headers) {
  if (headers != null && headers.isNotEmpty) {
    throw ResponsesBrowserHeadersException(headers.keys);
  }
  validateResponsesWebSocketUri(uri);
}

/// Validates the protocol's caller-supplied close parameters without logging
/// the potentially sensitive close reason.
void validateResponsesClose(int? code, String? reason) {
  if (code != null && code != 1000 && (code < 3000 || code > 4999)) {
    throw ArgumentError.value(
      code,
      'code',
      'must be 1000 or in range 3000-4999',
    );
  }
  if (reason != null && utf8.encode(reason).length > 123) {
    throw ArgumentError('reason must be at most 123 UTF-8 bytes');
  }
}

/// Checks the scheme without including credentials or query values in errors.
void validateResponsesWebSocketUri(Uri uri) {
  if (!uri.isScheme('ws') && !uri.isScheme('wss')) {
    throw ArgumentError('Responses WebSocket URL must use ws or wss');
  }
}

/// URL context safe to include in connector diagnostics.
String safeResponsesWebSocketUrl(Uri uri) => Uri(
  scheme: uri.scheme,
  host: uri.host,
  port: uri.hasPort ? uri.port : null,
  path: uri.path,
).toString();
