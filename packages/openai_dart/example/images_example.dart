// ignore_for_file: avoid_print
/// Example demonstrating GPT Image 2 generation and editing.
///
/// Run with: dart run example/images_example.dart
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Basic GPT Image 2 generation.
    print('=== GPT Image 2 — Basic Generation ===\n');

    final basic = await client.images.generate(
      const ImageGenerationRequest(
        model: ImageModels.gptImage2,
        prompt: 'A white Siamese cat wearing a top hat, digital art',
        size: ImageSize.size1024x1024,
      ),
    );

    _saveFirstImage(basic, path: 'cat.png');
    _printUsage(basic);

    // Flagship: transparent background + flexible size + webp output.
    print('\n=== GPT Image 2 — Flagship Features ===\n');

    final flagship = await client.images.generate(
      const ImageGenerationRequest(
        model: ImageModels.gptImage2,
        prompt: 'A cute robot holding a single flower on a white card',
        size: ImageSize.size1536x1024, // Flexible landscape size.
        quality: ImageQuality.high, // GPT image quality tiers.
        background: ImageBackground.transparent, // Transparent PNG/WebP only.
        outputFormat: ImageOutputFormat.webp,
        outputCompression: 80,
        moderation: ImageModerationLevel.low,
      ),
    );

    _saveFirstImage(flagship, path: 'robot.webp');
    _printUsage(flagship);

    // Image edit with high input fidelity (GPT Image 2 edit surface).
    print('\n=== GPT Image 2 — Edit with High Input Fidelity ===\n');

    final sourceFile = File('cat.png');
    if (sourceFile.existsSync()) {
      final edit = await client.images.edit(
        ImageEditRequest(
          image: sourceFile.readAsBytesSync(),
          imageFilename: 'cat.png',
          prompt: 'Make the cat wear a tiny monocle too',
          model: ImageModels.gptImage2,
          inputFidelity: ImageInputFidelity.high,
          size: ImageSize.size1024x1024,
          quality: ImageQuality.high,
        ),
      );

      _saveFirstImage(edit, path: 'cat_edited.png');
      _printUsage(edit);
    } else {
      print('(skipping edit — cat.png was not saved)');
    }

    // Streaming generation with partial images.
    print('\n=== GPT Image 2 — Streaming (partial + final) ===\n');

    final stream = client.images.generateStream(
      const ImageGenerationRequest(
        model: ImageModels.gptImage2,
        prompt: 'A simple orange circle on a white card',
        size: ImageSize.size1024x1024,
        partialImages: 2,
      ),
    );

    var partialCount = 0;
    ImageGenCompletedEvent? completed;
    await for (final event in stream) {
      switch (event) {
        case ImageGenPartialImageEvent():
          partialCount++;
          print(
            'partial #${event.partialImageIndex} '
            '(${event.b64Json.length} base64 chars)',
          );
        case ImageGenCompletedEvent():
          completed = event;
        case ImageGenUnknownEvent():
          print('unknown event type: ${event.type}');
      }
    }
    print('Received $partialCount partial image(s)');
    if (completed != null) {
      File(
        'stream_final.png',
      ).writeAsBytesSync(base64Decode(completed.b64Json));
      print(
        'Stream tokens — total: ${completed.usage.totalTokens}, '
        'out: ${completed.usage.outputTokens}',
      );
    }

    // Multiple images in one call.
    print('\n=== GPT Image 2 — Multiple Images ===\n');

    final multi = await client.images.generate(
      const ImageGenerationRequest(
        model: ImageModels.gptImage2,
        prompt: 'A minimalist logo for a coffee shop',
        n: 2,
        size: ImageSize.size1024x1024,
      ),
    );

    for (var i = 0; i < multi.data.length; i++) {
      _saveFirstImage(
        ImageResponse(created: multi.created, data: [multi.data[i]]),
        path: 'logo_${i + 1}.png',
      );
    }
    _printUsage(multi);
  } finally {
    client.close();
  }
}

void _saveFirstImage(ImageResponse response, {required String path}) {
  final image = response.data.first;
  if (image.b64Json case final b64?) {
    File(path).writeAsBytesSync(base64Decode(b64));
    print('Saved $path (${b64.length} base64 chars)');
  } else if (image.url case final url?) {
    // DALL-E URL path — GPT Image 2 always returns base64.
    print('URL: $url');
  }
  if (image.revisedPrompt case final revised?) {
    print('Revised prompt: $revised');
  }
}

void _printUsage(ImageResponse response) {
  final u = response.usage;
  if (u == null) return;
  print(
    'Tokens — total: ${u.totalTokens}, input: ${u.inputTokens}, '
    'output: ${u.outputTokens}',
  );
}
