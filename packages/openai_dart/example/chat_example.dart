// ignore_for_file: avoid_print
/// Example demonstrating basic chat completions with OpenAI.
///
/// Run with: dart run example/chat_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // Simple chat completion
    print('=== Simple Chat Completion ===\n');

    final response = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user('What is the capital of France?')],
        maxTokens: 100,
      ),
    );

    print('Response: ${response.text}');
    print('Finish reason: ${response.choices.first.finishReason}');
    print(
      'Tokens: ${response.usage?.promptTokens} prompt, '
      '${response.usage?.completionTokens} completion\n',
    );

    // Chat with system message
    print('=== With System Message ===\n');

    final response2 = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [
          ChatMessage.system('You are a helpful assistant that speaks French.'),
          ChatMessage.user('What is the capital of France?'),
        ],
        maxTokens: 100,
      ),
    );

    print('Response: ${response2.text}\n');

    // Multi-turn conversation
    print('=== Multi-turn Conversation ===\n');

    final response3 = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [
          ChatMessage.user('My name is Alice.'),
          ChatMessage.assistant(content: 'Hello Alice! Nice to meet you.'),
          ChatMessage.user('What is my name?'),
        ],
        maxTokens: 50,
      ),
    );

    print('Response: ${response3.text}\n');
  } finally {
    client.close();
  }
}
