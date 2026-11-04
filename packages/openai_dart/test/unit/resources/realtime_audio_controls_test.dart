import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as rt;
import 'package:test/test.dart';

void main() {
  for (final transcription in [false, true]) {
    for (final strength in [0.0, 0.45, 1.0, null]) {
      test(
        '${transcription ? 'transcription' : 'realtime'} client secret '
        'preserves strength $strength and returned transcription keywords',
        () async {
          late Map<String, dynamic> sent;
          final transport = MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/realtime/client_secrets');
            sent = jsonDecode(request.body) as Map<String, dynamic>;
            final session = sent['session'] as Map<String, dynamic>;
            final input =
                (session['audio'] as Map<String, dynamic>)['input']
                    as Map<String, dynamic>;
            final noise = input['noise_reduction'] as Map<String, dynamic>;
            expect(noise, {'type': 'near_field', 'strength': ?strength});
            return http.Response(
              jsonEncode({
                'value': 'test-ephemeral-secret',
                'expires_at': 100,
                'session': {
                  'id': 'session-one',
                  'object': transcription
                      ? 'realtime.transcription_session'
                      : 'realtime.session',
                  'type': transcription ? 'transcription' : 'realtime',
                  if (!transcription) 'model': 'gpt-realtime-2.1-mini',
                  'audio': {
                    'input': {
                      'noise_reduction': noise,
                      'transcription': {
                        'model': 'future-transcription-model',
                        'keywords': ['returned phrase', 'café'],
                      },
                    },
                  },
                },
              }),
              200,
            );
          });
          final client = _client(transport);
          addTearDown(client.close);
          final input = rt.RealtimeAudioConfigInput(
            noiseReduction: rt.AudioInputNoiseReduction(
              type: rt.NoiseReductionType.nearField,
              strength: strength,
            ),
            transcription: const rt.InputAudioTranscription(
              model: 'gpt-transcribe',
              keywords: ['requested phrase'],
            ),
          );
          final response = transcription
              ? await client.realtimeSessions.createTranscriptionClientSecret(
                  rt.RealtimeTranscriptionClientSecretCreateRequest(
                    session: rt.RealtimeTranscriptionSessionCreateRequest(
                      audio: rt.RealtimeTranscriptionSessionAudio(input: input),
                    ),
                  ),
                )
              : await client.realtimeSessions.createClientSecret(
                  rt.RealtimeClientSecretCreateRequest(
                    session: rt.RealtimeSessionCreateRequest(
                      model: 'gpt-realtime-2.1-mini',
                      audio: rt.RealtimeAudioConfig(input: input),
                    ),
                  ),
                );
          expect(
            response.session.audio!.input!.noiseReduction!.strength,
            strength,
          );
          expect(response.session.audio!.input!.transcription!.keywords, [
            'returned phrase',
            'café',
          ]);
          expect(
            response.session.audio!.input!.transcription!.model,
            'future-transcription-model',
          );
          expect(
            (sent['session'] as Map)['type'],
            transcription ? 'transcription' : 'realtime',
          );
        },
      );
    }

    test(
      '${transcription ? 'transcription' : 'realtime'} client secret '
      'keeps explicit disable distinct from an omitted configuration',
      () async {
        final sent = <Map<String, dynamic>>[];
        final client = _client(
          MockClient((request) async {
            sent.add(jsonDecode(request.body) as Map<String, dynamic>);
            return http.Response(
              jsonEncode({
                'value': 'test-ephemeral-secret',
                'expires_at': 100,
                'session': {
                  'id': 'session-one',
                  'object': 'realtime.session',
                  'type': transcription ? 'transcription' : 'realtime',
                },
              }),
              200,
            );
          }),
        );
        addTearDown(client.close);
        for (final disabled in [false, true]) {
          final input = rt.RealtimeAudioConfigInput(
            clearNoiseReduction: disabled,
          );
          if (transcription) {
            await client.realtimeSessions.createTranscriptionClientSecret(
              rt.RealtimeTranscriptionClientSecretCreateRequest(
                session: rt.RealtimeTranscriptionSessionCreateRequest(
                  audio: rt.RealtimeTranscriptionSessionAudio(input: input),
                ),
              ),
            );
          } else {
            await client.realtimeSessions.createClientSecret(
              rt.RealtimeClientSecretCreateRequest(
                session: rt.RealtimeSessionCreateRequest(
                  model: 'gpt-realtime-2.1',
                  audio: rt.RealtimeAudioConfig(input: input),
                ),
              ),
            );
          }
        }
        expect(
          ((sent.first['session'] as Map)['audio'] as Map)['input'],
          isEmpty,
        );
        expect(((sent.last['session'] as Map)['audio'] as Map)['input'], {
          'noise_reduction': null,
        });
      },
    );
  }

  test(
    'translation client secret uses and receives the same strength leaf',
    () async {
      final client = _client(
        MockClient((request) async {
          expect(request.url.path, '/v1/realtime/translations/client_secrets');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final session = body['session'] as Map<String, dynamic>;
          expect(session, {
            'model': 'gpt-realtime-translate',
            'audio': {
              'input': {
                'noise_reduction': {'type': 'far_field', 'strength': 0.2},
              },
            },
          });
          return http.Response(
            jsonEncode({
              'value': 'test-ephemeral-secret',
              'expires_at': 100,
              'session': {
                'id': 'translation-one',
                'type': 'translation',
                'expires_at': 100,
                ...session,
              },
            }),
            200,
          );
        }),
      );
      addTearDown(client.close);
      final response = await client.realtimeSessions.translations
          .createClientSecret(
            const rt.RealtimeTranslationClientSecretCreateRequest(
              session: rt.RealtimeTranslationSessionCreateRequest(
                model: 'gpt-realtime-translate',
                audio: rt.RealtimeTranslationSessionAudio(
                  input: rt.RealtimeTranslationSessionAudioInput(
                    noiseReduction: rt.RealtimeTranslationNoiseReduction(
                      type: rt.NoiseReductionType.farField,
                      strength: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
      expect(response.session.audio.input!.noiseReduction!.strength, 0.2);
    },
  );

  test(
    'custom sample voice object survives public Realtime REST exchange',
    () async {
      final client = _client(
        MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final session = body['session'] as Map<String, dynamic>;
          expect((session['audio'] as Map)['output'], {
            'voice': {'id': 'opaque-sample-voice'},
          });
          return http.Response(
            jsonEncode({
              'value': 'test-ephemeral-secret',
              'expires_at': 100,
              'session': {
                'id': 'session-one',
                'object': 'realtime.session',
                ...session,
              },
            }),
            200,
          );
        }),
      );
      addTearDown(client.close);
      final response = await client.realtimeSessions.createClientSecret(
        const rt.RealtimeClientSecretCreateRequest(
          session: rt.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2.1',
            audio: rt.RealtimeAudioConfig(
              output: rt.RealtimeAudioConfigOutput(
                voiceSelection: AudioVoice.custom('opaque-sample-voice'),
              ),
            ),
          ),
        ),
      );
      expect(
        response.session.audio!.output!.voiceSelection,
        const AudioVoice.custom('opaque-sample-voice'),
      );
    },
  );
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(authProvider: ApiKeyProvider('unit-test-key')),
  httpClient: transport,
);
