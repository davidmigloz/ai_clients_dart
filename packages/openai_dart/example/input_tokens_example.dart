// ignore_for_file: avoid_print
/// Example demonstrating the Input Tokens API for counting tokens.
///
/// This API allows calculating token usage before sending a request
/// to the Responses API.
///
/// Run with: dart run example/input_tokens_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Count tokens for a simple text input
    print('=== Count Input Tokens ===\n');

    final tokenCount = await client.responses.inputTokens.count(
      model: 'gpt-5.5',
      input: const ResponseInput.text('Hello, how are you?'),
    );

    print('Input tokens: ${tokenCount.inputTokens}\n');

    // Count tokens with tools
    print('=== Count Tokens with Tools ===\n');

    final countWithTools = await client.responses.inputTokens.count(
      model: 'gpt-5.5',
      input: const ResponseInput.text('What is the weather in Paris?'),
      tools: [
        ResponseTool.function(
          name: 'get_weather',
          description: 'Get the current weather for a location',
          parameters: {
            'type': 'object',
            'properties': {
              'location': {'type': 'string'},
            },
          },
        ),
      ],
    );

    print('Input tokens (with tools): ${countWithTools.inputTokens}\n');

    // Count tokens with a model-owned style preset (personality).
    // Known presets: Personality.friendly() / Personality.pragmatic().
    // Use Personality.custom('...') for values not yet modeled.
    print('=== Count Tokens with a Personality ===\n');

    final countWithPersonality = await client.responses.inputTokens.count(
      model: 'gpt-5.5',
      input: const ResponseInput.text('Hello, how are you?'),
      personality: const Personality.friendly(),
    );

    print(
      'Input tokens (with personality): ${countWithPersonality.inputTokens}\n',
    );
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
