import 'dart:async';
import 'dart:convert';

import 'package:web_socket/web_socket.dart';

import '../errors/exceptions.dart';
import '../models/realtime/realtime.dart';
import '../utils/private_audio_http.dart';
import 'base_resource.dart';
import 'realtime/websocket_connector.dart';
import 'responses/responses_recovering_websocket.dart';
import 'websocket_recovery.dart';

export 'realtime/websocket_connector.dart';
export 'websocket_recovery.dart';

/// Opt-in Realtime transport recovery with explicit session restoration.
///
/// Reopening creates a new session. Submitted configuration, audio and actions
/// are never replayed. By default disconnected sends are rejected; a positive
/// [maxQueueBytes] retains only never-attempted frames until the application
/// explicitly flushes or removes them after restoring the replacement session.
class RealtimeReconnectOptions extends WebSocketReconnectOptions {
  /// Uses a lifetime retry budget and disables pending-frame retention by default.
  const RealtimeReconnectOptions({
    required super.onReconnecting,
    super.maxAttempts,
    super.initialDelay,
    super.maxDelay,
    super.maxQueueBytes = 0,
    super.maxQueueMessages,
  });

  @override
  RealtimeReconnectOptions copyWith({
    WebSocketReconnectPreparation? onReconnecting,
    int? maxAttempts,
    Duration? initialDelay,
    Duration? maxDelay,
    int? maxQueueBytes,
    int? maxQueueMessages,
  }) => RealtimeReconnectOptions(
    onReconnecting: onReconnecting ?? this.onReconnecting,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    initialDelay: initialDelay ?? this.initialDelay,
    maxDelay: maxDelay ?? this.maxDelay,
    maxQueueBytes: maxQueueBytes ?? this.maxQueueBytes,
    maxQueueMessages: maxQueueMessages ?? this.maxQueueMessages,
  );

