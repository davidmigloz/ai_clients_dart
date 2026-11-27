import 'dart:async';
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../../auth/auth_provider.dart';
import '../../client/config.dart';
import '../../client/request_builder.dart';
import '../../errors/exceptions.dart' as errors;
import '../../models/audio/speech_stream_event.dart';
import '../../models/audio/transcription_stream_event.dart';
import '../../models/realtime/realtime_event.dart';
import '../../models/realtime/realtime_speech.dart';
import '../../models/realtime/realtime_transcription.dart';
import '../../utils/request_id.dart';
import 'websocket_connector.dart';

export 'websocket_connector.dart' show RealtimeWebSocketConnector;

/// WebSocket client for realtime Voxtral transcription.
final class RealtimeTranscriptionResource {
  /// Creates a realtime transcription resource for a Mistral client.
  RealtimeTranscriptionResource({
    required MistralConfig config,
    required RequestBuilder requestBuilder,
    void Function()? ensureNotClosed,
  }) : _transport = _RealtimeTransport(config, requestBuilder, ensureNotClosed);

  final _RealtimeTransport _transport;

  /// Opens a caller-owned transcription connection for [model].
  ///
  /// On native platforms, the client's bearer credentials or
  /// [additionalHeaders] authenticate the handshake. In the browser, supply
  /// [clientToken] from your backend's realtime client session endpoint.
  ///
  /// The connection waits for the server to create the session and confirm any
  /// initial [options]. [abortTrigger] cancels opening or closes an active
  /// session. Always close the connection when finished.
  Future<RealtimeTranscriptionConnection> connect({
    required String model,
    RealtimeTranscriptionOptions? options,
    String? clientToken,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeWebSocketConnector? connector,
  }) async => RealtimeTranscriptionConnection._(
    await _transport.open(
      path: '/v1/audio/transcriptions/realtime',
      model: model,
      parseSession: RealtimeTranscriptionSession.fromJson,
      parseData: (type, json) => _transcriptionTypes.contains(type)
          ? TranscriptionStreamEvent.fromJson(json)
          : null,
      options: options?.toJson(),
      clientToken: clientToken,
      additionalHeaders: additionalHeaders,
      connectionTimeout: connectionTimeout,
      abortTrigger: abortTrigger,
      connector: connector,
    ),
  );

  /// Sends an audio stream and publishes transcription and turn events.
  ///
  /// [audio] contains raw audio frames in the configured format. Finish the
  /// input stream to receive a final transcript and close the connection.
  /// A server error or subscriber cancellation stops both streams.
  Stream<TranscriptionStreamEvent> transcribeStream({
    required String model,
    required Stream<List<int>> audio,
    RealtimeTranscriptionOptions? options,
    String? clientToken,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeWebSocketConnector? connector,
  }) => _duplex(
    open: (stop) async => (await connect(
      model: model,
      options: options,
      clientToken: clientToken,
      additionalHeaders: additionalHeaders,
      connectionTimeout: connectionTimeout,
      abortTrigger: stop,
      connector: connector,
    ))._wire,
    source: audio,
    send: (wire, chunk) =>
        wire.sendInput('input_audio.append', {'audio': base64Encode(chunk)}),
    finish: (wire) => wire.endInput('input_audio.end'),
    isTerminal: (event) => event.isDone,
    abortTrigger: abortTrigger,
  );

  static const _transcriptionTypes = {
    'transcription.language',
    'transcription.text.delta',
    'transcription.segment',
    'transcription.done',
    'turn.start',
    'turn.eager_end',
    'turn.resume',
    'turn.end',
  };
}

/// WebSocket client for realtime Voxtral speech generation.
final class RealtimeSpeechResource {
  /// Creates a realtime speech resource for a Mistral client.
  RealtimeSpeechResource({
    required MistralConfig config,
    required RequestBuilder requestBuilder,
    void Function()? ensureNotClosed,
  }) : _transport = _RealtimeTransport(config, requestBuilder, ensureNotClosed);

