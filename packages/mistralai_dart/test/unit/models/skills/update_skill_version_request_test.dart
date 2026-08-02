import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateSkillVersionRequest', () {
    group('toJson', () {
      test('serializes all fields', () {
        const request = UpdateSkillVersionRequest(
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
        const request = UpdateSkillVersionRequest(
          aliases: AliasList(values: []),
        );

        expect(request.toJson(), {
          'aliases': {'values': <String>[]},
        });
      });

      test('omits aliases when omitted entirely (leave unchanged)', () {
        const request = UpdateSkillVersionRequest(notes: 'notes');

        expect(request.toJson(), {'notes': 'notes'});
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = UpdateSkillVersionRequest(notes: 'a');

        final copy = original.copyWith(notes: 'b');

        expect(copy.notes, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = UpdateSkillVersionRequest(notes: 'a');

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = UpdateSkillVersionRequest(notes: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = UpdateSkillVersionRequest(notes: 'a');
        const b = UpdateSkillVersionRequest(notes: 'a');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when aliases differ', () {
        const a = UpdateSkillVersionRequest(aliases: AliasList(values: ['a']));
        const b = UpdateSkillVersionRequest(aliases: AliasList(values: ['b']));

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes fields', () {
      const request = UpdateSkillVersionRequest(notes: 'notes');

      expect(request.toString(), contains('UpdateSkillVersionRequest'));
      expect(request.toString(), contains('notes'));
    });
  });
}
