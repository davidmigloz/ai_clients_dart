// ignore_for_file: avoid_print, unused_local_variable
/// Collection management examples.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // Create a new collection
    print('Creating collection...');
    final collection = await client.createCollection(
      name: 'my-collection',
      metadata: {'description': 'A test collection', 'created_by': 'example'},
    );
    print('Created: ${collection.name} (${collection.id})');

    // Get an existing collection
    print('\nGetting collection...');
    final fetched = await client.getCollection(name: 'my-collection');
    print('Fetched: ${fetched.name}');
    print('Metadata: ${fetched.metadata.metadata}');

    // Get a collection by ID
    print('\nGetting collection by ID...');
    final fetchedById = await client.getCollectionById(
      collectionId: collection.id,
    );
    print('Fetched by ID: ${fetchedById.name}');

    // Get or create (idempotent operation)
    print('\nGet or create collection...');
    final existing = await client.getOrCreateCollection(
      name: 'my-collection',
      metadata: {'updated': true}, // Metadata only used if creating
    );
    print('Got existing: ${existing.name}');

    // List all collections
    print('\nListing collections...');
    final collections = await client.listCollections();
    for (final c in collections) {
      print('  - ${c.name}: ${c.id}');
    }

    // Count collections
    final count = await client.countCollections();
    print('\nTotal collections: $count');

    // Update collection via low-level API
    print('\nUpdating collection...');
    await client.collections.update(
      name: collection.name,
      newName: 'renamed-collection',
      newMetadata: {'description': 'Updated description'},
    );
    print('Collection renamed');

    // Delete collection
    print('\nDeleting collection...');
    await client.deleteCollection(name: 'renamed-collection');
    print('Collection deleted');
  } finally {
    client.close();
  }
}
