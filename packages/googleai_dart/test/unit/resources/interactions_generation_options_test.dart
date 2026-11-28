import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'sends structured speech and sampler options through stable Interactions',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(interactionsApiVersion: ApiVersion.v1),
        httpClient: MockClient((request) async {
          expect(request.url.path, '/v1/interactions');
          expect(
            jsonDecode(request.body),
            containsPair('generation_config', {
              'structured_speech_config': {
                'speakers': [
                  {'speaker': 'Narrator', 'voice': 'Puck', 'language': 'en-US'},
                ],
                'text_normalization': 'enabled',
              },
              'temperature': 0.8,
              'top_p': 0.95,
            }),
          );
          return http.Response(
            '{"id":"speech","status":"completed","steps":[]}',
            200,
          );
        }),
      );
      addTearDown(client.close);
      final response = await client.interactions.create(
        model: 'gemini-3.8-flash-tts',
        input: const InteractionInput.text('Narrator: It was a sunny day.'),
        generationConfig: const InteractionGenerationConfig(
          structuredSpeechConfig: InteractionStructuredSpeechConfig.speakers(
            speakers: [
              InteractionSpeechConfig(
                speaker: 'Narrator',
                voice: 'Puck',
                language: 'en-US',
              ),
            ],
            textNormalization: InteractionTextNormalization.enabled,
          ),
          temperature: 0.8,
          topP: 0.95,
        ),
      );
      expect(response.id, 'speech');
    },
  );

  test(
    'sends SMART transcription and video resolution in their own payloads',
    () async {
      var calls = 0;
      final client = GoogleAIClient(
        config: const GoogleAIConfig(),
        httpClient: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          if (calls++ == 0) {
            expect(body['generation_config'], {
              'transcription_config': {
                'language_codes': ['en-US'],
                'mode': {'type': 'smart', 'source_text': 'Original sentence.'},
              },
            });
          } else {
            expect(body['response_format'], {
              'type': 'video',
              'resolution': '1080p',
              'aspect_ratio': '16:9',
            });
          }
          return http.Response(
            '{"id":"fixture","status":"completed","steps":[]}',
            200,
          );
        }),
      );
      addTearDown(client.close);
      await client.interactions.create(
        model: 'transcription-fixture',
        generationConfig: const InteractionGenerationConfig(
          transcriptionConfig: TranscriptionConfig(
            languageCodes: ['en-US'],
            mode: InteractionTranscriptionMode.smart(
              sourceText: 'Original sentence.',
            ),
          ),
        ),
      );
      await client.interactions.create(
        model: 'video-fixture',
        responseFormat: const InteractionResponseFormatConfig.single(
          InteractionVideoResponseFormat(
            resolution: InteractionVideoResponseResolution.p1080,
            aspectRatio: InteractionVideoResponseFormatAspectRatio.ratio16x9,
          ),
        ),
      );
      expect(calls, 2);
    },
  );

  test('round-trips array speech, compact and future transcription modes', () {
    final wire = {
      'structured_speech_config': [
        {'speaker': 'A', 'voice': 'Puck'},
      ],
      'transcription_config': {'mode': 'verbatim'},
      'temperature': 1,
    };
    final parsed = InteractionGenerationConfig.fromJson(wire);
    expect(parsed.structuredSpeechConfig, isA<InteractionSpeechConfigList>());
    expect(parsed.transcriptionConfig?.mode?.toJson(), 'verbatim');
    expect(parsed.temperature, 1.0);
    expect(parsed.toJson(), wire);
    expect(parsed.copyWith(topP: 1).topP, 1.0);
    expect(
      parsed.copyWith(structuredSpeechConfig: null).toJson(),
      isNot(contains('structured_speech_config')),
    );

    final mode = {'type': 'future', 'future_option': true};
    expect(InteractionTranscriptionMode.fromJson(mode).toJson(), mode);
    final format = InteractionVideoResponseFormat.fromJson({
      'type': 'video',
      'resolution': 'future',
    });
    expect(format.copyWith().toJson()['resolution'], 'future');
  });
}
