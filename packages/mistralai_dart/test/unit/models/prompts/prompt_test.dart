import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Prompt', () {
    final fullJson = {
      'id': 'prompt-1',
      'name': 'greeting',
      'title': 'Greeting',
      'description': 'A friendly greeting',
      'latestVersion': 2,
      'version': 2,
      'definition': {'content': 'Hello, {{name}}!'},
      'notes': 'v2 notes',
      'aliases': ['prod'],
      'sharingScope': 'workspace',
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-02T00:00:00Z',
    };

    group('fromJson', () {
      test('parses all fields', () {
        final prompt = Prompt.fromJson(fullJson);

        expect(prompt.id, 'prompt-1');
        expect(prompt.name, 'greeting');
        expect(prompt.title, 'Greeting');
        expect(prompt.description, 'A friendly greeting');
        expect(prompt.latestVersion, 2);
        expect(prompt.version, 2);
        expect(
          prompt.definition,
          const PromptDefinition(content: 'Hello, {{name}}!'),
        );
        expect(prompt.notes, 'v2 notes');
        expect(prompt.aliases, ['prod']);
        expect(prompt.sharingScope, RegistrySharingScope.workspace);
        expect(prompt.createdAt, '2026-01-01T00:00:00Z');
        expect(prompt.updatedAt, '2026-01-02T00:00:00Z');
      });

      test('defaults id to empty string when missing', () {
        final prompt = Prompt.fromJson(const {});

        expect(prompt.id, '');
        expect(prompt.name, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final prompt = Prompt.fromJson(fullJson);

        expect(prompt.toJson(), fullJson);
      });

      test('omits nullable fields when null', () {
        const prompt = Prompt(id: 'p1');

        expect(prompt.toJson(), {'id': 'p1'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = Prompt.fromJson(fullJson);

        final roundTripped = Prompt.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = Prompt(id: 'p1', name: 'a');

        final copy = original.copyWith(name: 'b');

        expect(copy.id, 'p1');
        expect(copy.name, 'b');
      });

      test('clears nullable fields when null is passed explicitly', () {
        const original = Prompt(id: 'p1', title: 'a');

        final copy = original.copyWith(title: null);

        expect(copy.title, isNull);
      });

      test('preserves fields when not specified', () {
        const original = Prompt(id: 'p1', name: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = Prompt.fromJson(fullJson);
        final b = Prompt.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when id differs', () {
        const a = Prompt(id: 'p1');
        const b = Prompt(id: 'p2');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes id', () {
      const prompt = Prompt(id: 'p1', name: 'greeting');

      expect(prompt.toString(), contains('Prompt'));
      expect(prompt.toString(), contains('p1'));
      expect(prompt.toString(), contains('greeting'));
    });
  });
}
