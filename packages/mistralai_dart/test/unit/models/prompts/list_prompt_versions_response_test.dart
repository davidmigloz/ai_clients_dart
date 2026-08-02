import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ListPromptVersionsResponse', () {
    final fullJson = {
      'data': [
        {'version': 1},
        {'version': 2},
      ],
    };

    group('fromJson', () {
      test('parses all fields', () {
        final response = ListPromptVersionsResponse.fromJson(fullJson);

        expect(response.data, [
          const PromptVersion(version: 1),
          const PromptVersion(version: 2),
        ]);
      });

      test('parses missing data as null', () {
        final response = ListPromptVersionsResponse.fromJson(const {});

        expect(response.data, isNull);
      });
    });

    group('toJson', () {
      test('serializes data', () {
        final response = ListPromptVersionsResponse.fromJson(fullJson);

        expect(response.toJson(), fullJson);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = ListPromptVersionsResponse.fromJson(fullJson);

        final roundTripped = ListPromptVersionsResponse.fromJson(
          original.toJson(),
        );

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces data', () {
        const original = ListPromptVersionsResponse();

        final copy = original.copyWith(data: const [PromptVersion(version: 1)]);

        expect(copy.data, [const PromptVersion(version: 1)]);
      });

      test('preserves data when not specified', () {
        final original = ListPromptVersionsResponse.fromJson(fullJson);

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when data matches', () {
        final a = ListPromptVersionsResponse.fromJson(fullJson);
        final b = ListPromptVersionsResponse.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when data differs', () {
        const a = ListPromptVersionsResponse(data: [PromptVersion(version: 1)]);
        const b = ListPromptVersionsResponse(data: [PromptVersion(version: 2)]);

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes item count', () {
      final response = ListPromptVersionsResponse.fromJson(fullJson);

      expect(response.toString(), contains('ListPromptVersionsResponse'));
      expect(response.toString(), contains('2 items'));
    });
  });
}
