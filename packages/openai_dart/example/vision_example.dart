// ignore_for_file: avoid_print
/// Example demonstrating GPT-4 Vision capabilities.
///
/// This example shows how to analyze images using GPT-4 Vision.
/// Run with: dart run example/vision_example.dart
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // Analyze image from URL
    print('=== Analyze Image from URL ===\n');

    final response = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [
          ChatMessage.user(
            UserMessageContent.parts([
              const TextContentPart(text: 'What is in this image?'),
              const ImageContentPart(
                url:
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/1280px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
              ),
            ]),
          ),
        ],
        maxTokens: 300,
      ),
    );

    print('Description: ${response.text}\n');

    // Analyze image with detail level
    print('=== Analyze with High Detail ===\n');

    final response2 = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [
          ChatMessage.user(
            UserMessageContent.parts([
              const TextContentPart(
                text:
                    'Describe this image in detail, including colors and composition.',
              ),
              const ImageContentPart(
                url:
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/1280px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
                detail: ImageDetail.high,
              ),
            ]),
          ),
        ],
        maxTokens: 500,
      ),
    );

    print('Detailed description: ${response2.text}\n');

    // Analyze local image (base64)
    print('=== Analyze Local Image (Base64) ===\n');

    // Create a simple test image or use an existing one
    // For this example, we'll demonstrate the format
    final exampleBase64 = base64Encode(
      utf8.encode('This would be image bytes'),
    );

    print('To analyze a local image, use this format:');
    print('''
ImageContentPart(
  url: 'data:image/jpeg;base64,$exampleBase64',
)
''');

    // Compare multiple images
    print('=== Compare Multiple Images ===\n');

    final response3 = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [
          ChatMessage.user(
            UserMessageContent.parts([
              const TextContentPart(
                text: 'Compare these two images. What are the differences?',
              ),
              const ImageContentPart(
                url:
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/1280px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg',
              ),
              const ImageContentPart(
                url:
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png',
              ),
            ]),
          ),
        ],
        maxTokens: 400,
      ),
    );

    print('Comparison: ${response3.text}\n');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
    exit(1);
  } finally {
    client.close();
  }
}
