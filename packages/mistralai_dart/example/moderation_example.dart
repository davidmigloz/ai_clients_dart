// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating content moderation with the Mistral AI API.
///
/// This example shows how to:
/// - Moderate text content for safety
/// - Moderate chat conversations
/// - Check for different content categories
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Example 1: Basic text moderation ---
    print('=== Basic Text Moderation ===\n');

    final textResponse = await client.moderations.create(
      request: ModerationRequest.single(
        input: 'This is a safe message about programming.',
      ),
    );

    print('Content flagged: ${textResponse.flagged}');
    if (textResponse.firstResult != null) {
      final result = textResponse.firstResult!;
      print('Categories: ${result.categories}');
      print('Sexual score: ${result.categoryScores.sexual}');
      print('Hate score: ${result.categoryScores.hate}');
      print('Violence score: ${result.categoryScores.violence}');
    }

    // --- Example 2: Batch text moderation ---
    print('\n=== Batch Text Moderation ===\n');

    final batchResponse = await client.moderations.create(
      request: const ModerationRequest(
        input: [
          'Hello, how are you today?',
          'I love programming in Dart!',
          'The weather is beautiful outside.',
        ],
      ),
    );

    print('Number of results: ${batchResponse.results.length}');
    print('Any content flagged: ${batchResponse.flagged}');

    for (var i = 0; i < batchResponse.results.length; i++) {
      final result = batchResponse.results[i];
      print('  Input $i flagged: ${result.flagged}');
    }

    // --- Example 3: Chat moderation ---
    print('\n=== Chat Moderation ===\n');

    final chatResponse = await client.moderations.createChat(
      request: ChatModerationRequest(
        input: [
          ChatMessage.user('Can you help me with my homework?'),
          ChatMessage.assistant(
            "Of course! I'd be happy to help. What subject?",
          ),
          ChatMessage.user('I need help with my math assignment.'),
        ],
      ),
    );

    print('Chat content flagged: ${chatResponse.flagged}');
    if (chatResponse.firstResult != null) {
      print('Chat categories: ${chatResponse.firstResult!.categories}');
    }

    // --- Example 4: Analyzing moderation scores ---
    print('\n=== Analyzing Moderation Scores ===\n');

    final analysisResponse = await client.moderations.create(
      request: ModerationRequest.single(
        input: 'This is a completely normal business email about our project.',
      ),
    );

    if (analysisResponse.firstResult != null) {
      final scores = analysisResponse.firstResult!.categoryScores;
      print('Content Safety Analysis:');
      print('  Sexual content: ${(scores.sexual * 100).toStringAsFixed(2)}%');
      print('  Hate speech: ${(scores.hate * 100).toStringAsFixed(2)}%');
      print('  Violence: ${(scores.violence * 100).toStringAsFixed(2)}%');
      print('  Harassment: ${(scores.harassment * 100).toStringAsFixed(2)}%');
      print('  Self-harm: ${(scores.selfHarm * 100).toStringAsFixed(2)}%');

      // Check against custom threshold
      const threshold = 0.1;
      final lowRisk =
          scores.sexual < threshold &&
          scores.hate < threshold &&
          scores.violence < threshold &&
          scores.harassment < threshold;

      print('\nContent is ${lowRisk ? "LOW RISK" : "REQUIRES REVIEW"}');
    }
  } finally {
    client.close();
  }
}
