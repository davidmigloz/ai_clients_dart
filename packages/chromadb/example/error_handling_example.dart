// ignore_for_file: avoid_print, unused_local_variable
/// Error handling patterns with ChromaDB exceptions.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // --- Handling specific exceptions ---
    print('=== Handling Specific Exceptions ===\n');

    // Not found exception
    print('Trying to get non-existent collection...');
    try {
      await client.getCollection(name: 'non-existent-collection');
    } on NotFoundException catch (e) {
      print('Not found: ${e.message}');
    }

    // Validation exception (duplicate IDs)
    print('\nTrying to add duplicate IDs...');
    final collection = await client.getOrCreateCollection(
      name: 'error-example',
    );
    try {
      await collection.add(
        ids: ['id1', 'id1'], // Duplicate!
        embeddings: [
          [1.0, 2.0, 3.0],
          [4.0, 5.0, 6.0],
        ],
      );
    } on ArgumentError catch (e) {
      print('Validation error: ${e.message}');
    }

    // Missing embedding function
    print('\nTrying to add documents without embedding function...');
    try {
      await collection.add(
        ids: ['id1'],
        documents: ['Hello world'], // No embeddings and no embedding function!
      );
    } on StateError catch (e) {
      print('State error: ${e.message}');
    }

    // --- Catching all ChromaDB exceptions ---
    print('\n=== Catching All ChromaDB Exceptions ===\n');

    try {
      // Some operation that might fail
      await client.databases.getByName(
        name: 'non-existent-db',
        tenant: 'default_tenant',
      );
    } on ApiException catch (e) {
      // ApiException includes response metadata
      print('API error: ${e.message}');
      print('Status code: ${e.response?.statusCode}');

      // You can check the specific type
      if (e is NotFoundException) {
        print('  -> Resource not found');
      } else if (e is AuthenticationException) {
        print('  -> Authentication failed');
      } else if (e is ServerException) {
        print('  -> Server error');
      }
    } on ChromaException catch (e) {
      // Base class catches all ChromaDB-specific exceptions
      print('ChromaDB error: ${e.message}');
    }

    // --- Exception hierarchy ---
    print('\n=== Exception Hierarchy ===\n');
    print('''
ChromaException (base sealed class)
├── ApiException (API errors with response metadata)
│   ├── AuthenticationException (401/403)
│   ├── NotFoundException (404)
│   ├── ConflictException (409)
│   ├── RateLimitException (429)
│   └── ServerException (5xx)
├── ValidationException (invalid input)
├── TimeoutException (request timeout)
└── AbortedException (request cancelled)
''');

    // --- Retry handling ---
    print('=== Retry Handling ===\n');
    print('The client automatically retries on:');
    print('  - Rate limits (429)');
    print('  - Server errors (5xx)');
    print('  - Network timeouts');
    print('\nConfigure retry behavior:');
    print('''
final client = ChromaClient(
  config: ChromaConfig(
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(milliseconds: 500),
      maxDelay: Duration(seconds: 30),
      jitter: 0.1,
    ),
  ),
);
''');

    // --- Best practices ---
    print('=== Best Practices ===\n');
    print('1. Always close the client when done');
    print('2. Use try/finally for cleanup');
    print('3. Handle specific exceptions when needed');
    print('4. Use ChromaException as a catch-all');
    print('5. Configure appropriate retry policies');
    print('6. Use timeouts for long operations');

    // Example of proper resource management
    print('\nExample: Proper resource management');
    print(r'''
Future<void> processDocuments() async {
  final client = ChromaClient();
  try {
    final collection = await client.getOrCreateCollection(
      name: 'my-docs',
    );
    // ... do work
  } on ChromaException catch (e) {
    // Handle ChromaDB-specific errors
    print('ChromaDB error: ${e.message}');
    rethrow;
  } finally {
    // Always clean up
    client.close();
  }
}
''');

    // Clean up
    await client.deleteCollection(name: 'error-example');
    print('Cleanup complete');
  } finally {
    client.close();
  }
}
