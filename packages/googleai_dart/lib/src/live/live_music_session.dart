part of 'live_music_client.dart';

/// An active bidirectional Lyria RealTime session.
class LiveMusicSession {
  static const _maxPendingMessages = 128;
  static const int _maxPendingPcmBytes = 4 * 1024 * 1024;

  LiveMusicSession._(
    this._socket, {
    required this._onClosed,
    required this._redact,
  });

  final WebSocket _socket;
  final void Function(LiveMusicSession) _onClosed;
  final String Function(String) _redact;
  final Completer<void> _setupComplete = Completer<void>();
  final _pending = <({LiveMusicServerMessage message, int pcmBytes})>[];
  late final _messages = StreamController<LiveMusicServerMessage>(
    sync: true,
    onListen: _scheduleDrain,
    onResume: _scheduleDrain,
    onCancel: _cancelReceiving,
  );
  StreamSubscription<WebSocketEvent>? _events;
  Future<void>? _closing;
  GoogleAIException? _terminalError;
  bool _isConnected = false;
  bool _drainScheduled = false;
  int _pendingPcmBytes = 0;

  /// Whether setup completed and the socket is still available.
  bool get isConnected => _isConnected;

  /// Output messages in delivery order.
  ///
  /// This single-subscription stream buffers up to 128 unread messages and
  /// at most 4 MiB of decoded audio. The session may discard older unread
  /// audio while a receiver is paused or absent. Warnings and other control
  /// messages stay ordered.
  /// If control messages fill the backlog, the session closes with a
  /// [LiveSessionException]. Cancel the subscription to close the session.
  Stream<LiveMusicServerMessage> get messages => _messages.stream;

  Future<void> _setup(String model) {
    _events = _socket.events.listen(
      _receive,
      onError: (Object error) => _fail(
        LiveSessionException(
          message: 'Live Music WebSocket error (${error.runtimeType}).',
        ),
      ),
      onDone: () => close().ignore(),
    );
    try {
      _socket.sendText(
        jsonEncode({
          'setup': {'model': model},
        }),
      );
    } catch (error) {
      _fail(
        LiveSessionException(
          message: 'Unable to send Live Music setup (${error.runtimeType}).',
        ),
      );
    }
    return _setupComplete.future;
  }

  void _receive(WebSocketEvent event) {
    if (_closing != null) return;
    try {
      switch (event) {
        case TextDataReceived(:final text):
          _receiveMessage(text);
        case BinaryDataReceived(:final data):
          _receiveMessage(utf8.decode(data));
        case CloseReceived(:final code, :final reason):
          if (!_isConnected || code != 1000) {
            _fail(
              LiveSessionClosedException(
                code: code,
                reason: reason.isEmpty ? null : _redact(reason),
              ),
            );
          } else {
            close().ignore();
          }
      }
    } on FormatException {
      _fail(
        const LiveSessionException(
          message: 'Invalid Live Music response frame.',
        ),
      );
    } on TypeError {
      _fail(
        const LiveSessionException(
          message: 'Invalid Live Music response fields.',
        ),
      );
    }
  }

  void _receiveMessage(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    final error =
        json['error'] ??
        (json['code'] is int && json['message'] is String ? json : null);
    if (error != null) {
      final value = error is Map<String, dynamic> ? error['message'] : error;
      final message = value is String
          ? _redact(value)
          : 'Live Music server error.';
      _fail(LiveSessionException(message: message));
      return;
    }
    final message = LiveMusicServerMessage.fromJson(json);
    if (!_isConnected) {
      if (message.setupComplete == null) {
        _fail(
          const LiveSessionException(
            message: 'Expected a Live Music setup acknowledgment.',
          ),
        );
        return;
      }
      _isConnected = true;
      _setupComplete.complete();
      return;
    }
    _enqueue(message);
  }

