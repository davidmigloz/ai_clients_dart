// ignore_for_file: avoid_print
/// Example demonstrating streaming chat completions.
///
/// Run with OPENAI_API_KEY set: dart run example/streaming_example.dart
/// Makes three paid requests with bounded output and retries disabled.
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient(
    config: OpenAIConfig.fromEnvironment().copyWith(
      retryPolicy: const RetryPolicy(maxRetries: 0),
      timeout: const Duration(seconds: 60),
    ),
  );

  try {
    // Basic streaming
    print('=== Basic Streaming ===\n');

    final stream = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-6-luna',
        reasoningEffort: ReasoningEffort.none,
        store: false,
        messages: [ChatMessage.user('Count from 1 to 10 slowly.')],
        maxCompletionTokens: 100,
        streamOptions: const StreamOptions(
          includeUsage: true,
          includeObfuscation: true,
        ),
      ),
    );

    await for (final event in stream) {
      // Padding in event.obfuscation is metadata; render content deltas only.
      if (event.textDelta case final delta?) {
        stdout.write(delta);
      }
      if (event.usage case final usage?) {
        // The final usage-only chunk has choices: []. Avoid .choices!.first.
        print(
          '\nPrompt text/image/cache writes: '
          '${usage.promptTokensDetails?.textTokens}/'
          '${usage.promptTokensDetails?.imageTokens}/'
          '${usage.promptTokensDetails?.cacheWriteTokens}',
        );
        print(
          'Completion text tokens: '
          '${usage.completionTokensDetails?.textTokens}',
        );
      }
    }
    print('\n');

    // Using collectText extension
    print('=== Using collectText Extension ===\n');

    final stream2 = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-6-luna',
        reasoningEffort: ReasoningEffort.none,
        store: false,
        messages: [ChatMessage.user('Say hello in 5 different languages.')],
        maxCompletionTokens: 200,
      ),
    );

    final fullText = await stream2.collectText();
    print('Collected text:\n$fullText\n');

    // Using accumulator
    print('=== Using Accumulator ===\n');

    // Explicit false disables padding; omitted keeps the server default.
    final stream3 = client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-6-luna',
        reasoningEffort: ReasoningEffort.none,
        store: false,
        messages: [ChatMessage.user('Write a short haiku about programming.')],
        maxCompletionTokens: 100,
        streamOptions: const StreamOptions(
          includeUsage: true,
          includeObfuscation: false,
        ),
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
    print('Final usage: ${accumulator.usage}');

    // Convert accumulated stream to a ChatCompletion object
    final completion = accumulator.toChatCompletion();
    print('Model: ${completion.model}');
    print('Text: ${completion.text}');
  } finally {
    client.close();
  }
}
