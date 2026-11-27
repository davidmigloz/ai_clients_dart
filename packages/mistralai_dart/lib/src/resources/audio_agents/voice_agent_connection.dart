import 'dart:async';
import 'dart:convert';

import '../../models/audio_agents/audio_agent_config.dart';
import '../../models/audio_agents/audio_agent_tools.dart';
import '../../models/audio_agents/audio_session.dart';
import '../../models/audio_agents/voice_agent_event.dart';

/// Participant credentials that a backend can return to its authenticated app.
final class VoiceAgentRoomCredentials {
  /// Creates the handoff from the server-issued room URL and participant token.
  const VoiceAgentRoomCredentials({
    required this.sessionId,
    required this.serverUrl,
    required this.participantToken,
  });

  /// Extracts the fields needed to join from the create response.
  factory VoiceAgentRoomCredentials.fromSession(
    AudioSessionCredentials session,
  ) => VoiceAgentRoomCredentials(
    sessionId: session.id,
    serverUrl: session.serverUrl,
    participantToken: session.participantToken,
  );

  /// Reads the handoff payload returned by your backend.
  factory VoiceAgentRoomCredentials.fromJson(Map<String, dynamic> json) =>
      VoiceAgentRoomCredentials(
        sessionId: json['id'] as String,
        serverUrl: json['server_url'] as String,
        participantToken: json['participant_token'] as String,
      );

  /// ID used when asking the backend to stop the session.
  final String sessionId;

  /// LiveKit server URL to connect to.
  final String serverUrl;

  /// Short-lived LiveKit participant token.
  final String participantToken;

  /// Encodes the handoff for the application. This output includes a secret.
  Map<String, dynamic> toJson() => {
    'id': sessionId,
    'server_url': serverUrl,
    'participant_token': participantToken,
  };

  @override
  String toString() =>
      'VoiceAgentRoomCredentials(sessionId: $sessionId, participantToken: [REDACTED])';
}

/// A room data packet with participant information from the media SDK.
final class VoiceAgentRoomPacket {
  /// Creates a room packet.
  const VoiceAgentRoomPacket({
    required this.topic,
    required this.bytes,
    required this.senderIsAgent,
  });

  /// LiveKit data topic.
  final String topic;

  /// UTF-8 encoded data.
  final List<int> bytes;

  /// Whether the media SDK identified the sender as the room's agent.
  final bool senderIsAgent;
}

/// An incoming LiveKit RPC, annotated using trusted participant metadata.
final class VoiceAgentRpcInvocation {
  /// Creates the RPC invocation.
  const VoiceAgentRpcInvocation({
    required this.payload,
    required this.senderIsAgent,
  });

  /// RPC payload JSON string.
  final String payload;

  /// Whether the caller is the room's voice agent.
  final bool senderIsAgent;
}

/// Error returned to the calling participant by the media adapter.
final class VoiceAgentRpcError implements Exception {
  /// Creates the error with the RPC [code] and [message].
  const VoiceAgentRpcError(this.code, this.message);

  /// Code to use when constructing the media SDK's RPC error.
  final int code;

  /// Safe reason for the failure.
  final String message;

  @override
  String toString() => 'VoiceAgentRpcError($code, $message)';
}

/// A room connection or protocol failure.
final class VoiceAgentConnectionException implements Exception {
  /// Creates the exception with a message that omits credentials.
  const VoiceAgentConnectionException(this.message);

  /// Description of the failed operation.
  final String message;

  @override
  String toString() => 'VoiceAgentConnectionException: $message';
}

/// The application callback for a client-side voice-agent function.
typedef VoiceAgentFunctionHandler =
    FutureOr<Object?> Function(Map<String, dynamic> arguments);

/// Callback for a LiveKit RPC registration.
typedef VoiceAgentRpcHandler =
    Future<String> Function(VoiceAgentRpcInvocation invocation);

/// Adapter implemented with the application's LiveKit SDK.
///
/// The application owns microphone capture and remote audio playback. Identify
/// agent speakers from the SDK's trusted participant metadata to label packets
/// and RPC invocations. Close [packets] on room disconnection and make
/// [disconnect] safe after a failed join. Register RPCs once joined, before
/// publishing the microphone.
abstract interface class VoiceAgentRoomTransport {
  /// Room packets. This stream is subscribed before the connection starts.
  Stream<VoiceAgentRoomPacket> get packets;

