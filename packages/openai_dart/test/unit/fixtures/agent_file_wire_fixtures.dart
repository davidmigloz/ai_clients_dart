import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// Independent canonical values; synthetic secrets only, never read from an API.
final agentFileWireFixtures = <AgentFileWireFixture>[
  AgentFileWireFixture(
    schema: 'ErrorBodyResource',
    minimal: jsonDecode(
      r'''{"type":"","code":"","message":"PRIVATE-synthetic-error","param":null}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-field","message":"PRIVATE-synthetic-error","param":"PRIVATE-field","type":"PRIVATE-field"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['param'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'ErrorResponse-2',
    minimal: jsonDecode(
      r'''{"error":{"type":"","code":"","message":"PRIVATE-synthetic-error","param":null}}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-field","message":"PRIVATE-synthetic-error","param":"PRIVATE-field","type":"PRIVATE-field"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['error'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'HostedEnvironmentFileParam',
    minimal: jsonDecode(
      r'''{"type":"file_id","file_id":"file_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin"}''',
    ),
    full: jsonDecode(
      r'''{"data":"AP+AAA0KQUJD","path":"/workspace/PRIVATE-file-café🚀.bin","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'data', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  AgentFileWireFixture(
    schema: 'HostedEnvironmentFileParamFileId',
    minimal: jsonDecode(
      r'''{"type":"file_id","file_id":"file_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"file_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'file_id', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  AgentFileWireFixture(
    schema: 'HostedEnvironmentFileParamInline',
    minimal: jsonDecode(
      r'''{"type":"inline","data":"","path":"/workspace/PRIVATE-file-café🚀.bin"}''',
    ),
    full: jsonDecode(
      r'''{"data":"AP+AAA0KQUJD","path":"/workspace/PRIVATE-file-café🚀.bin","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'data', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  AgentFileWireFixture(
    schema: 'ListOrderParam',
    minimal: jsonDecode(r'''"asc"'''),
    full: jsonDecode(r'''"desc"'''),
    parse: AgentListOrder.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  AgentFileWireFixture(
    schema: 'DeletedSessionArtifactResource',
    minimal: jsonDecode(
      r'''{"id":"artifact_synthetic","object":"agent.session.artifact.deleted","deleted":false}''',
    ),
    full: jsonDecode(
      r'''{"deleted":true,"id":"artifact_synthetic","object":"agent.session.artifact.deleted"}''',
    ),
    parse: (value) =>
        DeletedAgentSessionArtifact.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['id', 'object', 'deleted'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'EnvironmentFileListResource',
    minimal: jsonDecode(
      r'''{"object":"page","data":[],"next":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}],"has_more":true,"next":"PRIVATE-opaque-page/%2F?🚀","object":"page"}''',
    ),
    parse: (value) =>
        AgentEnvironmentFileList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'next', 'has_more'],
    nullableKeys: ['next'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'EnvironmentFilePageObjectResource',
    minimal: jsonDecode(r'''"page"'''),
    full: jsonDecode(r'''"page"'''),
    parse: AgentEnvironmentFilePageObject.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'EnvironmentFileResource',
    minimal: jsonDecode(
      r'''{"object":"agent.environment.file","environment_id":"environment_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":0}''',
    ),
    full: jsonDecode(
      r'''{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}''',
    ),
    parse: (value) =>
        AgentEnvironmentFile.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'environment_id', 'path', 'size_bytes'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'SessionArtifactListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
    ),
    parse: (value) =>
        AgentSessionArtifactList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  AgentFileWireFixture(
    schema: 'SessionArtifactResource',
    minimal: jsonDecode(
      r'''{"id":"artifact_synthetic","object":"agent.session.artifact","session_id":"session_synthetic","environment_id":"environment_synthetic","turn_id":"turn_completed","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","size_bytes":0,"created_at":0}''',
    ),
    full: jsonDecode(
      r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
    ),
    parse: (value) =>
        AgentSessionArtifact.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'object',
      'session_id',
      'environment_id',
      'turn_id',
      'path',
      'size_bytes',
      'created_at',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
];

/// Source requirements and actual exported parser for one schema.
class AgentFileWireFixture {
  const AgentFileWireFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.parse,
    required this.requiredKeys,
    required this.nullableKeys,
    required this.optionalNonnullKeys,
    required this.writable,
  });
  final String schema;
  final Object? minimal;
  final Object? full;
  final AgentJsonModel Function(Object?) parse;
  final List<String> requiredKeys;
  final List<String> nullableKeys;
  final List<String> optionalNonnullKeys;
  final bool writable;
}

/// Real typed copies for every concrete fixture branch, including shared values.
AgentJsonModel copyAgentFileFixture(AgentJsonModel model) => switch (model) {
  final AgentEnvironmentFile value => value.copyWith(),
  final AgentEnvironmentFileList value => value.copyWith(),
  final AgentEnvironmentFilePageObject value =>
    AgentEnvironmentFilePageObject.fromJson(value.toJson()),
  final AgentErrorBody value => value.copyWith(),
  final AgentErrorResponse value => value.copyWith(),
  final AgentListOrder value => AgentListOrder.fromJson(value.toJson()),
  final AgentSessionArtifact value => value.copyWith(),
  final AgentSessionArtifactList value => value.copyWith(),
  final AgentSessionHostedEnvironmentFileConfigFileId value => value.copyWith(),
  final AgentSessionHostedEnvironmentFileConfigInline value => value.copyWith(),
  final DeletedAgentSessionArtifact value => value.copyWith(),
  _ => throw StateError('Unrecognized source fixture type'),
};
