// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example of using vision models with image inputs.
void main() async {
  // Get API key from environment
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  // Create client
  final client = MistralClient.withApiKey(apiKey);

  try {
    // Use a vision model with an image URL
    print('=== Vision with Image URL ===');
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'pixtral-12b-2409', // Mistral's vision model
        messages: [
          ChatMessage.userMultimodal([
            ContentPart.text('What do you see in this image?'),
            ContentPart.imageUrl(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png',
            ),
          ]),
        ],
      ),
    );

    print('Response: ${response.choices.first.message.content}');

    // Multiple images in one request
    print('\n=== Multiple Images ===');
    final multiImageResponse = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'pixtral-12b-2409',
        messages: [
          ChatMessage.userMultimodal([
            ContentPart.text(
              'Compare these two images. What are the differences?',
            ),
            ContentPart.imageUrl(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png',
            ),
            ContentPart.imageUrl(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Camponotus_flavomarginatus_ant.jpg/320px-Camponotus_flavomarginatus_ant.jpg',
            ),
          ]),
        ],
      ),
    );

    print('Response: ${multiImageResponse.choices.first.message.content}');
  } finally {
    client.close();
  }
}
