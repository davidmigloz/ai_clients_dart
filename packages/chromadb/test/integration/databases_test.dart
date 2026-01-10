@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Databases API.
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

  group('DatabasesResource', () {
    test('list returns databases for default tenant', () async {
      final databases = await client.databases.list();

      expect(databases, isNotNull);
      // Default database should exist
      expect(databases.any((db) => db.name == 'default_database'), isTrue);
    });

    test('getByName returns default database', () async {
      final database = await client.databases.getByName(
        name: 'default_database',
      );

      expect(database.name, equals('default_database'));
    });

    test('create and delete database', () async {
      final dbName = 'test_db_${DateTime.now().millisecondsSinceEpoch}';

      // Create
      final database = await client.databases.create(name: dbName);
      expect(database.name, equals(dbName));

      // Verify it exists
      final listed = await client.databases.list();
      expect(listed.any((db) => db.name == dbName), isTrue);

      // Delete
      await client.databases.deleteByName(name: dbName);

      // Verify it's gone
      final afterDelete = await client.databases.list();
      expect(afterDelete.any((db) => db.name == dbName), isFalse);
    });

    test('create database for specific tenant', () async {
      final dbName = 'test_db_tenant_${DateTime.now().millisecondsSinceEpoch}';

      final database = await client.databases.create(
        name: dbName,
        tenant: 'default_tenant',
      );

      expect(database.name, equals(dbName));
      expect(database.tenant, equals('default_tenant'));

      // Cleanup
      await client.databases.deleteByName(
        name: dbName,
        tenant: 'default_tenant',
      );
    });
  });
}
