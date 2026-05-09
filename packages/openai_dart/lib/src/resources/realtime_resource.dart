import 'dart:async';
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../models/realtime/realtime.dart';
import 'base_resource.dart';
import 'realtime/websocket_connector.dart';

/// Resource for Realtime API operations.
///
/// The Realtime API enables real-time audio conversations with the model
/// using WebSockets.
///
/// Access this resource through [OpenAIClient.realtime].
///
/// ## Example
///
/// ```dart
/// // Connect to a realtime session
/// final session = await client.realtime.connect(
///   model: 'gpt-realtime-2',
/// );
///
/// // Listen for events
/// session.events.listen((event) {
///   if (event is ResponseTextDeltaEvent) {
///     stdout.write(event.delta);
///   }
/// });
///
/// // Send a user text message and let the model respond
/// session.sendUserMessage('Say hello');
///
/// // Or stream audio bytes (24 kHz PCM16 mono for realtime sessions)
/// session.appendAudioBytes(audioBytes);
///
/// // Close when done
/// await session.close();
/// ```
class RealtimeResource extends ResourceBase {
  /// Creates a [RealtimeResource].
  RealtimeResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Connects to a realtime session.
  ///
  /// ## Parameters
  ///
  /// - [model] - The model to use (e.g., 'gpt-realtime-2').
  /// - [config] - Optional session configuration applied via `session.update`
  ///   immediately after the connection opens.
  ///
  /// ## Returns
  ///
  /// A [RealtimeConnection] for sending and receiving events.
  ///
  /// ## Platform Notes
  ///
  /// The browser WebSocket API does not allow custom headers, so the
  /// Realtime WebSocket transport is supported on server / CLI / mobile
  /// only — calling `connect(...)` from a browser raises
  /// [ConnectionException]. For browser-based realtime, use the WebRTC
  /// transport via `client.realtimeSessions.calls.create(...)` (open a
  /// peer connection client-side, POST the SDP offer, complete the
  /// handshake with the returned answer). Alternatively, route the
  /// WebSocket through a server-side proxy that can set the
  /// `Authorization` header.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.realtime.connect(
  ///   model: 'gpt-realtime-2',
  ///   config: RealtimeSessionCreateRequest(
  ///     model: 'gpt-realtime-2',
  ///     audio: RealtimeAudioConfig(
  ///       output: RealtimeAudioConfigOutput(voice: 'alloy'),
  ///     ),
  ///     instructions: 'You are a helpful assistant.',
  ///   ),
  /// );
  /// ```
  Future<RealtimeConnection> connect({
    required String model,
    RealtimeSessionCreateRequest? config,
  }) async {
    if (config != null && config.model != model) {
      throw ArgumentError.value(
        config.model,
        'config.model',
        'must match the connect(model:) argument ("$model"): the WebSocket '
            'is opened for the URL-query model and the embedded session.update '
            'would target a different model, which the server may reject. '
            'Pass the same value in both places.',
      );
    }
    final socket = await _openSocket('/realtime', model);
    final connection = RealtimeConnection._(socket);
    if (config != null) {
      connection.updateSession(config);
    }
    return connection;
  }

  /// Connects to a Realtime translation session.
  ///
  /// Translation sessions stream source audio in and translated audio plus
  /// transcript deltas out continuously — there is no `response.create`
  /// lifecycle. The WebSocket lives at
  /// `wss://api.openai.com/v1/realtime/translations`.
  ///
  /// ## Parameters
  ///
  /// - [model] - The translation model (e.g., `'gpt-realtime-translate'`).
  /// - [config] - Optional update applied via `session.update` immediately
  ///   after the connection opens (e.g., to set `audio.output.language`).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.realtime.connectTranslation(
  ///   model: 'gpt-realtime-translate',
  ///   config: RealtimeTranslationSessionUpdateRequest(
  ///     audio: RealtimeTranslationSessionAudio(
  ///       output: RealtimeTranslationSessionAudioOutput(language: 'es'),
  ///     ),
  ///   ),
  /// );
  ///
  /// session.events.listen((event) {
  ///   switch (event) {
  ///     case RealtimeTranslationOutputAudioDeltaEvent(:final delta):
  ///       // base64 PCM16 translated audio
  ///     case RealtimeTranslationOutputTranscriptDeltaEvent(:final delta):
  ///       stdout.write(delta);
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Future<RealtimeTranslationConnection> connectTranslation({
    required String model,
    RealtimeTranslationSessionUpdateRequest? config,
  }) async {
    final socket = await _openSocket('/realtime/translations', model);
    final connection = RealtimeTranslationConnection._(socket);
    if (config != null) {
      connection.updateSession(config);
    }
    return connection;
  }

