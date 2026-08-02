import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreatePromptVersionRequest', () {
    group('toJson', () {
      test('serializes all fields', () {
        const request = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'Hi'),
          aliases: ['prod'],
          notes: 'notes',
        );

        expect(request.toJson(), {
          'definition': {'content': 'Hi'},
          'aliases': ['prod'],
          'notes': 'notes',
        });
      });

      test('omits optional fields when null', () {
        const request = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'Hi'),
        );

        expect(request.toJson(), {
          'definition': {'content': 'Hi'},
        });
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'a'),
        );

        final copy = original.copyWith(
          definition: const PromptDefinition(content: 'b'),
        );

        expect(copy.definition, const PromptDefinition(content: 'b'));
      });

      test('clears optional fields when null is passed explicitly', () {
        const original = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'a'),
          notes: 'notes',
        );

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'a'),
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'a'),
        );
        const b = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'a'),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when definition differs', () {
        const a = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'a'),
        );
        const b = CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'b'),
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes definition', () {
      const request = CreatePromptVersionRequest(
        definition: PromptDefinition(content: 'Hi'),
      );

      expect(request.toString(), contains('CreatePromptVersionRequest'));
    });
  });
}
