// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Images - Integration', () {
    test(
      'generates an image with DALL-E 2',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.images.generate(
          const ImageGenerationRequest(
            model: 'dall-e-2',
            prompt: 'A simple blue square on white background',
            size: ImageSize.size256x256,
            n: 1,
          ),
        );

        expect(response.created, isNotNull);
        expect(response.data, isNotEmpty);
        expect(response.data.length, 1);

        final image = response.data.first;
        // Either URL or b64_json should be present
        expect(image.url != null || image.b64Json != null, isTrue);

        if (image.url != null) {
          expect(image.url, startsWith('http'));
        }
      },
    );

    test(
      'generates image as base64',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.images.generate(
          const ImageGenerationRequest(
            model: 'dall-e-2',
            prompt: 'A simple red circle',
            size: ImageSize.size256x256,
            responseFormat: ImageResponseFormat.b64Json,
            n: 1,
          ),
        );

        expect(response.data, isNotEmpty);

        final image = response.data.first;
        expect(image.b64Json, isNotNull);
        expect(image.b64Json, isNotEmpty);
        // Base64 should be valid
        expect(image.b64Json!.length, greaterThan(100));
      },
    );

    test(
      'generates multiple images',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.images.generate(
          const ImageGenerationRequest(
            model: 'dall-e-2',
            prompt: 'A green triangle',
            size: ImageSize.size256x256,
            n: 2,
          ),
        );

        expect(response.data.length, 2);
        for (final image in response.data) {
          expect(image.url != null || image.b64Json != null, isTrue);
        }
      },
    );

    // Note: DALL-E 3 tests are more expensive, keeping minimal
    test(
      'generates image with DALL-E 3',
      timeout: const Timeout(Duration(minutes: 5)),
      skip: 'DALL-E 3 tests are expensive - enable manually',
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.images.generate(
          const ImageGenerationRequest(
            model: 'dall-e-3',
            prompt: 'A minimalist logo of a dart hitting a bullseye',
            size: ImageSize.size1024x1024,
            quality: ImageQuality.standard,
            style: ImageStyle.natural,
          ),
        );

        expect(response.data, isNotEmpty);
        expect(response.data.first.url, isNotNull);

        // DALL-E 3 may revise the prompt
        if (response.data.first.revisedPrompt != null) {
          print('Revised prompt: ${response.data.first.revisedPrompt}');
        }
      },
    );
  });
}
