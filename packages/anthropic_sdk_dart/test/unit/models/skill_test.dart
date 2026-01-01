import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Skill', () {
    test('fromJson parses skill correctly', () {
      final json = {
        'id': 'skill_abc123',
        'type': 'skill',
        'display_title': 'Custom PDF Processor',
        'created_at': '2025-01-15T10:00:00Z',
        'updated_at': '2025-01-20T15:30:00Z',
        'latest_version': '1234567890123',
        'source': 'custom',
      };

      final skill = Skill.fromJson(json);

      expect(skill.id, 'skill_abc123');
      expect(skill.type, 'skill');
      expect(skill.displayTitle, 'Custom PDF Processor');
      expect(skill.createdAt, DateTime.utc(2025, 1, 15, 10, 0, 0));
      expect(skill.updatedAt, DateTime.utc(2025, 1, 20, 15, 30, 0));
      expect(skill.latestVersion, '1234567890123');
      expect(skill.source, 'custom');
    });

    test('fromJson handles anthropic source', () {
      final json = {
        'id': 'skill_anthropic',
        'type': 'skill',
        'display_title': 'Built-in Skill',
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
        'latest_version': '1',
        'source': 'anthropic',
      };

      final skill = Skill.fromJson(json);

      expect(skill.source, 'anthropic');
    });

    test('toJson produces valid JSON', () {
      final skill = Skill(
        id: 'skill_test',
        displayTitle: 'Test Skill',
        createdAt: DateTime.utc(2025, 3, 1, 12, 0, 0),
        updatedAt: DateTime.utc(2025, 3, 5, 18, 0, 0),
        latestVersion: '9876543210987',
        source: 'custom',
      );

      final json = skill.toJson();

      expect(json['id'], 'skill_test');
      expect(json['type'], 'skill');
      expect(json['display_title'], 'Test Skill');
      expect(json['created_at'], '2025-03-01T12:00:00.000Z');
      expect(json['updated_at'], '2025-03-05T18:00:00.000Z');
      expect(json['latest_version'], '9876543210987');
      expect(json['source'], 'custom');
    });

    test('equality works correctly', () {
      final skill1 = Skill(
        id: 'skill_1',
        displayTitle: 'Skill One',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
        latestVersion: '1',
        source: 'custom',
      );

      final skill2 = Skill(
        id: 'skill_1',
        displayTitle: 'Skill One',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
        latestVersion: '1',
        source: 'custom',
      );

      final skill3 = Skill(
        id: 'skill_2',
        displayTitle: 'Skill Two',
        createdAt: DateTime.utc(2025, 1, 2),
        updatedAt: DateTime.utc(2025, 1, 2),
        latestVersion: '2',
        source: 'anthropic',
      );

      expect(skill1, equals(skill2));
      expect(skill1, isNot(equals(skill3)));
    });
  });

  group('SkillVersion', () {
    test('fromJson parses skill version correctly', () {
      final json = {
        'id': 'skillversion_abc123',
        'type': 'skill_version',
        'skill_id': 'skill_parent',
        'version': '1759178010641129',
        'name': 'pdf-processor',
        'description': 'Processes PDF files',
        'directory': '/skills/pdf-processor',
        'created_at': '2025-01-01T00:00:00Z',
      };

      final version = SkillVersion.fromJson(json);

      expect(version.id, 'skillversion_abc123');
      expect(version.type, 'skill_version');
      expect(version.skillId, 'skill_parent');
      expect(version.version, '1759178010641129');
      expect(version.name, 'pdf-processor');
      expect(version.description, 'Processes PDF files');
      expect(version.directory, '/skills/pdf-processor');
      expect(version.createdAt, DateTime.utc(2025, 1, 1));
    });

    test('toJson produces valid JSON', () {
      final version = SkillVersion(
        id: 'skillversion_test',
        skillId: 'skill_test',
        version: '123456',
        name: 'test-skill',
        description: 'A test skill',
        directory: '/test',
        createdAt: DateTime.utc(2025, 5, 15, 10, 30, 0),
      );

      final json = version.toJson();

      expect(json['id'], 'skillversion_test');
      expect(json['type'], 'skill_version');
      expect(json['skill_id'], 'skill_test');
      expect(json['version'], '123456');
      expect(json['name'], 'test-skill');
      expect(json['description'], 'A test skill');
      expect(json['directory'], '/test');
      expect(json['created_at'], '2025-05-15T10:30:00.000Z');
    });

    test('equality works correctly', () {
      final version1 = SkillVersion(
        id: 'v1',
        skillId: 's1',
        version: '1',
        name: 'version-one',
        description: 'First version',
        directory: '/v1',
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final version2 = SkillVersion(
        id: 'v1',
        skillId: 's1',
        version: '1',
        name: 'version-one',
        description: 'First version',
        directory: '/v1',
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final version3 = SkillVersion(
        id: 'v2',
        skillId: 's1',
        version: '2',
        name: 'version-two',
        description: 'Second version',
        directory: '/v2',
        createdAt: DateTime.utc(2025, 1, 2),
      );

      expect(version1, equals(version2));
      expect(version1, isNot(equals(version3)));
    });

    test('copyWith creates modified copy', () {
      final original = SkillVersion(
        id: 'v_orig',
        skillId: 's_orig',
        version: '100',
        name: 'original',
        description: 'Original description',
        directory: '/original',
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final modified = original.copyWith(version: '101', name: 'modified');

      expect(modified.version, '101');
      expect(modified.name, 'modified');
      expect(modified.id, 'v_orig'); // Unchanged
      expect(modified.skillId, 's_orig'); // Unchanged
      expect(modified.description, 'Original description'); // Unchanged
    });
  });

  group('SkillListResponse', () {
    test('fromJson parses list response correctly', () {
      final json = {
        'data': [
          {
            'id': 'skill_1',
            'type': 'skill',
            'display_title': 'Skill One',
            'created_at': '2025-01-01T00:00:00Z',
            'updated_at': '2025-01-01T00:00:00Z',
            'latest_version': '1',
            'source': 'custom',
          },
          {
            'id': 'skill_2',
            'type': 'skill',
            'display_title': 'Skill Two',
            'created_at': '2025-01-02T00:00:00Z',
            'updated_at': '2025-01-02T00:00:00Z',
            'latest_version': '2',
            'source': 'anthropic',
          },
        ],
        'has_more': true,
        'next_page': 'page_token_abc123',
      };

      final response = SkillListResponse.fromJson(json);

      expect(response.data, hasLength(2));
      expect(response.data[0].id, 'skill_1');
      expect(response.data[1].id, 'skill_2');
      expect(response.hasMore, isTrue);
      expect(response.nextPage, 'page_token_abc123');
    });

    test('fromJson handles empty list', () {
      final json = {
        'data': <Map<String, dynamic>>[],
        'has_more': false,
        'next_page': null,
      };

      final response = SkillListResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.hasMore, isFalse);
      expect(response.nextPage, isNull);
    });

    test('toJson produces valid JSON', () {
      final response = SkillListResponse(
        data: [
          Skill(
            id: 'skill_test',
            displayTitle: 'Test Skill',
            createdAt: DateTime.utc(2025, 1, 1),
            updatedAt: DateTime.utc(2025, 1, 1),
            latestVersion: '1',
            source: 'custom',
          ),
        ],
        hasMore: false,
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      expect(json['has_more'], isFalse);
    });
  });

  group('SkillVersionListResponse', () {
    test('fromJson parses version list response correctly', () {
      final json = {
        'data': [
          {
            'id': 'v1',
            'type': 'skill_version',
            'skill_id': 's1',
            'version': '1',
            'name': 'version-one',
            'description': 'First version',
            'directory': '/v1',
            'created_at': '2025-01-01T00:00:00Z',
          },
          {
            'id': 'v2',
            'type': 'skill_version',
            'skill_id': 's1',
            'version': '2',
            'name': 'version-two',
            'description': 'Second version',
            'directory': '/v2',
            'created_at': '2025-01-02T00:00:00Z',
          },
        ],
        'has_more': false,
        'next_page': null,
      };

      final response = SkillVersionListResponse.fromJson(json);

      expect(response.data, hasLength(2));
      expect(response.data[0].version, '1');
      expect(response.data[1].version, '2');
      expect(response.hasMore, isFalse);
      expect(response.nextPage, isNull);
    });

    test('toJson produces valid JSON', () {
      final response = SkillVersionListResponse(
        data: [
          SkillVersion(
            id: 'v_test',
            skillId: 's_test',
            version: '123',
            name: 'test-version',
            description: 'Test description',
            directory: '/test',
            createdAt: DateTime.utc(2025, 1, 1),
          ),
        ],
        hasMore: true,
        nextPage: 'next_page_token',
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      expect(json['has_more'], isTrue);
      expect(json['next_page'], 'next_page_token');
    });

    test('handles pagination correctly', () {
      final firstPage = SkillVersionListResponse(
        data: [
          SkillVersion(
            id: 'v1',
            skillId: 's1',
            version: '1',
            name: 'v1',
            description: 'd1',
            directory: '/v1',
            createdAt: DateTime.utc(2025, 1, 1),
          ),
        ],
        hasMore: true,
        nextPage: 'page_2',
      );

      expect(firstPage.hasMore, isTrue);
      expect(firstPage.nextPage, 'page_2');

      final secondPage = SkillVersionListResponse(
        data: [
          SkillVersion(
            id: 'v2',
            skillId: 's1',
            version: '2',
            name: 'v2',
            description: 'd2',
            directory: '/v2',
            createdAt: DateTime.utc(2025, 1, 2),
          ),
        ],
        hasMore: false,
      );

      expect(secondPage.hasMore, isFalse);
      expect(secondPage.nextPage, isNull);
    });
  });
}
