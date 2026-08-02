import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateSkillRequest', () {
    final fullJson = {
      'name': 'summarizer',
      'definition': {'body': 'Summarize.'},
      'notes': 'notes',
      'sharingScope': 'private',
      'aliases': ['prod'],
    };

    group('fromJson', () {
      test('parses all fields', () {
        final request = CreateSkillRequest.fromJson(fullJson);

        expect(request.name, 'summarizer');
        expect(request.definition, const SkillDefinition(body: 'Summarize.'));
        expect(request.notes, 'notes');
        expect(request.sharingScope, RegistrySharingScope.private);
        expect(request.aliases, ['prod']);
      });

      test('throws FormatException when name missing', () {
        expect(
          () => CreateSkillRequest.fromJson(const {
            'definition': {'body': 'Summarize.'},
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException when definition missing', () {
        expect(
          () => CreateSkillRequest.fromJson(const {'name': 'summarizer'}),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final request = CreateSkillRequest.fromJson(fullJson);

        expect(request.toJson(), fullJson);
      });

      test('omits optional fields when null', () {
        const request = CreateSkillRequest(
          name: 'summarizer',
          definition: SkillDefinition(body: 'Summarize.'),
        );

        expect(request.toJson(), {
          'name': 'summarizer',
          'definition': {'body': 'Summarize.'},
        });
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = CreateSkillRequest.fromJson(fullJson);

        final roundTripped = CreateSkillRequest.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = CreateSkillRequest(
          name: 'a',
          definition: SkillDefinition(body: 'x'),
        );

        final copy = original.copyWith(name: 'b');

        expect(copy.name, 'b');
        expect(copy.definition, const SkillDefinition(body: 'x'));
      });

      test('clears optional fields when null is passed explicitly', () {
        const original = CreateSkillRequest(
          name: 'a',
          definition: SkillDefinition(body: 'x'),
          notes: 'notes',
        );

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = CreateSkillRequest(
          name: 'a',
          definition: SkillDefinition(body: 'x'),
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = CreateSkillRequest.fromJson(fullJson);
        final b = CreateSkillRequest.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when name differs', () {
        const a = CreateSkillRequest(
          name: 'a',
          definition: SkillDefinition(body: 'x'),
        );
        const b = CreateSkillRequest(
          name: 'b',
          definition: SkillDefinition(body: 'x'),
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes name', () {
      const request = CreateSkillRequest(
        name: 'summarizer',
        definition: SkillDefinition(body: 'Summarize.'),
      );

      expect(request.toString(), contains('CreateSkillRequest'));
      expect(request.toString(), contains('summarizer'));
    });
  });
}