  final _RealtimeTransport _transport;

  /// Opens a caller-owned speech connection. This endpoint uses native bearer
  /// authentication.
  ///
  /// The connection waits for the server to create the session and confirm any
  /// initial [options]. [abortTrigger] cancels opening or closes an active
  /// session. Always close the connection when finished.
  Future<RealtimeSpeechConnection> connect({
    required String model,
    RealtimeSpeechOptions? options,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeWebSocketConnector? connector,
  }) async {
    if (options?.voiceId != null && options?.refAudio != null) {
      throw ArgumentError('Supply either voiceId or refAudio.');
    }
    return RealtimeSpeechConnection._(
      await _transport.open(
        path: '/v1/audio/speech/realtime',
        model: model,
        parseSession: RealtimeSpeechSession.fromJson,
        parseData: (type, json) => switch (type) {
          'speech.audio.delta' ||
          'speech.audio.done' => SpeechStreamEvent.fromJson(json),
          _ => null,
        },
        options: options?.toJson(),
        additionalHeaders: additionalHeaders,
        connectionTimeout: connectionTimeout,
        abortTrigger: abortTrigger,
        connector: connector,
      ),
    );
  }

  /// Sends text as it arrives and streams generated audio and usage.
  ///
  /// Finish [text] to complete the generation and close the connection.
  /// A server error or subscriber cancellation stops both streams.
  Stream<SpeechStreamEvent> speakStream({
    required String model,
    required Stream<String> text,
    RealtimeSpeechOptions? options,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeWebSocketConnector? connector,
  }) => _duplex(
    open: (stop) async => (await connect(
      model: model,
      options: options,
      additionalHeaders: additionalHeaders,
      connectionTimeout: connectionTimeout,
      abortTrigger: stop,
      connector: connector,
    ))._wire,
    source: text,
    send: (wire, delta) => wire.sendInput('input_text.append', {'text': delta}),
    finish: (wire) => wire.endInput('input_text.end'),
    isTerminal: (event) => event is SpeechStreamDone,
    abortTrigger: abortTrigger,
  );
}

/// An open realtime transcription WebSocket session.
final class RealtimeTranscriptionConnection {
  RealtimeTranscriptionConnection._(this._wire);

  final _RealtimeWire<RealtimeTranscriptionSession, TranscriptionStreamEvent>
  _wire;

  /// Current state, including the latest acknowledged configuration.
  RealtimeTranscriptionSession get session => _wire.session;

  /// A single-subscription stream of server frames. Cancelling releases
  /// the connection. API error frames remain inspectable in the stream.
  Stream<RealtimeEvent<RealtimeTranscriptionSession, TranscriptionStreamEvent>>
  get events => _wire.events;

  /// Completes when the socket reader and transport have been released.
  Future<void> get done => _wire.done;

  /// Whether the connection is closing or closed.
  bool get isClosed => _wire.isClosed;

  /// The close code reported by the peer, if any.
  int? get closeCode => _wire.closeCode;

  /// Applies settings and waits for the server's acknowledgment.
  Future<void> updateSession(RealtimeTranscriptionOptions options) =>
      _wire.update(options.toJson());

  /// Sends raw audio bytes in the configured encoding and sample rate.
  void sendAudio(List<int> bytes) =>
      _wire.sendInput('input_audio.append', {'audio': base64Encode(bytes)});

  /// Flushes buffered audio without ending the session.
  void flushAudio() => _wire.sendInput('input_audio.flush', const {});

  /// Ends audio input while allowing final transcription events to arrive.
  void endAudio() => _wire.endInput('input_audio.end');

  /// Closes the session and releases the socket.
  Future<void> close() => _wire.close();
}

/// An open realtime speech WebSocket session.
final class RealtimeSpeechConnection {
  RealtimeSpeechConnection._(this._wire);

