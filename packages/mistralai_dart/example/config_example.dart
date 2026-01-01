// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating client configuration options.
///
/// Shows how to configure the client for different use cases.
void main() async {
  // Example 1: Basic configuration
  basicConfiguration();

  // Example 2: Custom base URL
  customBaseUrl();

  // Example 3: Custom HTTP client
  customHttpClient();

  // Example 4: Request options
  await requestOptions();
}

/// Basic client configuration.
void basicConfiguration() {
  print('=== Basic Configuration ===\n');

  // Using API key from environment
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('MISTRAL_API_KEY not set');
    return;
  }

  // Simple configuration
  final client = MistralClient.withApiKey(apiKey);
  print('Client created with default settings');
  print('Base URL: https://api.mistral.ai/v1');

  client.close();
  print('');
}

/// Using a custom base URL.
void customBaseUrl() {
  print('=== Custom Base URL ===\n');

  // For self-hosted or proxy deployments
  const customUrl = 'https://my-proxy.example.com/v1';

  final client = MistralClient.withBaseUrl(
    apiKey: 'your-api-key',
    baseUrl: customUrl,
  );

  print('Client created with custom base URL: $customUrl');
  print('Useful for:');
  print('  - Self-hosted deployments');
  print('  - API proxies and gateways');
  print('  - Testing environments');

  client.close();
  print('');
}

/// Using a custom HTTP client.
void customHttpClient() {
  print('=== Custom HTTP Client ===\n');

  // You can provide your own HTTP client for advanced use cases
  print('Custom HTTP client use cases:');
  print('  - Custom timeouts');
  print('  - Retry interceptors');
  print('  - Request/response logging');
  print('  - Certificate pinning');
  print('  - Proxy configuration');
  print('');

  // Example with MistralConfig for more control
  final client = MistralClient(
    config: const MistralConfig(authProvider: ApiKeyProvider('your-api-key')),
  );

  print('Client created with MistralConfig');

  client.close();
  print('');
}

/// Request-specific options.
Future<void> requestOptions() async {
  print('=== Request Options ===\n');

  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('MISTRAL_API_KEY not set - skipping live demo');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Demonstrate various request options
    print('Available request parameters:\n');

    print('Temperature (0.0 - 1.0):');
    print('  - 0.0: Deterministic, focused responses');
    print('  - 0.5: Balanced creativity');
    print('  - 1.0: Maximum creativity/randomness\n');

    print('Top P (nucleus sampling):');
    print('  - Controls diversity via cumulative probability\n');

    print('Max Tokens:');
    print('  - Limits response length\n');

    print('Stop sequences:');
    print('  - Custom strings to stop generation\n');

    // Live example with different temperatures
    print('Example with temperature=0 (deterministic):');

    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [ChatMessage.user('What is 2+2?')],
        temperature: 0,
        maxTokens: 20,
      ),
    );

    print('Response: ${response.text}');
  } finally {
    client.close();
  }

  print('');
}
