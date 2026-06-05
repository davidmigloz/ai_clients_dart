// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating experimental image generation via `/api/generate`.
///
/// Image generation is experimental in Ollama and only works with image
/// generation models (e.g. `x/z-image-turbo`). The `width`, `height`, and
/// `steps` request parameters — and the `image`/`completed`/`total` response
/// fields — may change or be removed in a future Ollama release.
void main() async {
  final client = OllamaClient();

  try {
    // Non-streaming: generate a single image and save it to disk.
    print('--- Image Generation ---');
    final result = await client.completions.generate(
      request: const GenerateRequest(
        model: 'x/z-image-turbo',
        prompt: 'a sunset over mountains',
        width: 1024,
        height: 768,
        steps: 20,
      ),
    );

    final base64Image = result.image;
    if (base64Image != null) {
      // The `image` field is base64-encoded; decode it before writing bytes.
      final bytes = base64Decode(base64Image);
      final file = File('generated_image.png')..writeAsBytesSync(bytes);
      print('Saved ${bytes.length} bytes to ${file.path}');
    } else {
      print('No image returned (is this an image generation model?)');
    }
    print('');

    // Streaming: observe diffusion progress, then capture the final image.
    print('--- Streaming Image Generation ---');
    await for (final chunk in client.completions.generateStream(
      request: const GenerateRequest(
        model: 'x/z-image-turbo',
        prompt: 'a futuristic city at night',
        width: 512,
        height: 512,
        steps: 20,
      ),
    )) {
      if (chunk.completed != null && chunk.total != null) {
        print('Progress: ${chunk.completed}/${chunk.total} steps');
      }
      if ((chunk.done ?? false) && chunk.image != null) {
        final bytes = base64Decode(chunk.image!);
        File('generated_image_stream.png').writeAsBytesSync(bytes);
        print('Saved ${bytes.length} bytes (streamed)');
      }
    }
  } finally {
    client.close();
  }
}
