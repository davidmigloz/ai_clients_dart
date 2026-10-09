import 'dart:convert';
import 'package:test/test.dart';
import '../fixtures/agent_session_wire_fixtures.dart';

void main() {
  test('AgentMessageItemResource.content: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'AgentMessageItemResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['content'] = List<Object?>.filled(
      2001,
      body['content'] is List ? (body['content'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'AgentToolConfigParamFunction.description: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamFunction',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['description'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('AgentToolConfigParamFunction.name: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'AgentToolConfigParamFunction',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['name'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'AgentToolConfigParamMcp.allowed_tools: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamMcp',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['allowed_tools'] = List<Object?>.filled(
        16385,
        body['allowed_tools'] is List
            ? (body['allowed_tools'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'AgentToolConfigParamMcp.connection_origin: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamMcp',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['connection_origin'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'AgentToolConfigParamMcp.credential_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamMcp',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['credential_id'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'AgentToolConfigParamMcp.server_label: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamMcp',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['server_label'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'AgentToolConfigParamWebSearch.allowed_domains: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamWebSearch',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['allowed_domains'] = List<Object?>.filled(
        16385,
        body['allowed_domains'] is List
            ? (body['allowed_domains'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'AgentToolConfigParamWebSearch.context_size: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamWebSearch',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['context_size'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'AgentToolConfigParamWebSearch.mode: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolConfigParamWebSearch',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['mode'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('AgentToolResourceMcp.allowed_tools: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'AgentToolResourceMcp',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['allowed_tools'] = List<Object?>.filled(
      2001,
      body['allowed_tools'] is List
          ? (body['allowed_tools'] as List).first
          : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'AgentToolResourceWebSearch.allowed_domains: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'AgentToolResourceWebSearch',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['allowed_domains'] = List<Object?>.filled(
        2001,
        body['allowed_domains'] is List
            ? (body['allowed_domains'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('AssistantMessageItemResource.content: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'AssistantMessageItemResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['content'] = List<Object?>.filled(
      2001,
      body['content'] is List ? (body['content'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'BrowserAuthenticationFieldValueParam.field_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'BrowserAuthenticationFieldValueParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['field_id'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'BrowserAuthenticationFieldValueParam.value: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'BrowserAuthenticationFieldValueParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['value'] = '🚀' * 16385;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fields: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['fields'] = List<Object?>.filled(
        2001,
        body['fields'] is List ? (body['fields'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.options: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['options'] = List<Object?>.filled(
        2001,
        body['options'] is List ? (body['options'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'BrowserAuthenticationOptionResource.field_ids: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'BrowserAuthenticationOptionResource',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['field_ids'] = List<Object?>.filled(
        2001,
        body['field_ids'] is List ? (body['field_ids'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'ComputerUseApprovalRequestKindResourceBrowserAuthentication.fields: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'ComputerUseApprovalRequestKindResourceBrowserAuthentication',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['fields'] = List<Object?>.filled(
        2001,
        body['fields'] is List ? (body['fields'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'ComputerUseApprovalRequestKindResourceBrowserAuthentication.options: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'ComputerUseApprovalRequestKindResourceBrowserAuthentication',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['options'] = List<Object?>.filled(
        2001,
        body['options'] is List ? (body['options'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam.fields: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['fields'] = List<Object?>.filled(
        7,
        body['fields'] is List ? (body['fields'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam.selected_option: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['selected_option'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'ComputerUseApprovalResponseParamBrowserOriginAccessParam.decision: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'ComputerUseApprovalResponseParamBrowserOriginAccessParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['decision'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('CreateAgentSessionParams.agent_id: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'CreateAgentSessionParams',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['agent_id'] = '🚀' * 65;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('CreateAgentSessionParams.vault_ids: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'CreateAgentSessionParams',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['vault_ids'] = List<Object?>.filled(
      16385,
      body['vault_ids'] is List ? (body['vault_ids'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('CreateSessionEventsParams.events: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'CreateSessionEventsParams',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['events'] = List<Object?>.filled(
      16385,
      body['events'] is List ? (body['events'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'CreateSubagentCallItemResource.content: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'CreateSubagentCallItemResource',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content'] = List<Object?>.filled(
        2001,
        body['content'] is List ? (body['content'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('EnvironmentPackagesParam.npm: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentPackagesParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['npm'] = List<Object?>.filled(
      16385,
      body['npm'] is List ? (body['npm'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('EnvironmentPackagesParam.python: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentPackagesParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['python'] = List<Object?>.filled(
      16385,
      body['python'] is List ? (body['python'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('EnvironmentPackagesParam.system: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentPackagesParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['system'] = List<Object?>.filled(
      16385,
      body['system'] is List ? (body['system'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('EnvironmentPackagesResource.npm: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentPackagesResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['npm'] = List<Object?>.filled(
      16385,
      body['npm'] is List ? (body['npm'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('EnvironmentPackagesResource.python: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentPackagesResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['python'] = List<Object?>.filled(
      16385,
      body['python'] is List ? (body['python'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('EnvironmentPackagesResource.system: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentPackagesResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['system'] = List<Object?>.filled(
      16385,
      body['system'] is List ? (body['system'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'EnvironmentParamOpenaiHosted.capability_directories: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentParamOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['capability_directories'] = List<Object?>.filled(
        16385,
        body['capability_directories'] is List
            ? (body['capability_directories'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentParamOpenaiHosted.container_size: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentParamOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['container_size'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentParamOpenaiHosted.environment_template_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentParamOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['environment_template_id'] = '🚀' * 65;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('EnvironmentParamOpenaiHosted.files: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentParamOpenaiHosted',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['files'] = List<Object?>.filled(
      51,
      body['files'] is List ? (body['files'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('EnvironmentParamOpenaiHosted.plugins: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentParamOpenaiHosted',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['plugins'] = List<Object?>.filled(
      33,
      body['plugins'] is List ? (body['plugins'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'EnvironmentParamOpenaiHosted.setup_commands: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentParamOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['setup_commands'] = List<Object?>.filled(
        17,
        body['setup_commands'] is List
            ? (body['setup_commands'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('EnvironmentParamOpenaiHosted.skills: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'EnvironmentParamOpenaiHosted',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['skills'] = List<Object?>.filled(
      201,
      body['skills'] is List ? (body['skills'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'EnvironmentParamSelfHosted.capability_directories: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentParamSelfHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['capability_directories'] = List<Object?>.filled(
        16385,
        body['capability_directories'] is List
            ? (body['capability_directories'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentParamSelfHosted.workspace_directory: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentParamSelfHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['workspace_directory'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentResourceOpenaiHosted.capability_directories: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentResourceOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['capability_directories'] = List<Object?>.filled(
        2001,
        body['capability_directories'] is List
            ? (body['capability_directories'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentResourceOpenaiHosted.files: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentResourceOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['files'] = List<Object?>.filled(
        51,
        body['files'] is List ? (body['files'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentResourceOpenaiHosted.plugins: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentResourceOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['plugins'] = List<Object?>.filled(
        2001,
        body['plugins'] is List ? (body['plugins'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentResourceOpenaiHosted.skills: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentResourceOpenaiHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['skills'] = List<Object?>.filled(
        2001,
        body['skills'] is List ? (body['skills'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'EnvironmentResourceSelfHosted.capability_directories: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'EnvironmentResourceSelfHosted',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['capability_directories'] = List<Object?>.filled(
        2001,
        body['capability_directories'] is List
            ? (body['capability_directories'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamFileId.file_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamFileId',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['file_id'] = '🚀' * 257;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamFileId.file_id: canonical minLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamFileId',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['file_id'] = '';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamFileId.path: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamFileId',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['path'] = '🚀' * 4097;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamFileId.path: canonical minLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamFileId',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['path'] = '';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamInline.data: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamInline',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['data'] = '🚀' * 6990509;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamInline.path: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamInline',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['path'] = '🚀' * 4097;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileParamInline.path: canonical minLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileParamInline',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['path'] = '';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileResourceFileId.size_bytes: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileResourceFileId',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['size_bytes'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedEnvironmentFileResourceInline.size_bytes: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedEnvironmentFileResourceInline',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['size_bytes'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('HostedPluginParamInline.description: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'HostedPluginParamInline',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['description'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('HostedPluginParamInline.name: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'HostedPluginParamInline',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['name'] = '🚀' * 65;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('HostedPluginParamInline.name: canonical minLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'HostedPluginParamInline',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['name'] = '';
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('HostedSkillParamInline.description: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'HostedSkillParamInline',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['description'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('HostedSkillParamInline.name: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'HostedSkillParamInline',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['name'] = '🚀' * 65;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('HostedSkillParamInline.name: canonical minLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'HostedSkillParamInline',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['name'] = '';
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'HostedSkillParamSkillReference.skill_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedSkillParamSkillReference',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['skill_id'] = '🚀' * 65;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedSkillParamSkillReference.skill_id: canonical minLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedSkillParamSkillReference',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['skill_id'] = '';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'HostedSkillParamSkillReference.version: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'HostedSkillParamSkillReference',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['version'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'InlineCapabilitySourceParamBase64.data: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'InlineCapabilitySourceParamBase64',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['data'] = '🚀' * 70254593;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'InlineCapabilitySourceParamBase64.data: canonical minLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'InlineCapabilitySourceParamBase64',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['data'] = '';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'InputContentParamInputImage.image_url: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'InputContentParamInputImage',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['image_url'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('InputContentParamInputText.text: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'InputContentParamInputText',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['text'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('InputMessageParam.content: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'InputMessageParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['content'] = List<Object?>.filled(
      16385,
      body['content'] is List ? (body['content'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'McpTransportConfigParamHttp.authorization: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'McpTransportConfigParamHttp',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['authorization'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'McpTransportConfigParamHttp.server_url: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'McpTransportConfigParamHttp',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['server_url'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('McpTransportConfigParamStdio.args: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'McpTransportConfigParamStdio',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['args'] = List<Object?>.filled(
      16385,
      body['args'] is List ? (body['args'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'McpTransportConfigParamStdio.command: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'McpTransportConfigParamStdio',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['command'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('McpTransportConfigParamStdio.cwd: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'McpTransportConfigParamStdio',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['cwd'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'McpTransportConfigParamStdio.env_vars: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'McpTransportConfigParamStdio',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['env_vars'] = List<Object?>.filled(
        16385,
        body['env_vars'] is List ? (body['env_vars'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('McpTransportResourceStdio.args: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'McpTransportResourceStdio',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['args'] = List<Object?>.filled(
      2001,
      body['args'] is List ? (body['args'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('McpTransportResourceStdio.env_vars: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'McpTransportResourceStdio',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['env_vars'] = List<Object?>.filled(
      2001,
      body['env_vars'] is List ? (body['env_vars'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('MessageItemResource.content: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'MessageItemResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['content'] = List<Object?>.filled(
      2001,
      body['content'] is List ? (body['content'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'NetworkPolicyParam.access: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'NetworkPolicyParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['access'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('NetworkPolicyParam.blocked_domains: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'NetworkPolicyParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['blocked_domains'] = List<Object?>.filled(
      101,
      body['blocked_domains'] is List
          ? (body['blocked_domains'] as List).first
          : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'NetworkPolicyResource.allowed_domains: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'NetworkPolicyResource',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['allowed_domains'] = List<Object?>.filled(
        2001,
        body['allowed_domains'] is List
            ? (body['allowed_domains'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('ReasoningItemResource.summary: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'ReasoningItemResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['summary'] = List<Object?>.filled(
      2001,
      body['summary'] is List ? (body['summary'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'SendSubagentInputCallItemResource.content: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SendSubagentInputCallItemResource',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content'] = List<Object?>.filled(
        2001,
        body['content'] is List ? (body['content'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionAgentConfigParam.instructions: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionAgentConfigParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['instructions'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('SessionAgentConfigParam.model: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionAgentConfigParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['model'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'SessionAgentConfigParam.service_tier: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionAgentConfigParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['service_tier'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('SessionAgentConfigParam.tools: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionAgentConfigParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['tools'] = List<Object?>.filled(
      16385,
      body['tools'] is List ? (body['tools'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionAgentResource.tools: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionAgentResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['tools'] = List<Object?>.filled(
      2001,
      body['tools'] is List ? (body['tools'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'SessionEventAgentOutputCommandExecutionOutputDelta.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentOutputCommandExecutionOutputDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentOutputCommandExecutionOutputDelta.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentOutputCommandExecutionOutputDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionEnvironmentReset.reset_count: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionEnvironmentReset',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['reset_count'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartAdded.content_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartAdded.content_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartAdded.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartAdded.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartDone.content_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartDone.content_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartDone.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnContentPartDone.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnContentPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnItemAdded.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnItemAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnItemAdded.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnItemAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnItemDone.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnItemDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnItemDone.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnItemDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDelta.content_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDelta.content_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDelta.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDelta.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDone.content_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDone.content_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['content_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDone.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnOutputTextDone.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionEventAgentSessionTurnOutputTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartAdded.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartAdded.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartAdded.summary_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartAdded.summary_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartAdded',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartDone.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartDone.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartDone.summary_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryPartDone.summary_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryPartDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDelta.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDelta.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDelta.summary_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDelta.summary_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDelta',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDone.output_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDone.output_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['output_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDone.summary_index: canonical minimum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = -1;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionEventAgentSessionTurnReasoningSummaryTextDone.summary_index: canonical maximum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema == 'SessionEventAgentSessionTurnReasoningSummaryTextDone',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['summary_index'] = 4294967296;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionInputParamAgentSessionInputComputerUseApprovalRequestResult.request_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) =>
            f.schema ==
            'SessionInputParamAgentSessionInputComputerUseApprovalRequestResult',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['request_id'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionInputParamAgentSessionInputMessage.input: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionInputParamAgentSessionInputMessage',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['input'] = List<Object?>.filled(
        16385,
        body['input'] is List ? (body['input'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionInputParamAgentSessionInputToolResult.call_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionInputParamAgentSessionInputToolResult',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['call_id'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionInputParamAgentSessionInputToolResult.error: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionInputParamAgentSessionInputToolResult',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['error'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'SessionInputParamAgentSessionInputToolResult.turn_id: canonical maxLength boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'SessionInputParamAgentSessionInputToolResult',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['turn_id'] = '🚀' * 1048577;
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test('SessionListResource.data: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionListResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['data'] = List<Object?>.filled(
      2001,
      body['data'] is List ? (body['data'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionResource.required_actions: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['required_actions'] = List<Object?>.filled(
      2001,
      body['required_actions'] is List
          ? (body['required_actions'] as List).first
          : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionResource.vault_ids: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['vault_ids'] = List<Object?>.filled(
      2001,
      body['vault_ids'] is List ? (body['vault_ids'] as List).first : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionSpendControlParam.limit: canonical minimum boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionSpendControlParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['limit'] = 0;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionSpendControlParam.limit: canonical maximum boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionSpendControlParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['limit'] = 4503599627370496;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionSpendControlResource.consumed: canonical minimum boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionSpendControlResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['consumed'] = -1;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionSpendControlResource.limit: canonical minimum boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionSpendControlResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['limit'] = 0;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SessionSpendControlResource.limit: canonical maximum boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SessionSpendControlResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['limit'] = 4503599627370496;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SetupCommandParam.command: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SetupCommandParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['command'] = '🚀' * 65537;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SetupCommandParam.cwd: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SetupCommandParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['cwd'] = '🚀' * 4097;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('SubagentResource.instructions: canonical maxItems boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'SubagentResource',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['instructions'] = List<Object?>.filled(
      2001,
      body['instructions'] is List
          ? (body['instructions'] as List).first
          : null,
    );
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test('UpdateSessionAgentParam.model: canonical maxLength boundary', () {
    final fixture = agentSessionWireFixtures.singleWhere(
      (f) => f.schema == 'UpdateSessionAgentParam',
    );
    final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
    body['model'] = '🚀' * 1048577;
    expect(() => fixture.parse(body), throwsFormatException);
  });
  test(
    'UpdateSessionAgentParam.service_tier: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'UpdateSessionAgentParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['service_tier'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'UpdateSessionReasoningParam.effort: canonical unknown requested enum boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'UpdateSessionReasoningParam',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['effort'] = 'PRIVATE-future';
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'WaitForSubagentsCallItemResource.recipient_agent_ids: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'WaitForSubagentsCallItemResource',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['recipient_agent_ids'] = List<Object?>.filled(
        2001,
        body['recipient_agent_ids'] is List
            ? (body['recipient_agent_ids'] as List).first
            : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
  test(
    'WebSearchActionResourceSearch.queries: canonical maxItems boundary',
    () {
      final fixture = agentSessionWireFixtures.singleWhere(
        (f) => f.schema == 'WebSearchActionResourceSearch',
      );
      final body = jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>;
      body['queries'] = List<Object?>.filled(
        2001,
        body['queries'] is List ? (body['queries'] as List).first : null,
      );
      expect(() => fixture.parse(body), throwsFormatException);
    },
  );
}