  Future<WebSocket> _openSocket(String path, String model) {
    ensureNotClosed?.call();
    final httpUrl = requestBuilder.buildUrl(
      path,
      queryParams: {'model': model},
    );
    final wsUrl = httpUrl.replace(
      scheme: httpUrl.scheme == 'https' ? 'wss' : 'ws',
    );
    // The Realtime API authenticates via the standard `Authorization`
    // bearer token only — no `OpenAI-Beta` header is required (or
    // accepted) on the WebSocket handshake.
    final cfg = config;
    final headers = <String, String>{...cfg.defaultHeaders};
    if (cfg.authProvider case final authProvider?) {
      headers.addAll(authProvider.getHeaders());
    }
    if (cfg.organization case final org?) {
      headers['OpenAI-Organization'] = org;
    }
    if (cfg.project case final proj?) {
      headers['OpenAI-Project'] = proj;
    }
    if (cfg.apiVersion case final version?) {
      headers['OpenAI-Version'] = version;
    }
    return connectWebSocket(wsUrl, headers: headers);
  }
}

/// A connection to a realtime session.
///
/// Use this to send and receive events from the Realtime API.
class RealtimeConnection {
  RealtimeConnection._(this._socket) {
    // Buffer events emitted before the first listener attaches; drain them
    // when the broadcast stream gets its first subscriber. Without this,
    // early frames from the server (notably `session.created`) get dropped
    // because broadcast streams discard events when nobody is listening.
    _eventController = StreamController<RealtimeEvent>.broadcast(
      onListen: _drainBuffer,
    );
    _subscription = _socket.events.listen(
      _handleEvent,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  final WebSocket _socket;
  late final StreamSubscription<WebSocketEvent> _subscription;
  late final StreamController<RealtimeEvent> _eventController;
  final List<_BufferedEvent> _earlyEvents = [];
  bool _drained = false;
  bool _closed = false;

  void _drainBuffer() {
    if (_drained) return;
    _drained = true;
    // Guard against the race where the socket closes (and
    // [_handleDone] closes the controller) before the first listener
    // attaches. In that case `onListen` still fires when a late
    // subscriber arrives — emitting into a closed controller would
    // throw `StateError`. Clear the buffer instead.
    if (_closed) {
      _earlyEvents.clear();
      return;
    }
    for (final buffered in _earlyEvents) {
      if (buffered.error != null) {
        _eventController.addError(buffered.error!);
      } else {
        _eventController.add(buffered.event!);
      }
    }
    _earlyEvents.clear();
  }

  /// Maximum events buffered before the first listener attaches.
  ///
  /// Drops the oldest entry when full. Prevents unbounded memory growth
  /// if a caller never attaches a listener to [events] (or attaches very
  /// late in a long-running session). 1024 entries is large enough to
  /// cover the realistic "session.created" race window and an opening
  /// burst of frames; beyond that the loss is on partial early state
  /// the consumer chose not to read.
  static const int _maxBufferedEvents = 1024;

  void _emitEvent(RealtimeEvent event) {
    if (_closed) return;
    if (_drained) {
      _eventController.add(event);
    } else {
      if (_earlyEvents.length >= _maxBufferedEvents) {
        _earlyEvents.removeAt(0);
      }
      _earlyEvents.add(_BufferedEvent.event(event));
    }
  }

  void _emitError(Object error) {
    if (_closed) return;
    if (_drained) {
      _eventController.addError(error);
    } else {
      if (_earlyEvents.length >= _maxBufferedEvents) {
        _earlyEvents.removeAt(0);
      }
      _earlyEvents.add(_BufferedEvent.error(error));
    }
  }

  /// Stream of events from the server.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.events.listen((event) {
  ///   switch (event) {
  ///     case SessionCreatedEvent(:final session):
  ///       print('Session created: ${session.id}');
  ///     case ResponseTextDeltaEvent(:final delta):
  ///       stdout.write(delta);
  ///     case ErrorEvent(:final error):
  ///       print('Error: ${error.message}');
  ///     default:
  ///       // Handle other events
  ///   }
  /// });
  /// ```
  Stream<RealtimeEvent> get events => _eventController.stream;

  /// Whether the connection is closed.
  bool get isClosed => _closed;

  void _handleEvent(WebSocketEvent event) {
    switch (event) {
      case TextDataReceived(:final text):
        _handleMessage(text);
      case BinaryDataReceived():
        // Binary data not expected from OpenAI Realtime API
        break;
      case CloseReceived():
        _handleDone();
    }
  }

  void _handleMessage(String message) {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final event = RealtimeEvent.fromJson(json);
      _emitEvent(event);
    } catch (e) {
      _emitError(e);
    }
  }

  void _handleError(Object error) {
    _emitError(error);
  }

  void _handleDone() {
    // Idempotent: `_handleEvent` calls this on `CloseReceived`, and the
    // socket subscription's `onDone` also fires it. Without the guard,
    // `_eventController.close()` would run twice (the second call is a
    // no-op on `StreamController` but the explicit short-circuit makes
    // the contract clear and prevents future regressions).
    if (_closed) return;
    _closed = true;
    unawaited(_eventController.close());
  }

  /// Sends a raw event to the server.
  ///
  /// ## Parameters
  ///
  /// - [event] - The event to send as JSON.
  void send(Map<String, dynamic> event) {
    _ensureNotClosed();
    _socket.sendText(jsonEncode(event));
  }

  /// Updates the session configuration.
  ///
  /// ## Parameters
  ///
  /// - [config] - The session configuration update.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.updateSession(
  ///   RealtimeSessionCreateRequest(
  ///     model: 'gpt-realtime-2',
  ///     audio: RealtimeAudioConfig(
  ///       output: RealtimeAudioConfigOutput(voice: 'shimmer'),
  ///     ),
  ///     instructions: 'Be terse.',
  ///   ),
  /// );
  /// ```
  ///
  /// Per the spec, `model` and `voice` cannot be changed after the session
  /// has produced audio output; the server will ignore those fields if you
  /// supply them on update.
  void updateSession(RealtimeSessionCreateRequest config, {String? eventId}) {
    // The `session.update` event requires a discriminated session payload
    // (`type: 'realtime'` vs `'transcription'`). Inject the realtime
    // discriminator when the caller didn't set it so the bare
    // `RealtimeSessionCreateRequest.toJson` (which omits `type` to keep the
    // HTTP endpoint happy) still works on the WebSocket wire.
    final sessionJson = config.toJson();
    sessionJson['type'] ??= 'realtime';
    send({
      'type': 'session.update',
      'event_id': ?eventId,
      'session': sessionJson,
    });
  }

  /// Appends audio data to the input buffer.
  ///
  /// ## Parameters
  ///
  /// - [audioBase64] - The base64-encoded audio data.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Convert raw audio bytes to base64
  /// final audioBase64 = base64Encode(audioBytes);
  /// session.appendAudio(audioBase64);
  /// ```
  void appendAudio(String audioBase64, {String? eventId}) {
    send({
      'type': 'input_audio_buffer.append',
      'event_id': ?eventId,
      'audio': audioBase64,
    });
  }

  /// Convenience over [appendAudio]: base64-encodes the raw audio bytes
  /// for you.
  ///
  /// The audio must be in the format negotiated for the session
  /// (typically 24 kHz PCM16 mono little-endian for realtime sessions;
  /// G.711 μ-law/A-law for telephony). This helper does **not** validate
  /// or transcode — it only wraps `base64Encode`.
  void appendAudioBytes(List<int> audioBytes, {String? eventId}) =>
      appendAudio(base64Encode(audioBytes), eventId: eventId);

  /// Commits the audio buffer, creating a new conversation item.
  ///
  /// ## Parameters
  ///
  /// - [eventId] - Optional event ID.
  void commitAudio({String? eventId}) {
    send({'type': 'input_audio_buffer.commit', 'event_id': ?eventId});
  }

  /// Clears the audio buffer.
  ///
  /// ## Parameters
  ///
  /// - [eventId] - Optional event ID.
  void clearAudio({String? eventId}) {
    send({'type': 'input_audio_buffer.clear', 'event_id': ?eventId});
  }

  /// Creates a new conversation item.
  ///
  /// For the canonical "send a user text turn" flow, prefer
  /// [sendUserMessage] — it wraps this method plus [createResponse] in
  /// one call.
  ///
  /// ## Parameters
  ///
  /// - [item] - The item to create. Use this for advanced item types
  ///   (function-call output, assistant messages, system items,
  ///   item-references) or any flow not covered by [sendUserMessage].
  /// - [previousItemId] - Optional ID of the previous item.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Function-call output (assistant tool result):
  /// session.createItem({
  ///   'type': 'function_call_output',
  ///   'call_id': 'call_abc123',
  ///   'output': '{"temperature": 22, "unit": "C"}',
  /// });
  /// ```
  void createItem(
    Map<String, dynamic> item, {
    String? previousItemId,
    String? eventId,
  }) {
    send({
      'type': 'conversation.item.create',
      'event_id': ?eventId,
      'previous_item_id': ?previousItemId,
      'item': item,
    });
  }

  /// Sends a user text message as a conversation item, and (optionally)
  /// requests a response immediately afterwards.
  ///
  /// Convenience over [createItem] + [createResponse] for the canonical
  /// "send a turn" flow.
  ///
  /// **Caveat:** when the session has server-side VAD with
  /// `create_response: true` (the default), the server will already
  /// generate a response automatically; passing `createResponse: true`
  /// here would queue a duplicate request. Set `createResponse: false`
  /// in that mode.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.sendUserMessage('Say hello and nothing else.');
  /// ```
  void sendUserMessage(
    String text, {
    bool createResponse = true,
    String? eventId,
  }) {
    createItem({
      'type': 'message',
      'role': 'user',
      'content': [
        {'type': 'input_text', 'text': text},
      ],
    }, eventId: eventId);
    if (createResponse) {
      this.createResponse();
    }
  }

  /// Truncates a conversation item.
  ///
  /// ## Parameters
  ///
  /// - [itemId] - The ID of the item to truncate.
  /// - [contentIndex] - The content index.
  /// - [audioEndMs] - Where to truncate the audio.
  /// - [eventId] - Optional event ID.
  void truncateItem(
    String itemId, {
    required int contentIndex,
    required int audioEndMs,
    String? eventId,
  }) {
    send({
      'type': 'conversation.item.truncate',
      'event_id': ?eventId,
      'item_id': itemId,
      'content_index': contentIndex,
      'audio_end_ms': audioEndMs,
    });
  }

  /// Deletes a conversation item.
  ///
  /// ## Parameters
  ///
  /// - [itemId] - The ID of the item to delete.
  /// - [eventId] - Optional event ID.
  void deleteItem(String itemId, {String? eventId}) {
    send({
      'type': 'conversation.item.delete',
      'event_id': ?eventId,
      'item_id': itemId,
    });
  }

  /// Triggers a response from the model.
  ///
  /// ## Parameters
  ///
  /// - [outputModalities] - Response modality (`['text']` or `['audio']`).
  /// - [instructions] - Per-response instruction override.
  /// - [audio] - Per-response audio output config (format + voice).
  /// - [tools] - Tools available for this response.
  /// - [toolChoice] - The tool choice mode.
  /// - [maxOutputTokens] - Maximum output tokens.
  /// - [parallelToolCalls] - Whether to allow parallel tool calls.
  /// - [reasoning] - Reasoning configuration.
  /// - [conversation] - Which conversation the response belongs to
  ///   (`'auto'` to add to the default conversation, `'none'` for an
  ///   out-of-band response).
  /// - [metadata] - Arbitrary metadata for disambiguating responses.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.createResponse(
  ///   outputModalities: ['text'],
  ///   instructions: 'Respond briefly.',
  /// );
  /// ```
  ///
  /// The response payload follows `RealtimeResponseCreateParams` from the
  /// spec: `output_modalities` (single-modality array), nested
  /// `audio.output.{format, voice}`, and reasoning/parallel-tool-calls
  /// knobs.
  void createResponse({
    List<String>? outputModalities,
    String? instructions,
    RealtimeAudioConfigOutput? audio,
    List<RealtimeTool>? tools,
    Object? toolChoice,
    Object? maxOutputTokens,
    bool? parallelToolCalls,
    RealtimeReasoning? reasoning,
    String? conversation,
    Map<String, dynamic>? metadata,
    String? eventId,
  }) {
    final response = <String, dynamic>{
      'output_modalities': ?outputModalities,
      'instructions': ?instructions,
      'audio': ?(audio == null ? null : {'output': audio.toJson()}),
      'tools': ?tools?.map((t) => t.toJson()).toList(),
      'tool_choice': ?toolChoice,
      'max_output_tokens': ?maxOutputTokens,
      'parallel_tool_calls': ?parallelToolCalls,
      'reasoning': ?reasoning?.toJson(),
      'conversation': ?conversation,
      'metadata': ?metadata,
    };

    send({
      'type': 'response.create',
      'event_id': ?eventId,
      if (response.isNotEmpty) 'response': response,
    });
  }

  /// Cancels the current response.
  ///
  /// ## Parameters
  ///
  /// - [eventId] - Optional event ID.
  void cancelResponse({String? eventId}) {
    send({'type': 'response.cancel', 'event_id': ?eventId});
  }

  /// Sends a function call output.
  ///
  /// ## Parameters
  ///
  /// - [callId] - The function call ID.
  /// - [output] - The function output.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.sendFunctionOutput(
  ///   'call_abc123',
  ///   '{"result": 42}',
  /// );
  /// ```
  void sendFunctionOutput(String callId, String output, {String? eventId}) {
    createItem({
      'type': 'function_call_output',
      'call_id': callId,
      'output': output,
    }, eventId: eventId);
  }

  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('Connection has been closed');
    }
  }

  /// Closes the connection.
  ///
  /// ## Parameters
  ///
  /// - [code] - Optional close code.
  /// - [reason] - Optional close reason.
  Future<void> close({int? code, String? reason}) async {
    if (_closed) return;
    _closed = true;

    await _subscription.cancel();
    await _socket.close(code, reason);
    await _eventController.close();
  }
}

