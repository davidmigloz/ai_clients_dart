// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating Fill-in-the-Middle (FIM) code completions.
///
/// FIM allows you to define the starting point of code using a prompt,
/// and an optional ending point using a suffix. The model generates
/// the code that fits in between.
///
/// This is ideal for code completion tasks, especially with Codestral models.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    await basicFimCompletion(client);
    await streamingFimCompletion(client);
    await fimWithSuffix(client);
  } finally {
    client.close();
  }
}

/// Basic FIM completion without suffix.
Future<void> basicFimCompletion(MistralClient client) async {
  print('=== Basic FIM Completion ===\n');

  final response = await client.fim.create(
    request: const FimCompletionRequest(
      model: 'codestral-latest',
      prompt:
          'def fibonacci(n):\n    """Calculate the nth Fibonacci number."""\n    ',
      temperature: 0.2,
      maxTokens: 100,
    ),
  );

  print('Prompt: def fibonacci(n):');
  print('Generated code:');
  print(response.choices.first.message);

  if (response.usage != null) {
    print('\nTokens used: ${response.usage!.totalTokens}');
  }
  print('');
}

/// Streaming FIM completion for real-time code generation.
Future<void> streamingFimCompletion(MistralClient client) async {
  print('=== Streaming FIM Completion ===\n');

  print('Prompt: function quickSort(arr) {');
  print('Generated code (streaming):');

  final stream = client.fim.createStream(
    request: const FimCompletionRequest(
      model: 'codestral-latest',
      prompt: 'function quickSort(arr) {\n    ',
      temperature: 0.2,
      maxTokens: 200,
    ),
  );

  await for (final chunk in stream) {
    final content = chunk.choices.first.delta;
    if (content != null) {
      stdout.write(content);
    }
  }
  print('\n');
}

/// FIM completion with both prompt and suffix.
Future<void> fimWithSuffix(MistralClient client) async {
  print('=== FIM with Suffix ===\n');

  const prompt = '''
class Calculator:
    def __init__(self):
        self.result = 0

    def add(self, x):
''';

  const suffix = '''

    def subtract(self, x):
        self.result -= x
        return self
''';

  print('Prompt (before cursor):');
  print(prompt);
  print('Suffix (after cursor):');
  print(suffix);
  print('Generating code between prompt and suffix...\n');

  final response = await client.fim.create(
    request: const FimCompletionRequest(
      model: 'codestral-latest',
      prompt: prompt,
      suffix: suffix,
      temperature: 0.2,
      maxTokens: 50,
    ),
  );

  print('Generated code:');
  print(response.choices.first.message);
  print('');

  // Show complete code
  print('Complete code:');
  print(prompt);
  print(response.choices.first.message);
  print(suffix);
}