  void _enqueue(LiveMusicServerMessage message) {
    var pcmBytes = 0;
    for (final chunk
        in message.serverContent?.audioChunks ??
            const <LiveMusicAudioChunk>[]) {
      pcmBytes += chunk.data?.length ?? 0;
    }
    var entry = (message: message, pcmBytes: pcmBytes);
    if (pcmBytes > _maxPendingPcmBytes) {
      final control = _controlOnly(message);
      if (control == null) return;
      entry = (message: control, pcmBytes: 0);
    }
    while (_pending.length >= _maxPendingMessages ||
        _pendingPcmBytes + entry.pcmBytes > _maxPendingPcmBytes) {
      final oldestAudio = _pending.indexWhere(
        (queued) => queued.message.serverContent != null,
      );
      if (oldestAudio == -1) {
        if (entry.message.serverContent == null ||
            _controlOnly(entry.message) != null) {
          _fail(
            const LiveSessionException(
              message:
                  'The Live Music receiver backlog exceeded its message limit.',
            ),
          );
        }
        return;
      }
      final queued = _pending[oldestAudio];
      final control = _controlOnly(queued.message);
      if (control == null) {
        _pending.removeAt(oldestAudio);
      } else {
        _pending[oldestAudio] = (message: control, pcmBytes: 0);
      }
      _pendingPcmBytes -= queued.pcmBytes;
    }
    _pending.add(entry);
    _pendingPcmBytes += entry.pcmBytes;
    _scheduleDrain();
  }

  static LiveMusicServerMessage? _controlOnly(LiveMusicServerMessage message) {
    if (message.warning == null &&
        message.filteredPrompt == null &&
        message.setupComplete == null &&
        message.additionalProperties.isEmpty) {
      return null;
    }
    return LiveMusicServerMessage(
      setupComplete: message.setupComplete,
      filteredPrompt: message.filteredPrompt,
      warning: message.warning,
      additionalProperties: message.additionalProperties,
    );
  }

  void _scheduleDrain() {
    if (_drainScheduled || !_messages.hasListener || _messages.isClosed) return;
    _drainScheduled = true;
    scheduleMicrotask(() {
      _drainScheduled = false;
      while (_pending.isNotEmpty &&
          _messages.hasListener &&
          !_messages.isPaused) {
        final entry = _pending.removeAt(0);
        _pendingPcmBytes -= entry.pcmBytes;
        _messages.add(entry.message);
      }
      if (_closing != null && _messages.hasListener && !_messages.isPaused) {
        final error = _terminalError;
        if (error != null) _messages.addError(error, error.stackTrace);
        _messages.close().ignore();
      }
    });
  }

  Future<void> _cancelReceiving() {
    _pending.clear();
    _pendingPcmBytes = 0;
    return close();
  }

  void _fail(GoogleAIException error) {
    if (_closing != null) return;
    if (!_setupComplete.isCompleted) {
      _setupComplete.completeError(
        LiveSessionSetupException(message: error.message, cause: error),
      );
    } else {
      _terminalError = error;
    }
    close().ignore();
  }

  /// Replaces the weighted prompts used to generate music.
  void setWeightedPrompts(List<LiveMusicWeightedPrompt> prompts) {
    if (prompts.any((prompt) => !prompt.weight.isFinite) ||
        prompts.every((prompt) => prompt.weight == 0)) {
      throw ArgumentError(
        'Music prompts need finite weights and at least one nonzero weight.',
      );
    }
    _send({
      'clientContent': {
        'weightedPrompts': prompts.map((prompt) => prompt.toJson()).toList(),
      },
    });
  }

  /// Replaces the complete generation configuration.
  void setMusicGenerationConfig(LiveMusicGenerationConfig config) {
    _send({'musicGenerationConfig': config.toJson()});
  }

  /// Starts generating music or resumes from a pause.
  void play() => _send({'playbackControl': 'PLAY'});

  /// Pauses generation while keeping the current context.
  void pause() => _send({'playbackControl': 'PAUSE'});

  /// Stops generation and resets context while keeping the prompts.
  void stop() => _send({'playbackControl': 'STOP'});

  /// Resets context while keeping the prompts and playback state.
  void resetContext() => _send({'playbackControl': 'RESET_CONTEXT'});

  void _send(Map<String, dynamic> frame) {
    if (!_isConnected) throw const LiveSessionClosedException();
    try {
      _socket.sendText(jsonEncode(frame));
    } on WebSocketConnectionClosed {
      close().ignore();
      throw const LiveSessionClosedException();
    }
  }

  /// Closes this session and its output stream.
  ///
  /// Safe to call repeatedly, including after the remote end closed.
  Future<void> close() {
    final existing = _closing;
    if (existing != null) return existing;
    _isConnected = false;
    _closing = Future<void>.microtask(() async {
      try {
        await _events?.cancel();
      } finally {
        try {
          await _socket.close();
        } on WebSocketConnectionClosed {
          // The remote end has already closed the socket.
        } finally {
          _onClosed(this);
        }
      }
    });
    if (!_setupComplete.isCompleted) {
      _setupComplete.completeError(
        const LiveSessionSetupException(
          message: 'Connection closed before Live Music setup completed.',
        ),
      );
    }
    _scheduleDrain();
    return _closing!;
  }
}
