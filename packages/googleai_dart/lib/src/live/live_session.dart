import 'dart:async' show StreamController, StreamSubscription, unawaited;
import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:web_socket/web_socket.dart';

import '../errors/exceptions.dart';
import '../models/content/content.dart';
import '../models/live/messages/client/client_message.dart';
import '../models/live/messages/server/server_message.dart';
import '../models/tools/function_response.dart';

/// A live streaming session with the Gemini Live API.
///
/// Provides bidirectional real-time communication for audio, video, and text.
///
/// ## Example
///
/// ```dart
/// final session = await liveClient.connect(model: 'gemini-2.0-flash-live-001');
///
/// // Send text
/// session.sendText('Hello!');
///
/// // Send audio (16kHz, 16-bit, mono PCM)
/// session.sendAudio(pcmBytes);
///
/// // Handle responses
/// await for (final message in session.messages) {
///   switch (message) {
///     case BidiGenerateContentServerContent(:final modelTurn):
///       // Handle model response
///     case BidiGenerateContentToolCall(:final functionCalls):
///       // Handle tool calls
///       session.sendToolResponse(responses);
///   }
/// }
///
/// await session.close();
/// ```
class LiveSession {
  final WebSocket _socket;
  final StreamController<BidiGenerateContentServerMessage> _messageController;
  final String Function(String)? _redactDiagnostic;
  void Function(LiveSession)? _onClosed;
  StreamSubscription<WebSocketEvent>? _subscription;
  bool _isConnected = true;
  SessionResumptionUpdate? _lastResumableUpdate;

  /// Session ID returned by the server after setup.
  String? sessionId;

  /// Latest resumption token for session resumption.
  String? resumptionToken;

  /// Whether the session can be resumed.
  bool? resumable;

  /// The most recent resumable checkpoint, if the server sent one.
  ///
  /// It may describe an earlier state while [resumable] is false. Reusing
  /// that older handle can lose messages sent after its acknowledged index.
  SessionResumptionUpdate? get lastResumableUpdate => _lastResumableUpdate;

  LiveSession._(this._socket, this._onClosed, this._redactDiagnostic)
    : _messageController = StreamController.broadcast();

  /// Creates a new [LiveSession] from an established WebSocket connection.
  factory LiveSession.fromWebSocket(WebSocket socket) =>
      LiveSession.attach(socket);

  /// Attaches a socket whose lifetime is tracked by `LiveClient`.
  @internal
  factory LiveSession.attach(
    WebSocket socket, {
    void Function(LiveSession)? onClosed,
    String Function(String)? redactDiagnostic,
  }) => LiveSession._(socket, onClosed, redactDiagnostic).._startListening();

