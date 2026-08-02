import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ListSkillsResponse', () {
    final fullJson = {
      'data': [
        {'id': 's1'},
        {'id': 's2'},
      ],
      'nextPageToken': 'cursor-1',
    };

    group('fromJson', () {
      test('parses all fields', () {
        final response = ListSkillsResponse.fromJson(fullJson);

        expect(response.data, [const Skill(id: 's1'), const Skill(id: 's2')]);
        expect(response.nextPageToken, 'cursor-1');
      });

      test('parses missing fields as null', () {
        final response = ListSkillsResponse.fromJson(const {});

        expect(response.data, isNull);
        expect(response.nextPageToken, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final response = ListSkillsResponse.fromJson(fullJson);

        expect(response.toJson(), fullJson);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = ListSkillsResponse.fromJson(fullJson);

        final roundTripped = ListSkillsResponse.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = ListSkillsResponse(nextPageToken: 'a');

        final copy = original.copyWith(nextPageToken: 'b');

        expect(copy.nextPageToken, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = ListSkillsResponse(nextPageToken: 'a');

        final copy = original.copyWith(nextPageToken: null);

        expect(copy.nextPageToken, isNull);
      });

      test('preserves fields when not specified', () {
        const original = ListSkillsResponse(nextPageToken: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        final a = ListSkillsResponse.fromJson(fullJson);
        final b = ListSkillsResponse.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when nextPageToken differs', () {
        const a = ListSkillsResponse(nextPageToken: 'a');
        const b = ListSkillsResponse(nextPageToken: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      final response = ListSkillsResponse.fromJson(fullJson);

      expect(response.toString(), contains('ListSkillsResponse'));
      expect(response.toString(), contains('2 items'));
    });
  });
}
