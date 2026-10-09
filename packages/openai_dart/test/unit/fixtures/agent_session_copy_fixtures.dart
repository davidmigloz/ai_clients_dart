import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';

/// Field copy witnesses validated independently against canonical JSONSchema.
final agentSessionFieldCopies = <AgentSessionFieldCopyFixture>[
  AgentSessionFieldCopyFixture(
    name: 'ErrorBodyResource.code',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentErrorBody).copyWith(
      code: (replacement as AgentErrorBody).code,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ErrorBodyResource.message',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture-replacement","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentErrorBody).copyWith(
      message: (replacement as AgentErrorBody).message,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ErrorBodyResource.param',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentErrorBody).copyWith(
      param: (replacement as AgentErrorBody).param,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ErrorBodyResource.type',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentErrorBody.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentErrorBody).copyWith(
      type: (replacement as AgentErrorBody).type,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ErrorResponse-2.error',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}}''',
    ),
    parse: (value) =>
        AgentErrorResponse.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentErrorResponse).copyWith(
      error: (replacement as AgentErrorResponse).error,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MultiAgentConfigCurrentParam.enabled',
    original: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    replacement: jsonDecode(
      r'''{"enabled":true,"max_concurrent_subagents":1}''',
    ),
    parse: (value) =>
        AgentMultiAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentMultiAgentConfig)
        .copyWith(enabled: (replacement as AgentMultiAgentConfig).enabled),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MultiAgentConfigCurrentParam.max_concurrent_subagents',
    original: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    replacement: jsonDecode(r'''{"enabled":false}'''),
    parse: (value) =>
        AgentMultiAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentMultiAgentConfig).copyWith(
          maxConcurrentSubagents:
              (replacement as AgentMultiAgentConfig).maxConcurrentSubagents,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MultiAgentConfigResource.enabled',
    original: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    replacement: jsonDecode(
      r'''{"enabled":true,"max_concurrent_subagents":1}''',
    ),
    parse: (value) => AgentMultiAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentMultiAgent).copyWith(
      enabled: (replacement as AgentMultiAgent).enabled,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MultiAgentConfigResource.max_concurrent_subagents',
    original: jsonDecode(r'''{"enabled":false,"max_concurrent_subagents":1}'''),
    replacement: jsonDecode(
      r'''{"enabled":false,"max_concurrent_subagents":null}''',
    ),
    parse: (value) => AgentMultiAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentMultiAgent).copyWith(
      maxConcurrentSubagents:
          (replacement as AgentMultiAgent).maxConcurrentSubagents,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningParam.effort',
    original: jsonDecode(r'''{"effort":"none","summary":"concise"}'''),
    replacement: jsonDecode(r'''{"effort":null,"summary":"concise"}'''),
    parse: (value) =>
        AgentReasoningConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentReasoningConfig).copyWith(
          effort: (replacement as AgentReasoningConfig).effort,
          clearEffort: replacement.clearEffort,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningParam.summary',
    original: jsonDecode(r'''{"effort":"none","summary":"concise"}'''),
    replacement: jsonDecode(r'''{"effort":"none","summary":null}'''),
    parse: (value) =>
        AgentReasoningConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentReasoningConfig).copyWith(
          summary: (replacement as AgentReasoningConfig).summary,
          clearSummary: replacement.clearSummary,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningResource.effort',
    original: jsonDecode(r'''{"effort":"none","summary":"concise"}'''),
    replacement: jsonDecode(r'''{"effort":null,"summary":"concise"}'''),
    parse: (value) => AgentReasoning.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentReasoning).copyWith(
      effort: (replacement as AgentReasoning).effort,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningResource.summary',
    original: jsonDecode(r'''{"effort":"none","summary":"concise"}'''),
    replacement: jsonDecode(r'''{"effort":"none","summary":null}'''),
    parse: (value) => AgentReasoning.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentReasoning).copyWith(
      summary: (replacement as AgentReasoning).summary,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TextFormatParamJsonSchema.schema',
    original: jsonDecode(
      r'''{"schema":{"fixture":"PRIVATE-value"},"type":"json_schema"}''',
    ),
    replacement: jsonDecode(
      r'''{"schema":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"type":"json_schema"}''',
    ),
    parse: (value) =>
        AgentJsonSchemaFormat.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentJsonSchemaFormat)
        .copyWith(schema: (replacement as AgentJsonSchemaFormat).schema),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TextFormatResourceJsonSchema.schema',
    original: jsonDecode(
      r'''{"schema":{"fixture":"PRIVATE-value"},"type":"json_schema"}''',
    ),
    replacement: jsonDecode(
      r'''{"schema":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"type":"json_schema"}''',
    ),
    parse: (value) =>
        AgentJsonSchemaFormatResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentJsonSchemaFormatResource).copyWith(
          schema: (replacement as AgentJsonSchemaFormatResource).schema,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TextParam.format',
    original: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    replacement: jsonDecode(r'''{"format":null,"verbosity":"low"}'''),
    parse: (value) => AgentTextConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentTextConfig).copyWith(
      format: (replacement as AgentTextConfig).format,
      clearFormat: replacement.clearFormat,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TextParam.verbosity',
    original: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    replacement: jsonDecode(r'''{"format":{"type":"text"},"verbosity":null}'''),
    parse: (value) => AgentTextConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentTextConfig).copyWith(
      verbosity: (replacement as AgentTextConfig).verbosity,
      clearVerbosity: replacement.clearVerbosity,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TextResource.format',
    original: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    replacement: jsonDecode(
      r'''{"format":{"schema":{"fixture":"PRIVATE-value"},"type":"json_schema"},"verbosity":"low"}''',
    ),
    parse: (value) => AgentText.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentText).copyWith(
      format: (replacement as AgentText).format,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TextResource.verbosity',
    original: jsonDecode(r'''{"format":{"type":"text"},"verbosity":"low"}'''),
    replacement: jsonDecode(
      r'''{"format":{"type":"text"},"verbosity":"medium"}''',
    ),
    parse: (value) => AgentText.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentText).copyWith(
      verbosity: (replacement as AgentText).verbosity,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationParam.city',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":null,"country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocation.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocation).copyWith(
          city: (replacement as AgentWebSearchLocation).city,
          clearCity: replacement.clearCity,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationParam.country',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":null,"region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocation.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocation).copyWith(
          country: (replacement as AgentWebSearchLocation).country,
          clearCountry: replacement.clearCountry,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationParam.region',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":null,"timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocation.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocation).copyWith(
          region: (replacement as AgentWebSearchLocation).region,
          clearRegion: replacement.clearRegion,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationParam.timezone',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":null}''',
    ),
    parse: (value) =>
        AgentWebSearchLocation.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocation).copyWith(
          timezone: (replacement as AgentWebSearchLocation).timezone,
          clearTimezone: replacement.clearTimezone,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationResource.city',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":null,"country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocationResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocationResource).copyWith(
          city: (replacement as AgentWebSearchLocationResource).city,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationResource.country',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":null,"region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocationResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocationResource).copyWith(
          country: (replacement as AgentWebSearchLocationResource).country,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationResource.region',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":null,"timezone":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentWebSearchLocationResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocationResource).copyWith(
          region: (replacement as AgentWebSearchLocationResource).region,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchLocationResource.timezone',
    original: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":null}''',
    ),
    parse: (value) =>
        AgentWebSearchLocationResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentWebSearchLocationResource).copyWith(
          timezone: (replacement as AgentWebSearchLocationResource).timezone,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentContentResource.text',
    original: jsonDecode(
      r'''{"text":"PRIVATE-fixture","type":"output_text"}''',
    ),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"output_text"}''',
    ),
    parse: (value) =>
        AgentSessionContent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionOutputTextResource).copyWith(
          text: (replacement as AgentSessionOutputTextResource).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentMessageItemResource.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"},{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentMessageItemResource).copyWith(
          content:
              (replacement as AgentSessionAgentMessageItemResource).content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentMessageItemResource.id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture-replacement","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentMessageItemResource).copyWith(
          id: (replacement as AgentSessionAgentMessageItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentMessageItemResource.recipient_agent_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture-replacement","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentMessageItemResource).copyWith(
          recipientAgentId:
              (replacement as AgentSessionAgentMessageItemResource)
                  .recipientAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentMessageItemResource.sender_agent_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentMessageItemResource).copyWith(
          senderAgentId: (replacement as AgentSessionAgentMessageItemResource)
              .senderAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentMessageItemResource.turn_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent_message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture-replacement","type":"agent_message"}''',
    ),
    parse: (value) => AgentSessionAgentMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentMessageItemResource).copyWith(
          turnId: (replacement as AgentSessionAgentMessageItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentOutputItemResource.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"},{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionOutputItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          content:
              (replacement as AgentSessionAssistantMessageItemResource).content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentOutputItemResource.id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture-replacement","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionOutputItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          id: (replacement as AgentSessionAssistantMessageItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentOutputItemResource.phase',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":null,"role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionOutputItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          phase:
              (replacement as AgentSessionAssistantMessageItemResource).phase,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentOutputItemResource.status',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"completed","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionOutputItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          status:
              (replacement as AgentSessionAssistantMessageItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentOutputItemResource.turn_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionOutputItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          turnId:
              (replacement as AgentSessionAssistantMessageItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParam.defer_loading',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionTool).copyWith(
          deferLoading: (replacement as AgentSessionFunctionTool).deferLoading,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParam.description',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionTool).copyWith(
          description: (replacement as AgentSessionFunctionTool).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParam.name',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionFunctionTool)
        .copyWith(name: (replacement as AgentSessionFunctionTool).name),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParam.parameters',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionTool).copyWith(
          parameters: (replacement as AgentSessionFunctionTool).parameters,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamComputerUse.include_screenshots',
    original: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    replacement: jsonDecode(r'''{"type":"computer_use"}'''),
    parse: (value) =>
        AgentSessionComputerUseTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseTool).copyWith(
          includeScreenshots:
              (replacement as AgentSessionComputerUseTool).includeScreenshots,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamFunction.defer_loading',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionFunctionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionTool).copyWith(
          deferLoading: (replacement as AgentSessionFunctionTool).deferLoading,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamFunction.description',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionFunctionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionTool).copyWith(
          description: (replacement as AgentSessionFunctionTool).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamFunction.name',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionFunctionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionFunctionTool)
        .copyWith(name: (replacement as AgentSessionFunctionTool).name),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamFunction.parameters',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionFunctionTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionTool).copyWith(
          parameters: (replacement as AgentSessionFunctionTool).parameters,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.allowed_tools',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":null,"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      allowedTools: (replacement as AgentSessionMcpTool).allowedTools,
      clearAllowedTools: replacement.clearAllowedTools,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.connection_origin',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":null,"credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      connectionOrigin: (replacement as AgentSessionMcpTool).connectionOrigin,
      clearConnectionOrigin: replacement.clearConnectionOrigin,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.credential_id',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":null,"request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      credentialId: (replacement as AgentSessionMcpTool).credentialId,
      clearCredentialId: replacement.clearCredentialId,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.request_metadata',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":null,"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      requestMetadata: (replacement as AgentSessionMcpTool).requestMetadata,
      clearRequestMetadata: replacement.clearRequestMetadata,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.required',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      required: (replacement as AgentSessionMcpTool).required,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.server_label',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture-replacement","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      serverLabel: (replacement as AgentSessionMcpTool).serverLabel,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamMcp.transport',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"authorization":"PRIVATE-fixture-replacement","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpTool).copyWith(
      transport: (replacement as AgentSessionMcpTool).transport,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamProgrammaticToolCalling.enabled',
    original: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    replacement: jsonDecode(r'''{"type":"programmatic_tool_calling"}'''),
    parse: (value) => AgentSessionProgrammaticToolCallingTool.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionProgrammaticToolCallingTool).copyWith(
          enabled:
              (replacement as AgentSessionProgrammaticToolCallingTool).enabled,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamWebSearch.allowed_domains',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":null,"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) =>
        AgentSessionWebSearchTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchTool).copyWith(
          allowedDomains:
              (replacement as AgentSessionWebSearchTool).allowedDomains,
          clearAllowedDomains: replacement.clearAllowedDomains,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamWebSearch.context_size',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":null,"location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) =>
        AgentSessionWebSearchTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchTool).copyWith(
          contextSize: (replacement as AgentSessionWebSearchTool).contextSize,
          clearContextSize: replacement.clearContextSize,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamWebSearch.location',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":null,"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) =>
        AgentSessionWebSearchTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchTool).copyWith(
          location: (replacement as AgentSessionWebSearchTool).location,
          clearLocation: replacement.clearLocation,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolConfigParamWebSearch.mode',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":null,"type":"web_search"}''',
    ),
    parse: (value) =>
        AgentSessionWebSearchTool.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchTool).copyWith(
          mode: (replacement as AgentSessionWebSearchTool).mode,
          clearMode: replacement.clearMode,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResource.defer_loading',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":true,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          deferLoading:
              (replacement as AgentSessionFunctionToolResource).deferLoading,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResource.description',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          description:
              (replacement as AgentSessionFunctionToolResource).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResource.name',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          name: (replacement as AgentSessionFunctionToolResource).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResource.parameters',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"type":"function"}''',
    ),
    parse: (value) =>
        AgentSessionToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          parameters:
              (replacement as AgentSessionFunctionToolResource).parameters,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceComputerUse.include_screenshots',
    original: jsonDecode(
      r'''{"include_screenshots":false,"type":"computer_use"}''',
    ),
    replacement: jsonDecode(
      r'''{"include_screenshots":true,"type":"computer_use"}''',
    ),
    parse: (value) => AgentSessionComputerUseToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseToolResource).copyWith(
          includeScreenshots:
              (replacement as AgentSessionComputerUseToolResource)
                  .includeScreenshots,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceFunction.defer_loading',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":true,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionFunctionToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          deferLoading:
              (replacement as AgentSessionFunctionToolResource).deferLoading,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceFunction.description',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionFunctionToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          description:
              (replacement as AgentSessionFunctionToolResource).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceFunction.name',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionFunctionToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          name: (replacement as AgentSessionFunctionToolResource).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceFunction.parameters',
    original: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}''',
    ),
    replacement: jsonDecode(
      r'''{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"type":"function"}''',
    ),
    parse: (value) => AgentSessionFunctionToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionToolResource).copyWith(
          parameters:
              (replacement as AgentSessionFunctionToolResource).parameters,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.allowed_tools',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":null,"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          allowedTools:
              (replacement as AgentSessionMcpToolResource).allowedTools,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.connection_origin',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"environment","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          connectionOrigin:
              (replacement as AgentSessionMcpToolResource).connectionOrigin,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.credential_id',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":null,"request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          credentialId:
              (replacement as AgentSessionMcpToolResource).credentialId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.request_metadata',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          requestMetadata:
              (replacement as AgentSessionMcpToolResource).requestMetadata,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.required',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":true,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          required: (replacement as AgentSessionMcpToolResource).required,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.server_label',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture-replacement","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          serverLabel: (replacement as AgentSessionMcpToolResource).serverLabel,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceMcp.transport',
    original: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture","type":"http"},"type":"mcp"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_tools":["PRIVATE-fixture"],"connection_origin":"service","credential_id":"PRIVATE-fixture","request_metadata":{"fixture":"PRIVATE-value"},"required":false,"server_label":"PRIVATE-fixture","transport":{"server_url":"PRIVATE-fixture-replacement","type":"http"},"type":"mcp"}''',
    ),
    parse: (value) =>
        AgentSessionMcpToolResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpToolResource).copyWith(
          transport: (replacement as AgentSessionMcpToolResource).transport,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceProgrammaticToolCalling.enabled',
    original: jsonDecode(
      r'''{"enabled":false,"type":"programmatic_tool_calling"}''',
    ),
    replacement: jsonDecode(
      r'''{"enabled":true,"type":"programmatic_tool_calling"}''',
    ),
    parse: (value) => AgentSessionProgrammaticToolCallingToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionProgrammaticToolCallingToolResource).copyWith(
          enabled:
              (replacement as AgentSessionProgrammaticToolCallingToolResource)
                  .enabled,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceWebSearch.allowed_domains',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":null,"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) => AgentSessionWebSearchToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchToolResource).copyWith(
          allowedDomains:
              (replacement as AgentSessionWebSearchToolResource).allowedDomains,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceWebSearch.context_size',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"medium","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) => AgentSessionWebSearchToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchToolResource).copyWith(
          contextSize:
              (replacement as AgentSessionWebSearchToolResource).contextSize,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceWebSearch.location',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":null,"mode":"disabled","type":"web_search"}''',
    ),
    parse: (value) => AgentSessionWebSearchToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchToolResource).copyWith(
          location: (replacement as AgentSessionWebSearchToolResource).location,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AgentToolResourceWebSearch.mode',
    original: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"disabled","type":"web_search"}''',
    ),
    replacement: jsonDecode(
      r'''{"allowed_domains":["PRIVATE-fixture"],"context_size":"low","location":{"city":"PRIVATE-fixture","country":"PRIVATE-fixture","region":"PRIVATE-fixture","timezone":"PRIVATE-fixture"},"mode":"cached","type":"web_search"}''',
    ),
    parse: (value) => AgentSessionWebSearchToolResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchToolResource).copyWith(
          mode: (replacement as AgentSessionWebSearchToolResource).mode,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AssistantMessageItemResource.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"},{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionAssistantMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          content:
              (replacement as AgentSessionAssistantMessageItemResource).content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AssistantMessageItemResource.id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture-replacement","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionAssistantMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          id: (replacement as AgentSessionAssistantMessageItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AssistantMessageItemResource.phase',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":null,"role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionAssistantMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          phase:
              (replacement as AgentSessionAssistantMessageItemResource).phase,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AssistantMessageItemResource.status',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"completed","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionAssistantMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          status:
              (replacement as AgentSessionAssistantMessageItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'AssistantMessageItemResource.turn_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"message"}''',
    ),
    parse: (value) => AgentSessionAssistantMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionAssistantMessageItemResource).copyWith(
          turnId:
              (replacement as AgentSessionAssistantMessageItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationFieldResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationField.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationField).copyWith(
          id: (replacement as AgentSessionBrowserAuthenticationField).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationFieldResource.label',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture-replacement","required":false,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationField.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationField).copyWith(
          label: (replacement as AgentSessionBrowserAuthenticationField).label,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationFieldResource.required',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":true,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationField.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationField).copyWith(
          required:
              (replacement as AgentSessionBrowserAuthenticationField).required,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationFieldResource.type',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationField.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationField).copyWith(
          type: (replacement as AgentSessionBrowserAuthenticationField).type,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationFieldValueParam.field_id',
    original: jsonDecode(
      r'''{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"field_id":"PRIVATE-fixture-replacement","value":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationFieldValue.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationFieldValue).copyWith(
          fieldId: (replacement as AgentSessionBrowserAuthenticationFieldValue)
              .fieldId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationFieldValueParam.value',
    original: jsonDecode(
      r'''{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationFieldValue.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationFieldValue).copyWith(
          value: (replacement as AgentSessionBrowserAuthenticationFieldValue)
              .value,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationHistoryRequestKindResource.credential_origin',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":null,"fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              credentialOrigin:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .credentialOrigin,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationHistoryRequestKindResource.fields',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"},{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              fields:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .fields,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationHistoryRequestKindResource.options',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"},{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              options:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .options,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationHistoryRequestKindResource.reason',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":null,"type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              reason:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .reason,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.credential_origin',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":null,"fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              credentialOrigin:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .credentialOrigin,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fields',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"},{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              fields:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .fields,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.options',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"},{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              options:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .options,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.reason',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":null,"type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original
                as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
            .copyWith(
              reason:
                  (replacement
                          as AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication)
                      .reason,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationOptionResource.field_ids',
    original: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture","PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationOption.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationOption).copyWith(
          fieldIds:
              (replacement as AgentSessionBrowserAuthenticationOption).fieldIds,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationOptionResource.id',
    original: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture-replacement","label":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationOption.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationOption).copyWith(
          id: (replacement as AgentSessionBrowserAuthenticationOption).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationOptionResource.label',
    original: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationOption.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationOption).copyWith(
          label: (replacement as AgentSessionBrowserAuthenticationOption).label,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationRequestItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequestItemResource)
            .copyWith(
              id:
                  (replacement
                          as AgentSessionBrowserAuthenticationRequestItemResource)
                      .id,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationRequestItemResource.request',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture-replacement","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequestItemResource)
            .copyWith(
              request:
                  (replacement
                          as AgentSessionBrowserAuthenticationRequestItemResource)
                      .request,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationRequestItemResource.request_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequestItemResource)
            .copyWith(
              requestId:
                  (replacement
                          as AgentSessionBrowserAuthenticationRequestItemResource)
                      .requestId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'BrowserAuthenticationRequestItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture-replacement","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequestItemResource)
            .copyWith(
              turnId:
                  (replacement
                          as AgentSessionBrowserAuthenticationRequestItemResource)
                      .turnId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CloseSubagentCallItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCloseSubagentCallItemResource).copyWith(
          id: (replacement as AgentSessionCloseSubagentCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CloseSubagentCallItemResource.recipient_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture-replacement","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCloseSubagentCallItemResource).copyWith(
          recipientAgentId:
              (replacement as AgentSessionCloseSubagentCallItemResource)
                  .recipientAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CloseSubagentCallItemResource.sender_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCloseSubagentCallItemResource).copyWith(
          senderAgentId:
              (replacement as AgentSessionCloseSubagentCallItemResource)
                  .senderAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CloseSubagentCallItemResource.status',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCloseSubagentCallItemResource).copyWith(
          status:
              (replacement as AgentSessionCloseSubagentCallItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CloseSubagentCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"close_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"close_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCloseSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCloseSubagentCallItemResource).copyWith(
          turnId:
              (replacement as AgentSessionCloseSubagentCallItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.command',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture-replacement","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          command:
              (replacement as AgentSessionCommandExecutionItemResource).command,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.cwd',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":null,"duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          cwd: (replacement as AgentSessionCommandExecutionItemResource).cwd,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.duration_ms',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":null,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          durationMs: (replacement as AgentSessionCommandExecutionItemResource)
              .durationMs,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.exit_code',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":null,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          exitCode: (replacement as AgentSessionCommandExecutionItemResource)
              .exitCode,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.id',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture-replacement","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          id: (replacement as AgentSessionCommandExecutionItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.output',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":null,"status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          output:
              (replacement as AgentSessionCommandExecutionItemResource).output,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.status',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          status:
              (replacement as AgentSessionCommandExecutionItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CommandExecutionItemResource.turn_id',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"command_execution"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","duration_ms":0,"exit_code":0,"id":"PRIVATE-fixture","output":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"command_execution"}''',
    ),
    parse: (value) => AgentSessionCommandExecutionItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCommandExecutionItemResource).copyWith(
          turnId:
              (replacement as AgentSessionCommandExecutionItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerScreenshotResource.image_url',
    original: jsonDecode(
      r'''{"image_url":"PRIVATE-fixture","type":"computer_screenshot"}''',
    ),
    replacement: jsonDecode(
      r'''{"image_url":"PRIVATE-fixture-replacement","type":"computer_screenshot"}''',
    ),
    parse: (value) => AgentSessionComputerScreenshotResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerScreenshotResource).copyWith(
          imageUrl:
              (replacement as AgentSessionComputerScreenshotResource).imageUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResource.credential_origin',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":null,"fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequestKind.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          credentialOrigin:
              (replacement as AgentSessionBrowserAuthenticationRequest)
                  .credentialOrigin,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResource.fields',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"},{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequestKind.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          fields:
              (replacement as AgentSessionBrowserAuthenticationRequest).fields,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResource.options',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"},{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequestKind.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          options:
              (replacement as AgentSessionBrowserAuthenticationRequest).options,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResource.reason',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":null,"type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequestKind.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          reason:
              (replacement as AgentSessionBrowserAuthenticationRequest).reason,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'ComputerUseApprovalRequestKindResourceBrowserAuthentication.credential_origin',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":null,"fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          credentialOrigin:
              (replacement as AgentSessionBrowserAuthenticationRequest)
                  .credentialOrigin,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResourceBrowserAuthentication.fields',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"},{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          fields:
              (replacement as AgentSessionBrowserAuthenticationRequest).fields,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResourceBrowserAuthentication.options',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"},{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          options:
              (replacement as AgentSessionBrowserAuthenticationRequest).options,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResourceBrowserAuthentication.reason',
    original: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":null,"type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationRequest).copyWith(
          reason:
              (replacement as AgentSessionBrowserAuthenticationRequest).reason,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResourceBrowserOriginAccess.origin',
    original: jsonDecode(
      r'''{"origin":"PRIVATE-fixture","reason":"PRIVATE-fixture","type":"browser_origin_access"}''',
    ),
    replacement: jsonDecode(
      r'''{"origin":"PRIVATE-fixture-replacement","reason":"PRIVATE-fixture","type":"browser_origin_access"}''',
    ),
    parse: (value) => AgentSessionBrowserOriginAccessRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserOriginAccessRequest).copyWith(
          origin:
              (replacement as AgentSessionBrowserOriginAccessRequest).origin,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestKindResourceBrowserOriginAccess.reason',
    original: jsonDecode(
      r'''{"origin":"PRIVATE-fixture","reason":"PRIVATE-fixture","type":"browser_origin_access"}''',
    ),
    replacement: jsonDecode(
      r'''{"origin":"PRIVATE-fixture","reason":null,"type":"browser_origin_access"}''',
    ),
    parse: (value) => AgentSessionBrowserOriginAccessRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserOriginAccessRequest).copyWith(
          reason:
              (replacement as AgentSessionBrowserOriginAccessRequest).reason,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestResultItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequestResultItemResource)
            .copyWith(
              id:
                  (replacement
                          as AgentSessionComputerUseApprovalRequestResultItemResource)
                      .id,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestResultItemResource.request_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture-replacement","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequestResultItemResource)
            .copyWith(
              requestId:
                  (replacement
                          as AgentSessionComputerUseApprovalRequestResultItemResource)
                      .requestId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestResultItemResource.response',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture-replacement","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequestResultItemResource)
            .copyWith(
              response:
                  (replacement
                          as AgentSessionComputerUseApprovalRequestResultItemResource)
                      .response,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalRequestResultItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture","type":"computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","request_id":"PRIVATE-fixture","response":{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"},"turn_id":"PRIVATE-fixture-replacement","type":"computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequestResultItemResource)
            .copyWith(
              turnId:
                  (replacement
                          as AgentSessionComputerUseApprovalRequestResultItemResource)
                      .turnId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalResponseKindResource.selected_option',
    original: jsonDecode(
      r'''{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","selected_option":null,"type":"browser_authentication"}''',
    ),
    parse: (value) =>
        AgentSessionBrowserAuthenticationResponseResource.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmitResource).copyWith(
          selectedOption:
              (replacement as AgentSessionBrowserAuthenticationSubmitResource)
                  .selectedOption,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'ComputerUseApprovalResponseKindResourceBrowserAuthenticationSubmitResource.selected_option',
    original: jsonDecode(
      r'''{"action":"submit","selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","selected_option":null,"type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationSubmitResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmitResource).copyWith(
          selectedOption:
              (replacement as AgentSessionBrowserAuthenticationSubmitResource)
                  .selectedOption,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalResponseParam.fields',
    original: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"},{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmit).copyWith(
          fields:
              (replacement as AgentSessionBrowserAuthenticationSubmit).fields,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalResponseParam.selected_option',
    original: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":null,"type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmit).copyWith(
          selectedOption:
              (replacement as AgentSessionBrowserAuthenticationSubmit)
                  .selectedOption,
          clearSelectedOption: replacement.clearSelectedOption,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalResponseParamBrowserAuthentication.fields',
    original: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"},{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmit).copyWith(
          fields:
              (replacement as AgentSessionBrowserAuthenticationSubmit).fields,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'ComputerUseApprovalResponseParamBrowserAuthentication.selected_option',
    original: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":null,"type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmit).copyWith(
          selectedOption:
              (replacement as AgentSessionBrowserAuthenticationSubmit)
                  .selectedOption,
          clearSelectedOption: replacement.clearSelectedOption,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam.fields',
    original: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"},{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationSubmit.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmit).copyWith(
          fields:
              (replacement as AgentSessionBrowserAuthenticationSubmit).fields,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'ComputerUseApprovalResponseParamBrowserAuthenticationSubmitParam.selected_option',
    original: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":null,"type":"browser_authentication"}''',
    ),
    parse: (value) => AgentSessionBrowserAuthenticationSubmit.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserAuthenticationSubmit).copyWith(
          selectedOption:
              (replacement as AgentSessionBrowserAuthenticationSubmit)
                  .selectedOption,
          clearSelectedOption: replacement.clearSelectedOption,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseApprovalResponseParamBrowserOriginAccessParam.decision',
    original: jsonDecode(
      r'''{"decision":"approve","type":"browser_origin_access"}''',
    ),
    replacement: jsonDecode(
      r'''{"decision":"deny","type":"browser_origin_access"}''',
    ),
    parse: (value) => AgentSessionBrowserOriginAccessResponse.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionBrowserOriginAccessResponse).copyWith(
          decision:
              (replacement as AgentSessionBrowserOriginAccessResponse).decision,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseCallItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseCallItemResource).copyWith(
          id: (replacement as AgentSessionComputerUseCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseCallItemResource.output',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":null,"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseCallItemResource).copyWith(
          output:
              (replacement as AgentSessionComputerUseCallItemResource).output,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseCallItemResource.status',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"completed","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseCallItemResource).copyWith(
          status:
              (replacement as AgentSessionComputerUseCallItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseCallItemResource.title',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":null,"turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseCallItemResource).copyWith(
          title: (replacement as AgentSessionComputerUseCallItemResource).title,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ComputerUseCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","output":{"image_url":"PRIVATE-fixture","type":"computer_screenshot"},"status":"in_progress","title":"PRIVATE-fixture","turn_id":"PRIVATE-fixture-replacement","type":"computer_use_call"}''',
    ),
    parse: (value) => AgentSessionComputerUseCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseCallItemResource).copyWith(
          turnId:
              (replacement as AgentSessionComputerUseCallItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.agent',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as CreateAgentSessionRequest)
        .copyWith(agent: (replacement as CreateAgentSessionRequest).agent),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.agent_id',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as CreateAgentSessionRequest)
        .copyWith(agentId: (replacement as CreateAgentSessionRequest).agentId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.environment',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as CreateAgentSessionRequest).copyWith(
          environment: (replacement as CreateAgentSessionRequest).environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.metadata',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":null,"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as CreateAgentSessionRequest).copyWith(
          metadata: (replacement as CreateAgentSessionRequest).metadata,
          clearMetadata: replacement.clearMetadata,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.spend_control',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":null,"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as CreateAgentSessionRequest).copyWith(
          spendControl: (replacement as CreateAgentSessionRequest).spendControl,
          clearSpendControl: replacement.clearSpendControl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.stream',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as CreateAgentSessionRequest)
        .copyWith(stream: (replacement as CreateAgentSessionRequest).stream),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateAgentSessionParams.vault_ids',
    original: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"agent_id":"PRIVATE-fixture","environment":{"type":"none"},"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1},"stream":false,"vault_ids":null}''',
    ),
    parse: (value) =>
        CreateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as CreateAgentSessionRequest).copyWith(
          vaultIds: (replacement as CreateAgentSessionRequest).vaultIds,
          clearVaultIds: replacement.clearVaultIds,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSessionEventsParams.events',
    original: jsonDecode(
      r'''{"events":[{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"events":[{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"},{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}]}''',
    ),
    parse: (value) => CreateAgentSessionEventsRequest.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as CreateAgentSessionEventsRequest).copyWith(
          events: (replacement as CreateAgentSessionEventsRequest).events,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.agent_id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture-replacement","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          agentId: (replacement as AgentSessionCreateSubagentCallItemResource)
              .agentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.content',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"},{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          content: (replacement as AgentSessionCreateSubagentCallItemResource)
              .content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture-replacement","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          id: (replacement as AgentSessionCreateSubagentCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.model',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":null,"reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          model:
              (replacement as AgentSessionCreateSubagentCallItemResource).model,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.reasoning_effort',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":null,"status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          reasoningEffort:
              (replacement as AgentSessionCreateSubagentCallItemResource)
                  .reasoningEffort,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.status',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          status: (replacement as AgentSessionCreateSubagentCallItemResource)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'CreateSubagentCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"create_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","model":"PRIVATE-fixture","reasoning_effort":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"create_subagent_call"}''',
    ),
    parse: (value) => AgentSessionCreateSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionCreateSubagentCallItemResource).copyWith(
          turnId: (replacement as AgentSessionCreateSubagentCallItemResource)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'DeletedSessionResource.deleted',
    original: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture","object":"agent.session.deleted"}''',
    ),
    replacement: jsonDecode(
      r'''{"deleted":true,"id":"PRIVATE-fixture","object":"agent.session.deleted"}''',
    ),
    parse: (value) =>
        DeletedAgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as DeletedAgentSession).copyWith(
      deleted: (replacement as DeletedAgentSession).deleted,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'DeletedSessionResource.id',
    original: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture","object":"agent.session.deleted"}''',
    ),
    replacement: jsonDecode(
      r'''{"deleted":false,"id":"PRIVATE-fixture-replacement","object":"agent.session.deleted"}''',
    ),
    parse: (value) =>
        DeletedAgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as DeletedAgentSession).copyWith(
      id: (replacement as DeletedAgentSession).id,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'DesktopParam.enabled',
    original: jsonDecode(r'''{"enabled":false}'''),
    replacement: jsonDecode(r'''{"enabled":true}'''),
    parse: (value) =>
        AgentSessionDesktopConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionDesktopConfig)
        .copyWith(enabled: (replacement as AgentSessionDesktopConfig).enabled),
  ),
  AgentSessionFieldCopyFixture(
    name: 'DesktopResource.enabled',
    original: jsonDecode(r'''{"enabled":false}'''),
    replacement: jsonDecode(r'''{"enabled":true}'''),
    parse: (value) =>
        AgentSessionDesktopResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionDesktopResource).copyWith(
          enabled: (replacement as AgentSessionDesktopResource).enabled,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EncryptedContentResource.encrypted_content',
    original: jsonDecode(
      r'''{"encrypted_content":"PRIVATE-fixture","type":"encrypted_content"}''',
    ),
    replacement: jsonDecode(
      r'''{"encrypted_content":"PRIVATE-fixture-replacement","type":"encrypted_content"}''',
    ),
    parse: (value) => AgentSessionEncryptedContentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEncryptedContentResource).copyWith(
          encryptedContent:
              (replacement as AgentSessionEncryptedContentResource)
                  .encryptedContent,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentPackagesParam.npm',
    original: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"npm":null,"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPackagesConfig).copyWith(
          npm: (replacement as AgentSessionEnvironmentPackagesConfig).npm,
          clearNpm: replacement.clearNpm,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentPackagesParam.python',
    original: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":null,"system":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPackagesConfig).copyWith(
          python: (replacement as AgentSessionEnvironmentPackagesConfig).python,
          clearPython: replacement.clearPython,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentPackagesParam.system',
    original: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":null}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPackagesConfig).copyWith(
          system: (replacement as AgentSessionEnvironmentPackagesConfig).system,
          clearSystem: replacement.clearSystem,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentPackagesResource.npm',
    original: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"npm":["PRIVATE-fixture","PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPackagesResource).copyWith(
          npm: (replacement as AgentSessionEnvironmentPackagesResource).npm,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentPackagesResource.python',
    original: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture","PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPackagesResource).copyWith(
          python:
              (replacement as AgentSessionEnvironmentPackagesResource).python,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentPackagesResource.system',
    original: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture","PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionEnvironmentPackagesResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPackagesResource).copyWith(
          system:
              (replacement as AgentSessionEnvironmentPackagesResource).system,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.capability_directories',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":null,"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          capabilityDirectories: (replacement as AgentSessionHostedEnvironment)
              .capabilityDirectories,
          clearCapabilityDirectories: replacement.clearCapabilityDirectories,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.container_size',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          containerSize:
              (replacement as AgentSessionHostedEnvironment).containerSize,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.desktop',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":null,"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          desktop: (replacement as AgentSessionHostedEnvironment).desktop,
          clearDesktop: replacement.clearDesktop,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.env',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":null,"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          env: (replacement as AgentSessionHostedEnvironment).env,
          clearEnv: replacement.clearEnv,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.environment_template_id',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          environmentTemplateId: (replacement as AgentSessionHostedEnvironment)
              .environmentTemplateId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.files',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":null,"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          files: (replacement as AgentSessionHostedEnvironment).files,
          clearFiles: replacement.clearFiles,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.network',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":null,"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          network: (replacement as AgentSessionHostedEnvironment).network,
          clearNetwork: replacement.clearNetwork,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.packages',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":null,"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          packages: (replacement as AgentSessionHostedEnvironment).packages,
          clearPackages: replacement.clearPackages,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.plugins',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":null,"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          plugins: (replacement as AgentSessionHostedEnvironment).plugins,
          clearPlugins: replacement.clearPlugins,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.setup_commands',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":null,"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          setupCommands:
              (replacement as AgentSessionHostedEnvironment).setupCommands,
          clearSetupCommands: replacement.clearSetupCommands,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamOpenaiHosted.skills',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":[{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"env":{"fixture":"PRIVATE-value"},"environment_template_id":"PRIVATE-fixture","files":[{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}],"network":{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"PRIVATE-fixture","cwd":"/workspace"}],"skills":null,"type":"openai_hosted"}''',
    ),
    parse: (value) =>
        AgentSessionHostedEnvironment.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironment).copyWith(
          skills: (replacement as AgentSessionHostedEnvironment).skills,
          clearSkills: replacement.clearSkills,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamSelfHosted.capability_directories',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"type":"self_hosted","workspace_directory":"/workspace/project"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":null,"type":"self_hosted","workspace_directory":"/workspace/project"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironment.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSelfHostedEnvironment).copyWith(
          capabilityDirectories:
              (replacement as AgentSessionSelfHostedEnvironment)
                  .capabilityDirectories,
          clearCapabilityDirectories: replacement.clearCapabilityDirectories,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentParamSelfHosted.workspace_directory',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"type":"self_hosted","workspace_directory":"/workspace/project"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"type":"self_hosted","workspace_directory":"/workspace/project-replacement"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironment.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSelfHostedEnvironment).copyWith(
          workspaceDirectory: (replacement as AgentSessionSelfHostedEnvironment)
              .workspaceDirectory,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.capability_directories',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture","PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          capabilityDirectories:
              (replacement as AgentSessionHostedEnvironmentResource)
                  .capabilityDirectories,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.container_size',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":null,"desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          containerSize: (replacement as AgentSessionHostedEnvironmentResource)
              .containerSize,
          clearContainerSize: replacement.clearContainerSize,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.desktop',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":true},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          desktop:
              (replacement as AgentSessionHostedEnvironmentResource).desktop,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.files',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"},{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          files: (replacement as AgentSessionHostedEnvironmentResource).files,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.id',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture-replacement","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          id: (replacement as AgentSessionHostedEnvironmentResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.network',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"disabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          network:
              (replacement as AgentSessionHostedEnvironmentResource).network,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.packages',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture","PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          packages:
              (replacement as AgentSessionHostedEnvironmentResource).packages,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.plugins',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"},{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          plugins:
              (replacement as AgentSessionHostedEnvironmentResource).plugins,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceOpenaiHosted.skills',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"},{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentResource).copyWith(
          skills: (replacement as AgentSessionHostedEnvironmentResource).skills,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceSelfHosted.capability_directories',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture","PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSelfHostedEnvironmentResource).copyWith(
          capabilityDirectories:
              (replacement as AgentSessionSelfHostedEnvironmentResource)
                  .capabilityDirectories,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceSelfHosted.id',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture-replacement","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSelfHostedEnvironmentResource).copyWith(
          id: (replacement as AgentSessionSelfHostedEnvironmentResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceSelfHosted.remote_url',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture-replacement","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSelfHostedEnvironmentResource).copyWith(
          remoteUrl: (replacement as AgentSessionSelfHostedEnvironmentResource)
              .remoteUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'EnvironmentResourceSelfHosted.workspace_directory',
    original: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"capability_directories":["PRIVATE-fixture"],"id":"PRIVATE-fixture","remote_url":"PRIVATE-fixture","type":"self_hosted","workspace_directory":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionSelfHostedEnvironmentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSelfHostedEnvironmentResource).copyWith(
          workspaceDirectory:
              (replacement as AgentSessionSelfHostedEnvironmentResource)
                  .workspaceDirectory,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallItemResource.arguments',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":null,"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallItemResource).copyWith(
          arguments:
              (replacement as AgentSessionFunctionCallItemResource).arguments,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallItemResource.call_id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture-replacement","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallItemResource).copyWith(
          callId: (replacement as AgentSessionFunctionCallItemResource).callId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallItemResource.id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallItemResource).copyWith(
          id: (replacement as AgentSessionFunctionCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallItemResource.name',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallItemResource).copyWith(
          name: (replacement as AgentSessionFunctionCallItemResource).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallItemResource.status',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallItemResource).copyWith(
          status: (replacement as AgentSessionFunctionCallItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","id":"PRIVATE-fixture","name":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallItemResource).copyWith(
          turnId: (replacement as AgentSessionFunctionCallItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallOutputItemResource.call_id',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture-replacement","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallOutputItemResource).copyWith(
          callId: (replacement as AgentSessionFunctionCallOutputItemResource)
              .callId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallOutputItemResource.error',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":null,"id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallOutputItemResource).copyWith(
          error:
              (replacement as AgentSessionFunctionCallOutputItemResource).error,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallOutputItemResource.id',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture-replacement","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallOutputItemResource).copyWith(
          id: (replacement as AgentSessionFunctionCallOutputItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallOutputItemResource.output',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":null,"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallOutputItemResource).copyWith(
          output: (replacement as AgentSessionFunctionCallOutputItemResource)
              .output,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallOutputItemResource.status',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"completed","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallOutputItemResource).copyWith(
          status: (replacement as AgentSessionFunctionCallOutputItemResource)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'FunctionCallOutputItemResource.turn_id',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture","type":"function_call_output"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","id":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"function_call_output"}''',
    ),
    parse: (value) => AgentSessionFunctionCallOutputItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallOutputItemResource).copyWith(
          turnId: (replacement as AgentSessionFunctionCallOutputItemResource)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileParam.file_id',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture-replacement","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileConfigFileId).copyWith(
          fileId: (replacement as AgentSessionHostedEnvironmentFileConfigFileId)
              .fileId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileParam.path',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt-replacement","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileConfigFileId).copyWith(
          path: (replacement as AgentSessionHostedEnvironmentFileConfigFileId)
              .path,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileParamFileId.file_id',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture-replacement","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileConfigFileId).copyWith(
          fileId: (replacement as AgentSessionHostedEnvironmentFileConfigFileId)
              .fileId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileParamFileId.path',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt","type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","path":"/workspace/input.txt-replacement","type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileConfigFileId).copyWith(
          path: (replacement as AgentSessionHostedEnvironmentFileConfigFileId)
              .path,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileParamInline.data',
    original: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","path":"/workspace/input.txt","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":"UFJJVkFURS1yZXBsYWNlbWVudC1hcmNoaXZl","path":"/workspace/input.txt","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileConfigInline).copyWith(
          data: (replacement as AgentSessionHostedEnvironmentFileConfigInline)
              .data,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileParamInline.path',
    original: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","path":"/workspace/input.txt","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","path":"/workspace/input.txt-replacement","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileConfigInline).copyWith(
          path: (replacement as AgentSessionHostedEnvironmentFileConfigInline)
              .path,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResource.file_id',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture-replacement","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          fileId:
              (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
                  .fileId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResource.id',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture-replacement","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          id: (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
              .id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResource.path',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture-replacement","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          path: (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
              .path,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResource.size_bytes',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":1,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          sizeBytes:
              (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
                  .sizeBytes,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceFileId.file_id',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture-replacement","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          fileId:
              (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
                  .fileId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceFileId.id',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture-replacement","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          id: (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
              .id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceFileId.path',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture-replacement","size_bytes":0,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          path: (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
              .path,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceFileId.size_bytes',
    original: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}''',
    ),
    replacement: jsonDecode(
      r'''{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":1,"type":"file_id"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceFileId).copyWith(
          sizeBytes:
              (replacement as AgentSessionHostedEnvironmentFileResourceFileId)
                  .sizeBytes,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceInline.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","path":"PRIVATE-fixture","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceInline).copyWith(
          id: (replacement as AgentSessionHostedEnvironmentFileResourceInline)
              .id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceInline.path',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture-replacement","size_bytes":0,"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceInline).copyWith(
          path: (replacement as AgentSessionHostedEnvironmentFileResourceInline)
              .path,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedEnvironmentFileResourceInline.size_bytes',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":1,"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedEnvironmentFileResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedEnvironmentFileResourceInline).copyWith(
          sizeBytes:
              (replacement as AgentSessionHostedEnvironmentFileResourceInline)
                  .sizeBytes,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginParam.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) =>
        AgentSessionHostedPluginConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginConfigInline).copyWith(
          description:
              (replacement as AgentSessionHostedPluginConfigInline).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginParam.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) =>
        AgentSessionHostedPluginConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginConfigInline).copyWith(
          name: (replacement as AgentSessionHostedPluginConfigInline).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginParam.source',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UFJJVkFURS1yZXBsYWNlbWVudC1hcmNoaXZl","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) =>
        AgentSessionHostedPluginConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginConfigInline).copyWith(
          source: (replacement as AgentSessionHostedPluginConfigInline).source,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginParamInline.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginConfigInline).copyWith(
          description:
              (replacement as AgentSessionHostedPluginConfigInline).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginParamInline.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginConfigInline).copyWith(
          name: (replacement as AgentSessionHostedPluginConfigInline).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginParamInline.source',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UFJJVkFURS1yZXBsYWNlbWVudC1hcmNoaXZl","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginConfigInline).copyWith(
          source: (replacement as AgentSessionHostedPluginConfigInline).source,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginResource.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginResourceInline).copyWith(
          description: (replacement as AgentSessionHostedPluginResourceInline)
              .description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginResource.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginResourceInline).copyWith(
          name: (replacement as AgentSessionHostedPluginResourceInline).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginResourceInline.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginResourceInline).copyWith(
          description: (replacement as AgentSessionHostedPluginResourceInline)
              .description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedPluginResourceInline.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedPluginResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedPluginResourceInline).copyWith(
          name: (replacement as AgentSessionHostedPluginResourceInline).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParam.skill_id',
    original: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture-replacement","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionHostedSkillConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigSkillReference).copyWith(
          skillId: (replacement as AgentSessionHostedSkillConfigSkillReference)
              .skillId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParam.version',
    original: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":null}''',
    ),
    parse: (value) =>
        AgentSessionHostedSkillConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigSkillReference).copyWith(
          version: (replacement as AgentSessionHostedSkillConfigSkillReference)
              .version,
          clearVersion: replacement.clearVersion,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParamInline.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigInline).copyWith(
          description:
              (replacement as AgentSessionHostedSkillConfigInline).description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParamInline.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigInline).copyWith(
          name: (replacement as AgentSessionHostedSkillConfigInline).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParamInline.source',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","source":{"data":"UFJJVkFURS1yZXBsYWNlbWVudC1hcmNoaXZl","media_type":"application/zip","type":"base64"},"type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigInline).copyWith(
          source: (replacement as AgentSessionHostedSkillConfigInline).source,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParamSkillReference.skill_id',
    original: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture-replacement","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigSkillReference).copyWith(
          skillId: (replacement as AgentSessionHostedSkillConfigSkillReference)
              .skillId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillParamSkillReference.version',
    original: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"skill_id":"PRIVATE-fixture","type":"skill_reference","version":null}''',
    ),
    parse: (value) => AgentSessionHostedSkillConfigSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillConfigSkillReference).copyWith(
          version: (replacement as AgentSessionHostedSkillConfigSkillReference)
              .version,
          clearVersion: replacement.clearVersion,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResource.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          description:
              (replacement as AgentSessionHostedSkillResourceSkillReference)
                  .description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResource.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          name: (replacement as AgentSessionHostedSkillResourceSkillReference)
              .name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResource.skill_id',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture-replacement","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          skillId:
              (replacement as AgentSessionHostedSkillResourceSkillReference)
                  .skillId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResource.version',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          version:
              (replacement as AgentSessionHostedSkillResourceSkillReference)
                  .version,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResourceInline.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceInline).copyWith(
          description: (replacement as AgentSessionHostedSkillResourceInline)
              .description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResourceInline.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","type":"inline"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceInline.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceInline).copyWith(
          name: (replacement as AgentSessionHostedSkillResourceInline).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResourceSkillReference.description',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          description:
              (replacement as AgentSessionHostedSkillResourceSkillReference)
                  .description,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResourceSkillReference.name',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          name: (replacement as AgentSessionHostedSkillResourceSkillReference)
              .name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResourceSkillReference.skill_id',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture-replacement","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          skillId:
              (replacement as AgentSessionHostedSkillResourceSkillReference)
                  .skillId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'HostedSkillResourceSkillReference.version',
    original: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionHostedSkillResourceSkillReference.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionHostedSkillResourceSkillReference).copyWith(
          version:
              (replacement as AgentSessionHostedSkillResourceSkillReference)
                  .version,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InlineCapabilitySourceParam.data',
    original: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":"UFJJVkFURS1yZXBsYWNlbWVudC1hcmNoaXZl","media_type":"application/zip","type":"base64"}''',
    ),
    parse: (value) => AgentSessionInlineCapabilitySourceConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInlineCapabilitySourceConfigBase64).copyWith(
          data: (replacement as AgentSessionInlineCapabilitySourceConfigBase64)
              .data,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InlineCapabilitySourceParamBase64.data',
    original: jsonDecode(
      r'''{"data":"UEsDBAoAAAAAAAoAAA==","media_type":"application/zip","type":"base64"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":"UFJJVkFURS1yZXBsYWNlbWVudC1hcmNoaXZl","media_type":"application/zip","type":"base64"}''',
    ),
    parse: (value) => AgentSessionInlineCapabilitySourceConfigBase64.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInlineCapabilitySourceConfigBase64).copyWith(
          data: (replacement as AgentSessionInlineCapabilitySourceConfigBase64)
              .data,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputContentParam.text',
    original: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"input_text"}''',
    ),
    parse: (value) =>
        AgentSessionInputContent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionInputContentConfigInputText).copyWith(
          text: (replacement as AgentSessionInputContentConfigInputText).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputContentParamInputImage.image_url',
    original: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    replacement: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png-replacement","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionInputContentConfigInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInputContentConfigInputImage).copyWith(
          imageUrl: (replacement as AgentSessionInputContentConfigInputImage)
              .imageUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputContentParamInputText.text',
    original: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"input_text"}''',
    ),
    parse: (value) => AgentSessionInputContentConfigInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInputContentConfigInputText).copyWith(
          text: (replacement as AgentSessionInputContentConfigInputText).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputContentResource.text',
    original: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"input_text"}''',
    ),
    parse: (value) => AgentSessionInputContentResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInputContentResourceInputText).copyWith(
          text: (replacement as AgentSessionInputContentResourceInputText).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputContentResourceInputImage.image_url',
    original: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    replacement: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png-replacement","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionInputContentResourceInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInputContentResourceInputImage).copyWith(
          imageUrl: (replacement as AgentSessionInputContentResourceInputImage)
              .imageUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputContentResourceInputText.text',
    original: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"input_text"}''',
    ),
    parse: (value) => AgentSessionInputContentResourceInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInputContentResourceInputText).copyWith(
          text: (replacement as AgentSessionInputContentResourceInputText).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputMessageParam.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"},{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionInputMessage.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionInputMessage)
        .copyWith(content: (replacement as AgentSessionInputMessage).content),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InputTokensDetailsResource-2.cached_tokens',
    original: jsonDecode(r'''{"cached_tokens":0}'''),
    replacement: jsonDecode(r'''{"cached_tokens":1}'''),
    parse: (value) => AgentSessionInputTokensDetailsResourceDetails.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInputTokensDetailsResourceDetails).copyWith(
          cachedTokens:
              (replacement as AgentSessionInputTokensDetailsResourceDetails)
                  .cachedTokens,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InterruptSubagentCallItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInterruptSubagentCallItemResource).copyWith(
          id: (replacement as AgentSessionInterruptSubagentCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InterruptSubagentCallItemResource.recipient_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture-replacement","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInterruptSubagentCallItemResource).copyWith(
          recipientAgentId:
              (replacement as AgentSessionInterruptSubagentCallItemResource)
                  .recipientAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InterruptSubagentCallItemResource.sender_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInterruptSubagentCallItemResource).copyWith(
          senderAgentId:
              (replacement as AgentSessionInterruptSubagentCallItemResource)
                  .senderAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InterruptSubagentCallItemResource.status',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInterruptSubagentCallItemResource).copyWith(
          status: (replacement as AgentSessionInterruptSubagentCallItemResource)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'InterruptSubagentCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"interrupt_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"interrupt_subagent_call"}''',
    ),
    parse: (value) => AgentSessionInterruptSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionInterruptSubagentCallItemResource).copyWith(
          turnId: (replacement as AgentSessionInterruptSubagentCallItemResource)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.arguments',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":null,"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          arguments: (replacement as AgentSessionMcpCallItemResource).arguments,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.error',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":null,"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          error: (replacement as AgentSessionMcpCallItemResource).error,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          id: (replacement as AgentSessionMcpCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.name',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          name: (replacement as AgentSessionMcpCallItemResource).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.output',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":null,"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          output: (replacement as AgentSessionMcpCallItemResource).output,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.server_label',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          serverLabel:
              (replacement as AgentSessionMcpCallItemResource).serverLabel,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.status',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          status: (replacement as AgentSessionMcpCallItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"mcp_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"error":{"private":{"nested":[1,true,null]}},"id":"PRIVATE-fixture","name":"PRIVATE-fixture","output":{"private":{"nested":[1,true,null]}},"server_label":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"mcp_call"}''',
    ),
    parse: (value) => AgentSessionMcpCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpCallItemResource).copyWith(
          turnId: (replacement as AgentSessionMcpCallItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParam.authorization',
    original: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    replacement: jsonDecode(
      r'''{"authorization":null,"headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransport).copyWith(
          authorization:
              (replacement as AgentSessionMcpHttpTransport).authorization,
          clearAuthorization: replacement.clearAuthorization,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParam.headers',
    original: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    replacement: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":null,"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransport).copyWith(
          headers: (replacement as AgentSessionMcpHttpTransport).headers,
          clearHeaders: replacement.clearHeaders,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParam.server_url',
    original: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    replacement: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture-replacement","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransport).copyWith(
          serverUrl: (replacement as AgentSessionMcpHttpTransport).serverUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamHttp.authorization',
    original: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    replacement: jsonDecode(
      r'''{"authorization":null,"headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpHttpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransport).copyWith(
          authorization:
              (replacement as AgentSessionMcpHttpTransport).authorization,
          clearAuthorization: replacement.clearAuthorization,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamHttp.headers',
    original: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    replacement: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":null,"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpHttpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransport).copyWith(
          headers: (replacement as AgentSessionMcpHttpTransport).headers,
          clearHeaders: replacement.clearHeaders,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamHttp.server_url',
    original: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture","type":"http"}''',
    ),
    replacement: jsonDecode(
      r'''{"authorization":"PRIVATE-fixture","headers":{"fixture":"PRIVATE-value"},"server_url":"PRIVATE-fixture-replacement","type":"http"}''',
    ),
    parse: (value) =>
        AgentSessionMcpHttpTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransport).copyWith(
          serverUrl: (replacement as AgentSessionMcpHttpTransport).serverUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamStdio.args',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":null,"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentSessionMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransport).copyWith(
          args: (replacement as AgentSessionMcpStdioTransport).args,
          clearArgs: replacement.clearArgs,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamStdio.command',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture-replacement","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentSessionMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransport).copyWith(
          command: (replacement as AgentSessionMcpStdioTransport).command,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamStdio.cwd',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture-replacement","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentSessionMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMcpStdioTransport)
        .copyWith(cwd: (replacement as AgentSessionMcpStdioTransport).cwd),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamStdio.env',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":null,"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentSessionMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransport).copyWith(
          env: (replacement as AgentSessionMcpStdioTransport).env,
          clearEnv: replacement.clearEnv,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportConfigParamStdio.env_vars',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env":{"fixture":"PRIVATE-value"},"env_vars":null,"type":"stdio"}''',
    ),
    parse: (value) =>
        AgentSessionMcpStdioTransport.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransport).copyWith(
          envVars: (replacement as AgentSessionMcpStdioTransport).envVars,
          clearEnvVars: replacement.clearEnvVars,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportResource.server_url',
    original: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    replacement: jsonDecode(
      r'''{"server_url":"PRIVATE-fixture-replacement","type":"http"}''',
    ),
    parse: (value) => AgentSessionMcpTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransportResource).copyWith(
          serverUrl:
              (replacement as AgentSessionMcpHttpTransportResource).serverUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportResourceHttp.server_url',
    original: jsonDecode(r'''{"server_url":"PRIVATE-fixture","type":"http"}'''),
    replacement: jsonDecode(
      r'''{"server_url":"PRIVATE-fixture-replacement","type":"http"}''',
    ),
    parse: (value) => AgentSessionMcpHttpTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpHttpTransportResource).copyWith(
          serverUrl:
              (replacement as AgentSessionMcpHttpTransportResource).serverUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportResourceStdio.args',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture","PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) => AgentSessionMcpStdioTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransportResource).copyWith(
          args: (replacement as AgentSessionMcpStdioTransportResource).args,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportResourceStdio.command',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture-replacement","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) => AgentSessionMcpStdioTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransportResource).copyWith(
          command:
              (replacement as AgentSessionMcpStdioTransportResource).command,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportResourceStdio.cwd',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture-replacement","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) => AgentSessionMcpStdioTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransportResource).copyWith(
          cwd: (replacement as AgentSessionMcpStdioTransportResource).cwd,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'McpTransportResourceStdio.env_vars',
    original: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture"],"type":"stdio"}''',
    ),
    replacement: jsonDecode(
      r'''{"args":["PRIVATE-fixture"],"command":"PRIVATE-fixture","cwd":"PRIVATE-fixture","env_vars":["PRIVATE-fixture","PRIVATE-fixture"],"type":"stdio"}''',
    ),
    parse: (value) => AgentSessionMcpStdioTransportResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMcpStdioTransportResource).copyWith(
          envVars:
              (replacement as AgentSessionMcpStdioTransportResource).envVars,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageContentResource.text',
    original: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"input_text"}''',
    ),
    parse: (value) =>
        AgentSessionMessageContent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageContentResourceInputText).copyWith(
          text:
              (replacement as AgentSessionMessageContentResourceInputText).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageContentResourceInputImage.image_url',
    original: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png","type":"input_image"}''',
    ),
    replacement: jsonDecode(
      r'''{"image_url":"https://example.invalid/image.png-replacement","type":"input_image"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceInputImage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageContentResourceInputImage).copyWith(
          imageUrl:
              (replacement as AgentSessionMessageContentResourceInputImage)
                  .imageUrl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageContentResourceInputText.text',
    original: jsonDecode(r'''{"text":"PRIVATE-fixture","type":"input_text"}'''),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"input_text"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceInputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageContentResourceInputText).copyWith(
          text:
              (replacement as AgentSessionMessageContentResourceInputText).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageContentResourceOutputText.text',
    original: jsonDecode(
      r'''{"text":"PRIVATE-fixture","type":"output_text"}''',
    ),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"output_text"}''',
    ),
    parse: (value) => AgentSessionMessageContentResourceOutputText.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageContentResourceOutputText).copyWith(
          text: (replacement as AgentSessionMessageContentResourceOutputText)
              .text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageItemResource.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"},{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          content: (replacement as AgentSessionMessageItemResource).content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageItemResource.id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":null,"phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          id: (replacement as AgentSessionMessageItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageItemResource.phase',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":null,"role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          phase: (replacement as AgentSessionMessageItemResource).phase,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageItemResource.role',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          role: (replacement as AgentSessionMessageItemResource).role,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageItemResource.status',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"completed","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          status: (replacement as AgentSessionMessageItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'MessageItemResource.turn_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"message"}''',
    ),
    parse: (value) => AgentSessionMessageItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          turnId: (replacement as AgentSessionMessageItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'NetworkPolicyParam.access',
    original: jsonDecode(
      r'''{"access":"restricted","allowed_domains":[],"blocked_domains":[]}''',
    ),
    replacement: jsonDecode(
      r'''{"access":"enabled","allowed_domains":[],"blocked_domains":[]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionNetworkPolicyConfig).copyWith(
          access: (replacement as AgentSessionNetworkPolicyConfig).access,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'NetworkPolicyParam.allowed_domains',
    original: jsonDecode(
      r'''{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]}''',
    ),
    replacement: jsonDecode(
      r'''{"access":"restricted","allowed_domains":null,"blocked_domains":["blocked.example.invalid"]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionNetworkPolicyConfig).copyWith(
          allowedDomains:
              (replacement as AgentSessionNetworkPolicyConfig).allowedDomains,
          clearAllowedDomains: replacement.clearAllowedDomains,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'NetworkPolicyParam.blocked_domains',
    original: jsonDecode(
      r'''{"access":"restricted","allowed_domains":[],"blocked_domains":["blocked.example.invalid"]}''',
    ),
    replacement: jsonDecode(
      r'''{"access":"restricted","allowed_domains":[],"blocked_domains":null}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyConfig.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionNetworkPolicyConfig).copyWith(
          blockedDomains:
              (replacement as AgentSessionNetworkPolicyConfig).blockedDomains,
          clearBlockedDomains: replacement.clearBlockedDomains,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'NetworkPolicyResource.access',
    original: jsonDecode(
      r'''{"access":"enabled","allowed_domains":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"access":"disabled","allowed_domains":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionNetworkPolicyResource).copyWith(
          access: (replacement as AgentSessionNetworkPolicyResource).access,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'NetworkPolicyResource.allowed_domains',
    original: jsonDecode(
      r'''{"access":"enabled","allowed_domains":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"access":"enabled","allowed_domains":["PRIVATE-fixture","PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSessionNetworkPolicyResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionNetworkPolicyResource).copyWith(
          allowedDomains:
              (replacement as AgentSessionNetworkPolicyResource).allowedDomains,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'OutputTextResource.text',
    original: jsonDecode(
      r'''{"text":"PRIVATE-fixture","type":"output_text"}''',
    ),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"output_text"}''',
    ),
    parse: (value) =>
        AgentSessionOutputTextResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionOutputTextResource).copyWith(
          text: (replacement as AgentSessionOutputTextResource).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'OutputTokensDetailsResource-2.reasoning_tokens',
    original: jsonDecode(r'''{"reasoning_tokens":0}'''),
    replacement: jsonDecode(r'''{"reasoning_tokens":1}'''),
    parse: (value) => AgentSessionOutputTokensDetailsResourceDetails.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionOutputTokensDetailsResourceDetails).copyWith(
          reasoningTokens:
              (replacement as AgentSessionOutputTokensDetailsResourceDetails)
                  .reasoningTokens,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    parse: (value) => AgentSessionReasoningItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionReasoningItemResource).copyWith(
          id: (replacement as AgentSessionReasoningItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningItemResource.status',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":null,"summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    parse: (value) => AgentSessionReasoningItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionReasoningItemResource).copyWith(
          status: (replacement as AgentSessionReasoningItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningItemResource.summary',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"},{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    parse: (value) => AgentSessionReasoningItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionReasoningItemResource).copyWith(
          summary: (replacement as AgentSessionReasoningItemResource).summary,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ReasoningItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture","type":"reasoning"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","status":"in_progress","summary":[{"text":"PRIVATE-fixture","type":"summary_text"}],"turn_id":"PRIVATE-fixture-replacement","type":"reasoning"}''',
    ),
    parse: (value) => AgentSessionReasoningItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionReasoningItemResource).copyWith(
          turnId: (replacement as AgentSessionReasoningItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ResumeSubagentCallItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionResumeSubagentCallItemResource).copyWith(
          id: (replacement as AgentSessionResumeSubagentCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ResumeSubagentCallItemResource.recipient_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture-replacement","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionResumeSubagentCallItemResource).copyWith(
          recipientAgentId:
              (replacement as AgentSessionResumeSubagentCallItemResource)
                  .recipientAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ResumeSubagentCallItemResource.sender_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionResumeSubagentCallItemResource).copyWith(
          senderAgentId:
              (replacement as AgentSessionResumeSubagentCallItemResource)
                  .senderAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ResumeSubagentCallItemResource.status',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionResumeSubagentCallItemResource).copyWith(
          status: (replacement as AgentSessionResumeSubagentCallItemResource)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'ResumeSubagentCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"resume_subagent_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"resume_subagent_call"}''',
    ),
    parse: (value) => AgentSessionResumeSubagentCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionResumeSubagentCallItemResource).copyWith(
          turnId: (replacement as AgentSessionResumeSubagentCallItemResource)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SendSubagentInputCallItemResource.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"},{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSendSubagentInputCallItemResource).copyWith(
          content:
              (replacement as AgentSessionSendSubagentInputCallItemResource)
                  .content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SendSubagentInputCallItemResource.id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture-replacement","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSendSubagentInputCallItemResource).copyWith(
          id: (replacement as AgentSessionSendSubagentInputCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SendSubagentInputCallItemResource.recipient_agent_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture-replacement","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSendSubagentInputCallItemResource).copyWith(
          recipientAgentId:
              (replacement as AgentSessionSendSubagentInputCallItemResource)
                  .recipientAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SendSubagentInputCallItemResource.sender_agent_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSendSubagentInputCallItemResource).copyWith(
          senderAgentId:
              (replacement as AgentSessionSendSubagentInputCallItemResource)
                  .senderAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SendSubagentInputCallItemResource.status',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSendSubagentInputCallItemResource).copyWith(
          status: (replacement as AgentSessionSendSubagentInputCallItemResource)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SendSubagentInputCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"send_subagent_input_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","recipient_agent_id":"PRIVATE-fixture","sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"send_subagent_input_call"}''',
    ),
    parse: (value) => AgentSessionSendSubagentInputCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSendSubagentInputCallItemResource).copyWith(
          turnId: (replacement as AgentSessionSendSubagentInputCallItemResource)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.instructions',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentConfig).copyWith(
          instructions: (replacement as AgentSessionAgentConfig).instructions,
          clearInstructions: replacement.clearInstructions,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.model',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgentConfig)
        .copyWith(model: (replacement as AgentSessionAgentConfig).model),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.multi_agent',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":null,"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentConfig).copyWith(
          multiAgent: (replacement as AgentSessionAgentConfig).multiAgent,
          clearMultiAgent: replacement.clearMultiAgent,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.reasoning',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":null,"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentConfig).copyWith(
          reasoning: (replacement as AgentSessionAgentConfig).reasoning,
          clearReasoning: replacement.clearReasoning,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.service_tier',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":null,"text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentConfig).copyWith(
          serviceTier: (replacement as AgentSessionAgentConfig).serviceTier,
          clearServiceTier: replacement.clearServiceTier,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.text',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":null,"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentConfig).copyWith(
          text: (replacement as AgentSessionAgentConfig).text,
          clearText: replacement.clearText,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentConfigParam.tools',
    original: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":null}''',
    ),
    parse: (value) =>
        AgentSessionAgentConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentConfig).copyWith(
          tools: (replacement as AgentSessionAgentConfig).tools,
          clearTools: replacement.clearTools,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      id: (replacement as AgentSessionAgent).id,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.instructions',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":null,"model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      instructions: (replacement as AgentSessionAgent).instructions,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.model',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture-replacement","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      model: (replacement as AgentSessionAgent).model,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.multi_agent',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":true,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      multiAgent: (replacement as AgentSessionAgent).multiAgent,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.name',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":null,"reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      name: (replacement as AgentSessionAgent).name,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.reasoning',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"minimal","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      reasoning: (replacement as AgentSessionAgent).reasoning,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.service_tier',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"default","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      serviceTier: (replacement as AgentSessionAgent).serviceTier,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.text',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"schema":{"fixture":"PRIVATE-value"},"type":"json_schema"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      text: (replacement as AgentSessionAgent).text,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionAgentResource.tools',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"},{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]}''',
    ),
    parse: (value) =>
        AgentSessionAgent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgent).copyWith(
      tools: (replacement as AgentSessionAgent).tools,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentErrorResource.code',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentErrorResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentErrorResource).copyWith(
          code: (replacement as AgentSessionEnvironmentErrorResource).code,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentErrorResource.message',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture-replacement","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentErrorResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentErrorResource).copyWith(
          message:
              (replacement as AgentSessionEnvironmentErrorResource).message,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentErrorResource.type',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionEnvironmentErrorResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentErrorResource).copyWith(
          type: (replacement as AgentSessionEnvironmentErrorResource).type,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentStateResource.error',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":null,"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentStateResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentStateResource).copyWith(
          error: (replacement as AgentSessionEnvironmentStateResource).error,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentStateResource.id',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture-replacement","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentStateResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentStateResource).copyWith(
          id: (replacement as AgentSessionEnvironmentStateResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentStateResource.status',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"ready","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionEnvironmentStateResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentStateResource).copyWith(
          status: (replacement as AgentSessionEnvironmentStateResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEnvironmentStateResource.type',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) => AgentSessionEnvironmentStateResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentStateResource).copyWith(
          type: (replacement as AgentSessionEnvironmentStateResource).type,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionErrorResource.code',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":null,"message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorResource)
        .copyWith(code: (replacement as AgentSessionErrorResource).code),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionErrorResource.message',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture-replacement","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorResource)
        .copyWith(message: (replacement as AgentSessionErrorResource).message),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionErrorResource.param',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":null,"type":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorResource)
        .copyWith(param: (replacement as AgentSessionErrorResource).param),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionErrorResource.type',
    original: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) =>
        AgentSessionErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorResource)
        .copyWith(type: (replacement as AgentSessionErrorResource).type),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEvent.error',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorEvent)
        .copyWith(error: (replacement as AgentSessionErrorEvent).error),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEvent.event_id',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorEvent)
        .copyWith(eventId: (replacement as AgentSessionErrorEvent).eventId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEvent.session_id',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorEvent)
        .copyWith(sessionId: (replacement as AgentSessionErrorEvent).sessionId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentOutputCommandExecutionOutputDelta.delta',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture-replacement","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(
              delta:
                  (replacement
                          as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
                      .delta,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentOutputCommandExecutionOutputDelta.event_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(
              eventId:
                  (replacement
                          as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
                      .eventId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentOutputCommandExecutionOutputDelta.item_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(
              itemId:
                  (replacement
                          as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
                      .itemId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentOutputCommandExecutionOutputDelta.output_index',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(
              outputIndex:
                  (replacement
                          as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
                      .outputIndex,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentOutputCommandExecutionOutputDelta.session_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(
              sessionId:
                  (replacement
                          as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
                      .sessionId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentOutputCommandExecutionOutputDelta.turn_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.output.command_execution_output.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.output.command_execution_output.delta"}''',
    ),
    parse: (value) =>
        AgentSessionAgentOutputCommandExecutionOutputDeltaEvent.fromJson(
          value! as Map<String, dynamic>,
        ),
    copy: (original, replacement) =>
        (original as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
            .copyWith(
              turnId:
                  (replacement
                          as AgentSessionAgentOutputCommandExecutionOutputDeltaEvent)
                      .turnId,
            ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionCreated.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.created"}''',
    ),
    parse: (value) =>
        AgentSessionCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionCreatedEvent)
        .copyWith(eventId: (replacement as AgentSessionCreatedEvent).eventId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionCreated.session',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.created"}''',
    ),
    parse: (value) =>
        AgentSessionCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionCreatedEvent)
        .copyWith(session: (replacement as AgentSessionCreatedEvent).session),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentConnected.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentConnectedEvent).copyWith(
          environment: (replacement as AgentSessionEnvironmentConnectedEvent)
              .environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentConnected.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentConnectedEvent).copyWith(
          eventId:
              (replacement as AgentSessionEnvironmentConnectedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentConnected.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentConnectedEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentConnectedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentConnected.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.connected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.connected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentConnectedEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentConnectedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentDisconnected.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentDisconnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentDisconnectedEvent).copyWith(
          environment: (replacement as AgentSessionEnvironmentDisconnectedEvent)
              .environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentDisconnected.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentDisconnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentDisconnectedEvent).copyWith(
          eventId:
              (replacement as AgentSessionEnvironmentDisconnectedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentDisconnected.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentDisconnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentDisconnectedEvent).copyWith(
          sessionId: (replacement as AgentSessionEnvironmentDisconnectedEvent)
              .sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentDisconnected.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.disconnected"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.disconnected"}''',
    ),
    parse: (value) => AgentSessionEnvironmentDisconnectedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentDisconnectedEvent).copyWith(
          turnId:
              (replacement as AgentSessionEnvironmentDisconnectedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentExpired.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    parse: (value) => AgentSessionEnvironmentExpiredEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentExpiredEvent).copyWith(
          environment:
              (replacement as AgentSessionEnvironmentExpiredEvent).environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentExpired.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    parse: (value) => AgentSessionEnvironmentExpiredEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentExpiredEvent).copyWith(
          eventId: (replacement as AgentSessionEnvironmentExpiredEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentExpired.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    parse: (value) => AgentSessionEnvironmentExpiredEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentExpiredEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentExpiredEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentExpired.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.expired"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.expired"}''',
    ),
    parse: (value) => AgentSessionEnvironmentExpiredEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentExpiredEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentExpiredEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentFailed.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    parse: (value) => AgentSessionEnvironmentFailedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentFailedEvent).copyWith(
          environment:
              (replacement as AgentSessionEnvironmentFailedEvent).environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentFailed.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    parse: (value) => AgentSessionEnvironmentFailedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentFailedEvent).copyWith(
          eventId: (replacement as AgentSessionEnvironmentFailedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentFailed.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    parse: (value) => AgentSessionEnvironmentFailedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentFailedEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentFailedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentFailed.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.failed"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.failed"}''',
    ),
    parse: (value) => AgentSessionEnvironmentFailedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentFailedEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentFailedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentPending.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    parse: (value) => AgentSessionEnvironmentPendingEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPendingEvent).copyWith(
          environment:
              (replacement as AgentSessionEnvironmentPendingEvent).environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentPending.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    parse: (value) => AgentSessionEnvironmentPendingEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPendingEvent).copyWith(
          eventId: (replacement as AgentSessionEnvironmentPendingEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentPending.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    parse: (value) => AgentSessionEnvironmentPendingEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPendingEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentPendingEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentPending.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.pending"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.pending"}''',
    ),
    parse: (value) => AgentSessionEnvironmentPendingEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentPendingEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentPendingEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReady.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    parse: (value) => AgentSessionEnvironmentReadyEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentReadyEvent).copyWith(
          environment:
              (replacement as AgentSessionEnvironmentReadyEvent).environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReady.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    parse: (value) => AgentSessionEnvironmentReadyEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentReadyEvent).copyWith(
          eventId: (replacement as AgentSessionEnvironmentReadyEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReady.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    parse: (value) => AgentSessionEnvironmentReadyEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentReadyEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentReadyEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReady.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.ready"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.ready"}''',
    ),
    parse: (value) => AgentSessionEnvironmentReadyEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentReadyEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentReadyEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReset.environment_id',
    original: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture-replacement","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    parse: (value) => AgentSessionEnvironmentResetEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentResetEvent).copyWith(
          environmentId:
              (replacement as AgentSessionEnvironmentResetEvent).environmentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReset.event_id',
    original: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture-replacement","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    parse: (value) => AgentSessionEnvironmentResetEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentResetEvent).copyWith(
          eventId: (replacement as AgentSessionEnvironmentResetEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReset.reset_count',
    original: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":1,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    parse: (value) => AgentSessionEnvironmentResetEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentResetEvent).copyWith(
          resetCount:
              (replacement as AgentSessionEnvironmentResetEvent).resetCount,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReset.session_id',
    original: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    parse: (value) => AgentSessionEnvironmentResetEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentResetEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentResetEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentReset.turn_id',
    original: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.reset"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","event_id":"PRIVATE-fixture","reset_count":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.reset"}''',
    ),
    parse: (value) => AgentSessionEnvironmentResetEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentResetEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentResetEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentSuspended.environment',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    parse: (value) => AgentSessionEnvironmentSuspendedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentSuspendedEvent).copyWith(
          environment: (replacement as AgentSessionEnvironmentSuspendedEvent)
              .environment,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentSuspended.event_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    parse: (value) => AgentSessionEnvironmentSuspendedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentSuspendedEvent).copyWith(
          eventId:
              (replacement as AgentSessionEnvironmentSuspendedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentSuspended.session_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    parse: (value) => AgentSessionEnvironmentSuspendedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentSuspendedEvent).copyWith(
          sessionId:
              (replacement as AgentSessionEnvironmentSuspendedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionEnvironmentSuspended.turn_id',
    original: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.environment.suspended"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment":{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","type":"PRIVATE-fixture"},"id":"PRIVATE-fixture","status":"pending","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.environment.suspended"}''',
    ),
    parse: (value) => AgentSessionEnvironmentSuspendedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentSuspendedEvent).copyWith(
          turnId: (replacement as AgentSessionEnvironmentSuspendedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionFailed.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.failed"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.failed"}''',
    ),
    parse: (value) =>
        AgentSessionFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionFailedEvent)
        .copyWith(eventId: (replacement as AgentSessionFailedEvent).eventId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionFailed.session',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.failed"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.failed"}''',
    ),
    parse: (value) =>
        AgentSessionFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionFailedEvent)
        .copyWith(session: (replacement as AgentSessionFailedEvent).session),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionIdle.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.idle"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.idle"}''',
    ),
    parse: (value) =>
        AgentSessionIdleEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionIdleEvent)
        .copyWith(eventId: (replacement as AgentSessionIdleEvent).eventId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionIdle.session',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.idle"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.idle"}''',
    ),
    parse: (value) =>
        AgentSessionIdleEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionIdleEvent)
        .copyWith(session: (replacement as AgentSessionIdleEvent).session),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionInProgress.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.in_progress"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.in_progress"}''',
    ),
    parse: (value) =>
        AgentSessionInProgressEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionInProgressEvent).copyWith(
          eventId: (replacement as AgentSessionInProgressEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionInProgress.session',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.in_progress"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.in_progress"}''',
    ),
    parse: (value) =>
        AgentSessionInProgressEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionInProgressEvent).copyWith(
          session: (replacement as AgentSessionInProgressEvent).session,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionRequiresAction.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.requires_action"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.requires_action"}''',
    ),
    parse: (value) => AgentSessionRequiresActionEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionRequiresActionEvent).copyWith(
          eventId: (replacement as AgentSessionRequiresActionEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionRequiresAction.session',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.requires_action"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session":{"agent":{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},"type":"agent.session.requires_action"}''',
    ),
    parse: (value) => AgentSessionRequiresActionEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionRequiresActionEvent).copyWith(
          session: (replacement as AgentSessionRequiresActionEvent).session,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionSubagentActive.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.active"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.active"}''',
    ),
    parse: (value) => AgentSessionSubagentActiveEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSubagentActiveEvent).copyWith(
          eventId: (replacement as AgentSessionSubagentActiveEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionSubagentActive.subagent',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.active"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":1,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.active"}''',
    ),
    parse: (value) => AgentSessionSubagentActiveEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSubagentActiveEvent).copyWith(
          subagent: (replacement as AgentSessionSubagentActiveEvent).subagent,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionSubagentClosed.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.closed"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.closed"}''',
    ),
    parse: (value) => AgentSessionSubagentClosedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSubagentClosedEvent).copyWith(
          eventId: (replacement as AgentSessionSubagentClosedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionSubagentClosed.subagent',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.closed"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":1,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.closed"}''',
    ),
    parse: (value) => AgentSessionSubagentClosedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSubagentClosedEvent).copyWith(
          subagent: (replacement as AgentSessionSubagentClosedEvent).subagent,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionSubagentCreated.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.created"}''',
    ),
    parse: (value) => AgentSessionSubagentCreatedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSubagentCreatedEvent).copyWith(
          eventId: (replacement as AgentSessionSubagentCreatedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionSubagentCreated.subagent',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","subagent":{"closed_at":1,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"},"type":"agent.session.subagent.created"}''',
    ),
    parse: (value) => AgentSessionSubagentCreatedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSubagentCreatedEvent).copyWith(
          subagent: (replacement as AgentSessionSubagentCreatedEvent).subagent,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCancelled.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCancelledEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCancelledEvent).copyWith(
          eventId: (replacement as AgentSessionTurnCancelledEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCancelled.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCancelledEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCancelledEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnCancelledEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCancelled.turn',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture-replacement","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCancelledEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCancelledEvent).copyWith(
          turn: (replacement as AgentSessionTurnCancelledEvent).turn,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCancelled.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture-replacement","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCancelledEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCancelledEvent).copyWith(
          turnId: (replacement as AgentSessionTurnCancelledEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCancelled.usage',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.cancelled","usage":null}''',
    ),
    parse: (value) =>
        AgentSessionTurnCancelledEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCancelledEvent).copyWith(
          usage: (replacement as AgentSessionTurnCancelledEvent).usage,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCompleted.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCompletedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCompletedEvent).copyWith(
          eventId: (replacement as AgentSessionTurnCompletedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCompleted.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCompletedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCompletedEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnCompletedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCompleted.turn',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture-replacement","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCompletedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCompletedEvent).copyWith(
          turn: (replacement as AgentSessionTurnCompletedEvent).turn,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCompleted.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture-replacement","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnCompletedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCompletedEvent).copyWith(
          turnId: (replacement as AgentSessionTurnCompletedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCompleted.usage',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.completed","usage":null}''',
    ),
    parse: (value) =>
        AgentSessionTurnCompletedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCompletedEvent).copyWith(
          usage: (replacement as AgentSessionTurnCompletedEvent).usage,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.content_index',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":1,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          contentIndex: (replacement as AgentSessionTurnContentPartAddedEvent)
              .contentIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.event_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnContentPartAddedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.item_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          itemId: (replacement as AgentSessionTurnContentPartAddedEvent).itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.output_index',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          outputIndex: (replacement as AgentSessionTurnContentPartAddedEvent)
              .outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.part',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture-replacement","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          part: (replacement as AgentSessionTurnContentPartAddedEvent).part,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.session_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnContentPartAddedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartAdded.turn_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.content_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartAddedEvent).copyWith(
          turnId: (replacement as AgentSessionTurnContentPartAddedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.content_index',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":1,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          contentIndex: (replacement as AgentSessionTurnContentPartDoneEvent)
              .contentIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.event_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnContentPartDoneEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.item_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          itemId: (replacement as AgentSessionTurnContentPartDoneEvent).itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.output_index',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnContentPartDoneEvent).outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.part',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture-replacement","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          part: (replacement as AgentSessionTurnContentPartDoneEvent).part,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.session_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnContentPartDoneEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnContentPartDone.turn_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.content_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"output_text"},"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.content_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnContentPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnContentPartDoneEvent).copyWith(
          turnId: (replacement as AgentSessionTurnContentPartDoneEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCreated.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    parse: (value) =>
        AgentSessionTurnCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCreatedEvent).copyWith(
          eventId: (replacement as AgentSessionTurnCreatedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCreated.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    parse: (value) =>
        AgentSessionTurnCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnCreatedEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnCreatedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCreated.turn',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture-replacement","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    parse: (value) =>
        AgentSessionTurnCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnCreatedEvent)
        .copyWith(turn: (replacement as AgentSessionTurnCreatedEvent).turn),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnCreated.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.created"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture-replacement","type":"agent.session.turn.created"}''',
    ),
    parse: (value) =>
        AgentSessionTurnCreatedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnCreatedEvent)
        .copyWith(turnId: (replacement as AgentSessionTurnCreatedEvent).turnId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnFailed.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnFailedEvent).copyWith(
          eventId: (replacement as AgentSessionTurnFailedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnFailed.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnFailedEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnFailedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnFailed.turn',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture-replacement","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnFailedEvent)
        .copyWith(turn: (replacement as AgentSessionTurnFailedEvent).turn),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnFailed.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture-replacement","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) =>
        AgentSessionTurnFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnFailedEvent)
        .copyWith(turnId: (replacement as AgentSessionTurnFailedEvent).turnId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnFailed.usage',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.failed","usage":null}''',
    ),
    parse: (value) =>
        AgentSessionTurnFailedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnFailedEvent)
        .copyWith(usage: (replacement as AgentSessionTurnFailedEvent).usage),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnInProgress.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    parse: (value) => AgentSessionTurnInProgressEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnInProgressEvent).copyWith(
          eventId: (replacement as AgentSessionTurnInProgressEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnInProgress.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    parse: (value) => AgentSessionTurnInProgressEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnInProgressEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnInProgressEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnInProgress.turn',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture-replacement","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    parse: (value) => AgentSessionTurnInProgressEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnInProgressEvent).copyWith(
          turn: (replacement as AgentSessionTurnInProgressEvent).turn,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnInProgress.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture","type":"agent.session.turn.in_progress"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","turn":{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}},"turn_id":"PRIVATE-fixture-replacement","type":"agent.session.turn.in_progress"}''',
    ),
    parse: (value) => AgentSessionTurnInProgressEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnInProgressEvent).copyWith(
          turnId: (replacement as AgentSessionTurnInProgressEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemAdded.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemAddedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemAddedEvent).copyWith(
          eventId: (replacement as AgentSessionTurnItemAddedEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemAdded.item',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"},{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemAddedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemAddedEvent).copyWith(
          item: (replacement as AgentSessionTurnItemAddedEvent).item,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemAdded.output_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":null,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemAddedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemAddedEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnItemAddedEvent).outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemAdded.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemAddedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemAddedEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnItemAddedEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemAdded.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.item.added"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemAddedEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemAddedEvent).copyWith(
          turnId: (replacement as AgentSessionTurnItemAddedEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemDone.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemDoneEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemDoneEvent).copyWith(
          eventId: (replacement as AgentSessionTurnItemDoneEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemDone.item',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"},{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemDoneEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnItemDoneEvent)
        .copyWith(item: (replacement as AgentSessionTurnItemDoneEvent).item),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemDone.output_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":1,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemDoneEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemDoneEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnItemDoneEvent).outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemDone.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemDoneEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemDoneEvent).copyWith(
          sessionId: (replacement as AgentSessionTurnItemDoneEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnItemDone.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.item.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item":{"content":[{"text":"PRIVATE-fixture","type":"output_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"},"output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.item.done"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItemDoneEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnItemDoneEvent).copyWith(
          turnId: (replacement as AgentSessionTurnItemDoneEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.content_index',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":1,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          contentIndex: (replacement as AgentSessionTurnOutputTextDeltaEvent)
              .contentIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.delta',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture-replacement","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          delta: (replacement as AgentSessionTurnOutputTextDeltaEvent).delta,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.event_id',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnOutputTextDeltaEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.item_id',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          itemId: (replacement as AgentSessionTurnOutputTextDeltaEvent).itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.output_index',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnOutputTextDeltaEvent).outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.session_id',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnOutputTextDeltaEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDelta.turn_id',
    original: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.output_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDeltaEvent).copyWith(
          turnId: (replacement as AgentSessionTurnOutputTextDeltaEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.content_index',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":1,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          contentIndex:
              (replacement as AgentSessionTurnOutputTextDoneEvent).contentIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.event_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          eventId: (replacement as AgentSessionTurnOutputTextDoneEvent).eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.item_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          itemId: (replacement as AgentSessionTurnOutputTextDoneEvent).itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.output_index',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnOutputTextDoneEvent).outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.session_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture-replacement","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnOutputTextDoneEvent).sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.text',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          text: (replacement as AgentSessionTurnOutputTextDoneEvent).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnOutputTextDone.turn_id',
    original: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.output_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"content_index":0,"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","text":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.output_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnOutputTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnOutputTextDoneEvent).copyWith(
          turnId: (replacement as AgentSessionTurnOutputTextDoneEvent).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
                  .eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.item_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          itemId:
              (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
                  .itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.output_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
                  .outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.part',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture-replacement","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          part: (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
              .part,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture-replacement","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
                  .sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.summary_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":1,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          summaryIndex:
              (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
                  .summaryIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartAdded.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":null,"type":"agent.session.turn.reasoning_summary_part.added"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartAddedEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartAddedEvent).copyWith(
          turnId:
              (replacement as AgentSessionTurnReasoningSummaryPartAddedEvent)
                  .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
                  .eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.item_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          itemId: (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
              .itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.output_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
                  .outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.part',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture-replacement","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          part: (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
              .part,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture-replacement","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
                  .sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.status',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":null,"summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          status: (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.summary_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":1,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          summaryIndex:
              (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
                  .summaryIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryPartDone.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"part":{"text":"PRIVATE-fixture","type":"summary_text"},"session_id":"PRIVATE-fixture","status":"incomplete","summary_index":0,"turn_id":null,"type":"agent.session.turn.reasoning_summary_part.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryPartDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryPartDoneEvent).copyWith(
          turnId: (replacement as AgentSessionTurnReasoningSummaryPartDoneEvent)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.delta',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture-replacement","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          delta: (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
              .delta,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.event_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
                  .eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.item_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          itemId:
              (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
                  .itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.output_index',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
                  .outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.session_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture-replacement","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
                  .sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.summary_index',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":1,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          summaryIndex:
              (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
                  .summaryIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDelta.turn_id',
    original: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    replacement: jsonDecode(
      r'''{"delta":"PRIVATE-fixture","event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"turn_id":null,"type":"agent.session.turn.reasoning_summary_text.delta"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDeltaEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDeltaEvent).copyWith(
          turnId:
              (replacement as AgentSessionTurnReasoningSummaryTextDeltaEvent)
                  .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.event_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture-replacement","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          eventId:
              (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
                  .eventId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.item_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture-replacement","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          itemId: (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
              .itemId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.output_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":1,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          outputIndex:
              (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
                  .outputIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.session_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture-replacement","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          sessionId:
              (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
                  .sessionId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.summary_index',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":1,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          summaryIndex:
              (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
                  .summaryIndex,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.text',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          text: (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
              .text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventAgentSessionTurnReasoningSummaryTextDone.turn_id',
    original: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    replacement: jsonDecode(
      r'''{"event_id":"PRIVATE-fixture","item_id":"PRIVATE-fixture","output_index":0,"session_id":"PRIVATE-fixture","summary_index":0,"text":"PRIVATE-fixture","turn_id":null,"type":"agent.session.turn.reasoning_summary_text.done"}''',
    ),
    parse: (value) => AgentSessionTurnReasoningSummaryTextDoneEvent.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionTurnReasoningSummaryTextDoneEvent).copyWith(
          turnId: (replacement as AgentSessionTurnReasoningSummaryTextDoneEvent)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventError.error',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture-replacement","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionErrorEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorEvent)
        .copyWith(error: (replacement as AgentSessionErrorEvent).error),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventError.event_id',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionErrorEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorEvent)
        .copyWith(eventId: (replacement as AgentSessionErrorEvent).eventId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionEventError.session_id',
    original: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","type":"error"}''',
    ),
    replacement: jsonDecode(
      r'''{"error":{"code":"PRIVATE-fixture","message":"PRIVATE-fixture","param":"PRIVATE-fixture","type":"PRIVATE-fixture"},"event_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","type":"error"}''',
    ),
    parse: (value) =>
        AgentSessionErrorEvent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionErrorEvent)
        .copyWith(sessionId: (replacement as AgentSessionErrorEvent).sessionId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParam.request_id',
    original: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture-replacement","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionApprovalResultInput).copyWith(
          requestId: (replacement as AgentSessionApprovalResultInput).requestId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParam.response',
    original: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"},{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    parse: (value) =>
        AgentSessionInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionApprovalResultInput).copyWith(
          response: (replacement as AgentSessionApprovalResultInput).response,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'SessionInputParamAgentSessionInputComputerUseApprovalRequestResult.request_id',
    original: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture-replacement","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    parse: (value) => AgentSessionApprovalResultInput.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionApprovalResultInput).copyWith(
          requestId: (replacement as AgentSessionApprovalResultInput).requestId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name:
        'SessionInputParamAgentSessionInputComputerUseApprovalRequestResult.response',
    original: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"request_id":"PRIVATE-fixture","response":{"action":"submit","fields":[{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"},{"field_id":"PRIVATE-fixture","value":"PRIVATE-fixture"}],"selected_option":"PRIVATE-fixture","type":"browser_authentication"},"type":"agent.session.input.computer_use_approval_request_result"}''',
    ),
    parse: (value) => AgentSessionApprovalResultInput.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionApprovalResultInput).copyWith(
          response: (replacement as AgentSessionApprovalResultInput).response,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParamAgentSessionInputMessage.input',
    original: jsonDecode(
      r'''{"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"type":"agent.session.input.message"}''',
    ),
    replacement: jsonDecode(
      r'''{"input":[{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"},{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"role":"user","type":"message"}],"type":"agent.session.input.message"}''',
    ),
    parse: (value) =>
        AgentSessionMessageInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionMessageInput)
        .copyWith(input: (replacement as AgentSessionMessageInput).input),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParamAgentSessionInputToolResult.call_id',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture-replacement","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    parse: (value) =>
        AgentSessionToolResultInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionToolResultInput)
        .copyWith(callId: (replacement as AgentSessionToolResultInput).callId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParamAgentSessionInputToolResult.error',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":null,"output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    parse: (value) =>
        AgentSessionToolResultInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionToolResultInput).copyWith(
          error: (replacement as AgentSessionToolResultInput).error,
          clearError: replacement.clearError,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParamAgentSessionInputToolResult.output',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":null,"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    parse: (value) =>
        AgentSessionToolResultInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionToolResultInput).copyWith(
          output: (replacement as AgentSessionToolResultInput).output,
          clearOutput: replacement.clearOutput,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParamAgentSessionInputToolResult.success',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":true,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    parse: (value) =>
        AgentSessionToolResultInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionToolResultInput).copyWith(
          success: (replacement as AgentSessionToolResultInput).success,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionInputParamAgentSessionInputToolResult.turn_id',
    original: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture","type":"agent.session.input.tool_result"}''',
    ),
    replacement: jsonDecode(
      r'''{"call_id":"PRIVATE-fixture","error":"PRIVATE-fixture","output":[{"text":"PRIVATE-fixture","type":"input_text"}],"success":false,"turn_id":"PRIVATE-fixture-replacement","type":"agent.session.input.tool_result"}''',
    ),
    parse: (value) =>
        AgentSessionToolResultInput.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionToolResultInput)
        .copyWith(turnId: (replacement as AgentSessionToolResultInput).turnId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionListResource.data',
    original: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]},{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    parse: (value) => AgentSessionList.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionList).copyWith(
      data: (replacement as AgentSessionList).data,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionListResource.first_id',
    original: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":null,"has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    parse: (value) => AgentSessionList.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionList).copyWith(
      firstId: (replacement as AgentSessionList).firstId,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionListResource.has_more',
    original: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":true,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    parse: (value) => AgentSessionList.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionList).copyWith(
      hasMore: (replacement as AgentSessionList).hasMore,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionListResource.last_id',
    original: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":"PRIVATE-fixture","object":"list"}''',
    ),
    replacement: jsonDecode(
      r'''{"data":[{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}],"first_id":"PRIVATE-fixture","has_more":false,"last_id":null,"object":"list"}''',
    ),
    parse: (value) => AgentSessionList.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionList).copyWith(
      lastId: (replacement as AgentSessionList).lastId,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResource.request',
    original: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture-replacement","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionRequiredAction.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequiredAction).copyWith(
          request:
              (replacement as AgentSessionComputerUseApprovalRequiredAction)
                  .request,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResource.request_id',
    original: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionRequiredAction.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequiredAction).copyWith(
          requestId:
              (replacement as AgentSessionComputerUseApprovalRequiredAction)
                  .requestId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResource.turn_id',
    original: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture-replacement","type":"computer_use_approval_request"}''',
    ),
    parse: (value) =>
        AgentSessionRequiredAction.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequiredAction).copyWith(
          turnId: (replacement as AgentSessionComputerUseApprovalRequiredAction)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceComputerUseApprovalRequest.request',
    original: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture-replacement","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequiredAction).copyWith(
          request:
              (replacement as AgentSessionComputerUseApprovalRequiredAction)
                  .request,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceComputerUseApprovalRequest.request_id',
    original: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequiredAction).copyWith(
          requestId:
              (replacement as AgentSessionComputerUseApprovalRequiredAction)
                  .requestId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceComputerUseApprovalRequest.turn_id',
    original: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}''',
    ),
    replacement: jsonDecode(
      r'''{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture-replacement","type":"computer_use_approval_request"}''',
    ),
    parse: (value) => AgentSessionComputerUseApprovalRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionComputerUseApprovalRequiredAction).copyWith(
          turnId: (replacement as AgentSessionComputerUseApprovalRequiredAction)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceEnvironmentConnection.environment_id',
    original: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture","type":"environment_connection"}''',
    ),
    replacement: jsonDecode(
      r'''{"environment_id":"PRIVATE-fixture-replacement","type":"environment_connection"}''',
    ),
    parse: (value) => AgentSessionEnvironmentConnectionRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionEnvironmentConnectionRequiredAction).copyWith(
          environmentId:
              (replacement as AgentSessionEnvironmentConnectionRequiredAction)
                  .environmentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceFunctionCall.arguments',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":null,"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallRequiredAction).copyWith(
          arguments:
              (replacement as AgentSessionFunctionCallRequiredAction).arguments,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceFunctionCall.call_id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture-replacement","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallRequiredAction).copyWith(
          callId:
              (replacement as AgentSessionFunctionCallRequiredAction).callId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceFunctionCall.name',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture-replacement","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallRequiredAction).copyWith(
          name: (replacement as AgentSessionFunctionCallRequiredAction).name,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionRequiredActionResourceFunctionCall.turn_id',
    original: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"function_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"arguments":{"private":{"nested":[1,true,null]}},"call_id":"PRIVATE-fixture","name":"PRIVATE-fixture","turn_id":"PRIVATE-fixture-replacement","type":"function_call"}''',
    ),
    parse: (value) => AgentSessionFunctionCallRequiredAction.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionFunctionCallRequiredAction).copyWith(
          turnId:
              (replacement as AgentSessionFunctionCallRequiredAction).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.agent',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture-replacement","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      agent: (replacement as AgentSession).agent,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.created_at',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":1,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      createdAt: (replacement as AgentSession).createdAt,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.environment',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"capability_directories":["PRIVATE-fixture"],"container_size":"small","desktop":{"enabled":false},"files":[{"file_id":"PRIVATE-fixture","id":"PRIVATE-fixture","path":"PRIVATE-fixture","size_bytes":0,"type":"file_id"}],"id":"PRIVATE-fixture","network":{"access":"enabled","allowed_domains":["PRIVATE-fixture"]},"packages":{"npm":["PRIVATE-fixture"],"python":["PRIVATE-fixture"],"system":["PRIVATE-fixture"]},"plugins":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","type":"inline"}],"skills":[{"description":"PRIVATE-fixture","name":"PRIVATE-fixture","skill_id":"PRIVATE-fixture","type":"skill_reference","version":"PRIVATE-fixture"}],"type":"openai_hosted"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      environment: (replacement as AgentSession).environment,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.error',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":null,"id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      error: (replacement as AgentSession).error,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.id',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture-replacement","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      id: (replacement as AgentSession).id,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.last_active_at',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":1,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      lastActiveAt: (replacement as AgentSession).lastActiveAt,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.metadata',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value","replacement":"PRIVATE-replacement"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      metadata: (replacement as AgentSession).metadata,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.required_actions',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"},{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      requiredActions: (replacement as AgentSession).requiredActions,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.spend_control',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      spendControl: (replacement as AgentSession).spendControl,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.status',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"in_progress","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      status: (replacement as AgentSession).status,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.usage',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":null,"vault_ids":["PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      usage: (replacement as AgentSession).usage,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionResource.vault_ids',
    original: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture"]}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"id":"PRIVATE-fixture","instructions":"PRIVATE-fixture","model":"PRIVATE-fixture","multi_agent":{"enabled":false,"max_concurrent_subagents":1},"name":"PRIVATE-fixture","reasoning":{"effort":"none","summary":"concise"},"service_tier":"auto","text":{"format":{"type":"text"},"verbosity":"low"},"tools":[{"defer_loading":false,"description":"PRIVATE-fixture","name":"PRIVATE-fixture","parameters":{"fixture":"PRIVATE-value"},"type":"function"}]},"created_at":0,"environment":{"type":"none"},"error":"PRIVATE-fixture","id":"PRIVATE-fixture","last_active_at":0,"metadata":{"fixture":"PRIVATE-value"},"object":"agent.session","required_actions":[{"request":{"credential_origin":"PRIVATE-fixture","fields":[{"id":"PRIVATE-fixture","label":"PRIVATE-fixture","required":false,"type":"PRIVATE-fixture"}],"options":[{"field_ids":["PRIVATE-fixture"],"id":"PRIVATE-fixture","label":"PRIVATE-fixture"}],"reason":"PRIVATE-fixture","type":"browser_authentication"},"request_id":"PRIVATE-fixture","turn_id":"PRIVATE-fixture","type":"computer_use_approval_request"}],"spend_control":{"consumed":0,"limit":1},"status":"idle","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0},"vault_ids":["PRIVATE-fixture","PRIVATE-fixture"]}''',
    ),
    parse: (value) => AgentSession.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSession).copyWith(
      vaultIds: (replacement as AgentSession).vaultIds,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionSpendControlParam.limit',
    original: jsonDecode(r'''{"limit":1}'''),
    replacement: jsonDecode(r'''{"limit":null}'''),
    parse: (value) =>
        AgentSessionSpendControlConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionSpendControlConfig).copyWith(
          limit: (replacement as AgentSessionSpendControlConfig).limit,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionSpendControlResource.consumed',
    original: jsonDecode(r'''{"consumed":0,"limit":1}'''),
    replacement: jsonDecode(r'''{"consumed":null,"limit":1}'''),
    parse: (value) =>
        AgentSessionSpendControl.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSpendControl)
        .copyWith(consumed: (replacement as AgentSessionSpendControl).consumed),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionSpendControlResource.limit',
    original: jsonDecode(r'''{"consumed":0,"limit":1}'''),
    replacement: jsonDecode(r'''{"consumed":0,"limit":2}'''),
    parse: (value) =>
        AgentSessionSpendControl.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSpendControl)
        .copyWith(limit: (replacement as AgentSessionSpendControl).limit),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnErrorResource.code',
    original: jsonDecode(
      r'''{"code":"context_length_exceeded","message":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"session_budget_exceeded","message":"PRIVATE-fixture"}''',
    ),
    parse: (value) =>
        AgentSessionTurnErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurnErrorResource)
        .copyWith(code: (replacement as AgentSessionTurnErrorResource).code),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnErrorResource.message',
    original: jsonDecode(
      r'''{"code":"context_length_exceeded","message":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"code":"context_length_exceeded","message":"PRIVATE-fixture-replacement"}''',
    ),
    parse: (value) =>
        AgentSessionTurnErrorResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTurnErrorResource).copyWith(
          message: (replacement as AgentSessionTurnErrorResource).message,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnItemResource.content',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"},{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          content: (replacement as AgentSessionMessageItemResource).content,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnItemResource.id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":null,"phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          id: (replacement as AgentSessionMessageItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnItemResource.phase',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":null,"role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          phase: (replacement as AgentSessionMessageItemResource).phase,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnItemResource.role',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"assistant","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          role: (replacement as AgentSessionMessageItemResource).role,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnItemResource.status',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"completed","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          status: (replacement as AgentSessionMessageItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SessionTurnItemResource.turn_id',
    original: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture","type":"message"}''',
    ),
    replacement: jsonDecode(
      r'''{"content":[{"text":"PRIVATE-fixture","type":"input_text"}],"id":"PRIVATE-fixture","phase":"commentary","role":"user","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"message"}''',
    ),
    parse: (value) =>
        AgentSessionTurnItem.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionMessageItemResource).copyWith(
          turnId: (replacement as AgentSessionMessageItemResource).turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SetupCommandParam.command',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"/workspace"}''',
    ),
    replacement: jsonDecode(
      r'''{"command":"PRIVATE-fixture-replacement","cwd":"/workspace"}''',
    ),
    parse: (value) =>
        AgentSessionSetupCommandConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionSetupCommandConfig).copyWith(
          command: (replacement as AgentSessionSetupCommandConfig).command,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SetupCommandParam.cwd',
    original: jsonDecode(
      r'''{"command":"PRIVATE-fixture","cwd":"/workspace"}''',
    ),
    replacement: jsonDecode(r'''{"command":"PRIVATE-fixture","cwd":null}'''),
    parse: (value) =>
        AgentSessionSetupCommandConfig.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionSetupCommandConfig).copyWith(
          cwd: (replacement as AgentSessionSetupCommandConfig).cwd,
          clearCwd: replacement.clearCwd,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.closed_at',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":null,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSubagent)
        .copyWith(closedAt: (replacement as AgentSessionSubagent).closedAt),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.id',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture-replacement","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSubagent)
        .copyWith(id: (replacement as AgentSessionSubagent).id),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.instructions',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":null,"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionSubagent).copyWith(
          instructions: (replacement as AgentSessionSubagent).instructions,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.name',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":null,"object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSubagent)
        .copyWith(name: (replacement as AgentSessionSubagent).name),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.opened_at',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSubagent)
        .copyWith(openedAt: (replacement as AgentSessionSubagent).openedAt),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.parent_agent_id',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture-replacement","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionSubagent).copyWith(
          parentAgentId: (replacement as AgentSessionSubagent).parentAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.session_id',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture-replacement","status":"active"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSubagent)
        .copyWith(sessionId: (replacement as AgentSessionSubagent).sessionId),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SubagentResource.status',
    original: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"active"}''',
    ),
    replacement: jsonDecode(
      r'''{"closed_at":0,"id":"PRIVATE-fixture","instructions":[{"text":"PRIVATE-fixture","type":"output_text"}],"name":"PRIVATE-fixture","object":"agent.session.subagent","opened_at":0,"parent_agent_id":"PRIVATE-fixture","session_id":"PRIVATE-fixture","status":"closed"}''',
    ),
    parse: (value) =>
        AgentSessionSubagent.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionSubagent)
        .copyWith(status: (replacement as AgentSessionSubagent).status),
  ),
  AgentSessionFieldCopyFixture(
    name: 'SummaryTextResource.text',
    original: jsonDecode(
      r'''{"text":"PRIVATE-fixture","type":"summary_text"}''',
    ),
    replacement: jsonDecode(
      r'''{"text":"PRIVATE-fixture-replacement","type":"summary_text"}''',
    ),
    parse: (value) => AgentSessionSummaryTextResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionSummaryTextResource).copyWith(
          text: (replacement as AgentSessionSummaryTextResource).text,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TokenUsageResource.input_tokens',
    original: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    replacement: jsonDecode(
      r'''{"input_tokens":1,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTokenUsageResource).copyWith(
          inputTokens:
              (replacement as AgentSessionTokenUsageResource).inputTokens,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TokenUsageResource.input_tokens_details',
    original: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    replacement: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":1},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTokenUsageResource).copyWith(
          inputTokensDetails: (replacement as AgentSessionTokenUsageResource)
              .inputTokensDetails,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TokenUsageResource.output_tokens',
    original: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    replacement: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":1,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTokenUsageResource).copyWith(
          outputTokens:
              (replacement as AgentSessionTokenUsageResource).outputTokens,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TokenUsageResource.output_tokens_details',
    original: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    replacement: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":1},"total_tokens":0}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTokenUsageResource).copyWith(
          outputTokensDetails: (replacement as AgentSessionTokenUsageResource)
              .outputTokensDetails,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TokenUsageResource.total_tokens',
    original: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}''',
    ),
    replacement: jsonDecode(
      r'''{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":1}''',
    ),
    parse: (value) =>
        AgentSessionTokenUsageResource.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionTokenUsageResource).copyWith(
          totalTokens:
              (replacement as AgentSessionTokenUsageResource).totalTokens,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.agent_id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture-replacement","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      agentId: (replacement as AgentSessionTurn).agentId,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.completed_at',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":null,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      completedAt: (replacement as AgentSessionTurn).completedAt,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.created_at',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":1,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      createdAt: (replacement as AgentSessionTurn).createdAt,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.error',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":null,"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      error: (replacement as AgentSessionTurn).error,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture-replacement","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      id: (replacement as AgentSessionTurn).id,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.session_id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture-replacement","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      sessionId: (replacement as AgentSessionTurn).sessionId,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.started_at',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":null,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      startedAt: (replacement as AgentSessionTurn).startedAt,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.status',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"in_progress","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      status: (replacement as AgentSessionTurn).status,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.subagent_id',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":null,"usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      subagentId: (replacement as AgentSessionTurn).subagentId,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'TurnResource.usage',
    original: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":{"input_tokens":0,"input_tokens_details":{"cached_tokens":0},"output_tokens":0,"output_tokens_details":{"reasoning_tokens":0},"total_tokens":0}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent_id":"PRIVATE-fixture","completed_at":0,"created_at":0,"error":{"code":"context_length_exceeded","message":"PRIVATE-fixture"},"id":"PRIVATE-fixture","object":"agent.session.turn","session_id":"PRIVATE-fixture","started_at":0,"status":"queued","subagent_id":"PRIVATE-fixture","usage":null}''',
    ),
    parse: (value) => AgentSessionTurn.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionTurn).copyWith(
      usage: (replacement as AgentSessionTurn).usage,
    ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateAgentSessionParams.agent',
    original: jsonDecode(
      r'''{"agent":{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"},"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1}}''',
    ),
    replacement: jsonDecode(
      r'''{"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1}}''',
    ),
    parse: (value) =>
        UpdateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as UpdateAgentSessionRequest)
        .copyWith(agent: (replacement as UpdateAgentSessionRequest).agent),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateAgentSessionParams.metadata',
    original: jsonDecode(
      r'''{"agent":{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"},"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"},"metadata":null,"spend_control":{"limit":1}}''',
    ),
    parse: (value) =>
        UpdateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as UpdateAgentSessionRequest).copyWith(
          metadata: (replacement as UpdateAgentSessionRequest).metadata,
          clearMetadata: replacement.clearMetadata,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateAgentSessionParams.spend_control',
    original: jsonDecode(
      r'''{"agent":{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"},"metadata":{"fixture":"PRIVATE-value"},"spend_control":{"limit":1}}''',
    ),
    replacement: jsonDecode(
      r'''{"agent":{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"},"metadata":{"fixture":"PRIVATE-value"},"spend_control":null}''',
    ),
    parse: (value) =>
        UpdateAgentSessionRequest.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as UpdateAgentSessionRequest).copyWith(
          spendControl: (replacement as UpdateAgentSessionRequest).spendControl,
          clearSpendControl: replacement.clearSpendControl,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateSessionAgentParam.model',
    original: jsonDecode(
      r'''{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"}''',
    ),
    replacement: jsonDecode(
      r'''{"reasoning":{"effort":"none"},"service_tier":"auto"}''',
    ),
    parse: (value) =>
        AgentSessionAgentUpdate.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) => (original as AgentSessionAgentUpdate)
        .copyWith(model: (replacement as AgentSessionAgentUpdate).model),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateSessionAgentParam.reasoning',
    original: jsonDecode(
      r'''{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"}''',
    ),
    replacement: jsonDecode(
      r'''{"model":"PRIVATE-fixture","service_tier":"auto"}''',
    ),
    parse: (value) =>
        AgentSessionAgentUpdate.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentUpdate).copyWith(
          reasoning: (replacement as AgentSessionAgentUpdate).reasoning,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateSessionAgentParam.service_tier',
    original: jsonDecode(
      r'''{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":"auto"}''',
    ),
    replacement: jsonDecode(
      r'''{"model":"PRIVATE-fixture","reasoning":{"effort":"none"},"service_tier":null}''',
    ),
    parse: (value) =>
        AgentSessionAgentUpdate.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionAgentUpdate).copyWith(
          serviceTier: (replacement as AgentSessionAgentUpdate).serviceTier,
          clearServiceTier: replacement.clearServiceTier,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'UpdateSessionReasoningParam.effort',
    original: jsonDecode(r'''{"effort":"none"}'''),
    replacement: jsonDecode(r'''{"effort":null}'''),
    parse: (value) =>
        AgentSessionReasoningUpdate.fromJson(value! as Map<String, dynamic>),
    copy: (original, replacement) =>
        (original as AgentSessionReasoningUpdate).copyWith(
          effort: (replacement as AgentSessionReasoningUpdate).effort,
          clearEffort: replacement.clearEffort,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WaitForSubagentsCallItemResource.id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture-replacement","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWaitForSubagentsCallItemResource).copyWith(
          id: (replacement as AgentSessionWaitForSubagentsCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WaitForSubagentsCallItemResource.recipient_agent_ids',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture","PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWaitForSubagentsCallItemResource).copyWith(
          recipientAgentIds:
              (replacement as AgentSessionWaitForSubagentsCallItemResource)
                  .recipientAgentIds,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WaitForSubagentsCallItemResource.sender_agent_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWaitForSubagentsCallItemResource).copyWith(
          senderAgentId:
              (replacement as AgentSessionWaitForSubagentsCallItemResource)
                  .senderAgentId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WaitForSubagentsCallItemResource.status',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWaitForSubagentsCallItemResource).copyWith(
          status: (replacement as AgentSessionWaitForSubagentsCallItemResource)
              .status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WaitForSubagentsCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"wait_for_subagents_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"id":"PRIVATE-fixture","recipient_agent_ids":["PRIVATE-fixture"],"sender_agent_id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"wait_for_subagents_call"}''',
    ),
    parse: (value) => AgentSessionWaitForSubagentsCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWaitForSubagentsCallItemResource).copyWith(
          turnId: (replacement as AgentSessionWaitForSubagentsCallItemResource)
              .turnId,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResource.queries',
    original: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"}''',
    ),
    replacement: jsonDecode(
      r'''{"queries":null,"query":"PRIVATE-fixture","type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceSearch).copyWith(
          queries: (replacement as AgentSessionWebSearchActionResourceSearch)
              .queries,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResource.query',
    original: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"}''',
    ),
    replacement: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":null,"type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceSearch).copyWith(
          query:
              (replacement as AgentSessionWebSearchActionResourceSearch).query,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResourceFindInPage.pattern',
    original: jsonDecode(
      r'''{"pattern":"PRIVATE-fixture","type":"find_in_page","url":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"pattern":null,"type":"find_in_page","url":"PRIVATE-fixture"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceFindInPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceFindInPage).copyWith(
          pattern:
              (replacement as AgentSessionWebSearchActionResourceFindInPage)
                  .pattern,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResourceFindInPage.url',
    original: jsonDecode(
      r'''{"pattern":"PRIVATE-fixture","type":"find_in_page","url":"PRIVATE-fixture"}''',
    ),
    replacement: jsonDecode(
      r'''{"pattern":"PRIVATE-fixture","type":"find_in_page","url":null}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceFindInPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceFindInPage).copyWith(
          url: (replacement as AgentSessionWebSearchActionResourceFindInPage)
              .url,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResourceOpenPage.url',
    original: jsonDecode(r'''{"type":"open_page","url":"PRIVATE-fixture"}'''),
    replacement: jsonDecode(r'''{"type":"open_page","url":null}'''),
    parse: (value) => AgentSessionWebSearchActionResourceOpenPage.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceOpenPage).copyWith(
          url: (replacement as AgentSessionWebSearchActionResourceOpenPage).url,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResourceSearch.queries',
    original: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"}''',
    ),
    replacement: jsonDecode(
      r'''{"queries":null,"query":"PRIVATE-fixture","type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceSearch.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceSearch).copyWith(
          queries: (replacement as AgentSessionWebSearchActionResourceSearch)
              .queries,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchActionResourceSearch.query',
    original: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"}''',
    ),
    replacement: jsonDecode(
      r'''{"queries":["PRIVATE-fixture"],"query":null,"type":"search"}''',
    ),
    parse: (value) => AgentSessionWebSearchActionResourceSearch.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchActionResourceSearch).copyWith(
          query:
              (replacement as AgentSessionWebSearchActionResourceSearch).query,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchCallItemResource.action',
    original: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":null,"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    parse: (value) => AgentSessionWebSearchCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchCallItemResource).copyWith(
          action: (replacement as AgentSessionWebSearchCallItemResource).action,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchCallItemResource.id',
    original: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture-replacement","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    parse: (value) => AgentSessionWebSearchCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchCallItemResource).copyWith(
          id: (replacement as AgentSessionWebSearchCallItemResource).id,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchCallItemResource.status',
    original: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"completed","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    parse: (value) => AgentSessionWebSearchCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchCallItemResource).copyWith(
          status: (replacement as AgentSessionWebSearchCallItemResource).status,
        ),
  ),
  AgentSessionFieldCopyFixture(
    name: 'WebSearchCallItemResource.turn_id',
    original: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture","type":"web_search_call"}''',
    ),
    replacement: jsonDecode(
      r'''{"action":{"queries":["PRIVATE-fixture"],"query":"PRIVATE-fixture","type":"search"},"id":"PRIVATE-fixture","status":"in_progress","turn_id":"PRIVATE-fixture-replacement","type":"web_search_call"}''',
    ),
    parse: (value) => AgentSessionWebSearchCallItemResource.fromJson(
      value! as Map<String, dynamic>,
    ),
    copy: (original, replacement) =>
        (original as AgentSessionWebSearchCallItemResource).copyWith(
          turnId: (replacement as AgentSessionWebSearchCallItemResource).turnId,
        ),
  ),
];

/// Actual source mutation and type-safe per-field copy call.
class AgentSessionFieldCopyFixture {
  /// Creates a canonical copy fixture.
  const AgentSessionFieldCopyFixture({
    required this.name,
    required this.original,
    required this.replacement,
    required this.parse,
    required this.copy,
  });

  /// Component and field name.
  final String name;

  /// Full valid original wire value.
  final Object? original;

  /// Independently canonical replacement/clear wire value.
  final Object? replacement;

  /// Actual exported parser.
  final AgentJsonModel Function(Object?) parse;

  /// Actual public typed copy call.
  final AgentJsonModel Function(AgentJsonModel, AgentJsonModel) copy;
}
