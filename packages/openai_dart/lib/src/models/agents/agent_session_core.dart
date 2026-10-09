part of 'agent_session_models.dart';

/// Parameters for creating a Managed Agents session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateAgentSessionRequest extends AgentJsonModel {
  /// Creates a validated [CreateAgentSessionRequest].
  CreateAgentSessionRequest({
    this.agent,
    this.agentId,
    required this.environment,
    AgentSessionInitialInput? input,
    bool clearInput = false,
    Map<String, String>? metadata,
    bool clearMetadata = false,
    AgentSessionSpendControlConfig? spendControl,
    bool clearSpendControl = false,
    this.stream,
    List<String>? vaultIds,
    bool clearVaultIds = false,
  }) : clearInput = clearInput,
       input = clearInput ? null : input,
       clearMetadata = clearMetadata,
       metadata = ownAgentValue<Map<String, String>>(
         clearMetadata ? null : metadata,
         Map<String, String>.unmodifiable,
       ),
       clearSpendControl = clearSpendControl,
       spendControl = clearSpendControl ? null : spendControl,
       clearVaultIds = clearVaultIds,
       vaultIds = ownAgentValue<List<String>>(
         clearVaultIds ? null : vaultIds,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Agent configuration. With `agent_id`, supplied fields override the saved agent for this session. Without `agent_id`, `model` is required.
  final AgentSessionAgentConfig? agent;

  /// The ID of a saved reusable agent. Omit `agent` to use its configuration unchanged.
  final String? agentId;

  /// An inline execution environment or a reference to an environment template.
  final AgentSessionEnvironment environment;

  /// Initial input to submit when the session is created. A string is shorthand for a single user message. Required when `environment.type` is `none`, or when `stream` is `true` for an environment that is not `self_hosted`; optional for self-hosted and non-streaming execution environments.
  final AgentSessionInitialInput? input;

  /// Sends `input: null`, rather than omitting it.
  final bool clearInput;

  /// Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters. Omission or null defaults to an empty map.
  final Map<String, String>? metadata;

  /// Sends `metadata: null`, rather than omitting it.
  final bool clearMetadata;

  /// Optional spending limit in USD cents. Omission or null creates an unlimited session.
  final AgentSessionSpendControlConfig? spendControl;

  /// Sends `spend_control: null`, rather than omitting it.
  final bool clearSpendControl;

  /// Whether to stream session events as server-sent events. Defaults to `false`.
  final bool? stream;

  /// The IDs of vaults made available to the session.
  final List<String>? vaultIds;

  /// Sends `vault_ids: null`, rather than omitting it.
  final bool clearVaultIds;

  /// Parses [CreateAgentSessionRequest] with contextual, payload-free errors.
  factory CreateAgentSessionRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'agent',
      'agent_id',
      'environment',
      'input',
      'metadata',
      'spend_control',
      'stream',
      'vault_ids',
    ], 'CreateAgentSessionRequest');
    return CreateAgentSessionRequest(
      agent: optionalAgentValue(
        json,
        'agent',
        'CreateAgentSessionRequest.agent',
        (value, context) => AgentSessionAgentConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      ),
      agentId: optionalAgentValue(
        json,
        'agent_id',
        'CreateAgentSessionRequest.agentId',
        requireAgentString,
        nullable: false,
      ),
      environment: requiredAgentValue(
        json,
        'environment',
        'CreateAgentSessionRequest.environment',
        (value, context) => AgentSessionEnvironment.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      input: optionalAgentValue(
        json,
        'input',
        'CreateAgentSessionRequest.input',
        (value, context) => AgentSessionInitialInput.fromJson(value),
        nullable: true,
      ),
      clearInput: json.containsKey('input') && json['input'] == null,
      metadata: optionalAgentValue(
        json,
        'metadata',
        'CreateAgentSessionRequest.metadata',
        requireAgentStringMap,
        nullable: true,
      ),
      clearMetadata: json.containsKey('metadata') && json['metadata'] == null,
      spendControl: optionalAgentValue(
        json,
        'spend_control',
        'CreateAgentSessionRequest.spendControl',
        (value, context) => AgentSessionSpendControlConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearSpendControl:
          json.containsKey('spend_control') && json['spend_control'] == null,
      stream: optionalAgentValue(
        json,
        'stream',
        'CreateAgentSessionRequest.stream',
        requireAgentBool,
        nullable: false,
      ),
      vaultIds: optionalAgentValue(
        json,
        'vault_ids',
        'CreateAgentSessionRequest.vaultIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearVaultIds: json.containsKey('vault_ids') && json['vault_ids'] == null,
    );
  }
  @override
  void validate() {
    _validateAgentSessionCreation(
      agentId: agentId,
      agent: agent,
      environment: environment,
      input: input,
      stream: stream ?? false,
    );
    _validateAgentSessionRuntimeBudget(toJson());
    if (agent != null) {
      agent!.validate();
    }
    if (agentId != null) {
      validateAgentLength(
        agentId!,
        'CreateAgentSessionRequest.agentId',
        min: 0,
        max: 64,
      );
    }
    environment.validate();
    if (input != null) {
      input!.validate();
    }
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'CreateAgentSessionRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'CreateAgentSessionRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'CreateAgentSessionRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
    if (spendControl != null) {
      spendControl!.validate();
    }
    if (vaultIds != null) {
      validateAgentCount(
        vaultIds!.length,
        'CreateAgentSessionRequest.vaultIds',
        min: 0,
        max: 16384,
      );
      for (final item in vaultIds!) {
        validateAgentLength(
          item,
          'CreateAgentSessionRequest.vaultIds',
          min: 0,
          max: 1048576,
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (agent != null) 'agent': agent!.toJson(),
    'agent_id': ?agentId,
    'environment': environment.toJson(),
    if (clearInput)
      'input': null
    else if (input != null)
      'input': input!.toJson(),
    if (clearMetadata) 'metadata': null else 'metadata': ?metadata,
    if (clearSpendControl)
      'spend_control': null
    else if (spendControl != null)
      'spend_control': spendControl!.toJson(),
    'stream': ?stream,
    if (clearVaultIds)
      'vault_ids': null
    else if (vaultIds != null)
      'vault_ids': vaultIds!.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateAgentSessionRequest copyWith({
    Object? agent = unsetCopyWithValue,
    Object? agentId = unsetCopyWithValue,
    AgentSessionEnvironment? environment,
    Object? input = unsetCopyWithValue,
    bool? clearInput,
    Object? metadata = unsetCopyWithValue,
    bool? clearMetadata,
    Object? spendControl = unsetCopyWithValue,
    bool? clearSpendControl,
    Object? stream = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
    bool? clearVaultIds,
  }) => CreateAgentSessionRequest(
    agent: copyAgentValue<AgentSessionAgentConfig>(
      agent,
      this.agent,
      'CreateAgentSessionRequest.agent',
    ),
    agentId: copyAgentValue<String>(
      agentId,
      this.agentId,
      'CreateAgentSessionRequest.agentId',
    ),
    environment: environment ?? this.environment,
    input: copyAgentValue<AgentSessionInitialInput>(
      input,
      this.input,
      'CreateAgentSessionRequest.input',
    ),
    clearInput:
        clearInput ??
        (identical(input, unsetCopyWithValue)
            ? this.clearInput
            : input == null),
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'CreateAgentSessionRequest.metadata',
    ),
    clearMetadata:
        clearMetadata ??
        (identical(metadata, unsetCopyWithValue)
            ? this.clearMetadata
            : metadata == null),
    spendControl: copyAgentValue<AgentSessionSpendControlConfig>(
      spendControl,
      this.spendControl,
      'CreateAgentSessionRequest.spendControl',
    ),
    clearSpendControl:
        clearSpendControl ??
        (identical(spendControl, unsetCopyWithValue)
            ? this.clearSpendControl
            : spendControl == null),
    stream: copyAgentValue<bool>(
      stream,
      this.stream,
      'CreateAgentSessionRequest.stream',
    ),
    vaultIds: copyAgentValue<List<String>>(
      vaultIds,
      this.vaultIds,
      'CreateAgentSessionRequest.vaultIds',
    ),
    clearVaultIds:
        clearVaultIds ??
        (identical(vaultIds, unsetCopyWithValue)
            ? this.clearVaultIds
            : vaultIds == null),
  );
}

/// Input events submitted to an existing session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateAgentSessionEventsRequest extends AgentJsonModel {
  /// Creates a validated [CreateAgentSessionEventsRequest].
  CreateAgentSessionEventsRequest({required List<AgentSessionInput> events})
    : events = List.unmodifiable(events) {
    validate();
  }

  /// The input events to submit to the session.
  final List<AgentSessionInput> events;

  /// Parses [CreateAgentSessionEventsRequest] with contextual, payload-free errors.
  factory CreateAgentSessionEventsRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'events',
    ], 'CreateAgentSessionEventsRequest');
    return CreateAgentSessionEventsRequest(
      events: requiredAgentValue(
        json,
        'events',
        'CreateAgentSessionEventsRequest.events',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionInput.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateAgentSessionEventRuntimeBudget(toJson());
    validateAgentCount(
      events.length,
      'CreateAgentSessionEventsRequest.events',
      min: 0,
      max: 16384,
    );
    for (final item in events) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'events': events.map((value) => value.toJson()).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateAgentSessionEventsRequest copyWith({List<AgentSessionInput>? events}) =>
      CreateAgentSessionEventsRequest(events: events ?? this.events);
}

/// A request to spawn a subagent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionCreateSubagentCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionCreateSubagentCallItemResource].
  AgentSessionCreateSubagentCallItemResource({
    required this.agentId,
    required List<AgentSessionContent> content,
    required this.id,
    required this.model,
    required this.reasoningEffort,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       rawJson = agentExtras(rawJson, const [
         'agent_id',
         'content',
         'id',
         'model',
         'reasoning_effort',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionCreateSubagentCallItemResource') {
    validate();
  }

  /// The ID of the agent that requested the subagent.
  final String agentId;

  /// The task given to the spawned agent.
  final List<AgentSessionContent> content;

  /// The ID of the tool call item.
  final String id;

  /// The model requested for the spawned agent.
  final String? model;

  /// The reasoning effort requested for the spawned agent.
  final String? reasoningEffort;

  /// The status of the tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `create_subagent_call`.
  @override
  String get type => 'create_subagent_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionCreateSubagentCallItemResource] with contextual, payload-free errors.
  factory AgentSessionCreateSubagentCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'create_subagent_call',
      'AgentSessionCreateSubagentCallItemResource',
    );
    return AgentSessionCreateSubagentCallItemResource(
      agentId: requiredAgentValue(
        json,
        'agent_id',
        'AgentSessionCreateSubagentCallItemResource.agentId',
        requireAgentString,
        nullable: false,
      )!,
      content: requiredAgentValue(
        json,
        'content',
        'AgentSessionCreateSubagentCallItemResource.content',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionContent.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionCreateSubagentCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      model: requiredAgentValue(
        json,
        'model',
        'AgentSessionCreateSubagentCallItemResource.model',
        requireAgentString,
        nullable: true,
      ),
      reasoningEffort: requiredAgentValue(
        json,
        'reasoning_effort',
        'AgentSessionCreateSubagentCallItemResource.reasoningEffort',
        requireAgentString,
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionCreateSubagentCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionCreateSubagentCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'agent_id',
            'content',
            'id',
            'model',
            'reasoning_effort',
            'status',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      agentId,
      'AgentSessionCreateSubagentCallItemResource.agentId',
      min: 0,
    );
    validateAgentCount(
      content.length,
      'AgentSessionCreateSubagentCallItemResource.content',
      min: 0,
      max: 2000,
    );
    for (final item in content) {
      item.validate();
    }
    validateAgentLength(
      id,
      'AgentSessionCreateSubagentCallItemResource.id',
      min: 0,
    );
    if (model != null) {
      validateAgentLength(
        model!,
        'AgentSessionCreateSubagentCallItemResource.model',
        min: 0,
      );
    }
    if (reasoningEffort != null) {
      validateAgentLength(
        reasoningEffort!,
        'AgentSessionCreateSubagentCallItemResource.reasoningEffort',
        min: 0,
      );
    }
    validateAgentLength(
      turnId,
      'AgentSessionCreateSubagentCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'agent_id': agentId,
    'content': content.map((value) => value.toJson()).toList(),
    'id': id,
    'model': model,
    'reasoning_effort': reasoningEffort,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionCreateSubagentCallItemResource copyWith({
    String? agentId,
    List<AgentSessionContent>? content,
    String? id,
    Object? model = unsetCopyWithValue,
    Object? reasoningEffort = unsetCopyWithValue,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionCreateSubagentCallItemResource(
    agentId: agentId ?? this.agentId,
    content: content ?? this.content,
    id: id ?? this.id,
    model: copyAgentValue<String>(
      model,
      this.model,
      'AgentSessionCreateSubagentCallItemResource.model',
    ),
    reasoningEffort: copyAgentValue<String>(
      reasoningEffort,
      this.reasoningEffort,
      'AgentSessionCreateSubagentCallItemResource.reasoningEffort',
    ),
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A Managed Agents session removed from the public API. Physical cleanup may continue asynchronously.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class DeletedAgentSession extends AgentJsonModel {
  /// Creates a validated [DeletedAgentSession].
  DeletedAgentSession({
    required this.deleted,
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'deleted',
         'id',
         'object',
       ], 'DeletedAgentSession') {
    validate();
  }

  /// Whether the session has been removed from the public API. Always `true`. Physical cleanup may still be in progress.
  final bool deleted;

  /// The ID of the deleted session.
  final String id;

  /// The object type. Always `agent.session.deleted`.
  String get object => 'agent.session.deleted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [DeletedAgentSession] with contextual, payload-free errors.
  factory DeletedAgentSession.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.session.deleted',
      'DeletedAgentSession',
    );
    return DeletedAgentSession(
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedAgentSession.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'DeletedAgentSession.id',
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
    validateAgentLength(id, 'DeletedAgentSession.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'deleted': deleted,
    'id': id,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  DeletedAgentSession copyWith({
    bool? deleted,
    String? id,
    Map<String, dynamic>? rawJson,
  }) => DeletedAgentSession(
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Agent configuration for a session. Omitted fields inherit from `agent_id` when supplied. Supplied objects and arrays replace the whole field; null resets nullable fields.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionAgentConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionAgentConfig].
  AgentSessionAgentConfig({
    String? instructions,
    bool clearInstructions = false,
    this.model,
    AgentMultiAgentConfig? multiAgent,
    bool clearMultiAgent = false,
    AgentReasoningConfig? reasoning,
    bool clearReasoning = false,
    AgentServiceTierParam? serviceTier,
    bool clearServiceTier = false,
    AgentTextConfig? text,
    bool clearText = false,
    List<AgentSessionTool>? tools,
    bool clearTools = false,
  }) : clearInstructions = clearInstructions,
       instructions = clearInstructions ? null : instructions,
       clearMultiAgent = clearMultiAgent,
       multiAgent = clearMultiAgent ? null : multiAgent,
       clearReasoning = clearReasoning,
       reasoning = clearReasoning ? null : reasoning,
       clearServiceTier = clearServiceTier,
       serviceTier = clearServiceTier ? null : serviceTier,
       clearText = clearText,
       text = clearText ? null : text,
       clearTools = clearTools,
       tools = ownAgentValue<List<AgentSessionTool>>(
         clearTools ? null : tools,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Additional instructions appended to the agent's default base instructions. Omit to leave unchanged.
  final String? instructions;

  /// Sends `instructions: null`, rather than omitting it.
  final bool clearInstructions;

  /// The model to use for the agent. The requested model name is preserved.
  final String? model;

  /// Configuration for creating and coordinating subagents.
  final AgentMultiAgentConfig? multiAgent;

  /// Sends `multi_agent: null`, rather than omitting it.
  final bool clearMultiAgent;

  /// Configuration for model reasoning. Omit to keep the current settings; pass `null` to reset to the model's default effort.
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

  /// Tools available to the agent. Omit to inherit, or pass null to clear them. The resolved tool list must fit within 3 MiB (3,145,728 bytes) of compact UTF-8 JSON.
  final List<AgentSessionTool>? tools;

  /// Sends `tools: null`, rather than omitting it.
  final bool clearTools;

  /// Parses [AgentSessionAgentConfig] with contextual, payload-free errors.
  factory AgentSessionAgentConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'instructions',
      'model',
      'multi_agent',
      'reasoning',
      'service_tier',
      'text',
      'tools',
    ], 'AgentSessionAgentConfig');
    return AgentSessionAgentConfig(
      instructions: optionalAgentValue(
        json,
        'instructions',
        'AgentSessionAgentConfig.instructions',
        requireAgentString,
        nullable: true,
      ),
      clearInstructions:
          json.containsKey('instructions') && json['instructions'] == null,
      model: optionalAgentValue(
        json,
        'model',
        'AgentSessionAgentConfig.model',
        requireAgentString,
        nullable: false,
      ),
      multiAgent: optionalAgentValue(
        json,
        'multi_agent',
        'AgentSessionAgentConfig.multiAgent',
        (value, context) =>
            AgentMultiAgentConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearMultiAgent:
          json.containsKey('multi_agent') && json['multi_agent'] == null,
      reasoning: optionalAgentValue(
        json,
        'reasoning',
        'AgentSessionAgentConfig.reasoning',
        (value, context) =>
            AgentReasoningConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearReasoning:
          json.containsKey('reasoning') && json['reasoning'] == null,
      serviceTier: optionalAgentValue(
        json,
        'service_tier',
        'AgentSessionAgentConfig.serviceTier',
        (value, context) => AgentServiceTierParam.fromJson(value),
        nullable: true,
      ),
      clearServiceTier:
          json.containsKey('service_tier') && json['service_tier'] == null,
      text: optionalAgentValue(
        json,
        'text',
        'AgentSessionAgentConfig.text',
        (value, context) =>
            AgentTextConfig.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearText: json.containsKey('text') && json['text'] == null,
      tools: optionalAgentValue(
        json,
        'tools',
        'AgentSessionAgentConfig.tools',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) =>
                  AgentSessionTool.fromJson(requireAgentObject(value, context)),
            )
            .toList(),
        nullable: true,
      ),
      clearTools: json.containsKey('tools') && json['tools'] == null,
    );
  }
  @override
  void validate() {
    if (tools != null) {
      validateAgentToolBudget(tools!.map((tool) => tool.toJson()).toList());
    }
    if (instructions != null) {
      validateAgentLength(
        instructions!,
        'AgentSessionAgentConfig.instructions',
        min: 0,
        max: 1048576,
      );
    }
    if (model != null) {
      validateAgentLength(
        model!,
        'AgentSessionAgentConfig.model',
        min: 0,
        max: 1048576,
      );
    }
    if (multiAgent != null) {
      multiAgent!.validate();
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
      ], 'AgentSessionAgentConfig.serviceTier');
    }
    if (text != null) {
      text!.validate();
    }
    if (tools != null) {
      validateAgentCount(
        tools!.length,
        'AgentSessionAgentConfig.tools',
        min: 0,
        max: 16384,
      );
      for (final item in tools!) {
        item.validate();
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearInstructions)
      'instructions': null
    else
      'instructions': ?instructions,
    'model': ?model,
    if (clearMultiAgent)
      'multi_agent': null
    else if (multiAgent != null)
      'multi_agent': multiAgent!.toJson(),
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
  AgentSessionAgentConfig copyWith({
    Object? instructions = unsetCopyWithValue,
    bool? clearInstructions,
    Object? model = unsetCopyWithValue,
    Object? multiAgent = unsetCopyWithValue,
    bool? clearMultiAgent,
    Object? reasoning = unsetCopyWithValue,
    bool? clearReasoning,
    Object? serviceTier = unsetCopyWithValue,
    bool? clearServiceTier,
    Object? text = unsetCopyWithValue,
    bool? clearText,
    Object? tools = unsetCopyWithValue,
    bool? clearTools,
  }) => AgentSessionAgentConfig(
    instructions: copyAgentValue<String>(
      instructions,
      this.instructions,
      'AgentSessionAgentConfig.instructions',
    ),
    clearInstructions:
        clearInstructions ??
        (identical(instructions, unsetCopyWithValue)
            ? this.clearInstructions
            : instructions == null),
    model: copyAgentValue<String>(
      model,
      this.model,
      'AgentSessionAgentConfig.model',
    ),
    multiAgent: copyAgentValue<AgentMultiAgentConfig>(
      multiAgent,
      this.multiAgent,
      'AgentSessionAgentConfig.multiAgent',
    ),
    clearMultiAgent:
        clearMultiAgent ??
        (identical(multiAgent, unsetCopyWithValue)
            ? this.clearMultiAgent
            : multiAgent == null),
    reasoning: copyAgentValue<AgentReasoningConfig>(
      reasoning,
      this.reasoning,
      'AgentSessionAgentConfig.reasoning',
    ),
    clearReasoning:
        clearReasoning ??
        (identical(reasoning, unsetCopyWithValue)
            ? this.clearReasoning
            : reasoning == null),
    serviceTier: copyAgentValue<AgentServiceTierParam>(
      serviceTier,
      this.serviceTier,
      'AgentSessionAgentConfig.serviceTier',
    ),
    clearServiceTier:
        clearServiceTier ??
        (identical(serviceTier, unsetCopyWithValue)
            ? this.clearServiceTier
            : serviceTier == null),
    text: copyAgentValue<AgentTextConfig>(
      text,
      this.text,
      'AgentSessionAgentConfig.text',
    ),
    clearText:
        clearText ??
        (identical(text, unsetCopyWithValue) ? this.clearText : text == null),
    tools: copyAgentValue<List<AgentSessionTool>>(
      tools,
      this.tools,
      'AgentSessionAgentConfig.tools',
    ),
    clearTools:
        clearTools ??
        (identical(tools, unsetCopyWithValue)
            ? this.clearTools
            : tools == null),
  );
}

/// The effective agent configuration for a session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionAgent extends AgentJsonModel {
  /// Creates a validated [AgentSessionAgent].
  AgentSessionAgent({
    required this.id,
    required this.instructions,
    required this.model,
    required this.multiAgent,
    required this.name,
    required this.reasoning,
    required this.serviceTier,
    required this.text,
    required List<AgentSessionToolResource> tools,
    Map<String, dynamic> rawJson = const {},
  }) : tools = List.unmodifiable(tools),
       rawJson = agentExtras(rawJson, const [
         'id',
         'instructions',
         'model',
         'multi_agent',
         'name',
         'reasoning',
         'service_tier',
         'text',
         'tools',
       ], 'AgentSessionAgent') {
    validate();
  }

  /// The ID of the agent.
  final String id;

  /// Custom instructions appended to the agent's default base instructions.
  final String? instructions;

  /// The model used by the agent.
  final String model;

  /// Configuration for creating and coordinating subagents.
  final AgentMultiAgent multiAgent;

  /// The reusable agent's name when the session was created, or null if no name was saved. Later changes to the agent's name do not affect this value.
  final String? name;

  /// The agent's reasoning configuration.
  final AgentReasoning reasoning;

  /// The effective service-tier policy for model requests. Defaults to `auto`.
  final AgentServiceTierResource serviceTier;

  /// Configuration for text generated by the agent.
  final AgentText text;

  /// Tools available to the agent.
  final List<AgentSessionToolResource> tools;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionAgent] with contextual, payload-free errors.
  factory AgentSessionAgent.fromJson(Map<String, dynamic> json) {
    return AgentSessionAgent(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionAgent.id',
        requireAgentString,
        nullable: false,
      )!,
      instructions: requiredAgentValue(
        json,
        'instructions',
        'AgentSessionAgent.instructions',
        requireAgentString,
        nullable: true,
      ),
      model: requiredAgentValue(
        json,
        'model',
        'AgentSessionAgent.model',
        requireAgentString,
        nullable: false,
      )!,
      multiAgent: requiredAgentValue(
        json,
        'multi_agent',
        'AgentSessionAgent.multiAgent',
        (value, context) =>
            AgentMultiAgent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionAgent.name',
        requireAgentString,
        nullable: true,
      ),
      reasoning: requiredAgentValue(
        json,
        'reasoning',
        'AgentSessionAgent.reasoning',
        (value, context) =>
            AgentReasoning.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      serviceTier: requiredAgentValue(
        json,
        'service_tier',
        'AgentSessionAgent.serviceTier',
        (value, context) => AgentServiceTierResource.fromJson(value),
        nullable: false,
      )!,
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionAgent.text',
        (value, context) =>
            AgentText.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      tools: requiredAgentValue(
        json,
        'tools',
        'AgentSessionAgent.tools',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionToolResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'instructions',
            'model',
            'multi_agent',
            'name',
            'reasoning',
            'service_tier',
            'text',
            'tools',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'AgentSessionAgent.id', min: 0);
    if (instructions != null) {
      validateAgentLength(
        instructions!,
        'AgentSessionAgent.instructions',
        min: 0,
      );
    }
    validateAgentLength(model, 'AgentSessionAgent.model', min: 0);
    multiAgent.validate();
    if (name != null) {
      validateAgentLength(name!, 'AgentSessionAgent.name', min: 0);
    }
    reasoning.validate();
    text.validate();
    validateAgentCount(
      tools.length,
      'AgentSessionAgent.tools',
      min: 0,
      max: 2000,
    );
    for (final item in tools) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'instructions': instructions,
    'model': model,
    'multi_agent': multiAgent.toJson(),
    'name': name,
    'reasoning': reasoning.toJson(),
    'service_tier': serviceTier.toJson(),
    'text': text.toJson(),
    'tools': tools.map((value) => value.toJson()).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionAgent copyWith({
    String? id,
    Object? instructions = unsetCopyWithValue,
    String? model,
    AgentMultiAgent? multiAgent,
    Object? name = unsetCopyWithValue,
    AgentReasoning? reasoning,
    AgentServiceTierResource? serviceTier,
    AgentText? text,
    List<AgentSessionToolResource>? tools,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionAgent(
    id: id ?? this.id,
    instructions: copyAgentValue<String>(
      instructions,
      this.instructions,
      'AgentSessionAgent.instructions',
    ),
    model: model ?? this.model,
    multiAgent: multiAgent ?? this.multiAgent,
    name: copyAgentValue<String>(name, this.name, 'AgentSessionAgent.name'),
    reasoning: reasoning ?? this.reasoning,
    serviceTier: serviceTier ?? this.serviceTier,
    text: text ?? this.text,
    tools: tools ?? this.tools,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An error reported while preparing a session environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentErrorResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionEnvironmentErrorResource].
  AgentSessionEnvironmentErrorResource({
    required this.code,
    required this.message,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'code',
         'message',
         'type',
       ], 'AgentSessionEnvironmentErrorResource') {
    validate();
  }

  /// A machine-readable error code.
  final String code;

  /// A human-readable error message.
  final String message;

  /// The error type.
  final String type;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentErrorResource] with contextual, payload-free errors.
  factory AgentSessionEnvironmentErrorResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionEnvironmentErrorResource(
      code: requiredAgentValue(
        json,
        'code',
        'AgentSessionEnvironmentErrorResource.code',
        requireAgentString,
        nullable: false,
      )!,
      message: requiredAgentValue(
        json,
        'message',
        'AgentSessionEnvironmentErrorResource.message',
        requireAgentString,
        nullable: false,
      )!,
      type: requiredAgentValue(
        json,
        'type',
        'AgentSessionEnvironmentErrorResource.type',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['code', 'message', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      code,
      'AgentSessionEnvironmentErrorResource.code',
      min: 0,
    );
    validateAgentLength(
      message,
      'AgentSessionEnvironmentErrorResource.message',
      min: 0,
    );
    validateAgentLength(
      type,
      'AgentSessionEnvironmentErrorResource.type',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'code': code,
    'message': message,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentErrorResource copyWith({
    String? code,
    String? message,
    String? type,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentErrorResource(
    code: code ?? this.code,
    message: message ?? this.message,
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The current state of a session environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentStateResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionEnvironmentStateResource].
  AgentSessionEnvironmentStateResource({
    required this.error,
    required this.id,
    required this.status,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'error',
         'id',
         'status',
         'type',
       ], 'AgentSessionEnvironmentStateResource') {
    validate();
  }

  /// The error reported while preparing the environment, if any.
  final AgentSessionEnvironmentErrorResource? error;

  /// The public ID of the environment.
  final String id;

  /// The environment's connection status.
  final AgentSessionEnvironmentStatusResource status;

  /// The environment type.
  final String type;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentStateResource] with contextual, payload-free errors.
  factory AgentSessionEnvironmentStateResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionEnvironmentStateResource(
      error: requiredAgentValue(
        json,
        'error',
        'AgentSessionEnvironmentStateResource.error',
        (value, context) => AgentSessionEnvironmentErrorResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionEnvironmentStateResource.id',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionEnvironmentStateResource.status',
        (value, context) =>
            AgentSessionEnvironmentStatusResource.fromJson(value),
        nullable: false,
      )!,
      type: requiredAgentValue(
        json,
        'type',
        'AgentSessionEnvironmentStateResource.type',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['error', 'id', 'status', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (error != null) {
      error!.validate();
    }
    validateAgentLength(id, 'AgentSessionEnvironmentStateResource.id', min: 0);
    validateAgentLength(
      type,
      'AgentSessionEnvironmentStateResource.type',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'error': error?.toJson(),
    'id': id,
    'status': status.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentStateResource copyWith({
    Object? error = unsetCopyWithValue,
    String? id,
    AgentSessionEnvironmentStatusResource? status,
    String? type,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentStateResource(
    error: copyAgentValue<AgentSessionEnvironmentErrorResource>(
      error,
      this.error,
      'AgentSessionEnvironmentStateResource.error',
    ),
    id: id ?? this.id,
    status: status ?? this.status,
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An error payload with the same public fields as Responses API streaming errors.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionErrorResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionErrorResource].
  AgentSessionErrorResource({
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
       ], 'AgentSessionErrorResource') {
    validate();
  }

  /// The machine-readable error code, if any.
  final String? code;

  /// A customer-safe explanation of the error.
  final String message;

  /// The request parameter associated with the error, if any.
  final String? param;

  /// The error type.
  final String type;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionErrorResource] with contextual, payload-free errors.
  factory AgentSessionErrorResource.fromJson(Map<String, dynamic> json) {
    return AgentSessionErrorResource(
      code: requiredAgentValue(
        json,
        'code',
        'AgentSessionErrorResource.code',
        requireAgentString,
        nullable: true,
      ),
      message: requiredAgentValue(
        json,
        'message',
        'AgentSessionErrorResource.message',
        requireAgentString,
        nullable: false,
      )!,
      param: requiredAgentValue(
        json,
        'param',
        'AgentSessionErrorResource.param',
        requireAgentString,
        nullable: true,
      ),
      type: requiredAgentValue(
        json,
        'type',
        'AgentSessionErrorResource.type',
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
    if (code != null) {
      validateAgentLength(code!, 'AgentSessionErrorResource.code', min: 0);
    }
    validateAgentLength(message, 'AgentSessionErrorResource.message', min: 0);
    if (param != null) {
      validateAgentLength(param!, 'AgentSessionErrorResource.param', min: 0);
    }
    validateAgentLength(type, 'AgentSessionErrorResource.type', min: 0);
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
  AgentSessionErrorResource copyWith({
    Object? code = unsetCopyWithValue,
    String? message,
    Object? param = unsetCopyWithValue,
    String? type,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionErrorResource(
    code: copyAgentValue<String>(
      code,
      this.code,
      'AgentSessionErrorResource.code',
    ),
    message: message ?? this.message,
    param: copyAgentValue<String>(
      param,
      this.param,
      'AgentSessionErrorResource.param',
    ),
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionList extends AgentJsonModel {
  /// Creates a validated [AgentSessionList].
  AgentSessionList({
    required List<AgentSession> data,
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
       ], 'AgentSessionList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<AgentSession> data;

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

  /// Parses [AgentSessionList] with contextual, payload-free errors.
  factory AgentSessionList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentSessionList');
    return AgentSessionList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) =>
                  AgentSession.fromJson(requireAgentObject(value, context)),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentSessionList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentSessionList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentSessionList.lastId',
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
    validateAgentCount(data.length, 'AgentSessionList.data', min: 0, max: 2000);
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'AgentSessionList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'AgentSessionList.lastId', min: 0);
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
  AgentSessionList copyWith({
    List<AgentSession>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentSessionList.firstId',
    ),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentSessionList.lastId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An action that must be completed before a session can continue.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionRequiredAction extends AgentJsonModel {
  const AgentSessionRequiredAction();

  /// Parses a known contract or detached future received value.
  factory AgentSessionRequiredAction.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionRequiredAction.type',
    )) {
      'computer_use_approval_request' =>
        AgentSessionComputerUseApprovalRequiredAction.fromJson(json),
      'environment_connection' =>
        AgentSessionEnvironmentConnectionRequiredAction.fromJson(json),
      'function_call' => AgentSessionFunctionCallRequiredAction.fromJson(json),
      _ => UnknownAgentSessionRequiredAction.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `computer_use_approval_request` contract.
  factory AgentSessionRequiredAction.computerUseApprovalRequest({
    required AgentSessionComputerUseApprovalRequestKind request,
    required String requestId,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionComputerUseApprovalRequiredAction;

  /// Builds the `environment_connection` contract.
  factory AgentSessionRequiredAction.environmentConnection({
    required String environmentId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEnvironmentConnectionRequiredAction;

  /// Builds the `function_call` contract.
  factory AgentSessionRequiredAction.functionCall({
    required Object? arguments,
    required String callId,
    required String name,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionFunctionCallRequiredAction;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionRequiredAction
    extends AgentSessionRequiredAction {
  const UnknownAgentSessionRequiredAction._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionRequiredAction.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionRequiredAction.type',
    );
    if (const [
      'computer_use_approval_request',
      'environment_connection',
      'function_call',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionRequiredAction: expected a future discriminator',
      );
    }
    return UnknownAgentSessionRequiredAction._(
      snapshotAgentJson(json, 'UnknownAgentSessionRequiredAction'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionRequiredAction copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionRequiredAction.fromJson(rawJson ?? this.rawJson);
}

/// Reconnect a session environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentConnectionRequiredAction
    extends AgentSessionRequiredAction {
  /// Creates a validated [AgentSessionEnvironmentConnectionRequiredAction].
  AgentSessionEnvironmentConnectionRequiredAction({
    required this.environmentId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment_id',
         'type',
       ], 'AgentSessionEnvironmentConnectionRequiredAction') {
    validate();
  }

  /// The ID of the environment to reconnect.
  final String environmentId;

  /// The type of the object. Always `environment_connection`.
  @override
  String get type => 'environment_connection';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentConnectionRequiredAction] with contextual, payload-free errors.
  factory AgentSessionEnvironmentConnectionRequiredAction.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'environment_connection',
      'AgentSessionEnvironmentConnectionRequiredAction',
    );
    return AgentSessionEnvironmentConnectionRequiredAction(
      environmentId: requiredAgentValue(
        json,
        'environment_id',
        'AgentSessionEnvironmentConnectionRequiredAction.environmentId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['environment_id', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      environmentId,
      'AgentSessionEnvironmentConnectionRequiredAction.environmentId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment_id': environmentId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentConnectionRequiredAction copyWith({
    String? environmentId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentConnectionRequiredAction(
    environmentId: environmentId ?? this.environmentId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Run a function tool and submit its result.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionFunctionCallRequiredAction
    extends AgentSessionRequiredAction {
  /// Creates a validated [AgentSessionFunctionCallRequiredAction].
  AgentSessionFunctionCallRequiredAction({
    required Object? arguments,
    required this.callId,
    required this.name,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : arguments = snapshotAgentJson({
         'value': arguments,
       }, 'AgentSessionFunctionCallRequiredAction.arguments')['value'],
       rawJson = agentExtras(rawJson, const [
         'arguments',
         'call_id',
         'name',
         'turn_id',
         'type',
       ], 'AgentSessionFunctionCallRequiredAction') {
    validate();
  }

  /// The arguments supplied by the model.
  final Object? arguments;

  /// The ID to include when submitting the function result.
  final String callId;

  /// The function name.
  final String name;

  /// The ID of the turn that requested the function call.
  final String turnId;

  /// The type of the object. Always `function_call`.
  @override
  String get type => 'function_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionFunctionCallRequiredAction] with contextual, payload-free errors.
  factory AgentSessionFunctionCallRequiredAction.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'function_call',
      'AgentSessionFunctionCallRequiredAction',
    );
    return AgentSessionFunctionCallRequiredAction(
      arguments: requiredAgentValue(
        json,
        'arguments',
        'AgentSessionFunctionCallRequiredAction.arguments',
        (value, context) =>
            snapshotAgentJson({'value': value}, context)['value'],
        nullable: true,
      ),
      callId: requiredAgentValue(
        json,
        'call_id',
        'AgentSessionFunctionCallRequiredAction.callId',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionFunctionCallRequiredAction.name',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionFunctionCallRequiredAction.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'arguments',
            'call_id',
            'name',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      callId,
      'AgentSessionFunctionCallRequiredAction.callId',
      min: 0,
    );
    validateAgentLength(
      name,
      'AgentSessionFunctionCallRequiredAction.name',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionFunctionCallRequiredAction.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'arguments': arguments,
    'call_id': callId,
    'name': name,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionFunctionCallRequiredAction copyWith({
    Object? arguments = unsetCopyWithValue,
    String? callId,
    String? name,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionFunctionCallRequiredAction(
    arguments: copyAgentValue<Object>(
      arguments,
      this.arguments,
      'AgentSessionFunctionCallRequiredAction.arguments',
    ),
    callId: callId ?? this.callId,
    name: name ?? this.name,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A Managed Agents session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSession extends AgentJsonModel {
  /// Creates a validated [AgentSession].
  AgentSession({
    required this.agent,
    required this.createdAt,
    required this.environment,
    required this.error,
    required this.id,
    required this.lastActiveAt,
    required Map<String, String> metadata,
    required List<AgentSessionRequiredAction> requiredActions,
    this.spendControl,
    required this.status,
    required this.usage,
    required List<String> vaultIds,
    Map<String, dynamic> rawJson = const {},
  }) : metadata = Map<String, String>.unmodifiable(metadata),
       requiredActions = List.unmodifiable(requiredActions),
       vaultIds = List.unmodifiable(vaultIds),
       rawJson = agentExtras(rawJson, const [
         'agent',
         'created_at',
         'environment',
         'error',
         'id',
         'last_active_at',
         'metadata',
         'object',
         'required_actions',
         'spend_control',
         'status',
         'usage',
         'vault_ids',
       ], 'AgentSession') {
    validate();
  }

  /// The agent running in the session.
  final AgentSessionAgent agent;

  /// The Unix timestamp, in seconds, when the session was created.
  final int createdAt;

  /// The execution environment for the session.
  final AgentSessionEnvironmentResource environment;

  /// The error that caused the session to fail, if any.
  final String? error;

  /// The ID of the session.
  final String id;

  /// The Unix timestamp, in seconds, when the session was last active.
  final int lastActiveAt;

  /// Custom string key-value pairs attached to the session.
  final Map<String, String> metadata;

  /// The object type. Always `agent.session`.
  String get object => 'agent.session';

  /// Actions that must be completed before the session can continue.
  final List<AgentSessionRequiredAction> requiredActions;

  /// Configured spending limit and best-effort consumption, in USD cents. Unlimited sessions omit this object.
  final AgentSessionSpendControl? spendControl;

  /// The current status of the session.
  final AgentSessionStatusResource status;

  /// Best-effort token usage for the session, or null if unknown. Recorded usage may change.
  final AgentSessionTokenUsageResource? usage;

  /// The IDs of vaults made available to the session.
  final List<String> vaultIds;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSession] with contextual, payload-free errors.
  factory AgentSession.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'agent.session', 'AgentSession');
    return AgentSession(
      agent: requiredAgentValue(
        json,
        'agent',
        'AgentSession.agent',
        (value, context) =>
            AgentSessionAgent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentSession.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentSession.environment',
        (value, context) => AgentSessionEnvironmentResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      error: requiredAgentValue(
        json,
        'error',
        'AgentSession.error',
        requireAgentString,
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSession.id',
        requireAgentString,
        nullable: false,
      )!,
      lastActiveAt: requiredAgentValue(
        json,
        'last_active_at',
        'AgentSession.lastActiveAt',
        requireAgentInt,
        nullable: false,
      )!,
      metadata: requiredAgentValue(
        json,
        'metadata',
        'AgentSession.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      requiredActions: requiredAgentValue(
        json,
        'required_actions',
        'AgentSession.requiredActions',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionRequiredAction.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      spendControl: optionalAgentValue(
        json,
        'spend_control',
        'AgentSession.spendControl',
        (value, context) => AgentSessionSpendControl.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSession.status',
        (value, context) => AgentSessionStatusResource.fromJson(value),
        nullable: false,
      )!,
      usage: requiredAgentValue(
        json,
        'usage',
        'AgentSession.usage',
        (value, context) => AgentSessionTokenUsageResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      vaultIds: requiredAgentValue(
        json,
        'vault_ids',
        'AgentSession.vaultIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'agent',
            'created_at',
            'environment',
            'error',
            'id',
            'last_active_at',
            'metadata',
            'object',
            'required_actions',
            'spend_control',
            'status',
            'usage',
            'vault_ids',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    agent.validate();
    validateAgentInt(createdAt, 'AgentSession.createdAt');
    environment.validate();
    if (error != null) {
      validateAgentLength(error!, 'AgentSession.error', min: 0);
    }
    validateAgentLength(id, 'AgentSession.id', min: 0);
    validateAgentInt(lastActiveAt, 'AgentSession.lastActiveAt');
    validateAgentCount(metadata.length, 'AgentSession.metadata', min: 0);
    for (final key in metadata.keys) {
      validateAgentLength(key, 'AgentSession.metadata', min: 0);
    }
    for (final item in metadata.values) {
      validateAgentLength(item, 'AgentSession.metadata', min: 0);
    }
    validateAgentCount(
      requiredActions.length,
      'AgentSession.requiredActions',
      min: 0,
      max: 2000,
    );
    for (final item in requiredActions) {
      item.validate();
    }
    if (spendControl != null) {
      spendControl!.validate();
    }
    if (usage != null) {
      usage!.validate();
    }
    validateAgentCount(
      vaultIds.length,
      'AgentSession.vaultIds',
      min: 0,
      max: 2000,
    );
    for (final item in vaultIds) {
      validateAgentLength(item, 'AgentSession.vaultIds', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'agent': agent.toJson(),
    'created_at': createdAt,
    'environment': environment.toJson(),
    'error': error,
    'id': id,
    'last_active_at': lastActiveAt,
    'metadata': metadata,
    'object': object,
    'required_actions': requiredActions.map((value) => value.toJson()).toList(),
    if (spendControl != null) 'spend_control': spendControl!.toJson(),
    'status': status.toJson(),
    'usage': usage?.toJson(),
    'vault_ids': vaultIds.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSession copyWith({
    AgentSessionAgent? agent,
    int? createdAt,
    AgentSessionEnvironmentResource? environment,
    Object? error = unsetCopyWithValue,
    String? id,
    int? lastActiveAt,
    Map<String, String>? metadata,
    List<AgentSessionRequiredAction>? requiredActions,
    Object? spendControl = unsetCopyWithValue,
    AgentSessionStatusResource? status,
    Object? usage = unsetCopyWithValue,
    List<String>? vaultIds,
    Map<String, dynamic>? rawJson,
  }) => AgentSession(
    agent: agent ?? this.agent,
    createdAt: createdAt ?? this.createdAt,
    environment: environment ?? this.environment,
    error: copyAgentValue<String>(error, this.error, 'AgentSession.error'),
    id: id ?? this.id,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    metadata: metadata ?? this.metadata,
    requiredActions: requiredActions ?? this.requiredActions,
    spendControl: copyAgentValue<AgentSessionSpendControl>(
      spendControl,
      this.spendControl,
      'AgentSession.spendControl',
    ),
    status: status ?? this.status,
    usage: copyAgentValue<AgentSessionTokenUsageResource>(
      usage,
      this.usage,
      'AgentSession.usage',
    ),
    vaultIds: vaultIds ?? this.vaultIds,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Sets the session-wide limit without changing recorded spend.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionSpendControlConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionSpendControlConfig].
  AgentSessionSpendControlConfig({required this.limit}) {
    validate();
  }

  /// Positive USD cents, or null to remove the limit.
  final int? limit;

  /// Parses [AgentSessionSpendControlConfig] with contextual, payload-free errors.
  factory AgentSessionSpendControlConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'limit',
    ], 'AgentSessionSpendControlConfig');
    return AgentSessionSpendControlConfig(
      limit: requiredAgentValue(
        json,
        'limit',
        'AgentSessionSpendControlConfig.limit',
        requireAgentInt,
        nullable: true,
      ),
    );
  }
  @override
  void validate() {
    if (limit != null) {
      validateAgentInt(
        limit!,
        'AgentSessionSpendControlConfig.limit',
        min: 1,
        max: 4503599627370495,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {'limit': limit};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSpendControlConfig copyWith({
    Object? limit = unsetCopyWithValue,
  }) => AgentSessionSpendControlConfig(
    limit: copyAgentValue<int>(
      limit,
      this.limit,
      'AgentSessionSpendControlConfig.limit',
    ),
  );
}

/// Session-wide spending control, present only when a limit is configured.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSpendControl extends AgentJsonModel {
  /// Creates a validated [AgentSessionSpendControl].
  AgentSessionSpendControl({
    required this.consumed,
    required this.limit,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'consumed',
         'limit',
       ], 'AgentSessionSpendControl') {
    validate();
  }

  /// Best-effort recorded spend floored to whole USD cents, or null when unavailable.
  final int? consumed;

  /// The configured positive limit in USD cents.
  final int limit;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSpendControl] with contextual, payload-free errors.
  factory AgentSessionSpendControl.fromJson(Map<String, dynamic> json) {
    return AgentSessionSpendControl(
      consumed: requiredAgentValue(
        json,
        'consumed',
        'AgentSessionSpendControl.consumed',
        requireAgentInt,
        nullable: true,
      ),
      limit: requiredAgentValue(
        json,
        'limit',
        'AgentSessionSpendControl.limit',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['consumed', 'limit'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (consumed != null) {
      validateAgentInt(consumed!, 'AgentSessionSpendControl.consumed', min: 0);
    }
    validateAgentInt(
      limit,
      'AgentSessionSpendControl.limit',
      min: 1,
      max: 4503599627370495,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'consumed': consumed,
    'limit': limit,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSpendControl copyWith({
    Object? consumed = unsetCopyWithValue,
    int? limit,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSpendControl(
    consumed: copyAgentValue<int>(
      consumed,
      this.consumed,
      'AgentSessionSpendControl.consumed',
    ),
    limit: limit ?? this.limit,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A customer-safe error describing why a session request failed.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurnErrorResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionTurnErrorResource].
  AgentSessionTurnErrorResource({
    required this.code,
    required this.message,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'code',
         'message',
       ], 'AgentSessionTurnErrorResource') {
    validate();
  }

  /// A stable, machine-readable failure category.
  final AgentSessionTurnErrorCodeResource code;

  /// A customer-safe explanation of the failure.
  final String message;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurnErrorResource] with contextual, payload-free errors.
  factory AgentSessionTurnErrorResource.fromJson(Map<String, dynamic> json) {
    return AgentSessionTurnErrorResource(
      code: requiredAgentValue(
        json,
        'code',
        'AgentSessionTurnErrorResource.code',
        (value, context) => AgentSessionTurnErrorCodeResource.fromJson(value),
        nullable: false,
      )!,
      message: requiredAgentValue(
        json,
        'message',
        'AgentSessionTurnErrorResource.message',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['code', 'message'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      message,
      'AgentSessionTurnErrorResource.message',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'code': code.toJson(),
    'message': message,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurnErrorResource copyWith({
    AgentSessionTurnErrorCodeResource? code,
    String? message,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnErrorResource(
    code: code ?? this.code,
    message: message ?? this.message,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An item associated with a session turn.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionTurnItem extends AgentJsonModel {
  const AgentSessionTurnItem();

  /// Parses a known contract or detached future received value.
  factory AgentSessionTurnItem.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionTurnItem.type',
    )) {
      'agent_message' => AgentSessionAgentMessageItemResource.fromJson(json),
      'close_subagent_call' =>
        AgentSessionCloseSubagentCallItemResource.fromJson(json),
      'command_execution' => AgentSessionCommandExecutionItemResource.fromJson(
        json,
      ),
      'computer_use_approval_request' =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(json),
      'computer_use_approval_request_result' =>
        AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(json),
      'computer_use_call' => AgentSessionComputerUseCallItemResource.fromJson(
        json,
      ),
      'create_subagent_call' =>
        AgentSessionCreateSubagentCallItemResource.fromJson(json),
      'function_call' => AgentSessionFunctionCallItemResource.fromJson(json),
      'function_call_output' =>
        AgentSessionFunctionCallOutputItemResource.fromJson(json),
      'interrupt_subagent_call' =>
        AgentSessionInterruptSubagentCallItemResource.fromJson(json),
      'mcp_call' => AgentSessionMcpCallItemResource.fromJson(json),
      'message' => AgentSessionMessageItemResource.fromJson(json),
      'reasoning' => AgentSessionReasoningItemResource.fromJson(json),
      'resume_subagent_call' =>
        AgentSessionResumeSubagentCallItemResource.fromJson(json),
      'send_subagent_input_call' =>
        AgentSessionSendSubagentInputCallItemResource.fromJson(json),
      'wait_for_subagents_call' =>
        AgentSessionWaitForSubagentsCallItemResource.fromJson(json),
      'web_search_call' => AgentSessionWebSearchCallItemResource.fromJson(json),
      _ => UnknownAgentSessionTurnItem.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `agent_message` contract.
  factory AgentSessionTurnItem.agentMessage({
    required List<AgentSessionContent> content,
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionAgentMessageItemResource;

  /// Builds the `close_subagent_call` contract.
  factory AgentSessionTurnItem.closeSubagentCall({
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionCloseSubagentCallItemResource;

  /// Builds the `command_execution` contract.
  factory AgentSessionTurnItem.commandExecution({
    required String command,
    required String? cwd,
    required int? durationMs,
    required int? exitCode,
    required String id,
    required String? output,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionCommandExecutionItemResource;

  /// Builds the `computer_use_approval_request` contract.
  factory AgentSessionTurnItem.computerUseApprovalRequest({
    required String id,
    required AgentSessionBrowserAuthenticationHistoryRequestKindResource
    request,
    required String requestId,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionBrowserAuthenticationRequestItemResource;

  /// Builds the `computer_use_approval_request_result` contract.
  factory AgentSessionTurnItem.computerUseApprovalRequestResult({
    required String id,
    required String requestId,
    required AgentSessionBrowserAuthenticationResponseResource response,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionComputerUseApprovalRequestResultItemResource;

  /// Builds the `computer_use_call` contract.
  factory AgentSessionTurnItem.computerUseCall({
    required String id,
    required AgentSessionComputerScreenshotResource? output,
    required AgentSessionFunctionCallStatusResource status,
    required String? title,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionComputerUseCallItemResource;

  /// Builds the `create_subagent_call` contract.
  factory AgentSessionTurnItem.createSubagentCall({
    required String agentId,
    required List<AgentSessionContent> content,
    required String id,
    required String? model,
    required String? reasoningEffort,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionCreateSubagentCallItemResource;

  /// Builds the `function_call` contract.
  factory AgentSessionTurnItem.functionCall({
    required Object? arguments,
    required String callId,
    required String id,
    required String name,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionFunctionCallItemResource;

  /// Builds the `function_call_output` contract.
  factory AgentSessionTurnItem.functionCallOutput({
    required String callId,
    required String? error,
    required String id,
    required AgentSessionFunctionOutputResource? output,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionFunctionCallOutputItemResource;

  /// Builds the `interrupt_subagent_call` contract.
  factory AgentSessionTurnItem.interruptSubagentCall({
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionInterruptSubagentCallItemResource;

  /// Builds the `mcp_call` contract.
  factory AgentSessionTurnItem.mcpCall({
    required Object? arguments,
    required Object? error,
    required String id,
    required String name,
    required Object? output,
    required String serverLabel,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMcpCallItemResource;

  /// Builds the `message` contract.
  factory AgentSessionTurnItem.message({
    required List<AgentSessionMessageContent> content,
    required String? id,
    required AgentSessionMessagePhaseResource? phase,
    required AgentSessionMessageRoleResource role,
    required AgentSessionOutputItemStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMessageItemResource;

  /// Builds the `reasoning` contract.
  factory AgentSessionTurnItem.reasoning({
    required String id,
    required AgentSessionOutputItemStatusResource? status,
    required List<AgentSessionSummaryTextResource> summary,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionReasoningItemResource;

  /// Builds the `resume_subagent_call` contract.
  factory AgentSessionTurnItem.resumeSubagentCall({
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionResumeSubagentCallItemResource;

  /// Builds the `send_subagent_input_call` contract.
  factory AgentSessionTurnItem.sendSubagentInputCall({
    required List<AgentSessionContent> content,
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionSendSubagentInputCallItemResource;

  /// Builds the `wait_for_subagents_call` contract.
  factory AgentSessionTurnItem.waitForSubagentsCall({
    required String id,
    required List<String> recipientAgentIds,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWaitForSubagentsCallItemResource;

  /// Builds the `web_search_call` contract.
  factory AgentSessionTurnItem.webSearchCall({
    required AgentSessionWebSearchActionResource? action,
    required String id,
    required AgentSessionOutputItemStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchCallItemResource;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionTurnItem extends AgentSessionTurnItem {
  const UnknownAgentSessionTurnItem._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionTurnItem.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionTurnItem.type',
    );
    if (const [
      'agent_message',
      'close_subagent_call',
      'command_execution',
      'computer_use_approval_request',
      'computer_use_approval_request_result',
      'computer_use_call',
      'create_subagent_call',
      'function_call',
      'function_call_output',
      'interrupt_subagent_call',
      'mcp_call',
      'message',
      'reasoning',
      'resume_subagent_call',
      'send_subagent_input_call',
      'wait_for_subagents_call',
      'web_search_call',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionTurnItem: expected a future discriminator',
      );
    }
    return UnknownAgentSessionTurnItem._(
      snapshotAgentJson(json, 'UnknownAgentSessionTurnItem'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionTurnItem copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionTurnItem.fromJson(rawJson ?? this.rawJson);
}

/// Fields to update on an existing session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class UpdateAgentSessionRequest extends AgentJsonModel {
  /// Creates a validated [UpdateAgentSessionRequest].
  UpdateAgentSessionRequest({
    this.agent,
    Map<String, String>? metadata,
    bool clearMetadata = false,
    AgentSessionSpendControlConfig? spendControl,
    bool clearSpendControl = false,
  }) : clearMetadata = clearMetadata,
       metadata = ownAgentValue<Map<String, String>>(
         clearMetadata ? null : metadata,
         Map<String, String>.unmodifiable,
       ),
       clearSpendControl = clearSpendControl,
       spendControl = clearSpendControl ? null : spendControl {
    validate();
  }

  /// Model settings for subsequent turns. Omitted fields stay unchanged.
  final AgentSessionAgentUpdate? agent;

  /// Replaces all metadata. Omit to leave unchanged, or pass null or {} to clear it. Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters.
  final Map<String, String>? metadata;

  /// Sends `metadata: null`, rather than omitting it.
  final bool clearMetadata;

  /// Omit to retain the limit; null or a null limit removes it without resetting spend.
  final AgentSessionSpendControlConfig? spendControl;

  /// Sends `spend_control: null`, rather than omitting it.
  final bool clearSpendControl;

  /// Parses [UpdateAgentSessionRequest] with contextual, payload-free errors.
  factory UpdateAgentSessionRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'agent',
      'metadata',
      'spend_control',
    ], 'UpdateAgentSessionRequest');
    return UpdateAgentSessionRequest(
      agent: optionalAgentValue(
        json,
        'agent',
        'UpdateAgentSessionRequest.agent',
        (value, context) => AgentSessionAgentUpdate.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      ),
      metadata: optionalAgentValue(
        json,
        'metadata',
        'UpdateAgentSessionRequest.metadata',
        requireAgentStringMap,
        nullable: true,
      ),
      clearMetadata: json.containsKey('metadata') && json['metadata'] == null,
      spendControl: optionalAgentValue(
        json,
        'spend_control',
        'UpdateAgentSessionRequest.spendControl',
        (value, context) => AgentSessionSpendControlConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearSpendControl:
          json.containsKey('spend_control') && json['spend_control'] == null,
    );
  }
  @override
  void validate() {
    if (agent != null) {
      agent!.validate();
    }
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'UpdateAgentSessionRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'UpdateAgentSessionRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'UpdateAgentSessionRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
    if (spendControl != null) {
      spendControl!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (agent != null) 'agent': agent!.toJson(),
    if (clearMetadata) 'metadata': null else 'metadata': ?metadata,
    if (clearSpendControl)
      'spend_control': null
    else if (spendControl != null)
      'spend_control': spendControl!.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  UpdateAgentSessionRequest copyWith({
    Object? agent = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    bool? clearMetadata,
    Object? spendControl = unsetCopyWithValue,
    bool? clearSpendControl,
  }) => UpdateAgentSessionRequest(
    agent: copyAgentValue<AgentSessionAgentUpdate>(
      agent,
      this.agent,
      'UpdateAgentSessionRequest.agent',
    ),
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'UpdateAgentSessionRequest.metadata',
    ),
    clearMetadata:
        clearMetadata ??
        (identical(metadata, unsetCopyWithValue)
            ? this.clearMetadata
            : metadata == null),
    spendControl: copyAgentValue<AgentSessionSpendControlConfig>(
      spendControl,
      this.spendControl,
      'UpdateAgentSessionRequest.spendControl',
    ),
    clearSpendControl:
        clearSpendControl ??
        (identical(spendControl, unsetCopyWithValue)
            ? this.clearSpendControl
            : spendControl == null),
  );
}

/// Model settings that can change after session creation.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionAgentUpdate extends AgentJsonModel {
  /// Creates a validated [AgentSessionAgentUpdate].
  AgentSessionAgentUpdate({
    this.model,
    this.reasoning,
    AgentServiceTierParam? serviceTier,
    bool clearServiceTier = false,
  }) : clearServiceTier = clearServiceTier,
       serviceTier = clearServiceTier ? null : serviceTier {
    validate();
  }

  /// The model for subsequent turns. Omit to keep the current model.
  final String? model;

  /// Reasoning settings to update. Omit to keep the current effort.
  final AgentSessionReasoningUpdate? reasoning;

  /// Omit to keep the current tier. Null resets it to auto.
  final AgentServiceTierParam? serviceTier;

  /// Sends `service_tier: null`, rather than omitting it.
  final bool clearServiceTier;

  /// Parses [AgentSessionAgentUpdate] with contextual, payload-free errors.
  factory AgentSessionAgentUpdate.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'model',
      'reasoning',
      'service_tier',
    ], 'AgentSessionAgentUpdate');
    return AgentSessionAgentUpdate(
      model: optionalAgentValue(
        json,
        'model',
        'AgentSessionAgentUpdate.model',
        requireAgentString,
        nullable: false,
      ),
      reasoning: optionalAgentValue(
        json,
        'reasoning',
        'AgentSessionAgentUpdate.reasoning',
        (value, context) => AgentSessionReasoningUpdate.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      ),
      serviceTier: optionalAgentValue(
        json,
        'service_tier',
        'AgentSessionAgentUpdate.serviceTier',
        (value, context) => AgentServiceTierParam.fromJson(value),
        nullable: true,
      ),
      clearServiceTier:
          json.containsKey('service_tier') && json['service_tier'] == null,
    );
  }
  @override
  void validate() {
    if (model != null) {
      validateAgentLength(
        model!,
        'AgentSessionAgentUpdate.model',
        min: 0,
        max: 1048576,
      );
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
      ], 'AgentSessionAgentUpdate.serviceTier');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'model': ?model,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (clearServiceTier)
      'service_tier': null
    else if (serviceTier != null)
      'service_tier': serviceTier!.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionAgentUpdate copyWith({
    Object? model = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    bool? clearServiceTier,
  }) => AgentSessionAgentUpdate(
    model: copyAgentValue<String>(
      model,
      this.model,
      'AgentSessionAgentUpdate.model',
    ),
    reasoning: copyAgentValue<AgentSessionReasoningUpdate>(
      reasoning,
      this.reasoning,
      'AgentSessionAgentUpdate.reasoning',
    ),
    serviceTier: copyAgentValue<AgentServiceTierParam>(
      serviceTier,
      this.serviceTier,
      'AgentSessionAgentUpdate.serviceTier',
    ),
    clearServiceTier:
        clearServiceTier ??
        (identical(serviceTier, unsetCopyWithValue)
            ? this.clearServiceTier
            : serviceTier == null),
  );
}

/// Reasoning effort for subsequent turns. The reasoning summary stays unchanged.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionReasoningUpdate extends AgentJsonModel {
  /// Creates a validated [AgentSessionReasoningUpdate].
  AgentSessionReasoningUpdate({
    AgentReasoningEffortParam? effort,
    bool clearEffort = false,
  }) : clearEffort = clearEffort,
       effort = clearEffort ? null : effort {
    validate();
  }

  /// Omit to keep the current effort. Null selects the model's default effort.
  final AgentReasoningEffortParam? effort;

  /// Sends `effort: null`, rather than omitting it.
  final bool clearEffort;

  /// Parses [AgentSessionReasoningUpdate] with contextual, payload-free errors.
  factory AgentSessionReasoningUpdate.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'effort',
    ], 'AgentSessionReasoningUpdate');
    return AgentSessionReasoningUpdate(
      effort: optionalAgentValue(
        json,
        'effort',
        'AgentSessionReasoningUpdate.effort',
        (value, context) => AgentReasoningEffortParam.fromJson(value),
        nullable: true,
      ),
      clearEffort: json.containsKey('effort') && json['effort'] == null,
    );
  }
  @override
  void validate() {
    if (effort != null) {
      validateAgentEnum(effort!.value, [
        'none',
        'minimal',
        'low',
        'medium',
        'high',
        'xhigh',
        'max',
      ], 'AgentSessionReasoningUpdate.effort');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearEffort)
      'effort': null
    else if (effort != null)
      'effort': effort!.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionReasoningUpdate copyWith({
    Object? effort = unsetCopyWithValue,
    bool? clearEffort,
  }) => AgentSessionReasoningUpdate(
    effort: copyAgentValue<AgentReasoningEffortParam>(
      effort,
      this.effort,
      'AgentSessionReasoningUpdate.effort',
    ),
    clearEffort:
        clearEffort ??
        (identical(effort, unsetCopyWithValue)
            ? this.clearEffort
            : effort == null),
  );
}
