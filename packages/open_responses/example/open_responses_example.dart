// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Quick-start example for the OpenResponses Dart client.
///
/// This example demonstrates:
/// - Creating an [OpenResponsesClient]
/// - Making a simple text request and reading the output
/// - Streaming a response with the builder pattern
///
/// For more focused examples (tool calling, structured output, multi-turn
/// conversations, MCP tools, reasoning, error handling, …) see the other
/// files in this directory.
///
/// Set the OPENAI_API_KEY environment variable before running:
///
/// ```bash
/// dart run example/open_responses_example.dart
/// ```
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
    // 1. Simple text request.
    print('=== Basic Request ===\n');
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput('What is the capital of France?'),
      ),
    );

    print('Output: ${response.outputText}');
    if (response.usage != null) {
      print(
        'Tokens: ${response.usage!.inputTokens} in, '
        '${response.usage!.outputTokens} out, '
        '${response.usage!.totalTokens} total',
      );
    }

    // 2. Streaming response with the builder pattern.
    print('\n=== Streaming Request ===\n');
    final runner = client.responses.stream(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput('Write a haiku about Dart.'),
      ),
    )..onTextDelta(stdout.write);

    await runner.finalResponse;
    print('\n\n[Stream completed]');
  } finally {
    client.close();
  }
}
