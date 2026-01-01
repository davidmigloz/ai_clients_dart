// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Vision example for image analysis.
///
/// This example demonstrates:
/// - Analyzing images with base64 encoding
/// - Analyzing images from URLs
/// - Multi-image analysis
/// - Combining text and image inputs
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Image from URL
    print('=== Image from URL ===');
    final urlResponse = await client.messages.create(
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
            InputContentBlock.text('What animal is in this image?'),
          ]),
        ],
      ),
    );
    print('Response: ${urlResponse.text}');

    // Example 2: Image from base64
    print('\n=== Image from Base64 ===');
    // Create a simple test image (1x1 red pixel PNG)
    final sampleImageBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX'
      '8jL0wAAAABJRU5ErkJggg==',
    );

    final base64Response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.image(
              ImageSource.base64(
                mediaType: ImageMediaType.png,
                data: base64Encode(sampleImageBytes),
              ),
            ),
            InputContentBlock.text('Describe this image in detail.'),
          ]),
        ],
      ),
    );
    print('Response: ${base64Response.text}');

    // Example 3: Multiple images
    print('\n=== Multiple Images ===');
    final multiResponse = await client.messages.create(
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
                'YellowLabradorLooking_new.jpg/1200px-YellowLabradorLooking_new.jpg',
              ),
            ),
            InputContentBlock.text(
              'Compare these two images. '
              'What animals are shown and what are the differences?',
            ),
          ]),
        ],
      ),
    );
    print('Response: ${multiResponse.text}');

    // Example 4: Image with detailed question
    print('\n=== Detailed Image Analysis ===');
    final detailResponse = await client.messages.create(
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
              'Please analyze this famous painting. Include:\n'
              '1. The name of the painting and artist\n'
              '2. The artistic style\n'
              '3. Key elements and composition\n'
              '4. The mood and emotions it conveys',
            ),
          ]),
        ],
      ),
    );
    print('Response: ${detailResponse.text}');

    // Example 5: Load local image (if running with a local image)
    print('\n=== Local Image (if available) ===');
    const localImagePath = 'example/sample_image.jpg';
    final localImageFile = File(localImagePath);

    if (localImageFile.existsSync()) {
      final imageBytes = await localImageFile.readAsBytes();
      final localResponse = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 1024,
          messages: [
            InputMessage.userBlocks([
              InputContentBlock.image(
                ImageSource.base64(
                  mediaType: ImageMediaType.jpeg,
                  data: base64Encode(imageBytes),
                ),
              ),
              InputContentBlock.text('What do you see in this image?'),
            ]),
          ],
        ),
      );
      print('Response: ${localResponse.text}');
    } else {
      print('No local image found at $localImagePath');
      print('To test local image loading, place an image at that path.');
    }
  } finally {
    client.close();
  }
}
