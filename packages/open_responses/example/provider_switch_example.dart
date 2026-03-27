// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Provider switching example using the OpenResponses API.
///
/// This example demonstrates:
/// - Reusing the same request shape across providers
/// - Switching providers through `OpenResponsesConfig`
/// - Using provider-specific auth only when required
///
/// Set `OPENAI_API_KEY` to run the OpenAI example.
/// Start Ollama locally to run the Ollama example.
Future<void> main() async {
  const request = CreateResponseRequest(
    model: 'gpt-4o-mini',
    input: ResponseTextInput(
      'Give one short tip for writing better Dart APIs.',
    ),
  );

  final openAIClient = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider(
        Platform.environment['OPENAI_API_KEY'] ?? '',
      ),
    ),
  );
  final ollamaClient = OpenResponsesClient(
    config: const OpenResponsesConfig(
      baseUrl: 'http://localhost:11434/v1',
      authProvider: NoAuthProvider(),
    ),
  );

  try {
    await _runRequest(label: 'OpenAI', client: openAIClient, request: request);

    await _runRequest(
      label: 'Ollama',
      client: ollamaClient,
      request: const CreateResponseRequest(
        model: 'llama3.2',
        input: ResponseTextInput(
          'Give one short tip for writing better Dart APIs.',
        ),
      ),
    );
  } finally {
    openAIClient.close();
    ollamaClient.close();
  }
}

Future<void> _runRequest({
  required String label,
  required OpenResponsesClient client,
  required CreateResponseRequest request,
}) async {
  try {
    final response = await client.responses.create(request);
    print('[$label] ${response.outputText}');
  } on OpenResponsesException catch (error) {
    print('[$label] Request failed: $error');
  }
}
