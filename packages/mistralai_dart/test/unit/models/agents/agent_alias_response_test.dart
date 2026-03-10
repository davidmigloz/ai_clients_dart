import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentAliasResponse', () {
    final createdAt = DateTime.utc(2024, 1, 15, 10, 30);
    final updatedAt = DateTime.utc(2024, 1, 16, 12, 0);

    group('constructor', () {
      test('creates with required fields', () {
        final alias = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(alias.alias, 'latest');
        expect(alias.version, 3);
        expect(alias.createdAt, createdAt);
        expect(alias.updatedAt, updatedAt);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final alias = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final json = alias.toJson();
        expect(json['alias'], 'latest');
        expect(json['version'], 3);
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
      });
    });

    group('fromJson', () {
      test('deserializes all fields with ISO 8601 strings', () {
        final json = <String, dynamic>{
          'alias': 'latest',
          'version': 3,
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-16T12:00:00.000Z',
        };
        final alias = AgentAliasResponse.fromJson(json);
        expect(alias.alias, 'latest');
        expect(alias.version, 3);
        expect(alias.createdAt, createdAt);
        expect(alias.updatedAt, updatedAt);
      });

      test('deserializes with unix timestamps', () {
        final json = <String, dynamic>{
          'alias': 'stable',
          'version': 1,
          'created_at': 1705312200,
          'updated_at': 1705398000,
        };
        final alias = AgentAliasResponse.fromJson(json);
        expect(alias.alias, 'stable');
        expect(alias.version, 1);
        expect(alias.createdAt, isA<DateTime>());
        expect(alias.updatedAt, isA<DateTime>());
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final alias = AgentAliasResponse.fromJson(json);
        expect(alias.alias, '');
        expect(alias.version, 0);
        expect(alias.createdAt, isA<DateTime>());
        expect(alias.updatedAt, isA<DateTime>());
      });
    });

    group('equality', () {
      test('equals with same alias and version', () {
        final a1 = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final a2 = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: DateTime.utc(2025),
          updatedAt: DateTime.utc(2025),
        );
        expect(a1, equals(a2));
        expect(a1.hashCode, equals(a2.hashCode));
      });

      test('not equals with different alias', () {
        final a1 = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final a2 = AgentAliasResponse(
          alias: 'stable',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(a1, isNot(equals(a2)));
      });

      test('not equals with different version', () {
        final a1 = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final a2 = AgentAliasResponse(
          alias: 'latest',
          version: 4,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(a1, isNot(equals(a2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        final alias = AgentAliasResponse(
          alias: 'latest',
          version: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final str = alias.toString();
        expect(str, contains('AgentAliasResponse'));
        expect(str, contains('latest'));
        expect(str, contains('3'));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        final original = AgentAliasResponse(
          alias: 'latest',
          version: 5,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final json = original.toJson();
        final restored = AgentAliasResponse.fromJson(json);
        expect(restored.alias, original.alias);
        expect(restored.version, original.version);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
      });
    });
  });
}
