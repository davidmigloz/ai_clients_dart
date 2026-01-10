@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Functions API.
///
/// These tests require a running ChromaDB server with Functions support.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;
  late Collection testCollection;
  late String testCollectionName;

  setUpAll(() async {
    client = ChromaClient.local();
    // Create a test collection
    testCollectionName =
        'functions_test_${DateTime.now().millisecondsSinceEpoch}';
    testCollection = await client.collections.create(name: testCollectionName);
  });

  tearDownAll(() async {
    // Cleanup: delete test collection by name
    await client.collections.deleteByName(name: testCollectionName);
    client.close();
  });

  group('FunctionsResource', () {
    test('attach function works', () async {
      final functions = client.functions(testCollection.id);

      final response = await functions.attach(
        name: 'test-processor',
        functionId: 'embed_processor',
        outputCollection: 'test-output',
      );

      expect(response.attachedFunction, isNotNull);
      expect(response.attachedFunction.name, 'test-processor');
      expect(response.created, isTrue);
    });

    test('get attached function works', () async {
      final functions = client.functions(testCollection.id);

      final response = await functions.getFunction(name: 'test-processor');

      expect(response.attachedFunction, isNotNull);
      expect(response.attachedFunction.name, 'test-processor');
      expect(response.attachedFunction.functionName, 'embed_processor');
    });

    test('detach function works', () async {
      final functions = client.functions(testCollection.id);

      final response = await functions.detach(
        name: 'test-processor',
        deleteOutput: true,
      );

      expect(response.success, isTrue);
    });
  });

  group('ChromaCollection functions wrapper', () {
    test('attachFunction via wrapper works', () async {
      final collection = await client.getCollection(name: testCollection.name);

      final response = await collection.attachFunction(
        name: 'wrapper-test',
        functionId: 'summarizer',
        outputCollection: 'summaries',
      );

      expect(response.created, isTrue);

      // Cleanup
      await collection.detachFunction(name: 'wrapper-test');
    });
  });
}
