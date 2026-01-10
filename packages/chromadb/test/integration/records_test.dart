@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Records API.
///
/// These tests require a running ChromaDB server.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;
  late String collectionId;
  late String collectionName;

  setUpAll(() async {
    client = ChromaClient.local();

    // Create a test collection
    collectionName = 'test_records_${DateTime.now().millisecondsSinceEpoch}';
    final collection = await client.collections.create(name: collectionName);
    collectionId = collection.id;
  });

  tearDownAll(() async {
    // Cleanup - use deleteByName since that's what ChromaDB server expects
    await client.deleteCollection(name: collectionName);
    client.close();
  });

  group('RecordsResource', () {
    test('add records with embeddings', () async {
      final records = client.records(collectionId);

      await records.add(
        ids: ['rec1', 'rec2'],
        embeddings: [
          [0.1, 0.2, 0.3],
          [0.4, 0.5, 0.6],
        ],
        documents: ['Document 1', 'Document 2'],
        metadatas: [
          {'type': 'test'},
          {'type': 'test'},
        ],
      );

      // Verify count
      final count = await records.count();
      expect(count, greaterThanOrEqualTo(2));
    });

    test('get records by ids', () async {
      final records = client.records(collectionId);

      final response = await records.getRecords(
        ids: ['rec1'],
        include: [Include.documents, Include.metadatas, Include.embeddings],
      );

      expect(response.ids, contains('rec1'));
      expect(response.documents, isNotNull);
      expect(response.metadatas, isNotNull);
      expect(response.embeddings, isNotNull);
    });

    test('get records with where filter', () async {
      final records = client.records(collectionId);

      final response = await records.getRecords(
        where: {
          r'$and': [
            {'type': 'test'},
          ],
        },
        include: [Include.documents],
      );

      expect(response.ids, isNotEmpty);
    });

    test('update record metadata', () async {
      final records = client.records(collectionId);

      await records.update(
        ids: ['rec1'],
        metadatas: [
          {'type': 'updated'},
        ],
      );

      final response = await records.getRecords(
        ids: ['rec1'],
        include: [Include.metadatas],
      );

      expect(response.metadatas?.first?['type'], equals('updated'));
    });

    test('upsert creates or updates records', () async {
      final records = client.records(collectionId);

      // Upsert existing
      await records.upsert(
        ids: ['rec1'],
        embeddings: [
          [0.7, 0.8, 0.9],
        ],
        documents: ['Updated document'],
      );

      // Upsert new
      await records.upsert(
        ids: ['rec3'],
        embeddings: [
          [1.0, 1.1, 1.2],
        ],
        documents: ['New document'],
      );

      final count = await records.count();
      expect(count, greaterThanOrEqualTo(3));
    });

    test('delete records by ids', () async {
      final records = client.records(collectionId);

      // Add a record to delete
      await records.add(
        ids: ['to_delete'],
        embeddings: [
          [0.0, 0.0, 0.0],
        ],
      );

      // Delete it
      await records.deleteRecords(ids: ['to_delete']);
      // Note: ChromaDB API v2 may not return deleted IDs

      // Verify it's gone
      final response = await records.getRecords(ids: ['to_delete']);
      expect(response.ids, isEmpty);
    });

    test('delete records with where filter', () async {
      final records = client.records(collectionId);

      // Add records with specific metadata
      await records.add(
        ids: ['delete_filter1', 'delete_filter2'],
        embeddings: [
          [0.0, 0.0, 0.0],
          [0.0, 0.0, 0.0],
        ],
        metadatas: [
          {'toDelete': true},
          {'toDelete': true},
        ],
      );

      // Delete by filter
      await records.deleteRecords(where: {'toDelete': true});
      // Note: ChromaDB API v2 may not return deleted IDs

      // Verify they're gone by checking the records don't exist
      final response = await records.getRecords(
        ids: ['delete_filter1', 'delete_filter2'],
      );
      expect(response.ids, isEmpty);
    });
  });
}
