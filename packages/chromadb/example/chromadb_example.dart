// ignore_for_file: avoid_print, unused_local_variable
/// Basic ChromaDB client usage example.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  // Create a client for local ChromaDB instance
  final client = ChromaClient();

  try {
    // Check server health
    final heartbeat = await client.health.heartbeat();
    print('Server time: ${heartbeat.nanosecondHeartbeat}');

    // Get server version
    final version = await client.health.version();
    print('Server version: ${version.version}');

    // Create or get a collection
    final collection = await client.getOrCreateCollection(
      name: 'example-collection',
      metadata: {'description': 'My example collection'},
    );
    print('Collection: ${collection.name} (${collection.id})');

    // Add documents with embeddings
    await collection.add(
      ids: ['doc1', 'doc2', 'doc3'],
      embeddings: [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0],
      ],
      documents: [
        'The quick brown fox',
        'jumps over the lazy dog',
        'Hello world from ChromaDB',
      ],
      metadatas: [
        {'source': 'example', 'page': 1},
        {'source': 'example', 'page': 2},
        {'source': 'example', 'page': 3},
      ],
    );
    print('Added 3 documents');

    // Query by embedding similarity
    final results = await collection.query(
      queryEmbeddings: [
        [1.0, 2.0, 3.0],
      ],
      nResults: 2,
    );
    print('Query results:');
    for (var i = 0; i < results.ids.first.length; i++) {
      print('  - ${results.ids.first[i]}: ${results.documents?.first[i]}');
    }

    // Count records
    final count = await collection.count();
    print('Total records: $count');

    // Clean up - delete the collection
    await client.deleteCollection(name: 'example-collection');
    print('Collection deleted');
  } finally {
    client.close();
  }
}