  final _RealtimeWire<RealtimeSpeechSession, SpeechStreamEvent> _wire;

  /// Current state, including the latest acknowledged configuration.
  RealtimeSpeechSession get session => _wire.session;

  /// A single-subscription stream of server frames. Cancelling releases
  /// the connection. API error frames remain inspectable in the stream.
  Stream<RealtimeEvent<RealtimeSpeechSession, SpeechStreamEvent>> get events =>
      _wire.events;

  /// Completes when the socket reader and transport have been released.
  Future<void> get done => _wire.done;

  /// Whether the connection is closing or closed.
  bool get isClosed => _wire.isClosed;

  /// The close code reported by the peer, if any.
  int? get closeCode => _wire.closeCode;

  /// Applies settings and waits for the server's acknowledgment.
  Future<void> updateSession(RealtimeSpeechOptions options) {
    if (options.voiceId != null && options.refAudio != null) {
      throw ArgumentError('Supply either voiceId or refAudio.');
    }
    return _wire.update(options.toJson());
  }

  /// Appends text to the active generation.
  void sendText(String text) =>
      _wire.sendInput('input_text.append', {'text': text});

  /// Completes the current generation, optionally appending [text] first.
  /// Further generations can use the same session.
  void flush({String? text}) =>
      _wire.sendInput('input_text.flush', {'text': ?text});

  /// Ends text input while allowing final audio and usage to arrive.
  void end() => _wire.endInput('input_text.end');

  /// Closes the session and releases the socket.
  Future<void> close() => _wire.close();
}

final class _RealtimeTransport {
  const _RealtimeTransport(
    this.config,
    this.requestBuilder,
    this.ensureNotClosed,
  );

  final MistralConfig config;
  final RequestBuilder requestBuilder;
  final void Function()? ensureNotClosed;

  Future<_RealtimeWire<S, D>> open<S extends Object, D>({
    required String path,
    required String model,
    required S Function(Map<String, dynamic>) parseSession,
    required D? Function(String, Map<String, dynamic>) parseData,
    Map<String, dynamic>? options,
    String? clientToken,
    Map<String, String>? additionalHeaders,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeWebSocketConnector? connector,
  }) async {
    ensureNotClosed?.call();
    if (model.trim().isEmpty) throw ArgumentError('model must be non-empty.');
    final timeout = connectionTimeout ?? config.timeout;
    if (timeout <= Duration.zero) {
      throw ArgumentError('connectionTimeout must be positive.');
    }
    final uri = _socketUri(path, model);
    final protocols = _protocols(clientToken, additionalHeaders);
    final watch = Stopwatch()..start();
    final cancelled = Completer<_RealtimeWire<S, D>>();
    _RealtimeWire<S, D>? wire;
    var abandoned = false;
    var stage = errors.AbortionStage.beforeRequest;
    final requestId = generateRequestId();

    unawaited(
      abortTrigger?.then((_) {
        final error = errors.AbortedException(
          message: 'Realtime audio connection aborted by caller.',
          correlationId: requestId,
          timestamp: DateTime.now(),
          stage: stage,
        );
        wire?.abort(error);
        cancelled.completeError(error);
      }, onError: (Object _, StackTrace _) {}),
    );

    Future<_RealtimeWire<S, D>> negotiate() async {
      final headers = await _headers(clientToken, additionalHeaders);
      ensureNotClosed?.call();
      if (abandoned) {
        throw const RealtimeConnectionException('Connection abandoned.');
      }
      final bearer = headers.containsKey('authorization');
      if (uri.scheme == 'ws' &&
          (bearer || protocols.isNotEmpty) &&
          !const {'localhost', '127.0.0.1', '::1'}.contains(uri.host)) {
        throw ArgumentError(
          'Realtime credentials require a secure WebSocket URL.',
        );
      }
      stage = errors.AbortionStage.duringRequest;
      final WebSocket socket;
      try {
        socket = await (connector ?? connectRealtimeWebSocket)(
          uri,
          headers: Map.unmodifiable(headers),
          protocols: List.unmodifiable(protocols),
        );
      } catch (_) {
        throw const RealtimeConnectionException('WebSocket handshake failed.');
      }
      try {
        ensureNotClosed?.call();
        if (abandoned) {
          throw const RealtimeConnectionException('Connection abandoned.');
        }
        final current = _RealtimeWire(socket, parseSession, parseData, timeout);
        wire = current;
        await current.created;
        if (options != null && options.isNotEmpty) {
          await current.update(options);
        }
        ensureNotClosed?.call();
        stage = errors.AbortionStage.duringStream;
        return current;
      } catch (_) {
        if (wire case final current?) {
          current.close().ignore();
        } else {
          Future<void>.sync(socket.close).ignore();
        }
        rethrow;
      }
    }

    try {
      return await Future.any([
        negotiate(),
        if (abortTrigger != null) cancelled.future,
      ]).timeout(
        timeout,
        onTimeout: () => throw errors.TimeoutException(
          message: 'Starting the realtime audio session timed out.',
          timeout: timeout,
          elapsed: watch.elapsed,
        ),
      );
    } catch (_) {
      abandoned = true;
      wire?.close().ignore();
      rethrow;
    }
  }

