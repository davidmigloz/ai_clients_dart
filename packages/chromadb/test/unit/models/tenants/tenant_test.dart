import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('Tenant', () {
    test('fromJson creates tenant correctly', () {
      final json = {'name': 'my-tenant'};

      final tenant = Tenant.fromJson(json);

      expect(tenant.name, 'my-tenant');
    });

    test('toJson converts tenant correctly', () {
      const tenant = Tenant(name: 'test-tenant');

      final json = tenant.toJson();

      expect(json['name'], 'test-tenant');
    });

    test('copyWith preserves values when not specified', () {
      const original = Tenant(name: 'original-tenant');

      final copied = original.copyWith();

      expect(copied.name, 'original-tenant');
    });

    test('copyWith updates specified values', () {
      const original = Tenant(name: 'original-tenant');

      final copied = original.copyWith(name: 'new-tenant');

      expect(copied.name, 'new-tenant');
    });

    test('equality works correctly', () {
      const tenant1 = Tenant(name: 'tenant');
      const tenant2 = Tenant(name: 'tenant');
      const tenant3 = Tenant(name: 'other');

      expect(tenant1, equals(tenant2));
      expect(tenant1, isNot(equals(tenant3)));
    });

    test('hashCode is consistent with equality', () {
      const tenant1 = Tenant(name: 'tenant');
      const tenant2 = Tenant(name: 'tenant');

      expect(tenant1.hashCode, equals(tenant2.hashCode));
    });

    test('toString returns readable representation', () {
      const tenant = Tenant(name: 'my-tenant');

      expect(tenant.toString(), contains('Tenant'));
      expect(tenant.toString(), contains('my-tenant'));
    });
  });

  group('CreateTenantRequest', () {
    test('toJson converts request correctly', () {
      const request = CreateTenantRequest(name: 'new-tenant');

      final json = request.toJson();

      expect(json['name'], 'new-tenant');
    });
  });

  group('UpdateTenantRequest', () {
    test('toJson converts request with newName', () {
      const request = UpdateTenantRequest(newName: 'renamed-tenant');

      final json = request.toJson();

      expect(json['new_name'], 'renamed-tenant');
    });

    test('toJson excludes null values', () {
      const request = UpdateTenantRequest();

      final json = request.toJson();

      expect(json.containsKey('new_name'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = UpdateTenantRequest(newName: 'renamed');

      final copy = original.copyWith();

      expect(copy.newName, 'renamed');
    });

    test('copyWith can set fields to null', () {
      const original = UpdateTenantRequest(newName: 'renamed');

      final copy = original.copyWith(newName: null);

      expect(copy.newName, isNull);
    });

    test('equality works correctly', () {
      const request1 = UpdateTenantRequest(newName: 'new');
      const request2 = UpdateTenantRequest(newName: 'new');
      const request3 = UpdateTenantRequest(newName: 'other');

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });

    test('hashCode is consistent with equality', () {
      const request1 = UpdateTenantRequest(newName: 'new');
      const request2 = UpdateTenantRequest(newName: 'new');

      expect(request1.hashCode, equals(request2.hashCode));
    });

    test('toString returns readable representation', () {
      const request = UpdateTenantRequest(newName: 'renamed-tenant');

      expect(request.toString(), contains('UpdateTenantRequest'));
      expect(request.toString(), contains('renamed-tenant'));
    });
  });
}
