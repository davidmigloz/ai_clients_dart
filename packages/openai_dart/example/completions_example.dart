// ignore_for_file: avoid_print
/// Example demonstrating legacy Completions API usage.
///
/// **Note:** This API is deprecated. Use chat completions for new applications.
///
/// Run with: dart run example/completions_example.dart
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Create a completion
    print('=== Create Completion ===\n');

    final completion = await client.completions.create(
      const CompletionRequest(
        model: 'gpt-3.5-turbo-instruct',
        prompt: CompletionPrompt.text('Once upon a time'),
        maxTokens: 50,
      ),
    );

    print('Text: ${completion.text}');
    print('Finish reason: ${completion.choices.first.finishReason}');
    print('Usage: ${completion.usage?.totalTokens} tokens\n');

    // Streaming completion
    print('=== Streaming Completion ===\n');

    final stream = client.completions.createStream(
      const CompletionRequest(
        model: 'gpt-3.5-turbo-instruct',
        prompt: CompletionPrompt.text('The quick brown fox'),
        maxTokens: 30,
      ),
    );

    await for (final chunk in stream) {
      stdout.write(chunk.text);
    }
    print('\n');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
  } finally {
    client.close();
    print('Done!');
  }
}
