import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ListPromptsResponse', () {
    final fullJson = {
      'data': [
        {'id': 'p1'},
        {'id': 'p2'},
      ],
      'nextPageToken': 'cursor-1',
    };

    group('fromJson', () {
      test('parses all fields', () {
        final response = ListPromptsResponse.fromJson(fullJson);

        expect(response.data, [const Prompt(id: 'p1'), const Prompt(id: 'p2')]);
        expect(response.nextPageToken, 'cursor-1');
      });

      test('parses missing fields as null', () {
        final response = ListPromptsResponse.fromJson(const {});

        expect(response.data, isNull);
        expect(response.nextPageToken, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final response = ListPromptsResponse.fromJson(fullJson);

        expect(response.toJson(), fullJson);
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = ListPromptsResponse.fromJson(fullJson);

        final roundTripped = ListPromptsResponse.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = ListPromptsResponse(nextPageToken: 'a');

        final copy = original.copyWith(nextPageToken: 'b');

        expect(copy.nextPageToken, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = ListPromptsResponse(nextPageToken: 'a');

        final copy = original.copyWith(nextPageToken: null);

        expect(copy.nextPageToken, isNull);
      });

      test('preserves fields when not specified', () {
        const original = ListPromptsResponse(nextPageToken: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        final a = ListPromptsResponse.fromJson(fullJson);
        final b = ListPromptsResponse.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when nextPageToken differs', () {
        const a = ListPromptsResponse(nextPageToken: 'a');
        const b = ListPromptsResponse(nextPageToken: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      final response = ListPromptsResponse.fromJson(fullJson);

      expect(response.toString(), contains('ListPromptsResponse'));
      expect(response.toString(), contains('2 items'));
    });
  });
}