/// Internal: buffered event/error pair used while no listener is yet
/// attached to [RealtimeConnection.events].
class _BufferedEvent {
  _BufferedEvent.event(RealtimeEvent this.event) : error = null;
  _BufferedEvent.error(Object this.error) : event = null;

  final RealtimeEvent? event;
  final Object? error;
}

/// A connection to a Realtime translation session.
///
/// Translation sessions stream source audio in and translated audio plus
/// transcript deltas out continuously. They use a different event surface
/// from regular Realtime sessions — see [RealtimeTranslationServerEvent]
/// for the event types you'll receive on [events].
class RealtimeTranslationConnection {
  RealtimeTranslationConnection._(this._socket) {
    _eventController =
        StreamController<RealtimeTranslationServerEvent>.broadcast(
          onListen: _drainBuffer,
        );
    _subscription = _socket.events.listen(
      _handleEvent,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  final WebSocket _socket;
  late final StreamSubscription<WebSocketEvent> _subscription;
  late final StreamController<RealtimeTranslationServerEvent> _eventController;
  final List<_BufferedTranslationEvent> _earlyEvents = [];
  bool _drained = false;
  bool _closed = false;

  void _drainBuffer() {
    if (_drained) return;
    _drained = true;
    // Guard against the race where the socket closes (and
    // [_handleDone] closes the controller) before the first listener
    // attaches. In that case `onListen` still fires when a late
    // subscriber arrives — emitting into a closed controller would
    // throw `StateError`. Clear the buffer instead.
    if (_closed) {
      _earlyEvents.clear();
      return;
    }
    for (final buffered in _earlyEvents) {
      if (buffered.error != null) {
        _eventController.addError(buffered.error!);
      } else {
        _eventController.add(buffered.event!);
      }
    }
    _earlyEvents.clear();
  }

  /// Maximum events buffered before the first listener attaches.
  ///
  /// Drops the oldest entry when full. Prevents unbounded memory growth
  /// in long-lived translation sessions where a listener attaches late
  /// (or never).
  static const int _maxBufferedEvents = 1024;

  void _emitEvent(RealtimeTranslationServerEvent event) {
    if (_closed) return;
    if (_drained) {
      _eventController.add(event);
    } else {
      if (_earlyEvents.length >= _maxBufferedEvents) {
        _earlyEvents.removeAt(0);
      }
      _earlyEvents.add(_BufferedTranslationEvent.event(event));
    }
  }

  void _emitError(Object error) {
    if (_closed) return;
    if (_drained) {
      _eventController.addError(error);
    } else {
      if (_earlyEvents.length >= _maxBufferedEvents) {
        _earlyEvents.removeAt(0);
      }
      _earlyEvents.add(_BufferedTranslationEvent.error(error));
    }
  }

  /// Stream of translation server events.
  Stream<RealtimeTranslationServerEvent> get events => _eventController.stream;

  /// Whether the connection is closed.
  bool get isClosed => _closed;

  void _handleEvent(WebSocketEvent event) {
    switch (event) {
      case TextDataReceived(:final text):
        _handleMessage(text);
      case BinaryDataReceived():
        // Binary data not expected from OpenAI Realtime API
        break;
      case CloseReceived():
        _handleDone();
    }
  }

  void _handleMessage(String message) {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final event = RealtimeTranslationServerEvent.fromJson(json);
      _emitEvent(event);
    } catch (e) {
      _emitError(e);
    }
  }

  void _handleError(Object error) {
    _emitError(error);
  }

  void _handleDone() {
    // Idempotent: `_handleEvent` calls this on `CloseReceived`, and the
    // socket subscription's `onDone` also fires it. Without the guard,
    // `_eventController.close()` would run twice (the second call is a
    // no-op on `StreamController` but the explicit short-circuit makes
    // the contract clear and prevents future regressions).
    if (_closed) return;
    _closed = true;
    unawaited(_eventController.close());
  }

  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('RealtimeTranslationConnection is closed.');
    }
  }

  /// Sends a raw client event to the server.
  void send(Map<String, dynamic> event) {
    _ensureNotClosed();
    _socket.sendText(jsonEncode(event));
  }

  /// Updates the translation session's configuration.
  ///
  /// Translation sessions only allow updates to `audio.input.transcription`,
  /// `audio.input.noise_reduction`, and `audio.output.language` — `model`
  /// and the session `type` are fixed at session creation.
  void updateSession(
    RealtimeTranslationSessionUpdateRequest config, {
    String? eventId,
  }) {
    send({
      'type': 'session.update',
      'event_id': ?eventId,
      'session': config.toJson(),
    });
  }

  /// Appends base64-encoded 24 kHz PCM16 mono audio bytes to the input
  /// buffer. The translation engine consumes 200 ms frames.
  void appendAudio(String audioBase64, {String? eventId}) {
    send({
      'type': 'session.input_audio_buffer.append',
      'event_id': ?eventId,
      'audio': audioBase64,
    });
  }

  /// Convenience over [appendAudio]: base64-encodes the raw audio bytes
  /// for you. The translation flow expects 24 kHz PCM16 mono
  /// little-endian audio in 200 ms frames. This helper does **not**
  /// validate or transcode — it only wraps `base64Encode`.
  void appendAudioBytes(List<int> audioBytes, {String? eventId}) =>
      appendAudio(base64Encode(audioBytes), eventId: eventId);

  /// Gracefully closes the translation session. The server flushes any
  /// pending input audio and emits any remaining translated output before
  /// closing the socket.
  void closeSession({String? eventId}) {
    send({'type': 'session.close', 'event_id': ?eventId});
  }

  /// Closes the WebSocket connection.
  Future<void> close({int? code, String? reason}) async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await _socket.close(code, reason);
    await _eventController.close();
  }
}

class _BufferedTranslationEvent {
  _BufferedTranslationEvent.event(RealtimeTranslationServerEvent this.event)
    : error = null;
  _BufferedTranslationEvent.error(Object this.error) : event = null;

  final RealtimeTranslationServerEvent? event;
  final Object? error;
}
