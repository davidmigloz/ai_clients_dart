// ignore_for_file: avoid_print, unused_local_variable
/// Multi-tenant usage example.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  // Create a client with default tenant and database
  final client = ChromaClient(
    config: const ChromaConfig(
      tenant: 'default_tenant',
      database: 'default_database',
    ),
  );

  try {
    // Check server health
    final version = await client.health.version();
    print('ChromaDB version: ${version.version}\n');

    // --- Tenant Management ---
    print('=== Tenant Management ===\n');

    // Create a new tenant
    print('Creating tenant...');
    try {
      final tenant = await client.tenants.create(name: 'example-tenant');
      print('Created tenant: ${tenant.name}');
    } on ChromaException catch (e) {
      // Tenant may already exist
      print('Tenant exists or error: ${e.message}');
    }

    // Get tenant info
    print('\nGetting tenant...');
    final tenant = await client.tenants.getByName(name: 'default_tenant');
    print('Tenant: ${tenant.name}');

    // --- Database Management ---
    print('\n=== Database Management ===\n');

    // List databases in the default tenant
    print('Listing databases...');
    final databases = await client.databases.list();
    print('Databases in default_tenant:');
    for (final db in databases) {
      print('  - ${db.name} (${db.id})');
    }

    // Create a new database
    print('\nCreating database...');
    try {
      final database = await client.databases.create(
        name: 'example-database',
        tenant: 'default_tenant',
      );
      print('Created database: ${database.name}');
    } on ChromaException catch (e) {
      print('Database exists or error: ${e.message}');
    }

    // Get database info
    print('\nGetting database...');
    try {
      final db = await client.databases.getByName(
        name: 'default_database',
        tenant: 'default_tenant',
      );
      print('Database: ${db.name}');
    } on ChromaException catch (e) {
      print('Error: ${e.message}');
    }

    // --- Collections in Different Tenants/Databases ---
    print('\n=== Collections in Different Contexts ===\n');

    // Create a collection in the default context
    print('Creating collection in default context...');
    final defaultCollection = await client.getOrCreateCollection(
      name: 'default-collection',
    );
    print('Collection: ${defaultCollection.name} (${defaultCollection.id})');

    // Create a collection in a specific tenant/database
    print('\nCreating collection in specific context...');
    try {
      final specificCollection = await client.getOrCreateCollection(
        name: 'specific-collection',
        tenant: 'default_tenant',
        database: 'default_database',
      );
      print('Collection: ${specificCollection.name}');
    } on ChromaException catch (e) {
      print('Error: ${e.message}');
    }

    // List collections (will use default tenant/database)
    print('\nListing collections...');
    final collections = await client.listCollections();
    print('Collections:');
    for (final c in collections) {
      print('  - ${c.name}');
    }

    // --- User Identity (if authenticated) ---
    print('\n=== User Identity ===\n');
    try {
      final identity = await client.auth.identity();
      print('User ID: ${identity.userId}');
      print('Tenant: ${identity.tenant}');
      print('Databases: ${identity.databases}');
    } on ChromaException catch (e) {
      print('Auth not available: ${e.message}');
    }

    // --- Clean Up ---
    print('\n=== Cleanup ===\n');

    // Delete collections
    await client.deleteCollection(name: 'default-collection');
    print('Deleted default-collection');

    try {
      await client.deleteCollection(name: 'specific-collection');
      print('Deleted specific-collection');
    } on ChromaException catch (_) {
      // May not exist
    }

    // Delete database (if it exists)
    try {
      await client.databases.deleteByName(
        name: 'example-database',
        tenant: 'default_tenant',
      );
      print('Deleted example-database');
    } on ChromaException catch (_) {
      // May not exist
    }

    print('\nDone!');
  } finally {
    client.close();
  }
}
