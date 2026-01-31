// ignore_for_file: avoid_print
/// Example demonstrating streaming chat completions.
///
/// Run with: dart run example/streaming_example.dart
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Basic streaming
    print('=== Basic Streaming ===\n');

    final stream = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user('Count from 1 to 10 slowly.')],
        maxTokens: 100,
      ),
    );

    await for (final event in stream) {
      if (event.textDelta case final delta?) {
        stdout.write(delta);
      }
    }
    print('\n');

    // Using collectText extension
    print('=== Using collectText Extension ===\n');

    final stream2 = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user('Say hello in 5 different languages.')],
        maxTokens: 200,
      ),
    );

    final fullText = await stream2.collectText();
    print('Collected text:\n$fullText\n');

    // Using accumulator
    print('=== Using Accumulator ===\n');

    final stream3 = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user('Write a short haiku about programming.')],
        maxTokens: 100,
      ),
    );

    final accumulator = ChatStreamAccumulator();
    await for (final event in stream3) {
      accumulator.add(event);
      stdout.write(event.textDelta ?? '');
    }

    print('\n');
    print('Final content: ${accumulator.content}');
    print('Finish reason: ${accumulator.finishReason}');
  } finally {
    client.close();
  }
}
