// ignore_for_file: avoid_print
/// Database management example.
///
/// Demonstrates how to create, list, get, and delete databases
/// within tenants in a multi-tenant ChromaDB deployment.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient(
    config: const ChromaConfig(
      tenant: 'default_tenant',
      database: 'default_database',
    ),
  );

  try {
    print('=== Database Management ===\n');

    // --- List Databases ---
    print('Listing databases in default_tenant...');
    final databases = await client.databases.list();
    print('Found ${databases.length} database(s):');
    for (final db in databases) {
      print('  - ${db.name} (id: ${db.id})');
    }

    // --- Create a Database ---
    print('\nCreating database...');
    try {
      final newDb = await client.databases.create(
        name: 'my-database',
        tenant: 'default_tenant',
      );
      print('Created database: ${newDb.name} (id: ${newDb.id})');
    } on ConflictException catch (e) {
      print('Database already exists: ${e.message}');
    }

    // --- Get Database by Name ---
    print('\nGetting database...');
    try {
      final db = await client.databases.getByName(
        name: 'my-database',
        tenant: 'default_tenant',
      );
      print('Database: ${db.name}');
      print('  ID: ${db.id}');
      print('  Tenant: ${db.tenant}');
    } on NotFoundException catch (e) {
      print('Database not found: ${e.message}');
    }

    // --- Working with Collections in Database ---
    print('\n=== Collections in Database ===\n');

    // Create a collection in the specific database
    final collection = await client.getOrCreateCollection(
      name: 'db-collection',
      tenant: 'default_tenant',
      database: 'my-database',
    );
    print('Created collection: ${collection.name} in my-database');

    // List collections in the database
    final collections = await client.listCollections(
      tenant: 'default_tenant',
      database: 'my-database',
    );
    print(
      'Collections in my-database: ${collections.map((c) => c.name).join(', ')}',
    );

    // Clean up collection
    await client.deleteCollection(
      name: 'db-collection',
      tenant: 'default_tenant',
      database: 'my-database',
    );
    print('Deleted collection');

    // --- Delete Database ---
    print('\nDeleting database...');
    try {
      await client.databases.deleteByName(
        name: 'my-database',
        tenant: 'default_tenant',
      );
      print('Deleted database: my-database');
    } on NotFoundException catch (e) {
      print('Database not found: ${e.message}');
    } on ChromaException catch (e) {
      print('Cannot delete: ${e.message}');
    }

    print('\nDatabase management complete!');
  } on ChromaException catch (e) {
    print('Error: ${e.message}');
  } finally {
    client.close();
  }
}
