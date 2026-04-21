// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert';
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

    test(
      'generates image with GPT Image 2 and token-based usage',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.images.generate(
          const ImageGenerationRequest(
            model: ImageModels.gptImage2,
            prompt: 'A red apple on a white background',
            size: ImageSize.size1024x1024,
            quality: ImageQuality.low,
            background: ImageBackground.opaque,
            outputFormat: ImageOutputFormat.png,
            moderation: ImageModerationLevel.auto,
          ),
        );

        // GPT Image 2 always returns base64, never a URL.
        expect(response.data, hasLength(1));
        expect(response.data.first.b64Json, isNotNull);
        expect(response.data.first.b64Json!.length, greaterThan(100));
        expect(response.data.first.url, isNull);

        // Response metadata must echo the request.
        expect(response.size, ImageSize.size1024x1024);
        expect(response.background, ImageBackground.opaque);
        expect(response.outputFormat, ImageOutputFormat.png);
        expect(response.quality, ImageQuality.low);

        // Token-based pricing: usage must be populated.
        final usage = response.usage;
        expect(usage, isNotNull);
        expect(usage!.totalTokens, greaterThan(0));
        expect(usage.inputTokens, greaterThan(0));
        expect(usage.outputTokens, greaterThan(0));
        expect(usage.inputTokensDetails.textTokens, greaterThanOrEqualTo(0));
        expect(usage.inputTokensDetails.imageTokens, greaterThanOrEqualTo(0));
      },
    );

    test(
      'streams GPT Image 2 generation with partial + completed events',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final events = await client!.images
            .generateStream(
              const ImageGenerationRequest(
                model: ImageModels.gptImage2,
                prompt: 'A simple green square on a white background',
                size: ImageSize.size1024x1024,
                quality: ImageQuality.low,
                partialImages: 1,
              ),
            )
            .toList();

        expect(events, isNotEmpty);
        final completed = events.whereType<ImageGenCompletedEvent>().toList();
        expect(
          completed,
          hasLength(1),
          reason: 'exactly one image_generation.completed event expected',
        );
        expect(completed.single.b64Json, isNotEmpty);
        expect(completed.single.usage.totalTokens, greaterThan(0));

        // Partial events are optional per API, but we requested them and
        // the server may emit 0+ depending on how quickly it generates.
        final partials = events.whereType<ImageGenPartialImageEvent>().toList();
        for (final p in partials) {
          expect(p.b64Json, isNotEmpty);
          expect(p.partialImageIndex, greaterThanOrEqualTo(0));
        }
      },
    );

    test(
      'streams GPT Image 2 multipart edit with partial + completed events',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Generate a small seed image first so we have real bytes to edit.
        final seed = await client!.images.generate(
          const ImageGenerationRequest(
            model: ImageModels.gptImage2,
            prompt: 'A plain white card',
            size: ImageSize.size1024x1024,
            quality: ImageQuality.low,
          ),
        );
        final seedBytes = base64Decode(seed.data.first.b64Json!);

        final events = await client!.images
            .editStream(
              ImageEditRequest(
                image: seedBytes,
                imageFilename: 'seed.png',
                prompt: 'Add a small orange dot in the center',
                model: ImageModels.gptImage2,
              ),
            )
            .toList();

        expect(events, isNotEmpty);
        final completed = events.whereType<ImageEditCompletedEvent>().toList();
        expect(
          completed,
          hasLength(1),
          reason: 'exactly one image_edit.completed event expected',
        );
        expect(completed.single.b64Json, isNotEmpty);
        expect(completed.single.usage.totalTokens, greaterThan(0));
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
