// ignore_for_file: avoid_print, unused_local_variable
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Quick start example for anthropic_sdk_dart.
///
/// This example demonstrates the basic usage of the Anthropic API client.
/// Make sure to set the ANTHROPIC_API_KEY environment variable before running.
void main() async {
  // Create client (reads ANTHROPIC_API_KEY from environment)
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // --- Basic Message ---
    print('=== Basic Message ===');
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [InputMessage.user('What is the capital of France?')],
      ),
    );

    print('Response: ${response.text}');
    print('Stop reason: ${response.stopReason}');
    print(
      'Usage: ${response.usage.inputTokens} in, '
      '${response.usage.outputTokens} out',
    );

    // --- Multi-turn Conversation ---
    print('\n=== Multi-turn Conversation ===');
    final conversation = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [
          InputMessage.user('My name is Alice.'),
          InputMessage.assistant('Nice to meet you, Alice!'),
          InputMessage.user('What is my name?'),
        ],
      ),
    );
    print('Response: ${conversation.text}');

    // --- System Prompt ---
    print('\n=== System Prompt ===');
    final pirate = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        system: SystemPrompt.text(
          'You are a friendly pirate. Respond in pirate speak.',
        ),
        messages: [InputMessage.user('Hello, how are you?')],
      ),
    );
    print('Pirate says: ${pirate.text}');

    // --- Streaming ---
    print('\n=== Streaming ===');
    stdout.write('Streaming response: ');
    final stream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 256,
        messages: [InputMessage.user('Count from 1 to 5 slowly.')],
      ),
    );

    await for (final event in stream) {
      if (event is ContentBlockDeltaEvent) {
        final delta = event.delta;
        if (delta is TextDelta) {
          stdout.write(delta.text);
        }
      }
    }
    print(''); // Newline after stream

    // --- List Models ---
    print('\n=== Available Models ===');
    final models = await client.models.list();
    for (final model in models.data.take(3)) {
      print('- ${model.id}: ${model.displayName}');
    }

    print('\nDone!');
  } finally {
    client.close();
  }
}
