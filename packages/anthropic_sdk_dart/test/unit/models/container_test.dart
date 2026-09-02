import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ContainerSkillType', () {
    test('round-trips known values', () {
      expect(
        ContainerSkillType.fromJson('anthropic'),
        ContainerSkillType.anthropic,
      );
      expect(ContainerSkillType.fromJson('custom'), ContainerSkillType.custom);
      expect(ContainerSkillType.anthropic.toJson(), 'anthropic');
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        ContainerSkillType.fromJson('something_new'),
        ContainerSkillType.unknown,
      );
    });
  });

  group('ContainerSkillParams', () {
    test('round-trips with version', () {
      final json = {
        'type': 'anthropic',
        'skill_id': 'pdf',
        'version': 'latest',
      };
      final params = ContainerSkillParams.fromJson(json);
      expect(params.type, ContainerSkillType.anthropic);
      expect(params.skillId, 'pdf');
      expect(params.version, 'latest');
      expect(params.toJson(), json);
    });

    test('omits version when absent', () {
      const params = ContainerSkillParams(
        type: ContainerSkillType.custom,
        skillId: 'my-skill',
      );
      expect(params.toJson().containsKey('version'), isFalse);
    });

    test('throws FormatException for missing required fields', () {
      expect(
        () => ContainerSkillParams.fromJson(const {'skill_id': 'pdf'}),
        throwsFormatException,
      );
      expect(
        () => ContainerSkillParams.fromJson(const {'type': 'anthropic'}),
        throwsFormatException,
      );
    });
  });

  group('ContainerParams', () {
    test('round-trips id and skills', () {
      final json = {
        'id': 'container_123',
        'skills': [
          {'type': 'anthropic', 'skill_id': 'pdf', 'version': 'latest'},
        ],
      };
      final params = ContainerParams.fromJson(json);
      expect(params.id, 'container_123');
      expect(params.skills, hasLength(1));
      expect(params.toJson(), json);
    });

    test('omits null fields', () {
      const params = ContainerParams();
      expect(params.toJson(), isEmpty);
    });

    test('copyWith / equality / toString', () {
      const a = ContainerParams(id: 'c1');
      const b = ContainerParams(id: 'c1');
      final c = a.copyWith(id: 'c2');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.id, 'c2');
      expect(a.toString(), contains('ContainerParams'));
    });
  });

  group('ContainerParam', () {
    test('fromJson parses a plain string as ContainerParamId', () {
      final param = ContainerParam.fromJson('container_abc');
      expect(param, isA<ContainerParamId>());
      expect((param as ContainerParamId).id, 'container_abc');
      expect(param.toJson(), 'container_abc');
    });

    test('fromJson parses an object as ContainerParamConfig', () {
      final json = {
        'skills': [
          {'type': 'anthropic', 'skill_id': 'pdf', 'version': 'latest'},
        ],
      };
      final param = ContainerParam.fromJson(json);
      expect(param, isA<ContainerParamConfig>());
      final config = param as ContainerParamConfig;
      expect(config.params.skills, hasLength(1));
      expect(param.toJson(), json);
    });

    test('fromJson throws for an unsupported JSON shape', () {
      expect(() => ContainerParam.fromJson(42), throwsFormatException);
    });

    test('factories build the id and config forms', () {
      final idParam = ContainerParam.id('c1');
      expect(idParam, isA<ContainerParamId>());
      expect(idParam.toJson(), 'c1');

      final configParam = ContainerParam.config(
        const ContainerParams(
          skills: [
            ContainerSkillParams(
              type: ContainerSkillType.custom,
              skillId: 'my-skill',
            ),
          ],
        ),
      );
      expect(configParam, isA<ContainerParamConfig>());
      expect(configParam.toJson(), {
        'skills': [
          {'type': 'custom', 'skill_id': 'my-skill'},
        ],
      });
    });
  });

  group('ContainerSkill', () {
    test('round-trips from JSON', () {
      final json = {'skill_id': 'pdf', 'type': 'anthropic', 'version': 'v1'};
      final skill = ContainerSkill.fromJson(json);
      expect(skill.skillId, 'pdf');
      expect(skill.type, ContainerSkillType.anthropic);
      expect(skill.version, 'v1');
      expect(skill.toJson(), json);
    });

    test('throws FormatException for missing required fields', () {
      expect(
        () => ContainerSkill.fromJson(const {
          'type': 'anthropic',
          'version': 'v1',
        }),
        throwsFormatException,
      );
    });
  });

  group('Container', () {
    test('round-trips with skills present', () {
      final json = {
        'id': 'container_011CpZohnwH4vuy7gazohgSP',
        'expires_at': '2026-02-20T00:00:00.000Z',
        'skills': [
          {'skill_id': 'pdf', 'type': 'anthropic', 'version': 'latest'},
        ],
      };
      final container = Container.fromJson(json);
      expect(container.id, 'container_011CpZohnwH4vuy7gazohgSP');
      expect(container.skills, hasLength(1));
      expect(container.toJson(), json);
    });

    test('round-trips with skills null (required-but-nullable in spec)', () {
      final json = {
        'id': 'container_123',
        'expires_at': '2026-02-20T00:00:00.000Z',
      };
      final container = Container.fromJson(json);
      expect(container.skills, isNull);
      expect(container.toJson()['skills'], isNull);
    });

    test('copyWith / equality / toString', () {
      final a = Container(id: 'c1', expiresAt: DateTime.utc(2026, 1, 1));
      final b = Container(id: 'c1', expiresAt: DateTime.utc(2026, 1, 1));
      final c = a.copyWith(
        skills: const [
          ContainerSkill(
            skillId: 'pdf',
            type: ContainerSkillType.anthropic,
            version: 'latest',
          ),
        ],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.skills, isNotNull);
      expect(a.toString(), contains('Container'));
    });
  });
}