  @override
  String toString() =>
      'RealtimeReconnectOptions(onReconnecting: [REDACTED], '
      'maxAttempts: $maxAttempts, initialDelay: $initialDelay, '
      'maxDelay: $maxDelay, maxQueueBytes: $maxQueueBytes, '
      'maxQueueMessages: $maxQueueMessages)';
}

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
  /// [reconnect] explicitly enables bounded transport recovery. Each replacement
  /// socket creates a new session; the initial [config] is sent only once. Restore
  /// session state after `recovery.events` reports a reconnected event, then call
  /// `flushPending()` if disconnected retention was explicitly enabled. Audio,
  /// tool actions and already-attempted writes are never automatically replayed.
  /// [abortTrigger] cancels setup, retry waiting, or the established connection.
  /// [connectionTimeout] bounds each dial, including replacement sockets.
  /// [connector] can capture caller native options for use on every attempt.
  /// [additionalHeaders] and [queryParameters] are snapshotted before opening;
  /// preparation callback overrides are layered over those original values.
  ///
  /// ## Platform Notes
  ///
  /// The browser WebSocket API does not allow custom headers, so the
  /// Realtime WebSocket transport can authenticate directly on server / CLI /
  /// mobile. A browser connection with configured headers raises
  /// [RealtimeBrowserHeadersException] before credential lookup. For browser-based realtime, use the WebRTC
  /// transport via `client.realtimeSessions.calls.create(...)` (open a
  /// peer connection client-side, POST the SDP offer, complete the
  /// handshake with the returned answer). Alternatively, route the
  /// WebSocket through a server-side proxy that can set the
  /// `Authorization` header.
  /// A headerless configuration may connect to an authenticated backend proxy.
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
    RealtimeWebSocketConnector? connector,
    Map<String, String>? additionalHeaders,
    Map<String, String>? queryParameters,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeReconnectOptions? reconnect,
  }) async {
    if (config != null && config.model != model) {
      throw ArgumentError(
        'config.model must match the connect(model:) argument.',
      );
    }
    final socket = await _connectSocket(
      '/realtime',
      model,
      connector: connector,
      additionalHeaders: additionalHeaders,
      queryParameters: queryParameters,
      connectionTimeout: connectionTimeout,
      abortTrigger: abortTrigger,
      reconnect: reconnect,
    );
    RealtimeConnection? connection;
    try {
      connection = RealtimeConnection._(socket, abortTrigger: abortTrigger);
      if (config != null) connection.updateSession(config);
      return connection;
    } catch (_) {
      if (connection != null) {
        await connection.close().catchError((Object _) {});
      } else {
        await _disposeSocket(socket);
      }
      rethrow;
    }
  }

  /// Connects to a Realtime translation session.
  ///
  /// Translation sessions stream source audio in and translated audio plus
  /// transcript deltas out continuously — there is no `response.create`
  /// lifecycle. The WebSocket lives at
  /// `wss://api.openai.com/v1/realtime/translations`.
  ///
  /// [reconnect] is opt-in and opens a new translation session. Configuration
  /// and audio are not replayed. After restoring the new session, explicitly
  /// flush or remove never-attempted pending frames; retention defaults to zero.
  /// [connector], [additionalHeaders], [queryParameters], [connectionTimeout]
  /// and [abortTrigger] follow the same setup and cleanup policy as [connect].
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
    RealtimeWebSocketConnector? connector,
    Map<String, String>? additionalHeaders,
    Map<String, String>? queryParameters,
    Duration? connectionTimeout,
    Future<void>? abortTrigger,
    RealtimeReconnectOptions? reconnect,
  }) async {
    final socket = await _connectSocket(
      '/realtime/translations',
      model,
      connector: connector,
      additionalHeaders: additionalHeaders,
      queryParameters: queryParameters,
      connectionTimeout: connectionTimeout,
      abortTrigger: abortTrigger,
      reconnect: reconnect,
    );
    RealtimeTranslationConnection? connection;
    try {
      connection = RealtimeTranslationConnection._(
        socket,
        abortTrigger: abortTrigger,
      );
      if (config != null) connection.updateSession(config);
      return connection;
    } catch (_) {
      if (connection != null) {
        await connection.close().catchError((Object _) {});
      } else {
        await _disposeSocket(socket);
      }
      rethrow;
    }
  }

  Future<WebSocket> _connectSocket(
    String path,
    String model, {
    required RealtimeWebSocketConnector? connector,
    required Map<String, String>? additionalHeaders,
    required Map<String, String>? queryParameters,
    required Duration? connectionTimeout,
    required Future<void>? abortTrigger,
    required RealtimeReconnectOptions? reconnect,
  }) async {
    ensureNotClosed?.call();
    reconnect?.validate();
    final timeout = connectionTimeout ?? config.connectTimeout;
    if (!timeout.inMicroseconds.isFinite || timeout <= Duration.zero) {
      throw ArgumentError('connectionTimeout must be finite and positive.');
    }
    if (model.isEmpty) throw ArgumentError('model must be nonempty.');
    final initialHeaders = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    final initialQuery = queryParameters == null
        ? null
        : Map<String, String>.unmodifiable(queryParameters);
    Map<String, String>? currentHeaders;
    Map<String, String>? currentQuery;
    if (reconnect != null &&
        (initialQuery?.containsKey('intent') == true ||
            initialQuery?.containsKey('call_id') == true ||
            Uri.parse(config.baseUrl).queryParameters.containsKey('intent') ||
            Uri.parse(config.baseUrl).queryParameters.containsKey('call_id'))) {
      throw ArgumentError(
        'Automatic Realtime recovery requires a model session.',
      );
    }
    Future<WebSocket> open() => _openSocket(
      path,
      model,
      connector: connector ?? connectWebSocket,
      checkBrowserHeaders: connector == null,
      additionalHeaders: {...?initialHeaders, ...?currentHeaders},
      queryParameters: {...?initialQuery, ...?currentQuery},
      timeout: timeout,
      abortTrigger: abortTrigger,
    );
    final socket = await open();
    try {
      await checkPrivateAudioAbort(abortTrigger, 'Realtime connection');
      ensureNotClosed?.call();
      if (reconnect == null) return socket;
      return ResponsesRecoveringWebSocket(
        socket,
        options: reconnect.copyWith(
          onReconnecting: (context) {
            ensureNotClosed?.call();
            return reconnect.onReconnecting(context);
          },
        ),
        manualQueue: true,
        lifetimeRetries: true,
        recoverableCloseCodes: const {1001, 1005, 1006, 1011, 1012, 1013},
        reconnect: (decision) {
          if (decision.headers != null) currentHeaders = decision.headers;
          if (decision.queryParameters != null) {
            currentQuery = decision.queryParameters;
          }
          if (currentQuery?.containsKey('intent') == true ||
              currentQuery?.containsKey('call_id') == true) {
            throw ArgumentError(
              'Automatic Realtime recovery requires a model session.',
            );
          }
          return open();
        },
      );
    } catch (_) {
      await _disposeSocket(socket);
      rethrow;
    }
  }

  Future<WebSocket> _openSocket(
    String path,
    String model, {
    required RealtimeWebSocketConnector connector,
    required bool checkBrowserHeaders,
    required Map<String, String>? additionalHeaders,
    required Map<String, String>? queryParameters,
    required Duration timeout,
    required Future<void>? abortTrigger,
  }) async {
    await checkPrivateAudioAbort(abortTrigger, 'Realtime connection');
    ensureNotClosed?.call();
    final Uri wsUrl;
    try {
      final uri = requestBuilder.buildUrl(
        path,
        queryParams: {...?queryParameters, 'model': model},
      );
      final scheme = switch (uri.scheme) {
        'https' || 'wss' => 'wss',
        'http' || 'ws' => 'ws',
        _ => throw const FormatException(),
      };
      if (uri.host.isEmpty || uri.hasFragment) throw const FormatException();
      wsUrl = uri.replace(scheme: scheme);
    } on FormatException {
      throw ArgumentError(
        'Realtime baseUrl must have a host, no fragment, and use http, https, ws or wss.',
      );
    }
    if (checkBrowserHeaders && isRealtimeBrowserWebSocket) {
      final names = <String>{
        ...config.defaultHeaders.keys,
        if (config.authProvider != null) 'auth-provider',
        if (config.organization != null) 'openai-organization',
        if (config.project != null) 'openai-project',
        if (config.apiVersion != null) 'openai-version',
        ...?additionalHeaders?.keys,
      };
      if (names.isNotEmpty) throw RealtimeBrowserHeadersException(names);
    }
    final headers = <String, String>{};
    void merge(Map<String, String> values) {
      for (final entry in values.entries) {
        headers[entry.key.toLowerCase()] = entry.value;
      }
    }

    merge(config.defaultHeaders);
    if (config.authProvider case final provider?) merge(provider.getHeaders());
    merge({
      'OpenAI-Organization': ?config.organization,
      'OpenAI-Project': ?config.project,
      'OpenAI-Version': ?config.apiVersion,
    });
    if (additionalHeaders != null) merge(additionalHeaders);
    await checkPrivateAudioAbort(abortTrigger, 'Realtime connection');
    ensureNotClosed?.call();
    final cancelled = Completer<WebSocket>();
    var abandoned = false;
    if (abortTrigger != null) {
      void abort() {
        if (cancelled.isCompleted) return;
        cancelled.completeError(
          AbortedException(
            message: 'Realtime connection aborted.',
            stage: AbortionStage.duringRequest,
            timestamp: DateTime.now(),
            redactDiagnostics: true,
          ),
        );
      }

      unawaited(
        abortTrigger.then<void>(
          (_) => abort(),
          onError: (Object _, StackTrace _) => abort(),
        ),
      );
    }
    final WebSocket socket;
    try {
      final opening = Future<WebSocket>.sync(
        () => connector(wsUrl, headers: Map.unmodifiable(headers)),
      );
      unawaited(
        opening.then<void>((socket) {
          if (abandoned) unawaited(_disposeSocket(socket));
        }, onError: (Object _, StackTrace _) {}),
      );
      socket = await Future.any<WebSocket>([
        opening,
        cancelled.future,
      ]).timeout(timeout);
    } on AbortedException {
      abandoned = true;
      rethrow;
    } on RealtimeBrowserHeadersException {
      abandoned = true;
      rethrow;
    } catch (error) {
      abandoned = true;
      throw ConnectionException(
        message: error is TimeoutException
            ? 'Realtime WebSocket handshake timed out.'
            : 'Realtime WebSocket handshake failed.',
        cause: error,
        redactDiagnostics: true,
      );
    } finally {
      // Release Future.any's losing listener after a successful dial/timeout.
      // Otherwise the connection-lifetime abort future can retain the winning
      // socket through its completed race until the eventual abort arrives.
      if (!cancelled.isCompleted) {
        cancelled.completeError(
          const RealtimeTransportException(operation: 'settled_handshake'),
        );
      }
    }
    try {
      await checkPrivateAudioAbort(abortTrigger, 'Realtime connection');
      ensureNotClosed?.call();
      return socket;
    } catch (_) {
      await _disposeSocket(socket);
      rethrow;
    }
  }

  static Future<void> _disposeSocket(WebSocket socket) async {
    try {
      await socket.close(1000).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Cleanup of a late/abandoned handshake must not create another failure.
    }
  }
}

