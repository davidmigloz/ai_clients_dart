@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Search API.
///
/// These tests require a running ChromaDB server.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;
  late String collectionId;
  late String collectionName;

  setUpAll(() async {
    client = ChromaClient.local();

    // Create a test collection with some records
    collectionName = 'test_search_${DateTime.now().millisecondsSinceEpoch}';
    final collection = await client.collections.create(name: collectionName);
    collectionId = collection.id;

    // Add test records
    final records = client.records(collectionId);
    await records.add(
      ids: ['search1', 'search2', 'search3'],
      embeddings: [
        [0.1, 0.2, 0.3],
        [0.4, 0.5, 0.6],
        [0.7, 0.8, 0.9],
      ],
      documents: ['Document one', 'Document two', 'Document three'],
      metadatas: [
        {'category': 'a', 'score': 1},
        {'category': 'b', 'score': 2},
        {'category': 'a', 'score': 3},
      ],
    );
  });

  tearDownAll(() async {
    // Cleanup by name
    await client.collections.deleteByName(name: collectionName);
    client.close();
  });

  group('RecordsResource.search', () {
    test('search returns results', () async {
      final records = client.records(collectionId);

      final response = await records.search(
        searches: [const SearchPayload(limit: SearchLimit(limit: 10))],
      );

      expect(response.ids, isNotEmpty);
      expect(response.searchCount, 1);
    });

    test('search with filter by ids works', () async {
      final records = client.records(collectionId);

      final response = await records.search(
        searches: [
          const SearchPayload(
            filter: SearchFilter(queryIds: ['search1', 'search2']),
            limit: SearchLimit(limit: 10),
          ),
        ],
      );

      expect(response.ids, isNotEmpty);
      // Results should only include filtered IDs
      final allIds = response.ids.expand((ids) => ids).toList();
      expect(allIds, everyElement(isIn(['search1', 'search2'])));
    });

    test('search with where filter works', () async {
      final records = client.records(collectionId);

      final response = await records.search(
        searches: [
          const SearchPayload(
            filter: SearchFilter(whereClause: {'category': 'a'}),
            limit: SearchLimit(limit: 10),
          ),
        ],
      );

      expect(response.ids, isNotEmpty);
    });

    test('search with limit works', () async {
      final records = client.records(collectionId);

      final response = await records.search(
        searches: [const SearchPayload(limit: SearchLimit(limit: 2))],
      );

      expect(response.ids, isNotEmpty);
      expect(response.ids.first.length, lessThanOrEqualTo(2));
    });

    test('multiple searches in one request', () async {
      final records = client.records(collectionId);

      final response = await records.search(
        searches: [
          const SearchPayload(
            filter: SearchFilter(queryIds: ['search1']),
            limit: SearchLimit(limit: 5),
          ),
          const SearchPayload(
            filter: SearchFilter(queryIds: ['search2']),
            limit: SearchLimit(limit: 5),
          ),
        ],
      );

      expect(response.searchCount, 2);
    });
  });

  group('ChromaCollection.search', () {
    test('wrapper search method works', () async {
      final collection = await client.getOrCreateCollection(
        name: 'test_search_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Add some data
      await collection.add(
        ids: ['wrap1'],
        embeddings: [
          [1.0, 2.0, 3.0],
        ],
        documents: ['Wrapper test document'],
      );

      try {
        final response = await collection.search(
          searches: [const SearchPayload(limit: SearchLimit(limit: 10))],
        );

        expect(response.ids, isNotEmpty);
      } finally {
        await client.deleteCollection(name: collection.name);
      }
    });
  });
}
