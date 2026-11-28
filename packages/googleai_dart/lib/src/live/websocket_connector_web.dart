import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;
import 'package:web_socket/web_socket.dart';

import '../errors/exceptions.dart';

/// Browser WebSockets cannot send custom upgrade headers.
Future<WebSocket> connectWebSocket(
  Uri uri, {
  Map<String, String>? headers,
  Future<void>? abort,
}) {
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
  if (abort == null) return WebSocket.connect(uri);
  final socket = _CancellableWebSocket(web.WebSocket(uri.toString()));
  abort.then((_) => socket.abortUpgrade()).ignore();
  return socket.connected;
}

/// Keeps the native browser socket accessible while its upgrade is pending.
class _CancellableWebSocket implements WebSocket {
  final web.WebSocket _socket;
  final _connected = Completer<WebSocket>();
  final _events = StreamController<WebSocketEvent>();
  final _detach = <Future<void> Function()>[];

  _CancellableWebSocket(this._socket) {
    _socket.binaryType = 'arraybuffer';
    _detach.addAll([
      _socket.onOpen.listen((_) => _connected.complete(this)).cancel,
      _socket.onMessage.listen(_onMessage).cancel,
      _socket.onError.listen((_) => _finish(1006, 'error')).cancel,
      _socket.onClose
          .listen((event) => _finish(event.code, event.reason))
          .cancel,
    ]);
  }

  Future<WebSocket> get connected => _connected.future;

  void abortUpgrade() {
    if (_connected.isCompleted) return;
    _finish();
    _socket.close();
  }

  void _onMessage(web.MessageEvent event) {
    final data = event.data;
    if (data != null && data.typeofEquals('string')) {
      _events.add(TextDataReceived((data as JSString).toDart));
    } else if (data != null && data.isA<JSArrayBuffer>()) {
      _events.add(
        BinaryDataReceived((data as JSArrayBuffer).toDart.asUint8List()),
      );
    } else {
      _events.addError(WebSocketException('Unexpected browser WebSocket data'));
    }
  }

  void _finish([int? code, String? reason]) {
    if (_events.isClosed) return;
    if (!_connected.isCompleted) {
      _connected.completeError(
        WebSocketException('Failed to connect WebSocket'),
      );
    } else if (code != null) {
      _events.add(CloseReceived(code, reason ?? ''));
    }
    unawaited(_events.close());
    for (final detach in _detach) {
      unawaited(detach());
    }
    _detach.clear();
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => _socket.protocol;

  @override
  void sendText(String text) {
    if (_events.isClosed) throw WebSocketConnectionClosed();
    _socket.send(text.toJS);
  }

  @override
  void sendBytes(Uint8List bytes) {
    if (_events.isClosed) throw WebSocketConnectionClosed();
    _socket.send(bytes.toJS);
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    if (_events.isClosed) throw WebSocketConnectionClosed();
    if (code != null && code != 1000 && !(code >= 3000 && code <= 4999)) {
      throw ArgumentError.value(code, 'code', 'must be 1000 or in 3000-4999');
    }
    if (reason != null && utf8.encode(reason).length > 123) {
      throw ArgumentError.value(reason, 'reason', 'must be at most 123 bytes');
    }
    _finish();
    if (code == null) {
      _socket.close();
    } else if (reason == null) {
      _socket.close(code);
    } else {
      _socket.close(code, reason);
    }
  }
}