/// A connection to a realtime session.
///
/// Use this to send and receive events from the Realtime API.
class RealtimeConnection extends _RealtimeConnection<RealtimeEvent> {
  RealtimeConnection._(super.socket, {super.abortTrigger});

  @override
  RealtimeEvent _parse(Map<String, dynamic> json) =>
      RealtimeEvent.fromJson(json);

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
}

/// A connection to a Realtime translation session.
///
/// Translation sessions stream source audio in and translated audio plus
/// transcript deltas out continuously. They use a different event surface
/// from regular Realtime sessions — see [RealtimeTranslationServerEvent]
/// for the event types you'll receive on [events].
class RealtimeTranslationConnection
    extends _RealtimeConnection<RealtimeTranslationServerEvent> {
  RealtimeTranslationConnection._(super.socket, {super.abortTrigger});

  @override
  RealtimeTranslationServerEvent _parse(Map<String, dynamic> json) =>
      RealtimeTranslationServerEvent.fromJson(json);

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
}

/// A malformed incoming frame or invalid outgoing JSON command.
class RealtimeProtocolException implements Exception {
  /// Creates a diagnostic excluding event contents.
  const RealtimeProtocolException({required this.kind, this.cause});

  /// Classification of the invalid frame or command.
  final String kind;

  /// Original failure, available explicitly and excluded from diagnostics.
  final Object? cause;

