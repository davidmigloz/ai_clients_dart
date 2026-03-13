// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Streaming example using the OpenResponses API.
///
/// This example demonstrates:
/// - Creating a streaming response
/// - Processing events as they arrive
/// - Using the builder pattern with callbacks
/// - Getting the final response
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
    // Example 1: Using the builder pattern with callbacks
    print('=== Streaming with Builder Pattern ===\n');

    final runner =
        client.responses.stream(
            const CreateResponseRequest(
              model: 'gpt-4o-mini',
              input: ResponseTextInput('Write a haiku about programming.'),
            ),
          )
          ..onTextDelta(stdout.write)
          ..onEvent((event) {
            // You can handle specific events
            if (event is ResponseCompletedEvent) {
              print('\n\n[Stream completed]');
            }
          });

    // Wait for completion and get final response
    final response = await runner.finalResponse;
    print('Final response ID: ${response?.id}');

    // Example 2: Manual event processing
    print('\n=== Manual Event Processing ===\n');

    await for (final event in client.responses.createStream(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput('Count from 1 to 5, one number per line.'),
      ),
    )) {
      switch (event) {
        case ResponseCreatedEvent():
          print('[Response created: ${event.response.id}]');
        case OutputTextDeltaEvent():
          stdout.write(event.delta);
        case ResponseCompletedEvent():
          print(
            '\n[Completed with ${event.response.usage?.totalTokens} tokens]',
          );
        default:
          // Handle other events as needed
          break;
      }
    }

    // Example 3: Simple text accumulation
    print('\n=== Simple Text Accumulation ===\n');

    final text = await client.responses
        .createStream(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseTextInput('Say "Hello, World!"'),
          ),
        )
        .text;

    print('Accumulated text: $text');
  } finally {
    client.close();
  }
}
