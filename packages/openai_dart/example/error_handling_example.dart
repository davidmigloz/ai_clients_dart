// ignore_for_file: avoid_print
/// Example demonstrating error handling with OpenAI.
///
/// This example shows how to handle various API errors gracefully.
/// Run with: dart run example/error_handling_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Example 1: Authentication error (invalid API key)
    print('=== Authentication Error ===\n');
    final invalidClient = OpenAIClient.withApiKey('invalid-api-key');

    try {
      await invalidClient.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-5.5',
          messages: [ChatMessage.user('Hello')],
          maxTokens: 100,
        ),
      );
    } on AuthenticationException catch (e) {
      print('Authentication failed: ${e.message}');
      print('This happens when your API key is invalid or expired.\n');
    } finally {
      invalidClient.close();
    }

    // Example 2: Validation error (invalid parameters)
    print('=== Bad Request Error ===\n');
    try {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-5.5',
          messages: [ChatMessage.user('Hello')],
          maxTokens: -1, // Invalid: must be positive
        ),
      );
    } on BadRequestException catch (e) {
      print('Bad request: ${e.message}');
      if (e.param != null) {
        print('Invalid parameter: ${e.param}');
      }
      print('');
    }

    // Example 3: Model not found
    print('=== Not Found Error ===\n');
    try {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-nonexistent-model',
          messages: [ChatMessage.user('Hello')],
        ),
      );
    } on NotFoundException catch (e) {
      print('Not found: ${e.message}');
      print('This happens when the model or resource does not exist.\n');
    } on BadRequestException catch (e) {
      // Some invalid model errors come back as 400 instead of 404
      print('Bad request: ${e.message}\n');
    }

    // Example 4: Rate limiting
    print('=== Rate Limit Handling ===\n');
    try {
      // Make a normal request (rate limiting would occur with many requests)
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-5.5',
          messages: [ChatMessage.user('Hello')],
          maxTokens: 10,
        ),
      );
      print('Request succeeded (no rate limit hit)\n');
    } on RateLimitException catch (e) {
      print('Rate/quota error ${e.code ?? e.type}: ${e.message}');
      if (e.retryAfter != null) {
        print('Full server retry hint: ${e.retryAfter}');
        // Inspect code/type first: billing, spend and quota require action.
        // For a transient error, defer for the full hint and account for any
        // automatic attempts already made, or disable built-in retries.
      }
      print('');
    }

    // Example 5: General error handling pattern
    print('=== General Error Handling Pattern ===\n');
    try {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-5.5',
          messages: [ChatMessage.user('What is 2 + 2?')],
          maxTokens: 50,
        ),
      );
      print('Request succeeded\n');
    } on AuthenticationException catch (e) {
      print('Invalid API key: ${e.message}');
    } on RateLimitException catch (e) {
      print(
        'Rate/quota error ${e.code ?? e.type}; retry hint: ${e.retryAfter}',
      );
      // Fix permanent credit/spend/quota failures before resending.
    } on BadRequestException catch (e) {
      print('Invalid request: ${e.message}');
    } on NotFoundException catch (e) {
      print('Resource not found: ${e.message}');
    } on PermissionDeniedException catch (e) {
      print('Permission denied: ${e.message}');
    } on InternalServerException catch (e) {
      print('Server error (${e.statusCode}): ${e.message}');
      print('Server retry hint: ${e.retryAfter}');
      // POST is not automatically replayed for 5xx. Check the operation outcome
      // before resubmission, and defer for the full server hint when present.
    } on RequestTimeoutException catch (e) {
      print('Request timed out: ${e.message}');
      if (e.timeout != null) {
        print('Timeout was: ${e.timeout!.inSeconds} seconds');
      }
    } on ConnectionException catch (e) {
      print('Connection failed: ${e.message}');
      if (e.url != null) {
        print('URL: ${e.url}');
      }
    } on ApiException catch (e) {
      // Catch-all for other API errors
      print('API error (${e.statusCode}): ${e.message}');
      print('Error type: ${e.type}');
      print('Request ID: ${e.requestId}');
    } on OpenAIException catch (e) {
      // Catch-all for any OpenAI client errors
      print('OpenAI error: ${e.message}');
    }

    // Example 6: Error information
    print('=== Error Information ===\n');
    try {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-5.5',
          messages: [ChatMessage.user('Hello')],
          maxTokens: 0, // Invalid
        ),
      );
    } on ApiException catch (e) {
      print('Status code: ${e.statusCode}');
      print('Message: ${e.message}');
      print('Type: ${e.type}');
      print('Code: ${e.code}');
      print('Parameter: ${e.param}');
      print('Request ID: ${e.requestId}');
      print('');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
