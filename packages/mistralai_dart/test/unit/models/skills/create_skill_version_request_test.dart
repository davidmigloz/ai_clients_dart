import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateSkillVersionRequest', () {
    group('toJson', () {
      test('serializes all fields', () {
        const request = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'Do it.'),
          aliases: ['prod'],
          notes: 'notes',
        );

        expect(request.toJson(), {
          'definition': {'body': 'Do it.'},
          'aliases': ['prod'],
          'notes': 'notes',
        });
      });

      test('omits optional fields when null', () {
        const request = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'Do it.'),
        );

        expect(request.toJson(), {
          'definition': {'body': 'Do it.'},
        });
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'a'),
        );

        final copy = original.copyWith(
          definition: const SkillDefinition(body: 'b'),
        );

        expect(copy.definition, const SkillDefinition(body: 'b'));
      });

      test('clears optional fields when null is passed explicitly', () {
        const original = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'a'),
          notes: 'notes',
        );

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'a'),
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'a'),
        );
        const b = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'a'),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when definition differs', () {
        const a = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'a'),
        );
        const b = CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'b'),
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes definition', () {
      const request = CreateSkillVersionRequest(
        definition: SkillDefinition(body: 'Do it.'),
      );

      expect(request.toString(), contains('CreateSkillVersionRequest'));
    });
  });
}
