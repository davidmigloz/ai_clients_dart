import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PromptDefinition', () {
    group('fromJson', () {
      test('parses required content and variables', () {
        final definition = PromptDefinition.fromJson(const {
          'content': 'Hello, {{name}}!',
          'variables': [
            {'name': 'name'},
          ],
        });

        expect(definition.content, 'Hello, {{name}}!');
        expect(definition.variables, [const PromptVariable(name: 'name')]);
      });

      test('parses missing variables as null', () {
        final definition = PromptDefinition.fromJson(const {'content': 'Hi!'});

        expect(definition.variables, isNull);
      });

      test('throws FormatException when content missing', () {
        expect(
          () => PromptDefinition.fromJson(const {}),
          throwsFormatException,
        );
      });

      test('throws FormatException when content is null', () {
        expect(
          () => PromptDefinition.fromJson(const {'content': null}),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('serializes content and variables', () {
        const definition = PromptDefinition(
          content: 'Hi',
          variables: [PromptVariable(name: 'x')],
        );

        expect(definition.toJson(), {
          'content': 'Hi',
          'variables': [
            {'name': 'x'},
          ],
        });
      });

      test('omits variables when null', () {
        const definition = PromptDefinition(content: 'Hi');

        expect(definition.toJson(), {'content': 'Hi'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = PromptDefinition(
          content: 'Hello, {{name}}!',
          variables: [PromptVariable(name: 'name')],
        );

        final roundTripped = PromptDefinition.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = PromptDefinition(content: 'a');

        final copy = original.copyWith(content: 'b');

        expect(copy.content, 'b');
      });

      test('clears variables when null is passed explicitly', () {
        const original = PromptDefinition(
          content: 'a',
          variables: [PromptVariable(name: 'x')],
        );

        final copy = original.copyWith(variables: null);

        expect(copy.variables, isNull);
      });

      test('preserves fields when not specified', () {
        const original = PromptDefinition(content: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = PromptDefinition(content: 'a');
        const b = PromptDefinition(content: 'a');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when content differs', () {
        const a = PromptDefinition(content: 'a');
        const b = PromptDefinition(content: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      const definition = PromptDefinition(content: 'Hello');

      expect(definition.toString(), contains('PromptDefinition'));
      expect(definition.toString(), contains('chars'));
    });
  });
}
