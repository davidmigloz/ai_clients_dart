import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_environment_wire_fixtures.dart';

Map<String, dynamic> wire(String n) =>
    jsonDecode(
          jsonEncode(
            environmentWireFixtures.singleWhere((f) => f.schema == n).full,
          ),
        )
        as Map<String, dynamic>;
void main() {
  test('AgentEnvironmentListResource.data: canonical maximum rejection', () {
    final body = wire('AgentEnvironmentListResource');
    body['data'] = List<Object?>.filled(
      2001,
      (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'AgentEnvironmentListResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'CreateAgentEnvironmentParams.vault_ids: canonical maximum rejection',
    () {
      final body = wire('CreateAgentEnvironmentParams');
      body['vault_ids'] = List<Object?>.filled(
        11,
        (body['vault_ids'] as List).isEmpty
            ? ''
            : (body['vault_ids'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'CreateAgentEnvironmentParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.capability_directories: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['capability_directories'] = List<Object?>.filled(
        16385,
        (body['capability_directories'] as List).isEmpty
            ? ''
            : (body['capability_directories'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.env: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['env'] = {for (var i = 0; i < 1025; i++) 'k$i': 'value'};
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.environment_template_id: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['environment_template_id'] = '🚀' * 65;
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.files: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['files'] = List<Object?>.filled(
        51,
        (body['files'] as List).isEmpty ? '' : (body['files'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.plugins: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['plugins'] = List<Object?>.filled(
        33,
        (body['plugins'] as List).isEmpty
            ? ''
            : (body['plugins'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.setup_commands: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['setup_commands'] = List<Object?>.filled(
        17,
        (body['setup_commands'] as List).isEmpty
            ? ''
            : (body['setup_commands'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentParamOpenaiHosted.skills: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentParamOpenaiHosted');
      body['skills'] = List<Object?>.filled(
        201,
        (body['skills'] as List).isEmpty ? '' : (body['skills'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere(
              (f) => f.schema == 'CreateEnvironmentParamOpenaiHosted',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentTemplateParams.capability_directories: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentTemplateParams');
      body['capability_directories'] = List<Object?>.filled(
        16385,
        (body['capability_directories'] as List).isEmpty
            ? ''
            : (body['capability_directories'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('CreateEnvironmentTemplateParams.env: canonical maximum rejection', () {
    final body = wire('CreateEnvironmentTemplateParams');
    body['env'] = {for (var i = 0; i < 1025; i++) 'k$i': 'value'};
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'CreateEnvironmentTemplateParams.files: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentTemplateParams');
      body['files'] = List<Object?>.filled(
        51,
        (body['files'] as List).isEmpty ? '' : (body['files'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('CreateEnvironmentTemplateParams.name: canonical maximum rejection', () {
    final body = wire('CreateEnvironmentTemplateParams');
    body['name'] = '🚀' * 257;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'CreateEnvironmentTemplateParams.plugins: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentTemplateParams');
      body['plugins'] = List<Object?>.filled(
        33,
        (body['plugins'] as List).isEmpty
            ? ''
            : (body['plugins'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentTemplateParams.setup_commands: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentTemplateParams');
      body['setup_commands'] = List<Object?>.filled(
        17,
        (body['setup_commands'] as List).isEmpty
            ? ''
            : (body['setup_commands'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateEnvironmentTemplateParams.skills: canonical maximum rejection',
    () {
      final body = wire('CreateEnvironmentTemplateParams');
      body['skills'] = List<Object?>.filled(
        201,
        (body['skills'] as List).isEmpty ? '' : (body['skills'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'CreateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('EnvironmentPackagesParam.npm: canonical maximum rejection', () {
    final body = wire('EnvironmentPackagesParam');
    body['npm'] = List<Object?>.filled(
      16385,
      (body['npm'] as List).isEmpty ? '' : (body['npm'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentPackagesParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentPackagesParam.python: canonical maximum rejection', () {
    final body = wire('EnvironmentPackagesParam');
    body['python'] = List<Object?>.filled(
      16385,
      (body['python'] as List).isEmpty ? '' : (body['python'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentPackagesParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentPackagesParam.system: canonical maximum rejection', () {
    final body = wire('EnvironmentPackagesParam');
    body['system'] = List<Object?>.filled(
      16385,
      (body['system'] as List).isEmpty ? '' : (body['system'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentPackagesParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentPackagesResource.npm: canonical maximum rejection', () {
    final body = wire('EnvironmentPackagesResource');
    body['npm'] = List<Object?>.filled(
      16385,
      (body['npm'] as List).isEmpty ? '' : (body['npm'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentPackagesResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentPackagesResource.python: canonical maximum rejection', () {
    final body = wire('EnvironmentPackagesResource');
    body['python'] = List<Object?>.filled(
      16385,
      (body['python'] as List).isEmpty ? '' : (body['python'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentPackagesResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentPackagesResource.system: canonical maximum rejection', () {
    final body = wire('EnvironmentPackagesResource');
    body['system'] = List<Object?>.filled(
      16385,
      (body['system'] as List).isEmpty ? '' : (body['system'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentPackagesResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentTemplateListResource.data: canonical maximum rejection', () {
    final body = wire('EnvironmentTemplateListResource');
    body['data'] = List<Object?>.filled(
      2001,
      (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentTemplateListResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'EnvironmentTemplateResource.capability_directories: canonical maximum rejection',
    () {
      final body = wire('EnvironmentTemplateResource');
      body['capability_directories'] = List<Object?>.filled(
        2001,
        (body['capability_directories'] as List).isEmpty
            ? ''
            : (body['capability_directories'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'EnvironmentTemplateResource')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('EnvironmentTemplateResource.files: canonical maximum rejection', () {
    final body = wire('EnvironmentTemplateResource');
    body['files'] = List<Object?>.filled(
      51,
      (body['files'] as List).isEmpty ? '' : (body['files'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentTemplateResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentTemplateResource.plugins: canonical maximum rejection', () {
    final body = wire('EnvironmentTemplateResource');
    body['plugins'] = List<Object?>.filled(
      33,
      (body['plugins'] as List).isEmpty ? '' : (body['plugins'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentTemplateResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('EnvironmentTemplateResource.skills: canonical maximum rejection', () {
    final body = wire('EnvironmentTemplateResource');
    body['skills'] = List<Object?>.filled(
      201,
      (body['skills'] as List).isEmpty ? '' : (body['skills'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentTemplateResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'HostedEnvironmentFileParamFileId.file_id: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamFileId');
      body['file_id'] = '🚀' * 257;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamFileId')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileParamFileId.path: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamFileId');
      body['path'] = '🚀' * 4097;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamFileId')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileParamInline.data: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamInline');
      body['data'] = 'A' * 6990512;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamInline')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileParamInline.path: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamInline');
      body['path'] = '🚀' * 4097;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamInline')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('HostedPluginParamInline.description: canonical maximum rejection', () {
    final body = wire('HostedPluginParamInline');
    body['description'] = '🚀' * 1048577;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'HostedPluginParamInline')
          .parse(body),
      throwsFormatException,
    );
  });
  test('HostedPluginParamInline.name: canonical maximum rejection', () {
    final body = wire('HostedPluginParamInline');
    body['name'] = '🚀' * 65;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'HostedPluginParamInline')
          .parse(body),
      throwsFormatException,
    );
  });
  test('HostedSkillParamInline.description: canonical maximum rejection', () {
    final body = wire('HostedSkillParamInline');
    body['description'] = '🚀' * 1048577;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'HostedSkillParamInline')
          .parse(body),
      throwsFormatException,
    );
  });
  test('HostedSkillParamInline.name: canonical maximum rejection', () {
    final body = wire('HostedSkillParamInline');
    body['name'] = '🚀' * 65;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'HostedSkillParamInline')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'HostedSkillParamSkillReference.skill_id: canonical maximum rejection',
    () {
      final body = wire('HostedSkillParamSkillReference');
      body['skill_id'] = '🚀' * 65;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'HostedSkillParamSkillReference')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedSkillParamSkillReference.version: canonical maximum rejection',
    () {
      final body = wire('HostedSkillParamSkillReference');
      body['version'] = '🚀' * 1048577;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'HostedSkillParamSkillReference')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'InlineCapabilitySourceParamBase64.data: canonical maximum rejection',
    () {
      final body = wire('InlineCapabilitySourceParamBase64');
      body['data'] = 'A' * 70254596;
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'InlineCapabilitySourceParamBase64')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('NetworkPolicyParam.allowed_domains: canonical maximum rejection', () {
    final body = wire('NetworkPolicyParam');
    body['allowed_domains'] = List<Object?>.filled(
      16385,
      (body['allowed_domains'] as List).isEmpty
          ? ''
          : (body['allowed_domains'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'NetworkPolicyParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test('NetworkPolicyParam.blocked_domains: canonical maximum rejection', () {
    final body = wire('NetworkPolicyParam');
    body['blocked_domains'] = List<Object?>.filled(
      101,
      (body['blocked_domains'] as List).isEmpty
          ? ''
          : (body['blocked_domains'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'NetworkPolicyParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'NetworkPolicyResource.allowed_domains: canonical maximum rejection',
    () {
      final body = wire('NetworkPolicyResource');
      body['allowed_domains'] = List<Object?>.filled(
        2001,
        (body['allowed_domains'] as List).isEmpty
            ? ''
            : (body['allowed_domains'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'NetworkPolicyResource')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('PublicEnvironmentResource.files: canonical maximum rejection', () {
    final body = wire('PublicEnvironmentResource');
    body['files'] = List<Object?>.filled(
      2001,
      (body['files'] as List).isEmpty ? '' : (body['files'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'PublicEnvironmentResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('PublicEnvironmentResource.plugins: canonical maximum rejection', () {
    final body = wire('PublicEnvironmentResource');
    body['plugins'] = List<Object?>.filled(
      2001,
      (body['plugins'] as List).isEmpty ? '' : (body['plugins'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'PublicEnvironmentResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('PublicEnvironmentResource.skills: canonical maximum rejection', () {
    final body = wire('PublicEnvironmentResource');
    body['skills'] = List<Object?>.filled(
      2001,
      (body['skills'] as List).isEmpty ? '' : (body['skills'] as List).first,
    );
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'PublicEnvironmentResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('SetupCommandParam.command: canonical maximum rejection', () {
    final body = wire('SetupCommandParam');
    body['command'] = '🚀' * 65537;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'SetupCommandParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test('SetupCommandParam.cwd: canonical maximum rejection', () {
    final body = wire('SetupCommandParam');
    body['cwd'] = '🚀' * 4097;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'SetupCommandParam')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'UpdateEnvironmentTemplateParams.capability_directories: canonical maximum rejection',
    () {
      final body = wire('UpdateEnvironmentTemplateParams');
      body['capability_directories'] = List<Object?>.filled(
        16385,
        (body['capability_directories'] as List).isEmpty
            ? ''
            : (body['capability_directories'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('UpdateEnvironmentTemplateParams.env: canonical maximum rejection', () {
    final body = wire('UpdateEnvironmentTemplateParams');
    body['env'] = {for (var i = 0; i < 1025; i++) 'k$i': 'value'};
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'UpdateEnvironmentTemplateParams.files: canonical maximum rejection',
    () {
      final body = wire('UpdateEnvironmentTemplateParams');
      body['files'] = List<Object?>.filled(
        51,
        (body['files'] as List).isEmpty ? '' : (body['files'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('UpdateEnvironmentTemplateParams.name: canonical maximum rejection', () {
    final body = wire('UpdateEnvironmentTemplateParams');
    body['name'] = '🚀' * 257;
    expect(
      () => environmentWireFixtures
          .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'UpdateEnvironmentTemplateParams.plugins: canonical maximum rejection',
    () {
      final body = wire('UpdateEnvironmentTemplateParams');
      body['plugins'] = List<Object?>.filled(
        33,
        (body['plugins'] as List).isEmpty
            ? ''
            : (body['plugins'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateEnvironmentTemplateParams.setup_commands: canonical maximum rejection',
    () {
      final body = wire('UpdateEnvironmentTemplateParams');
      body['setup_commands'] = List<Object?>.filled(
        17,
        (body['setup_commands'] as List).isEmpty
            ? ''
            : (body['setup_commands'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateEnvironmentTemplateParams.skills: canonical maximum rejection',
    () {
      final body = wire('UpdateEnvironmentTemplateParams');
      body['skills'] = List<Object?>.filled(
        201,
        (body['skills'] as List).isEmpty ? '' : (body['skills'] as List).first,
      );
      expect(
        () => environmentWireFixtures
            .singleWhere((f) => f.schema == 'UpdateEnvironmentTemplateParams')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: parse rejects double.nan',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceFileId.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: copy rejects double.nan',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        body,
      );
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: construct rejects double.nan',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        body,
      );
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceFileId(
          id: original.id,
          fileId: original.fileId,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: parse rejects double.infinity',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceFileId.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: copy rejects double.infinity',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        body,
      );
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: construct rejects double.infinity',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        body,
      );
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceFileId(
          id: original.id,
          fileId: original.fileId,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: parse rejects double.negativeInfinity',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceFileId.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: copy rejects double.negativeInfinity',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        body,
      );
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: construct rejects double.negativeInfinity',
    () {
      final body = wire('HostedEnvironmentFileResourceFileId');
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        body,
      );
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceFileId(
          id: original.id,
          fileId: original.fileId,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: parse rejects double.nan',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceInline.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: copy rejects double.nan',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        body,
      );
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: construct rejects double.nan',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        body,
      );
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceInline(
          id: original.id,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: parse rejects double.infinity',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceInline.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: copy rejects double.infinity',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        body,
      );
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: construct rejects double.infinity',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        body,
      );
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceInline(
          id: original.id,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: parse rejects double.negativeInfinity',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceInline.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: copy rejects double.negativeInfinity',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        body,
      );
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: construct rejects double.negativeInfinity',
    () {
      final body = wire('HostedEnvironmentFileResourceInline');
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        body,
      );
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionHostedEnvironmentFileResourceInline(
          id: original.id,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentEnvironmentTemplate.createdAt: parse rejects double.nan', () {
    final body = wire('EnvironmentTemplateResource');
    const dynamic bad = double.nan;
    expect(
      () => AgentEnvironmentTemplate.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.createdAt: copy rejects double.nan', () {
    final body = wire('EnvironmentTemplateResource');
    final original = AgentEnvironmentTemplate.fromJson(body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.createdAt: construct rejects double.nan', () {
    final body = wire('EnvironmentTemplateResource');
    final original = AgentEnvironmentTemplate.fromJson(body);
    const dynamic bad = double.nan;
    expect(
      () => AgentEnvironmentTemplate(
        id: original.id,
        name: original.name,
        updatedAt: original.updatedAt,
        packages: original.packages,
        network: original.network,
        desktop: original.desktop,
        capabilityDirectories: original.capabilityDirectories,
        skills: original.skills,
        plugins: original.plugins,
        files: original.files,
        createdAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.createdAt: parse rejects double.infinity', () {
    final body = wire('EnvironmentTemplateResource');
    const dynamic bad = double.infinity;
    expect(
      () => AgentEnvironmentTemplate.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.createdAt: copy rejects double.infinity', () {
    final body = wire('EnvironmentTemplateResource');
    final original = AgentEnvironmentTemplate.fromJson(body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentEnvironmentTemplate.createdAt: construct rejects double.infinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      final original = AgentEnvironmentTemplate.fromJson(body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentEnvironmentTemplate(
          id: original.id,
          name: original.name,
          updatedAt: original.updatedAt,
          packages: original.packages,
          network: original.network,
          desktop: original.desktop,
          capabilityDirectories: original.capabilityDirectories,
          skills: original.skills,
          plugins: original.plugins,
          files: original.files,
          createdAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentTemplate.createdAt: parse rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentEnvironmentTemplate.fromJson({...body, 'created_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentTemplate.createdAt: copy rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      final original = AgentEnvironmentTemplate.fromJson(body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(createdAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentTemplate.createdAt: construct rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      final original = AgentEnvironmentTemplate.fromJson(body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentEnvironmentTemplate(
          id: original.id,
          name: original.name,
          updatedAt: original.updatedAt,
          packages: original.packages,
          network: original.network,
          desktop: original.desktop,
          capabilityDirectories: original.capabilityDirectories,
          skills: original.skills,
          plugins: original.plugins,
          files: original.files,
          createdAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentEnvironmentTemplate.updatedAt: parse rejects double.nan', () {
    final body = wire('EnvironmentTemplateResource');
    const dynamic bad = double.nan;
    expect(
      () => AgentEnvironmentTemplate.fromJson({...body, 'updated_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.updatedAt: copy rejects double.nan', () {
    final body = wire('EnvironmentTemplateResource');
    final original = AgentEnvironmentTemplate.fromJson(body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(updatedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.updatedAt: construct rejects double.nan', () {
    final body = wire('EnvironmentTemplateResource');
    final original = AgentEnvironmentTemplate.fromJson(body);
    const dynamic bad = double.nan;
    expect(
      () => AgentEnvironmentTemplate(
        id: original.id,
        name: original.name,
        createdAt: original.createdAt,
        packages: original.packages,
        network: original.network,
        desktop: original.desktop,
        capabilityDirectories: original.capabilityDirectories,
        skills: original.skills,
        plugins: original.plugins,
        files: original.files,
        updatedAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.updatedAt: parse rejects double.infinity', () {
    final body = wire('EnvironmentTemplateResource');
    const dynamic bad = double.infinity;
    expect(
      () => AgentEnvironmentTemplate.fromJson({...body, 'updated_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentTemplate.updatedAt: copy rejects double.infinity', () {
    final body = wire('EnvironmentTemplateResource');
    final original = AgentEnvironmentTemplate.fromJson(body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(updatedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentEnvironmentTemplate.updatedAt: construct rejects double.infinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      final original = AgentEnvironmentTemplate.fromJson(body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentEnvironmentTemplate(
          id: original.id,
          name: original.name,
          createdAt: original.createdAt,
          packages: original.packages,
          network: original.network,
          desktop: original.desktop,
          capabilityDirectories: original.capabilityDirectories,
          skills: original.skills,
          plugins: original.plugins,
          files: original.files,
          updatedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentTemplate.updatedAt: parse rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentEnvironmentTemplate.fromJson({...body, 'updated_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentTemplate.updatedAt: copy rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      final original = AgentEnvironmentTemplate.fromJson(body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(updatedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentTemplate.updatedAt: construct rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentTemplateResource');
      final original = AgentEnvironmentTemplate.fromJson(body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentEnvironmentTemplate(
          id: original.id,
          name: original.name,
          createdAt: original.createdAt,
          packages: original.packages,
          network: original.network,
          desktop: original.desktop,
          capabilityDirectories: original.capabilityDirectories,
          skills: original.skills,
          plugins: original.plugins,
          files: original.files,
          updatedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentHostedTemplateFileInline.sizeBytes: parse rejects double.nan', () {
    final body = wire('HostedTemplateFileResourceInline');
    const dynamic bad = double.nan;
    expect(
      () =>
          AgentHostedTemplateFileInline.fromJson({...body, 'size_bytes': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentHostedTemplateFileInline.sizeBytes: copy rejects double.nan', () {
    final body = wire('HostedTemplateFileResourceInline');
    final original = AgentHostedTemplateFileInline.fromJson(body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(sizeBytes: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentHostedTemplateFileInline.sizeBytes: construct rejects double.nan',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      final original = AgentHostedTemplateFileInline.fromJson(body);
      const dynamic bad = double.nan;
      expect(
        () =>
            AgentHostedTemplateFileInline(path: original.path, sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: parse rejects double.infinity',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      const dynamic bad = double.infinity;
      expect(
        () => AgentHostedTemplateFileInline.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: copy rejects double.infinity',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      final original = AgentHostedTemplateFileInline.fromJson(body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: construct rejects double.infinity',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      final original = AgentHostedTemplateFileInline.fromJson(body);
      const dynamic bad = double.infinity;
      expect(
        () =>
            AgentHostedTemplateFileInline(path: original.path, sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: parse rejects double.negativeInfinity',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentHostedTemplateFileInline.fromJson({
          ...body,
          'size_bytes': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: copy rejects double.negativeInfinity',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      final original = AgentHostedTemplateFileInline.fromJson(body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: construct rejects double.negativeInfinity',
    () {
      final body = wire('HostedTemplateFileResourceInline');
      final original = AgentHostedTemplateFileInline.fromJson(body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () =>
            AgentHostedTemplateFileInline(path: original.path, sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('CreateEnvironmentParam: known openai_hosted source variant', () {
    final body =
        jsonDecode(
              r'''{"capability_directories": ["/workspace/capabilities"], "desktop": {"enabled": true}, "env": {"APP_CONFIG": "PRIVATE-environment-value"}, "environment_template_id": "environment_template_1", "files": [{"file_id": "file_synthetic", "path": "/workspace/private-input.txt", "type": "file_id"}, {"data": "UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK", "path": "/workspace/private-input.txt", "type": "inline"}], "network": {"access": "restricted", "allowed_domains": ["api.example.com"], "blocked_domains": []}, "packages": {"npm": ["lodash@4.17.21"], "python": ["pytest==8.0.0"], "system": ["jq"]}, "plugins": [{"description": "PRIVATE-description", "name": "example_capability", "source": {"data": "UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAIAAAAU0tJTEwubWQtLS0KbmFtZTogZXhhbXBsZV9jYXBhYmlsaXR5CmRlc2NyaXB0aW9uOiBQUklWQVRFLWRlc2NyaXB0aW9uCi0tLQpTeW50aGV0aWMgb2ZmbGluZSBjYXBhYmlsaXR5LgpQSwMEFAAAAAAAAAAhUNTcdRNEAAAARAAAABkAAAAuY29kZXgtcGx1Z2luL3BsdWdpbi5qc29ueyJuYW1lIjogImV4YW1wbGVfY2FwYWJpbGl0eSIsICJkZXNjcmlwdGlvbiI6ICJQUklWQVRFLWRlc2NyaXB0aW9uIn1QSwECFAMUAAAAAAAAACFQeALWFWAAAABgAAAACAAAAAAAAAAAAAAAgAEAAAAAU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAAGQAAAAAAAAAAAAAAgAGGAAAALmNvZGV4LXBsdWdpbi9wbHVnaW4uanNvblBLBQYAAAAAAgACAH0AAAABAQAAAAA=", "media_type": "application/zip", "type": "base64"}, "type": "inline"}], "setup_commands": [{"command": "printf PRIVATE-setup-command", "cwd": "/workspace"}], "skills": [{"description": "PRIVATE-description", "name": "example_capability", "source": {"data": "UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAIAAAAU0tJTEwubWQtLS0KbmFtZTogZXhhbXBsZV9jYXBhYmlsaXR5CmRlc2NyaXB0aW9uOiBQUklWQVRFLWRlc2NyaXB0aW9uCi0tLQpTeW50aGV0aWMgb2ZmbGluZSBjYXBhYmlsaXR5LgpQSwMEFAAAAAAAAAAhUNTcdRNEAAAARAAAABkAAAAuY29kZXgtcGx1Z2luL3BsdWdpbi5qc29ueyJuYW1lIjogImV4YW1wbGVfY2FwYWJpbGl0eSIsICJkZXNjcmlwdGlvbiI6ICJQUklWQVRFLWRlc2NyaXB0aW9uIn1QSwECFAMUAAAAAAAAACFQeALWFWAAAABgAAAACAAAAAAAAAAAAAAAgAEAAAAAU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAAGQAAAAAAAAAAAAAAgAGGAAAALmNvZGV4LXBsdWdpbi9wbHVnaW4uanNvblBLBQYAAAAAAgACAH0AAAABAQAAAAA=", "media_type": "application/zip", "type": "base64"}, "type": "inline"}, {"skill_id": "skill_synthetic", "type": "skill_reference", "version": "latest"}], "type": "openai_hosted"}''',
            )
            as Map<String, dynamic>;
    final value = AgentPrewarmEnvironment.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentPrewarmEnvironment.fromJson({
        ...body,
        'type': 'openai_hosted',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test('CreateEnvironmentParam: unknown privately owned received fallback', () {
    final value = AgentPrewarmEnvironment.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(value.validate, throwsFormatException);
  });
  test('EnvironmentStatusResource: pending', () {
    final v = AgentEnvironmentStatus.fromJson('pending');
    expect(v.toJson(), 'pending');
  });
  test('EnvironmentStatusResource: ready', () {
    final v = AgentEnvironmentStatus.fromJson('ready');
    expect(v.toJson(), 'ready');
  });
  test('EnvironmentStatusResource: connected', () {
    final v = AgentEnvironmentStatus.fromJson('connected');
    expect(v.toJson(), 'connected');
  });
  test('EnvironmentStatusResource: disconnected', () {
    final v = AgentEnvironmentStatus.fromJson('disconnected');
    expect(v.toJson(), 'disconnected');
  });
  test('EnvironmentStatusResource: suspended', () {
    final v = AgentEnvironmentStatus.fromJson('suspended');
    expect(v.toJson(), 'suspended');
  });
  test('EnvironmentStatusResource: expired', () {
    final v = AgentEnvironmentStatus.fromJson('expired');
    expect(v.toJson(), 'expired');
  });
  test('EnvironmentStatusResource: failed', () {
    final v = AgentEnvironmentStatus.fromJson('failed');
    expect(v.toJson(), 'failed');
  });
  test('EnvironmentTypeParam: openai_hosted', () {
    final v = AgentEnvironmentType.fromJson('openai_hosted');
    expect(v.toJson(), 'openai_hosted');
  });
  test('EnvironmentTypeResource: openai_hosted', () {
    final v = AgentEnvironmentTypeResource.fromJson('openai_hosted');
    expect(v.toJson(), 'openai_hosted');
  });
  test('EnvironmentTypeResource: self_hosted', () {
    final v = AgentEnvironmentTypeResource.fromJson('self_hosted');
    expect(v.toJson(), 'self_hosted');
  });
  test('HostedEnvironmentFileParam: known file_id source variant', () {
    final body =
        jsonDecode(
              r'''{"file_id": "file_synthetic", "path": "/workspace/private-input.txt", "type": "file_id"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedEnvironmentFileConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedEnvironmentFileConfig.fromJson({
        ...body,
        'type': 'file_id',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test('HostedEnvironmentFileParam: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"data": "UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK", "path": "/workspace/private-input.txt", "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedEnvironmentFileConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedEnvironmentFileConfig.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test(
    'HostedEnvironmentFileParam: unknown privately owned received fallback',
    () {
      final value = AgentSessionHostedEnvironmentFileConfig.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(value.validate, throwsFormatException);
    },
  );
  test('HostedEnvironmentFileResource: known file_id source variant', () {
    final body =
        jsonDecode(
              r'''{"file_id": "file_synthetic", "id": "environment_1", "path": "/workspace/private-input.txt", "size_bytes": 0, "type": "file_id"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedEnvironmentFileResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedEnvironmentFileResource.fromJson({
        ...body,
        'type': 'file_id',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('HostedEnvironmentFileResource: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"id": "environment_1", "path": "/workspace/private-input.txt", "size_bytes": 0, "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedEnvironmentFileResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedEnvironmentFileResource.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'HostedEnvironmentFileResource: unknown privately owned received fallback',
    () {
      final value = AgentSessionHostedEnvironmentFileResource.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
  test('HostedPluginParam: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"description": "PRIVATE-description", "name": "example_capability", "source": {"data": "UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAIAAAAU0tJTEwubWQtLS0KbmFtZTogZXhhbXBsZV9jYXBhYmlsaXR5CmRlc2NyaXB0aW9uOiBQUklWQVRFLWRlc2NyaXB0aW9uCi0tLQpTeW50aGV0aWMgb2ZmbGluZSBjYXBhYmlsaXR5LgpQSwMEFAAAAAAAAAAhUNTcdRNEAAAARAAAABkAAAAuY29kZXgtcGx1Z2luL3BsdWdpbi5qc29ueyJuYW1lIjogImV4YW1wbGVfY2FwYWJpbGl0eSIsICJkZXNjcmlwdGlvbiI6ICJQUklWQVRFLWRlc2NyaXB0aW9uIn1QSwECFAMUAAAAAAAAACFQeALWFWAAAABgAAAACAAAAAAAAAAAAAAAgAEAAAAAU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAAGQAAAAAAAAAAAAAAgAGGAAAALmNvZGV4LXBsdWdpbi9wbHVnaW4uanNvblBLBQYAAAAAAgACAH0AAAABAQAAAAA=", "media_type": "application/zip", "type": "base64"}, "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedPluginConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedPluginConfig.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test('HostedPluginParam: unknown privately owned received fallback', () {
    final value = AgentSessionHostedPluginConfig.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(value.validate, throwsFormatException);
  });
  test('HostedPluginResource: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"description": "Safe capability description", "name": "example_capability", "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedPluginResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedPluginResource.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('HostedPluginResource: unknown privately owned received fallback', () {
    final value = AgentSessionHostedPluginResource.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
  });
  test('HostedSkillParam: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"description": "PRIVATE-description", "name": "example_capability", "source": {"data": "UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAIAAAAU0tJTEwubWQtLS0KbmFtZTogZXhhbXBsZV9jYXBhYmlsaXR5CmRlc2NyaXB0aW9uOiBQUklWQVRFLWRlc2NyaXB0aW9uCi0tLQpTeW50aGV0aWMgb2ZmbGluZSBjYXBhYmlsaXR5LgpQSwMEFAAAAAAAAAAhUNTcdRNEAAAARAAAABkAAAAuY29kZXgtcGx1Z2luL3BsdWdpbi5qc29ueyJuYW1lIjogImV4YW1wbGVfY2FwYWJpbGl0eSIsICJkZXNjcmlwdGlvbiI6ICJQUklWQVRFLWRlc2NyaXB0aW9uIn1QSwECFAMUAAAAAAAAACFQeALWFWAAAABgAAAACAAAAAAAAAAAAAAAgAEAAAAAU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAAGQAAAAAAAAAAAAAAgAGGAAAALmNvZGV4LXBsdWdpbi9wbHVnaW4uanNvblBLBQYAAAAAAgACAH0AAAABAQAAAAA=", "media_type": "application/zip", "type": "base64"}, "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedSkillConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedSkillConfig.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test('HostedSkillParam: known skill_reference source variant', () {
    final body =
        jsonDecode(
              r'''{"skill_id": "skill_synthetic", "type": "skill_reference", "version": "latest"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedSkillConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedSkillConfig.fromJson({
        ...body,
        'type': 'skill_reference',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test('HostedSkillParam: unknown privately owned received fallback', () {
    final value = AgentSessionHostedSkillConfig.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(value.validate, throwsFormatException);
  });
  test('HostedSkillResource: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"description": "Safe capability description", "name": "example_capability", "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedSkillResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedSkillResource.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('HostedSkillResource: known skill_reference source variant', () {
    final body =
        jsonDecode(
              r'''{"description": "Safe capability description", "name": "example_capability", "skill_id": "skill_synthetic", "type": "skill_reference", "version": "latest"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedSkillResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedSkillResource.fromJson({
        ...body,
        'type': 'skill_reference',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('HostedSkillResource: unknown privately owned received fallback', () {
    final value = AgentSessionHostedSkillResource.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
  });
  test('HostedTemplateFileResource: known file_id source variant', () {
    final body =
        jsonDecode(
              r'''{"file_id": "file_synthetic", "path": "/workspace/private-input.txt", "type": "file_id"}''',
            )
            as Map<String, dynamic>;
    final value = AgentHostedTemplateFile.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentHostedTemplateFile.fromJson({
        ...body,
        'type': 'file_id',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('HostedTemplateFileResource: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"path": "/workspace/private-input.txt", "size_bytes": 0, "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentHostedTemplateFile.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentHostedTemplateFile.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'HostedTemplateFileResource: unknown privately owned received fallback',
    () {
      final value = AgentHostedTemplateFile.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
  test('HostedTemplateSkillResource: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"description": "Safe capability description", "name": "Template caf\u00e9\ud83d\ude80", "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentHostedTemplateSkill.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentHostedTemplateSkill.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('HostedTemplateSkillResource: known skill_reference source variant', () {
    final body =
        jsonDecode(
              r'''{"skill_id": "skill_synthetic", "type": "skill_reference", "version": "latest"}''',
            )
            as Map<String, dynamic>;
    final value = AgentHostedTemplateSkill.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentHostedTemplateSkill.fromJson({
        ...body,
        'type': 'skill_reference',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'HostedTemplateSkillResource: unknown privately owned received fallback',
    () {
      final value = AgentHostedTemplateSkill.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
  test('InlineCapabilitySourceParam: known base64 source variant', () {
    final body =
        jsonDecode(
              r'''{"data": "UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAIAAAAU0tJTEwubWQtLS0KbmFtZTogZXhhbXBsZV9jYXBhYmlsaXR5CmRlc2NyaXB0aW9uOiBQUklWQVRFLWRlc2NyaXB0aW9uCi0tLQpTeW50aGV0aWMgb2ZmbGluZSBjYXBhYmlsaXR5LgpQSwMEFAAAAAAAAAAhUNTcdRNEAAAARAAAABkAAAAuY29kZXgtcGx1Z2luL3BsdWdpbi5qc29ueyJuYW1lIjogImV4YW1wbGVfY2FwYWJpbGl0eSIsICJkZXNjcmlwdGlvbiI6ICJQUklWQVRFLWRlc2NyaXB0aW9uIn1QSwECFAMUAAAAAAAAACFQeALWFWAAAABgAAAACAAAAAAAAAAAAAAAgAEAAAAAU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAAGQAAAAAAAAAAAAAAgAGGAAAALmNvZGV4LXBsdWdpbi9wbHVnaW4uanNvblBLBQYAAAAAAgACAH0AAAABAQAAAAA=", "media_type": "application/zip", "type": "base64"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionInlineCapabilitySourceConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionInlineCapabilitySourceConfig.fromJson({
        ...body,
        'type': 'base64',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test(
    'InlineCapabilitySourceParam: unknown privately owned received fallback',
    () {
      final value = AgentSessionInlineCapabilitySourceConfig.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(value.validate, throwsFormatException);
    },
  );
  test('ListOrderParam: asc', () {
    final v = AgentListOrder.fromJson('asc');
    expect(v.toJson(), 'asc');
  });
  test('ListOrderParam: desc', () {
    final v = AgentListOrder.fromJson('desc');
    expect(v.toJson(), 'desc');
  });
  test('NetworkAccessParam: enabled', () {
    final v = AgentSessionNetworkAccessConfig.fromJson('enabled');
    expect(v.toJson(), 'enabled');
  });
  test('NetworkAccessParam: disabled', () {
    final v = AgentSessionNetworkAccessConfig.fromJson('disabled');
    expect(v.toJson(), 'disabled');
  });
  test('NetworkAccessParam: restricted', () {
    final v = AgentSessionNetworkAccessConfig.fromJson('restricted');
    expect(v.toJson(), 'restricted');
  });
  test('NetworkAccessResource: enabled', () {
    final v = AgentSessionNetworkAccessResource.fromJson('enabled');
    expect(v.toJson(), 'enabled');
  });
  test('NetworkAccessResource: disabled', () {
    final v = AgentSessionNetworkAccessResource.fromJson('disabled');
    expect(v.toJson(), 'disabled');
  });
  test('NetworkAccessResource: restricted', () {
    final v = AgentSessionNetworkAccessResource.fromJson('restricted');
    expect(v.toJson(), 'restricted');
  });

  test(
    'safe nested direct constructor and copy reject hidden source/env/commands',
    () {
      final original = AgentEnvironment.fromJson(
        wire('PublicEnvironmentResource'),
      );
      for (final key in ['source', 'env', 'setup_commands', 'secret_value']) {
        final plugin = AgentSessionHostedPluginResourceInline(
          name: 'safe',
          description: 'safe',
          rawJson: {key: 'PRIVATE'},
        );
        expect(
          () => original.copyWith(plugins: [plugin]),
          throwsFormatException,
        );
        expect(
          () => AgentEnvironment(
            id: 'e',
            type: original.type,
            status: original.status,
            files: const [],
            skills: const [],
            plugins: [plugin],
          ),
          throwsFormatException,
        );
        final template = AgentEnvironmentTemplate.fromJson(
          wire('EnvironmentTemplateResource'),
        );
        expect(
          () => template.copyWith(plugins: [plugin]),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'prewarm request is distinct from session attachment and ten-vault maximum',
    () {
      final environment = AgentPrewarmEnvironment.openaiHosted();
      final req = CreateAgentEnvironmentRequest(
        environment: environment,
        vaultIds: List.filled(10, 'v'),
      );
      expect(req.toJson()['vault_ids'], hasLength(10));
      expect(
        () => req.copyWith(vaultIds: List.filled(11, 'v')),
        throwsFormatException,
      );
      for (final field in ['environment_id', 'container_size']) {
        expect(
          () => AgentPrewarmEnvironment.fromJson({
            'type': 'openai_hosted',
            field: 'value',
          }),
          throwsFormatException,
        );
      }
    },
  );
  test('template tri-state update and omission-driven network default', () {
    expect(UpdateAgentEnvironmentTemplateRequest().toJson(), isEmpty);
    final reset = UpdateAgentEnvironmentTemplateRequest(
      clearNetwork: true,
      clearDesktop: true,
    );
    expect(reset.toJson(), {'network': null, 'desktop': null});
    expect(reset.copyWith().toJson(), reset.toJson());
    expect(AgentPrewarmEnvironment.openaiHosted().toJson(), {
      'type': 'openai_hosted',
    });
  });
  test(
    'network restrictions and plain base64/path configuration errors stay private',
    () {
      expect(
        () => AgentSessionNetworkPolicyConfig(
          access: AgentSessionNetworkAccessConfig.enabled,
          blockedDomains: const ['example.com'],
        ),
        throwsFormatException,
      );
      expect(
        () => AgentSessionNetworkPolicyConfig(
          access: AgentSessionNetworkAccessConfig.restricted,
          allowedDomains: const ['example.com'],
          blockedDomains: const ['other.com'],
        ),
        throwsFormatException,
      );
      expect(
        () => AgentSessionNetworkPolicyConfig(
          access: AgentSessionNetworkAccessConfig.restricted,
          blockedDomains: const ['*.example.com'],
        ),
        throwsFormatException,
      );
      expect(
        () => AgentSessionHostedEnvironmentFileConfig.inline(
          data: 'data:text/plain;base64,QQ==',
          path: '/workspace/a',
        ),
        throwsFormatException,
      );
      expect(
        () => AgentSessionHostedEnvironmentFileConfig.inline(
          data: 'QQ==',
          path: '/workspace/../../a',
        ),
        throwsFormatException,
      );
      expect(
        () => AgentPrewarmEnvironment.openaiHosted(
          capabilityDirectories: const ['relative'],
        ),
        throwsFormatException,
      );
    },
  );
  test('inline decoded five MiB and aggregate ten MiB boundaries', () {
    final at = base64Encode(List.filled(5242880, 0));
    final over = base64Encode(List.filled(5242881, 0));
    // Same encoded length: the schema string bound cannot detect this overflow.
    expect(at.length, over.length);
    final file = AgentSessionHostedEnvironmentFileConfig.inline(
      data: at,
      path: '/workspace/a',
    );
    expect(
      () => AgentSessionHostedEnvironmentFileConfig.inline(
        data: over,
        path: '/workspace/a',
      ),
      throwsFormatException,
    );
    final config = AgentPrewarmHostedEnvironment(files: [file, file]);
    expect(config.files, hasLength(2));
    final one = AgentSessionHostedEnvironmentFileConfig.inline(
      data: 'AA==',
      path: '/workspace/b',
    );
    expect(
      () => config.copyWith(files: [file, file, one]),
      throwsFormatException,
    );
    expect(
      () => CreateAgentEnvironmentTemplateRequest(files: [file, file, one]),
      throwsFormatException,
    );
    expect(
      () => UpdateAgentEnvironmentTemplateRequest(files: [file, file, one]),
      throwsFormatException,
    );
    expect(
      () => AgentSessionHostedEnvironment(files: [file, file, one]),
      throwsFormatException,
    );
  });
}
