@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Collections API.
///
/// These tests require a running ChromaDB server.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;

  setUpAll(() {
    client = ChromaClient.local();
  });

  tearDownAll(() {
    client.close();
  });

  group('CollectionsResource', () {
    test('list returns collections', () async {
      final collections = await client.collections.list();

      expect(collections, isNotNull);
      expect(collections, isA<List<Collection>>());
    });

    test('count returns collection count', () async {
      final count = await client.collections.count();

      expect(count, isNotNull);
      expect(count, greaterThanOrEqualTo(0));
    });

    test('create and delete collection', () async {
      final collectionName = 'test_${DateTime.now().millisecondsSinceEpoch}';

      // Create
      final collection = await client.collections.create(
        name: collectionName,
        metadata: {'test': true},
      );

      expect(collection.name, equals(collectionName));
      expect(collection.id, isNotEmpty);
      expect(collection.metadata?['test'], equals(true));

      // Get by name
      final fetched = await client.collections.getByName(name: collectionName);
      expect(fetched.name, equals(collectionName));

      // Delete by name
      await client.collections.deleteByName(name: collectionName);

      // Verify it's gone
      expect(
        () => client.collections.getByName(name: collectionName),
        throwsA(isA<ChromaException>()),
      );
    });

    test('getOrCreate returns existing collection', () async {
      final collectionName =
          'test_getorcreate_${DateTime.now().millisecondsSinceEpoch}';

      // Create first
      final created = await client.collections.create(name: collectionName);

      // Get or create should return existing
      final fetched = await client.collections.create(
        name: collectionName,
        getOrCreate: true,
      );

      expect(fetched.id, equals(created.id));

      // Cleanup
      await client.collections.deleteByName(name: collectionName);
    });

    test('update collection metadata', () async {
      final collectionName =
          'test_update_${DateTime.now().millisecondsSinceEpoch}';

      await client.collections.create(
        name: collectionName,
        metadata: {'version': 1},
      );

      // Update
      final updated = await client.collections.update(
        name: collectionName,
        newMetadata: {'version': 2},
      );

      expect(updated.metadata?['version'], equals(2));

      // Cleanup
      await client.collections.deleteByName(name: collectionName);
    });

    test('list with pagination', () async {
      // Create a few collections
      final names = <String>[];
      for (var i = 0; i < 3; i++) {
        final name = 'test_page_${DateTime.now().millisecondsSinceEpoch}_$i';
        names.add(name);
        await client.collections.create(name: name);
      }

      try {
        // List with limit
        final page1 = await client.collections.list(limit: 2);
        expect(page1.length, lessThanOrEqualTo(2));

        // List with offset
        final page2 = await client.collections.list(limit: 2, offset: 2);
        expect(page2, isNotNull);
      } finally {
        // Cleanup by name
        for (final name in names) {
          try {
            await client.collections.deleteByName(name: name);
          } catch (_) {
            // Ignore if already deleted
          }
        }
      }
    });
  });

  group('ChromaClient convenience methods', () {
    test('getOrCreateCollection creates wrapper', () async {
      final collectionName =
          'test_wrapper_${DateTime.now().millisecondsSinceEpoch}';

      final collection = await client.getOrCreateCollection(
        name: collectionName,
      );

      expect(collection.name, equals(collectionName));
      expect(collection.id, isNotEmpty);

      // Cleanup
      await client.deleteCollection(name: collectionName);
    });

    test('listCollections returns all collections', () async {
      final collections = await client.listCollections();

      expect(collections, isNotNull);
      expect(collections, isA<List<Collection>>());
    });

    test('countCollections returns count', () async {
      final count = await client.countCollections();

      expect(count, greaterThanOrEqualTo(0));
    });
  });
}
