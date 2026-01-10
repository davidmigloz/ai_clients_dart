@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Auth API.
///
/// These tests require a running ChromaDB server with authentication enabled.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;

  setUpAll(() {
    client = ChromaClient.local();
  });

  tearDownAll(() {
    client.close();
  });

  group('AuthResource', () {
    test(
      'identity returns user info when authenticated',
      () async {
        final response = await client.auth.identity();

        expect(response, isNotNull);
        // The response may have null fields for unauthenticated servers
      },
      skip: 'Requires authentication to be enabled on the server',
    );
  });
}
