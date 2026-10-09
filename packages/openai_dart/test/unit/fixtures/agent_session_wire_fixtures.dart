import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// Independently canonical JSON fixtures; never obtained from Dart serialization.
final agentSessionWireFixtures = <AgentSessionWireFixture>[
  AgentSessionWireFixture(
    schema: 'ErrorBodyResource',
    minimal: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentErrorBody).copyWith(),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['param'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ErrorResponse-2',
    minimal: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentErrorResponse).copyWith(),
    requiredKeys: ['error'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ListOrderParam',
    minimal: jsonDecode(r'''"asc"'''),
    full: jsonDecode(r'''"asc"'''),
    parse: AgentListOrder.fromJson,
    copy: (model) => (model as AgentListOrder).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'McpConnectionOriginParam',
    minimal: jsonDecode(r'''"service"'''),
    full: jsonDecode(r'''"service"'''),
    parse: AgentMcpConnectionOriginParam.fromJson,
    copy: (model) => (model as AgentMcpConnectionOriginParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'McpConnectionOriginResource',
    minimal: jsonDecode(r'''"service"'''),
    full: jsonDecode(r'''"service"'''),
    parse: AgentMcpConnectionOriginResource.fromJson,
    copy: (model) => (model as AgentMcpConnectionOriginResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MultiAgentConfigCurrentParam',
    minimal: jsonDecode(r'''{"enabled":false}'''),
    full: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    parse: (value) =>
        AgentMultiAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentMultiAgentConfig).copyWith(),
    requiredKeys: ['enabled'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'MultiAgentConfigResource',
    minimal: jsonDecode(
      r'''{"enabled":false,"max_concurrent_subagents":null}''',
    ),
    full: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    parse: (value) => AgentMultiAgent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentMultiAgent).copyWith(),
    requiredKeys: ['enabled', 'max_concurrent_subagents'],
    nullableKeys: ['max_concurrent_subagents'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningEffortParam',
    minimal: jsonDecode(r'''"none"'''),
    full: jsonDecode(r'''"none"'''),
    parse: AgentReasoningEffortParam.fromJson,
    copy: (model) => (model as AgentReasoningEffortParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningEffortResource',
    minimal: jsonDecode(r'''"none"'''),
    full: jsonDecode(r'''"none"'''),
    parse: AgentReasoningEffortResource.fromJson,
    copy: (model) => (model as AgentReasoningEffortResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(r'''{"effort":"none","summary":"concise"}'''),
    parse: (value) =>
        AgentReasoningConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentReasoningConfig).copyWith(),
    requiredKeys: [],
    nullableKeys: ['effort', 'summary'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningResource',
    minimal: jsonDecode(r'''{"effort":null,"summary":null}'''),
    full: jsonDecode(r'''{"effort":"none","summary":"concise"}'''),
    parse: (value) => AgentReasoning.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentReasoning).copyWith(),
    requiredKeys: ['effort', 'summary'],
    nullableKeys: ['effort', 'summary'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningSummaryParam',
    minimal: jsonDecode(r'''"concise"'''),
    full: jsonDecode(r'''"concise"'''),
    parse: AgentReasoningSummaryParam.fromJson,
    copy: (model) => (model as AgentReasoningSummaryParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningSummaryResource',
    minimal: jsonDecode(r'''"concise"'''),
    full: jsonDecode(r'''"concise"'''),
    parse: AgentReasoningSummaryResource.fromJson,
    copy: (model) => (model as AgentReasoningSummaryResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ServiceTierParam',
    minimal: jsonDecode(r'''"auto"'''),
    full: jsonDecode(r'''"auto"'''),
    parse: AgentServiceTierParam.fromJson,
    copy: (model) => (model as AgentServiceTierParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ServiceTierResource',
    minimal: jsonDecode(r'''"auto"'''),
    full: jsonDecode(r'''"auto"'''),
    parse: AgentServiceTierResource.fromJson,
    copy: (model) => (model as AgentServiceTierResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TextFormatParam',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) => AgentTextFormat.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentPlainTextFormat).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'TextFormatParamJsonSchema',
    minimal: jsonDecode(r'''{"schema":{},"type":"json_schema"}'''),
    full: jsonDecode(
      r'''{"schema":{"fixture":"PRIVATE-value"},"type":"json_schema"}''',
    ),
    parse: (value) =>
        AgentJsonSchemaFormat.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentJsonSchemaFormat).copyWith(),
    requiredKeys: ['type', 'schema'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'TextFormatParamText',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) =>
        AgentPlainTextFormat.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentPlainTextFormat).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'TextFormatResource',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) =>
        AgentTextFormatResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentPlainTextFormatResource).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TextFormatResourceJsonSchema',
    minimal: jsonDecode(r'''{"schema":{},"type":"json_schema"}'''),
    full: jsonDecode(
      r'''{"schema":{"fixture":"PRIVATE-value"},"type":"json_schema"}''',
    ),
    parse: (value) =>
        AgentJsonSchemaFormatResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentJsonSchemaFormatResource).copyWith(),
    requiredKeys: ['type', 'schema'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TextFormatResourceText',
    minimal: jsonDecode(r'''{"type":"text"}'''),
    full: jsonDecode(r'''{"type":"text"}'''),
    parse: (value) =>
        AgentPlainTextFormatResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentPlainTextFormatResource).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TextParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    parse: (value) => AgentTextConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentTextConfig).copyWith(),
    requiredKeys: [],
    nullableKeys: ['format', 'verbosity'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'TextResource',
    minimal: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    full: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    parse: (value) => AgentText.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentText).copyWith(),
    requiredKeys: ['format', 'verbosity'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'VerbosityParam',
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentVerbosityParam.fromJson,
    copy: (model) => (model as AgentVerbosityParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'VerbosityResource',
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentVerbosityResource.fromJson,
    copy: (model) => (model as AgentVerbosityResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchContextSizeParam',
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentWebSearchContextSizeParam.fromJson,
    copy: (model) => (model as AgentWebSearchContextSizeParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchContextSizeResource',
    minimal: jsonDecode(r'''"low"'''),
    full: jsonDecode(r'''"low"'''),
    parse: AgentWebSearchContextSizeResource.fromJson,
    copy: (model) => (model as AgentWebSearchContextSizeResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchLocationParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocation.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentWebSearchLocation).copyWith(),
    requiredKeys: [],
    nullableKeys: ['city', 'country', 'region', 'timezone'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchLocationResource',
    minimal: jsonDecode(
      r'''{"city":null,"country":null,"region":null,"timezone":null}''',
    ),
    full: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocationResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentWebSearchLocationResource).copyWith(),
    requiredKeys: ['country', 'region', 'city', 'timezone'],
    nullableKeys: ['city', 'country', 'region', 'timezone'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchModeParam',
    minimal: jsonDecode(r'''"disabled"'''),
    full: jsonDecode(r'''"disabled"'''),
    parse: AgentWebSearchModeParam.fromJson,
    copy: (model) => (model as AgentWebSearchModeParam).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchModeResource',
    minimal: jsonDecode(r'''"disabled"'''),
    full: jsonDecode(r'''"disabled"'''),
    parse: AgentWebSearchModeResource.fromJson,
    copy: (model) => (model as AgentWebSearchModeResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'AgentContentResource',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"output_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"output_text"}'''),
    parse: (value) =>
        AgentSessionContent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionOutputTextResource).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'AgentMessageItemResource',
    minimal: jsonDecode(
      r'''{"content":[],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionAgentMessageItemResource).copyWith(),
    requiredKeys: [
      'id',
      'turn_id',
      'type',
      'sender_agent_id',
      'recipient_agent_id',
      'content',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'AgentOutputItemResource',
    minimal: jsonDecode(
      r'''{"content":[],"id":"PRIVATE-fixture","phase":null,"role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionOutputItem.fromJson(value! as Map<String, dynamic>),
    copy: (model) =>
        (model as AgentSessionAssistantMessageItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'role',
      'status',
      'content',
      'phase',
    ],
    nullableKeys: ['phase'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParam',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionTool.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionFunctionTool).copyWith(),
    requiredKeys: ['type', 'name', 'description', 'parameters'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParamComputerUse',
    minimal: jsonDecode(r'''{"type":"computer_use"}'''),
    full: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseTool.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionComputerUseTool).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParamFunction',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionFunctionTool.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionFunctionTool).copyWith(),
    requiredKeys: ['type', 'name', 'description', 'parameters'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParamMcp',
    minimal: jsonDecode(
      r'''{"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    full: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMcpTool).copyWith(),
    requiredKeys: ['type', 'server_label', 'transport'],
    nullableKeys: [
      'allowed_tools',
      'connection_origin',
      'credential_id',
      'request_metadata',
    ],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParamProgrammaticToolCalling',
    minimal: jsonDecode(r'''{"type":"programmatic_tool_calling"}'''),
    full: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    parse: (value) => AgentSessionProgrammaticToolCallingTool.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionProgrammaticToolCallingTool).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParamToolSearch',
    minimal: jsonDecode(r'''{"type":"tool_search"}'''),
    full: jsonDecode(r'''{"type":"tool_search"}'''),
    parse: (value) =>
        AgentSessionToolSearchTool.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionToolSearchTool).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolConfigParamWebSearch',
    minimal: jsonDecode(r'''{"type":"web_search"}'''),
    full: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) =>
        AgentSessionWebSearchTool.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionWebSearchTool).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: ['allowed_domains', 'context_size', 'location', 'mode'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolResource',
    minimal: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionFunctionToolResource).copyWith(),
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
  AgentSessionWireFixture(
    schema: 'AgentToolResourceComputerUse',
    minimal: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    full: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    parse: (value) => AgentSessionComputerUseToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionComputerUseToolResource).copyWith(),
    requiredKeys: ['type', 'include_screenshots'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolResourceFunction',
    minimal: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{},"type":"function"}''',
    ),
    full: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionFunctionToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionFunctionToolResource).copyWith(),
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
  AgentSessionWireFixture(
    schema: 'AgentToolResourceMcp',
    minimal: jsonDecode(
      r'''{"allowed_tools":null,"connection_origin":"service","credential_id":null,"request_metadata":{},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    full: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMcpToolResource).copyWith(),
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
  AgentSessionWireFixture(
    schema: 'AgentToolResourceProgrammaticToolCalling',
    minimal: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    full: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    parse: (value) => AgentSessionProgrammaticToolCallingToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionProgrammaticToolCallingToolResource).copyWith(),
    requiredKeys: ['type', 'enabled'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'AgentToolResourceWebSearch',
    minimal: jsonDecode(
      r'''{"allowed_domains":null,"context_size":"low","location":null,"mode":"disabled","type":"web_search"}''',
    ),
    full: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) => AgentSessionWebSearchToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionWebSearchToolResource).copyWith(),
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
  AgentSessionWireFixture(
    schema: 'AssistantMessageItemResource',
    minimal: jsonDecode(
      r'''{"content":[],"id":"PRIVATE-fixture","phase":null,"role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionAssistantMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionAssistantMessageItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'role',
      'status',
      'content',
      'phase',
    ],
    nullableKeys: ['phase'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'BrowserAuthenticationFieldResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationField.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationField).copyWith(),
    requiredKeys: ['id', 'label', 'type', 'required'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'BrowserAuthenticationFieldValueParam',
    minimal: jsonDecode(
      r'''{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationFieldValue.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationFieldValue).copyWith(),
    requiredKeys: ['field_id', 'value'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'BrowserAuthenticationHistoryRequestKindResource',
    minimal: jsonDecode(
      r'''{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (model) =>
        (model
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(),
    requiredKeys: ['type', 'reason', 'credential_origin', 'fields', 'options'],
    nullableKeys: ['credential_origin', 'reason'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema:
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
    minimal: jsonDecode(
      r'''{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (model) =>
        (model
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(),
    requiredKeys: ['type', 'reason', 'credential_origin', 'fields', 'options'],
    nullableKeys: ['credential_origin', 'reason'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'BrowserAuthenticationOptionResource',
    minimal: jsonDecode(
      r'''{"field_ids":[],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationOption.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationOption).copyWith(),
    requiredKeys: ['id', 'label', 'field_ids'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'BrowserAuthenticationRequestItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationRequestItemResource)
            .copyWith(),
    requiredKeys: ['turn_id', 'request_id', 'request', 'id', 'type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'BrowserOriginAccessDecisionParam',
    minimal: jsonDecode(r'''"approve"'''),
    full: jsonDecode(r'''"approve"'''),
    parse: AgentSessionBrowserOriginAccessDecision.fromJson,
    copy: (model) =>
        (model as AgentSessionBrowserOriginAccessDecision).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'CloseSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionCloseSubagentCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'CommandExecutionItemResource',
    minimal: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":null,"duration_ms":null,"exit_code":null,"id":"PRIVATE-fixture","output":null,"status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    full: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionCommandExecutionItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'command',
      'cwd',
      'status',
      'output',
      'exit_code',
      'duration_ms',
    ],
    nullableKeys: ['cwd', 'duration_ms', 'exit_code', 'output'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerScreenshotResource',
    minimal: jsonDecode(
      r'''{"image_url":"PRIVATE-fixture","type":"computer_screenshot"}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"PRIVATE-fixture","type":"computer_screenshot"}''',
    ),
    parse: (value) => AgentSessionComputerScreenshotResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionComputerScreenshotResource).copyWith(),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalRequestKindResource',
    minimal: jsonDecode(
      r'''{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequestKind.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationRequest).copyWith(),
    requiredKeys: ['type', 'reason', 'credential_origin', 'fields', 'options'],
    nullableKeys: ['credential_origin', 'reason'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalRequestKindResourceBrowserAuthentication',
    minimal: jsonDecode(
      r'''{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationRequest).copyWith(),
    requiredKeys: ['type', 'reason', 'credential_origin', 'fields', 'options'],
    nullableKeys: ['credential_origin', 'reason'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalRequestKindResourceBrowserOriginAccess',
    minimal: jsonDecode(
      r'''{"origin":"PRIVATE-fixture","reason":null,"type":"browser_origin_access"}''',
    ),
    full: jsonDecode(
      r'''{"origin":"PRIVATE-fixture","reason":"PRIVATE-fixture","type":"browser_origin_access"}''',
    ),
    parse: (value) => AgentSessionBrowserOriginAccessRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserOriginAccessRequest).copyWith(),
    requiredKeys: ['type', 'reason', 'origin'],
    nullableKeys: ['reason'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalRequestResultItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":null,"type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (model) =>
        (model as AgentSessionComputerUseApprovalRequestResultItemResource)
            .copyWith(),
    requiredKeys: ['id', 'type', 'turn_id', 'request_id', 'response'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalResponseKindResource',
    minimal: jsonDecode(
      r'''{"action":"submit","selected_option":null,"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationResponseResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationSubmitResource).copyWith(),
    requiredKeys: ['type', 'action', 'selected_option'],
    nullableKeys: ['selected_option'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema:
        'ComputerUseApprovalResponseKindResourceBrowserAuthenticationCancelResource',
    minimal: jsonDecode(
      r'''{"action":"cancel","type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"cancel","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationCancelResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationCancelResource).copyWith(),
    requiredKeys: ['type', 'action'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema:
        'ComputerUseApprovalResponseKindResourceBrowserAuthenticationSubmitResource',
    minimal: jsonDecode(
      r'''{"action":"submit","selected_option":null,"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationSubmitResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationSubmitResource).copyWith(),
    requiredKeys: ['type', 'action', 'selected_option'],
    nullableKeys: ['selected_option'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalResponseParam',
    minimal: jsonDecode(
      r'''{"action":"submit","fields":[],"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationSubmit).copyWith(),
    requiredKeys: ['type', 'action', 'fields'],
    nullableKeys: ['selected_option'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalResponseParamBrowserAuthentication',
    minimal: jsonDecode(
      r'''{"action":"submit","fields":[],"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationSubmit).copyWith(),
    requiredKeys: ['type', 'action', 'fields'],
    nullableKeys: ['selected_option'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalResponseParamBrowserAuthenticationCancelParam',
    minimal: jsonDecode(
      r'''{"action":"cancel","type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"cancel","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationCancel.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationCancel).copyWith(),
    requiredKeys: ['type', 'action'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam',
    minimal: jsonDecode(
      r'''{"action":"submit","fields":[],"type":"browser_authentication"}''',
    ),
    full: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationSubmit.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserAuthenticationSubmit).copyWith(),
    requiredKeys: ['type', 'action', 'fields'],
    nullableKeys: ['selected_option'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseApprovalResponseParamBrowserOriginAccessParam',
    minimal: jsonDecode(
      r'''{"decision":"approve","type":"browser_origin_access"}''',
    ),
    full: jsonDecode(
      r'''{"decision":"approve","type":"browser_origin_access"}''',
    ),
    parse: (value) => AgentSessionBrowserOriginAccessResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionBrowserOriginAccessResponse).copyWith(),
    requiredKeys: ['type', 'decision'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ComputerUseCallItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":null,"status":"in_progress","title":null,"turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionComputerUseCallItemResource).copyWith(),
    requiredKeys: ['type', 'id', 'turn_id', 'title', 'status', 'output'],
    nullableKeys: ['output', 'title'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ContainerSizeParam',
    minimal: jsonDecode(r'''"small"'''),
    full: jsonDecode(r'''"small"'''),
    parse: AgentSessionContainerSizeConfig.fromJson,
    copy: (model) => (model as AgentSessionContainerSizeConfig).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'ContainerSizeResource',
    minimal: jsonDecode(r'''"small"'''),
    full: jsonDecode(r'''"small"'''),
    parse: AgentSessionContainerSizeResource.fromJson,
    copy: (model) => (model as AgentSessionContainerSizeResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'CreateAgentSessionParams',
    minimal: jsonDecode(
      r'''{"environment":{"type":"none"},"agent":{"model":"requested-model"},"input":"PRIVATE-initial input"}''',
    ),
    full: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as CreateAgentSessionRequest).copyWith(),
    requiredKeys: ['environment'],
    nullableKeys: ['input', 'metadata', 'spend_control', 'vault_ids'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'CreateSessionEventsParams',
    minimal: jsonDecode(r'''{"events":[]}'''),
    full: jsonDecode(
      r'''{"events":[{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}]}''',
    ),
    parse: (value) => CreateAgentSessionEventsRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as CreateAgentSessionEventsRequest).copyWith(),
    requiredKeys: ['events'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'CreateSessionInputParam',
    minimal: jsonDecode(r'''"PRIVATE-fixture"'''),
    full: jsonDecode(
      r'''[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}]''',
    ),
    parse: AgentSessionInitialInput.fromJson,
    copy: (model) => switch (model) {
      final AgentSessionInitialInputText value => value.copyWith(),
      final AgentSessionInitialInputItems value => value.copyWith(),
      _ => throw StateError('Unexpected fixture variant'),
    },
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'CreateSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[],"id":"PRIVATE-fixture","model":null,"reasoning_effort":null,"status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    full: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionCreateSubagentCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'agent_id',
      'content',
      'model',
      'reasoning_effort',
    ],
    nullableKeys: ['model', 'reasoning_effort'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'DeletedSessionResource',
    minimal: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture","object":"agent.session.deleted"}''',
    ),
    full: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture","object":"agent.session.deleted"}''',
    ),
    parse: (value) =>
        DeletedAgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as DeletedAgentSession).copyWith(),
    requiredKeys: ['id', 'object', 'deleted'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'DesktopParam',
    minimal: jsonDecode(r'''{"enabled":false}'''),
    full: jsonDecode(r'''{"enabled":false}'''),
    parse: (value) =>
        AgentSessionDesktopConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionDesktopConfig).copyWith(),
    requiredKeys: ['enabled'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'DesktopResource',
    minimal: jsonDecode(r'''{"enabled":false}'''),
    full: jsonDecode(r'''{"enabled":false}'''),
    parse: (value) =>
        AgentSessionDesktopResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionDesktopResource).copyWith(),
    requiredKeys: ['enabled'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'EncryptedContentResource',
    minimal: jsonDecode(
      r'''{"encrypted_content":"PRIVATE-fixture","type":"encrypted_content"}''',
    ),
    full: jsonDecode(
      r'''{"encrypted_content":"PRIVATE-fixture","type":"encrypted_content"}''',
    ),
    parse: (value) => AgentSessionEncryptedContentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEncryptedContentResource).copyWith(),
    requiredKeys: ['type', 'encrypted_content'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentPackagesParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionEnvironmentPackagesConfig).copyWith(),
    requiredKeys: [],
    nullableKeys: ['npm', 'python', 'system'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentPackagesResource',
    minimal: jsonDecode(r'''{"npm":[],"python":[],"system":[]}'''),
    full: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionEnvironmentPackagesResource).copyWith(),
    requiredKeys: ['python', 'system', 'npm'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentParam',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"none"}'''),
    parse: (value) =>
        AgentSessionEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionNoneEnvironment).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentParamNone',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"none"}'''),
    parse: (value) =>
        AgentSessionNoneEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionNoneEnvironment).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentParamOpenaiHosted',
    minimal: jsonDecode(r'''{"type":"openai_hosted"}'''),
    full: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionHostedEnvironment).copyWith(),
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
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentParamSelfHosted',
    minimal: jsonDecode(
      r'''{"type":"self_hosted","workspace_directory":"/workspace/project"}''',
    ),
    full: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"type":"self_hosted","workspace_directory":"/workspace/project"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironment.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionSelfHostedEnvironment).copyWith(),
    requiredKeys: ['type', 'workspace_directory'],
    nullableKeys: ['capability_directories'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentResource',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"none"}'''),
    parse: (value) => AgentSessionEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionNoneEnvironmentResource).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentResourceNone',
    minimal: jsonDecode(r'''{"type":"none"}'''),
    full: jsonDecode(r'''{"type":"none"}'''),
    parse: (value) => AgentSessionNoneEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionNoneEnvironmentResource).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentResourceOpenaiHosted',
    minimal: jsonDecode(
      r'''{"capability_directories":[],"desktop":{"enabled":false},"files":[],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":[]},"packages":{"npm":[],"python":[],"system":[]},"plugins":[],"skills":[],"type":"openai_hosted"}''',
    ),
    full: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'packages',
      'network',
      'desktop',
      'capability_directories',
      'skills',
      'plugins',
      'files',
    ],
    nullableKeys: ['container_size'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'EnvironmentResourceSelfHosted',
    minimal: jsonDecode(
      r'''{"capability_directories":[],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionSelfHostedEnvironmentResource).copyWith(),
    requiredKeys: [
      'type',
      'remote_url',
      'id',
      'workspace_directory',
      'capability_directories',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'FunctionCallItemResource',
    minimal: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    full: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionFunctionCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'call_id',
      'name',
      'arguments',
      'status',
    ],
    nullableKeys: ['arguments'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'FunctionCallOutputItemResource',
    minimal: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":null,"id":"PRIVATE-fixture","output":null,"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    full: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionFunctionCallOutputItemResource).copyWith(),
    requiredKeys: [
      'id',
      'turn_id',
      'type',
      'call_id',
      'status',
      'output',
      'error',
    ],
    nullableKeys: ['error', 'output'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'FunctionCallOutputParam',
    minimal: jsonDecode(r'''"PRIVATE-fixture"'''),
    full: jsonDecode(r'''[{"text":"PRIVATE-fixture","type":"input_text"}]'''),
    parse: AgentSessionFunctionOutput.fromJson,
    copy: (model) => switch (model) {
      final AgentSessionFunctionOutputText value => value.copyWith(),
      final AgentSessionFunctionOutputItems value => value.copyWith(),
      _ => throw StateError('Unexpected fixture variant'),
    },
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'FunctionCallOutputResource',
    minimal: jsonDecode(r'''"PRIVATE-fixture"'''),
    full: jsonDecode(r'''[{"text":"PRIVATE-fixture","type":"input_text"}]'''),
    parse: AgentSessionFunctionOutputResource.fromJson,
    copy: (model) => switch (model) {
      final AgentSessionFunctionOutputResourceText value => value.copyWith(),
      final AgentSessionFunctionOutputResourceItems value => value.copyWith(),
      _ => throw StateError('Unexpected fixture variant'),
    },
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'FunctionCallStatusResource',
    minimal: jsonDecode(r'''"in_progress"'''),
    full: jsonDecode(r'''"in_progress"'''),
    parse: AgentSessionFunctionCallStatusResource.fromJson,
    copy: (model) =>
        (model as AgentSessionFunctionCallStatusResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedEnvironmentFileParam',
    minimal: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentFileConfigFileId).copyWith(),
    requiredKeys: ['type', 'file_id', 'path'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedEnvironmentFileParamFileId',
    minimal: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentFileConfigFileId).copyWith(),
    requiredKeys: ['type', 'file_id', 'path'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedEnvironmentFileParamInline',
    minimal: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","path":"/workspace/input.txt","type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","path":"/workspace/input.txt","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentFileConfigInline).copyWith(),
    requiredKeys: ['type', 'data', 'path'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedEnvironmentFileResource',
    minimal: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(),
    requiredKeys: ['type', 'id', 'file_id', 'path', 'size_bytes'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedEnvironmentFileResourceFileId',
    minimal: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    full: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(),
    requiredKeys: ['type', 'id', 'file_id', 'path', 'size_bytes'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedEnvironmentFileResourceInline',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedEnvironmentFileResourceInline).copyWith(),
    requiredKeys: ['type', 'id', 'path', 'size_bytes'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedPluginParam',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) =>
        AgentSessionHostedPluginConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionHostedPluginConfigInline).copyWith(),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedPluginParamInline',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionHostedPluginConfigInline).copyWith(),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedPluginResource',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedPluginResourceInline).copyWith(),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedPluginResourceInline',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedPluginResourceInline).copyWith(),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedSkillParam',
    minimal: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference"}''',
    ),
    full: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionHostedSkillConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) =>
        (model as AgentSessionHostedSkillConfigSkillReference).copyWith(),
    requiredKeys: ['type', 'skill_id'],
    nullableKeys: ['version'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedSkillParamInline',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionHostedSkillConfigInline).copyWith(),
    requiredKeys: ['type', 'name', 'description', 'source'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedSkillParamSkillReference',
    minimal: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference"}''',
    ),
    full: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedSkillConfigSkillReference).copyWith(),
    requiredKeys: ['type', 'skill_id'],
    nullableKeys: ['version'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'HostedSkillResource',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedSkillResourceSkillReference).copyWith(),
    requiredKeys: ['type', 'skill_id', 'version', 'name', 'description'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedSkillResourceInline',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedSkillResourceInline).copyWith(),
    requiredKeys: ['type', 'name', 'description'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'HostedSkillResourceSkillReference',
    minimal: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionHostedSkillResourceSkillReference).copyWith(),
    requiredKeys: ['type', 'skill_id', 'version', 'name', 'description'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'InlineCapabilitySourceParam',
    minimal: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"}''',
    ),
    parse: (value) => AgentSessionInlineCapabilitySourceConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInlineCapabilitySourceConfigBase64).copyWith(),
    requiredKeys: ['type', 'media_type', 'data'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'InlineCapabilitySourceParamBase64',
    minimal: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"}''',
    ),
    full: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"}''',
    ),
    parse: (value) => AgentSessionInlineCapabilitySourceConfigBase64.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInlineCapabilitySourceConfigBase64).copyWith(),
    requiredKeys: ['type', 'media_type', 'data'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'InputContentParam',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    parse: (value) =>
        AgentSessionInputContent.fromJson(value! as Map<String, dynamic>),
    copy: (model) =>
        (model as AgentSessionInputContentConfigInputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'InputContentParamInputImage',
    minimal: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionInputContentConfigInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInputContentConfigInputImage).copyWith(),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'InputContentParamInputText',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    parse: (value) => AgentSessionInputContentConfigInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInputContentConfigInputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'InputContentResource',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    parse: (value) => AgentSessionInputContentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInputContentResourceInputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'InputContentResourceInputImage',
    minimal: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionInputContentResourceInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInputContentResourceInputImage).copyWith(),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'InputContentResourceInputText',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    parse: (value) => AgentSessionInputContentResourceInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInputContentResourceInputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'InputMessageParam',
    minimal: jsonDecode(r'''{"content":[],"role":"user"}'''),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionInputMessage.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionInputMessage).copyWith(),
    requiredKeys: ['role', 'content'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'InputTokensDetailsResource-2',
    minimal: jsonDecode(r'''{"cached_tokens":0}'''),
    full: jsonDecode(r'''{"cached_tokens":0}'''),
    parse: (value) => AgentSessionInputTokensDetailsResourceDetails.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInputTokensDetailsResourceDetails).copyWith(),
    requiredKeys: ['cached_tokens'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'InterruptSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionInterruptSubagentCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'McpCallItemResource',
    minimal: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":null,"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":null,"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    full: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionMcpCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'server_label',
      'name',
      'arguments',
      'status',
      'output',
      'error',
    ],
    nullableKeys: ['arguments', 'error', 'output'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'McpTransportConfigParam',
    minimal: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    full: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMcpHttpTransport).copyWith(),
    requiredKeys: ['type', 'server_url'],
    nullableKeys: ['authorization', 'headers'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'McpTransportConfigParamHttp',
    minimal: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    full: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpHttpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMcpHttpTransport).copyWith(),
    requiredKeys: ['type', 'server_url'],
    nullableKeys: ['authorization', 'headers'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'McpTransportConfigParamStdio',
    minimal: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","type":"stdio"}''',
    ),
    full: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentSessionMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMcpStdioTransport).copyWith(),
    requiredKeys: ['type', 'command', 'cwd'],
    nullableKeys: ['args', 'env', 'env_vars'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'McpTransportResource',
    minimal: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    full: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    parse: (value) => AgentSessionMcpTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionMcpHttpTransportResource).copyWith(),
    requiredKeys: ['type', 'server_url'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'McpTransportResourceHttp',
    minimal: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    full: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    parse: (value) => AgentSessionMcpHttpTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionMcpHttpTransportResource).copyWith(),
    requiredKeys: ['type', 'server_url'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'McpTransportResourceStdio',
    minimal: jsonDecode(
      r'''{"args":[],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":[],"type":"stdio"}''',
    ),
    full: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) => AgentSessionMcpStdioTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionMcpStdioTransportResource).copyWith(),
    requiredKeys: ['type', 'command', 'args', 'cwd', 'env_vars'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MessageContentResource',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    parse: (value) =>
        AgentSessionMessageContent.fromJson(value! as Map<String, dynamic>),
    copy: (model) =>
        (model as AgentSessionMessageContentResourceInputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MessageContentResourceInputImage',
    minimal: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    full: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionMessageContentResourceInputImage).copyWith(),
    requiredKeys: ['type', 'image_url'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MessageContentResourceInputText',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    parse: (value) => AgentSessionMessageContentResourceInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionMessageContentResourceInputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MessageContentResourceOutputText',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"output_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"output_text"}'''),
    parse: (value) => AgentSessionMessageContentResourceOutputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionMessageContentResourceOutputText).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MessageItemResource',
    minimal: jsonDecode(
      r'''{"content":[],"id":null,"phase":null,"role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionMessageItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'role',
      'content',
      'status',
      'phase',
    ],
    nullableKeys: ['id', 'phase'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'MessagePhaseResource',
    minimal: jsonDecode(r'''"commentary"'''),
    full: jsonDecode(r'''"commentary"'''),
    parse: AgentSessionMessagePhaseResource.fromJson,
    copy: (model) => (model as AgentSessionMessagePhaseResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'NetworkAccessParam',
    minimal: jsonDecode(r'''"enabled"'''),
    full: jsonDecode(r'''"enabled"'''),
    parse: AgentSessionNetworkAccessConfig.fromJson,
    copy: (model) => (model as AgentSessionNetworkAccessConfig).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'NetworkAccessResource',
    minimal: jsonDecode(r'''"enabled"'''),
    full: jsonDecode(r'''"enabled"'''),
    parse: AgentSessionNetworkAccessResource.fromJson,
    copy: (model) => (model as AgentSessionNetworkAccessResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'NetworkPolicyParam',
    minimal: jsonDecode(r'''{"access":"enabled"}'''),
    full: jsonDecode(
      r'''{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionNetworkPolicyConfig).copyWith(),
    requiredKeys: ['access'],
    nullableKeys: ['allowed_domains', 'blocked_domains'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'NetworkPolicyResource',
    minimal: jsonDecode(r'''{"access":"enabled","allowed_domains":[]}'''),
    full: jsonDecode(
      r'''{"access":"enabled","allowed_domains":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionNetworkPolicyResource).copyWith(),
    requiredKeys: ['access', 'allowed_domains'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'OutputItemStatusResource',
    minimal: jsonDecode(r'''"in_progress"'''),
    full: jsonDecode(r'''"in_progress"'''),
    parse: AgentSessionOutputItemStatusResource.fromJson,
    copy: (model) => (model as AgentSessionOutputItemStatusResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'OutputTextResource',
    minimal: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"output_text"}'''),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"output_text"}'''),
    parse: (value) =>
        AgentSessionOutputTextResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionOutputTextResource).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'OutputTokensDetailsResource-2',
    minimal: jsonDecode(r'''{"reasoning_tokens":0}'''),
    full: jsonDecode(r'''{"reasoning_tokens":0}'''),
    parse: (value) => AgentSessionOutputTokensDetailsResourceDetails.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionOutputTokensDetailsResourceDetails).copyWith(),
    requiredKeys: ['reasoning_tokens'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ReasoningItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":null,"summary":[],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    parse: (value) => AgentSessionReasoningItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionReasoningItemResource).copyWith(),
    requiredKeys: ['type', 'id', 'turn_id', 'summary', 'status'],
    nullableKeys: ['status'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'ResumeSubagentCallItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionResumeSubagentCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SendSubagentInputCallItemResource',
    minimal: jsonDecode(
      r'''{"content":[],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionSendSubagentInputCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_id',
      'content',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionAgentConfigParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionAgentConfig).copyWith(),
    requiredKeys: [],
    nullableKeys: [
      'instructions',
      'multi_agent',
      'reasoning',
      'service_tier',
      'text',
      'tools',
    ],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SessionAgentResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionAgent).copyWith(),
    requiredKeys: [
      'id',
      'name',
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
  AgentSessionWireFixture(
    schema: 'SessionEnvironmentErrorResource',
    minimal: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentErrorResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentErrorResource).copyWith(),
    requiredKeys: ['type', 'code', 'message'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEnvironmentStateResource',
    minimal: jsonDecode(
      r'''{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentStateResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentStateResource).copyWith(),
    requiredKeys: ['id', 'type', 'status', 'error'],
    nullableKeys: ['error'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEnvironmentStatusResource',
    minimal: jsonDecode(r'''"pending"'''),
    full: jsonDecode(r'''"pending"'''),
    parse: AgentSessionEnvironmentStatusResource.fromJson,
    copy: (model) =>
        (model as AgentSessionEnvironmentStatusResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionErrorResource',
    minimal: jsonDecode(
      r'''{"code":null,"message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionErrorResource).copyWith(),
    requiredKeys: ['type', 'code', 'message', 'param'],
    nullableKeys: ['code', 'param'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEvent',
    minimal: jsonDecode(
      r'''{"error":{"code":null,"message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionErrorEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'error'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentOutputCommandExecutionOutputDelta',
    minimal: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.output.command_execution_output.delta"}''',
    ),
    full: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (model) =>
        (model as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'delta',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionCreated',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{},"object":"agent.session","required_actions":[],"status":"idle","usage":null,"vault_ids":[]},"type":"agent.session.created"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.created"}''',
    ),
    parse: (value) =>
        AgentSessionCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionCreatedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentConnected',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.connected"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionEnvironmentConnectedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentDisconnected',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.disconnected"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentDisconnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionEnvironmentDisconnectedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentExpired',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.expired"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    parse: (value) => AgentSessionEnvironmentExpiredEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentExpiredEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentFailed',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.failed"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    parse: (value) => AgentSessionEnvironmentFailedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentFailedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentPending',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.pending"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    parse: (value) => AgentSessionEnvironmentPendingEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentPendingEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentReady',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.ready"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    parse: (value) => AgentSessionEnvironmentReadyEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentReadyEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentReset',
    minimal: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.reset"}''',
    ),
    full: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    parse: (value) => AgentSessionEnvironmentResetEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionEnvironmentResetEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'environment_id',
      'reset_count',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionEnvironmentSuspended',
    minimal: jsonDecode(
      r'''{"environment":{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.suspended"}''',
    ),
    full: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    parse: (value) => AgentSessionEnvironmentSuspendedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionEnvironmentSuspendedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'environment'],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionFailed',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{},"object":"agent.session","required_actions":[],"status":"idle","usage":null,"vault_ids":[]},"type":"agent.session.failed"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.failed"}''',
    ),
    parse: (value) =>
        AgentSessionFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionFailedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionIdle',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{},"object":"agent.session","required_actions":[],"status":"idle","usage":null,"vault_ids":[]},"type":"agent.session.idle"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.idle"}''',
    ),
    parse: (value) =>
        AgentSessionIdleEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionIdleEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionInProgress',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{},"object":"agent.session","required_actions":[],"status":"idle","usage":null,"vault_ids":[]},"type":"agent.session.in_progress"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.in_progress"}''',
    ),
    parse: (value) =>
        AgentSessionInProgressEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionInProgressEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionRequiresAction',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{},"object":"agent.session","required_actions":[],"status":"idle","usage":null,"vault_ids":[]},"type":"agent.session.requires_action"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.requires_action"}''',
    ),
    parse: (value) => AgentSessionRequiresActionEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionRequiresActionEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionSubagentActive',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":null,"id":"PRIVATE-fixture","instructions":null,"name":null,"object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.active"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.active"}''',
    ),
    parse: (value) => AgentSessionSubagentActiveEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionSubagentActiveEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'subagent'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionSubagentClosed',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":null,"id":"PRIVATE-fixture","instructions":null,"name":null,"object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.closed"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.closed"}''',
    ),
    parse: (value) => AgentSessionSubagentClosedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionSubagentClosedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'subagent'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionSubagentCreated',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":null,"id":"PRIVATE-fixture","instructions":null,"name":null,"object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.created"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.created"}''',
    ),
    parse: (value) => AgentSessionSubagentCreatedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionSubagentCreatedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'subagent'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnCancelled',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":null,"usage":null},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":null}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCancelledEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnCancelledEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'turn',
      'usage',
    ],
    nullableKeys: ['usage'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnCompleted',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":null,"usage":null},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":null}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCompletedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnCompletedEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'turn',
      'usage',
    ],
    nullableKeys: ['usage'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnContentPartAdded',
    minimal: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.content_part.added"}''',
    ),
    full: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionTurnContentPartAddedEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'content_index',
      'part',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnContentPartDone',
    minimal: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.content_part.done"}''',
    ),
    full: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionTurnContentPartDoneEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'content_index',
      'part',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnCreated',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":null,"usage":null},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    parse: (value) =>
        AgentSessionTurnCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnCreatedEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'turn'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnFailed',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":null,"usage":null},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":null}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnFailedEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'turn',
      'usage',
    ],
    nullableKeys: ['usage'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnInProgress',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":null,"usage":null},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    parse: (value) => AgentSessionTurnInProgressEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionTurnInProgressEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'turn_id', 'turn'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnItemAdded',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[],"id":null,"phase":null,"role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":null,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.item.added"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemAddedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnItemAddedEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'output_index',
      'item',
    ],
    nullableKeys: ['output_index', 'turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnItemDone',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[],"id":"PRIVATE-fixture","phase":null,"role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.item.done"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemDoneEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnItemDoneEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'output_index',
      'item',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnOutputTextDelta',
    minimal: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.output_text.delta"}''',
    ),
    full: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionTurnOutputTextDeltaEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'content_index',
      'delta',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnOutputTextDone',
    minimal: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.output_text.done"}''',
    ),
    full: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionTurnOutputTextDoneEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'content_index',
      'text',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":null,"type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'summary_index',
      'part',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnReasoningSummaryPartDone',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":null,"summary_index":0,"turn_id":null,"type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'summary_index',
      'part',
      'status',
    ],
    nullableKeys: ['status', 'turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta',
    minimal: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":null,"type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    full: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'summary_index',
      'delta',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventAgentSessionTurnReasoningSummaryTextDone',
    minimal: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    full: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(),
    requiredKeys: [
      'type',
      'event_id',
      'session_id',
      'turn_id',
      'item_id',
      'output_index',
      'summary_index',
      'text',
    ],
    nullableKeys: ['turn_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionEventError',
    minimal: jsonDecode(
      r'''{"error":{"code":null,"message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    full: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionErrorEvent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionErrorEvent).copyWith(),
    requiredKeys: ['type', 'event_id', 'session_id', 'error'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionInputParam',
    minimal: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[],"type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    full: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionInput.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionApprovalResultInput).copyWith(),
    requiredKeys: ['type', 'request_id', 'response'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SessionInputParamAgentSessionInputCancel',
    minimal: jsonDecode(r'''{"type":"agent.session.input.cancel"}'''),
    full: jsonDecode(r'''{"type":"agent.session.input.cancel"}'''),
    parse: (value) =>
        AgentSessionCancelInput.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionCancelInput).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema:
        'SessionInputParamAgentSessionInputComputerUseApprovalRequestResult',
    minimal: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[],"type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    full: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    parse: (value) => AgentSessionApprovalResultInput.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionApprovalResultInput).copyWith(),
    requiredKeys: ['type', 'request_id', 'response'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SessionInputParamAgentSessionInputMessage',
    minimal: jsonDecode(
      r'''{"input":[],"type":"agent.session.input.message"}''',
    ),
    full: jsonDecode(
      r'''{"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"type":"agent.session.input.message"}''',
    ),
    parse: (value) =>
        AgentSessionMessageInput.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMessageInput).copyWith(),
    requiredKeys: ['type', 'input'],
    nullableKeys: [],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SessionInputParamAgentSessionInputToolResult',
    minimal: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    full: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    parse: (value) =>
        AgentSessionToolResultInput.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionToolResultInput).copyWith(),
    requiredKeys: ['type', 'turn_id', 'call_id', 'success'],
    nullableKeys: ['error', 'output'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SessionListResource',
    minimal: jsonDecode(
      r'''{"data":[],"first_id":null,"has_more":false,"last_id":null,"object":"list"}''',
    ),
    full: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    parse: (value) => AgentSessionList.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionList).copyWith(),
    requiredKeys: ['object', 'data', 'first_id', 'last_id', 'has_more'],
    nullableKeys: ['first_id', 'last_id'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionMessageRoleResource',
    minimal: jsonDecode(r'''"user"'''),
    full: jsonDecode(r'''"user"'''),
    parse: AgentSessionMessageRoleResource.fromJson,
    copy: (model) => (model as AgentSessionMessageRoleResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionRequiredActionResource',
    minimal: jsonDecode(
      r'''{"request":{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    full: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionRequiredAction.fromJson(value! as Map<String, dynamic>),
    copy: (model) =>
        (model as AgentSessionComputerUseApprovalRequiredAction).copyWith(),
    requiredKeys: ['type', 'turn_id', 'request_id', 'request'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionRequiredActionResourceComputerUseApprovalRequest',
    minimal: jsonDecode(
      r'''{"request":{"credential_origin":null,"fields":[],"options":[],"reason":null,"type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    full: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionComputerUseApprovalRequiredAction).copyWith(),
    requiredKeys: ['type', 'turn_id', 'request_id', 'request'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionRequiredActionResourceEnvironmentConnection',
    minimal: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","type":"environment_connection"}''',
    ),
    full: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","type":"environment_connection"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectionRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionEnvironmentConnectionRequiredAction).copyWith(),
    requiredKeys: ['type', 'environment_id'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionRequiredActionResourceFunctionCall',
    minimal: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    full: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionFunctionCallRequiredAction).copyWith(),
    requiredKeys: ['type', 'turn_id', 'call_id', 'name', 'arguments'],
    nullableKeys: ['arguments'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionResource',
    minimal: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":null},"name":null,"reasoning":{"effort":null,"summary":null},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{},"object":"agent.session","required_actions":[],"status":"idle","usage":null,"vault_ids":[]}''',
    ),
    full: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSession).copyWith(),
    requiredKeys: [
      'metadata',
      'id',
      'object',
      'created_at',
      'last_active_at',
      'status',
      'required_actions',
      'error',
      'agent',
      'environment',
      'vault_ids',
      'usage',
    ],
    nullableKeys: ['error', 'usage'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionSpendControlParam',
    minimal: jsonDecode(r'''{"limit":null}'''),
    full: jsonDecode(r'''{"limit":1}'''),
    parse: (value) =>
        AgentSessionSpendControlConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionSpendControlConfig).copyWith(),
    requiredKeys: ['limit'],
    nullableKeys: ['limit'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SessionSpendControlResource',
    minimal: jsonDecode(r'''{"consumed":null,"limit":1}'''),
    full: jsonDecode(r'''{"consumed":0,"limit":1}'''),
    parse: (value) =>
        AgentSessionSpendControl.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionSpendControl).copyWith(),
    requiredKeys: ['limit', 'consumed'],
    nullableKeys: ['consumed'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionStatusResource',
    minimal: jsonDecode(r'''"idle"'''),
    full: jsonDecode(r'''"idle"'''),
    parse: AgentSessionStatusResource.fromJson,
    copy: (model) => (model as AgentSessionStatusResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionTurnErrorCodeResource',
    minimal: jsonDecode(r'''"context_length_exceeded"'''),
    full: jsonDecode(r'''"context_length_exceeded"'''),
    parse: AgentSessionTurnErrorCodeResource.fromJson,
    copy: (model) => (model as AgentSessionTurnErrorCodeResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionTurnErrorResource',
    minimal: jsonDecode(
      r'''{"code":"context_length_exceeded","message":"PRIVATE-fixture"}''',
    ),
    full: jsonDecode(
      r'''{"code":"context_length_exceeded","message":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionTurnErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurnErrorResource).copyWith(),
    requiredKeys: ['code', 'message'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SessionTurnItemResource',
    minimal: jsonDecode(
      r'''{"content":[],"id":null,"phase":null,"role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    full: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionMessageItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'role',
      'content',
      'status',
      'phase',
    ],
    nullableKeys: ['id', 'phase'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SetupCommandParam',
    minimal: jsonDecode(r'''{"command":"PRIVATE-fixture"}'''),
    full: jsonDecode(r'''{"command":"PRIVATE-fixture","cwd":"/workspace"}'''),
    parse: (value) =>
        AgentSessionSetupCommandConfig.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionSetupCommandConfig).copyWith(),
    requiredKeys: ['command'],
    nullableKeys: ['cwd'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'SubagentObjectResource',
    minimal: jsonDecode(r'''"agent.session.subagent"'''),
    full: jsonDecode(r'''"agent.session.subagent"'''),
    parse: AgentSessionSubagentObjectResource.fromJson,
    copy: (model) => (model as AgentSessionSubagentObjectResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SubagentResource',
    minimal: jsonDecode(
      r'''{"closed_at":null,"id":"PRIVATE-fixture","instructions":null,"name":null,"object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    full: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionSubagent).copyWith(),
    requiredKeys: [
      'id',
      'object',
      'session_id',
      'name',
      'instructions',
      'parent_agent_id',
      'status',
      'opened_at',
      'closed_at',
    ],
    nullableKeys: ['closed_at', 'instructions', 'name'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SubagentStatusResource',
    minimal: jsonDecode(r'''"active"'''),
    full: jsonDecode(r'''"active"'''),
    parse: AgentSessionSubagentStatusResource.fromJson,
    copy: (model) => (model as AgentSessionSubagentStatusResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'SummaryTextResource',
    minimal: jsonDecode(
      r'''{"text":"PRIVATE-fixture","type":"summary_text"}''',
    ),
    full: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"summary_text"}'''),
    parse: (value) => AgentSessionSummaryTextResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) => (model as AgentSessionSummaryTextResource).copyWith(),
    requiredKeys: ['type', 'text'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TokenUsageResource',
    minimal: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    full: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTokenUsageResource).copyWith(),
    requiredKeys: [
      'input_tokens',
      'input_tokens_details',
      'output_tokens',
      'output_tokens_details',
      'total_tokens',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TurnObjectResource',
    minimal: jsonDecode(r'''"agent.session.turn"'''),
    full: jsonDecode(r'''"agent.session.turn"'''),
    parse: AgentSessionTurnObjectResource.fromJson,
    copy: (model) => (model as AgentSessionTurnObjectResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TurnResource',
    minimal: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":null,"usage":null}''',
    ),
    full: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionTurn).copyWith(),
    requiredKeys: [
      'id',
      'object',
      'session_id',
      'agent_id',
      'subagent_id',
      'status',
      'created_at',
      'started_at',
      'completed_at',
      'error',
      'usage',
    ],
    nullableKeys: [
      'completed_at',
      'error',
      'started_at',
      'subagent_id',
      'usage',
    ],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'TurnStatusResource',
    minimal: jsonDecode(r'''"queued"'''),
    full: jsonDecode(r'''"queued"'''),
    parse: AgentSessionTurnStatusResource.fromJson,
    copy: (model) => (model as AgentSessionTurnStatusResource).copyWith(),
    requiredKeys: [],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'UpdateAgentSessionParams',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"agent":{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"},"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1}}''',
    ),
    parse: (value) =>
        UpdateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as UpdateAgentSessionRequest).copyWith(),
    requiredKeys: [],
    nullableKeys: ['metadata', 'spend_control'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'UpdateSessionAgentParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(
      r'''{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"}''',
    ),
    parse: (value) =>
        AgentSessionAgentUpdate.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionAgentUpdate).copyWith(),
    requiredKeys: [],
    nullableKeys: ['service_tier'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'UpdateSessionReasoningParam',
    minimal: jsonDecode(r'''{}'''),
    full: jsonDecode(r'''{"effort":"none"}'''),
    parse: (value) =>
        AgentSessionReasoningUpdate.fromJson(value! as Map<String, dynamic>),
    copy: (model) => (model as AgentSessionReasoningUpdate).copyWith(),
    requiredKeys: [],
    nullableKeys: ['effort'],
    writable: true,
  ),
  AgentSessionWireFixture(
    schema: 'WaitForSubagentsCallItemResource',
    minimal: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":[],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    full: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWaitForSubagentsCallItemResource).copyWith(),
    requiredKeys: [
      'type',
      'id',
      'turn_id',
      'status',
      'sender_agent_id',
      'recipient_agent_ids',
    ],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchActionResource',
    minimal: jsonDecode(r'''{"queries":null,"query":null,"type":"search"}'''),
    full: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWebSearchActionResourceSearch).copyWith(),
    requiredKeys: ['type', 'query', 'queries'],
    nullableKeys: ['queries', 'query'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchActionResourceFindInPage',
    minimal: jsonDecode(
      r'''{"pattern":null,"type":"find_in_page","url":null}''',
    ),
    full: jsonDecode(
      r'''{"pattern":"PRIVATE-fixture","type":"find_in_page","url":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceFindInPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWebSearchActionResourceFindInPage).copyWith(),
    requiredKeys: ['type', 'url', 'pattern'],
    nullableKeys: ['pattern', 'url'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchActionResourceOpenPage',
    minimal: jsonDecode(r'''{"type":"open_page","url":null}'''),
    full: jsonDecode(r'''{"type":"open_page","url":"PRIVATE-fixture"}'''),
    parse: (value) => AgentSessionWebSearchActionResourceOpenPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWebSearchActionResourceOpenPage).copyWith(),
    requiredKeys: ['type', 'url'],
    nullableKeys: ['url'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchActionResourceOther',
    minimal: jsonDecode(r'''{"type":"other"}'''),
    full: jsonDecode(r'''{"type":"other"}'''),
    parse: (value) => AgentSessionWebSearchActionResourceOther.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWebSearchActionResourceOther).copyWith(),
    requiredKeys: ['type'],
    nullableKeys: [],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchActionResourceSearch',
    minimal: jsonDecode(r'''{"queries":null,"query":null,"type":"search"}'''),
    full: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceSearch.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWebSearchActionResourceSearch).copyWith(),
    requiredKeys: ['type', 'query', 'queries'],
    nullableKeys: ['queries', 'query'],
    writable: false,
  ),
  AgentSessionWireFixture(
    schema: 'WebSearchCallItemResource',
    minimal: jsonDecode(
      r'''{"action":null,"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    full: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    parse: (value) => AgentSessionWebSearchCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (model) =>
        (model as AgentSessionWebSearchCallItemResource).copyWith(),
    requiredKeys: ['type', 'id', 'turn_id', 'status', 'action'],
    nullableKeys: ['action'],
    writable: false,
  ),
];

/// One actual canonical component and its requiredness/presence corpus.
class AgentSessionWireFixture {
  /// Creates a component fixture.
  const AgentSessionWireFixture({
    required this.schema,
    required this.minimal,
    required this.full,
    required this.parse,
    required this.copy,
    required this.requiredKeys,
    required this.nullableKeys,
    required this.writable,
  });

  /// Actual component name.
  final String schema;

  /// A minimal meaningful source value.
  final Object? minimal;

  /// A source value covering optional nonnull branches.
  final Object? full;

  /// The actual exported parser.
  final AgentJsonModel Function(Object?) parse;

  /// Type-safe copy for the actual parsed variant.
  final AgentJsonModel Function(AgentJsonModel) copy;

  /// Canonically required object keys.
  final List<String> requiredKeys;

  /// Object keys which admit null.
  final List<String> nullableKeys;

  /// Whether request extras are closed.
  final bool writable;
}
