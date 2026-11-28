import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'sends speech directions and returns typed audio transcription',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta),
        httpClient: MockClient((request) async {
          expect(
            request.url.path,
            '/v1beta/models/gemini-3.8-flash-tts:generateContent',
          );
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['contents'], [
            {
              'role': 'user',
              'parts': [
                {
                  'text': 'Welcome.',
                  'speechMetadata': {
                    'speaker': 'Narrator',
                    'style': 'Calm and clear.',
                  },
                },
              ],
            },
          ]);
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'inlineData': {'mimeType': 'audio/pcm', 'data': 'AQI='},
                        'audioTranscription': {
                          'text': 'Welcome.',
                          'speakerLabel': 'spk_1',
                          'words': [
                            {
                              'word': 'Welcome.',
                              'startOffset': '0s',
                              'endOffset': '0.4s',
                            },
                          ],
                        },
                      },
                    ],
                  },
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
      final response = await client.models.generateContent(
        model: 'gemini-3.8-flash-tts',
        request: const GenerateContentRequest(
          contents: [
            Content(
              role: 'user',
              parts: [
                TextPart(
                  'Welcome.',
                  speechMetadata: SpeechMetadata(
                    speaker: 'Narrator',
                    style: 'Calm and clear.',
                  ),
                ),
              ],
            ),
          ],
          generationConfig: GenerationConfig(
            responseModalities: [ResponseModality.audio],
          ),
        ),
      );
      final part =
          response.candidates!.single.content!.parts.single as InlineDataPart;
      expect(part.inlineData.data, 'AQI=');
      expect(part.audioTranscription?.text, 'Welcome.');
      expect(part.audioTranscription?.speakerLabel, 'spk_1');
      expect(part.audioTranscription?.words?.single.endOffset, '0.4s');
      expect(part.copyWith(audioTranscription: null).toJson(), {
        'inlineData': {'mimeType': 'audio/pcm', 'data': 'AQI='},
      });
    },
  );

  test('preserves unknown nested and unavailable typed speech metadata', () {
    final future = {
      'text': 'Welcome.',
      'speechMetadata': {
        'speaker': 'Narrator',
        'style': null,
        'futureStyle': {'setting': 'quiet'},
      },
      'audioTranscription': {'futureReplacement': true},
    };
    final part = Part.fromJson(future) as TextPart;
    expect(part.speechMetadata?.speaker, 'Narrator');
    expect(part.audioTranscription, isNull);
    expect(part.copyWith().toJson(), future);
    expect(part.speechMetadata?.copyWith(speaker: 'Speaker').toJson(), {
      'speaker': 'Speaker',
      'style': null,
      'futureStyle': {'setting': 'quiet'},
    });
  });
}
