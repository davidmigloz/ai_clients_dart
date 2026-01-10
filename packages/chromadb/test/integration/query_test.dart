@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Query API.
///
/// These tests require a running ChromaDB server.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;
  late String collectionId;
  late String collectionName;

  setUpAll(() async {
    client = ChromaClient.local();

    // Create a test collection with sample data
    collectionName = 'test_query_${DateTime.now().millisecondsSinceEpoch}';
    final collection = await client.collections.create(name: collectionName);
    collectionId = collection.id;

    // Add sample documents
    final records = client.records(collectionId);
    await records.add(
      ids: ['doc1', 'doc2', 'doc3', 'doc4', 'doc5'],
      embeddings: [
        [1.0, 0.0, 0.0],
        [0.9, 0.1, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.9, 0.1],
        [0.0, 0.0, 1.0],
      ],
      documents: [
        'The quick brown fox',
        'A fast brown dog',
        'The lazy cat sleeps',
        'A tired cat naps',
        'The blue sky is clear',
      ],
      metadatas: [
        {'category': 'animals', 'animal': 'fox'},
        {'category': 'animals', 'animal': 'dog'},
        {'category': 'animals', 'animal': 'cat'},
        {'category': 'animals', 'animal': 'cat'},
        {'category': 'nature', 'topic': 'sky'},
      ],
    );
  });

  tearDownAll(() async {
    await client.deleteCollection(name: collectionName);
    client.close();
  });

  group('RecordsResource.query', () {
    test('query returns similar documents', () async {
      final records = client.records(collectionId);

      final response = await records.query(
        queryEmbeddings: [
          [1.0, 0.0, 0.0], // Similar to doc1
        ],
        nResults: 2,
        include: [Include.documents, Include.distances],
      );

      expect(response.ids, isNotEmpty);
      expect(response.ids.first.length, equals(2));
      // First result should be doc1 (exact match)
      expect(response.ids.first.first, equals('doc1'));
      expect(response.distances, isNotNull);
      expect(response.documents, isNotNull);
    });

    test('query with multiple query embeddings', () async {
      final records = client.records(collectionId);

      final response = await records.query(
        queryEmbeddings: [
          [1.0, 0.0, 0.0], // Similar to doc1
          [0.0, 1.0, 0.0], // Similar to doc3
        ],
        nResults: 1,
        include: [Include.documents],
      );

      expect(response.ids.length, equals(2)); // Two queries
      expect(response.ids[0].first, equals('doc1'));
      expect(response.ids[1].first, equals('doc3'));
    });

    test('query with where filter', () async {
      final records = client.records(collectionId);

      final response = await records.query(
        queryEmbeddings: [
          [1.0, 0.0, 0.0],
        ],
        nResults: 10,
        where: {'category': 'animals'},
        include: [Include.metadatas],
      );

      expect(response.ids.first, isNotEmpty);
      // All results should be animals
      for (final metadata in response.metadatas!.first) {
        expect(metadata?['category'], equals('animals'));
      }
    });

    test('query with whereDocument filter', () async {
      final records = client.records(collectionId);

      final response = await records.query(
        queryEmbeddings: [
          [0.5, 0.5, 0.0],
        ],
        nResults: 10,
        whereDocument: {r'$contains': 'cat'},
        include: [Include.documents],
      );

      expect(response.ids.first, isNotEmpty);
      // All results should contain "cat"
      for (final doc in response.documents!.first) {
        expect(doc?.toLowerCase(), contains('cat'));
      }
    });

    test('query returns embeddings when requested', () async {
      final records = client.records(collectionId);

      final response = await records.query(
        queryEmbeddings: [
          [1.0, 0.0, 0.0],
        ],
        nResults: 1,
        include: [Include.embeddings],
      );

      expect(response.embeddings, isNotNull);
      expect(response.embeddings!.first.first, isNotNull);
      expect(response.embeddings!.first.first.length, equals(3));
    });
  });

  group('ChromaCollection.query', () {
    test('query with text requires embedding function', () async {
      final collection = await client.getCollection(name: collectionName);

      // Without embedding function, queryTexts should throw
      expect(
        () => collection.query(queryTexts: ['test']),
        throwsA(isA<StateError>()),
      );
    });

    test('query with embeddings works without embedding function', () async {
      final collection = await client.getCollection(name: collectionName);

      final response = await collection.query(
        queryEmbeddings: [
          [1.0, 0.0, 0.0],
        ],
        nResults: 2,
      );

      expect(response.ids.first.first, equals('doc1'));
    });
  });
}
