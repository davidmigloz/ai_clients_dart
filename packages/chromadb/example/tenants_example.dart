// ignore_for_file: avoid_print
/// Tenant management example.
///
/// Demonstrates how to create, get, and update tenants
/// in a multi-tenant ChromaDB deployment.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    print('=== Tenant Management ===\n');

    // --- Create a Tenant ---
    print('Creating tenant...');
    try {
      final newTenant = await client.tenants.create(name: 'my-tenant');
      print('Created tenant: ${newTenant.name}');
    } on ConflictException catch (e) {
      print('Tenant already exists: ${e.message}');
    }

    // --- Get Tenant by Name ---
    print('\nGetting tenant...');
    try {
      final tenant = await client.tenants.getByName(name: 'my-tenant');
      print('Tenant name: ${tenant.name}');
    } on NotFoundException catch (e) {
      print('Tenant not found: ${e.message}');
    }

    // --- Update Tenant ---
    // Note: Update operations may be limited depending on ChromaDB version
    print('\nUpdating tenant...');
    try {
      final updated = await client.tenants.update(
        name: 'my-tenant',
        newName: 'renamed-tenant',
      );
      print('Updated tenant: ${updated.name}');
    } on ChromaException catch (e) {
      print('Update not supported or failed: ${e.message}');
    }

    // --- Get Default Tenant ---
    print('\nGetting default tenant...');
    final defaultTenant = await client.tenants.getByName(
      name: 'default_tenant',
    );
    print('Default tenant: ${defaultTenant.name}');

    // --- Working with Collections in Tenant ---
    print('\n=== Collections in Tenant ===\n');

    // Create a collection in a specific tenant
    final collection = await client.getOrCreateCollection(
      name: 'tenant-collection',
      tenant: 'default_tenant',
      database: 'default_database',
    );
    print('Created collection: ${collection.name}');

    // Clean up
    await client.deleteCollection(
      name: 'tenant-collection',
      tenant: 'default_tenant',
      database: 'default_database',
    );
    print('Deleted collection');

    print('\nTenant management complete!');
  } on ChromaException catch (e) {
    print('Error: ${e.message}');
  } finally {
    client.close();
  }
}
