import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SkillVersion', () {
    final fullJson = {
      'version': 3,
      'definition': {'body': 'Do the thing.'},
      'notes': 'notes',
      'aliases': ['prod'],
      'createdAt': '2026-01-01T00:00:00Z',
    };

    group('fromJson', () {
      test('parses all fields', () {
        final version = SkillVersion.fromJson(fullJson);

        expect(version.version, 3);
        expect(
          version.definition,
          const SkillDefinition(body: 'Do the thing.'),
        );
        expect(version.notes, 'notes');
        expect(version.aliases, ['prod']);
        expect(version.createdAt, '2026-01-01T00:00:00Z');
      });

      test('parses missing fields as null', () {
        final version = SkillVersion.fromJson(const {});

        expect(version.version, isNull);
        expect(version.definition, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final version = SkillVersion.fromJson(fullJson);

        expect(version.toJson(), fullJson);
      });

      test('omits nullable fields when null', () {
        const version = SkillVersion();

        expect(version.toJson(), <String, dynamic>{});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = SkillVersion.fromJson(fullJson);

        final roundTripped = SkillVersion.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = SkillVersion(version: 1);

        final copy = original.copyWith(version: 2);

        expect(copy.version, 2);
      });

      test('clears fields when null is passed explicitly', () {
        const original = SkillVersion(notes: 'a');

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = SkillVersion(version: 1);

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        final a = SkillVersion.fromJson(fullJson);
        final b = SkillVersion.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when version differs', () {
        const a = SkillVersion(version: 1);
        const b = SkillVersion(version: 2);

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes version', () {
      const version = SkillVersion(version: 3);

      expect(version.toString(), contains('SkillVersion'));
      expect(version.toString(), contains('3'));
    });
  });
}
