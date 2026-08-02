import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SkillDefinition', () {
    final fullJson = {
      'body': 'Summarize the input.',
      'description': 'Summarizes documents.',
      'assets': {
        'notes.txt': {'textContent': 'hello'},
      },
    };

    group('fromJson', () {
      test('parses all fields', () {
        final definition = SkillDefinition.fromJson(fullJson);

        expect(definition.body, 'Summarize the input.');
        expect(definition.description, 'Summarizes documents.');
        expect(definition.assets, {
          'notes.txt': const SkillAssetContent.text(textContent: 'hello'),
        });
      });

      test('parses missing fields as null', () {
        final definition = SkillDefinition.fromJson(const {});

        expect(definition.body, isNull);
        expect(definition.assets, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final definition = SkillDefinition.fromJson(fullJson);

        expect(definition.toJson(), fullJson);
      });

      test('omits fields when null', () {
        const definition = SkillDefinition();

        expect(definition.toJson(), <String, dynamic>{});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = SkillDefinition.fromJson(fullJson);

        final roundTripped = SkillDefinition.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = SkillDefinition(body: 'a');

        final copy = original.copyWith(body: 'b');

        expect(copy.body, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = SkillDefinition(description: 'a');

        final copy = original.copyWith(description: null);

        expect(copy.description, isNull);
      });

      test('preserves fields when not specified', () {
        const original = SkillDefinition(body: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        final a = SkillDefinition.fromJson(fullJson);
        final b = SkillDefinition.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when body differs', () {
        const a = SkillDefinition(body: 'a');
        const b = SkillDefinition(body: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      final definition = SkillDefinition.fromJson(fullJson);

      expect(definition.toString(), contains('SkillDefinition'));
      expect(definition.toString(), contains('Summarizes documents.'));
    });
  });
}
