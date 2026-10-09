import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web_socket/web_socket.dart';

import '../../errors/exceptions.dart';
import 'websocket_connector_common.dart';

/// Whether the default connector is subject to browser header limits.
const isLiveBrowserWebSocket = true;

/// Opens a headerless browser WebSocket to a Live backend proxy.
///
/// Browsers cannot send any custom handshake headers. Configure authentication
/// on your backend proxy rather than passing an API key to this connector.
Future<WebSocket> connectLiveWebSocket(
  Uri uri, {
  Map<String, String>? headers,
}) {
  validateLiveBrowserHandshake(uri, headers);
  return _connectHeaderless(uri);
}

Future<WebSocket> _connectHeaderless(Uri uri) async {
  try {
    return await _LiveBrowserWebSocket(_BrowserSocket(uri.toString())).opened;
  } catch (error) {
    throw ConnectionException(
      message: 'Live WebSocket handshake failed.',
      url: uri.toString(),
      cause: error,
      redactDiagnostics: true,
    );
  }
}

class _LiveBrowserWebSocket implements WebSocket {
  _LiveBrowserWebSocket(this._socket) {
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
  late final StreamController<WebSocketEvent> _events = StreamController(
    onCancel: _cancelReader,
  );
  final Completer<WebSocket> _opened = Completer();
  final Completer<void> _transportDone = Completer();
  late final JSFunction _onOpen;
  late final JSFunction _onMessage;
  late final JSFunction _onError;
  late final JSFunction _onClose;
  bool _closed = false;
  bool _readerDetached = false;
  bool _closing = false;
  Future<void>? _closeFuture;

  Future<WebSocket> get opened => _opened.future;

  void _handleOpen() {
    if (!_opened.isCompleted) _opened.complete(this);
  }

  void _handleMessage(_BrowserMessage event) {
    if (_closed || _readerDetached) return;
    final data = event.data;
    if (data != null && data.typeofEquals('string')) {
      _events.add(TextDataReceived((data as JSString).toDart));
    } else if (data != null && data.instanceOfString('ArrayBuffer')) {
      _events.add(
        BinaryDataReceived((data as JSArrayBuffer).toDart.asUint8List()),
      );
    } else {
      _events.addError(
        WebSocketException('Live WebSocket frame is unsupported.'),
      );
    }
  }

  void _handleError() {
    if (_closed || _readerDetached) return;
    final error = WebSocketException('Live WebSocket transport failed.');
    if (!_opened.isCompleted) {
      _opened.completeError(error);
    } else {
      _events.addError(error);
    }
  }

  void _handleClose(int? code, String reason) {
    if (_closed || _readerDetached) return;
    _closed = true;
    _detachListeners();
    if (!_opened.isCompleted) {
      _opened.completeError(
        WebSocketException('Live WebSocket closed before opening.'),
      );
    }
    _events.add(CloseReceived(code, reason));
    unawaited(_events.close());
    if (!_transportDone.isCompleted) _transportDone.complete();
  }

  void _detachListeners() {
    if (_readerDetached) return;
    _readerDetached = true;
    _socket
      ..removeEventListener('open', _onOpen)
      ..removeEventListener('message', _onMessage)
      ..removeEventListener('error', _onError)
      ..removeEventListener('close', _onClose);
  }

  void _cancelReader() {
    // A bounded connection cleanup cannot depend on a browser close event
    // which may never arrive. Detach only our listeners; never close borrowed
    // caller media or invent a peer close code/reason.
    _detachListeners();
    if (!_transportDone.isCompleted) _transportDone.complete();
    if (!_events.isClosed) unawaited(_events.close());
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
    } catch (error) {
      throw ConnectionException(
        message: 'Live WebSocket send failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
  }

  @override
  void sendText(String text) {
    _ensureOpen();
    try {
      _socket.send(text.toJS);
    } catch (error) {
      throw ConnectionException(
        message: 'Live WebSocket send failed.',
        cause: error,
        redactDiagnostics: true,
      );
    }
  }

  @override
  Future<void> close([int? code, String? reason]) {
    validateLiveClose(code, reason);
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
    } catch (error) {
      // Local failures release the reader without fabricating a peer close.
      _closed = true;
      _detachListeners();
      if (!_events.isClosed) unawaited(_events.close());
      if (!_transportDone.isCompleted) _transportDone.complete();
      throw ConnectionException(
        message: 'Live WebSocket close failed.',
        cause: error,
        redactDiagnostics: true,
      );
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