  /// Joins the room with the server-issued credentials.
  Future<void> connect(VoiceAgentRoomCredentials credentials);

  /// Registers a function RPC. Returns a callback that removes it.
  void Function() registerRpcMethod(
    String method,
    VoiceAgentRpcHandler handler,
  );

  /// Calls the agent participant. Wait for that participant to arrive if needed.
  Future<String> performAgentRpc(
    String method, {
    required String payload,
    required Duration timeout,
  });

  /// Leaves the room, releasing local tracks and listeners.
  Future<void> disconnect();
}

/// The full configuration fields accepted by the TypeScript SDK's room RPC.
///
/// Instructions and tools apply at the next agent turn. The server can apply
/// [turn] interruption settings immediately.
final class VoiceAgentRoomUpdate {
  /// Creates an update. Omitted values retain their current settings.
  const VoiceAgentRoomUpdate({this.instructions, this.tools, this.turn});

  /// Updated agent instructions.
  final String? instructions;

  /// Replacement tool declarations.
  final List<VoiceAgentTool>? tools;

  /// Updated turn settings.
  final AudioTurnConfig? turn;

  /// Encodes the RPC payload.
  Map<String, dynamic> toJson() => {
    'instructions': ?instructions,
    if (tools case final rules?)
      'tools': rules.map((tool) => tool.toJson()).toList(),
    'turn': ?turn?.toJson(),
  };
}

/// The public session event and RPC protocol over an application-owned room.
final class VoiceAgentConnection {
  VoiceAgentConnection._(
    this.credentials,
    this._transport,
    this._closeSession,
    Map<String, VoiceAgentFunctionHandler> functions,
  ) : _functions = Map.of(functions);

  /// LiveKit topic carrying agent events.
  static const eventsTopic = 'voice_agent.events';

  /// RPC used for calls to application-defined functions.
  static const functionToolMethod = 'mistral.function_tool';

  /// RPC used by the TypeScript SDK to update an active room session.
  static const sessionUpdateMethod = 'mistral.session_update';

  /// Participant credentials and the session ID.
  final VoiceAgentRoomCredentials credentials;
  final VoiceAgentRoomTransport _transport;
  final Future<void> Function(String sessionId) _closeSession;
  final Map<String, VoiceAgentFunctionHandler> _functions;
  final _events = StreamController<VoiceAgentEvent>.broadcast();
  // Released in _teardown(), shared by all shutdown paths.
  // ignore: cancel_subscriptions
  StreamSubscription<VoiceAgentRoomPacket>? _packets;
  void Function()? _unregister;
  Future<void>? _shutdown;
  final _done = Completer<void>();

  /// Agent events. Subscribe after connecting and call [close] to end the session.
  Stream<VoiceAgentEvent> get events => _events.stream;

  /// Completes after the media connection and backend session are released.
  Future<void> get done => _done.future;

  /// Whether the connection is closing or has finished.
  bool get isClosed => _shutdown != null;

  /// Joins the room. [closeSession] calls your authenticated backend to stop
  /// the session and runs on disconnect, close, or failed join.
  ///
  /// Use the same function names here that your backend declared when it
  /// created the session or saved the agent.
  static Future<VoiceAgentConnection> connect({
    required VoiceAgentRoomCredentials credentials,
    required VoiceAgentRoomTransport transport,
    required Future<void> Function(String sessionId) closeSession,
    Map<String, VoiceAgentFunctionHandler> functions = const {},
  }) async {
    final connection = VoiceAgentConnection._(
      credentials,
      transport,
      closeSession,
      functions,
    );
    try {
      connection._packets = transport.packets.listen(
        connection._receive,
        onError: (Object _, StackTrace _) {
          if (connection.isClosed) return;
          connection._events.addError(
            const VoiceAgentConnectionException('Voice room transport failed.'),
          );
          connection.close().ignore();
        },
        onDone: () => connection.close().ignore(),
      );
      await transport.connect(credentials);
      if (connection.isClosed) {
        throw const VoiceAgentConnectionException(
          'Voice room closed while joining.',
        );
      }
      connection._unregister = transport.registerRpcMethod(
        functionToolMethod,
        connection._invokeFunction,
      );
      return connection;
    } catch (_) {
      await connection.close().catchError((Object _) {});
      throw const VoiceAgentConnectionException(
        'Joining the voice room failed.',
      );
    }
  }

