// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Path to the test samples directory.
///
/// Tests may run from the workspace root or the package directory,
/// so we check both known locations.
final String _samplesDir = _resolveSamplesDir();

String _resolveSamplesDir() {
  const candidates = [
    'packages/googleai_dart/test/samples', // workspace root
    'test/samples', // package root
  ];
  for (final path in candidates) {
    if (io.Directory(path).existsSync()) return path;
  }
  throw StateError(
    'Cannot find test/samples directory. '
    'Run tests from the workspace root or the package directory.',
  );
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
          request: GenerateContentRequest(
            contents: const [
              Content(parts: [TextPart('Hello, World!')], role: 'user'),
            ],
            generationConfig: GenerationConfig(
              responseModalities: const [ResponseModality.audio],
              speechConfig: SpeechConfig.withVoice('Kore'),
            ),
          ),
        );

        expect(response.candidates, isNotEmpty);
        final parts = response.candidates!.first.content?.parts;
        expect(parts, isNotEmpty);

        final audioParts = parts!.whereType<InlineDataPart>().toList();
        expect(
          audioParts,
          isNotEmpty,
          reason: 'Expected InlineDataPart with audio, got: $parts',
        );
        expect(audioParts.first.inlineData.mimeType, contains('audio'));
        expect(audioParts.first.inlineData.data, isNotEmpty);
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
          request: GenerateContentRequest(
            contents: const [
              Content(
                parts: [
                  TextPart('The quick brown fox jumps over the lazy dog.'),
                ],
                role: 'user',
              ),
            ],
            generationConfig: GenerationConfig(
              responseModalities: const [ResponseModality.audio],
              speechConfig: SpeechConfig.withVoice('Puck'),
            ),
          ),
        );

        expect(response.candidates, isNotEmpty);
        final parts = response.candidates!.first.content?.parts;
        expect(parts, isNotEmpty);

        final audioParts = parts!.whereType<InlineDataPart>().toList();
        expect(
          audioParts,
          isNotEmpty,
          reason: 'Expected InlineDataPart with audio, got: $parts',
        );
        expect(audioParts.first.inlineData.mimeType, contains('audio'));
        expect(audioParts.first.inlineData.data, isNotEmpty);
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
