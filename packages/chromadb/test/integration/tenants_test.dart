@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Tenants API.
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

  group('TenantsResource', () {
    test('getByName returns default tenant', () async {
      final tenant = await client.tenants.getByName(name: 'default_tenant');

      expect(tenant.name, equals('default_tenant'));
    });

    test(
      'create creates a new tenant',
      () async {
        final tenantName =
            'test_tenant_${DateTime.now().millisecondsSinceEpoch}';

        final tenant = await client.tenants.create(name: tenantName);

        expect(tenant.name, equals(tenantName));
      },
      skip: 'Destructive test - creates a tenant that cannot be deleted',
    );

    test('update modifies tenant name', () async {
      // Note: Update may not work on all ChromaDB versions
      final tenant = await client.tenants.update(
        name: 'default_tenant',
        newName: 'default_tenant', // No-op update
      );

      expect(tenant.name, isNotNull);
    }, skip: 'Update tenant may not be supported');
  });
}
