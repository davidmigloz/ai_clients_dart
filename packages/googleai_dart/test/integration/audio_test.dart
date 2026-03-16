// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Path to the test samples directory.
///
/// Resolves relative to the package root regardless of working directory.
final String _samplesDir = '${_packageRoot()}/test/samples';

String _packageRoot() {
  // Walk up from this file's location to find the package root
  var dir = io.Directory('packages/googleai_dart');
  if (dir.existsSync()) return dir.path;
  // Fallback: already in the package directory
  dir = io.Directory('test/samples');
  if (dir.existsSync()) return '.';
  // Last resort: use an absolute path
  return 'packages/googleai_dart';
}

/// Integration tests for TTS (Text-to-Speech) and STT (Speech-to-Text).
///
/// These tests require a real API key set in the GEMINI_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  String? apiKey;
  GoogleAIClient? client;

  setUpAll(() {
    final key = io.Platform.environment['GEMINI_API_KEY'];
    apiKey = (key != null && key.isNotEmpty) ? key : null;
    if (apiKey == null) {
      print(
        '⚠️  GEMINI_API_KEY not set. Integration tests will be skipped.\n'
        '   To run these tests, export GEMINI_API_KEY=your_api_key',
      );
    } else {
      client = GoogleAIClient(
        config: GoogleAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('TTS - Text-to-Speech', () {
    test(
      'generates speech from text',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.models.generateContent(
          model: defaultTTSModel,
          request: const GenerateContentRequest(
            contents: [
              Content(parts: [TextPart('Hello, World!')], role: 'user'),
            ],
            generationConfig: GenerationConfig(
              responseModalities: ['AUDIO'],
              speechConfig: {
                'voiceConfig': {
                  'prebuiltVoiceConfig': {'voiceName': 'Kore'},
                },
              },
            ),
          ),
        );

        expect(response.candidates, isNotEmpty);
        final parts = response.candidates!.first.content?.parts;
        expect(parts, isNotEmpty);

        final audioPart = parts!.whereType<InlineDataPart>().first;
        expect(audioPart.inlineData.mimeType, contains('audio'));
        expect(audioPart.inlineData.data, isNotEmpty);
      },
    );

    test(
      'generates speech with different voice',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.models.generateContent(
          model: defaultTTSModel,
          request: const GenerateContentRequest(
            contents: [
              Content(
                parts: [
                  TextPart('The quick brown fox jumps over the lazy dog.'),
                ],
                role: 'user',
              ),
            ],
            generationConfig: GenerationConfig(
              responseModalities: ['AUDIO'],
              speechConfig: {
                'voiceConfig': {
                  'prebuiltVoiceConfig': {'voiceName': 'Puck'},
                },
              },
            ),
          ),
        );

        expect(response.candidates, isNotEmpty);
        final parts = response.candidates!.first.content?.parts;
        expect(parts, isNotEmpty);

        final audioPart = parts!.whereType<InlineDataPart>().first;
        expect(audioPart.inlineData.mimeType, contains('audio'));
        expect(audioPart.inlineData.data, isNotEmpty);
      },
    );
  });

  group('STT - Speech-to-Text', () {
    test(
      'transcribes audio from WAV file',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final wavBytes = await io.File(
          '$_samplesDir/harvard.wav',
        ).readAsBytes();

        final response = await client!.models.generateContent(
          model: defaultSTTModel,
          request: GenerateContentRequest(
            contents: [
              Content(
                parts: [
                  Part.bytes(wavBytes, 'audio/wav'),
                  const TextPart('Transcribe this audio.'),
                ],
                role: 'user',
              ),
            ],
          ),
        );

        expect(response.candidates, isNotEmpty);
        final text = response.text;
        expect(text, isNotNull);
        expect(text, isNotEmpty);
      },
    );
  });
}
