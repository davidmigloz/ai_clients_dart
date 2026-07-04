// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating basic usage of the Mistral AI Dart client.
///
/// Covers chat completions, embeddings, and OCR document processing with
/// paragraph-level block extraction. See the other files in this directory
/// for per-feature examples (streaming, tool calling, agents, files, etc.).
void main() async {
  // Get the API key from the environment.
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set the MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Chat completion ---
    print('=== Chat ===');
    final chat = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          ChatMessage.system('You are a helpful assistant.'),
          ChatMessage.user('What is the capital of France?'),
        ],
      ),
    );
    print('Assistant: ${chat.text}');
    print('Tokens used: ${chat.usage?.totalTokens}');

    // --- Embeddings ---
    print('\n=== Embeddings ===');
    final embeddings = await client.embeddings.create(
      request: EmbeddingRequest.single(
        model: 'mistral-embed',
        input: 'Hello, world!',
      ),
    );
    final vector = embeddings.data.first.embedding;
    print('Embedding dimension: ${vector.length}');

    // --- OCR with block extraction ---
    print('\n=== OCR ===');
    final ocr = await client.ocr.process(
      request: OcrRequest.fromUrl(
        url: 'https://arxiv.org/pdf/2201.04234',
        // `pages` accepts a list of 0-indexed numbers or a comma-separated
        // string of numbers and ranges (e.g. '0,2-4').
        pages: const OcrPages.string('0'),
        // Return paragraph-level bounding boxes for each content block.
        includeBlocks: true,
      ),
    );
    for (final page in ocr.pages) {
      print('Page ${page.index}: ${page.markdown.length} chars of markdown');
      for (final block in page.blocks ?? const <OcrBlock>[]) {
        // Blocks are a sealed union — switch over the concrete subtypes.
        final detail = switch (block) {
          OcrImageBlock(:final imageId) => ' (image id: $imageId)',
          OcrTableBlock(:final tableId) => ' (table id: $tableId)',
          UnknownOcrBlock() => ' (unrecognized)',
          _ => '',
        };
        print('  [${block.type}]$detail');
      }
    }
  } finally {
    client.close();
  }
}
