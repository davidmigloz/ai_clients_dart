// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating error handling patterns.
///
/// Shows how to handle various API errors gracefully.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Handle common API errors
    await handleApiErrors(client);

    // Example 2: Retry with exponential backoff
    await retryWithBackoff(client);

    // Example 3: Graceful degradation
    await gracefulDegradation(client);
  } finally {
    client.close();
  }
}

/// Handle common API errors.
Future<void> handleApiErrors(MistralClient client) async {
  print('=== Handling API Errors ===\n');

  // Example: Invalid model
  try {
    await client.chat.create(
      request: ChatCompletionRequest(
        model: 'invalid-model-name',
        messages: [ChatMessage.user('Hello')],
      ),
    );
  } on ApiException catch (e) {
    print('API Error: ${e.message}');
    print('Status code: ${e.code}');
    print('');
  }

  // Example: Empty messages
  try {
    await client.chat.create(
      request: const ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [],
      ),
    );
  } on ApiException catch (e) {
    print('Validation Error: ${e.message}');
    print('');
  }
}

/// Retry failed requests with exponential backoff.
Future<void> retryWithBackoff(MistralClient client) async {
  print('=== Retry with Exponential Backoff ===\n');

  const maxRetries = 3;
  var retryCount = 0;
  var delay = const Duration(seconds: 1);

  while (retryCount < maxRetries) {
    try {
      final response = await client.chat.create(
        request: ChatCompletionRequest(
          model: 'mistral-small-latest',
          messages: [ChatMessage.user('Say "success"')],
          maxTokens: 10,
        ),
      );

      print('Success on attempt ${retryCount + 1}');
      print('Response: ${response.text}');
      return;
    } on ApiException catch (e) {
      retryCount++;

      // Check if it's a retryable error (rate limit, server error)
      final code = e.code;
      final isRetryable = code == 429 || (code >= 500 && code < 600);

      if (!isRetryable || retryCount >= maxRetries) {
        print('Non-retryable error or max retries reached: ${e.message}');
        rethrow;
      }

      print('Attempt $retryCount failed, retrying in ${delay.inSeconds}s...');
      await Future<void>.delayed(delay);
      delay *= 2; // Exponential backoff
    }
  }

  print('');
}

/// Graceful degradation with fallback models.
Future<void> gracefulDegradation(MistralClient client) async {
  print('=== Graceful Degradation ===\n');

  // List of models to try, from preferred to fallback
  final models = [
    'mistral-large-latest', // Primary
    'mistral-medium-latest', // Fallback 1
    'mistral-small-latest', // Fallback 2
  ];

  for (final model in models) {
    try {
      print('Trying model: $model');

      final response = await client.chat.create(
        request: ChatCompletionRequest(
          model: model,
          messages: [ChatMessage.user('Hello!')],
          maxTokens: 50,
        ),
      );

      print('Success with model: $model');
      print('Response: ${response.text}\n');
      return;
    } on ApiException catch (e) {
      print('Model $model failed: ${e.message}');

      if (model == models.last) {
        print('All models failed');
        rethrow;
      }

      print('Trying next fallback...\n');
    }
  }
}
