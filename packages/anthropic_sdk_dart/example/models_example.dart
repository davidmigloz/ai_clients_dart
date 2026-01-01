// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Models API example.
///
/// This example demonstrates:
/// - Listing available models
/// - Retrieving a specific model's information
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: List all available models
    print('=== List Models ===');
    final modelsResponse = await client.models.list();

    print('Available models:');
    for (final model in modelsResponse.data) {
      print('  - ${model.id}');
      print('    Display name: ${model.displayName}');
      print('    Created: ${model.createdAt}');
      print('');
    }

    print('Has more: ${modelsResponse.hasMore}');

    // Example 2: Retrieve a specific model
    print('\n=== Retrieve Model ===');
    const modelId = 'claude-sonnet-4-20250514';
    final model = await client.models.retrieve(modelId);

    print('Model details:');
    print('  ID: ${model.id}');
    print('  Display name: ${model.displayName}');
    print('  Created at: ${model.createdAt}');
    print('  Type: ${model.type}');

    // Example 3: List models with pagination
    print('\n=== Paginated List ===');
    final paginatedResponse = await client.models.list(limit: 5);

    print('First page (limit 5):');
    for (final m in paginatedResponse.data) {
      print('  - ${m.id}');
    }
    print('Has more: ${paginatedResponse.hasMore}');

    if (paginatedResponse.hasMore && paginatedResponse.lastId != null) {
      print('\nFetching next page...');
      final nextPage = await client.models.list(
        limit: 5,
        afterId: paginatedResponse.lastId,
      );
      print('Next page:');
      for (final m in nextPage.data) {
        print('  - ${m.id}');
      }
    }
  } finally {
    client.close();
  }
}
