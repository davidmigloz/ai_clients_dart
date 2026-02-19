import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Skill', () {
    test('fromJson parses correctly', () {
      final skill = Skill.fromJson(const {
        'id': 'skill_123',
        'object': 'skill',
        'name': 'Spreadsheet Helper',
        'description': 'Handles spreadsheet operations',
        'created_at': 1234567890,
        'default_version': 'latest',
        'latest_version': '42',
      });

      expect(skill.id, equals('skill_123'));
      expect(skill.object, equals('skill'));
      expect(skill.defaultVersion, equals('latest'));
      expect(skill.latestVersion, equals('42'));
    });
  });

  group('SkillVersion', () {
    test('fromJson parses correctly', () {
      final version = SkillVersion.fromJson(const {
        'object': 'skill.version',
        'id': 'skillver_123',
        'skill_id': 'skill_123',
        'version': '42',
        'created_at': 1234567890,
        'name': 'Spreadsheet Helper',
        'description': 'Handles spreadsheet operations',
      });

      expect(version.object, equals('skill.version'));
      expect(version.id, equals('skillver_123'));
      expect(version.skillId, equals('skill_123'));
      expect(version.version, equals('42'));
    });
  });

  group('SkillList', () {
    test('fromJson parses correctly', () {
      final list = SkillList.fromJson(const {
        'object': 'list',
        'data': [
          {
            'id': 'skill_123',
            'object': 'skill',
            'name': 'Spreadsheet Helper',
            'description': 'Handles spreadsheet operations',
            'created_at': 1234567890,
            'default_version': 'latest',
            'latest_version': '42',
          },
        ],
        'first_id': 'skill_123',
        'last_id': 'skill_123',
        'has_more': false,
      });

      expect(list.object, equals('list'));
      expect(list.data, hasLength(1));
      expect(list.firstId, equals('skill_123'));
      expect(list.hasMore, isFalse);
    });
  });

  group('SetDefaultSkillVersionRequest', () {
    test('toJson serializes correctly', () {
      const request = SetDefaultSkillVersionRequest(defaultVersion: '42');
      expect(request.toJson(), equals({'default_version': '42'}));
    });
  });
}
