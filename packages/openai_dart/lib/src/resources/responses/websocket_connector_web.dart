import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

import '../../errors/exceptions.dart';
import 'websocket_connector_common.dart';

/// Opens a headerless browser WebSocket to a Responses backend proxy.
///
/// Browsers cannot send any custom handshake headers. Configure authentication
/// on your backend proxy rather than passing an API key to this connector.
Future<WebSocket> connectResponsesWebSocket(
  Uri uri, {
  Map<String, String>? headers,
}) {
  validateResponsesBrowserHandshake(uri, headers);
  return _connectHeaderless(uri);
}

Future<WebSocket> _connectHeaderless(Uri uri) async {
  try {
    return await _ResponsesBrowserWebSocket(
      _BrowserSocket(uri.toString()),
    ).opened;
  } catch (_) {
    throw ConnectionException(
      message: 'Responses WebSocket handshake failed.',
      url: safeResponsesWebSocketUrl(uri),
    );
  }
}

class _ResponsesBrowserWebSocket implements WebSocket {
  _ResponsesBrowserWebSocket(this._socket) {
    _socket.binaryType = 'arraybuffer';
    _onOpen = ((JSObject _) => _handleOpen()).toJS;
    _onMessage = ((JSObject event) => _handleMessage(
      _BrowserMessage(event),
    )).toJS;
    _onError = ((JSObject _) => _handleError()).toJS;
    _onClose = ((JSObject event) {
      final close = _BrowserClose(event);
      _handleClose(close.code, close.reason);
    }).toJS;
    _socket
      ..addEventListener('open', _onOpen)
      ..addEventListener('message', _onMessage)
      ..addEventListener('error', _onError)
      ..addEventListener('close', _onClose);
    if (_socket.readyState == 1) _handleOpen();
  }

  final _BrowserSocket _socket;
  final StreamController<WebSocketEvent> _events = StreamController();
  final Completer<WebSocket> _opened = Completer();
  final Completer<void> _transportDone = Completer();
  late final JSFunction _onOpen;
  late final JSFunction _onMessage;
  late final JSFunction _onError;
  late final JSFunction _onClose;
  bool _closed = false;
  bool _closing = false;
  Future<void>? _closeFuture;

  Future<WebSocket> get opened => _opened.future;

  void _handleOpen() {
    if (!_opened.isCompleted) _opened.complete(this);
  }

  void _handleMessage(_BrowserMessage event) {
    if (_closed) return;
    final data = event.data;
    if (data != null && data.typeofEquals('string')) {
      _events.add(TextDataReceived((data as JSString).toDart));
    } else if (data != null && data.instanceOfString('ArrayBuffer')) {
      _events.add(
        BinaryDataReceived((data as JSArrayBuffer).toDart.asUint8List()),
      );
    } else {
      _events.addError(
        WebSocketException('Responses WebSocket frame is unsupported.'),
      );
    }
  }

  void _handleError() {
    if (_closed) return;
    final error = WebSocketException('Responses WebSocket transport failed.');
    if (!_opened.isCompleted) {
      _opened.completeError(error);
    } else {
      _events.addError(error);
    }
  }

  void _handleClose(int? code, String reason) {
    if (_closed) return;
    _closed = true;
    _socket
      ..removeEventListener('open', _onOpen)
      ..removeEventListener('message', _onMessage)
      ..removeEventListener('error', _onError)
      ..removeEventListener('close', _onClose);
    if (!_opened.isCompleted) {
      _opened.completeError(
        WebSocketException('Responses WebSocket closed before opening.'),
      );
    }
    _events.add(CloseReceived(code, reason));
    unawaited(_events.close());
    _transportDone.complete();
  }

  void _ensureOpen() {
    if (_closed || _closing || _socket.readyState != 1) {
      throw WebSocketConnectionClosed();
    }
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => _socket.protocol;

  @override
  void sendBytes(Uint8List bytes) {
    _ensureOpen();
    try {
      _socket.send(bytes.toJS);
    } catch (_) {
      throw WebSocketException('Responses WebSocket send failed.');
    }
  }

  @override
  void sendText(String text) {
    _ensureOpen();
    try {
      _socket.send(text.toJS);
    } catch (_) {
      throw WebSocketException('Responses WebSocket send failed.');
    }
  }

  @override
  Future<void> close([int? code, String? reason]) {
    validateResponsesClose(code, reason);
    if (_closeFuture case final future?) return future;
    if (_closed) return Future.value();
    _closing = true;
    return _closeFuture = _close(reason != null ? code ?? 1000 : code, reason);
  }

  Future<void> _close(int? code, String? reason) async {
    try {
      if (code != null && reason != null) {
        _socket.close(code, reason);
      } else if (code != null) {
        _socket.close(code);
      } else {
        _socket.close();
      }
      // Keep browser listeners until the actual close notification, retaining
      // its code and reason before releasing the event stream.
      await _transportDone.future;
    } catch (_) {
      _handleClose(null, '');
      throw WebSocketException('Responses WebSocket close failed.');
    }
  }
}

@JS('WebSocket')
extension type _BrowserSocket._(JSObject _) implements JSObject {
  external factory _BrowserSocket(String url);
  external int get readyState;
  external String get protocol;
  external String get binaryType;
  external set binaryType(String value);
  external void send(JSAny data);
  external void close([int? code, String? reason]);
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
}

extension type _BrowserMessage(JSObject _) implements JSObject {
  external JSAny? get data;
}

extension type _BrowserClose(JSObject _) implements JSObject {
  external int get code;
  external String get reason;
}