  @override
  String toString() => 'RealtimeProtocolException: $kind';
}

/// A transport failure, distinct from an ordinary Realtime server error event.
class RealtimeTransportException implements Exception {
  /// Creates a value-safe transport diagnostic.
  const RealtimeTransportException({required this.operation, this.cause});

  /// Failed operation, without payload, header, URL or close-reason values.
  final String operation;

  /// Original failure, available explicitly and excluded from diagnostics.
  final Object? cause;

  @override
  String toString() => 'RealtimeTransportException: $operation failed';
}

abstract class _RealtimeConnection<T> {
  _RealtimeConnection(WebSocket socket, {Future<void>? abortTrigger})
    : _socket = socket {
    _events = StreamController<T>.broadcast(onListen: _drain);
    _subscription = _socket.events.listen(
      _receive,
      onError: _receiveError,
      onDone: _peerDone,
    );
    if (abortTrigger != null) {
      unawaited(
        abortTrigger.then<void>(
          (_) => _abort(),
          onError: (Object _, StackTrace _) => _abort(),
        ),
      );
    }
  }

  final WebSocket _socket;
  late final StreamController<T> _events;
  StreamSubscription<WebSocketEvent>? _subscription;
  final List<_BufferedRealtimeEvent<T>> _opening = [];
  final Completer<void> _done = Completer();
  Future<void>? _shutdownFuture;
  bool _hasListened = false;
  bool _closed = false;
  bool _eventsClosed = false;
  int? _closeCode;
  String? _closeReason;

  T _parse(Map<String, dynamic> json);

  /// Broadcast events from the server. Opening events reach the first listener.
  Stream<T> get events => _events.stream;

  /// Whether this logical connection has permanently closed.
  bool get isClosed => _closed;

  /// Completes after transport and reader cleanup, independently of event taps.
  Future<void> get done => _done.future;

  /// Actual peer close code, when a close frame was received.
  int? get closeCode => _closeCode;

  /// Actual peer close reason; excluded from automatic diagnostics.
  String? get closeReason => _closeReason;

  /// Opt-in recovery state and final never-attempted delivery report.
  WebSocketRecovery? get recovery =>
      _socket is ResponsesRecoveringWebSocket ? _socket.recovery : null;

  /// Removes retained frames without transmitting them.
  List<WebSocketUnsentMessage> takePending() =>
      recovery?.takePending() ?? const [];

  /// Sends retained frames once, after the application restores the new session.
  ///
  /// The physical connection must be open. Submitted frames are removed before
  /// each write and are never automatically replayed after an uncertain send.
  void flushPending() => recovery?.flushPending();

  void _receive(WebSocketEvent frame) {
    if (frame case CloseReceived(:final code, :final reason)) {
      _closeCode = code;
      _closeReason = reason;
      _peerDone();
      return;
    }
    if (_closed) return;
    switch (frame) {
      case TextDataReceived(:final text):
        try {
          final json = jsonDecode(text);
          if (json is! Map<String, dynamic>) {
            throw const FormatException('Expected a JSON object.');
          }
          _emit(_BufferedRealtimeEvent.event(_parse(json)));
        } catch (error) {
          _emit(
            _BufferedRealtimeEvent.error(
              RealtimeProtocolException(kind: 'invalid_event', cause: error),
            ),
          );
        }
      case BinaryDataReceived():
        _emit(
          _BufferedRealtimeEvent.error(
            const RealtimeProtocolException(kind: 'binary'),
          ),
        );
      case CloseReceived():
        break;
    }
  }

  void _receiveError(Object error, StackTrace stackTrace) {
    if (_closed) return;
    _emit(
      _BufferedRealtimeEvent.error(
        RealtimeTransportException(operation: 'receive', cause: error),
        stackTrace,
      ),
    );
    _backgroundShutdown(closeSocket: true);
  }

