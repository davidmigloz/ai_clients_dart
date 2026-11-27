@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'native socket carries bearer headers and closes after duplex speech',
    () async {
      const model = 'voxtral-mini-tts-3-0';
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final closed = Completer<void>();
      final received = <Map<String, dynamic>>[];
      final headers = <String, String?>{};
      final connection = server.listen((request) async {
        headers
          ..['path'] = request.uri.path
          ..['model'] = request.uri.queryParameters['model']
          ..['authorization'] = request.headers.value('authorization')
          ..['x-test-header'] = request.headers.value('x-test-header');
        final socket = await WebSocketTransformer.upgrade(request);
        socket.add(
          jsonEncode({
            'type': 'session.created',
            'session': {'model': model, 'voice': 'voice_fixture'},
          }),
        );
        await for (final frame in socket) {
          final json = jsonDecode(frame as String) as Map<String, dynamic>;
          received.add(json);
          switch (json['type']) {
            case 'session.update':
              socket.add(
                jsonEncode({
                  'type': 'session.updated',
                  'session': {'model': model, ...json['session'] as Map},
                }),
              );
            case 'input_text.end':
              socket
                ..add(
                  jsonEncode({
                    'type': 'speech.audio.delta',
                    'audio_data': 'AQID',
                  }),
                )
                ..add(
                  jsonEncode({
                    'type': 'speech.audio.done',
                    'usage': {'total_tokens': 7},
                  }),
                );
          }
        }
        closed.complete();
      });
      addTearDown(connection.cancel);

      final client = MistralClient(
        config: MistralConfig(
          baseUrl: 'http://127.0.0.1:${server.port}/gateway',
          authProvider: const ApiKeyProvider('fixture'),
        ),
      );
      addTearDown(client.close);
      final events = await client.audio.realtimeSpeech
          .speakStream(
            model: model,
            text: Stream.fromIterable(['two ', 'parts']),
            options: const RealtimeSpeechOptions(voiceId: 'voice_fixture'),
            additionalHeaders: {'x-test-header': 'extension'},
          )
          .toList();
      await closed.future;
      expect(headers, {
        'path': '/gateway/v1/audio/speech/realtime',
        'model': model,
        'authorization': 'Bearer fixture',
        'x-test-header': 'extension',
      });
      expect(received, [
        {
          'type': 'session.update',
          'session': {'voice': 'voice_fixture'},
        },
        {'type': 'input_text.append', 'text': 'two '},
        {'type': 'input_text.append', 'text': 'parts'},
        {'type': 'input_text.end'},
      ]);
      expect((events.first as SpeechStreamAudioDelta).audioData, 'AQID');
      expect((events.last as SpeechStreamDone).usage.totalTokens, 7);
    },
  );
}
