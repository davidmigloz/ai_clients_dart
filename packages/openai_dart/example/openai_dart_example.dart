// ignore_for_file: avoid_print
/// Main example file for openai_dart package.
///
/// This example demonstrates the core functionality of the OpenAI Dart client.
///
/// Run with: dart run example/openai_dart_example.dart
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create a client (uses OPENAI_API_KEY environment variable)
  final client = OpenAIClient.fromEnvironment();

  try {
    // 1. Simple Responses request
    print('=== Responses ===\n');

    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-6.2-sol',
        input: ResponseInput.text('What is the Dart programming language?'),
        maxOutputTokens: 150,
      ),
    );

    print('Response: ${response.outputText}\n');

    // 2. Streaming
    print('=== Streaming ===\n');

    final stream = client.responses.createStream(
      const CreateResponseRequest(
        model: 'gpt-6.2-sol',
        input: ResponseInput.text('Count from 1 to 5'),
        maxOutputTokens: 50,
      ),
    );

    stdout.write('Streaming: ');
    await stream.textDeltas().forEach(stdout.write);
    print('\n');

    // 3. Embeddings
    print('=== Embeddings ===\n');

    final embeddings = await client.embeddings.create(
      EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Hello, world!'),
      ),
    );

    print('Embedding dimensions: ${embeddings.firstEmbedding.length}');
    print('First 3 values: ${embeddings.firstEmbedding.take(3).toList()}\n');

    // 4. List models
    print('=== Available Models ===\n');

    final models = await client.models.list();
    final gptModels = models.data
        .where((m) => m.id.startsWith('gpt'))
        .take(5)
        .toList();

    print('Some GPT models:');
    for (final model in gptModels) {
      print('  - ${model.id}');
    }
    print('');

    // 5. Moderation
    print('=== Content Moderation ===\n');

    final moderation = await client.moderations.create(
      ModerationRequest(
        input: ModerationInput.text('Hello, how are you today?'),
      ),
    );

    print('Content flagged: ${moderation.results.first.flagged}');
  } finally {
    client.close();
  }
}
