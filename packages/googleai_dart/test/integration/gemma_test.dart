// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Integration tests for Gemma open models.
///
/// These tests verify that Gemma models work correctly through the
/// Google AI API. They require a real API key set in the GEMINI_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  String? apiKey;
  GoogleAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['GEMINI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
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

  group('Gemma - generateContent', () {
    test('generates content with a simple text prompt', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.models.generateContent(
        model: defaultGemmaModel,
        request: const GenerateContentRequest(
          contents: [
            Content(
              parts: [TextPart('Say "Hello, World!" and nothing else.')],
              role: 'user',
            ),
          ],
        ),
      );

      expect(response, isNotNull);
      expect(response.candidates, isNotEmpty);
      expect(response.candidates?.first.content, isNotNull);
      expect(response.candidates?.first.content?.parts, isNotEmpty);

      final firstPart = response.candidates!.first.content!.parts.first;
      expect(firstPart, isA<TextPart>());
      final textPart = firstPart as TextPart;
      expect(textPart.text.toLowerCase(), contains('hello'));
    });
  });

  group('Gemma - streamGenerateContent', () {
    test('streams content chunks', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final chunks = <GenerateContentResponse>[];
      final stream = client!.models.streamGenerateContent(
        model: defaultGemmaModel,
        request: const GenerateContentRequest(
          contents: [
            Content(
              parts: [TextPart('Count from 1 to 5, one number per line.')],
              role: 'user',
            ),
          ],
        ),
      );

      await for (final chunk in stream) {
        chunks.add(chunk);
        expect(chunk, isNotNull);
        expect(chunk.candidates, isNotEmpty);
      }

      expect(chunks.length, greaterThan(0));

      // At least one chunk should contain text
      final hasText = chunks.any(
        (c) =>
            (c.candidates?.first.content?.parts.isNotEmpty ?? false) &&
            c.candidates!.first.content!.parts.first is TextPart,
      );
      expect(hasText, isTrue);
    });
  });
}
