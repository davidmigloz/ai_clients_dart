import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

/// Canonical source fixtures, separate from model serialization.
final agentWireFixtures = <AgentWireFixture>[
  AgentWireFixture(
    schema: 'AgentListResource',
    minimal: jsonDecode(
      r'''{"data":[],"first_id":null,"has_more":false,"last_id":null,"object":"list"}''',
    ),
    full: jsonDecode(
      r'''{"data":[],"first_id":null,"has_more":false,"last_id":null,"object":"list"}''',
    ),
    parse: (value) => AgentList.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'AgentResource',
    minimal: jsonDecode(
      r'''{"created_at":0,"id":"PRIVATE-fixture","instructions":null,"metadata":{},"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"object":"agent","reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[],"updated_at":0}''',
    ),
    full: jsonDecode(
      r'''{"created_at":0,"id":"PRIVATE-fixture","instructions":null,"metadata":{},"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"object":"agent","reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[],"updated_at":0}''',
    ),
    parse: (value) => Agent.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'id',
      'object',
      'created_at',
      'updated_at',
      'name',
      'metadata',
      'model',
      'reasoning',
      'text',
      'service_tier',
      'instructions',
      'tools',
      'multi_agent',
    ],
    nullableKeys: ['instructions', 'name'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'CreateAgentParams',
    minimal: jsonDecode(r'''{"model":"PRIVATE-fixture"}'''),
    full: jsonDecode(
      r'''{"instructions":null,"metadata":null,"model":"PRIVATE-fixture","multi_agent":null,"name":null,"reasoning":null,"service_tier":null,"text":null,"tools":null}''',
    ),
    parse: (value) =>
        CreateAgentRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['model'],
    nullableKeys: [
      'instructions',
      'metadata',
      'multi_agent',
      'name',
      'reasoning',
      'service_tier',
      'text',
      'tools',
    ],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'DeletedAgentResource',
    minimal: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture","object":"agent.deleted"}''',
    ),
    full: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture","object":"agent.deleted"}''',
    ),
    parse: (value) => DeletedAgent.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['id', 'object', 'deleted'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ErrorBodyResource',
    minimal: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['param'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ErrorResponse-2',
    minimal: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['error'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ListOrderParam',
    knownValues: ['asc', 'desc'],
    minimal: jsonDecode(r'''"asc"'''),
    full: jsonDecode(r'''"asc"'''),
    parse: AgentListOrder.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'McpConnectionOriginParam',
    knownValues: ['service', 'environment'],
    minimal: jsonDecode(r'''"service"'''),
    full: jsonDecode(r'''"service"'''),
    parse: AgentMcpConnectionOriginParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'McpConnectionOriginResource',
    knownValues: ['service', 'environment'],
    minimal: jsonDecode(r'''"service"'''),
    full: jsonDecode(r'''"service"'''),
    parse: AgentMcpConnectionOriginResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'MultiAgentConfigCurrentParam',
    minimal: jsonDecode(r'''{"enabled":false}'''),
    full: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    parse: (value) =>
        AgentMultiAgentConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['enabled'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'MultiAgentConfigResource',
    minimal: jsonDecode(
      r'''{"enabled":false,"max_concurrent_subagents":null}''',
    ),
    full: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":null}'''),
    parse: (value) => AgentMultiAgent.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['enabled', 'max_concurrent_subagents'],
    nullableKeys: ['max_concurrent_subagents'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParam',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    parse: (value) => AgentTool.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'name', 'description', 'parameters'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParamComputerUse',
    minimal: jsonDecode(r'''{"type":"computer_use"}'''),
    full: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    parse: (value) =>
        AgentComputerUseTool.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParamFunction',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    parse: (value) =>
        AgentFunctionTool.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'name', 'description', 'parameters'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParamMcp',
    minimal: jsonDecode(
      r'''{"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    full: jsonDecode(
      r'''{"allowed_tools":null,"connection_origin":null,"credential_id":null,"request_metadata":null,"required":false,"server_label":"PRIVATE-fixture","transport":{"headers":null,"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) => AgentMcpTool.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'server_label', 'transport'],
    nullableKeys: [
      'allowed_tools',
      'connection_origin',
      'credential_id',
      'request_metadata',
    ],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParamProgrammaticToolCalling',
    minimal: jsonDecode(r'''{"type":"programmatic_tool_calling"}'''),
    full: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    parse: (value) => AgentProgrammaticToolCallingTool.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParamToolSearch',
    minimal: jsonDecode(r'''{"type":"tool_search"}'''),
    full: jsonDecode(r'''{"type":"tool_search"}'''),
    parse: (value) =>
        AgentToolSearchTool.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolConfigParamWebSearch',
    minimal: jsonDecode(r'''{"type":"web_search"}'''),
    full: jsonDecode(
      r'''{"allowed_domains":null,"context_size":null,"location":null,"mode":null,"type":"web_search"}''',
    ),
    parse: (value) =>
        AgentWebSearchTool.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: ['allowed_domains', 'context_size', 'location', 'mode'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResource',
    minimal: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    parse: (value) =>
        AgentToolResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'type',
      'name',
      'description',
      'parameters',
      'defer_loading',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResourceComputerUse',
    minimal: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    full: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    parse: (value) =>
        AgentComputerUseToolResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'include_screenshots'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResourceFunction',
    minimal: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    parse: (value) =>
        AgentFunctionToolResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'type',
      'name',
      'description',
      'parameters',
      'defer_loading',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResourceMcp',
    minimal: jsonDecode(
      r'''{"allowed_tools":null,"connection_origin":"service","credential_id":null,"request_metadata":{},"required":false,"server_label":"PRIVATE-fixture","transport":{"headers":{},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    full: jsonDecode(
      r'''{"allowed_tools":null,"connection_origin":"service","credential_id":null,"request_metadata":{},"required":false,"server_label":"PRIVATE-fixture","transport":{"headers":{},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentMcpToolResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'type',
      'server_label',
      'credential_id',
      'transport',
      'request_metadata',
      'allowed_tools',
      'required',
      'connection_origin',
    ],
    nullableKeys: ['allowed_tools', 'credential_id'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResourceProgrammaticToolCalling',
    minimal: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    full: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    parse: (value) => AgentProgrammaticToolCallingToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    requiredKeys: ['type', 'enabled'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResourceToolSearch',
    minimal: jsonDecode(r'''{"type":"tool_search"}'''),
    full: jsonDecode(r'''{"type":"tool_search"}'''),
    parse: (value) =>
        AgentToolSearchToolResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedAgentToolResourceWebSearch',
    minimal: jsonDecode(
      r'''{"allowed_domains":null,"context_size":"low","location":null,"mode":"disabled","type":"web_search"}''',
    ),
    full: jsonDecode(
      r'''{"allowed_domains":null,"context_size":"low","location":null,"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) =>
        AgentWebSearchToolResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [
      'type',
      'mode',
      'context_size',
      'allowed_domains',
      'location',
    ],
    nullableKeys: ['allowed_domains', 'location'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedMcpTransportConfigParam',
    minimal: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    full: jsonDecode(
      r'''{"headers":null,"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentMcpTransport.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'server_url'],
    nullableKeys: ['headers'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedMcpTransportConfigParamHttp',
    minimal: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    full: jsonDecode(
      r'''{"headers":null,"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentMcpHttpTransport.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'server_url'],
    nullableKeys: ['headers'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedMcpTransportConfigParamStdio',
    minimal: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","type":"stdio"}''',
    ),
    full: jsonDecode(
      r'''{"args":null,"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":null,"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'command', 'cwd'],
    nullableKeys: ['args', 'env_vars'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'PersistedMcpTransportResource',
    minimal: jsonDecode(
      r'''{"headers":{},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    full: jsonDecode(
      r'''{"headers":{},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentMcpTransportResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'server_url', 'headers'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedMcpTransportResourceHttp',
    minimal: jsonDecode(
      r'''{"headers":{},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    full: jsonDecode(
      r'''{"headers":{},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentMcpHttpTransportResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'server_url', 'headers'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'PersistedMcpTransportResourceStdio',
    minimal: jsonDecode(
      r'''{"args":[],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":[],"type":"stdio"}''',
    ),
    full: jsonDecode(
      r'''{"args":[],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":[],"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentMcpStdioTransportResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'command', 'args', 'cwd', 'env_vars'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ReasoningEffortParam',
    knownValues: ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
    minimal: jsonDecode(r'''"none"'''),
    full: jsonDecode(r'''"none"'''),
    parse: AgentReasoningEffortParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'ReasoningEffortResource',
    knownValues: ['none', 'minimal', 'low', 'medium', 'high', 'xhigh', 'max'],
    minimal: jsonDecode(r'''"none"'''),
    full: jsonDecode(r'''"none"'''),
    parse: AgentReasoningEffortResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ReasoningParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(r'''{"effort":null,"summary":null}'''),
    parse: (value) =>
        AgentReasoningConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: ['effort', 'summary'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'ReasoningResource',
    minimal: jsonDecode(r'''{"effort":null,"summary":null}'''),
    full: jsonDecode(r'''{"effort":null,"summary":null}'''),
    parse: (value) => AgentReasoning.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['effort', 'summary'],
    nullableKeys: ['effort', 'summary'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ReasoningSummaryParam',
    knownValues: ['concise', 'detailed', 'auto'],
    minimal: jsonDecode(r'''"concise"'''),
    full: jsonDecode(r'''"concise"'''),
    parse: AgentReasoningSummaryParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'ReasoningSummaryResource',
    knownValues: ['concise', 'detailed', 'auto'],
    minimal: jsonDecode(r'''"concise"'''),
    full: jsonDecode(r'''"concise"'''),
    parse: AgentReasoningSummaryResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'ServiceTierParam',
    knownValues: ['auto', 'default', 'flex', 'priority', 'fast'],
    minimal: jsonDecode(r'''"auto"'''),
    full: jsonDecode(r'''"auto"'''),
    parse: AgentServiceTierParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'ServiceTierResource',
    knownValues: ['auto', 'default', 'flex', 'priority', 'fast', 'ultrafast'],
    minimal: jsonDecode(r'''"auto"'''),
    full: jsonDecode(r'''"auto"'''),
    parse: AgentServiceTierResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'TextFormatParam',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) => AgentTextFormat.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'TextFormatParamJsonSchema',
    minimal: jsonDecode(r'''{"schema":{},"type":"json_schema"}'''),
    full: jsonDecode(r'''{"schema":{},"type":"json_schema"}'''),
    parse: (value) =>
        AgentJsonSchemaFormat.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'schema'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'TextFormatParamText',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) =>
        AgentPlainTextFormat.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'TextFormatResource',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) =>
        AgentTextFormatResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'TextFormatResourceJsonSchema',
    minimal: jsonDecode(r'''{"schema":{},"type":"json_schema"}'''),
    full: jsonDecode(r'''{"schema":{},"type":"json_schema"}'''),
    parse: (value) =>
        AgentJsonSchemaFormatResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type', 'schema'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'TextFormatResourceText',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) =>
        AgentPlainTextFormatResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'TextParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(r'''{"format":null,"verbosity":null}'''),
    parse: (value) => AgentTextConfig.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: ['format', 'verbosity'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'TextResource',
    minimal: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    full: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    parse: (value) => AgentText.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['format', 'verbosity'],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'UpdateAgentParams',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"instructions":null,"metadata":null,"model":"PRIVATE-fixture","multi_agent":null,"name":null,"reasoning":null,"service_tier":null,"text":null,"tools":null}''',
    ),
    parse: (value) =>
        UpdateAgentRequest.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: [
      'instructions',
      'metadata',
      'multi_agent',
      'name',
      'reasoning',
      'service_tier',
      'text',
      'tools',
    ],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'VerbosityParam',
    knownValues: ['low', 'medium', 'high'],
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentVerbosityParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'VerbosityResource',
    knownValues: ['low', 'medium', 'high'],
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentVerbosityResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'WebSearchContextSizeParam',
    knownValues: ['low', 'medium', 'high'],
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentWebSearchContextSizeParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'WebSearchContextSizeResource',
    knownValues: ['low', 'medium', 'high'],
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentWebSearchContextSizeResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'WebSearchLocationParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"city":null,"country":null,"region":null,"timezone":null}''',
    ),
    parse: (value) =>
        AgentWebSearchLocation.fromJson(value! as Map<String, dynamic>),
    requiredKeys: [],
    nullableKeys: ['city', 'country', 'region', 'timezone'],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'WebSearchLocationResource',
    minimal: jsonDecode(
      r'''{"city":null,"country":null,"region":null,"timezone":null}''',
    ),
    full: jsonDecode(
      r'''{"city":null,"country":null,"region":null,"timezone":null}''',
    ),
    parse: (value) =>
        AgentWebSearchLocationResource.fromJson(value! as Map<String, dynamic>),
    requiredKeys: ['country', 'region', 'city', 'timezone'],
    nullableKeys: ['city', 'country', 'region', 'timezone'],
    writable: false,
  ),
  AgentWireFixture(
    schema: 'WebSearchModeParam',
    knownValues: ['disabled', 'cached', 'live'],
    minimal: jsonDecode(r'''"disabled"'''),
    full: jsonDecode(r'''"disabled"'''),
    parse: AgentWebSearchModeParam.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentWireFixture(
    schema: 'WebSearchModeResource',
    knownValues: ['disabled', 'cached', 'live'],
    minimal: jsonDecode(r'''"disabled"'''),
    full: jsonDecode(r'''"disabled"'''),
    parse: AgentWebSearchModeResource.fromJson,
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
];

/// One declared canonical component and its requiredness corpus.
class AgentWireFixture {
  /// Creates a source fixture.
  const AgentWireFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.parse,
    required this.requiredKeys,
    required this.nullableKeys,
    required this.writable,
    this.knownValues = const [],
  });

  /// Canonical component name.
  final String schema;

  /// Required fields only.
  final Object? minimal;

  /// All declared fields.
  final Object? full;

  /// Actual exported model parser.
  final AgentJsonModel Function(Object?) parse;

  /// Keys required even when null.
  final List<String> requiredKeys;

  /// Fields which admit explicit null.
  final List<String> nullableKeys;

  /// Whether unexpected request fields must fail.
  final bool writable;

  /// Every member of a canonical scalar enum.
  final List<String> knownValues;
}
