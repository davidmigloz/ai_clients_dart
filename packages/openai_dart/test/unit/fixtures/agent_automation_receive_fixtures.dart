import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

class AutomationReceiveFixture {
  const AutomationReceiveFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.requiredKeys,
    required this.nullableKeys,
    required this.parse,
    required this.copy,
  });
  final String schema;
  final Map<String, dynamic> minimal;
  final Map<String, dynamic> full;
  final List<String> requiredKeys;
  final List<String> nullableKeys;
  final AgentJsonModel Function(Map<String, dynamic>) parse;
  final AgentJsonModel Function(AgentJsonModel) copy;
}

class AutomationReceiveCopyFixture {
  const AutomationReceiveCopyFixture({
    required this.name,
    required this.original,
    required this.replacement,
    required this.parse,
    required this.copy,
  });
  final String name;
  final Map<String, dynamic> original;
  final Map<String, dynamic> replacement;
  final AgentJsonModel Function(Map<String, dynamic>) parse;
  final AgentJsonModel Function(AgentJsonModel, AgentJsonModel) copy;
}

Map<String, dynamic> _json(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

final automationReceiveFixtures = <AutomationReceiveFixture>[
  AutomationReceiveFixture(
    schema: 'AutomationCreatedByResourceDeveloper',
    minimal: _json(r'''{"type":"developer"}'''),
    full: _json(r'''{"type":"developer"}'''),
    requiredKeys: const ['type'],
    nullableKeys: const [],
    parse: AgentAutomationDeveloperCreator.fromJson,
    copy: (value) => (value as AgentAutomationDeveloperCreator).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationCreatedByResourceAgent',
    minimal: _json(
      r'''{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE"}''',
    ),
    full: _json(
      r'''{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE"}''',
    ),
    requiredKeys: const ['type', 'session_id', 'tool_call_id'],
    nullableKeys: const [],
    parse: AgentAutomationAgentCreator.fromJson,
    copy: (value) => (value as AgentAutomationAgentCreator).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationEnvironmentResourceNone',
    minimal: _json(r'''{"type":"none"}'''),
    full: _json(r'''{"type":"none"}'''),
    requiredKeys: const ['type'],
    nullableKeys: const [],
    parse: AgentAutomationNoneEnvironmentResource.fromJson,
    copy: (value) =>
        (value as AgentAutomationNoneEnvironmentResource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationEnvironmentResourceOpenaiHosted',
    minimal: _json(
      r'''{"type":"openai_hosted","environment_id":null,"environment_template_id":null,"container_size":null,"packages":null,"network":null,"desktop":null,"capability_directories":null,"skills":null,"plugins":null,"files":null}''',
    ),
    full: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    requiredKeys: const [
      'type',
      'environment_id',
      'environment_template_id',
      'container_size',
      'packages',
      'network',
      'desktop',
      'capability_directories',
      'skills',
      'plugins',
      'files',
    ],
    nullableKeys: const [
      'environment_id',
      'environment_template_id',
      'container_size',
      'packages',
      'network',
      'desktop',
      'capability_directories',
      'skills',
      'plugins',
      'files',
    ],
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (value) =>
        (value as AgentAutomationHostedEnvironmentResource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationEnvironmentResourceSelfHosted',
    minimal: _json(
      r'''{"type":"self_hosted","environment_id":null,"workspace_directory":"PRIVATE","capability_directories":[]}''',
    ),
    full: _json(
      r'''{"type":"self_hosted","environment_id":"PRIVATE","workspace_directory":"PRIVATE","capability_directories":["PRIVATE"]}''',
    ),
    requiredKeys: const [
      'type',
      'environment_id',
      'workspace_directory',
      'capability_directories',
    ],
    nullableKeys: const ['environment_id'],
    parse: AgentAutomationSelfHostedEnvironmentResource.fromJson,
    copy: (value) =>
        (value as AgentAutomationSelfHostedEnvironmentResource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationAgentConfigResource',
    minimal: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":null,"summary":null},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":null,"tools":[],"multi_agent":{"enabled":false,"max_concurrent_subagents":null}}''',
    ),
    full: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    requiredKeys: const [
      'model',
      'reasoning',
      'text',
      'service_tier',
      'instructions',
      'tools',
      'multi_agent',
    ],
    nullableKeys: const ['instructions'],
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (value) => (value as AgentAutomationAgentConfig).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'InputMessageResource-2',
    minimal: _json(r'''{"type":"message","role":"user","content":[]}'''),
    full: _json(
      r'''{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}''',
    ),
    requiredKeys: const ['type', 'role', 'content'],
    nullableKeys: const [],
    parse: AgentAutomationInputMessage.fromJson,
    copy: (value) => (value as AgentAutomationInputMessage).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationTargetResourceExistingSession',
    minimal: _json(
      r'''{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE"}''',
    ),
    full: _json(
      r'''{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE"}''',
    ),
    requiredKeys: const ['type', 'session_id', 'instructions'],
    nullableKeys: const [],
    parse: AgentAutomationExistingSessionTargetResource.fromJson,
    copy: (value) =>
        (value as AgentAutomationExistingSessionTargetResource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationTargetResourceNewSession',
    minimal: _json(
      r'''{"type":"new_session","agent_id":null,"agent":null,"environment":{"type":"none"},"input":[],"vault_ids":[],"metadata":{}}''',
    ),
    full: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    requiredKeys: const [
      'type',
      'agent_id',
      'agent',
      'environment',
      'input',
      'vault_ids',
      'metadata',
    ],
    nullableKeys: const ['agent_id', 'agent'],
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (value) =>
        (value as AgentAutomationNewSessionTargetResource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationResourceOnce',
    minimal: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":null,"agent":null,"environment":{"type":"none"},"input":[],"vault_ids":[],"metadata":{}},"metadata":{},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    full: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    requiredKeys: const [
      'type',
      'id',
      'object',
      'created_at',
      'name',
      'target',
      'metadata',
      'created_by',
      'run_at',
      'status',
    ],
    nullableKeys: const [],
    parse: AgentAutomationOnce.fromJson,
    copy: (value) => (value as AgentAutomationOnce).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationResourcePeriodic',
    minimal: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":null,"agent":null,"environment":{"type":"none"},"input":[],"vault_ids":[],"metadata":{}},"metadata":{},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    full: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    requiredKeys: const [
      'type',
      'id',
      'object',
      'created_at',
      'name',
      'target',
      'metadata',
      'created_by',
      'expression',
      'timezone',
      'status',
    ],
    nullableKeys: const [],
    parse: AgentAutomationPeriodic.fromJson,
    copy: (value) => (value as AgentAutomationPeriodic).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationInvocationErrorResource',
    minimal: _json(r'''{"code":"PRIVATE","message":"PRIVATE"}'''),
    full: _json(r'''{"code":"PRIVATE","message":"PRIVATE"}'''),
    requiredKeys: const ['code', 'message'],
    nullableKeys: const [],
    parse: AgentAutomationInvocationError.fromJson,
    copy: (value) => (value as AgentAutomationInvocationError).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationInvocationSourceResourceManual',
    minimal: _json(r'''{"type":"manual"}'''),
    full: _json(r'''{"type":"manual"}'''),
    requiredKeys: const ['type'],
    nullableKeys: const [],
    parse: AgentAutomationManualInvocationSource.fromJson,
    copy: (value) =>
        (value as AgentAutomationManualInvocationSource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationInvocationSourceResourceAutomation',
    minimal: _json(
      r'''{"type":"automation","automation":{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":null,"agent":null,"environment":{"type":"none"},"input":[],"vault_ids":[],"metadata":{}},"metadata":{},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}}''',
    ),
    full: _json(
      r'''{"type":"automation","automation":{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}}''',
    ),
    requiredKeys: const ['type', 'automation'],
    nullableKeys: const [],
    parse: AgentAutomationScheduledInvocationSource.fromJson,
    copy: (value) =>
        (value as AgentAutomationScheduledInvocationSource).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AutomationInvocationResource',
    minimal: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":null,"session_id":null,"status":"queued","skip_reason":null,"error":null}''',
    ),
    full: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    requiredKeys: const [
      'id',
      'object',
      'automation_id',
      'created_at',
      'source',
      'scheduled_at',
      'session_id',
      'status',
      'skip_reason',
      'error',
    ],
    nullableKeys: const ['scheduled_at', 'session_id', 'skip_reason', 'error'],
    parse: AgentAutomationInvocation.fromJson,
    copy: (value) => (value as AgentAutomationInvocation).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'DeletedAutomationResource',
    minimal: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.deleted","deleted":false}''',
    ),
    full: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.deleted","deleted":false}''',
    ),
    requiredKeys: const ['id', 'object', 'deleted'],
    nullableKeys: const [],
    parse: DeletedAgentAutomation.fromJson,
    copy: (value) => (value as DeletedAgentAutomation).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AgentAutomationList',
    minimal: _json(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    requiredKeys: const ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: const ['first_id', 'last_id'],
    parse: AgentAutomationList.fromJson,
    copy: (value) => (value as AgentAutomationList).copyWith(),
  ),
  AutomationReceiveFixture(
    schema: 'AgentAutomationInvocationList',
    minimal: _json(
      r'''{"object":"list","data":[],"first_id":null,"last_id":null,"has_more":false}''',
    ),
    full: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    requiredKeys: const ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: const ['first_id', 'last_id'],
    parse: AgentAutomationInvocationList.fromJson,
    copy: (value) => (value as AgentAutomationInvocationList).copyWith(),
  ),
];
final automationReceiveCopies = <AutomationReceiveCopyFixture>[
  AutomationReceiveCopyFixture(
    name: 'AutomationCreatedByResourceAgent.session_id',
    original: _json(
      r'''{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE"}''',
    ),
    replacement: _json(
      r'''{"type":"agent","session_id":"PRIVATE-changed","tool_call_id":"PRIVATE"}''',
    ),
    parse: AgentAutomationAgentCreator.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentCreator).copyWith(
          sessionId: (replacement as AgentAutomationAgentCreator).sessionId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationCreatedByResourceAgent.tool_call_id',
    original: _json(
      r'''{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE"}''',
    ),
    replacement: _json(
      r'''{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE-changed"}''',
    ),
    parse: AgentAutomationAgentCreator.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentCreator).copyWith(
          toolCallId: (replacement as AgentAutomationAgentCreator).toolCallId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.environment_id',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":null,"environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          environmentId:
              (replacement as AgentAutomationHostedEnvironmentResource)
                  .environmentId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.environment_template_id',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":null,"container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          environmentTemplateId:
              (replacement as AgentAutomationHostedEnvironmentResource)
                  .environmentTemplateId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.container_size',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":null,"packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          containerSize:
              (replacement as AgentAutomationHostedEnvironmentResource)
                  .containerSize,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.packages',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":null,"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          packages: (replacement as AgentAutomationHostedEnvironmentResource)
              .packages,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.network',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":null,"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          network:
              (replacement as AgentAutomationHostedEnvironmentResource).network,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.desktop',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":null,"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          desktop:
              (replacement as AgentAutomationHostedEnvironmentResource).desktop,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.capability_directories',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":null,"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          capabilityDirectories:
              (replacement as AgentAutomationHostedEnvironmentResource)
                  .capabilityDirectories,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.skills',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":null,"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          skills:
              (replacement as AgentAutomationHostedEnvironmentResource).skills,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.plugins',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":null,"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          plugins:
              (replacement as AgentAutomationHostedEnvironmentResource).plugins,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceOpenaiHosted.files',
    original: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]}''',
    ),
    replacement: _json(
      r'''{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":null}''',
    ),
    parse: AgentAutomationHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationHostedEnvironmentResource).copyWith(
          files:
              (replacement as AgentAutomationHostedEnvironmentResource).files,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceSelfHosted.environment_id',
    original: _json(
      r'''{"type":"self_hosted","environment_id":"PRIVATE","workspace_directory":"PRIVATE","capability_directories":["PRIVATE"]}''',
    ),
    replacement: _json(
      r'''{"type":"self_hosted","environment_id":null,"workspace_directory":"PRIVATE","capability_directories":["PRIVATE"]}''',
    ),
    parse: AgentAutomationSelfHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationSelfHostedEnvironmentResource).copyWith(
          environmentId:
              (replacement as AgentAutomationSelfHostedEnvironmentResource)
                  .environmentId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceSelfHosted.workspace_directory',
    original: _json(
      r'''{"type":"self_hosted","environment_id":"PRIVATE","workspace_directory":"PRIVATE","capability_directories":["PRIVATE"]}''',
    ),
    replacement: _json(
      r'''{"type":"self_hosted","environment_id":"PRIVATE","workspace_directory":"PRIVATE-changed","capability_directories":["PRIVATE"]}''',
    ),
    parse: AgentAutomationSelfHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationSelfHostedEnvironmentResource).copyWith(
          workspaceDirectory:
              (replacement as AgentAutomationSelfHostedEnvironmentResource)
                  .workspaceDirectory,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationEnvironmentResourceSelfHosted.capability_directories',
    original: _json(
      r'''{"type":"self_hosted","environment_id":"PRIVATE","workspace_directory":"PRIVATE","capability_directories":["PRIVATE"]}''',
    ),
    replacement: _json(
      r'''{"type":"self_hosted","environment_id":"PRIVATE","workspace_directory":"PRIVATE","capability_directories":[]}''',
    ),
    parse: AgentAutomationSelfHostedEnvironmentResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationSelfHostedEnvironmentResource).copyWith(
          capabilityDirectories:
              (replacement as AgentAutomationSelfHostedEnvironmentResource)
                  .capabilityDirectories,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.model',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE-changed","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) => (original as AgentAutomationAgentConfig)
        .copyWith(model: (replacement as AgentAutomationAgentConfig).model),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.reasoning',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":null,"summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentConfig).copyWith(
          reasoning: (replacement as AgentAutomationAgentConfig).reasoning,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.text',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"json_schema","schema":{"PRIVATE-key":"PRIVATE"}},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) => (original as AgentAutomationAgentConfig)
        .copyWith(text: (replacement as AgentAutomationAgentConfig).text),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.service_tier',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"default","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentConfig).copyWith(
          serviceTier: (replacement as AgentAutomationAgentConfig).serviceTier,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.instructions',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":null,"tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentConfig).copyWith(
          instructions:
              (replacement as AgentAutomationAgentConfig).instructions,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.tools',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) => (original as AgentAutomationAgentConfig)
        .copyWith(tools: (replacement as AgentAutomationAgentConfig).tools),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.multi_agent',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":true,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentConfig).copyWith(
          multiAgent: (replacement as AgentAutomationAgentConfig).multiAgent,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.compaction',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":true},"experimental":{"time_awareness":false}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentConfig).copyWith(
          compaction: (replacement as AgentAutomationAgentConfig).compaction,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationAgentConfigResource.experimental',
    original: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}}''',
    ),
    replacement: _json(
      r'''{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":true}}''',
    ),
    parse: AgentAutomationAgentConfig.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationAgentConfig).copyWith(
          experimental:
              (replacement as AgentAutomationAgentConfig).experimental,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'InputMessageResource-2.content',
    original: _json(
      r'''{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}''',
    ),
    replacement: _json(r'''{"type":"message","role":"user","content":[]}'''),
    parse: AgentAutomationInputMessage.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInputMessage).copyWith(
          content: (replacement as AgentAutomationInputMessage).content,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceExistingSession.session_id',
    original: _json(
      r'''{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE"}''',
    ),
    replacement: _json(
      r'''{"type":"existing_session","session_id":"PRIVATE-changed","instructions":"PRIVATE"}''',
    ),
    parse: AgentAutomationExistingSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationExistingSessionTargetResource).copyWith(
          sessionId:
              (replacement as AgentAutomationExistingSessionTargetResource)
                  .sessionId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceExistingSession.instructions',
    original: _json(
      r'''{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE"}''',
    ),
    replacement: _json(
      r'''{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE-changed"}''',
    ),
    parse: AgentAutomationExistingSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationExistingSessionTargetResource).copyWith(
          instructions:
              (replacement as AgentAutomationExistingSessionTargetResource)
                  .instructions,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceNewSession.agent_id',
    original: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"type":"new_session","agent_id":null,"agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationNewSessionTargetResource).copyWith(
          agentId:
              (replacement as AgentAutomationNewSessionTargetResource).agentId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceNewSession.agent',
    original: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":null,"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationNewSessionTargetResource).copyWith(
          agent: (replacement as AgentAutomationNewSessionTargetResource).agent,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceNewSession.environment',
    original: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"openai_hosted","environment_id":"PRIVATE","environment_template_id":"PRIVATE","container_size":"small","packages":{"python":["PRIVATE"],"system":["PRIVATE"],"npm":["PRIVATE"]},"network":{"access":"enabled","allowed_domains":["PRIVATE"]},"desktop":{"enabled":false},"capability_directories":["PRIVATE"],"skills":[{"type":"skill_reference","skill_id":"PRIVATE","version":"PRIVATE"}],"plugins":[{"type":"inline","name":"PRIVATE","description":"PRIVATE"}],"files":[{"type":"file_id","file_id":"PRIVATE","path":"PRIVATE"}]},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationNewSessionTargetResource).copyWith(
          environment: (replacement as AgentAutomationNewSessionTargetResource)
              .environment,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceNewSession.input',
    original: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationNewSessionTargetResource).copyWith(
          input: (replacement as AgentAutomationNewSessionTargetResource).input,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceNewSession.vault_ids',
    original: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":[],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationNewSessionTargetResource).copyWith(
          vaultIds:
              (replacement as AgentAutomationNewSessionTargetResource).vaultIds,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationTargetResourceNewSession.metadata',
    original: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{}}''',
    ),
    parse: AgentAutomationNewSessionTargetResource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationNewSessionTargetResource).copyWith(
          metadata:
              (replacement as AgentAutomationNewSessionTargetResource).metadata,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.id',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE-changed","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      id: (replacement as AgentAutomationOnce).id,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.created_at',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":2,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      createdAt: (replacement as AgentAutomationOnce).createdAt,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.name',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE-changed","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      name: (replacement as AgentAutomationOnce).name,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.target',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE"},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      target: (replacement as AgentAutomationOnce).target,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.metadata',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      metadata: (replacement as AgentAutomationOnce).metadata,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.created_by',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE"},"run_at":1,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      createdBy: (replacement as AgentAutomationOnce).createdBy,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.run_at',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":2,"status":"active"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      runAt: (replacement as AgentAutomationOnce).runAt,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourceOnce.status',
    original: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"paused"}''',
    ),
    parse: AgentAutomationOnce.fromJson,
    copy: (original, replacement) => (original as AgentAutomationOnce).copyWith(
      status: (replacement as AgentAutomationOnce).status,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.id',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE-changed","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) => (original as AgentAutomationPeriodic)
        .copyWith(id: (replacement as AgentAutomationPeriodic).id),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.created_at',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":2,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationPeriodic).copyWith(
          createdAt: (replacement as AgentAutomationPeriodic).createdAt,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.name',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE-changed","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) => (original as AgentAutomationPeriodic)
        .copyWith(name: (replacement as AgentAutomationPeriodic).name),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.target',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"existing_session","session_id":"PRIVATE","instructions":"PRIVATE"},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) => (original as AgentAutomationPeriodic)
        .copyWith(target: (replacement as AgentAutomationPeriodic).target),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.metadata',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) => (original as AgentAutomationPeriodic)
        .copyWith(metadata: (replacement as AgentAutomationPeriodic).metadata),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.created_by',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"agent","session_id":"PRIVATE","tool_call_id":"PRIVATE"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationPeriodic).copyWith(
          createdBy: (replacement as AgentAutomationPeriodic).createdBy,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.expression',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE-changed","timezone":"PRIVATE","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationPeriodic).copyWith(
          expression: (replacement as AgentAutomationPeriodic).expression,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.timezone',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE-changed","status":"active"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) => (original as AgentAutomationPeriodic)
        .copyWith(timezone: (replacement as AgentAutomationPeriodic).timezone),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationResourcePeriodic.status',
    original: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}''',
    ),
    replacement: _json(
      r'''{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"paused"}''',
    ),
    parse: AgentAutomationPeriodic.fromJson,
    copy: (original, replacement) => (original as AgentAutomationPeriodic)
        .copyWith(status: (replacement as AgentAutomationPeriodic).status),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationErrorResource.code',
    original: _json(r'''{"code":"PRIVATE","message":"PRIVATE"}'''),
    replacement: _json(r'''{"code":"PRIVATE-changed","message":"PRIVATE"}'''),
    parse: AgentAutomationInvocationError.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocationError).copyWith(
          code: (replacement as AgentAutomationInvocationError).code,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationErrorResource.message',
    original: _json(r'''{"code":"PRIVATE","message":"PRIVATE"}'''),
    replacement: _json(r'''{"code":"PRIVATE","message":"PRIVATE-changed"}'''),
    parse: AgentAutomationInvocationError.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocationError).copyWith(
          message: (replacement as AgentAutomationInvocationError).message,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationSourceResourceAutomation.automation',
    original: _json(
      r'''{"type":"automation","automation":{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}}''',
    ),
    replacement: _json(
      r'''{"type":"automation","automation":{"type":"once","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"run_at":1,"status":"active"}}''',
    ),
    parse: AgentAutomationScheduledInvocationSource.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationScheduledInvocationSource).copyWith(
          automation: (replacement as AgentAutomationScheduledInvocationSource)
              .automation,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.id',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE-changed","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) => (original as AgentAutomationInvocation)
        .copyWith(id: (replacement as AgentAutomationInvocation).id),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.automation_id',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE-changed","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocation).copyWith(
          automationId: (replacement as AgentAutomationInvocation).automationId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.created_at',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":2,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocation).copyWith(
          createdAt: (replacement as AgentAutomationInvocation).createdAt,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.source',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"automation","automation":{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) => (original as AgentAutomationInvocation)
        .copyWith(source: (replacement as AgentAutomationInvocation).source),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.scheduled_at',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":null,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocation).copyWith(
          scheduledAt: (replacement as AgentAutomationInvocation).scheduledAt,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.session_id',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":null,"status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocation).copyWith(
          sessionId: (replacement as AgentAutomationInvocation).sessionId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.status',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"completed","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) => (original as AgentAutomationInvocation)
        .copyWith(status: (replacement as AgentAutomationInvocation).status),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.skip_reason',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":null,"error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocation).copyWith(
          skipReason: (replacement as AgentAutomationInvocation).skipReason,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AutomationInvocationResource.error',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":null}''',
    ),
    parse: AgentAutomationInvocation.fromJson,
    copy: (original, replacement) => (original as AgentAutomationInvocation)
        .copyWith(error: (replacement as AgentAutomationInvocation).error),
  ),
  AutomationReceiveCopyFixture(
    name: 'DeletedAutomationResource.id',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.deleted","deleted":false}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE-changed","object":"agent.automation.deleted","deleted":false}''',
    ),
    parse: DeletedAgentAutomation.fromJson,
    copy: (original, replacement) => (original as DeletedAgentAutomation)
        .copyWith(id: (replacement as DeletedAgentAutomation).id),
  ),
  AutomationReceiveCopyFixture(
    name: 'DeletedAutomationResource.deleted',
    original: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.deleted","deleted":false}''',
    ),
    replacement: _json(
      r'''{"id":"PRIVATE","object":"agent.automation.deleted","deleted":true}''',
    ),
    parse: DeletedAgentAutomation.fromJson,
    copy: (original, replacement) => (original as DeletedAgentAutomation)
        .copyWith(deleted: (replacement as DeletedAgentAutomation).deleted),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationList.data',
    original: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    parse: AgentAutomationList.fromJson,
    copy: (original, replacement) => (original as AgentAutomationList).copyWith(
      data: (replacement as AgentAutomationList).data,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationList.first_id',
    original: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":null,"last_id":"PRIVATE","has_more":false}''',
    ),
    parse: AgentAutomationList.fromJson,
    copy: (original, replacement) => (original as AgentAutomationList).copyWith(
      firstId: (replacement as AgentAutomationList).firstId,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationList.last_id',
    original: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":null,"has_more":false}''',
    ),
    parse: AgentAutomationList.fromJson,
    copy: (original, replacement) => (original as AgentAutomationList).copyWith(
      lastId: (replacement as AgentAutomationList).lastId,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationList.has_more',
    original: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[{"type":"periodic","id":"PRIVATE","object":"agent.automation","created_at":1,"name":"PRIVATE","target":{"type":"new_session","agent_id":"PRIVATE","agent":{"model":"PRIVATE","reasoning":{"effort":"none","summary":"concise"},"text":{"format":{"type":"text"},"verbosity":"low"},"service_tier":"auto","instructions":"PRIVATE","tools":[{"type":"function","name":"PRIVATE","description":"PRIVATE","parameters":{"PRIVATE-key":"PRIVATE"},"defer_loading":false}],"multi_agent":{"enabled":false,"max_concurrent_subagents":1},"compaction":{"async":false},"experimental":{"time_awareness":false}},"environment":{"type":"none"},"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"PRIVATE"}]}],"vault_ids":["PRIVATE"],"metadata":{"PRIVATE-key":"PRIVATE"}},"metadata":{"PRIVATE-key":"PRIVATE"},"created_by":{"type":"developer"},"expression":"PRIVATE","timezone":"PRIVATE","status":"active"}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":true}''',
    ),
    parse: AgentAutomationList.fromJson,
    copy: (original, replacement) => (original as AgentAutomationList).copyWith(
      hasMore: (replacement as AgentAutomationList).hasMore,
    ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationInvocationList.data',
    original: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    parse: AgentAutomationInvocationList.fromJson,
    copy: (original, replacement) => (original as AgentAutomationInvocationList)
        .copyWith(data: (replacement as AgentAutomationInvocationList).data),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationInvocationList.first_id',
    original: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":null,"last_id":"PRIVATE","has_more":false}''',
    ),
    parse: AgentAutomationInvocationList.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocationList).copyWith(
          firstId: (replacement as AgentAutomationInvocationList).firstId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationInvocationList.last_id',
    original: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":null,"has_more":false}''',
    ),
    parse: AgentAutomationInvocationList.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocationList).copyWith(
          lastId: (replacement as AgentAutomationInvocationList).lastId,
        ),
  ),
  AutomationReceiveCopyFixture(
    name: 'AgentAutomationInvocationList.has_more',
    original: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":false}''',
    ),
    replacement: _json(
      r'''{"object":"list","data":[{"id":"PRIVATE","object":"agent.automation.invocation","automation_id":"PRIVATE","created_at":1,"source":{"type":"manual"},"scheduled_at":1,"session_id":"PRIVATE","status":"queued","skip_reason":"pending_delivery","error":{"code":"PRIVATE","message":"PRIVATE"}}],"first_id":"PRIVATE","last_id":"PRIVATE","has_more":true}''',
    ),
    parse: AgentAutomationInvocationList.fromJson,
    copy: (original, replacement) =>
        (original as AgentAutomationInvocationList).copyWith(
          hasMore: (replacement as AgentAutomationInvocationList).hasMore,
        ),
  ),
];
