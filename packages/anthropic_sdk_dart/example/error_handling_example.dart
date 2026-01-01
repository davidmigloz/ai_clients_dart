// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Error handling example demonstrating exception handling.
///
/// This example shows how to handle various API errors gracefully.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Authentication error (invalid API key)
    print('=== Authentication Error ===');
    final invalidClient = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('invalid-api-key'),
      ),
    );

    try {
      await invalidClient.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('Hello')],
        ),
      );
    } on AuthenticationException catch (e) {
      print('Authentication failed: ${e.message}');
    } finally {
      invalidClient.close();
    }

    // Example 2: Validation error (invalid parameters)
    print('\n=== Validation Error ===');
    try {
      await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: -1, // Invalid: must be positive
          messages: [InputMessage.user('Hello')],
        ),
      );
    } on ApiException catch (e) {
      print('API error (${e.code}): ${e.message}');
    }

    // Example 3: Rate limiting
    print('\n=== Rate Limit Handling ===');
    try {
      // This would happen with too many requests
      await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('Hello')],
        ),
      );
      print('Request succeeded');
    } on RateLimitException catch (e) {
      print('Rate limited: ${e.message}');
      // Implement exponential backoff here
    }

    // Example 4: General error handling
    print('\n=== General Error Handling ===');
    try {
      await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('Hello')],
        ),
      );
      print('Request succeeded');
    } on AuthenticationException {
      print('Invalid API key - please check your credentials');
    } on RateLimitException catch (e) {
      print('Rate limited - try again after ${e.message}');
    } on ApiException catch (e) {
      print('API error ${e.code}: ${e.message}');
    } on AnthropicException catch (e) {
      print('Anthropic error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  } finally {
    client.close();
  }
}
