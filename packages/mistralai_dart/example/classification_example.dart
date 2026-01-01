// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating text classification with the Mistral AI API.
///
/// This example shows how to:
/// - Classify text content
/// - Classify chat conversations
/// - Analyze classification results
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Example 1: Basic text classification ---
    print('=== Basic Text Classification ===\n');

    final textResponse = await client.classifications.create(
      request: ClassificationRequest.single(
        input: 'This is a technical article about machine learning.',
      ),
    );

    print('Content flagged: ${textResponse.flagged}');
    if (textResponse.firstResult != null) {
      final result = textResponse.firstResult!;
      print('Categories: ${result.categories}');
    }

    // --- Example 2: Batch text classification ---
    print('\n=== Batch Text Classification ===\n');

    final batchResponse = await client.classifications.create(
      request: const ClassificationRequest(
        input: [
          'How do I implement a binary search tree?',
          'What are the best practices for REST API design?',
          'Can you explain quantum computing basics?',
        ],
      ),
    );

    print('Number of results: ${batchResponse.results.length}');
    print('Any content flagged: ${batchResponse.flagged}');

    for (var i = 0; i < batchResponse.results.length; i++) {
      final result = batchResponse.results[i];
      print('  Input $i flagged: ${result.flagged}');
    }

    // --- Example 3: Chat classification ---
    print('\n=== Chat Classification ===\n');

    final chatResponse = await client.classifications.createChat(
      request: ChatClassificationRequest(
        input: [
          ChatMessage.user('What is the capital of France?'),
          ChatMessage.assistant('The capital of France is Paris.'),
          ChatMessage.user('Tell me more about Paris.'),
        ],
      ),
    );

    print('Chat content flagged: ${chatResponse.flagged}');
    if (chatResponse.firstResult != null) {
      print('Chat categories: ${chatResponse.firstResult!.categories}');
    }

    // --- Example 4: Using classification for content filtering ---
    print('\n=== Content Filtering Example ===\n');

    final messages = [
      'How to make a delicious pasta recipe',
      'Tips for learning a new programming language',
      'Best practices for code review',
    ];

    for (final message in messages) {
      final response = await client.classifications.create(
        request: ClassificationRequest.single(input: message),
      );

      final status = response.flagged ? 'BLOCKED' : 'ALLOWED';
      print('[$status] $message');
    }

    // --- Example 5: Analyzing classification scores ---
    print('\n=== Analyzing Classification Scores ===\n');

    final analysisResponse = await client.classifications.create(
      request: ClassificationRequest.single(
        input: 'This is a professional document about software architecture.',
      ),
    );

    if (analysisResponse.firstResult != null) {
      final scores = analysisResponse.firstResult!.categoryScores;
      print('Classification Analysis:');
      print('  Sexual content: ${(scores.sexual * 100).toStringAsFixed(2)}%');
      print('  Hate speech: ${(scores.hate * 100).toStringAsFixed(2)}%');
      print('  Violence: ${(scores.violence * 100).toStringAsFixed(2)}%');
      print('  Harassment: ${(scores.harassment * 100).toStringAsFixed(2)}%');

      // Calculate overall safety score
      final maxScore = [
        scores.sexual,
        scores.hate,
        scores.violence,
        scores.harassment,
      ].reduce((a, b) => a > b ? a : b);

      final safetyLevel = maxScore < 0.1
          ? 'SAFE'
          : maxScore < 0.5
          ? 'MODERATE'
          : 'HIGH RISK';
      print('\nOverall safety level: $safetyLevel');
    }
  } finally {
    client.close();
  }
}