  void _receive(VoiceAgentRoomPacket packet) {
    if (isClosed || packet.topic != eventsTopic || !packet.senderIsAgent) {
      return;
    }
    final VoiceAgentEvent event;
    try {
      final json =
          jsonDecode(utf8.decode(packet.bytes)) as Map<String, dynamic>;
      event = VoiceAgentEvent.fromJson(json);
    } catch (_) {
      _events.addError(
        const VoiceAgentConnectionException('Malformed voice room event.'),
      );
      return;
    }
    _events.add(event);
    if (event case VoiceAgentErrorEvent(fatal: true)) close().ignore();
  }

  Future<String> _invokeFunction(VoiceAgentRpcInvocation invocation) async {
    if (isClosed || !invocation.senderIsAgent) {
      throw const VoiceAgentRpcError(2400, 'Invalid voice-agent RPC caller.');
    }
    final String name;
    final Map<String, dynamic> arguments;
    try {
      final json = jsonDecode(invocation.payload) as Map<String, dynamic>;
      name = json['name'] as String;
      final raw = json['arguments'];
      arguments = switch (raw) {
        null || '' => const {},
        final String value => jsonDecode(value) as Map<String, dynamic>,
        final Map<String, dynamic> values => values,
        _ => throw const FormatException('Expected function arguments.'),
      };
    } catch (_) {
      throw const VoiceAgentRpcError(2400, 'Malformed function call payload.');
    }
    final handler = _functions[name];
    if (handler == null) {
      throw const VoiceAgentRpcError(
        2404,
        'No handler for the requested function.',
      );
    }
    try {
      final result = await handler(arguments);
      return switch (result) {
        null => '',
        final String value => value,
        _ => jsonEncode(result),
      };
    } catch (_) {
      throw const VoiceAgentRpcError(1, 'The function handler failed.');
    }
  }

  /// Updates the session via the agent's room RPC and decodes its acknowledgment.
  ///
  /// The transport uses the room's agent participant as the destination. Any
  /// supplied [functions] are installed only when their declarations appear in
  /// the confirmed configuration.
  Future<VoiceAgentSessionUpdatedEvent> update({
    required VoiceAgentRoomUpdate request,
    Map<String, VoiceAgentFunctionHandler> functions = const {},
  }) async {
    if (isClosed) throw StateError('Voice room is closed.');
    final String raw;
    try {
      raw = await _transport.performAgentRpc(
        sessionUpdateMethod,
        payload: jsonEncode(request.toJson()),
        timeout: const Duration(seconds: 5),
      );
    } catch (_) {
      throw const VoiceAgentConnectionException(
        'Voice room session update failed.',
      );
    }
    final VoiceAgentSessionUpdatedEvent result;
    try {
      final body = jsonDecode(raw) as Map<String, dynamic>;
      if (body['type'] != 'session.updated') {
        throw const FormatException('Expected a voice room acknowledgment.');
      }
      result = VoiceAgentSessionUpdatedEvent.fromJson(body);
    } catch (_) {
      throw const VoiceAgentConnectionException(
        'Invalid voice room update acknowledgment.',
      );
    }
    if (!isClosed && functions.isNotEmpty) {
      for (final tool in result.session.tools ?? const <VoiceAgentTool>[]) {
        if (tool case VoiceAgentFunctionTool(function: final definition)) {
          if (functions[definition.name] case final handler?) {
            _functions[definition.name] = handler;
          }
        }
      }
    }
    return result;
  }

  /// Leaves the media room and stops the server session exactly once.
  Future<void> close() => _shutdown ??= Future<void>.microtask(_teardown);

  Future<void> _teardown() async {
    var failed = false;
    Future<void> attempt(FutureOr<void> Function() action) async {
      try {
        await action();
      } catch (_) {
        failed = true;
      }
    }

    await attempt(() => _packets?.cancel());
    if (_unregister case final dispose?) await attempt(dispose);
    await attempt(_transport.disconnect);
    await attempt(() => _closeSession(credentials.sessionId));
    _functions.clear();
    unawaited(_events.close());
    _done.complete();
    if (failed) {
      throw const VoiceAgentConnectionException(
        'Closing the voice session failed.',
      );
    }
  }
}
