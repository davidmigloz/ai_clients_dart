// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Basic example of creating a response using the OpenResponses API.
///
/// This example demonstrates:
/// - Creating an OpenResponsesClient
/// - Making a simple text request
/// - Accessing the response content
///
/// Set the OPENAI_API_KEY environment variable before running.
void main() async {
  // Create a client using environment variables
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider(
        Platform.environment['OPENAI_API_KEY'] ?? '',
      ),
    ),
  );

  try {
    // Simple text request
    print('Sending request...');
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput('Solve 8x + 31 = 2'),
      ),
    );

    // Access the response
    print('Response status: ${response.status}');
    print('Model: ${response.model}');
    print('Output: ${response.outputText}');

    // Access usage information
    if (response.usage != null) {
      print('Input tokens: ${response.usage!.inputTokens}');
      print('Output tokens: ${response.usage!.outputTokens}');
      print('Total tokens: ${response.usage!.totalTokens}');
    }
  } finally {
    client.close();
  }
}
