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
    // 1. Simple chat completion
    print('=== Chat Completion ===\n');

    final response = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [
          ChatMessage.system('You are a helpful assistant.'),
          ChatMessage.user('What is Dart programming language?'),
        ],
        maxTokens: 150,
      ),
    );

    print('Response: ${response.text}\n');

    // 2. Streaming
    print('=== Streaming ===\n');

    final stream = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user('Count from 1 to 5')],
        maxTokens: 50,
      ),
    );

    stdout.write('Streaming: ');
    await for (final event in stream) {
      stdout.write(event.textDelta ?? '');
    }
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
