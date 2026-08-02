import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreatePromptRequest', () {
    final fullJson = {
      'name': 'greeting',
      'definition': {'content': 'Hi'},
      'title': 'Greeting',
      'description': 'desc',
      'notes': 'notes',
      'sharingScope': 'private',
      'aliases': ['prod'],
    };

    group('fromJson', () {
      test('parses all fields', () {
        final request = CreatePromptRequest.fromJson(fullJson);

        expect(request.name, 'greeting');
        expect(request.definition, const PromptDefinition(content: 'Hi'));
        expect(request.title, 'Greeting');
        expect(request.description, 'desc');
        expect(request.notes, 'notes');
        expect(request.sharingScope, RegistrySharingScope.private);
        expect(request.aliases, ['prod']);
      });

      test('throws FormatException when name missing', () {
        expect(
          () => CreatePromptRequest.fromJson(const {
            'definition': {'content': 'Hi'},
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException when definition missing', () {
        expect(
          () => CreatePromptRequest.fromJson(const {'name': 'greeting'}),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final request = CreatePromptRequest.fromJson(fullJson);

        expect(request.toJson(), fullJson);
      });

      test('omits optional fields when null', () {
        const request = CreatePromptRequest(
          name: 'greeting',
          definition: PromptDefinition(content: 'Hi'),
        );

        expect(request.toJson(), {
          'name': 'greeting',
          'definition': {'content': 'Hi'},
        });
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = CreatePromptRequest.fromJson(fullJson);

        final roundTripped = CreatePromptRequest.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = CreatePromptRequest(
          name: 'a',
          definition: PromptDefinition(content: 'x'),
        );

        final copy = original.copyWith(name: 'b');

        expect(copy.name, 'b');
        expect(copy.definition, const PromptDefinition(content: 'x'));
      });

      test('clears optional fields when null is passed explicitly', () {
        const original = CreatePromptRequest(
          name: 'a',
          definition: PromptDefinition(content: 'x'),
          title: 'title',
        );

        final copy = original.copyWith(title: null);

        expect(copy.title, isNull);
      });

      test('preserves fields when not specified', () {
        const original = CreatePromptRequest(
          name: 'a',
          definition: PromptDefinition(content: 'x'),
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = CreatePromptRequest.fromJson(fullJson);
        final b = CreatePromptRequest.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when name differs', () {
        const a = CreatePromptRequest(
          name: 'a',
          definition: PromptDefinition(content: 'x'),
        );
        const b = CreatePromptRequest(
          name: 'b',
          definition: PromptDefinition(content: 'x'),
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes name', () {
      const request = CreatePromptRequest(
        name: 'greeting',
        definition: PromptDefinition(content: 'Hi'),
      );

      expect(request.toString(), contains('CreatePromptRequest'));
      expect(request.toString(), contains('greeting'));
    });
  });
}
