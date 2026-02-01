// ignore_for_file: avoid_print
/// Example demonstrating content moderation with OpenAI.
///
/// The Moderation API classifies text for potentially harmful content
/// across categories like hate, harassment, self-harm, sexual content,
/// and violence.
///
/// Run with: dart run example/moderation_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // Basic moderation check
    print('=== Basic Moderation ===\n');

    final response = await client.moderations.create(
      ModerationRequest(
        input: ModerationInput.text(
          'The quick brown fox jumps over the lazy dog.',
        ),
      ),
    );

    print('Model used: ${response.model}');
    print('Moderation ID: ${response.id}');
    print('Flagged: ${response.first.flagged}\n');

    // Check multiple texts at once
    print('=== Batch Moderation ===\n');

    final batchResponse = await client.moderations.create(
      ModerationRequest(
        input: ModerationInput.textList([
          'Hello, how are you?',
          'This is a normal sentence.',
          'Have a great day!',
        ]),
      ),
    );

    print('Checked ${batchResponse.results.length} text(s):');
    for (var i = 0; i < batchResponse.results.length; i++) {
      final result = batchResponse.results[i];
      print('  Text ${i + 1}: ${result.flagged ? "FLAGGED" : "OK"}');
    }
    print('');

    // Detailed category analysis
    print('=== Category Analysis ===\n');

    final detailedResponse = await client.moderations.create(
      ModerationRequest(
        input: ModerationInput.text('This is sample text for analysis.'),
        model: 'text-moderation-latest',
      ),
    );

    final categories = detailedResponse.first.categories;
    print('Category flags:');
    print('  Hate: ${categories.hate}');
    print('  Hate/Threatening: ${categories.hateThreatening}');
    print('  Harassment: ${categories.harassment}');
    print('  Harassment/Threatening: ${categories.harassmentThreatening}');
    print('  Self-harm: ${categories.selfHarm}');
    print('  Self-harm/Intent: ${categories.selfHarmIntent}');
    print('  Self-harm/Instructions: ${categories.selfHarmInstructions}');
    print('  Sexual: ${categories.sexual}');
    print('  Sexual/Minors: ${categories.sexualMinors}');
    print('  Violence: ${categories.violence}');
    print('  Violence/Graphic: ${categories.violenceGraphic}');
    print('');

    // Category confidence scores
    print('=== Category Scores ===\n');

    final scores = detailedResponse.first.categoryScores;
    print('Confidence scores (0.0 - 1.0):');
    print('  Hate: ${scores.hate.toStringAsFixed(6)}');
    print('  Hate/Threatening: ${scores.hateThreatening.toStringAsFixed(6)}');
    print('  Harassment: ${scores.harassment.toStringAsFixed(6)}');
    print(
      '  Harassment/Threatening: '
      '${scores.harassmentThreatening.toStringAsFixed(6)}',
    );
    print('  Self-harm: ${scores.selfHarm.toStringAsFixed(6)}');
    print('  Self-harm/Intent: ${scores.selfHarmIntent.toStringAsFixed(6)}');
    print(
      '  Self-harm/Instructions: '
      '${scores.selfHarmInstructions.toStringAsFixed(6)}',
    );
    print('  Sexual: ${scores.sexual.toStringAsFixed(6)}');
    print('  Sexual/Minors: ${scores.sexualMinors.toStringAsFixed(6)}');
    print('  Violence: ${scores.violence.toStringAsFixed(6)}');
    print('  Violence/Graphic: ${scores.violenceGraphic.toStringAsFixed(6)}');
    print('');

    // Convenience methods
    print('=== Convenience Methods ===\n');

    final convenienceResponse = await client.moderations.create(
      ModerationRequest(input: ModerationInput.text('Normal text here.')),
    );

    print('Any input flagged: ${convenienceResponse.anyFlagged}');
    print('First result flagged: ${convenienceResponse.first.flagged}');
    print('');

    // Model options
    print('=== Model Options ===\n');
    print('Available moderation models:');
    print('  - text-moderation-latest (recommended, updates automatically)');
    print(
      '  - text-moderation-stable (consistent behavior, less frequent '
      'updates)',
    );
    print('  - omni-moderation-latest (supports images, newest model)');
    print('');

    // Usage pattern for content filtering
    print('=== Content Filtering Pattern ===\n');
    print('''
// Example: Pre-moderation before processing user input
Future<bool> isContentSafe(
  OpenAIClient client,
  String userInput,
) async {
  final result = await client.moderations.create(
    ModerationRequest(
      input: ModerationInput.text(userInput),
    ),
  );
  return !result.anyFlagged;
}

// Example: Post-moderation of AI responses
Future<String?> moderateResponse(
  OpenAIClient client,
  String aiResponse,
) async {
  final result = await client.moderations.create(
    ModerationRequest(
      input: ModerationInput.text(aiResponse),
    ),
  );

  if (result.anyFlagged) {
    // Log the flagged categories
    final flagged = result.first;
    if (flagged.categories.hate) print('Hate speech detected');
    if (flagged.categories.violence) print('Violence detected');
    // ... handle appropriately
    return null; // Don't show flagged content
  }

  return aiResponse;
}
''');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
