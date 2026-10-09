import '../common/copy_with_sentinel.dart';
import 'agent_config.dart';
import 'agent_enums.dart';
import 'agent_json_helpers.dart';
import 'agent_tools.dart';

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentList extends AgentJsonModel {
  /// Creates a validated [AgentList].
  AgentList({
    required List<Agent> data,
    required this.firstId,
    required this.hasMore,
    required this.lastId,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'data',
         'first_id',
         'has_more',
         'last_id',
         'object',
       ], 'AgentList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<Agent> data;

  /// The ID of the first resource in `data`, or `null` if the page is empty.
  final String? firstId;

  /// Whether there are more resources to retrieve after this page.
  final bool hasMore;

  /// The ID of the last resource in `data`, or `null` if the page is empty. Pass this as `after` with the same order and filters.
  final String? lastId;

  /// The object type, which is always `list`.
  String get object => 'list';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentList] with contextual, payload-free errors.
  factory AgentList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentList');
    return AgentList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentList.data',
        (value, context) => requireAgentList(value, context)
            .map((value) => Agent.fromJson(requireAgentObject(value, context)))
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentList.lastId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'data',
            'first_id',
            'has_more',
            'last_id',
            'object',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(data.length, 'AgentList.data', min: 0, max: 2000);
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'AgentList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'AgentList.lastId', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((value) => value.toJson()).toList(),
    'first_id': firstId,
    'has_more': hasMore,
    'last_id': lastId,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentList copyWith({
    List<Agent>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(firstId, this.firstId, 'AgentList.firstId'),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(lastId, this.lastId, 'AgentList.lastId'),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A reusable agent scoped to the caller's project.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class Agent extends AgentJsonModel {
  /// Creates a validated [Agent].
  Agent({
    required this.createdAt,
    required this.id,
    required this.instructions,
    required Map<String, String> metadata,
    required this.model,
    required this.multiAgent,
    required this.name,
    required this.reasoning,
    required this.serviceTier,
    required this.text,
    required List<AgentToolResource> tools,
    required this.updatedAt,
    Map<String, dynamic> rawJson = const {},
  }) : metadata = Map<String, String>.unmodifiable(metadata),
       tools = List.unmodifiable(tools),
       rawJson = agentExtras(rawJson, const [
         'created_at',
         'id',
         'instructions',
         'metadata',
         'model',
         'multi_agent',
         'name',
         'object',
         'reasoning',
         'service_tier',
         'text',
         'tools',
         'updated_at',
       ], 'Agent') {
    validate();
  }

  /// The Unix timestamp, in seconds, when the agent was created.
  final int createdAt;

  /// The ID of the reusable agent.
  final String id;

  /// Custom instructions appended to the agent's default base instructions.
  final String? instructions;

  /// Custom string key-value pairs attached to the agent.
  final Map<String, String> metadata;

  /// The requested model name used for inference.
  final String model;

  /// The resolved configuration for creating and coordinating subagents.
  final AgentMultiAgent multiAgent;

  /// A human-readable name for the agent, or null if it is unnamed.
  final String? name;

  /// The object type. Always `agent`.
  String get object => 'agent';

  /// The resolved reasoning configuration, including the model default for an omitted effort.
  final AgentReasoning reasoning;

  /// The resolved service-tier policy used for model requests.
  final AgentServiceTierResource serviceTier;

  /// The resolved configuration for text generated by the agent.
  final AgentText text;

  /// Tools available to the agent.
  final List<AgentToolResource> tools;

  /// The Unix timestamp, in seconds, when the agent was last updated.
  final int updatedAt;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [Agent] with contextual, payload-free errors.
  factory Agent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'agent', 'Agent');
    return Agent(
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'Agent.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'Agent.id',
        requireAgentString,
        nullable: false,
      )!,
      instructions: requiredAgentValue(
        json,
        'instructions',
        'Agent.instructions',
        requireAgentString,
        nullable: true,
      ),
      metadata: requiredAgentValue(
        json,
        'metadata',
        'Agent.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      model: requiredAgentValue(
        json,
        'model',
        'Agent.model',
        requireAgentString,
        nullable: false,
      )!,
      multiAgent: requiredAgentValue(
        json,
        'multi_agent',
        'Agent.multiAgent',
        (value, context) =>
            AgentMultiAgent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'Agent.name',
        requireAgentString,
        nullable: true,
      ),
      reasoning: requiredAgentValue(
        json,
        'reasoning',
        'Agent.reasoning',
        (value, context) =>
            AgentReasoning.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      serviceTier: requiredAgentValue(
        json,
        'service_tier',
        'Agent.serviceTier',
        (value, context) => AgentServiceTierResource.fromJson(value),
        nullable: false,
      )!,
      text: requiredAgentValue(
        json,
        'text',
        'Agent.text',
        (value, context) =>
            AgentText.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      tools: requiredAgentValue(
        json,
        'tools',
        'Agent.tools',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentToolResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      updatedAt: requiredAgentValue(
        json,
        'updated_at',
        'Agent.updatedAt',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'created_at',
            'id',
            'instructions',
            'metadata',
            'model',
            'multi_agent',
            'name',
            'object',
            'reasoning',
            'service_tier',
            'text',
            'tools',
            'updated_at',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(createdAt, 'Agent.createdAt');
    validateAgentLength(id, 'Agent.id', min: 0);
    if (instructions != null) {
      validateAgentLength(instructions!, 'Agent.instructions', min: 0);
    }
    validateAgentCount(metadata.length, 'Agent.metadata', min: 0);
    for (final key in metadata.keys) {
      validateAgentLength(key, 'Agent.metadata', min: 0);
    }
    for (final item in metadata.values) {
      validateAgentLength(item, 'Agent.metadata', min: 0);
    }
    validateAgentLength(model, 'Agent.model', min: 0);
    multiAgent.validate();
    if (name != null) {
      validateAgentLength(name!, 'Agent.name', min: 0);
    }
    reasoning.validate();
    text.validate();
    validateAgentCount(tools.length, 'Agent.tools', min: 0, max: 2000);
    for (final item in tools) {
      item.validate();
    }
    validateAgentInt(updatedAt, 'Agent.updatedAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'created_at': createdAt,
    'id': id,
    'instructions': instructions,
    'metadata': metadata,
    'model': model,
    'multi_agent': multiAgent.toJson(),
    'name': name,
    'object': object,
    'reasoning': reasoning.toJson(),
    'service_tier': serviceTier.toJson(),
    'text': text.toJson(),
    'tools': tools.map((value) => value.toJson()).toList(),
    'updated_at': updatedAt,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  Agent copyWith({
    int? createdAt,
    String? id,
    Object? instructions = unsetCopyWithValue,
    Map<String, String>? metadata,
    String? model,
    AgentMultiAgent? multiAgent,
    Object? name = unsetCopyWithValue,
    AgentReasoning? reasoning,
    AgentServiceTierResource? serviceTier,
    AgentText? text,
    List<AgentToolResource>? tools,
    int? updatedAt,
    Map<String, dynamic>? rawJson,
  }) => Agent(
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    instructions: copyAgentValue<String>(
      instructions,
      this.instructions,
      'Agent.instructions',
    ),
    metadata: metadata ?? this.metadata,
    model: model ?? this.model,
    multiAgent: multiAgent ?? this.multiAgent,
    name: copyAgentValue<String>(name, this.name, 'Agent.name'),
    reasoning: reasoning ?? this.reasoning,
    serviceTier: serviceTier ?? this.serviceTier,
    text: text ?? this.text,
    tools: tools ?? this.tools,
    updatedAt: updatedAt ?? this.updatedAt,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Parameters for creating a reusable agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateAgentRequest extends AgentJsonModel {
  /// Creates a validated [CreateAgentRequest].
  CreateAgentRequest({
    String? instructions,
    bool clearInstructions = false,
    Map<String, String>? metadata,
    bool clearMetadata = false,
    required this.model,
    AgentMultiAgentConfig? multiAgent,
    bool clearMultiAgent = false,
    String? name,
    bool clearName = false,
    AgentReasoningConfig? reasoning,
    bool clearReasoning = false,
    AgentServiceTierParam? serviceTier,
    bool clearServiceTier = false,
    AgentTextConfig? text,
    bool clearText = false,
    List<AgentTool>? tools,
    bool clearTools = false,
  }) : clearInstructions = clearInstructions,
       instructions = clearInstructions ? null : instructions,
       clearMetadata = clearMetadata,
       metadata = ownAgentValue<Map<String, String>>(
         clearMetadata ? null : metadata,
         Map<String, String>.unmodifiable,
       ),
       clearMultiAgent = clearMultiAgent,
       multiAgent = clearMultiAgent ? null : multiAgent,
       clearName = clearName,
       name = clearName ? null : name,
       clearReasoning = clearReasoning,
       reasoning = clearReasoning ? null : reasoning,
       clearServiceTier = clearServiceTier,
       serviceTier = clearServiceTier ? null : serviceTier,
       clearText = clearText,
       text = clearText ? null : text,
       clearTools = clearTools,
       tools = ownAgentValue<List<AgentTool>>(
         clearTools ? null : tools,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Additional instructions appended to the agent's default base instructions. Omit or set to null to add no custom instructions.
  final String? instructions;

  /// Sends `instructions: null`, rather than omitting it.
  final bool clearInstructions;

  /// Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters. Omission or null defaults to an empty map.
  final Map<String, String>? metadata;

  /// Sends `metadata: null`, rather than omitting it.
  final bool clearMetadata;

  /// The model to use for the agent. The requested model name is preserved.
  final String model;

  /// Configuration for creating and coordinating subagents. Subagent tools are disabled by default.
  final AgentMultiAgentConfig? multiAgent;

  /// Sends `multi_agent: null`, rather than omitting it.
  final bool clearMultiAgent;

  /// A human-readable name for the agent. Omission or null leaves the agent unnamed.
  final String? name;

  /// Sends `name: null`, rather than omitting it.
  final bool clearName;

  /// Configuration for model reasoning. Omission uses the model's default effort.
  final AgentReasoningConfig? reasoning;

  /// Sends `reasoning: null`, rather than omitting it.
  final bool clearReasoning;

  /// The service tier used for model requests. Defaults to `auto`.
  final AgentServiceTierParam? serviceTier;

  /// Sends `service_tier: null`, rather than omitting it.
  final bool clearServiceTier;

  /// Configuration for generated text. Defaults to the `text` format and medium verbosity.
  final AgentTextConfig? text;

  /// Sends `text: null`, rather than omitting it.
  final bool clearText;

  /// Tools available to the agent. Defaults to an empty list. The tool list must fit within 3 MiB (3,145,728 bytes) of compact UTF-8 JSON.
  final List<AgentTool>? tools;

  /// Sends `tools: null`, rather than omitting it.
  final bool clearTools;

  /// Parses [CreateAgentRequest] with contextual, payload-free errors.
  factory CreateAgentRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'instructions',
      'metadata',
      'model',
      'multi_agent',
      'name',
      'reasoning',
      'service_tier',
      'text',
      'tools',
    ], 'CreateAgentRequest');
    return CreateAgentRequest(
      instructions: optionalAgentValue(
        json,
        'instructions',
        'CreateAgentRequest.instructions',
        requireAgentString,
        nullable: true,
      ),
      clearInstructions:
          json.containsKey('instructions') && json['instructions'] == null,
      metadata: optionalAgentValue(
        json,
        'metadata',
        'CreateAgentRequest.metadata',
        requireAgentStringMap,
        nullable: true,
      ),
      clearMetadata: json.containsKey('metadata') && json['metadata'] == null,
      model: requiredAgentValue(
        json,
        'model',
        'CreateAgentRequest.model',
        requireAgentString,
        nullable: false,
      )!,
      multiAgent: optionalAgentValue(
        json,
        'multi_agent',
        'CreateAgentRequest.multiAgent',
        (value, context) =>
            AgentMultiAgentConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearMultiAgent:
          json.containsKey('multi_agent') && json['multi_agent'] == null,
      name: optionalAgentValue(
        json,
        'name',
        'CreateAgentRequest.name',
        requireAgentString,
        nullable: true,
      ),
      clearName: json.containsKey('name') && json['name'] == null,
      reasoning: optionalAgentValue(
        json,
        'reasoning',
        'CreateAgentRequest.reasoning',
        (value, context) =>
            AgentReasoningConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearReasoning:
          json.containsKey('reasoning') && json['reasoning'] == null,
      serviceTier: optionalAgentValue(
        json,
        'service_tier',
        'CreateAgentRequest.serviceTier',
        (value, context) => AgentServiceTierParam.fromJson(value),
        nullable: true,
      ),
      clearServiceTier:
          json.containsKey('service_tier') && json['service_tier'] == null,
      text: optionalAgentValue(
        json,
        'text',
        'CreateAgentRequest.text',
        (value, context) =>
            AgentTextConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearText: json.containsKey('text') && json['text'] == null,
      tools: optionalAgentValue(
        json,
        'tools',
        'CreateAgentRequest.tools',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentTool.fromJson(requireAgentObject(value, context)),
            )
            .toList(),
        nullable: true,
      ),
      clearTools: json.containsKey('tools') && json['tools'] == null,
    );
  }
  @override
  void validate() {
    if (instructions != null) {
      validateAgentLength(
        instructions!,
        'CreateAgentRequest.instructions',
        min: 0,
        max: 1048576,
      );
    }
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'CreateAgentRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'CreateAgentRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'CreateAgentRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
    validateAgentLength(
      model,
      'CreateAgentRequest.model',
      min: 0,
      max: 1048576,
    );
    if (multiAgent != null) {
      multiAgent!.validate();
    }
    if (name != null) {
      validateAgentLength(name!, 'CreateAgentRequest.name', min: 0, max: 128);
    }
    if (reasoning != null) {
      reasoning!.validate();
    }
    if (serviceTier != null) {
      validateAgentEnum(serviceTier!.value, [
        'auto',
        'default',
        'flex',
        'priority',
        'fast',
      ], 'CreateAgentRequest.serviceTier');
    }
    if (text != null) {
      text!.validate();
    }
    if (tools != null) {
      validateAgentCount(
        tools!.length,
        'CreateAgentRequest.tools',
        min: 0,
        max: 2000,
      );
      for (final item in tools!) {
        item.validate();
      }
    }
    if (tools != null) {
      validateAgentToolBudget(tools!.map((tool) => tool.toJson()).toList());
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearInstructions)
      'instructions': null
    else
      'instructions': ?instructions,
    if (clearMetadata) 'metadata': null else 'metadata': ?metadata,
    'model': model,
    if (clearMultiAgent)
      'multi_agent': null
    else if (multiAgent != null)
      'multi_agent': multiAgent!.toJson(),
    if (clearName) 'name': null else 'name': ?name,
    if (clearReasoning)
      'reasoning': null
    else if (reasoning != null)
      'reasoning': reasoning!.toJson(),
    if (clearServiceTier)
      'service_tier': null
    else if (serviceTier != null)
      'service_tier': serviceTier!.toJson(),
    if (clearText) 'text': null else if (text != null) 'text': text!.toJson(),
    if (clearTools)
      'tools': null
    else if (tools != null)
      'tools': tools!.map((value) => value.toJson()).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateAgentRequest copyWith({
    Object? instructions = unsetCopyWithValue,
    bool? clearInstructions,
    Object? metadata = unsetCopyWithValue,
    bool? clearMetadata,
    String? model,
    Object? multiAgent = unsetCopyWithValue,
    bool? clearMultiAgent,
    Object? name = unsetCopyWithValue,
    bool? clearName,
    Object? reasoning = unsetCopyWithValue,
    bool? clearReasoning,
    Object? serviceTier = unsetCopyWithValue,
    bool? clearServiceTier,
    Object? text = unsetCopyWithValue,
    bool? clearText,
    Object? tools = unsetCopyWithValue,
    bool? clearTools,
  }) => CreateAgentRequest(
    instructions: copyAgentValue<String>(
      instructions,
      this.instructions,
      'CreateAgentRequest.instructions',
    ),
    clearInstructions:
        clearInstructions ??
        (identical(instructions, unsetCopyWithValue)
            ? this.clearInstructions
            : instructions == null),
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'CreateAgentRequest.metadata',
    ),
    clearMetadata:
        clearMetadata ??
        (identical(metadata, unsetCopyWithValue)
            ? this.clearMetadata
            : metadata == null),
    model: model ?? this.model,
    multiAgent: copyAgentValue<AgentMultiAgentConfig>(
      multiAgent,
      this.multiAgent,
      'CreateAgentRequest.multiAgent',
    ),
    clearMultiAgent:
        clearMultiAgent ??
        (identical(multiAgent, unsetCopyWithValue)
            ? this.clearMultiAgent
            : multiAgent == null),
    name: copyAgentValue<String>(name, this.name, 'CreateAgentRequest.name'),
    clearName:
        clearName ??
        (identical(name, unsetCopyWithValue) ? this.clearName : name == null),
    reasoning: copyAgentValue<AgentReasoningConfig>(
      reasoning,
      this.reasoning,
      'CreateAgentRequest.reasoning',
    ),
    clearReasoning:
        clearReasoning ??
        (identical(reasoning, unsetCopyWithValue)
            ? this.clearReasoning
            : reasoning == null),
    serviceTier: copyAgentValue<AgentServiceTierParam>(
      serviceTier,
      this.serviceTier,
      'CreateAgentRequest.serviceTier',
    ),
    clearServiceTier:
        clearServiceTier ??
        (identical(serviceTier, unsetCopyWithValue)
            ? this.clearServiceTier
            : serviceTier == null),
    text: copyAgentValue<AgentTextConfig>(
      text,
      this.text,
      'CreateAgentRequest.text',
    ),
    clearText:
        clearText ??
        (identical(text, unsetCopyWithValue) ? this.clearText : text == null),
    tools: copyAgentValue<List<AgentTool>>(
      tools,
      this.tools,
      'CreateAgentRequest.tools',
    ),
    clearTools:
        clearTools ??
        (identical(tools, unsetCopyWithValue)
            ? this.clearTools
            : tools == null),
  );
}

/// A deleted reusable agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class DeletedAgent extends AgentJsonModel {
  /// Creates a validated [DeletedAgent].
  DeletedAgent({
    required this.deleted,
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'deleted',
         'id',
         'object',
       ], 'DeletedAgent') {
    validate();
  }

  /// Whether the agent was deleted. Always `true`.
  final bool deleted;

  /// The ID of the deleted agent.
  final String id;

  /// The object type. Always `agent.deleted`.
  String get object => 'agent.deleted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [DeletedAgent] with contextual, payload-free errors.
  factory DeletedAgent.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'agent.deleted', 'DeletedAgent');
    return DeletedAgent(
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedAgent.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'DeletedAgent.id',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['deleted', 'id', 'object'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'DeletedAgent.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'deleted': deleted,
    'id': id,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  DeletedAgent copyWith({
    bool? deleted,
    String? id,
    Map<String, dynamic>? rawJson,
  }) => DeletedAgent(
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Details about an API error.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentErrorBody extends AgentJsonModel {
  /// Creates a validated [AgentErrorBody].
  AgentErrorBody({
    required this.code,
    required this.message,
    required this.param,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'code',
         'message',
         'param',
         'type',
       ], 'AgentErrorBody') {
    validate();
  }

  /// A machine-readable error code.
  final String code;

  /// A human-readable error message.
  final String message;

  /// The request parameter that caused the error, or null for a request-wide error.
  final String? param;

  /// The error type.
  final String type;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentErrorBody] with contextual, payload-free errors.
  factory AgentErrorBody.fromJson(Map<String, dynamic> json) {
    return AgentErrorBody(
      code: requiredAgentValue(
        json,
        'code',
        'AgentErrorBody.code',
        requireAgentString,
        nullable: false,
      )!,
      message: requiredAgentValue(
        json,
        'message',
        'AgentErrorBody.message',
        requireAgentString,
        nullable: false,
      )!,
      param: requiredAgentValue(
        json,
        'param',
        'AgentErrorBody.param',
        requireAgentString,
        nullable: true,
      ),
      type: requiredAgentValue(
        json,
        'type',
        'AgentErrorBody.type',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['code', 'message', 'param', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(code, 'AgentErrorBody.code', min: 0);
    validateAgentLength(message, 'AgentErrorBody.message', min: 0);
    if (param != null) {
      validateAgentLength(param!, 'AgentErrorBody.param', min: 0);
    }
    validateAgentLength(type, 'AgentErrorBody.type', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'code': code,
    'message': message,
    'param': param,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentErrorBody copyWith({
    String? code,
    String? message,
    Object? param = unsetCopyWithValue,
    String? type,
    Map<String, dynamic>? rawJson,
  }) => AgentErrorBody(
    code: code ?? this.code,
    message: message ?? this.message,
    param: copyAgentValue<String>(param, this.param, 'AgentErrorBody.param'),
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An API error response.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentErrorResponse extends AgentJsonModel {
  /// Creates a validated [AgentErrorResponse].
  AgentErrorResponse({
    required this.error,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const ['error'], 'AgentErrorResponse') {
    validate();
  }

  /// The error returned by the API.
  final AgentErrorBody error;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentErrorResponse] with contextual, payload-free errors.
  factory AgentErrorResponse.fromJson(Map<String, dynamic> json) {
    return AgentErrorResponse(
      error: requiredAgentValue(
        json,
        'error',
        'AgentErrorResponse.error',
        (value, context) =>
            AgentErrorBody.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['error'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    error.validate();
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'error': error.toJson()};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentErrorResponse copyWith({
    AgentErrorBody? error,
    Map<String, dynamic>? rawJson,
  }) => AgentErrorResponse(
    error: error ?? this.error,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Fields to replace on an existing reusable agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class UpdateAgentRequest extends AgentJsonModel {
  /// Creates a validated [UpdateAgentRequest].
  UpdateAgentRequest({
    String? instructions,
    bool clearInstructions = false,
    Map<String, String>? metadata,
    bool clearMetadata = false,
    this.model,
    AgentMultiAgentConfig? multiAgent,
    bool clearMultiAgent = false,
    String? name,
    bool clearName = false,
    AgentReasoningConfig? reasoning,
    bool clearReasoning = false,
    AgentServiceTierParam? serviceTier,
    bool clearServiceTier = false,
    AgentTextConfig? text,
    bool clearText = false,
    List<AgentTool>? tools,
    bool clearTools = false,
  }) : clearInstructions = clearInstructions,
       instructions = clearInstructions ? null : instructions,
       clearMetadata = clearMetadata,
       metadata = ownAgentValue<Map<String, String>>(
         clearMetadata ? null : metadata,
         Map<String, String>.unmodifiable,
       ),
       clearMultiAgent = clearMultiAgent,
       multiAgent = clearMultiAgent ? null : multiAgent,
       clearName = clearName,
       name = clearName ? null : name,
       clearReasoning = clearReasoning,
       reasoning = clearReasoning ? null : reasoning,
       clearServiceTier = clearServiceTier,
       serviceTier = clearServiceTier ? null : serviceTier,
       clearText = clearText,
       text = clearText ? null : text,
       clearTools = clearTools,
       tools = ownAgentValue<List<AgentTool>>(
         clearTools ? null : tools,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Additional instructions appended to the agent's default base instructions. Omit to leave unchanged.
  final String? instructions;

  /// Sends `instructions: null`, rather than omitting it.
  final bool clearInstructions;

  /// Replaces all metadata. Omit to leave unchanged; use clearMetadata: true or an empty map to clear it. Constructor metadata: null omits the field; copyWith(metadata: null) sends explicit null. Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters.
  final Map<String, String>? metadata;

  /// Sends `metadata: null`, rather than omitting it.
  final bool clearMetadata;

  /// The model to use for the agent. The requested model name is preserved.
  final String? model;

  /// Configuration for creating and coordinating subagents.
  final AgentMultiAgentConfig? multiAgent;

  /// Sends `multi_agent: null`, rather than omitting it.
  final bool clearMultiAgent;

  /// A replacement name. Omit to leave unchanged; use clearName: true to clear it. Constructor name: null omits the field; copyWith(name: null) sends explicit null.
  final String? name;

  /// Sends `name: null`, rather than omitting it.
  final bool clearName;

  /// Configuration for model reasoning. Omit to retain it; use clearReasoning: true to reset to the model default. Constructor reasoning: null omits the field; copyWith(reasoning: null) sends explicit null.
  final AgentReasoningConfig? reasoning;

  /// Sends `reasoning: null`, rather than omitting it.
  final bool clearReasoning;

  /// The service tier used for model requests.
  final AgentServiceTierParam? serviceTier;

  /// Sends `service_tier: null`, rather than omitting it.
  final bool clearServiceTier;

  /// Configuration for text generated by the agent.
  final AgentTextConfig? text;

  /// Sends `text: null`, rather than omitting it.
  final bool clearText;

  /// Replaces the tool list. Omit to leave it unchanged; use clearTools: true or an empty list to clear it. Constructor tools: null omits the field; copyWith(tools: null) sends explicit null. The replacement must fit within 3 MiB (3,145,728 bytes) of compact UTF-8 JSON.
  final List<AgentTool>? tools;

  /// Sends `tools: null`, rather than omitting it.
  final bool clearTools;

  /// Parses [UpdateAgentRequest] with contextual, payload-free errors.
  factory UpdateAgentRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'instructions',
      'metadata',
      'model',
      'multi_agent',
      'name',
      'reasoning',
      'service_tier',
      'text',
      'tools',
    ], 'UpdateAgentRequest');
    return UpdateAgentRequest(
      instructions: optionalAgentValue(
        json,
        'instructions',
        'UpdateAgentRequest.instructions',
        requireAgentString,
        nullable: true,
      ),
      clearInstructions:
          json.containsKey('instructions') && json['instructions'] == null,
      metadata: optionalAgentValue(
        json,
        'metadata',
        'UpdateAgentRequest.metadata',
        requireAgentStringMap,
        nullable: true,
      ),
      clearMetadata: json.containsKey('metadata') && json['metadata'] == null,
      model: optionalAgentValue(
        json,
        'model',
        'UpdateAgentRequest.model',
        requireAgentString,
        nullable: false,
      ),
      multiAgent: optionalAgentValue(
        json,
        'multi_agent',
        'UpdateAgentRequest.multiAgent',
        (value, context) =>
            AgentMultiAgentConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearMultiAgent:
          json.containsKey('multi_agent') && json['multi_agent'] == null,
      name: optionalAgentValue(
        json,
        'name',
        'UpdateAgentRequest.name',
        requireAgentString,
        nullable: true,
      ),
      clearName: json.containsKey('name') && json['name'] == null,
      reasoning: optionalAgentValue(
        json,
        'reasoning',
        'UpdateAgentRequest.reasoning',
        (value, context) =>
            AgentReasoningConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearReasoning:
          json.containsKey('reasoning') && json['reasoning'] == null,
      serviceTier: optionalAgentValue(
        json,
        'service_tier',
        'UpdateAgentRequest.serviceTier',
        (value, context) => AgentServiceTierParam.fromJson(value),
        nullable: true,
      ),
      clearServiceTier:
          json.containsKey('service_tier') && json['service_tier'] == null,
      text: optionalAgentValue(
        json,
        'text',
        'UpdateAgentRequest.text',
        (value, context) =>
            AgentTextConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearText: json.containsKey('text') && json['text'] == null,
      tools: optionalAgentValue(
        json,
        'tools',
        'UpdateAgentRequest.tools',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentTool.fromJson(requireAgentObject(value, context)),
            )
            .toList(),
        nullable: true,
      ),
      clearTools: json.containsKey('tools') && json['tools'] == null,
    );
  }
  @override
  void validate() {
    if (instructions != null) {
      validateAgentLength(
        instructions!,
        'UpdateAgentRequest.instructions',
        min: 0,
        max: 1048576,
      );
    }
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'UpdateAgentRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'UpdateAgentRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'UpdateAgentRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
    if (model != null) {
      validateAgentLength(
        model!,
        'UpdateAgentRequest.model',
        min: 0,
        max: 1048576,
      );
    }
    if (multiAgent != null) {
      multiAgent!.validate();
    }
    if (name != null) {
      validateAgentLength(name!, 'UpdateAgentRequest.name', min: 0, max: 128);
    }
    if (reasoning != null) {
      reasoning!.validate();
    }
    if (serviceTier != null) {
      validateAgentEnum(serviceTier!.value, [
        'auto',
        'default',
        'flex',
        'priority',
        'fast',
      ], 'UpdateAgentRequest.serviceTier');
    }
    if (text != null) {
      text!.validate();
    }
    if (tools != null) {
      validateAgentCount(
        tools!.length,
        'UpdateAgentRequest.tools',
        min: 0,
        max: 2000,
      );
      for (final item in tools!) {
        item.validate();
      }
    }
    if (tools != null) {
      validateAgentToolBudget(tools!.map((tool) => tool.toJson()).toList());
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearInstructions)
      'instructions': null
    else
      'instructions': ?instructions,
    if (clearMetadata) 'metadata': null else 'metadata': ?metadata,
    'model': ?model,
    if (clearMultiAgent)
      'multi_agent': null
    else if (multiAgent != null)
      'multi_agent': multiAgent!.toJson(),
    if (clearName) 'name': null else 'name': ?name,
    if (clearReasoning)
      'reasoning': null
    else if (reasoning != null)
      'reasoning': reasoning!.toJson(),
    if (clearServiceTier)
      'service_tier': null
    else if (serviceTier != null)
      'service_tier': serviceTier!.toJson(),
    if (clearText) 'text': null else if (text != null) 'text': text!.toJson(),
    if (clearTools)
      'tools': null
    else if (tools != null)
      'tools': tools!.map((value) => value.toJson()).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  UpdateAgentRequest copyWith({
    Object? instructions = unsetCopyWithValue,
    bool? clearInstructions,
    Object? metadata = unsetCopyWithValue,
    bool? clearMetadata,
    Object? model = unsetCopyWithValue,
    Object? multiAgent = unsetCopyWithValue,
    bool? clearMultiAgent,
    Object? name = unsetCopyWithValue,
    bool? clearName,
    Object? reasoning = unsetCopyWithValue,
    bool? clearReasoning,
    Object? serviceTier = unsetCopyWithValue,
    bool? clearServiceTier,
    Object? text = unsetCopyWithValue,
    bool? clearText,
    Object? tools = unsetCopyWithValue,
    bool? clearTools,
  }) => UpdateAgentRequest(
    instructions: copyAgentValue<String>(
      instructions,
      this.instructions,
      'UpdateAgentRequest.instructions',
    ),
    clearInstructions:
        clearInstructions ??
        (identical(instructions, unsetCopyWithValue)
            ? this.clearInstructions
            : instructions == null),
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'UpdateAgentRequest.metadata',
    ),
    clearMetadata:
        clearMetadata ??
        (identical(metadata, unsetCopyWithValue)
            ? this.clearMetadata
            : metadata == null),
    model: copyAgentValue<String>(
      model,
      this.model,
      'UpdateAgentRequest.model',
    ),
    multiAgent: copyAgentValue<AgentMultiAgentConfig>(
      multiAgent,
      this.multiAgent,
      'UpdateAgentRequest.multiAgent',
    ),
    clearMultiAgent:
        clearMultiAgent ??
        (identical(multiAgent, unsetCopyWithValue)
            ? this.clearMultiAgent
            : multiAgent == null),
    name: copyAgentValue<String>(name, this.name, 'UpdateAgentRequest.name'),
    clearName:
        clearName ??
        (identical(name, unsetCopyWithValue) ? this.clearName : name == null),
    reasoning: copyAgentValue<AgentReasoningConfig>(
      reasoning,
      this.reasoning,
      'UpdateAgentRequest.reasoning',
    ),
    clearReasoning:
        clearReasoning ??
        (identical(reasoning, unsetCopyWithValue)
            ? this.clearReasoning
            : reasoning == null),
    serviceTier: copyAgentValue<AgentServiceTierParam>(
      serviceTier,
      this.serviceTier,
      'UpdateAgentRequest.serviceTier',
    ),
    clearServiceTier:
        clearServiceTier ??
        (identical(serviceTier, unsetCopyWithValue)
            ? this.clearServiceTier
            : serviceTier == null),
    text: copyAgentValue<AgentTextConfig>(
      text,
      this.text,
      'UpdateAgentRequest.text',
    ),
    clearText:
        clearText ??
        (identical(text, unsetCopyWithValue) ? this.clearText : text == null),
    tools: copyAgentValue<List<AgentTool>>(
      tools,
      this.tools,
      'UpdateAgentRequest.tools',
    ),
    clearTools:
        clearTools ??
        (identical(tools, unsetCopyWithValue)
            ? this.clearTools
            : tools == null),
  );
}
