import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Skill', () {
    final fullJson = {
      'id': 'skill-1',
      'name': 'summarizer',
      'latestVersion': 2,
      'version': 2,
      'definition': {'body': 'Summarize.'},
      'notes': 'v2 notes',
      'aliases': ['prod'],
      'sharingScope': 'workspace',
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-02T00:00:00Z',
    };

    group('fromJson', () {
      test('parses all fields', () {
        final skill = Skill.fromJson(fullJson);

        expect(skill.id, 'skill-1');
        expect(skill.name, 'summarizer');
        expect(skill.latestVersion, 2);
        expect(skill.version, 2);
        expect(skill.definition, const SkillDefinition(body: 'Summarize.'));
        expect(skill.notes, 'v2 notes');
        expect(skill.aliases, ['prod']);
        expect(skill.sharingScope, RegistrySharingScope.workspace);
        expect(skill.createdAt, '2026-01-01T00:00:00Z');
        expect(skill.updatedAt, '2026-01-02T00:00:00Z');
      });

      test('defaults id to empty string when missing', () {
        final skill = Skill.fromJson(const {});

        expect(skill.id, '');
        expect(skill.name, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final skill = Skill.fromJson(fullJson);

        expect(skill.toJson(), fullJson);
      });

      test('omits nullable fields when null', () {
        const skill = Skill(id: 's1');

        expect(skill.toJson(), {'id': 's1'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = Skill.fromJson(fullJson);

        final roundTripped = Skill.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = Skill(id: 's1', name: 'a');

        final copy = original.copyWith(name: 'b');

        expect(copy.id, 's1');
        expect(copy.name, 'b');
      });

      test('clears nullable fields when null is passed explicitly', () {
        const original = Skill(id: 's1', notes: 'a');

        final copy = original.copyWith(notes: null);

        expect(copy.notes, isNull);
      });

      test('preserves fields when not specified', () {
        const original = Skill(id: 's1', name: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = Skill.fromJson(fullJson);
        final b = Skill.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when id differs', () {
        const a = Skill(id: 's1');
        const b = Skill(id: 's2');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes id', () {
      const skill = Skill(id: 's1', name: 'summarizer');

      expect(skill.toString(), contains('Skill'));
      expect(skill.toString(), contains('s1'));
      expect(skill.toString(), contains('summarizer'));
    });
  });
}
