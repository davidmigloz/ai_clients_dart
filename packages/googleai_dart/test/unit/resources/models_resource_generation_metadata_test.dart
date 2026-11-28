import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('sends Developer labels and SMART transcription options', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta),
      httpClient: MockClient((request) async {
        expect(
          request.url.path,
          '/v1beta/models/transcription-fixture:generateContent',
        );
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['labels'], {'team': 'reporting'});
        expect(body['generationConfig'], {
          'audioTranscriptionConfig': {
            'mode': 'SMART',
            'sourceText': 'First draft.',
            'languageCodes': ['en-US'],
            'customVocabulary': ['OpenTelemetry'],
          },
        });
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'toolCall': {
                        'toolType': 'MEDIA_PROCESSING',
                        'id': 'media-fixture',
                      },
                    },
                  ],
                },
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);
    const config = GenerationAudioTranscriptionConfig(
      mode: AudioTranscriptionConfigMode.smart,
      sourceText: 'First draft.',
      languageCodes: ['en-US'],
      customVocabulary: ['OpenTelemetry'],
    );
    const request = GenerateContentRequest(
      contents: [
        Content(
          parts: [InlineDataPart(Blob(mimeType: 'audio/wav', data: 'AQI='))],
        ),
      ],
      labels: {'team': 'reporting'},
      generationConfig: GenerationConfig(audioTranscriptionConfig: config),
    );
    final response = await client.models.generateContent(
      model: 'transcription-fixture',
      request: request,
    );
    final result =
        response.candidates!.single.content!.parts.single as ToolCallPart;
    expect(result.toolCall.toolType, ToolType.mediaProcessing);
    expect(
      result.toJson()['toolCall'],
      containsPair('toolType', 'MEDIA_PROCESSING'),
    );

    expect(
      GenerateContentRequest.fromJson(request.toJson()).labels,
      request.labels,
    );
    expect(request.copyWith(labels: null).toJson(), isNot(contains('labels')));
    expect(
      GenerationAudioTranscriptionConfig.fromJson(config.toJson()).mode,
      AudioTranscriptionConfigMode.smart,
    );
    expect(
      config.copyWith(sourceText: null).toJson(),
      isNot(contains('sourceText')),
    );
  });

  test('keeps labels and publisher model routing on Vertex AI', () async {
    final client = GoogleAIClient(
      config: GoogleAIConfig.vertexAI(
        projectId: 'fixture-project',
        location: 'eu',
        authProvider: const BearerTokenProvider('fixture'),
      ),
      httpClient: MockClient((request) async {
        expect(request.url.host, 'aiplatform.eu.rep.googleapis.com');
        expect(
          request.url.path,
          '/v1/projects/fixture-project/locations/eu/publishers/google/models/fixture:generateContent',
        );
        expect(request.headers['authorization'], 'Bearer fixture');
        expect(
          jsonDecode(request.body),
          containsPair('labels', {'request': 'triage'}),
        );
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.close);
    await client.models.generateContent(
      model: 'fixture',
      request: GenerateContentRequest(
        contents: [Content.text('Classify this request.')],
        labels: const {'request': 'triage'},
      ),
    );
  });
}
