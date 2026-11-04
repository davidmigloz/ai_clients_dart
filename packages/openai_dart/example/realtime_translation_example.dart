/// Runs the typed translation flow against synthetic HTTP and WebSocket peers.
/// No API key, microphone, audio device or paid API request is used.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
import 'package:web_socket/web_socket.dart';

Map<String, dynamic> _session() => {
  'id': 'translation_fixture',
  'type': 'translation',
  'model': 'gpt-realtime-translate',
  'expires_at': 2000000000,
  'audio': {
    'input': {
      'transcription': {'model': 'gpt-realtime-whisper'},
      'noise_reduction': {'type': 'near_field', 'strength': 0.35},
    },
    'output': {'language': 'es'},
  },
};

Future<void> main() async {
  // A production server creates a scoped secret without exposing its API key.
  final broker = OpenAIClient(
    httpClient: MockClient((request) async {
      if (request.method != 'POST' ||
          request.url.path != '/v1/realtime/translations/client_secrets') {
        throw StateError('Unexpected synthetic HTTP request.');
      }
      return http.Response(
        jsonEncode({
          'value': 'synthetic_translation_credential',
          'expires_at': 2000000000,
          'session': _session(),
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
  OpenAIClient? client;
  RealtimeTranslationConnection? connection;
  StreamSubscription<realtime.RealtimeTranslationServerEvent>? tap;
  try {
    final secret = await broker.realtimeSessions.translations
        .createClientSecret(
          realtime.RealtimeTranslationClientSecretCreateRequest.fromJson({
            'session': {
              'model': 'gpt-realtime-translate',
              'audio': _session()['audio'],
            },
          }),
        );
    client = OpenAIClient(
      config: OpenAIConfig(authProvider: ApiKeyProvider(secret.value)),
      httpClient: MockClient(
        (_) async => throw StateError('No HTTP expected.'),
      ),
    );
    final peer = _Peer();
    connection = await client.realtime.connectTranslation(
      model: 'gpt-realtime-translate',
      connector: (uri, {headers}) async => peer,
    );
    final events = <realtime.RealtimeTranslationServerEvent>[];
    final errors = <Object>[];
    tap = connection.events.listen(events.add, onError: errors.add);
    final created = connection.events.firstWhere(
      (event) => event is realtime.RealtimeTranslationSessionCreatedEvent,
    );
    peer.ready();
    await created;

    final updated = connection.events.firstWhere(
      (event) => event is realtime.RealtimeTranslationSessionUpdatedEvent,
    );
    connection.updateSession(
      realtime.RealtimeTranslationSessionUpdateRequest.fromJson(const {
        'audio': {
          'input': {
            'noise_reduction': {'type': 'near_field', 'strength': 0.35},
          },
          'output': {'language': 'es'},
        },
      }),
      eventId: 'configure',
    );
    await updated;

    // Raw mono PCM16 little-endian at 24 kHz. A 200 ms frame is 9,600 bytes.
    // Continue sending source audio, including silence between phrases. The
    // translation stream has no conversation/response.create/commit lifecycle.
    final translated = connection.events.firstWhere(
      (event) => event is realtime.RealtimeTranslationOutputAudioDeltaEvent,
    );
    connection.appendAudioBytes(Uint8List(9600));
    await translated;

    // session.close requests a flush. Keep consuming output until the service's
    // session.closed event, then release the local connection in finally.
    final closed = connection.events.firstWhere(
      (event) => event is realtime.RealtimeTranslationSessionClosedEvent,
    );
    connection.closeSession(eventId: 'finish');
    await closed;
    final output = events
        .whereType<realtime.RealtimeTranslationOutputTranscriptDeltaEvent>()
        .map((event) => event.delta)
        .join();
    if (output != 'Hola.' ||
        errors.isNotEmpty ||
        events.whereType<realtime.RealtimeTranslationErrorEvent>().isNotEmpty) {
      throw StateError('Unexpected synthetic translation result.');
    }
    stdout
      ..writeln('Translated transcript: $output')
      ..writeln('Observed typed audio output and flushed session closure.')
      ..writeln('Zero external API requests or audio-device usage.');
  } finally {
    await tap?.cancel();
    await connection?.close();
    client?.close();
    broker.close();
  }
}

class _Peer implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  void _emit(Map<String, dynamic> event) =>
      _events.add(TextDataReceived(jsonEncode(event)));
  void ready() => _emit({
    'type': 'session.created',
    'event_id': 'created',
    'session': _session(),
  });
  @override
  void sendText(String text) {
    final command = jsonDecode(text) as Map<String, dynamic>;
    switch (command['type']) {
      case 'session.update':
        _emit({
          'type': 'session.updated',
          'event_id': 'updated',
          'session': _session(),
        });
      case 'session.input_audio_buffer.append':
        _emit({
          'type': 'session.input_transcript.delta',
          'event_id': 'source',
          'delta': 'Hello.',
          'elapsed_ms': 200,
        });
        _emit({
          'type': 'session.output_transcript.delta',
          'event_id': 'translated',
          'delta': 'Hola.',
          'elapsed_ms': 200,
        });
        _emit({
          'type': 'session.output_audio.delta',
          'event_id': 'audio',
          'delta': 'AAA=',
          'format': 'pcm16',
          'sample_rate': 24000,
          'channels': 1,
          'elapsed_ms': 200,
        });
      case 'session.close':
        _emit({'type': 'session.closed', 'event_id': 'closed'});
      default:
        throw StateError('Unexpected synthetic command.');
    }
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('JSON only');
  @override
  Future<void> close([int? code, String? reason]) async {
    unawaited(_events.close());
  }
}