  void _startListening() {
    _subscription = _socket.events.listen(
      _handleEvent,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  void _handleEvent(WebSocketEvent event) {
    switch (event) {
      case TextDataReceived(:final text):
        _parseAndEmitMessage(text: text);
      case BinaryDataReceived(:final data):
        _parseAndEmitMessage(bytes: data);
      case CloseReceived(:final code, :final reason):
        if (!_messageController.isClosed) {
          _messageController.addError(
            LiveSessionClosedException(
              code: code,
              reason: _redactDiagnostic?.call(reason) ?? reason,
            ),
          );
        }
        _handleDone();
    }
  }

  void _parseAndEmitMessage({String? text, Uint8List? bytes}) {
    if (_messageController.isClosed) return;
    try {
      final json =
          jsonDecode(text ?? utf8.decode(bytes!)) as Map<String, dynamic>;
      final message = BidiGenerateContentServerMessage.fromJson(json);

      // Track session state
      switch (message) {
        case BidiGenerateContentSetupComplete(:final sessionId):
          this.sessionId = sessionId;
        case final SessionResumptionUpdate update:
          final newHandle = update.newHandle;
          resumptionToken = newHandle;
          resumable = update.resumable;
          if (newHandle != null && newHandle.isNotEmpty && resumable != false) {
            _lastResumableUpdate = update;
          }
        default:
          break;
      }

      _messageController.add(message);
    } on FormatException {
      _messageController.addError(
        const LiveSessionException(
          message: 'Failed to parse a Live server message.',
        ),
      );
    } on TypeError {
      _messageController.addError(
        const LiveSessionException(
          message: 'Invalid Live server message fields.',
        ),
      );
    }
  }

  void _handleError(Object error) {
    if (!_messageController.isClosed) {
      _messageController.addError(
        LiveSessionException(
          message: 'Live WebSocket transport failed (${error.runtimeType}).',
        ),
      );
    }
  }

  void _handleDone() {
    _isConnected = false;
    final onClosed = _onClosed;
    _onClosed = null;
    onClosed?.call(this);
    if (!_messageController.isClosed) {
      unawaited(_messageController.close());
    }
  }

  /// Whether the session is currently connected.
  bool get isConnected => _isConnected;

  /// Stream of server messages.
  ///
  /// Listen to this stream to receive model responses, tool calls,
  /// and other server events.
  Stream<BidiGenerateContentServerMessage> get messages =>
      _messageController.stream;

  /// Sends a raw message to the server.
  void send(BidiGenerateContentClientMessage message) {
    if (!_isConnected) {
      throw const LiveSessionClosedException();
    }
    final json = jsonEncode(message.toJson());
    _socket.sendText(json);
  }

  /// Sends audio data to the server.
  ///
  /// Audio must be:
  /// - Format: Linear PCM
  /// - Sample rate: 16,000 Hz
  /// - Bit depth: 16-bit signed little-endian
  /// - Channels: Mono
  void sendAudio(List<int> pcmBytes) {
    send(BidiGenerateContentRealtimeInput.audio(pcmBytes));
  }

  /// Sends text input to the server.
  void sendText(String text) {
    send(BidiGenerateContentRealtimeInput.textInput(text));
  }

  /// Sends conversation context/turns to the server.
  void sendContent({required List<Content> turns, bool? turnComplete}) {
    send(
      BidiGenerateContentClientContent(
        turns: turns,
        turnComplete: turnComplete,
      ),
    );
  }

  /// Sends tool responses to the server.
  ///
  /// Call this after receiving a [BidiGenerateContentToolCall] with the
  /// results of executing the requested tools.
  void sendToolResponse(List<FunctionResponse> responses) {
    send(BidiGenerateContentToolResponse(functionResponses: responses));
  }

  /// Signals that user activity has started (manual VAD mode).
  ///
  /// Use this when `automaticActivityDetection.disabled` is `true`
  /// in the session configuration.
  void signalActivityStart() {
    send(BidiGenerateContentRealtimeInput.startActivity());
  }

  /// Signals that user activity has ended (manual VAD mode).
  ///
  /// Use this when `automaticActivityDetection.disabled` is `true`
  /// in the session configuration.
  void signalActivityEnd() {
    send(BidiGenerateContentRealtimeInput.endActivity());
  }

  /// Flushes audio input when automatic activity detection is enabled.
  ///
  /// You can resume sending audio after this signal. When using manual
  /// activity detection, mark the end of a turn with [signalActivityEnd].
  void signalAudioStreamEnd() {
    send(const BidiGenerateContentRealtimeInput(audioStreamEnd: true));
  }

  /// Closes the session.
  ///
  /// After calling this, the session can no longer send or receive messages.
  /// If session resumption is enabled, save the [resumptionToken] before
  /// closing to resume the session later.
  ///
  /// A paused message subscription receives its done event when resumed.
  ///
  /// This is idempotent and safe to call when the connection has already been
  /// closed (for example, when the server closed it first, or when [close] is
  /// called more than once).
  Future<void> close([int? code, String? reason]) async {
    _isConnected = false;
    try {
      try {
        await _subscription?.cancel();
      } finally {
        try {
          await _socket.close(code, reason);
        } on WebSocketConnectionClosed {
          // A peer close or another caller may have closed the socket first.
        }
      }
    } finally {
      _handleDone();
    }
  }
}
