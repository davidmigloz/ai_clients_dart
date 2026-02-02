// ignore_for_file: avoid_print
/// Demonstrates native image generation using Gemini multimodal models.
///
/// This example shows how to:
/// - Generate images from text prompts
/// - Configure aspect ratio and image size
/// - Handle the response (text description + base64 image data)
///
/// Supported models: gemini-2.5-flash-image, gemini-3-pro-image-preview
///
/// Note: The model always returns both text and images when using
/// `responseModalities: ['TEXT', 'IMAGE']`.
library;

import 'dart:convert';
import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(
      authProvider: ApiKeyProvider('YOUR_API_KEY'), // Replace with your API key
    ),
  );

  try {
    // Example 1: Basic image generation
    print('=== Basic Image Generation ===\n');

    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash-image',
      request: GenerateContentRequest(
        contents: [
          Content.text('Generate an image of a sunset over mountains'),
        ],
        generationConfig: const GenerationConfig(
          responseModalities: ['TEXT', 'IMAGE'],
        ),
      ),
    );

    // Print the text response (model describes what it generated)
    print('Model response: ${response.text}');

    // Access base64 image data using the .data extension
    final imageData = response.data;
    if (imageData != null) {
      print('Image generated successfully!');
      print('Image data length: ${imageData.length} characters (base64)');

      // Save to file
      final bytes = base64Decode(imageData);
      await io.File('generated_sunset.png').writeAsBytes(bytes);
      print('Saved to generated_sunset.png');
    } else {
      print('No image data in response');
    }

    // Example 2: Custom image configuration
    print('\n=== Custom Image Configuration ===\n');

    final customResponse = await client.models.generateContent(
      model: 'gemini-2.5-flash-image',
      request: GenerateContentRequest(
        contents: [
          Content.text('A futuristic cityscape at night with neon lights'),
        ],
        generationConfig: const GenerationConfig(
          responseModalities: ['TEXT', 'IMAGE'],
          imageConfig: ImageConfig(
            aspectRatio: '16:9', // Widescreen format
            imageSize: '2K', // Higher resolution
          ),
        ),
      ),
    );

    print('Model response: ${customResponse.text}');

    final customImageData = customResponse.data;
    if (customImageData != null) {
      final bytes = base64Decode(customImageData);
      await io.File('generated_cityscape.png').writeAsBytes(bytes);
      print('Saved to generated_cityscape.png');
    }

    // Example 3: Image editing with multi-turn conversation
    print('\n=== Image Editing (Multi-turn) ===\n');

    // First, generate an initial image
    final initialResponse = await client.models.generateContent(
      model: 'gemini-2.5-flash-image',
      request: GenerateContentRequest(
        contents: [Content.text('A calm lake surrounded by pine trees')],
        generationConfig: const GenerationConfig(
          responseModalities: ['TEXT', 'IMAGE'],
        ),
      ),
    );

    print('Initial image: ${initialResponse.text}');

    // Get the image data from the response parts
    final initialImageParts = initialResponse.candidates?.first.content?.parts;
    if (initialImageParts != null) {
      // Build a multi-turn conversation to edit the image
      final editResponse = await client.models.generateContent(
        model: 'gemini-2.5-flash-image',
        request: GenerateContentRequest(
          contents: [
            // Include the original generation turn
            const Content(
              role: 'user',
              parts: [TextPart('A calm lake surrounded by pine trees')],
            ),
            Content(role: 'model', parts: initialImageParts),
            // Request an edit
            const Content(
              role: 'user',
              parts: [TextPart('Add a small wooden cabin on the shore')],
            ),
          ],
          generationConfig: const GenerationConfig(
            responseModalities: ['TEXT', 'IMAGE'],
          ),
        ),
      );

      print('Edited image: ${editResponse.text}');

      final editedImageData = editResponse.data;
      if (editedImageData != null) {
        final bytes = base64Decode(editedImageData);
        await io.File('generated_lake_with_cabin.png').writeAsBytes(bytes);
        print('Saved to generated_lake_with_cabin.png');
      }
    }

    // Example 4: Square format for social media
    print('\n=== Square Format (Social Media) ===\n');

    final squareResponse = await client.models.generateContent(
      model: 'gemini-2.5-flash-image',
      request: GenerateContentRequest(
        contents: [Content.text('A cute robot holding a cup of coffee')],
        generationConfig: const GenerationConfig(
          responseModalities: ['TEXT', 'IMAGE'],
          imageConfig: ImageConfig(
            aspectRatio: '1:1', // Square format
            imageSize: '1K',
          ),
        ),
      ),
    );

    print('Model response: ${squareResponse.text}');

    if (squareResponse.data != null) {
      print('Square image generated successfully!');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
