// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example of using the Mistral AI Moderations API.
///
/// The Moderations API helps detect potentially harmful or inappropriate
/// content in text and conversations.
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
    // Example 1: Moderate single text input
    print('=== Single Text Moderation ===');
    final singleResponse = await client.moderations.create(
      request: ModerationRequest.single(
        input: 'This is a normal, friendly message.',
      ),
    );

    print('Input: "This is a normal, friendly message."');
    print('Flagged: ${singleResponse.flagged}');
    print('Results:');
    for (final result in singleResponse.results) {
      print('  Categories: ${result.categories}');
      print('  Category Scores: ${result.categoryScores}');
    }

    // Example 2: Moderate multiple text inputs
    print('\n=== Batch Text Moderation ===');
    final batchResponse = await client.moderations.create(
      request: const ModerationRequest(
        input: [
          'Hello, how are you today?',
          'This is another friendly message.',
          'Let me help you with that question.',
        ],
      ),
    );

    print('Batch moderation results:');
    print('Overall flagged: ${batchResponse.flagged}');
    for (var i = 0; i < batchResponse.results.length; i++) {
      print('  Input ${i + 1}: flagged=${batchResponse.results[i].flagged}');
    }

    // Example 3: Moderate chat messages
    print('\n=== Chat Message Moderation ===');
    final chatResponse = await client.moderations.createChat(
      request: ChatModerationRequest(
        input: [
          ChatMessage.user('Can you help me with my homework?'),
          ChatMessage.assistant('Of course! What subject?'),
          ChatMessage.user('I need help with math problems.'),
        ],
      ),
    );

    print('Chat moderation results:');
    print('Overall flagged: ${chatResponse.flagged}');
    for (var i = 0; i < chatResponse.results.length; i++) {
      print('  Result ${i + 1}:');
      print('    Flagged: ${chatResponse.results[i].flagged}');
      print('    Categories: ${chatResponse.results[i].categories}');
    }

    print('\n=== Moderation API Notes ===');
    print('- Use to filter harmful content before display');
    print('- Supports single text, batch, and chat formats');
    print('- Returns category flags and confidence scores');
    print('- Categories include:');
    print('  * Violence');
    print('  * Hate speech');
    print('  * Sexual content');
    print('  * Self-harm');
    print('  * And more...');
    print('');
    print('Best practices:');
    print('- Check flagged field for quick pass/fail');
    print('- Use categoryScores for nuanced filtering');
    print('- Moderate both user input and AI output');
  } finally {
    client.close();
  }
}
