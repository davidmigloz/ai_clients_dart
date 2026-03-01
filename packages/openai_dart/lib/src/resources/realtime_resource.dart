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
/// // Connect to realtime session
/// final session = await client.realtime.connect(
///   model: 'gpt-4o-realtime-preview',
/// );
///
/// // Listen for events
/// session.events.listen((event) {
///   if (event is ResponseTextDeltaEvent) {
///     stdout.write(event.delta);
///   }
/// });
///
/// // Send audio
/// session.sendAudio(audioBytes);
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
  /// - [model] - The model to use (e.g., 'gpt-4o-realtime-preview').
  /// - [config] - Optional session configuration.
  ///
  /// ## Returns
  ///
  /// A [RealtimeConnection] for sending and receiving events.
  ///
  /// ## Platform Notes
  ///
  /// On web platforms, browser WebSocket connections do not support custom
  /// headers. Direct connections with API keys will throw [ConnectionException].
  /// For web, use ephemeral tokens from [OpenAIClient.realtimeSessions.create()]
  /// to authenticate.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.realtime.connect(
  ///   model: 'gpt-4o-realtime-preview',
  ///   config: SessionUpdateConfig(
  ///     voice: 'alloy',
  ///     instructions: 'You are a helpful assistant.',
  ///   ),
  /// );
  /// ```
  Future<RealtimeConnection> connect({
    required String model,
    SessionUpdateConfig? config,
  }) async {
    ensureNotClosed?.call();

    // Build URL with proper normalization using the request builder
    final httpUrl = requestBuilder.buildUrl(
      '/realtime',
      queryParams: {'model': model},
    );

    // Convert to WebSocket scheme
    final wsUrl = httpUrl.replace(
      scheme: httpUrl.scheme == 'https' ? 'wss' : 'ws',
    );

    // Build headers with all config options
    final headers = <String, String>{
      'OpenAI-Beta': 'realtime=v1',
      ...this.config.defaultHeaders,
    };

    // Add auth headers
    if (this.config.authProvider case final authProvider?) {
      headers.addAll(authProvider.getHeaders());
    }

    // Add organization header if configured
    if (this.config.organization case final org?) {
      headers['OpenAI-Organization'] = org;
    }

    // Add project header if configured
    if (this.config.project case final proj?) {
      headers['OpenAI-Project'] = proj;
    }

    // Add API version if configured
    if (this.config.apiVersion case final version?) {
      headers['OpenAI-Version'] = version;
    }

    // Connect to WebSocket using platform-specific implementation
    final socket = await connectWebSocket(wsUrl, headers: headers);
    final connection = RealtimeConnection._(socket);

    // Apply config if provided
    if (config != null) {
      connection.updateSession(config);
    }

    return connection;
  }
}

/// A connection to a realtime session.
///
/// Use this to send and receive events from the Realtime API.
class RealtimeConnection {
  RealtimeConnection._(this._socket) {
    _subscription = _socket.events.listen(
      _handleEvent,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  final WebSocket _socket;
  late final StreamSubscription<WebSocketEvent> _subscription;
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  bool _closed = false;

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
      _eventController.add(event);
    } catch (e) {
      _eventController.addError(e);
    }
  }

  void _handleError(Object error) {
    _eventController.addError(error);
  }

  void _handleDone() {
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
  ///   SessionUpdateConfig(
  ///     voice: 'shimmer',
  ///     temperature: 0.8,
  ///   ),
  /// );
  /// ```
  void updateSession(SessionUpdateConfig config, {String? eventId}) {
    send({
      'type': 'session.update',
      'event_id': ?eventId,
      'session': config.toJson(),
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
  /// ## Parameters
  ///
  /// - [item] - The item to create.
  /// - [previousItemId] - Optional ID of the previous item.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.createItem({
  ///   'type': 'message',
  ///   'role': 'user',
  ///   'content': [
  ///     {'type': 'input_text', 'text': 'Hello!'},
  ///   ],
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
  /// - [modalities] - The response modalities (e.g., ['text', 'audio']).
  /// - [instructions] - Additional instructions for this response.
  /// - [voice] - The voice to use.
  /// - [outputAudioFormat] - The audio output format.
  /// - [tools] - Tools available for this response.
  /// - [toolChoice] - The tool choice mode.
  /// - [temperature] - Sampling temperature.
  /// - [maxOutputTokens] - Maximum output tokens.
  /// - [eventId] - Optional event ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// session.createResponse(
  ///   modalities: ['text', 'audio'],
  ///   instructions: 'Respond briefly.',
  /// );
  /// ```
  void createResponse({
    List<String>? modalities,
    String? instructions,
    String? voice,
    String? outputAudioFormat,
    List<RealtimeTool>? tools,
    Object? toolChoice,
    double? temperature,
    Object? maxOutputTokens,
    String? eventId,
  }) {
    final response = <String, dynamic>{
      'modalities': ?modalities,
      'instructions': ?instructions,
      'voice': ?voice,
      'output_audio_format': ?outputAudioFormat,
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      'tool_choice': ?toolChoice,
      'temperature': ?temperature,
      'max_output_tokens': ?maxOutputTokens,
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