  Uri _socketUri(String path, String model) {
    final uri = requestBuilder.buildUrl(path, queryParams: {'model': model});
    if (uri.host.isEmpty || uri.userInfo.isNotEmpty || uri.hasFragment) {
      throw ArgumentError('Invalid realtime audio base URL.');
    }
    return uri.replace(
      scheme: switch (uri.scheme) {
        'http' || 'ws' => 'ws',
        'https' || 'wss' => 'wss',
        _ => throw ArgumentError('Expected an HTTP or WebSocket URL.'),
      },
    );
  }

  List<String> _protocols(
    String? token,
    Map<String, String>? additionalHeaders,
  ) {
    if (token == null) {
      if (isRealtimeBrowser) {
        throw UnsupportedError(
          'Realtime transcription on the web requires a client session token. '
          'Realtime speech uses native bearer authentication.',
        );
      }
      return const [];
    }
    if (!RegExp(r"^rt_[!#$%&'*+.^_`|~0-9A-Za-z-]+$").hasMatch(token)) {
      throw ArgumentError('Expected a realtime client session token.');
    }
    if (additionalHeaders?.isNotEmpty ?? false) {
      throw ArgumentError('A client token uses subprotocols without headers.');
    }
    return ['realtime', token];
  }

  Future<Map<String, String>> _headers(
    String? token,
    Map<String, String>? additionalHeaders,
  ) async {
    if (token != null) return const {};
    final headers = <String, String>{
      for (final entry in config.defaultHeaders.entries)
        entry.key.toLowerCase(): entry.value,
      for (final entry
          in (additionalHeaders ?? const <String, String>{}).entries)
        entry.key.toLowerCase(): entry.value,
    };
    if (headers.containsKey('sec-websocket-protocol')) {
      throw ArgumentError(
        'Specify clientToken to select realtime subprotocols.',
      );
    }
    if (!headers.containsKey('authorization')) {
      final credentials = await config.authProvider?.getCredentials();
      if (credentials case BearerTokenCredentials(:final token)) {
        headers['authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}

final class _RealtimeWire<S extends Object, D> {
  _RealtimeWire(
    this._socket,
    this._parseSession,
    this._parseData,
    this._timeout,
  ) {
    _events = StreamController(
      onListen: () => _hasListener = true,
      onCancel: () => close().ignore(),
    );
    _created.future.ignore();
    _reader = _socket.events.listen(
      _receive,
      onError: (Object _, StackTrace stack) => _fail(
        const RealtimeConnectionException('Realtime transport failed.'),
        stack,
      ),
      onDone: () => close().ignore(),
    );
  }

  final WebSocket _socket;
  final S Function(Map<String, dynamic>) _parseSession;
  final D? Function(String, Map<String, dynamic>) _parseData;
  final Duration _timeout;
  late final StreamController<RealtimeEvent<S, D>> _events;
  // The common shutdown path releases the reader in _release.
  // ignore: cancel_subscriptions
  late final StreamSubscription<WebSocketEvent> _reader;
  final _created = Completer<void>();
  final _done = Completer<void>();
  Completer<void>? _update;
  Future<void>? _shutdown;
  var _closed = false;
  var _inputEnded = false;
  var _hasListener = false;
  var _eventsBeforeListen = 0;
  late S session;
  int? closeCode;

  Future<void> get created => _created.future;
  Stream<RealtimeEvent<S, D>> get events => _events.stream;
  Future<void> get done => _done.future;
  bool get isClosed => _closed;

  void _receive(WebSocketEvent frame) {
    if (_closed) return;
    try {
      switch (frame) {
        case TextDataReceived(:final text):
          _decode(text);
        case BinaryDataReceived(:final data):
          _decode(utf8.decode(data));
        case CloseReceived(:final code):
          closeCode = code;
          if (code != null && !const {1000, 1001, 1005}.contains(code)) {
            _fail(
              RealtimeConnectionException(
                'Realtime peer closed the connection ($code).',
              ),
            );
          } else {
            close().ignore();
          }
      }
    } catch (_, stack) {
      _fail(
        const RealtimeConnectionException('Invalid realtime frame.'),
        stack,
      );
    }
  }

  void _decode(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    final type = json['type'] as String;
    S? state;
    RealtimeError? error;
    D? data;
    switch (type) {
      case 'session.created' || 'session.updated':
        final latest = _parseSession(json['session'] as Map<String, dynamic>);
        state = session = latest;
        if (type == 'session.created' && !_created.isCompleted) {
          _created.complete();
        }
        if (_update case final pending?
            when type == 'session.updated' && !pending.isCompleted) {
          pending.complete();
        }
      case 'error':
        error = RealtimeError.fromJson(json['error'] as Map<String, dynamic>);
        final exception = RealtimeConnectionException(
          'The realtime service rejected the request.',
          apiError: error,
        );
        if (!_created.isCompleted) _created.completeError(exception);
        if (_update case final pending? when !pending.isCompleted) {
          pending.completeError(exception);
        }
      default:
        data = _parseData(type, json);
    }
    if (!_hasListener && ++_eventsBeforeListen > 1024) {
      _fail(
        const RealtimeConnectionException(
          'Realtime opening buffer exceeded 1024 events.',
        ),
      );
      return;
    }
    _events.add(
      RealtimeEvent(json, type: type, session: state, data: data, error: error),
    );
  }

  Future<void> update(Map<String, dynamic> options) async {
    if (options.isEmpty) return;
    if (_inputEnded) throw StateError('Realtime input has ended.');
    if (_update != null) {
      throw StateError('A session update is already pending.');
    }
    final pending = _update = Completer<void>();
    pending.future.ignore();
    try {
      _send('session.update', {'session': options});
      await pending.future.timeout(_timeout);
    } on TimeoutException {
      close().ignore();
      throw errors.TimeoutException(
        message: 'Waiting for realtime session update timed out.',
        timeout: _timeout,
        elapsed: _timeout,
      );
    } finally {
      _update = null;
    }
  }

  void sendInput(String type, Map<String, dynamic> payload) {
    if (_inputEnded) throw StateError('Realtime input has ended.');
    _send(type, payload);
  }

  void endInput(String type) {
    if (_inputEnded) return;
    _send(type, const {});
    _inputEnded = true;
  }

  void _send(String type, Map<String, dynamic> payload) {
    if (_closed) throw StateError('Realtime audio connection is closed.');
    if (!_created.isCompleted) {
      throw StateError('Realtime session is not ready.');
    }
    final frame = jsonEncode({'type': type, ...payload});
    try {
      _socket.sendText(frame);
    } catch (_) {
      throw const RealtimeConnectionException(
        'Sending a realtime frame failed.',
      );
    }
  }

  void abort(errors.AbortedException error) => _fail(error);

  void _fail(Object error, [StackTrace? stack]) {
    if (_closed) return;
    _events.addError(error, stack);
    _stop(error).ignore();
  }

  Future<void> close() => _stop(
    const RealtimeConnectionException('Realtime audio connection closed.'),
  );

  Future<void> _stop(Object reason) {
    if (_shutdown case final existing?) return existing;
    _closed = true;
    if (!_created.isCompleted) _created.completeError(reason);
    if (_update case final pending? when !pending.isCompleted) {
      pending.completeError(reason);
    }
    unawaited(_events.close());
    return _shutdown = _release();
  }

  Future<void> _release() async {
    try {
      await Future.wait([
        Future<void>.sync(_reader.cancel),
        Future<void>.sync(_socket.close),
      ]);
    } catch (_) {
      throw const RealtimeConnectionException(
        'Closing the realtime socket failed.',
      );
    } finally {
      _done.complete();
    }
  }
}

Stream<D> _duplex<S extends Object, D, I>({
  required Future<_RealtimeWire<S, D>> Function(Future<void> stop) open,
  required Stream<I> source,
  required void Function(_RealtimeWire<S, D>, I) send,
  required void Function(_RealtimeWire<S, D>) finish,
  required bool Function(D) isTerminal,
  Future<void>? abortTrigger,
}) {
  final stop = Completer<void>();
  StreamSubscription<I>? input;
  StreamSubscription<RealtimeEvent<S, D>>? output;
  _RealtimeWire<S, D>? wire;
  var stopped = false;
  late final StreamController<D> controller;

  void end([Object? error, StackTrace? stackTrace]) {
    if (stopped) return;
    stopped = true;
    if (error != null) controller.addError(error, stackTrace);
    wire?.close().ignore();
    stop.complete();
    input?.cancel().ignore();
    output?.cancel().ignore();
    unawaited(controller.close());
  }

  Future<void> run() async {
    unawaited(
      abortTrigger?.then((_) {
        if (stopped) return;
        end(
          errors.AbortedException(
            message: 'Realtime audio stream aborted by caller.',
            correlationId: generateRequestId(),
            timestamp: DateTime.now(),
            stage: wire == null
                ? errors.AbortionStage.duringRequest
                : errors.AbortionStage.duringStream,
          ),
        );
      }, onError: (Object _, StackTrace _) {}),
    );
    try {
      final current = wire = await open(stop.future);
      if (stopped) {
        await current.close();
        return;
      }
      output = current.events.listen(
        (event) {
          if (stopped) return;
          if (event.error case final failure?) {
            end(
              RealtimeConnectionException(
                'Realtime audio request failed.',
                apiError: failure,
              ),
            );
            return;
          }
          if (event.data case final value?) {
            controller.add(value);
            if (isTerminal(value)) end();
          }
        },
        onError: end,
        onDone: () => end(
          const RealtimeConnectionException(
            'Realtime audio connection closed before the final event.',
          ),
        ),
      );
      input = source.listen(
        (value) {
          if (stopped) return;
          try {
            send(current, value);
          } catch (error, stack) {
            end(error, stack);
          }
        },
        onError: end,
        onDone: () {
          if (stopped) return;
          try {
            finish(current);
          } catch (error, stack) {
            end(error, stack);
          }
        },
      );
      if (stopped) input?.cancel().ignore();
    } catch (error, stack) {
      end(error, stack);
    }
  }

  controller = StreamController(
    onListen: () => unawaited(run()),
    onPause: () => output?.pause(),
    onResume: () => output?.resume(),
    onCancel: end,
  );
  return controller.stream;
}
