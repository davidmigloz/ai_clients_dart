import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateSkillVersionResponse', () {
    group('fromJson', () {
      test('parses all fields', () {
        final response = CreateSkillVersionResponse.fromJson(const {
          'version': 2,
          'deduplicated': false,
        });

        expect(response.version, 2);
        expect(response.deduplicated, false);
      });

      test('parses missing fields as null', () {
        final response = CreateSkillVersionResponse.fromJson(const {});

        expect(response.version, isNull);
        expect(response.deduplicated, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const response = CreateSkillVersionResponse(
          version: 2,
          deduplicated: true,
        );

        expect(response.toJson(), {'version': 2, 'deduplicated': true});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = CreateSkillVersionResponse(
          version: 1,
          deduplicated: false,
        );

        final roundTripped = CreateSkillVersionResponse.fromJson(
          original.toJson(),
        );

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = CreateSkillVersionResponse(version: 1);

        final copy = original.copyWith(version: 2);

        expect(copy.version, 2);
      });

      test('preserves fields when not specified', () {
        const original = CreateSkillVersionResponse(version: 1);

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = CreateSkillVersionResponse(version: 1, deduplicated: true);
        const b = CreateSkillVersionResponse(version: 1, deduplicated: true);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when version differs', () {
        const a = CreateSkillVersionResponse(version: 1);
        const b = CreateSkillVersionResponse(version: 2);

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes fields', () {
      const response = CreateSkillVersionResponse(
        version: 1,
        deduplicated: true,
      );

      expect(response.toString(), contains('CreateSkillVersionResponse'));
      expect(response.toString(), contains('1'));
      expect(response.toString(), contains('true'));
    });
  });
}
