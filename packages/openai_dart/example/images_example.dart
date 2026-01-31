// ignore_for_file: avoid_print
/// Example demonstrating GPT Image generation.
///
/// Run with: dart run example/images_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Basic image generation
    print('=== GPT Image Generation ===\n');

    final response = await client.images.generate(
      const ImageGenerationRequest(
        model: 'gpt-image-1',
        prompt: 'A white Siamese cat wearing a top hat, digital art',
        size: ImageSize.size1024x1024,
        quality: ImageQuality.standard,
        style: ImageStyle.vivid,
      ),
    );

    print('Generated ${response.data.length} image(s)');
    for (final image in response.data) {
      if (image.url case final url?) {
        print('URL: $url');
      }
      if (image.revisedPrompt case final revised?) {
        print('Revised prompt: $revised');
      }
    }
    print('');

    // HD quality image
    print('=== HD Quality Image ===\n');

    final response2 = await client.images.generate(
      const ImageGenerationRequest(
        model: 'gpt-image-1',
        prompt:
            'A beautiful sunset over mountains with a lake in the foreground',
        size: ImageSize.size1792x1024, // Wide format
        quality: ImageQuality.hd,
        style: ImageStyle.natural,
      ),
    );

    print('Generated HD image');
    if (response2.data.first.url case final url?) {
      print('URL: $url');
    }
    print('');

    // Multiple images
    print('=== Multiple Images ===\n');

    final response3 = await client.images.generate(
      const ImageGenerationRequest(
        model: 'gpt-image-1',
        prompt: 'A cute robot holding a flower',
        n: 2, // Generate 2 images
        size: ImageSize.size512x512,
      ),
    );

    print('Generated ${response3.data.length} images');
    for (var i = 0; i < response3.data.length; i++) {
      if (response3.data[i].url case final url?) {
        print('Image ${i + 1}: $url');
      }
    }
  } finally {
    client.close();
  }
}
