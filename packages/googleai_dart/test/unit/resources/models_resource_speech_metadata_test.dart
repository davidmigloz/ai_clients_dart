import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('sends single-speaker style and decodes WAV speech', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta),
      httpClient: MockClient((request) async {
        expect(
          request.url.path,
          '/v1beta/models/gemini-3.8-flash-tts:generateContent',
        );
        expect(jsonDecode(request.body), {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': 'Welcome.',
                  'speechMetadata': {'style': 'Calm and clear.'},
                },
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {'voiceName': 'Kore'},
              },
            },
          },
        });
        return _response({
          'inlineData': {'mimeType': 'audio/wav', 'data': 'UklGRg=='},
        });
      }),
    );
    addTearDown(client.close);
    final response = await client.models.generateContent(
      model: 'gemini-3.8-flash-tts',
      request: GenerateContentRequest(
        contents: const [
          Content(
            role: 'user',
            parts: [
              TextPart(
                'Welcome.',
                speechMetadata: SpeechMetadata(style: 'Calm and clear.'),
              ),
            ],
          ),
        ],
        generationConfig: GenerationConfig(
          responseModalities: const [ResponseModality.audio],
          speechConfig: SpeechConfig.withVoice('Kore'),
        ),
      ),
    );
    final part =
        response.candidates!.single.content!.parts.single as InlineDataPart;
    expect(part.inlineData.mimeType, 'audio/wav');
    expect(utf8.decode(base64Decode(part.inlineData.data)), 'RIFF');
  });

  test('returns diarized transcript and requested word offsets', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(apiVersion: ApiVersion.v1beta),
      httpClient: MockClient((request) async {
        expect(
          request.url.path,
          '/v1beta/models/gemini-3.5-transcribe:generateContent',
        );
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['generationConfig'], {
          'audioTranscriptionConfig': {
            'diarization': true,
            'wordTimestamp': true,
          },
        });
        return _response({
          'text': 'Welcome.',
          'audioTranscription': {
            'text': 'Welcome.',
            'speakerLabel': 'spk_1',
            'words': [
              {'word': 'Welcome.', 'startOffset': '0s', 'endOffset': '0.4s'},
            ],
          },
        });
      }),
    );
    addTearDown(client.close);
    final response = await client.models.generateContent(
      model: 'gemini-3.5-transcribe',
      request: const GenerateContentRequest(
        contents: [
          Content(
            parts: [
              InlineDataPart(Blob(mimeType: 'audio/wav', data: 'UklGRg==')),
            ],
          ),
        ],
        generationConfig: GenerationConfig(
          audioTranscriptionConfig: GenerationAudioTranscriptionConfig(
            diarization: true,
            wordTimestamp: true,
          ),
        ),
      ),
    );
    final part = response.candidates!.single.content!.parts.single;
    expect(part.audioTranscription?.text, 'Welcome.');
    expect(part.audioTranscription?.speakerLabel, 'spk_1');
    expect(part.audioTranscription?.words?.single.endOffset, '0.4s');
    expect((part as TextPart).copyWith(audioTranscription: null).toJson(), {
      'text': 'Welcome.',
    });
  });

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

http.Response _response(Map<String, Object?> part) => http.Response(
  jsonEncode({
    'candidates': [
      {
        'content': {
          'parts': [part],
        },
      },
    ],
  }),
  200,
  headers: {'content-type': 'application/json'},
);
