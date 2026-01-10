// ignore_for_file: avoid_print, unused_local_variable
/// Records management examples (add, get, update, delete).
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // Create a collection for this example
    final collection = await client.getOrCreateCollection(
      name: 'records-example',
    );

    // Add records with embeddings
    print('Adding records...');
    await collection.add(
      ids: ['id1', 'id2', 'id3'],
      embeddings: [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0],
      ],
      documents: ['First document', 'Second document', 'Third document'],
      metadatas: [
        {'category': 'A', 'priority': 1},
        {'category': 'B', 'priority': 2},
        {'category': 'A', 'priority': 3},
      ],
    );
    print('Added 3 records');

    // Get all records
    print('\nGetting all records...');
    final all = await collection.get();
    print('Total: ${all.ids.length} records');
    for (var i = 0; i < all.ids.length; i++) {
      print('  - ${all.ids[i]}: ${all.documents?[i]}');
    }

    // Get specific records by ID
    print('\nGetting specific records...');
    final specific = await collection.get(ids: ['id1', 'id3']);
    print('Found: ${specific.ids}');

    // Update records
    print('\nUpdating record...');
    await collection.update(
      ids: ['id1'],
      documents: ['Updated first document'],
      metadatas: [
        {'category': 'A', 'priority': 10, 'updated': true},
      ],
    );
    print('Record updated');

    // Verify update
    final updated = await collection.get(ids: ['id1']);
    print('Updated document: ${updated.documents?.first}');
    print('Updated metadata: ${updated.metadatas?.first}');

    // Upsert (insert or update)
    print('\nUpserting records...');
    await collection.upsert(
      ids: ['id2', 'id4'], // id2 exists, id4 is new
      embeddings: [
        [4.1, 5.1, 6.1],
        [10.0, 11.0, 12.0],
      ],
      documents: ['Updated second document', 'Fourth document (new)'],
    );
    print('Upserted 2 records');

    // Count records
    final count = await collection.count();
    print('\nTotal records: $count');

    // Peek at first N records
    print('\nPeeking at records...');
    final peek = await collection.peek(limit: 2);
    print('First 2 records: ${peek.ids}');

    // Delete by ID
    print('\nDeleting record by ID...');
    await collection.delete(ids: ['id4']);
    print('Deleted id4');

    // Delete by filter
    print('\nDeleting by filter...');
    await collection.delete(
      where: {
        'category': {r'$eq': 'B'},
      },
    );
    print('Deleted records with category B');

    // Final count
    final finalCount = await collection.count();
    print('\nFinal count: $finalCount');

    // Clean up
    await client.deleteCollection(name: 'records-example');
  } finally {
    client.close();
  }
}
