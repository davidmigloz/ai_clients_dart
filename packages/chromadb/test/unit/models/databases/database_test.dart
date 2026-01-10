import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('Database', () {
    test('fromJson creates database with all fields', () {
      final json = {
        'id': 'db-123',
        'name': 'my-database',
        'tenant': 'my-tenant',
      };

      final database = Database.fromJson(json);

      expect(database.id, 'db-123');
      expect(database.name, 'my-database');
      expect(database.tenant, 'my-tenant');
    });

    test('fromJson handles null tenant', () {
      final json = {'id': 'db-456', 'name': 'test-database'};

      final database = Database.fromJson(json);

      expect(database.id, 'db-456');
      expect(database.name, 'test-database');
      expect(database.tenant, isNull);
    });

    test('toJson converts database correctly', () {
      const database = Database(
        id: 'db-789',
        name: 'export-db',
        tenant: 'export-tenant',
      );

      final json = database.toJson();

      expect(json['id'], 'db-789');
      expect(json['name'], 'export-db');
      expect(json['tenant'], 'export-tenant');
    });

    test('toJson excludes null values', () {
      const database = Database(id: 'db-only', name: 'minimal');

      final json = database.toJson();

      expect(json['id'], 'db-only');
      expect(json['name'], 'minimal');
      expect(json.containsKey('tenant'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = Database(
        id: 'original-id',
        name: 'original-name',
        tenant: 'original-tenant',
      );

      final copied = original.copyWith();

      expect(copied.id, 'original-id');
      expect(copied.name, 'original-name');
      expect(copied.tenant, 'original-tenant');
    });

    test('copyWith updates specified values', () {
      const original = Database(
        id: 'original-id',
        name: 'original-name',
        tenant: 'original-tenant',
      );

      final copied = original.copyWith(name: 'new-name');

      expect(copied.id, 'original-id');
      expect(copied.name, 'new-name');
      expect(copied.tenant, 'original-tenant');
    });

    test('equality works correctly', () {
      const db1 = Database(id: 'id', name: 'db', tenant: 'tenant');
      const db2 = Database(id: 'id', name: 'db', tenant: 'tenant');
      const db3 = Database(id: 'other', name: 'db', tenant: 'tenant');

      expect(db1, equals(db2));
      expect(db1, isNot(equals(db3)));
    });

    test('hashCode is consistent with equality', () {
      const db1 = Database(id: 'id', name: 'db', tenant: 'tenant');
      const db2 = Database(id: 'id', name: 'db', tenant: 'tenant');

      expect(db1.hashCode, equals(db2.hashCode));
    });

    test('toString returns readable representation', () {
      const database = Database(id: 'db-123', name: 'my-db');

      expect(database.toString(), contains('Database'));
      expect(database.toString(), contains('db-123'));
      expect(database.toString(), contains('my-db'));
    });
  });

  group('CreateDatabaseRequest', () {
    test('toJson converts request correctly', () {
      const request = CreateDatabaseRequest(name: 'new-database');

      final json = request.toJson();

      expect(json['name'], 'new-database');
    });
  });
}
