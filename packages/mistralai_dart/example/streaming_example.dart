// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example of using streaming chat completions.
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
    print('Streaming response:\n');

    // Stream the response
    final stream = client.chat.createStream(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          ChatMessage.system('You are a creative storyteller.'),
          ChatMessage.user(
            'Tell me a short story about a robot in 3 sentences.',
          ),
        ],
      ),
    );

    // Process each chunk as it arrives
    await for (final chunk in stream) {
      final content = chunk.choices.first.delta.content;
      if (content != null) {
        stdout.write(content);
      }
    }

    print('\n\nStreaming complete!');
  } finally {
    client.close();
  }
}
