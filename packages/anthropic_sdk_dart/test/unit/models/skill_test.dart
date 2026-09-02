import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SkillSourceType', () {
    test('round-trips known values', () {
      for (final value in SkillSourceType.values.where(
        (v) => v != SkillSourceType.unknown,
      )) {
        expect(SkillSourceType.fromJson(value.toJson()), value);
      }
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        SkillSourceType.fromJson('future_source'),
        SkillSourceType.unknown,
      );
    });
  });

  group('SkillSource', () {
    test('round-trips JSON', () {
      const source = SkillSource(type: SkillSourceType.custom);
      final json = source.toJson();
      expect(json, {'type': 'custom'});
      expect(SkillSource.fromJson(json), source);
    });

    test('equality and hashCode', () {
      const a = SkillSource(type: SkillSourceType.anthropic);
      const b = SkillSource(type: SkillSourceType.anthropic);
      const c = SkillSource(type: SkillSourceType.plugin);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('Skill', () {
    Map<String, dynamic> skillJson({
      String source = 'custom',
      String displayName = 'Custom PDF Processor',
    }) {
      return {
        'id': 'skill_abc123',
        'type': 'skill',
        'display_name': displayName,
        'created_at': '2025-01-15T10:00:00Z',
        'updated_at': '2025-01-20T15:30:00Z',
        'latest_version_id': 'skillver_123',
        'source': {'type': source},
      };
    }

    test('fromJson parses skill correctly', () {
      final skill = Skill.fromJson(skillJson());

      expect(skill.id, 'skill_abc123');
      expect(skill.type, 'skill');
      expect(skill.displayName, 'Custom PDF Processor');
      expect(skill.createdAt, DateTime.utc(2025, 1, 15, 10, 0, 0));
      expect(skill.updatedAt, DateTime.utc(2025, 1, 20, 15, 30, 0));
      expect(skill.latestVersionId, 'skillver_123');
      expect(skill.source, const SkillSource(type: SkillSourceType.custom));
    });

    test('fromJson handles anthropic source', () {
      final skill = Skill.fromJson(skillJson(source: 'anthropic'));
      expect(skill.source, const SkillSource(type: SkillSourceType.anthropic));
    });

    test(
      'fromJson throws FormatException when a required field is missing',
      () {
        final json = skillJson()..remove('display_name');
        expect(() => Skill.fromJson(json), throwsFormatException);
      },
    );

    test('toJson produces valid JSON', () {
      final skill = Skill(
        id: 'skill_test',
        displayName: 'Test Skill',
        latestVersionId: 'skillver_987',
        source: const SkillSource(type: SkillSourceType.custom),
        createdAt: DateTime.utc(2025, 3, 1, 12, 0, 0),
        updatedAt: DateTime.utc(2025, 3, 5, 18, 0, 0),
      );

      final json = skill.toJson();

      expect(json['id'], 'skill_test');
      expect(json['type'], 'skill');
      expect(json['display_name'], 'Test Skill');
      expect(json['created_at'], '2025-03-01T12:00:00.000Z');
      expect(json['updated_at'], '2025-03-05T18:00:00.000Z');
      expect(json['latest_version_id'], 'skillver_987');
      expect(json['source'], {'type': 'custom'});
    });

    test('equality works correctly', () {
      final skill1 = Skill.fromJson(skillJson());
      final skill2 = Skill.fromJson(skillJson());
      final skill3 = Skill.fromJson(skillJson(displayName: 'Other'));

      expect(skill1, equals(skill2));
      expect(skill1, isNot(equals(skill3)));
    });
  });

  group('SkillVersion', () {
    Map<String, dynamic> versionJson() {
      return {
        'id': 'skillver_abc123',
        'type': 'skill_version',
        'skill_id': 'skill_parent',
        'name': 'pdf-processor',
        'description': 'Processes PDF files',
        'created_at': '2025-01-01T00:00:00Z',
      };
    }

    test('fromJson parses skill version correctly', () {
      final version = SkillVersion.fromJson(versionJson());

      expect(version.id, 'skillver_abc123');
      expect(version.type, 'skill_version');
      expect(version.skillId, 'skill_parent');
      expect(version.name, 'pdf-processor');
      expect(version.description, 'Processes PDF files');
      expect(version.createdAt, DateTime.utc(2025, 1, 1));
    });

    test(
      'fromJson throws FormatException when a required field is missing',
      () {
        final json = versionJson()..remove('description');
        expect(() => SkillVersion.fromJson(json), throwsFormatException);
      },
    );

    test('toJson produces valid JSON', () {
      final version = SkillVersion(
        id: 'skillver_test',
        skillId: 'skill_test',
        name: 'test-skill',
        description: 'A test skill',
        createdAt: DateTime.utc(2025, 5, 15, 10, 30, 0),
      );

      final json = version.toJson();

      expect(json['id'], 'skillver_test');
      expect(json['type'], 'skill_version');
      expect(json['skill_id'], 'skill_test');
      expect(json['name'], 'test-skill');
      expect(json['description'], 'A test skill');
      expect(json['created_at'], '2025-05-15T10:30:00.000Z');
    });

    test('equality works correctly', () {
      final version1 = SkillVersion.fromJson(versionJson());
      final version2 = SkillVersion.fromJson(versionJson());
      final version3 = SkillVersion.fromJson(
        versionJson(),
      ).copyWith(id: 'other');

      expect(version1, equals(version2));
      expect(version1, isNot(equals(version3)));
    });

    test('copyWith creates modified copy', () {
      final original = SkillVersion.fromJson(versionJson());
      final modified = original.copyWith(name: 'modified');

      expect(modified.name, 'modified');
      expect(modified.id, original.id); // Unchanged
      expect(modified.skillId, original.skillId); // Unchanged
      expect(modified.description, original.description); // Unchanged
    });
  });

  group('SkillListResponse', () {
    test('fromJson parses list response correctly', () {
      final json = {
        'data': [
          {
            'id': 'skill_1',
            'type': 'skill',
            'display_name': 'Skill One',
            'created_at': '2025-01-01T00:00:00Z',
            'updated_at': '2025-01-01T00:00:00Z',
            'latest_version_id': 'skillver_1',
            'source': {'type': 'custom'},
          },
          {
            'id': 'skill_2',
            'type': 'skill',
            'display_name': 'Skill Two',
            'created_at': '2025-01-02T00:00:00Z',
            'updated_at': '2025-01-02T00:00:00Z',
            'latest_version_id': 'skillver_2',
            'source': {'type': 'anthropic'},
          },
        ],
        'next_page': 'page_token_abc123',
      };

      final response = SkillListResponse.fromJson(json);

      expect(response.data, hasLength(2));
      expect(response.data[0].id, 'skill_1');
      expect(response.data[1].id, 'skill_2');
      expect(response.nextPage, 'page_token_abc123');
    });

    test('fromJson handles empty list', () {
      final json = {'data': <Map<String, dynamic>>[], 'next_page': null};

      final response = SkillListResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.nextPage, isNull);
    });

    test('toJson produces valid JSON', () {
      final response = SkillListResponse(
        data: [
          Skill(
            id: 'skill_test',
            displayName: 'Test Skill',
            latestVersionId: 'skillver_1',
            source: const SkillSource(type: SkillSourceType.custom),
            createdAt: DateTime.utc(2025, 1, 1),
            updatedAt: DateTime.utc(2025, 1, 1),
          ),
        ],
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      expect(json['next_page'], isNull);
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
            'name': 'version-one',
            'description': 'First version',
            'created_at': '2025-01-01T00:00:00Z',
          },
          {
            'id': 'v2',
            'type': 'skill_version',
            'skill_id': 's1',
            'name': 'version-two',
            'description': 'Second version',
            'created_at': '2025-01-02T00:00:00Z',
          },
        ],
        'next_page': null,
      };

      final response = SkillVersionListResponse.fromJson(json);

      expect(response.data, hasLength(2));
      expect(response.data[0].name, 'version-one');
      expect(response.data[1].name, 'version-two');
      expect(response.nextPage, isNull);
    });

    test('toJson produces valid JSON', () {
      final response = SkillVersionListResponse(
        data: [
          SkillVersion(
            id: 'v_test',
            skillId: 's_test',
            name: 'test-version',
            description: 'Test description',
            createdAt: DateTime.utc(2025, 1, 1),
          ),
        ],
        nextPage: 'next_page_token',
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      expect(json['next_page'], 'next_page_token');
    });

    test('handles pagination correctly', () {
      final firstPage = SkillVersionListResponse(
        data: [
          SkillVersion(
            id: 'v1',
            skillId: 's1',
            name: 'v1',
            description: 'd1',
            createdAt: DateTime.utc(2025, 1, 1),
          ),
        ],
        nextPage: 'page_2',
      );

      expect(firstPage.nextPage, 'page_2');

      final secondPage = SkillVersionListResponse(
        data: [
          SkillVersion(
            id: 'v2',
            skillId: 's1',
            name: 'v2',
            description: 'd2',
            createdAt: DateTime.utc(2025, 1, 2),
          ),
        ],
      );

      expect(secondPage.nextPage, isNull);
    });
  });

  group('DeletedSkill', () {
    test('round-trips JSON', () {
      final json = {'id': 'skill_abc123', 'type': 'skill_deleted'};
      final deleted = DeletedSkill.fromJson(json);

      expect(deleted.id, 'skill_abc123');
      expect(deleted.type, 'skill_deleted');
      expect(deleted.toJson(), json);
    });

    test('equality works correctly', () {
      const a = DeletedSkill(id: 'skill_1');
      const b = DeletedSkill(id: 'skill_1');
      const c = DeletedSkill(id: 'skill_2');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('DeletedSkillVersion', () {
    test('round-trips JSON', () {
      final json = {'id': 'skillver_abc123', 'type': 'skill_version_deleted'};
      final deleted = DeletedSkillVersion.fromJson(json);

      expect(deleted.id, 'skillver_abc123');
      expect(deleted.type, 'skill_version_deleted');
      expect(deleted.toJson(), json);
    });
  });

  group('SkillFile', () {
    test('equality is content-based on bytes', () {
      final a = SkillFile(
        path: 'my-skill/SKILL.md',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final b = SkillFile(
        path: 'my-skill/SKILL.md',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final c = SkillFile(
        path: 'my-skill/other.md',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('hashCode is based on byte length, not every byte', () {
      // Two files with the same path/length/mimeType but different byte
      // content hash the same (hashCode need not distinguish unequal
      // objects), while equality still compares the exact bytes.
      final a = SkillFile(
        path: 'my-skill/SKILL.md',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final b = SkillFile(
        path: 'my-skill/SKILL.md',
        bytes: Uint8List.fromList([9, 9, 9]),
      );

      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(b)));
    });
  });
}
