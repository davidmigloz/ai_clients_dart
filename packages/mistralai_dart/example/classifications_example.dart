// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example of using the Mistral AI Classifications API.
///
/// The Classifications API helps categorize text content into predefined
/// categories, useful for content routing, tagging, and organization.
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
    // Example 1: Classify single text input
    print('=== Single Text Classification ===');
    final singleResponse = await client.classifications.create(
      request: ClassificationRequest.single(
        input: 'I love programming in Dart!',
      ),
    );

    print('Input: "I love programming in Dart!"');
    print('Flagged: ${singleResponse.flagged}');
    print('Results:');
    for (final result in singleResponse.results) {
      print('  Categories: ${result.categories}');
    }

    // Example 2: Classify multiple text inputs
    print('\n=== Batch Text Classification ===');
    final batchResponse = await client.classifications.create(
      request: const ClassificationRequest(
        input: [
          'This is a technical question about APIs',
          'I need help with my order',
          'Tell me a joke',
        ],
      ),
    );

    print('Batch classification results:');
    print('Flagged: ${batchResponse.flagged}');
    for (var i = 0; i < batchResponse.results.length; i++) {
      print('  Input ${i + 1}:');
      print('    Categories: ${batchResponse.results[i].categories}');
    }

    // Example 3: Classify chat messages
    print('\n=== Chat Message Classification ===');
    final chatResponse = await client.classifications.createChat(
      request: ChatClassificationRequest(
        input: [
          ChatMessage.user('How do I reset my password?'),
        ],
      ),
    );

    print('Chat classification results:');
    print('Flagged: ${chatResponse.flagged}');
    for (var i = 0; i < chatResponse.results.length; i++) {
      print('  Result ${i + 1}:');
      print('    Categories: ${chatResponse.results[i].categories}');
    }

    print('\n=== Classification API Notes ===');
    print('- Use for content routing and categorization');
    print('- Supports single text, batch, and chat formats');
    print('- Returns category predictions with flags');
    print('- Useful for:');
    print('  * Support ticket routing');
    print('  * Content tagging');
    print('  * Intent detection');
    print('  * Topic classification');
  } finally {
    client.close();
  }
}
