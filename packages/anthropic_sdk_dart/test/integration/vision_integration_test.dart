// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Vision API - Integration', () {
    test(
      'analyzes image from URL',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            messages: [
              InputMessage.userBlocks([
                InputContentBlock.image(
                  ImageSource.url(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/'
                    'Cat03.jpg/1200px-Cat03.jpg',
                  ),
                ),
                InputContentBlock.text(
                  'What animal is in this image? Reply with just the animal name.',
                ),
              ]),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.content, isNotEmpty);
        expect(response.stopReason, StopReason.endTurn);

        // Should identify cat
        final text = response.text.toLowerCase();
        expect(text, contains('cat'));
      },
    );

    test(
      'analyzes image from base64',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Fetch a real image and convert to base64 to test the base64 pathway
        // Using the same cat image as the URL test but encoding as base64
        final imageUrl = Uri.parse(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/'
          'Cat03.jpg/480px-Cat03.jpg',
        );
        final imageResponse = await http.get(imageUrl);
        if (imageResponse.statusCode != 200) {
          markTestSkipped(
            'Could not fetch test image (status: ${imageResponse.statusCode})',
          );
          return;
        }
        final imageBase64 = base64Encode(imageResponse.bodyBytes);

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            messages: [
              InputMessage.userBlocks([
                InputContentBlock.image(
                  ImageSource.base64(
                    mediaType: ImageMediaType.jpeg,
                    data: imageBase64,
                  ),
                ),
                InputContentBlock.text(
                  'What animal is in this image? Reply with just the animal name.',
                ),
              ]),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.content, isNotEmpty);
        expect(response.text.toLowerCase(), contains('cat'));
      },
    );

    test(
      'compares multiple images',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            messages: [
              InputMessage.userBlocks([
                InputContentBlock.image(
                  ImageSource.url(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/'
                    'Cat03.jpg/1200px-Cat03.jpg',
                  ),
                ),
                InputContentBlock.image(
                  ImageSource.url(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/'
                    'YellowLabradorLooking_new.jpg/'
                    '1200px-YellowLabradorLooking_new.jpg',
                  ),
                ),
                InputContentBlock.text(
                  'What animals are in these two images? '
                  'Reply with the animal names only, separated by comma.',
                ),
              ]),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.content, isNotEmpty);

        final text = response.text.toLowerCase();
        // Should identify both animals
        expect(text, contains('cat'));
        expect(text, anyOf(contains('dog'), contains('labrador')));
      },
    );

    test(
      'handles image with detailed analysis',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 2048,
            messages: [
              InputMessage.userBlocks([
                InputContentBlock.image(
                  ImageSource.url(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/'
                    'Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/'
                    '1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg',
                  ),
                ),
                InputContentBlock.text(
                  'What is the name of this famous painting and who painted it?',
                ),
              ]),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.content, isNotEmpty);

        final text = response.text.toLowerCase();
        // Should identify the painting
        expect(text, contains('starry night'));
        expect(text, anyOf(contains('van gogh'), contains('gogh')));
      },
    );

    test(
      'streams vision response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            messages: [
              InputMessage.userBlocks([
                InputContentBlock.image(
                  ImageSource.url(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/'
                    'Cat03.jpg/1200px-Cat03.jpg',
                  ),
                ),
                InputContentBlock.text('What animal is this?'),
              ]),
            ],
          ),
        );

        var text = '';
        await for (final event in stream) {
          if (event is ContentBlockDeltaEvent) {
            final delta = event.delta;
            if (delta is TextDelta) {
              text += delta.text;
            }
          }
        }

        expect(text.toLowerCase(), contains('cat'));
      },
    );
  });
}
