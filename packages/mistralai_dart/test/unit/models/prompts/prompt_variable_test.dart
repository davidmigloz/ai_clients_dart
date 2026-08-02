import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PromptVariable', () {
    group('fromJson', () {
      test('parses name', () {
        final variable = PromptVariable.fromJson(const {'name': 'topic'});

        expect(variable.name, 'topic');
      });

      test('parses missing name as null', () {
        final variable = PromptVariable.fromJson(const {});

        expect(variable.name, isNull);
      });
    });

    group('toJson', () {
      test('serializes name', () {
        const variable = PromptVariable(name: 'topic');

        expect(variable.toJson(), {'name': 'topic'});
      });

      test('omits name when null', () {
        const variable = PromptVariable();

        expect(variable.toJson(), <String, dynamic>{});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = PromptVariable(name: 'topic');

        final roundTripped = PromptVariable.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces name', () {
        const original = PromptVariable(name: 'a');

        final copy = original.copyWith(name: 'b');

        expect(copy.name, 'b');
      });

      test('clears name when null is passed explicitly', () {
        const original = PromptVariable(name: 'a');

        final copy = original.copyWith(name: null);

        expect(copy.name, isNull);
      });

      test('preserves name when not specified', () {
        const original = PromptVariable(name: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when name matches', () {
        const a = PromptVariable(name: 'a');
        const b = PromptVariable(name: 'a');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when name differs', () {
        const a = PromptVariable(name: 'a');
        const b = PromptVariable(name: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes name', () {
      const variable = PromptVariable(name: 'topic');

      expect(variable.toString(), contains('PromptVariable'));
      expect(variable.toString(), contains('topic'));
    });
  });
}
