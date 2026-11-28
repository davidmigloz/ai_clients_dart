import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

http.Response _json(Object value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('creates prompted voice and reads sample audio', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        apiVersion: ApiVersion.v1beta,
        authProvider: ApiKeyProvider(
          'fixture',
          placement: AuthPlacement.header,
        ),
      ),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1beta/voices');
        expect(request.headers['x-goog-api-key'], 'fixture');
        expect(jsonDecode(request.body), {
          'store': true,
          'voice': {
            'type': 'prompted',
            'model': 'gemini-3.8-flash-tts',
            'display_name': 'Thoughtful narrator',
            'pitch': 'medium',
            'prompted': {
              'input': 'A fictional warm narrator.',
              'base_voice': 'Puck',
            },
          },
        });
        return _json({
          'type': 'prompted',
          'id': 'voice_design',
          'display_name': 'Narrateur éclairé',
          'sample_audio': {'data': 'AQI=', 'mime_type': 'audio/wav'},
          'expire_time': '2026-11-28T01:00:00Z',
        });
      }),
    );
    addTearDown(client.close);
    final voice = await client.voices.create(
      voice: const Voice(
        id: 'ignored-output-only',
        key: 'ignored-output-only-key',
        type: VoiceType.prompted,
        model: 'gemini-3.8-flash-tts',
        displayName: 'Thoughtful narrator',
        pitch: VoicePitch.medium,
        prompted: PromptedVoice(
          input: 'A fictional warm narrator.',
          baseVoice: 'Puck',
        ),
      ),
    );
    expect(voice.id, 'voice_design');
    expect(voice.displayName, 'Narrateur éclairé');
    expect(voice.sampleAudio?.toBytes(), [1, 2]);
    expect(voice.expireTime, DateTime.utc(2026, 11, 28, 1));
  });

  test(
    'replication sends both recordings and accepts the stateless key',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(),
        httpClient: MockClient((request) async {
          expect(jsonDecode(request.body), {
            'store': false,
            'voice': {
              'type': 'replicated',
              'replicated': {
                'source_audio': {'data': 'AQ==', 'mime_type': 'audio/wav'},
                'consent_audio': {'data': 'Ag==', 'mime_type': 'audio/wav'},
              },
            },
          });
          return _json({'type': 'replicated', 'key': 'voicekey_fixture'});
        }),
      );
      addTearDown(client.close);
      final voice = await client.voices.create(
        store: false,
        voice: Voice(
          type: VoiceType.replicated,
          replicated: ReplicatedVoice(
            sourceAudio: VoiceAudioData.fromBytes([1], mimeType: 'audio/wav'),
            consentAudio: VoiceAudioData.fromBytes([2], mimeType: 'audio/wav'),
          ),
        ),
      );
      expect(voice.key, 'voicekey_fixture');
      expect(voice.id, isNull);
      final config = VoiceConfig(voice: voice.key);
      expect(config.toJson(), {'voice': 'voicekey_fixture'});
      expect(config.toString(), isNot(contains('voicekey_fixture')));
      expect(
        VoiceConfig.fromJson(config.toJson()).copyWith(voice: null).voice,
        isNull,
      );
    },
  );

  test(
    'uses a custom voice ID in GenerateContent speech configuration',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(),
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            '/v1beta/models/gemini-3.8-flash-tts:generateContent',
          );
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['generationConfig'], {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {'voice': 'voice_design'},
            },
          });
          return _json({});
        }),
      );
      addTearDown(client.close);
      await client.models.generateContent(
        model: 'gemini-3.8-flash-tts',
        request: GenerateContentRequest(
          contents: [Content.text('A short narration.')],
          generationConfig: const GenerationConfig(
            responseModalities: [ResponseModality.audio],
            speechConfig: SpeechConfig(
              voiceConfig: VoiceConfig(voice: 'voice_design'),
            ),
          ),
        ),
      );
    },
  );

  test(
    'keeps voice keys off diagnostics on unary and streamed errors',
    () async {
      const voiceKey = 'voicekey_private_fixture';
      const speakerKey = 'voicekey_second_fixture';
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.FINE;
      addTearDown(() => Logger.root.level = previousLevel);
      final logs = <LogRecord>[];
      final subscription = Logger.root.onRecord.listen(logs.add);
      addTearDown(subscription.cancel);
      final body = jsonEncode({
        'error': {
          'message': 'Invalid voice: $voiceKey and $speakerKey',
          'details': [
            {'echo': voiceKey, 'query': speakerKey},
          ],
        },
      });
      var calls = 0;
      final client = GoogleAIClient(
        config: const GoogleAIConfig(logLevel: Level.FINE),
        httpClient: MockClient((request) async {
          expect(request.body, contains(voiceKey));
          expect(request.body, contains(speakerKey));
          calls++;
          if (calls == 3) {
            return http.Response(
              'event: error\ndata: $body\n\n',
              200,
              headers: {'content-type': 'text/event-stream; charset=utf-8'},
            );
          }
          return http.Response(body, 400);
        }),
      );
      addTearDown(client.close);
      final request = GenerateContentRequest(
        contents: [Content.text('Narration')],
        generationConfig: const GenerationConfig(
          speechConfig: SpeechConfig(
            voiceConfig: VoiceConfig(voice: voiceKey),
            multiSpeakerVoiceConfig: MultiSpeakerVoiceConfig(
              speakerVoiceConfigs: [
                SpeakerVoiceConfig(voiceConfig: VoiceConfig(voice: speakerKey)),
              ],
            ),
          ),
        ),
      );
      final safeDiagnostics = allOf(
        contains('***REDACTED***'),
        isNot(contains(voiceKey)),
        isNot(contains(speakerKey)),
      );
      final httpError = isA<ApiException>()
          .having((error) => error.message, 'message', safeDiagnostics)
          .having(
            (error) => error.details.toString(),
            'details',
            safeDiagnostics,
          );
      await expectLater(
        client.models.generateContent(
          model: 'gemini-3.8-flash-tts',
          request: request,
        ),
        throwsA(
          httpError.having(
            (error) => error.responseMetadata?.bodyExcerpt,
            'response excerpt',
            safeDiagnostics,
          ),
        ),
      );
      await expectLater(
        client.models.streamGenerateContent(
          model: 'gemini-3.8-flash-tts',
          request: request,
        ),
        emitsError(httpError),
      );
      await expectLater(
        client.models.streamGenerateContent(
          model: 'gemini-3.8-flash-tts',
          request: request,
        ),
        emitsError(
          isA<StreamException>().having(
            (error) => error.partialData,
            'partial SSE data',
            safeDiagnostics,
          ),
        ),
      );
      expect(calls, 3);
      expect(logs.where((log) => log.level == Level.FINE), isNotEmpty);
      for (final log in logs) {
        expect('${log.message}${log.error}', isNot(contains(voiceKey)));
        expect('${log.message}${log.error}', isNot(contains(speakerKey)));
      }
    },
  );

  test('lists repeated filters then gets and deletes a stored voice', () async {
    final calls = <String>[];
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        switch (request.url.path) {
          case '/v1beta/voices':
            expect(request.url.queryParametersAll, {
              'page_size': ['2'],
              'page_token': ['next'],
              'accent': ['British', 'American'],
              'language_code': ['en-GB', 'en-US'],
              'pitch': ['low', 'medium'],
              'type': ['prebuilt', 'prompted'],
            });
            return _json({
              'voices': [
                {'type': 'prebuilt', 'id': 'Puck'},
                {'type': 'future_kind', 'id': 'voice_design'},
              ],
              'next_page_token': 'after',
            });
          case '/v1beta/voices/voice_design' when request.method == 'GET':
            return _json({'type': 'prompted', 'id': 'voice_design'});
          case '/v1beta/voices/voice_design' when request.method == 'DELETE':
            return http.Response('', 204);
          default:
            fail('Unexpected Voices request');
        }
      }),
    );
    addTearDown(client.close);

    final list = await client.voices.list(
      pageSize: 2,
      pageToken: 'next',
      accents: ['British', 'American'],
      languageCodes: ['en-GB', 'en-US'],
      pitches: [VoicePitch.low, VoicePitch.medium],
      types: [VoiceType.prebuilt, VoiceType.prompted],
    );
    expect(list.nextPageToken, 'after');
    expect(list.voices!.first.type, VoiceType.prebuilt);
    expect(list.voices!.last.toJson()['type'], 'future_kind');
    expect((await client.voices.get('voices/voice_design')).id, 'voice_design');
    await client.voices.delete('voice_design');
    expect(calls, [
      'GET /v1beta/voices',
      'GET /v1beta/voices/voice_design',
      'DELETE /v1beta/voices/voice_design',
    ]);
  });

  test(
    'rejects unsupported routes and missing consent without transport',
    () async {
      final transport = MockClient(
        (_) async => fail('Unexpected Voices request'),
      );
      final developer = GoogleAIClient(
        config: const GoogleAIConfig(),
        httpClient: transport,
      );
      final stable = GoogleAIClient(
        config: const GoogleAIConfig(apiVersion: ApiVersion.v1),
        httpClient: transport,
      );
      addTearDown(developer.close);
      addTearDown(stable.close);
      await expectLater(stable.voices.list(), throwsUnsupportedError);
      await expectLater(
        developer.voices.create(voice: const Voice(type: VoiceType.replicated)),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        developer.voices.get('voices/../other'),
        throwsA(isA<ValidationException>()),
      );
    },
  );
}