  void _peerDone() => _backgroundShutdown(closeSocket: false);

  void _abort() {
    if (_closed) return;
    _emit(
      _BufferedRealtimeEvent.error(
        AbortedException(
          message: 'Realtime connection aborted.',
          stage: AbortionStage.duringRequest,
          timestamp: DateTime.now(),
          redactDiagnostics: true,
        ),
      ),
    );
    _backgroundShutdown(closeSocket: true);
  }

  void _emit(_BufferedRealtimeEvent<T> entry) {
    if (_eventsClosed) return;
    if (_hasListened) {
      _publish(entry);
    } else {
      // Preserve the existing bounded opening-buffer policy.
      if (_opening.length >= 1024) _opening.removeAt(0);
      _opening.add(entry);
    }
  }

  void _publish(_BufferedRealtimeEvent<T> entry) {
    if (entry.error case final error?) {
      _events.addError(error, entry.stackTrace);
    } else {
      _events.add(entry.event as T);
    }
  }

  void _drain() {
    if (_hasListened || _eventsClosed) return;
    _hasListened = true;
    _opening
      ..forEach(_publish)
      ..clear();
    if (_done.isCompleted) _finishEvents();
  }

  /// Serializes and sends a JSON command or retains it during opted-in recovery.
  ///
  /// Initial configuration is sent only by connect; reopening never replays it.
  /// Disconnected retention is disabled unless maxQueueBytes is positive.
  void send(Map<String, dynamic> event) {
    if (_closed) throw StateError('Realtime connection is closed.');
    final String text;
    try {
      text = jsonEncode(event);
    } catch (error) {
      throw RealtimeProtocolException(kind: 'invalid_command', cause: error);
    }
    try {
      _socket.sendText(text);
    } on WebSocketSendQueueOverflowException {
      rethrow;
    } on WebSocketDeliveryUnknownException {
      _backgroundShutdown(closeSocket: true);
      rethrow;
    } catch (error) {
      _backgroundShutdown(closeSocket: true);
      throw RealtimeTransportException(operation: 'send', cause: error);
    }
  }

  /// Releases the reader and owned socket without waiting for paused event taps.
  Future<void> close({int? code, String? reason}) {
    validateRealtimeClose(code, reason);
    return _startShutdown(closeSocket: true, code: code, reason: reason);
  }

  void _backgroundShutdown({required bool closeSocket}) {
    unawaited(
      _startShutdown(closeSocket: closeSocket).catchError((Object _) {}),
    );
  }

  Future<void> _startShutdown({
    required bool closeSocket,
    int? code,
    String? reason,
  }) {
    if (_shutdownFuture case final future?) return future;
    _closed = true;
    final completion = Completer<void>();
    _shutdownFuture = completion.future;
    // A custom synchronous socket may close inside listen(). Defer cancellation
    // until the returned subscription has been assigned.
    unawaited(
      Future<void>.microtask(
        () => _cleanup(closeSocket, code, reason),
      ).then(completion.complete, onError: completion.completeError),
    );
    return completion.future;
  }

  Future<void> _cleanup(bool closeSocket, int? code, String? reason) async {
    Object? failure;
    final clock = Stopwatch()..start();
    Future<void> bounded(Future<void> operation) {
      final remaining = const Duration(seconds: 5) - clock.elapsed;
      if (remaining <= Duration.zero) {
        unawaited(operation.catchError((Object _) {}));
        return Future.error(TimeoutException('Realtime cleanup timed out.'));
      }
      return operation.timeout(remaining);
    }

    try {
      if (closeSocket) await bounded(_socket.close(code, reason));
    } catch (error) {
      failure = error;
    } finally {
      try {
        if (_subscription != null) await bounded(_subscription!.cancel());
      } catch (error) {
        failure ??= error;
      } finally {
        _subscription = null;
        if (!_done.isCompleted) _done.complete();
        if (_hasListened) _finishEvents();
      }
    }
    if (failure != null) {
      throw RealtimeTransportException(operation: 'close', cause: failure);
    }
  }

  void _finishEvents() {
    if (_eventsClosed) return;
    _eventsClosed = true;
    unawaited(_events.close());
  }

  @override
  String toString() => '$runtimeType(isClosed: $isClosed)';
}

class _BufferedRealtimeEvent<T> {
  _BufferedRealtimeEvent.event(T this.event) : error = null, stackTrace = null;
  _BufferedRealtimeEvent.error(this.error, [this.stackTrace]) : event = null;

  final T? event;
  final Object? error;
  final StackTrace? stackTrace;
}
