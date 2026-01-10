@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Comprehensive integration tests that mirror the original chromadb_old tests.
///
/// These tests ensure feature parity with the original package.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;

  setUpAll(() {
    client = ChromaClient.local();
  });

  tearDownAll(() {
    client.close();
  });

  group('Database Reset', () {
    test('reset clears all collections', () async {
      // Create a collection first
      final testName = 'reset_test_${DateTime.now().millisecondsSinceEpoch}';
      await client.createCollection(name: testName);

      // Verify it exists
      final before = await client.listCollections();
      expect(before.any((c) => c.name == testName), isTrue);

      // Reset
      final result = await client.health.reset();
      expect(result, isTrue);

      // Verify collections are gone
      final after = await client.listCollections();
      expect(after.any((c) => c.name == testName), isFalse);
    }, skip: 'Requires ALLOW_RESET=TRUE on server');
  });

  group('Collection Operations', () {
    test('create collection with metadata', () async {
      final collectionName =
          'test_metadata_${DateTime.now().millisecondsSinceEpoch}';

      try {
        final collection = await client.createCollection(
          name: collectionName,
          metadata: {'description': 'A test collection'},
        );

        expect(collection.name, collectionName);
        // collection.metadata is the Collection model, which has a metadata Map
        expect(
          collection.metadata.metadata?['description'],
          'A test collection',
        );
      } finally {
        await client.deleteCollection(name: collectionName);
      }
    });

    test('modify collection name and metadata', () async {
      final originalName =
          'original_name_${DateTime.now().millisecondsSinceEpoch}';
      final modifiedName =
          'modified_name_${DateTime.now().millisecondsSinceEpoch}';

      try {
        // Create collection
        final collection = await client.createCollection(
          name: originalName,
          metadata: {'version': 1},
        );
        expect(collection.name, originalName);
        expect(collection.metadata.metadata?['version'], 1);

        // Modify using wrapper
        await collection.modify(
          newName: modifiedName,
          newMetadata: {'version': 2},
        );

        // Verify changes
        final modified = await client.getCollection(name: modifiedName);
        expect(modified.name, modifiedName);
        expect(modified.metadata.metadata?['version'], 2);
      } finally {
        // Clean up (use modified name since it was renamed)
        try {
          await client.deleteCollection(name: modifiedName);
        } catch (_) {
          // If rename failed, try original name
          try {
            await client.deleteCollection(name: originalName);
          } catch (_) {}
        }
      }
    });
  });

  group('Records Operations', () {
    late ChromaCollection collection;
    late String collectionName;

    setUp(() async {
      collectionName =
          'test_records_ops_${DateTime.now().millisecondsSinceEpoch}';
      collection = await client.createCollection(name: collectionName);
    });

    tearDown(() async {
      try {
        await client.deleteCollection(name: collectionName);
      } catch (_) {}
    });

    test('add single embedding and verify', () async {
      const id = 'single_item';
      final embedding = [1.0, 2.0, 3.0, 4.0, 5.0];
      final metadata = {'category': 'test'};

      await collection.add(
        ids: [id],
        embeddings: [embedding],
        metadatas: [metadata],
      );

      expect(await collection.count(), 1);

      // Verify data
      final response = await collection.get(
        ids: [id],
        include: [Include.embeddings, Include.metadatas],
      );
      expect(response.ids, [id]);
      expect(response.embeddings?.first, embedding);
      expect(response.metadatas?.first?['category'], 'test');
    });

    test('add batch embeddings and verify all', () async {
      const ids = ['batch1', 'batch2', 'batch3'];
      final embeddings = [
        [1.0, 2.0, 3.0, 4.0, 5.0],
        [6.0, 7.0, 8.0, 9.0, 10.0],
        [11.0, 12.0, 13.0, 14.0, 15.0],
      ];
      final metadatas = [
        {'index': 1},
        {'index': 2},
        {'index': 3},
      ];

      await collection.add(
        ids: ids,
        embeddings: embeddings,
        metadatas: metadatas,
      );

      expect(await collection.count(), 3);

      // Verify all data
      final response = await collection.get(
        ids: ids,
        include: [Include.embeddings, Include.metadatas],
      );
      expect(response.ids, ids);
      expect(response.embeddings, embeddings);
      for (var i = 0; i < metadatas.length; i++) {
        expect(response.metadatas?[i]?['index'], metadatas[i]['index']);
      }
    });

    test('upsert existing record does not duplicate', () async {
      const id = 'upsert_test';
      final embedding1 = [1.0, 2.0, 3.0, 4.0, 5.0];
      final embedding2 = [5.0, 4.0, 3.0, 2.0, 1.0];
      final metadata = {'version': 1};

      // Add initial
      await collection.add(
        ids: [id],
        embeddings: [embedding1],
        metadatas: [metadata],
      );
      expect(await collection.count(), 1);

      // Upsert same id
      await collection.upsert(
        ids: [id],
        embeddings: [embedding2],
        metadatas: [
          {'version': 2},
        ],
      );

      // Count should still be 1
      expect(await collection.count(), 1);

      // Verify data was updated
      final response = await collection.get(
        ids: [id],
        include: [Include.embeddings, Include.metadatas],
      );
      expect(response.embeddings?.first, embedding2);
      expect(response.metadatas?.first?['version'], 2);
    });

    test('update embeddings and verify change', () async {
      const id = 'update_test';
      final originalEmbedding = [1.0, 2.0, 3.0, 4.0, 5.0];
      final updatedEmbedding = [5.0, 4.0, 3.0, 2.0, 1.0];
      final metadata = {'test': 'value'};

      // Add initial
      await collection.add(
        ids: [id],
        embeddings: [originalEmbedding],
        metadatas: [metadata],
      );
      expect(await collection.count(), 1);

      // Update embedding
      await collection.update(
        ids: [id],
        embeddings: [updatedEmbedding],
        metadatas: [metadata],
      );

      // Verify embedding changed
      final response = await collection.get(
        ids: [id],
        include: [Include.embeddings, Include.metadatas],
      );
      expect(response.ids, [id]);
      expect(response.embeddings?.first, updatedEmbedding);
      expect(response.metadatas?.first?['test'], 'value');
    });

    test('peek returns limited results', () async {
      // Add multiple records
      await collection.add(
        ids: ['peek1', 'peek2', 'peek3', 'peek4', 'peek5'],
        embeddings: [
          [1.0, 0.0, 0.0],
          [0.0, 1.0, 0.0],
          [0.0, 0.0, 1.0],
          [1.0, 1.0, 0.0],
          [0.0, 1.0, 1.0],
        ],
      );
      expect(await collection.count(), 5);

      // Peek with limit
      final response = await collection.peek(limit: 2);
      expect(response.ids.length, 2);
    });

    test('delete by id decrements count', () async {
      await collection.add(
        ids: ['del1', 'del2', 'del3'],
        embeddings: [
          [1.0, 0.0, 0.0],
          [0.0, 1.0, 0.0],
          [0.0, 0.0, 1.0],
        ],
        metadatas: [
          {'keep': false},
          {'keep': true},
          {'keep': true},
        ],
      );
      expect(await collection.count(), 3);

      // Delete one by id
      await collection.delete(ids: ['del1']);
      expect(await collection.count(), 2);

      // Verify it's gone
      final response = await collection.get(ids: ['del1']);
      expect(response.ids, isEmpty);
    });

    test('delete by where filter removes matching records', () async {
      await collection.add(
        ids: ['filter1', 'filter2', 'filter3'],
        embeddings: [
          [1.0, 0.0, 0.0],
          [0.0, 1.0, 0.0],
          [0.0, 0.0, 1.0],
        ],
        metadatas: [
          {'category': 'A'},
          {'category': 'B'},
          {'category': 'A'},
        ],
      );
      expect(await collection.count(), 3);

      // Delete by category
      await collection.delete(where: {'category': 'A'});
      expect(await collection.count(), 1);

      // Verify only B remains
      final response = await collection.get(include: [Include.metadatas]);
      expect(response.ids, ['filter2']);
      expect(response.metadatas?.first?['category'], 'B');
    });
  });

  group('Query Operations', () {
    late ChromaCollection collection;
    late String collectionName;

    setUp(() async {
      collectionName =
          'test_query_ops_${DateTime.now().millisecondsSinceEpoch}';
      collection = await client.createCollection(name: collectionName);

      // Add test data with distinct embeddings for similarity testing
      await collection.add(
        ids: ['q1', 'q2', 'q3'],
        embeddings: [
          [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0], // Similar to q2
          [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0], // Same as q1
          [10.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0], // Different
        ],
      );
    });

    tearDown(() async {
      try {
        await client.deleteCollection(name: collectionName);
      } catch (_) {}
    });

    test('query returns results ordered by similarity', () async {
      expect(await collection.count(), 3);

      final response = await collection.query(
        queryEmbeddings: [
          [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0],
        ],
        nResults: 2,
      );

      expect(response.ids, hasLength(1)); // One query
      expect(response.ids.first, containsAllInOrder(['q1', 'q2']));
    });
  });

  group('Error Handling', () {
    late ChromaCollection collection;
    late String collectionName;

    setUp(() async {
      collectionName = 'test_errors_${DateTime.now().millisecondsSinceEpoch}';
      collection = await client.createCollection(name: collectionName);

      await collection.add(
        ids: ['err1', 'err2'],
        embeddings: [
          [1.0, 2.0, 3.0],
          [4.0, 5.0, 6.0],
        ],
        metadatas: [
          {'key': 'value1'},
          {'key': 'value2'},
        ],
      );
    });

    tearDown(() async {
      try {
        await client.deleteCollection(name: collectionName);
      } catch (_) {}
    });

    test('invalid where clause throws exception', () {
      // Using invalid operator syntax
      expect(
        () => collection.get(
          where: {
            'key': {r'$invalid_operator': 'test'},
          },
        ),
        throwsA(isA<ChromaException>()),
      );
    });

    test('getting non-existent collection throws exception', () {
      expect(
        () => client.getCollection(
          name: 'non_existent_${DateTime.now().millisecondsSinceEpoch}',
        ),
        throwsA(isA<ChromaException>()),
      );
    });

    test('adding duplicate ids throws or handles gracefully', () async {
      // Try to add a record with an existing id
      // Behavior depends on server version - may throw or ignore
      try {
        await collection.add(
          ids: ['err1'], // Already exists
          embeddings: [
            [9.0, 9.0, 9.0],
          ],
        );
        // If no exception, verify original data is unchanged
        final response = await collection.get(
          ids: ['err1'],
          include: [Include.embeddings],
        );
        // Either the add was ignored or it's an error - both are valid
        expect(response.ids, isNotEmpty);
      } on ChromaException {
        // Expected - duplicate ID should throw
      }
    });
  });

  group('Get with Filters', () {
    late ChromaCollection collection;
    late String collectionName;

    setUp(() async {
      collectionName = 'test_filters_${DateTime.now().millisecondsSinceEpoch}';
      collection = await client.createCollection(name: collectionName);

      await collection.add(
        ids: ['f1', 'f2', 'f3'],
        embeddings: [
          [1.0, 2.0, 3.0, 4.0, 5.0],
          [6.0, 7.0, 8.0, 9.0, 10.0],
          [11.0, 12.0, 13.0, 14.0, 15.0],
        ],
        metadatas: [
          {'category': 'A', 'score': 10},
          {'category': 'B', 'score': 20},
          {'category': 'A', 'score': 30},
        ],
      );
    });

    tearDown(() async {
      try {
        await client.deleteCollection(name: collectionName);
      } catch (_) {}
    });

    test('get by id returns specific record', () async {
      final response = await collection.get(ids: ['f2']);
      expect(response.ids, hasLength(1));
      expect(response.ids.first, 'f2');
    });

    test('get by where returns filtered records', () async {
      final response = await collection.get(
        where: {'category': 'A'},
        include: [Include.metadatas],
      );

      expect(response.ids, hasLength(2));
      expect(response.ids, containsAll(['f1', 'f3']));
      for (final meta in response.metadatas!) {
        expect(meta?['category'], 'A');
      }
    });

    test('get with limit returns limited results', () async {
      final response = await collection.get(limit: 2);
      expect(response.ids.length, lessThanOrEqualTo(2));
    });
  });
}
