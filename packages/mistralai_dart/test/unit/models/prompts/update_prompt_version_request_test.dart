import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdatePromptVersionRequest', () {
    group('toJson', () {
      test('serializes all fields', () {
        const request = UpdatePromptVersionRequest(
          aliases: AliasList(values: ['prod']),
          notes: 'notes',
        );

        expect(request.toJson(), {
          'aliases': {
            'values': ['prod'],
          },
          'notes': 'notes',
        });
      });

      test('serializes an explicit empty alias list (clear all aliases)', () {
        const request = UpdatePromptVersionRequest(
          aliases: AliasList(values: []),
        );

        expect(request.toJson(), {
          'aliases': {'values': <String>[]},
        });
      });

      test('omits aliases when omitted entirely (leave unchanged)', () {
        const request = UpdatePromptVersionRequest(notes: 'notes');

        expect(request.toJson(), {'notes': 'notes'});
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = UpdatePromptVersionRequest(notes: 'a');

        final copy = original.copyWith(notes: 'b');

        expect(copy.notes, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = UpdatePromptVersionRequest(notes: 'a');

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = UpdatePromptVersionRequest(notes: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = UpdatePromptVersionRequest(notes: 'a');
        const b = UpdatePromptVersionRequest(notes: 'a');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when aliases differ', () {
        const a = UpdatePromptVersionRequest(aliases: AliasList(values: ['a']));
        const b = UpdatePromptVersionRequest(aliases: AliasList(values: ['b']));

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes fields', () {
      const request = UpdatePromptVersionRequest(notes: 'notes');

      expect(request.toString(), contains('UpdatePromptVersionRequest'));
      expect(request.toString(), contains('notes'));
    });
  });
}
