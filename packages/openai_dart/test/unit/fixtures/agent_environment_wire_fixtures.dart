import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// Independent canonical values; synthetic secrets only, never read from an API.
final environmentWireFixtures = <EnvironmentWireFixture>[
  EnvironmentWireFixture(
    schema: 'DesktopParam',
    minimal: jsonDecode(r'''{"enabled":false}'''),
    full: jsonDecode(r'''{"enabled":true}'''),
    parse: (value) =>
        AgentSessionDesktopConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['enabled'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'DesktopResource',
    minimal: jsonDecode(r'''{"enabled":false}'''),
    full: jsonDecode(r'''{"enabled":true}'''),
    parse: (value) =>
        AgentSessionDesktopResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['enabled'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentPackagesParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [],
    nullableKeys: ['npm', 'python', 'system'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentPackagesResource',
    minimal: jsonDecode(r'''{"python":[],"system":[],"npm":[]}'''),
    full: jsonDecode(
      r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['python', 'system', 'npm'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'ErrorBodyResource',
    minimal: jsonDecode(
      r'''{"type":"","code":"","message":"PRIVATE-error-message","param":null}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-field","message":"PRIVATE-error-message","param":"PRIVATE-field","type":"PRIVATE-field"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['param'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'ErrorResponse-2',
    minimal: jsonDecode(
      r'''{"error":{"type":"","code":"","message":"PRIVATE-error-message","param":null}}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-field","message":"PRIVATE-error-message","param":"PRIVATE-field","type":"PRIVATE-field"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['error'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedEnvironmentFileParam',
    minimal: jsonDecode(
      r'''{"type":"file_id","file_id":"file_synthetic","path":"/workspace/private-input.txt"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'data', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedEnvironmentFileParamFileId',
    minimal: jsonDecode(
      r'''{"type":"file_id","file_id":"file_synthetic","path":"/workspace/private-input.txt"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'file_id', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedEnvironmentFileParamInline',
    minimal: jsonDecode(
      r'''{"type":"inline","data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'data', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedEnvironmentFileResource',
    minimal: jsonDecode(
      r'''{"type":"file_id","id":"environment_1","file_id":"file_synthetic","path":"/workspace/private-input.txt","size_bytes":0}''',
    ),
    full: jsonDecode(
      r'''{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'id', 'path', 'size_bytes'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedEnvironmentFileResourceFileId',
    minimal: jsonDecode(
      r'''{"type":"file_id","id":"environment_1","file_id":"file_synthetic","path":"/workspace/private-input.txt","size_bytes":0}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'id', 'file_id', 'path', 'size_bytes'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedEnvironmentFileResourceInline',
    minimal: jsonDecode(
      r'''{"type":"inline","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0}''',
    ),
    full: jsonDecode(
      r'''{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'id', 'path', 'size_bytes'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedPluginParam',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"example_capability","description":"PRIVATE-description","source":{"type":"base64","media_type":"application/zip","data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA"}}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) =>
        AgentSessionHostedPluginConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedPluginParamInline',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"example_capability","description":"PRIVATE-description","source":{"type":"base64","media_type":"application/zip","data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA"}}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedPluginResource',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"example_capability","description":"Safe capability description"}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedPluginResourceInline',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"example_capability","description":"Safe capability description"}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedSkillParam',
    minimal: jsonDecode(
      r'''{"type":"skill_reference","skill_id":"skill_synthetic"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) =>
        AgentSessionHostedSkillConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedSkillParamInline',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"example_capability","description":"PRIVATE-description","source":{"type":"base64","media_type":"application/zip","data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA"}}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedSkillParamSkillReference',
    minimal: jsonDecode(
      r'''{"type":"skill_reference","skill_id":"skill_synthetic"}''',
    ),
    full: jsonDecode(
      r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'skill_id'],
    nullableKeys: ['version'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'HostedSkillResource',
    minimal: jsonDecode(
      r'''{"type":"skill_reference","skill_id":"skill_synthetic","version":"latest","name":"example_capability","description":"Safe capability description"}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedSkillResourceInline',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"example_capability","description":"Safe capability description"}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedSkillResourceSkillReference',
    minimal: jsonDecode(
      r'''{"type":"skill_reference","skill_id":"skill_synthetic","version":"latest","name":"example_capability","description":"Safe capability description"}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'skill_id', 'version', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'InlineCapabilitySourceParam',
    minimal: jsonDecode(
      r'''{"type":"base64","media_type":"application/zip","data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"}''',
    ),
    parse: (value) => AgentSessionInlineCapabilitySourceConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'media_type', 'data'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'InlineCapabilitySourceParamBase64',
    minimal: jsonDecode(
      r'''{"type":"base64","media_type":"application/zip","data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"}''',
    ),
    parse: (value) => AgentSessionInlineCapabilitySourceConfigBase64.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'media_type', 'data'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'ListOrderParam',
    minimal: jsonDecode(r'''"asc"'''),
    full: jsonDecode(r'''"desc"'''),
    parse: AgentListOrder.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'NetworkAccessParam',
    minimal: jsonDecode(r'''"enabled"'''),
    full: jsonDecode(r'''"restricted"'''),
    parse: AgentSessionNetworkAccessConfig.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'NetworkAccessResource',
    minimal: jsonDecode(r'''"enabled"'''),
    full: jsonDecode(r'''"restricted"'''),
    parse: AgentSessionNetworkAccessResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'NetworkPolicyParam',
    minimal: jsonDecode(r'''{"access":"enabled"}'''),
    full: jsonDecode(
      r'''{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['access'],
    nullableKeys: ['allowed_domains', 'blocked_domains'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'NetworkPolicyResource',
    minimal: jsonDecode(r'''{"access":"enabled","allowed_domains":[]}'''),
    full: jsonDecode(
      r'''{"access":"restricted","allowed_domains":["api.example.com"]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['access', 'allowed_domains'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'SetupCommandParam',
    minimal: jsonDecode(r'''{"command":""}'''),
    full: jsonDecode(
      r'''{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}''',
    ),
    parse: (value) =>
        AgentSessionSetupCommandConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['command'],
    nullableKeys: ['cwd'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'AgentEnvironmentListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":true,"last_id":"environment_14","object":"list"}''',
    ),
    parse: (value) =>
        AgentEnvironmentList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'CreateAgentEnvironmentParams',
    minimal: jsonDecode(r'''{"environment":{"type":"openai_hosted"}}'''),
    full: jsonDecode(
      r'''{"environment":{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"},"vault_ids":["vault_synthetic"]}''',
    ),
    parse: (value) =>
        CreateAgentEnvironmentRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['environment'],
    nullableKeys: ['vault_ids'],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'CreateEnvironmentParam',
    minimal: jsonDecode(r'''{"type":"openai_hosted"}'''),
    full: jsonDecode(
      r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentPrewarmEnvironment.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [
      'capability_directories',
      'desktop',
      'env',
      'files',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
    ],
    optionalNonnullKeys: ['environment_template_id'],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'CreateEnvironmentParamOpenaiHosted',
    minimal: jsonDecode(r'''{"type":"openai_hosted"}'''),
    full: jsonDecode(
      r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentPrewarmHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [
      'capability_directories',
      'desktop',
      'env',
      'files',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
    ],
    optionalNonnullKeys: ['environment_template_id'],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'CreateEnvironmentTemplateParams',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
    ),
    parse: (value) => CreateAgentEnvironmentTemplateRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [],
    nullableKeys: [
      'capability_directories',
      'desktop',
      'env',
      'files',
      'name',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
    ],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'DeletedEnvironmentTemplateResource',
    minimal: jsonDecode(
      r'''{"id":"environment_template_1","object":"agent.environment.template.deleted","deleted":false}''',
    ),
    full: jsonDecode(
      r'''{"deleted":true,"id":"environment_template_1","object":"agent.environment.template.deleted"}''',
    ),
    parse: (value) => DeletedAgentEnvironmentTemplate.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['id', 'object', 'deleted'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentStatusResource',
    minimal: jsonDecode(r'''"pending"'''),
    full: jsonDecode(r'''"failed"'''),
    parse: AgentEnvironmentStatus.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentTemplateListResource',
    minimal: jsonDecode(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1","object":"list"}''',
    ),
    parse: (value) =>
        AgentEnvironmentTemplateList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentTemplateResource',
    minimal: jsonDecode(
      r'''{"id":"environment_template_1","name":null,"object":"agent.environment.template","created_at":0,"updated_at":0,"packages":{"python":[],"system":[],"npm":[]},"network":{"access":"enabled","allowed_domains":[]},"desktop":{"enabled":false},"capability_directories":[],"skills":[],"plugins":[],"files":[]}''',
    ),
    full: jsonDecode(
      r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
    ),
    parse: (value) =>
        AgentEnvironmentTemplate.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'name',
      'object',
      'created_at',
      'updated_at',
      'packages',
      'network',
      'desktop',
      'capability_directories',
      'skills',
      'plugins',
      'files',
    ],
    nullableKeys: ['name'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentTypeParam',
    minimal: jsonDecode(r'''"openai_hosted"'''),
    full: jsonDecode(r'''"openai_hosted"'''),
    parse: AgentEnvironmentType.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: true,
  ),
  EnvironmentWireFixture(
    schema: 'EnvironmentTypeResource',
    minimal: jsonDecode(r'''"openai_hosted"'''),
    full: jsonDecode(r'''"self_hosted"'''),
    parse: AgentEnvironmentTypeResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedTemplateFileResource',
    minimal: jsonDecode(
      r'''{"type":"file_id","file_id":"file_synthetic","path":"/workspace/private-input.txt"}''',
    ),
    full: jsonDecode(
      r'''{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) =>
        AgentHostedTemplateFile.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'path', 'size_bytes'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedTemplateFileResourceFileId',
    minimal: jsonDecode(
      r'''{"type":"file_id","file_id":"file_synthetic","path":"/workspace/private-input.txt"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"}''',
    ),
    parse: (value) =>
        AgentHostedTemplateFileFileId.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'file_id', 'path'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedTemplateFileResourceInline',
    minimal: jsonDecode(
      r'''{"type":"inline","path":"/workspace/private-input.txt","size_bytes":0}''',
    ),
    full: jsonDecode(
      r'''{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) =>
        AgentHostedTemplateFileInline.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'path', 'size_bytes'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedTemplateSkillResource',
    minimal: jsonDecode(
      r'''{"type":"skill_reference","skill_id":"skill_synthetic","version":null}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"Template café🚀","type":"inline"}''',
    ),
    parse: (value) =>
        AgentHostedTemplateSkill.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedTemplateSkillResourceInline',
    minimal: jsonDecode(
      r'''{"type":"inline","name":"Template café🚀","description":"Safe capability description"}''',
    ),
    full: jsonDecode(
      r'''{"description":"Safe capability description","name":"Template café🚀","type":"inline"}''',
    ),
    parse: (value) =>
        AgentHostedTemplateSkillInline.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'HostedTemplateSkillResourceSkillReference',
    minimal: jsonDecode(
      r'''{"type":"skill_reference","skill_id":"skill_synthetic","version":null}''',
    ),
    full: jsonDecode(
      r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
    ),
    parse: (value) => AgentHostedTemplateSkillSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'skill_id', 'version'],
    nullableKeys: ['version'],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'PublicEnvironmentResource',
    minimal: jsonDecode(
      r'''{"id":"environment_1","object":"agent.environment","type":"openai_hosted","status":"pending","files":[],"skills":[],"plugins":[]}''',
    ),
    full: jsonDecode(
      r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
    ),
    parse: (value) => AgentEnvironment.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'object',
      'type',
      'status',
      'files',
      'skills',
      'plugins',
    ],
    nullableKeys: [],
    optionalNonnullKeys: [],
    writable: false,
  ),
  EnvironmentWireFixture(
    schema: 'UpdateEnvironmentTemplateParams',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
    ),
    parse: (value) => UpdateAgentEnvironmentTemplateRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: [],
    nullableKeys: [
      'capability_directories',
      'desktop',
      'env',
      'files',
      'name',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
    ],
    optionalNonnullKeys: [],
    writable: true,
  ),
];

/// Source requirements and actual exported parser for one schema.
class EnvironmentWireFixture {
  const EnvironmentWireFixture({
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
AgentJsonModel copyEnvironmentFixture(AgentJsonModel model) => switch (model) {
  final AgentEnvironment value => value.copyWith(),
  final AgentEnvironmentList value => value.copyWith(),
  final AgentEnvironmentStatus value => AgentEnvironmentStatus.fromJson(
    value.toJson(),
  ),
  final AgentEnvironmentTemplate value => value.copyWith(),
  final AgentEnvironmentTemplateList value => value.copyWith(),
  final AgentEnvironmentType value => AgentEnvironmentType.fromJson(
    value.toJson(),
  ),
  final AgentEnvironmentTypeResource value =>
    AgentEnvironmentTypeResource.fromJson(value.toJson()),
  final AgentErrorBody value => value.copyWith(),
  final AgentErrorResponse value => value.copyWith(),
  final AgentHostedTemplateFileFileId value => value.copyWith(),
  final AgentHostedTemplateFileInline value => value.copyWith(),
  final AgentHostedTemplateSkillInline value => value.copyWith(),
  final AgentHostedTemplateSkillSkillReference value => value.copyWith(),
  final AgentListOrder value => AgentListOrder.fromJson(value.toJson()),
  final AgentPrewarmHostedEnvironment value => value.copyWith(),
  final AgentSessionDesktopConfig value => value.copyWith(),
  final AgentSessionDesktopResource value => value.copyWith(),
  final AgentSessionEnvironmentPackagesConfig value => value.copyWith(),
  final AgentSessionEnvironmentPackagesResource value => value.copyWith(),
  final AgentSessionHostedEnvironmentFileConfigFileId value => value.copyWith(),
  final AgentSessionHostedEnvironmentFileConfigInline value => value.copyWith(),
  final AgentSessionHostedEnvironmentFileResourceFileId value =>
    value.copyWith(),
  final AgentSessionHostedEnvironmentFileResourceInline value =>
    value.copyWith(),
  final AgentSessionHostedPluginConfigInline value => value.copyWith(),
  final AgentSessionHostedPluginResourceInline value => value.copyWith(),
  final AgentSessionHostedSkillConfigInline value => value.copyWith(),
  final AgentSessionHostedSkillConfigSkillReference value => value.copyWith(),
  final AgentSessionHostedSkillResourceInline value => value.copyWith(),
  final AgentSessionHostedSkillResourceSkillReference value => value.copyWith(),
  final AgentSessionInlineCapabilitySourceConfigBase64 value =>
    value.copyWith(),
  final AgentSessionNetworkAccessConfig value =>
    AgentSessionNetworkAccessConfig.fromJson(value.toJson()),
  final AgentSessionNetworkAccessResource value =>
    AgentSessionNetworkAccessResource.fromJson(value.toJson()),
  final AgentSessionNetworkPolicyConfig value => value.copyWith(),
  final AgentSessionNetworkPolicyResource value => value.copyWith(),
  final AgentSessionSetupCommandConfig value => value.copyWith(),
  final CreateAgentEnvironmentRequest value => value.copyWith(),
  final CreateAgentEnvironmentTemplateRequest value => value.copyWith(),
  final DeletedAgentEnvironmentTemplate value => value.copyWith(),
  final UpdateAgentEnvironmentTemplateRequest value => value.copyWith(),
  _ => throw StateError('Unrecognized source fixture type'),
};
