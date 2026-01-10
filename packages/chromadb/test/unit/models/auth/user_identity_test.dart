import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('UserIdentity', () {
    test('fromJson creates identity with all fields', () {
      final json = {
        'user_id': 'user-123',
        'tenant': 'my-tenant',
        'databases': ['db1', 'db2'],
      };

      final identity = UserIdentity.fromJson(json);

      expect(identity.userId, 'user-123');
      expect(identity.tenant, 'my-tenant');
      expect(identity.databases, ['db1', 'db2']);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};

      final identity = UserIdentity.fromJson(json);

      expect(identity.userId, isNull);
      expect(identity.tenant, isNull);
      expect(identity.databases, isNull);
    });

    test('fromJson handles partial fields', () {
      final json = {'user_id': 'user-456'};

      final identity = UserIdentity.fromJson(json);

      expect(identity.userId, 'user-456');
      expect(identity.tenant, isNull);
      expect(identity.databases, isNull);
    });

    test('toJson converts identity correctly', () {
      const identity = UserIdentity(
        userId: 'user-789',
        tenant: 'test-tenant',
        databases: ['testdb'],
      );

      final json = identity.toJson();

      expect(json['user_id'], 'user-789');
      expect(json['tenant'], 'test-tenant');
      expect(json['databases'], ['testdb']);
    });

    test('toJson excludes null values', () {
      const identity = UserIdentity();

      final json = identity.toJson();

      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('tenant'), isFalse);
      expect(json.containsKey('databases'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = UserIdentity(
        userId: 'original-user',
        tenant: 'original-tenant',
        databases: ['original-db'],
      );

      final copied = original.copyWith();

      expect(copied.userId, 'original-user');
      expect(copied.tenant, 'original-tenant');
      expect(copied.databases, ['original-db']);
    });

    test('copyWith updates specified values', () {
      const original = UserIdentity(
        userId: 'original-user',
        tenant: 'original-tenant',
        databases: ['original-db'],
      );

      final copied = original.copyWith(
        userId: 'new-user',
        databases: ['new-db1', 'new-db2'],
      );

      expect(copied.userId, 'new-user');
      expect(copied.tenant, 'original-tenant');
      expect(copied.databases, ['new-db1', 'new-db2']);
    });

    test('equality works correctly', () {
      const identity1 = UserIdentity(userId: 'user', tenant: 'tenant');
      const identity2 = UserIdentity(userId: 'user', tenant: 'tenant');
      const identity3 = UserIdentity(userId: 'other', tenant: 'tenant');

      expect(identity1, equals(identity2));
      expect(identity1, isNot(equals(identity3)));
    });

    test('hashCode is consistent with equality', () {
      const identity1 = UserIdentity(userId: 'user', tenant: 'tenant');
      const identity2 = UserIdentity(userId: 'user', tenant: 'tenant');

      expect(identity1.hashCode, equals(identity2.hashCode));
    });

    test('toString returns readable representation', () {
      const identity = UserIdentity(userId: 'user-123', tenant: 'my-tenant');

      expect(identity.toString(), contains('UserIdentity'));
      expect(identity.toString(), contains('user-123'));
    });
  });
}
