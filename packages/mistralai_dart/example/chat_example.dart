// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example of using the Mistral AI chat API.
void main() async {
  // Get API key from environment
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  // Create client
  final client = MistralClient.withApiKey(apiKey);

  try {
    // Simple chat completion
    print('=== Simple Chat ===');
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          ChatMessage.system('You are a helpful assistant.'),
          ChatMessage.user('What is the capital of France?'),
        ],
      ),
    );

    print('Response: ${response.choices.first.message.content}');
    print('Tokens used: ${response.usage?.totalTokens}');

    // Multi-turn conversation
    print('\n=== Multi-turn Conversation ===');
    final conversation = <ChatMessage>[
      ChatMessage.system('You are a helpful math tutor.'),
      ChatMessage.user('What is 2 + 2?'),
    ];

    final firstReply = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: conversation,
      ),
    );

    print('Q: What is 2 + 2?');
    print('A: ${firstReply.choices.first.message.content}');

    // Continue the conversation
    conversation
      ..add(ChatMessage.assistant(firstReply.choices.first.message.content))
      ..add(ChatMessage.user('And what is that multiplied by 3?'));

    final secondReply = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: conversation,
      ),
    );

    print('Q: And what is that multiplied by 3?');
    print('A: ${secondReply.choices.first.message.content}');
  } finally {
    client.close();
  }
}
