import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ListSkillVersionsResponse', () {
    final fullJson = {
      'data': [
        {'version': 1},
        {'version': 2},
      ],
    };

    group('fromJson', () {
      test('parses all fields', () {
        final response = ListSkillVersionsResponse.fromJson(fullJson);

        expect(response.data, [
          const SkillVersion(version: 1),
          const SkillVersion(version: 2),
        ]);
      });

      test('parses missing data as null', () {
        final response = ListSkillVersionsResponse.fromJson(const {});

        expect(response.data, isNull);
      });
    });

    group('toJson', () {
      test('serializes data', () {
        final response = ListSkillVersionsResponse.fromJson(fullJson);

        expect(response.toJson(), fullJson);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = ListSkillVersionsResponse.fromJson(fullJson);

        final roundTripped = ListSkillVersionsResponse.fromJson(
          original.toJson(),
        );

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces data', () {
        const original = ListSkillVersionsResponse();

        final copy = original.copyWith(data: const [SkillVersion(version: 1)]);

        expect(copy.data, [const SkillVersion(version: 1)]);
      });

      test('preserves data when not specified', () {
        final original = ListSkillVersionsResponse.fromJson(fullJson);

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when data matches', () {
        final a = ListSkillVersionsResponse.fromJson(fullJson);
        final b = ListSkillVersionsResponse.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when data differs', () {
        const a = ListSkillVersionsResponse(data: [SkillVersion(version: 1)]);
        const b = ListSkillVersionsResponse(data: [SkillVersion(version: 2)]);

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes item count', () {
      final response = ListSkillVersionsResponse.fromJson(fullJson);

      expect(response.toString(), contains('ListSkillVersionsResponse'));
      expect(response.toString(), contains('2 items'));
    });
  });
}
