// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Reasoning example using the OpenResponses API.
///
/// This example demonstrates:
/// - Using reasoning models (like o1)
/// - Configuring reasoning effort levels
/// - Accessing reasoning summaries
///
/// Set the OPENAI_API_KEY environment variable before running.
void main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider(
        Platform.environment['OPENAI_API_KEY'] ?? '',
      ),
    ),
  );

  try {
    // Example 1: Basic reasoning with high effort
    print('=== Reasoning with High Effort ===\n');

    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'o1-mini', // Use a reasoning model
        input: ResponseTextInput('''
A farmer has 17 sheep. All but 9 run away.
How many sheep does the farmer have left?
Explain your reasoning step by step.
'''),
        reasoning: ReasoningConfig(
          effort: ReasoningEffort.high,
          summary: ReasoningSummary.detailed,
        ),
      ),
    );

    print('Status: ${response.status}');
    print('Model: ${response.model}');
    print('');

    // Access reasoning items if available
    if (response.reasoningItems.isNotEmpty) {
      print('Reasoning process:');
      for (final item in response.reasoningItems) {
        for (final content in item.summary) {
          print('  - ${content.text}');
        }
      }
      print('');
    }

    print('Final answer: ${response.outputText}');

    // Example 2: Streaming with reasoning
    print('\n=== Streaming Reasoning ===\n');

    await for (final event in client.responses.createStream(
      const CreateResponseRequest(
        model: 'o1-mini',
        input: ResponseTextInput(
          'What is the next number in this sequence: 2, 6, 12, 20, 30, ?',
        ),
        reasoning: ReasoningConfig(
          effort: ReasoningEffort.medium,
          summary: ReasoningSummary.concise,
        ),
      ),
    )) {
      switch (event) {
        case ReasoningDeltaEvent():
          // Reasoning tokens (may be hidden depending on model)
          stdout.write('[R]');
        case ReasoningSummaryDeltaEvent():
          stdout.write(event.delta);
        case OutputTextDeltaEvent():
          stdout.write(event.delta);
        case ResponseCompletedEvent():
          print('\n\n[Completed]');
          if (event.response.usage != null) {
            final usage = event.response.usage!;
            print('Input tokens: ${usage.inputTokens}');
            print('Output tokens: ${usage.outputTokens}');
            if (usage.outputTokensDetails?.reasoningTokens != null) {
              print(
                'Reasoning tokens: ${usage.outputTokensDetails!.reasoningTokens}',
              );
            }
          }
        default:
          break;
      }
    }

    // Example 3: Different effort levels
    print('\n=== Comparing Effort Levels ===\n');

    for (final effort in [ReasoningEffort.low, ReasoningEffort.high]) {
      print('Effort: ${effort.name}');

      final effortResponse = await client.responses.create(
        CreateResponseRequest(
          model: 'o1-mini',
          input: const ResponseTextInput('Is 97 a prime number?'),
          reasoning: ReasoningConfig(effort: effort),
        ),
      );

      print('Answer: ${effortResponse.outputText}');
      if (effortResponse.usage != null) {
        print('Tokens used: ${effortResponse.usage!.totalTokens}');
      }
      print('');
    }
  } finally {
    client.close();
  }
}
