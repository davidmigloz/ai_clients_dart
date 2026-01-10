// ignore_for_file: avoid_print
/// Authentication example demonstrating different auth providers.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  // --- API Key Authentication ---
  // Use for ChromaDB Cloud or API key protected instances
  print('=== API Key Authentication ===\n');

  final apiKeyClient = ChromaClient.withApiKey(
    'your-api-key-here',
    baseUrl: 'https://api.trychroma.com',
    tenant: 'your-tenant',
    database: 'your-database',
  );

  // Or configure manually with ChromaConfig
  final configuredClient = ChromaClient(
    config: const ChromaConfig(
      baseUrl: 'https://api.trychroma.com',
      authProvider: ApiKeyProvider('your-api-key-here'),
      tenant: 'your-tenant',
      database: 'your-database',
    ),
  );

  // --- Bearer Token Authentication ---
  // Use for OAuth/JWT based authentication
  print('=== Bearer Token Authentication ===\n');

  final bearerClient = ChromaClient(
    config: const ChromaConfig(
      baseUrl: 'https://api.trychroma.com',
      authProvider: BearerTokenProvider('your-jwt-token'),
    ),
  );

  // --- Custom Authentication ---
  // Implement your own auth provider for custom auth schemes
  print('=== Custom Authentication ===\n');

  // Example: Custom provider that fetches tokens dynamically
  final customClient = ChromaClient(
    config: ChromaConfig(
      baseUrl: 'https://api.trychroma.com',
      authProvider: DynamicTokenProvider(),
    ),
  );

  // --- User Identity ---
  // Get information about the authenticated user
  print('=== User Identity ===\n');

  final client = ChromaClient();

  try {
    final identity = await client.auth.identity();
    print('User ID: ${identity.userId}');
    print('Tenant: ${identity.tenant}');
    print('Databases: ${identity.databases}');
  } on AuthenticationException catch (e) {
    print('Authentication required: ${e.message}');
  } on ChromaException catch (e) {
    print('Error: ${e.message}');
  } finally {
    client.close();
  }

  // Clean up other clients
  apiKeyClient.close();
  configuredClient.close();
  bearerClient.close();
  customClient.close();
}

// --- Custom AuthProvider Implementation ---
// Implement AuthProvider for custom authentication schemes

/// Example custom provider that fetches tokens dynamically.
class DynamicTokenProvider implements AuthProvider {
  @override
  Future<AuthCredentials> getCredentials() async {
    // In a real app, this would fetch from your auth system
    // e.g., refresh an OAuth token, get from secure storage, etc.
    final token = await _fetchTokenFromAuthSystem();
    return BearerTokenCredentials(token: token);
  }

  Future<String> _fetchTokenFromAuthSystem() async {
    // Simulate async token fetch
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 'dynamic-jwt-token';
  }
}
