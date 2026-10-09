part of 'agent_session_models.dart';

/// A plaintext or encrypted content part exchanged between agents.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionContent extends AgentJsonModel {
  const AgentSessionContent();

  /// Parses a known contract or detached future received value.
  factory AgentSessionContent.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionContent.type',
    )) {
      'encrypted_content' => AgentSessionEncryptedContentResource.fromJson(
        json,
      ),
      'output_text' => AgentSessionOutputTextResource.fromJson(json),
      _ => UnknownAgentSessionContent.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `encrypted_content` contract.
  factory AgentSessionContent.encryptedContent({
    required String encryptedContent,
    Map<String, dynamic> rawJson,
  }) = AgentSessionEncryptedContentResource;

  /// Builds the `output_text` contract.
  factory AgentSessionContent.outputText({
    required String text,
    Map<String, dynamic> rawJson,
  }) = AgentSessionOutputTextResource;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionContent extends AgentSessionContent {
  const UnknownAgentSessionContent._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionContent.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionContent.type',
    );
    if (const ['encrypted_content', 'output_text'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionContent: expected a future discriminator',
      );
    }
    return UnknownAgentSessionContent._(
      snapshotAgentJson(json, 'UnknownAgentSessionContent'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionContent copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionContent.fromJson(rawJson ?? this.rawJson);
}

/// A message exchanged between agent threads.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionAgentMessageItemResource extends AgentSessionTurnItem {
  /// Creates a validated [AgentSessionAgentMessageItemResource].
  AgentSessionAgentMessageItemResource({
    required List<AgentSessionContent> content,
    required this.id,
    required this.recipientAgentId,
    required this.senderAgentId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       rawJson = agentExtras(rawJson, const [
         'content',
         'id',
         'recipient_agent_id',
         'sender_agent_id',
         'turn_id',
         'type',
       ], 'AgentSessionAgentMessageItemResource') {
    validate();
  }

  /// The content exchanged between the agents.
  final List<AgentSessionContent> content;

  /// The ID of the message.
  final String id;

  /// The ID or name of the receiving agent.
  final String recipientAgentId;

  /// The ID or name of the sending agent.
  final String senderAgentId;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `agent_message`.
  @override
  String get type => 'agent_message';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionAgentMessageItemResource] with contextual, payload-free errors.
  factory AgentSessionAgentMessageItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'agent_message',
      'AgentSessionAgentMessageItemResource',
    );
    return AgentSessionAgentMessageItemResource(
      content: requiredAgentValue(
        json,
        'content',
        'AgentSessionAgentMessageItemResource.content',
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
        'AgentSessionAgentMessageItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      recipientAgentId: requiredAgentValue(
        json,
        'recipient_agent_id',
        'AgentSessionAgentMessageItemResource.recipientAgentId',
        requireAgentString,
        nullable: false,
      )!,
      senderAgentId: requiredAgentValue(
        json,
        'sender_agent_id',
        'AgentSessionAgentMessageItemResource.senderAgentId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionAgentMessageItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content',
            'id',
            'recipient_agent_id',
            'sender_agent_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      content.length,
      'AgentSessionAgentMessageItemResource.content',
      min: 0,
      max: 2000,
    );
    for (final item in content) {
      item.validate();
    }
    validateAgentLength(id, 'AgentSessionAgentMessageItemResource.id', min: 0);
    validateAgentLength(
      recipientAgentId,
      'AgentSessionAgentMessageItemResource.recipientAgentId',
      min: 0,
    );
    validateAgentLength(
      senderAgentId,
      'AgentSessionAgentMessageItemResource.senderAgentId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionAgentMessageItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content': content.map((value) => value.toJson()).toList(),
    'id': id,
    'recipient_agent_id': recipientAgentId,
    'sender_agent_id': senderAgentId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionAgentMessageItemResource copyWith({
    List<AgentSessionContent>? content,
    String? id,
    String? recipientAgentId,
    String? senderAgentId,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionAgentMessageItemResource(
    content: content ?? this.content,
    id: id ?? this.id,
    recipientAgentId: recipientAgentId ?? this.recipientAgentId,
    senderAgentId: senderAgentId ?? this.senderAgentId,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An output item produced by an agent.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionOutputItem extends AgentJsonModel {
  const AgentSessionOutputItem();

  /// Parses a known contract or detached future received value.
  factory AgentSessionOutputItem.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionOutputItem.type',
    )) {
      'close_subagent_call' =>
        AgentSessionCloseSubagentCallItemResource.fromJson(json),
      'command_execution' => AgentSessionCommandExecutionItemResource.fromJson(
        json,
      ),
      'computer_use_approval_request' =>
        AgentSessionBrowserAuthenticationRequestItemResource.fromJson(json),
      'computer_use_call' => AgentSessionComputerUseCallItemResource.fromJson(
        json,
      ),
      'create_subagent_call' =>
        AgentSessionCreateSubagentCallItemResource.fromJson(json),
      'function_call' => AgentSessionFunctionCallItemResource.fromJson(json),
      'interrupt_subagent_call' =>
        AgentSessionInterruptSubagentCallItemResource.fromJson(json),
      'mcp_call' => AgentSessionMcpCallItemResource.fromJson(json),
      'message' => AgentSessionAssistantMessageItemResource.fromJson(json),
      'reasoning' => AgentSessionReasoningItemResource.fromJson(json),
      'resume_subagent_call' =>
        AgentSessionResumeSubagentCallItemResource.fromJson(json),
      'send_subagent_input_call' =>
        AgentSessionSendSubagentInputCallItemResource.fromJson(json),
      'wait_for_subagents_call' =>
        AgentSessionWaitForSubagentsCallItemResource.fromJson(json),
      'web_search_call' => AgentSessionWebSearchCallItemResource.fromJson(json),
      _ => UnknownAgentSessionOutputItem.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `close_subagent_call` contract.
  factory AgentSessionOutputItem.closeSubagentCall({
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionCloseSubagentCallItemResource;

  /// Builds the `command_execution` contract.
  factory AgentSessionOutputItem.commandExecution({
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
  factory AgentSessionOutputItem.computerUseApprovalRequest({
    required String id,
    required AgentSessionBrowserAuthenticationHistoryRequestKindResource
    request,
    required String requestId,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionBrowserAuthenticationRequestItemResource;

  /// Builds the `computer_use_call` contract.
  factory AgentSessionOutputItem.computerUseCall({
    required String id,
    required AgentSessionComputerScreenshotResource? output,
    required AgentSessionFunctionCallStatusResource status,
    required String? title,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionComputerUseCallItemResource;

  /// Builds the `create_subagent_call` contract.
  factory AgentSessionOutputItem.createSubagentCall({
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
  factory AgentSessionOutputItem.functionCall({
    required Object? arguments,
    required String callId,
    required String id,
    required String name,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionFunctionCallItemResource;

  /// Builds the `interrupt_subagent_call` contract.
  factory AgentSessionOutputItem.interruptSubagentCall({
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionInterruptSubagentCallItemResource;

  /// Builds the `mcp_call` contract.
  factory AgentSessionOutputItem.mcpCall({
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
  factory AgentSessionOutputItem.message({
    required List<AgentSessionOutputTextResource> content,
    required String id,
    required AgentSessionMessagePhaseResource? phase,
    required AgentSessionOutputItemStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionAssistantMessageItemResource;

  /// Builds the `reasoning` contract.
  factory AgentSessionOutputItem.reasoning({
    required String id,
    required AgentSessionOutputItemStatusResource? status,
    required List<AgentSessionSummaryTextResource> summary,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionReasoningItemResource;

  /// Builds the `resume_subagent_call` contract.
  factory AgentSessionOutputItem.resumeSubagentCall({
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionResumeSubagentCallItemResource;

  /// Builds the `send_subagent_input_call` contract.
  factory AgentSessionOutputItem.sendSubagentInputCall({
    required List<AgentSessionContent> content,
    required String id,
    required String recipientAgentId,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionSendSubagentInputCallItemResource;

  /// Builds the `wait_for_subagents_call` contract.
  factory AgentSessionOutputItem.waitForSubagentsCall({
    required String id,
    required List<String> recipientAgentIds,
    required String senderAgentId,
    required AgentSessionFunctionCallStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWaitForSubagentsCallItemResource;

  /// Builds the `web_search_call` contract.
  factory AgentSessionOutputItem.webSearchCall({
    required AgentSessionWebSearchActionResource? action,
    required String id,
    required AgentSessionOutputItemStatusResource status,
    required String turnId,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchCallItemResource;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionOutputItem extends AgentSessionOutputItem {
  const UnknownAgentSessionOutputItem._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionOutputItem.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionOutputItem.type',
    );
    if (const [
      'close_subagent_call',
      'command_execution',
      'computer_use_approval_request',
      'computer_use_call',
      'create_subagent_call',
      'function_call',
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
        'UnknownAgentSessionOutputItem: expected a future discriminator',
      );
    }
    return UnknownAgentSessionOutputItem._(
      snapshotAgentJson(json, 'UnknownAgentSessionOutputItem'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionOutputItem copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionOutputItem.fromJson(rawJson ?? this.rawJson);
}

/// An assistant message produced by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionAssistantMessageItemResource
    extends AgentSessionOutputItem {
  /// Creates a validated [AgentSessionAssistantMessageItemResource].
  AgentSessionAssistantMessageItemResource({
    required List<AgentSessionOutputTextResource> content,
    required this.id,
    required this.phase,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       rawJson = agentExtras(rawJson, const [
         'content',
         'id',
         'phase',
         'role',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionAssistantMessageItemResource') {
    validate();
  }

  /// The content of the message.
  final List<AgentSessionOutputTextResource> content;

  /// The ID of the message.
  final String id;

  /// The phase of the assistant message.
  final AgentSessionMessagePhaseResource? phase;

  /// The role of the message author. Always `assistant`.
  String get role => 'assistant';

  /// The status of the message.
  final AgentSessionOutputItemStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `message`.
  @override
  String get type => 'message';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionAssistantMessageItemResource] with contextual, payload-free errors.
  factory AgentSessionAssistantMessageItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'role',
      'assistant',
      'AgentSessionAssistantMessageItemResource',
    );
    requireAgentTag(
      json,
      'type',
      'message',
      'AgentSessionAssistantMessageItemResource',
    );
    return AgentSessionAssistantMessageItemResource(
      content: requiredAgentValue(
        json,
        'content',
        'AgentSessionAssistantMessageItemResource.content',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionOutputTextResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionAssistantMessageItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      phase: requiredAgentValue(
        json,
        'phase',
        'AgentSessionAssistantMessageItemResource.phase',
        (value, context) => AgentSessionMessagePhaseResource.fromJson(value),
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionAssistantMessageItemResource.status',
        (value, context) =>
            AgentSessionOutputItemStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionAssistantMessageItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content',
            'id',
            'phase',
            'role',
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
    validateAgentCount(
      content.length,
      'AgentSessionAssistantMessageItemResource.content',
      min: 0,
      max: 2000,
    );
    for (final item in content) {
      item.validate();
    }
    validateAgentLength(
      id,
      'AgentSessionAssistantMessageItemResource.id',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionAssistantMessageItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content': content.map((value) => value.toJson()).toList(),
    'id': id,
    'phase': phase?.toJson(),
    'role': role,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionAssistantMessageItemResource copyWith({
    List<AgentSessionOutputTextResource>? content,
    String? id,
    Object? phase = unsetCopyWithValue,
    AgentSessionOutputItemStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionAssistantMessageItemResource(
    content: content ?? this.content,
    id: id ?? this.id,
    phase: copyAgentValue<AgentSessionMessagePhaseResource>(
      phase,
      this.phase,
      'AgentSessionAssistantMessageItemResource.phase',
    ),
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A request to close a subagent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionCloseSubagentCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionCloseSubagentCallItemResource].
  AgentSessionCloseSubagentCallItemResource({
    required this.id,
    required this.recipientAgentId,
    required this.senderAgentId,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'recipient_agent_id',
         'sender_agent_id',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionCloseSubagentCallItemResource') {
    validate();
  }

  /// The ID of the tool call item.
  final String id;

  /// The ID of the agent to close.
  final String recipientAgentId;

  /// The ID of the agent requesting the close.
  final String senderAgentId;

  /// The status of the tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `close_subagent_call`.
  @override
  String get type => 'close_subagent_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionCloseSubagentCallItemResource] with contextual, payload-free errors.
  factory AgentSessionCloseSubagentCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'close_subagent_call',
      'AgentSessionCloseSubagentCallItemResource',
    );
    return AgentSessionCloseSubagentCallItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionCloseSubagentCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      recipientAgentId: requiredAgentValue(
        json,
        'recipient_agent_id',
        'AgentSessionCloseSubagentCallItemResource.recipientAgentId',
        requireAgentString,
        nullable: false,
      )!,
      senderAgentId: requiredAgentValue(
        json,
        'sender_agent_id',
        'AgentSessionCloseSubagentCallItemResource.senderAgentId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionCloseSubagentCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionCloseSubagentCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'recipient_agent_id',
            'sender_agent_id',
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
      id,
      'AgentSessionCloseSubagentCallItemResource.id',
      min: 0,
    );
    validateAgentLength(
      recipientAgentId,
      'AgentSessionCloseSubagentCallItemResource.recipientAgentId',
      min: 0,
    );
    validateAgentLength(
      senderAgentId,
      'AgentSessionCloseSubagentCallItemResource.senderAgentId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionCloseSubagentCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'recipient_agent_id': recipientAgentId,
    'sender_agent_id': senderAgentId,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionCloseSubagentCallItemResource copyWith({
    String? id,
    String? recipientAgentId,
    String? senderAgentId,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionCloseSubagentCallItemResource(
    id: id ?? this.id,
    recipientAgentId: recipientAgentId ?? this.recipientAgentId,
    senderAgentId: senderAgentId ?? this.senderAgentId,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A command execution produced by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionCommandExecutionItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionCommandExecutionItemResource].
  AgentSessionCommandExecutionItemResource({
    required this.command,
    required this.cwd,
    required this.durationMs,
    required this.exitCode,
    required this.id,
    required this.output,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'command',
         'cwd',
         'duration_ms',
         'exit_code',
         'id',
         'output',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionCommandExecutionItemResource') {
    validate();
  }

  /// The command that was executed.
  final String command;

  /// The working directory used to execute the command.
  final String? cwd;

  /// The command duration in milliseconds.
  final int? durationMs;

  /// The process exit code, if the command completed.
  final int? exitCode;

  /// The ID of the command execution item.
  final String id;

  /// The command output, if available.
  final String? output;

  /// The status of the command execution.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `command_execution`.
  @override
  String get type => 'command_execution';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionCommandExecutionItemResource] with contextual, payload-free errors.
  factory AgentSessionCommandExecutionItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'command_execution',
      'AgentSessionCommandExecutionItemResource',
    );
    return AgentSessionCommandExecutionItemResource(
      command: requiredAgentValue(
        json,
        'command',
        'AgentSessionCommandExecutionItemResource.command',
        requireAgentString,
        nullable: false,
      )!,
      cwd: requiredAgentValue(
        json,
        'cwd',
        'AgentSessionCommandExecutionItemResource.cwd',
        requireAgentString,
        nullable: true,
      ),
      durationMs: requiredAgentValue(
        json,
        'duration_ms',
        'AgentSessionCommandExecutionItemResource.durationMs',
        requireAgentInt,
        nullable: true,
      ),
      exitCode: requiredAgentValue(
        json,
        'exit_code',
        'AgentSessionCommandExecutionItemResource.exitCode',
        requireAgentInt,
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionCommandExecutionItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      output: requiredAgentValue(
        json,
        'output',
        'AgentSessionCommandExecutionItemResource.output',
        requireAgentString,
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionCommandExecutionItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionCommandExecutionItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'command',
            'cwd',
            'duration_ms',
            'exit_code',
            'id',
            'output',
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
      command,
      'AgentSessionCommandExecutionItemResource.command',
      min: 0,
    );
    if (cwd != null) {
      validateAgentLength(
        cwd!,
        'AgentSessionCommandExecutionItemResource.cwd',
        min: 0,
      );
    }
    if (durationMs != null) {
      validateAgentInt(
        durationMs!,
        'AgentSessionCommandExecutionItemResource.durationMs',
      );
    }
    if (exitCode != null) {
      validateAgentInt(
        exitCode!,
        'AgentSessionCommandExecutionItemResource.exitCode',
      );
    }
    validateAgentLength(
      id,
      'AgentSessionCommandExecutionItemResource.id',
      min: 0,
    );
    if (output != null) {
      validateAgentLength(
        output!,
        'AgentSessionCommandExecutionItemResource.output',
        min: 0,
      );
    }
    validateAgentLength(
      turnId,
      'AgentSessionCommandExecutionItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'command': command,
    'cwd': cwd,
    'duration_ms': durationMs,
    'exit_code': exitCode,
    'id': id,
    'output': output,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionCommandExecutionItemResource copyWith({
    String? command,
    Object? cwd = unsetCopyWithValue,
    Object? durationMs = unsetCopyWithValue,
    Object? exitCode = unsetCopyWithValue,
    String? id,
    Object? output = unsetCopyWithValue,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionCommandExecutionItemResource(
    command: command ?? this.command,
    cwd: copyAgentValue<String>(
      cwd,
      this.cwd,
      'AgentSessionCommandExecutionItemResource.cwd',
    ),
    durationMs: copyAgentValue<int>(
      durationMs,
      this.durationMs,
      'AgentSessionCommandExecutionItemResource.durationMs',
    ),
    exitCode: copyAgentValue<int>(
      exitCode,
      this.exitCode,
      'AgentSessionCommandExecutionItemResource.exitCode',
    ),
    id: id ?? this.id,
    output: copyAgentValue<String>(
      output,
      this.output,
      'AgentSessionCommandExecutionItemResource.output',
    ),
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A browser screenshot emitted by the model during computer use.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionComputerScreenshotResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionComputerScreenshotResource].
  AgentSessionComputerScreenshotResource({
    required this.imageUrl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'image_url',
         'type',
       ], 'AgentSessionComputerScreenshotResource') {
    validate();
  }

  /// The complete JPEG image as a base64 data URL.
  final String imageUrl;

  /// The content type. Always `computer_screenshot`.
  String get type => 'computer_screenshot';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionComputerScreenshotResource] with contextual, payload-free errors.
  factory AgentSessionComputerScreenshotResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'computer_screenshot',
      'AgentSessionComputerScreenshotResource',
    );
    return AgentSessionComputerScreenshotResource(
      imageUrl: requiredAgentValue(
        json,
        'image_url',
        'AgentSessionComputerScreenshotResource.imageUrl',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['image_url', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      imageUrl,
      'AgentSessionComputerScreenshotResource.imageUrl',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'image_url': imageUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionComputerScreenshotResource copyWith({
    String? imageUrl,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionComputerScreenshotResource(
    imageUrl: imageUrl ?? this.imageUrl,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One execution of the platform-provided computer-use capability.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionComputerUseCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionComputerUseCallItemResource].
  AgentSessionComputerUseCallItemResource({
    required this.id,
    required this.output,
    required this.status,
    required this.title,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'output',
         'status',
         'title',
         'turn_id',
         'type',
       ], 'AgentSessionComputerUseCallItemResource') {
    validate();
  }

  /// The ID of the activity item.
  final String id;

  /// The last screenshot emitted by the model. Null when screenshot inclusion is disabled or the call emitted no screenshot.
  final AgentSessionComputerScreenshotResource? output;

  /// The execution status of the activity.
  final AgentSessionFunctionCallStatusResource status;

  /// A model-generated description of the activity, when available.
  final String? title;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `computer_use_call`.
  @override
  String get type => 'computer_use_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionComputerUseCallItemResource] with contextual, payload-free errors.
  factory AgentSessionComputerUseCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'computer_use_call',
      'AgentSessionComputerUseCallItemResource',
    );
    return AgentSessionComputerUseCallItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionComputerUseCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      output: requiredAgentValue(
        json,
        'output',
        'AgentSessionComputerUseCallItemResource.output',
        (value, context) => AgentSessionComputerScreenshotResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionComputerUseCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      title: requiredAgentValue(
        json,
        'title',
        'AgentSessionComputerUseCallItemResource.title',
        requireAgentString,
        nullable: true,
      ),
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionComputerUseCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'output',
            'status',
            'title',
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
      id,
      'AgentSessionComputerUseCallItemResource.id',
      min: 0,
    );
    if (output != null) {
      output!.validate();
    }
    if (title != null) {
      validateAgentLength(
        title!,
        'AgentSessionComputerUseCallItemResource.title',
        min: 0,
      );
    }
    validateAgentLength(
      turnId,
      'AgentSessionComputerUseCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'output': output?.toJson(),
    'status': status.toJson(),
    'title': title,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionComputerUseCallItemResource copyWith({
    String? id,
    Object? output = unsetCopyWithValue,
    AgentSessionFunctionCallStatusResource? status,
    Object? title = unsetCopyWithValue,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionComputerUseCallItemResource(
    id: id ?? this.id,
    output: copyAgentValue<AgentSessionComputerScreenshotResource>(
      output,
      this.output,
      'AgentSessionComputerUseCallItemResource.output',
    ),
    status: status ?? this.status,
    title: copyAgentValue<String>(
      title,
      this.title,
      'AgentSessionComputerUseCallItemResource.title',
    ),
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Encrypted content exchanged between agents.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEncryptedContentResource extends AgentSessionContent {
  /// Creates a validated [AgentSessionEncryptedContentResource].
  AgentSessionEncryptedContentResource({
    required this.encryptedContent,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'encrypted_content',
         'type',
       ], 'AgentSessionEncryptedContentResource') {
    validate();
  }

  /// The encrypted content payload.
  final String encryptedContent;

  /// The content type. Always `encrypted_content`.
  @override
  String get type => 'encrypted_content';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEncryptedContentResource] with contextual, payload-free errors.
  factory AgentSessionEncryptedContentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'encrypted_content',
      'AgentSessionEncryptedContentResource',
    );
    return AgentSessionEncryptedContentResource(
      encryptedContent: requiredAgentValue(
        json,
        'encrypted_content',
        'AgentSessionEncryptedContentResource.encryptedContent',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['encrypted_content', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      encryptedContent,
      'AgentSessionEncryptedContentResource.encryptedContent',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'encrypted_content': encryptedContent,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEncryptedContentResource copyWith({
    String? encryptedContent,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEncryptedContentResource(
    encryptedContent: encryptedContent ?? this.encryptedContent,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A function call produced by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionFunctionCallItemResource extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionFunctionCallItemResource].
  AgentSessionFunctionCallItemResource({
    required Object? arguments,
    required this.callId,
    required this.id,
    required this.name,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : arguments = snapshotAgentJson({
         'value': arguments,
       }, 'AgentSessionFunctionCallItemResource.arguments')['value'],
       rawJson = agentExtras(rawJson, const [
         'arguments',
         'call_id',
         'id',
         'name',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionFunctionCallItemResource') {
    validate();
  }

  /// The arguments to pass to the function.
  final Object? arguments;

  /// The ID used to submit the function result.
  final String callId;

  /// The ID of the function call item.
  final String id;

  /// The name of the function to call.
  final String name;

  /// The status of the function call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `function_call`.
  @override
  String get type => 'function_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionFunctionCallItemResource] with contextual, payload-free errors.
  factory AgentSessionFunctionCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'function_call',
      'AgentSessionFunctionCallItemResource',
    );
    return AgentSessionFunctionCallItemResource(
      arguments: requiredAgentValue(
        json,
        'arguments',
        'AgentSessionFunctionCallItemResource.arguments',
        (value, context) =>
            snapshotAgentJson({'value': value}, context)['value'],
        nullable: true,
      ),
      callId: requiredAgentValue(
        json,
        'call_id',
        'AgentSessionFunctionCallItemResource.callId',
        requireAgentString,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionFunctionCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionFunctionCallItemResource.name',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionFunctionCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionFunctionCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'arguments',
            'call_id',
            'id',
            'name',
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
      callId,
      'AgentSessionFunctionCallItemResource.callId',
      min: 0,
    );
    validateAgentLength(id, 'AgentSessionFunctionCallItemResource.id', min: 0);
    validateAgentLength(
      name,
      'AgentSessionFunctionCallItemResource.name',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionFunctionCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'arguments': arguments,
    'call_id': callId,
    'id': id,
    'name': name,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionFunctionCallItemResource copyWith({
    Object? arguments = unsetCopyWithValue,
    String? callId,
    String? id,
    String? name,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionFunctionCallItemResource(
    arguments: copyAgentValue<Object>(
      arguments,
      this.arguments,
      'AgentSessionFunctionCallItemResource.arguments',
    ),
    callId: callId ?? this.callId,
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The result supplied for a function call.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionFunctionCallOutputItemResource
    extends AgentSessionTurnItem {
  /// Creates a validated [AgentSessionFunctionCallOutputItemResource].
  AgentSessionFunctionCallOutputItemResource({
    required this.callId,
    required this.error,
    required this.id,
    required this.output,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'call_id',
         'error',
         'id',
         'output',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionFunctionCallOutputItemResource') {
    validate();
  }

  /// The ID of the function call that produced this output.
  final String callId;

  /// The error message, if the call failed.
  final String? error;

  /// The ID of the function call output item.
  final String id;

  /// The function result, if the call succeeded.
  final AgentSessionFunctionOutputResource? output;

  /// The status of the function call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `function_call_output`.
  @override
  String get type => 'function_call_output';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionFunctionCallOutputItemResource] with contextual, payload-free errors.
  factory AgentSessionFunctionCallOutputItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'function_call_output',
      'AgentSessionFunctionCallOutputItemResource',
    );
    return AgentSessionFunctionCallOutputItemResource(
      callId: requiredAgentValue(
        json,
        'call_id',
        'AgentSessionFunctionCallOutputItemResource.callId',
        requireAgentString,
        nullable: false,
      )!,
      error: requiredAgentValue(
        json,
        'error',
        'AgentSessionFunctionCallOutputItemResource.error',
        requireAgentString,
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionFunctionCallOutputItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      output: requiredAgentValue(
        json,
        'output',
        'AgentSessionFunctionCallOutputItemResource.output',
        (value, context) => AgentSessionFunctionOutputResource.fromJson(value),
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionFunctionCallOutputItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionFunctionCallOutputItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'call_id',
            'error',
            'id',
            'output',
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
      callId,
      'AgentSessionFunctionCallOutputItemResource.callId',
      min: 0,
    );
    if (error != null) {
      validateAgentLength(
        error!,
        'AgentSessionFunctionCallOutputItemResource.error',
        min: 0,
      );
    }
    validateAgentLength(
      id,
      'AgentSessionFunctionCallOutputItemResource.id',
      min: 0,
    );
    if (output != null) {
      output!.validate();
    }
    validateAgentLength(
      turnId,
      'AgentSessionFunctionCallOutputItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'call_id': callId,
    'error': error,
    'id': id,
    'output': output?.toJson(),
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionFunctionCallOutputItemResource copyWith({
    String? callId,
    Object? error = unsetCopyWithValue,
    String? id,
    Object? output = unsetCopyWithValue,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionFunctionCallOutputItemResource(
    callId: callId ?? this.callId,
    error: copyAgentValue<String>(
      error,
      this.error,
      'AgentSessionFunctionCallOutputItemResource.error',
    ),
    id: id ?? this.id,
    output: copyAgentValue<AgentSessionFunctionOutputResource>(
      output,
      this.output,
      'AgentSessionFunctionCallOutputItemResource.output',
    ),
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A breakdown of input token usage for a session or turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionInputTokensDetailsResourceDetails
    extends AgentJsonModel {
  /// Creates a validated [AgentSessionInputTokensDetailsResourceDetails].
  AgentSessionInputTokensDetailsResourceDetails({
    required this.cachedTokens,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'cached_tokens',
       ], 'AgentSessionInputTokensDetailsResourceDetails') {
    validate();
  }

  /// The number of input tokens retrieved from the prompt cache.
  final int cachedTokens;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionInputTokensDetailsResourceDetails] with contextual, payload-free errors.
  factory AgentSessionInputTokensDetailsResourceDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionInputTokensDetailsResourceDetails(
      cachedTokens: requiredAgentValue(
        json,
        'cached_tokens',
        'AgentSessionInputTokensDetailsResourceDetails.cachedTokens',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['cached_tokens'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(
      cachedTokens,
      'AgentSessionInputTokensDetailsResourceDetails.cachedTokens',
    );
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'cached_tokens': cachedTokens};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInputTokensDetailsResourceDetails copyWith({
    int? cachedTokens,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionInputTokensDetailsResourceDetails(
    cachedTokens: cachedTokens ?? this.cachedTokens,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A request to interrupt a subagent's current turn. The subagent remains available.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionInterruptSubagentCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionInterruptSubagentCallItemResource].
  AgentSessionInterruptSubagentCallItemResource({
    required this.id,
    required this.recipientAgentId,
    required this.senderAgentId,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'recipient_agent_id',
         'sender_agent_id',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionInterruptSubagentCallItemResource') {
    validate();
  }

  /// The ID of the tool call item.
  final String id;

  /// The ID of the agent to interrupt.
  final String recipientAgentId;

  /// The ID of the agent requesting the interrupt.
  final String senderAgentId;

  /// The status of the tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `interrupt_subagent_call`.
  @override
  String get type => 'interrupt_subagent_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionInterruptSubagentCallItemResource] with contextual, payload-free errors.
  factory AgentSessionInterruptSubagentCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'interrupt_subagent_call',
      'AgentSessionInterruptSubagentCallItemResource',
    );
    return AgentSessionInterruptSubagentCallItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionInterruptSubagentCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      recipientAgentId: requiredAgentValue(
        json,
        'recipient_agent_id',
        'AgentSessionInterruptSubagentCallItemResource.recipientAgentId',
        requireAgentString,
        nullable: false,
      )!,
      senderAgentId: requiredAgentValue(
        json,
        'sender_agent_id',
        'AgentSessionInterruptSubagentCallItemResource.senderAgentId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionInterruptSubagentCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionInterruptSubagentCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'recipient_agent_id',
            'sender_agent_id',
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
      id,
      'AgentSessionInterruptSubagentCallItemResource.id',
      min: 0,
    );
    validateAgentLength(
      recipientAgentId,
      'AgentSessionInterruptSubagentCallItemResource.recipientAgentId',
      min: 0,
    );
    validateAgentLength(
      senderAgentId,
      'AgentSessionInterruptSubagentCallItemResource.senderAgentId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionInterruptSubagentCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'recipient_agent_id': recipientAgentId,
    'sender_agent_id': senderAgentId,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInterruptSubagentCallItemResource copyWith({
    String? id,
    String? recipientAgentId,
    String? senderAgentId,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionInterruptSubagentCallItemResource(
    id: id ?? this.id,
    recipientAgentId: recipientAgentId ?? this.recipientAgentId,
    senderAgentId: senderAgentId ?? this.senderAgentId,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A call to a tool on an MCP server.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMcpCallItemResource extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionMcpCallItemResource].
  AgentSessionMcpCallItemResource({
    required Object? arguments,
    required Object? error,
    required this.id,
    required this.name,
    required Object? output,
    required this.serverLabel,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : arguments = snapshotAgentJson({
         'value': arguments,
       }, 'AgentSessionMcpCallItemResource.arguments')['value'],
       error = snapshotAgentJson({
         'value': error,
       }, 'AgentSessionMcpCallItemResource.error')['value'],
       output = snapshotAgentJson({
         'value': output,
       }, 'AgentSessionMcpCallItemResource.output')['value'],
       rawJson = agentExtras(rawJson, const [
         'arguments',
         'error',
         'id',
         'name',
         'output',
         'server_label',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionMcpCallItemResource') {
    validate();
  }

  /// The arguments passed to the MCP tool.
  final Object? arguments;

  /// The error returned by the MCP tool, if any.
  final Object? error;

  /// The ID of the MCP call item.
  final String id;

  /// The name of the MCP tool.
  final String name;

  /// The output returned by the MCP tool, if any.
  final Object? output;

  /// The label of the MCP server.
  final String serverLabel;

  /// The status of the MCP tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `mcp_call`.
  @override
  String get type => 'mcp_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMcpCallItemResource] with contextual, payload-free errors.
  factory AgentSessionMcpCallItemResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'mcp_call',
      'AgentSessionMcpCallItemResource',
    );
    return AgentSessionMcpCallItemResource(
      arguments: requiredAgentValue(
        json,
        'arguments',
        'AgentSessionMcpCallItemResource.arguments',
        (value, context) =>
            snapshotAgentJson({'value': value}, context)['value'],
        nullable: true,
      ),
      error: requiredAgentValue(
        json,
        'error',
        'AgentSessionMcpCallItemResource.error',
        (value, context) =>
            snapshotAgentJson({'value': value}, context)['value'],
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionMcpCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionMcpCallItemResource.name',
        requireAgentString,
        nullable: false,
      )!,
      output: requiredAgentValue(
        json,
        'output',
        'AgentSessionMcpCallItemResource.output',
        (value, context) =>
            snapshotAgentJson({'value': value}, context)['value'],
        nullable: true,
      ),
      serverLabel: requiredAgentValue(
        json,
        'server_label',
        'AgentSessionMcpCallItemResource.serverLabel',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionMcpCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionMcpCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'arguments',
            'error',
            'id',
            'name',
            'output',
            'server_label',
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
    validateAgentLength(id, 'AgentSessionMcpCallItemResource.id', min: 0);
    validateAgentLength(name, 'AgentSessionMcpCallItemResource.name', min: 0);
    validateAgentLength(
      serverLabel,
      'AgentSessionMcpCallItemResource.serverLabel',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionMcpCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'arguments': arguments,
    'error': error,
    'id': id,
    'name': name,
    'output': output,
    'server_label': serverLabel,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpCallItemResource copyWith({
    Object? arguments = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    String? id,
    String? name,
    Object? output = unsetCopyWithValue,
    String? serverLabel,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMcpCallItemResource(
    arguments: copyAgentValue<Object>(
      arguments,
      this.arguments,
      'AgentSessionMcpCallItemResource.arguments',
    ),
    error: copyAgentValue<Object>(
      error,
      this.error,
      'AgentSessionMcpCallItemResource.error',
    ),
    id: id ?? this.id,
    name: name ?? this.name,
    output: copyAgentValue<Object>(
      output,
      this.output,
      'AgentSessionMcpCallItemResource.output',
    ),
    serverLabel: serverLabel ?? this.serverLabel,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A content part in a session message.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionMessageContent extends AgentJsonModel {
  const AgentSessionMessageContent();

  /// Parses a known contract or detached future received value.
  factory AgentSessionMessageContent.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionMessageContent.type',
    )) {
      'input_image' => AgentSessionMessageContentResourceInputImage.fromJson(
        json,
      ),
      'input_text' => AgentSessionMessageContentResourceInputText.fromJson(
        json,
      ),
      'output_text' => AgentSessionMessageContentResourceOutputText.fromJson(
        json,
      ),
      _ => UnknownAgentSessionMessageContent.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `input_image` contract.
  factory AgentSessionMessageContent.inputImage({
    required String imageUrl,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMessageContentResourceInputImage;

  /// Builds the `input_text` contract.
  factory AgentSessionMessageContent.inputText({
    required String text,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMessageContentResourceInputText;

  /// Builds the `output_text` contract.
  factory AgentSessionMessageContent.outputText({
    required String text,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMessageContentResourceOutputText;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionMessageContent
    extends AgentSessionMessageContent {
  const UnknownAgentSessionMessageContent._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionMessageContent.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionMessageContent.type',
    );
    if (const ['input_image', 'input_text', 'output_text'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionMessageContent: expected a future discriminator',
      );
    }
    return UnknownAgentSessionMessageContent._(
      snapshotAgentJson(json, 'UnknownAgentSessionMessageContent'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionMessageContent copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionMessageContent.fromJson(rawJson ?? this.rawJson);
}

/// An image supplied by the user.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMessageContentResourceInputImage
    extends AgentSessionMessageContent {
  /// Creates a validated [AgentSessionMessageContentResourceInputImage].
  AgentSessionMessageContentResourceInputImage({
    required this.imageUrl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'image_url',
         'type',
       ], 'AgentSessionMessageContentResourceInputImage') {
    validate();
  }

  /// The URL of the image supplied by the user, which may be a base64-encoded data URL.
  final String imageUrl;

  /// The type of the object. Always `input_image`.
  @override
  String get type => 'input_image';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMessageContentResourceInputImage] with contextual, payload-free errors.
  factory AgentSessionMessageContentResourceInputImage.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'input_image',
      'AgentSessionMessageContentResourceInputImage',
    );
    return AgentSessionMessageContentResourceInputImage(
      imageUrl: requiredAgentValue(
        json,
        'image_url',
        'AgentSessionMessageContentResourceInputImage.imageUrl',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['image_url', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      imageUrl,
      'AgentSessionMessageContentResourceInputImage.imageUrl',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'image_url': imageUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMessageContentResourceInputImage copyWith({
    String? imageUrl,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMessageContentResourceInputImage(
    imageUrl: imageUrl ?? this.imageUrl,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Text supplied by the user.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMessageContentResourceInputText
    extends AgentSessionMessageContent {
  /// Creates a validated [AgentSessionMessageContentResourceInputText].
  AgentSessionMessageContentResourceInputText({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'text',
         'type',
       ], 'AgentSessionMessageContentResourceInputText') {
    validate();
  }

  /// The text supplied by the user.
  final String text;

  /// The type of the object. Always `input_text`.
  @override
  String get type => 'input_text';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMessageContentResourceInputText] with contextual, payload-free errors.
  factory AgentSessionMessageContentResourceInputText.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'input_text',
      'AgentSessionMessageContentResourceInputText',
    );
    return AgentSessionMessageContentResourceInputText(
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionMessageContentResourceInputText.text',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['text', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionMessageContentResourceInputText.text',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'text': text, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMessageContentResourceInputText copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMessageContentResourceInputText(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Text produced by the assistant.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMessageContentResourceOutputText
    extends AgentSessionMessageContent {
  /// Creates a validated [AgentSessionMessageContentResourceOutputText].
  AgentSessionMessageContentResourceOutputText({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'text',
         'type',
       ], 'AgentSessionMessageContentResourceOutputText') {
    validate();
  }

  /// The text produced by the assistant.
  final String text;

  /// The type of the object. Always `output_text`.
  @override
  String get type => 'output_text';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMessageContentResourceOutputText] with contextual, payload-free errors.
  factory AgentSessionMessageContentResourceOutputText.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'output_text',
      'AgentSessionMessageContentResourceOutputText',
    );
    return AgentSessionMessageContentResourceOutputText(
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionMessageContentResourceOutputText.text',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['text', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      text,
      'AgentSessionMessageContentResourceOutputText.text',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'text': text, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMessageContentResourceOutputText copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMessageContentResourceOutputText(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A user or assistant message recorded in a session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMessageItemResource extends AgentSessionTurnItem {
  /// Creates a validated [AgentSessionMessageItemResource].
  AgentSessionMessageItemResource({
    required List<AgentSessionMessageContent> content,
    required this.id,
    required this.phase,
    required this.role,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       rawJson = agentExtras(rawJson, const [
         'content',
         'id',
         'phase',
         'role',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionMessageItemResource') {
    validate();
  }

  /// The content of the message. User messages contain input text or images; assistant messages contain output text.
  final List<AgentSessionMessageContent> content;

  /// The ID of this item, or null for legacy user messages whose ID was not recorded.
  final String? id;

  /// The phase of an assistant message. Null for user messages.
  final AgentSessionMessagePhaseResource? phase;

  /// The role of the message author.
  final AgentSessionMessageRoleResource role;

  /// The status of the message. User messages are always `completed`.
  final AgentSessionOutputItemStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `message`.
  @override
  String get type => 'message';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMessageItemResource] with contextual, payload-free errors.
  factory AgentSessionMessageItemResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'message', 'AgentSessionMessageItemResource');
    return AgentSessionMessageItemResource(
      content: requiredAgentValue(
        json,
        'content',
        'AgentSessionMessageItemResource.content',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionMessageContent.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionMessageItemResource.id',
        requireAgentString,
        nullable: true,
      ),
      phase: requiredAgentValue(
        json,
        'phase',
        'AgentSessionMessageItemResource.phase',
        (value, context) => AgentSessionMessagePhaseResource.fromJson(value),
        nullable: true,
      ),
      role: requiredAgentValue(
        json,
        'role',
        'AgentSessionMessageItemResource.role',
        (value, context) => AgentSessionMessageRoleResource.fromJson(value),
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionMessageItemResource.status',
        (value, context) =>
            AgentSessionOutputItemStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionMessageItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content',
            'id',
            'phase',
            'role',
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
    validateAgentCount(
      content.length,
      'AgentSessionMessageItemResource.content',
      min: 0,
      max: 2000,
    );
    for (final item in content) {
      item.validate();
    }
    if (id != null) {
      validateAgentLength(id!, 'AgentSessionMessageItemResource.id', min: 0);
    }
    validateAgentLength(
      turnId,
      'AgentSessionMessageItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content': content.map((value) => value.toJson()).toList(),
    'id': id,
    'phase': phase?.toJson(),
    'role': role.toJson(),
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMessageItemResource copyWith({
    List<AgentSessionMessageContent>? content,
    Object? id = unsetCopyWithValue,
    Object? phase = unsetCopyWithValue,
    AgentSessionMessageRoleResource? role,
    AgentSessionOutputItemStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMessageItemResource(
    content: content ?? this.content,
    id: copyAgentValue<String>(
      id,
      this.id,
      'AgentSessionMessageItemResource.id',
    ),
    phase: copyAgentValue<AgentSessionMessagePhaseResource>(
      phase,
      this.phase,
      'AgentSessionMessageItemResource.phase',
    ),
    role: role ?? this.role,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A text content part produced by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionOutputTextResource extends AgentSessionContent {
  /// Creates a validated [AgentSessionOutputTextResource].
  AgentSessionOutputTextResource({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'text',
         'type',
       ], 'AgentSessionOutputTextResource') {
    validate();
  }

  /// The text produced by the agent.
  final String text;

  /// The content type. Always `output_text`.
  @override
  String get type => 'output_text';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionOutputTextResource] with contextual, payload-free errors.
  factory AgentSessionOutputTextResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'output_text',
      'AgentSessionOutputTextResource',
    );
    return AgentSessionOutputTextResource(
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionOutputTextResource.text',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['text', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(text, 'AgentSessionOutputTextResource.text', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'text': text, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionOutputTextResource copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionOutputTextResource(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A breakdown of output token usage for a session or turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionOutputTokensDetailsResourceDetails
    extends AgentJsonModel {
  /// Creates a validated [AgentSessionOutputTokensDetailsResourceDetails].
  AgentSessionOutputTokensDetailsResourceDetails({
    required this.reasoningTokens,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'reasoning_tokens',
       ], 'AgentSessionOutputTokensDetailsResourceDetails') {
    validate();
  }

  /// The number of output tokens used for reasoning.
  final int reasoningTokens;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionOutputTokensDetailsResourceDetails] with contextual, payload-free errors.
  factory AgentSessionOutputTokensDetailsResourceDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionOutputTokensDetailsResourceDetails(
      reasoningTokens: requiredAgentValue(
        json,
        'reasoning_tokens',
        'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['reasoning_tokens'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(
      reasoningTokens,
      'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'reasoning_tokens': reasoningTokens,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionOutputTokensDetailsResourceDetails copyWith({
    int? reasoningTokens,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionOutputTokensDetailsResourceDetails(
    reasoningTokens: reasoningTokens ?? this.reasoningTokens,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A reasoning item produced by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionReasoningItemResource extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionReasoningItemResource].
  AgentSessionReasoningItemResource({
    required this.id,
    required this.status,
    required List<AgentSessionSummaryTextResource> summary,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : summary = List.unmodifiable(summary),
       rawJson = agentExtras(rawJson, const [
         'id',
         'status',
         'summary',
         'turn_id',
         'type',
       ], 'AgentSessionReasoningItemResource') {
    validate();
  }

  /// The ID of the reasoning item.
  final String id;

  /// The status of the reasoning item.
  final AgentSessionOutputItemStatusResource? status;

  /// The reasoning summaries produced by the agent.
  final List<AgentSessionSummaryTextResource> summary;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `reasoning`.
  @override
  String get type => 'reasoning';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionReasoningItemResource] with contextual, payload-free errors.
  factory AgentSessionReasoningItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'reasoning',
      'AgentSessionReasoningItemResource',
    );
    return AgentSessionReasoningItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionReasoningItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionReasoningItemResource.status',
        (value, context) =>
            AgentSessionOutputItemStatusResource.fromJson(value),
        nullable: true,
      ),
      summary: requiredAgentValue(
        json,
        'summary',
        'AgentSessionReasoningItemResource.summary',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionSummaryTextResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionReasoningItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'status',
            'summary',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'AgentSessionReasoningItemResource.id', min: 0);
    validateAgentCount(
      summary.length,
      'AgentSessionReasoningItemResource.summary',
      min: 0,
      max: 2000,
    );
    for (final item in summary) {
      item.validate();
    }
    validateAgentLength(
      turnId,
      'AgentSessionReasoningItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'status': status?.toJson(),
    'summary': summary.map((value) => value.toJson()).toList(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionReasoningItemResource copyWith({
    String? id,
    Object? status = unsetCopyWithValue,
    List<AgentSessionSummaryTextResource>? summary,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionReasoningItemResource(
    id: id ?? this.id,
    status: copyAgentValue<AgentSessionOutputItemStatusResource>(
      status,
      this.status,
      'AgentSessionReasoningItemResource.status',
    ),
    summary: summary ?? this.summary,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A request to resume a subagent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionResumeSubagentCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionResumeSubagentCallItemResource].
  AgentSessionResumeSubagentCallItemResource({
    required this.id,
    required this.recipientAgentId,
    required this.senderAgentId,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'recipient_agent_id',
         'sender_agent_id',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionResumeSubagentCallItemResource') {
    validate();
  }

  /// The ID of the tool call item.
  final String id;

  /// The ID of the agent to resume.
  final String recipientAgentId;

  /// The ID of the agent requesting the resume.
  final String senderAgentId;

  /// The status of the tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `resume_subagent_call`.
  @override
  String get type => 'resume_subagent_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionResumeSubagentCallItemResource] with contextual, payload-free errors.
  factory AgentSessionResumeSubagentCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'resume_subagent_call',
      'AgentSessionResumeSubagentCallItemResource',
    );
    return AgentSessionResumeSubagentCallItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionResumeSubagentCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      recipientAgentId: requiredAgentValue(
        json,
        'recipient_agent_id',
        'AgentSessionResumeSubagentCallItemResource.recipientAgentId',
        requireAgentString,
        nullable: false,
      )!,
      senderAgentId: requiredAgentValue(
        json,
        'sender_agent_id',
        'AgentSessionResumeSubagentCallItemResource.senderAgentId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionResumeSubagentCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionResumeSubagentCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'recipient_agent_id',
            'sender_agent_id',
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
      id,
      'AgentSessionResumeSubagentCallItemResource.id',
      min: 0,
    );
    validateAgentLength(
      recipientAgentId,
      'AgentSessionResumeSubagentCallItemResource.recipientAgentId',
      min: 0,
    );
    validateAgentLength(
      senderAgentId,
      'AgentSessionResumeSubagentCallItemResource.senderAgentId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionResumeSubagentCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'recipient_agent_id': recipientAgentId,
    'sender_agent_id': senderAgentId,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionResumeSubagentCallItemResource copyWith({
    String? id,
    String? recipientAgentId,
    String? senderAgentId,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionResumeSubagentCallItemResource(
    id: id ?? this.id,
    recipientAgentId: recipientAgentId ?? this.recipientAgentId,
    senderAgentId: senderAgentId ?? this.senderAgentId,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A request to send input to another agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSendSubagentInputCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionSendSubagentInputCallItemResource].
  AgentSessionSendSubagentInputCallItemResource({
    required List<AgentSessionContent> content,
    required this.id,
    required this.recipientAgentId,
    required this.senderAgentId,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       rawJson = agentExtras(rawJson, const [
         'content',
         'id',
         'recipient_agent_id',
         'sender_agent_id',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionSendSubagentInputCallItemResource') {
    validate();
  }

  /// The input sent to the receiving agent.
  final List<AgentSessionContent> content;

  /// The ID of the tool call item.
  final String id;

  /// The ID of the agent receiving the input.
  final String recipientAgentId;

  /// The ID of the agent sending the input.
  final String senderAgentId;

  /// The status of the tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `send_subagent_input_call`.
  @override
  String get type => 'send_subagent_input_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSendSubagentInputCallItemResource] with contextual, payload-free errors.
  factory AgentSessionSendSubagentInputCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'send_subagent_input_call',
      'AgentSessionSendSubagentInputCallItemResource',
    );
    return AgentSessionSendSubagentInputCallItemResource(
      content: requiredAgentValue(
        json,
        'content',
        'AgentSessionSendSubagentInputCallItemResource.content',
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
        'AgentSessionSendSubagentInputCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      recipientAgentId: requiredAgentValue(
        json,
        'recipient_agent_id',
        'AgentSessionSendSubagentInputCallItemResource.recipientAgentId',
        requireAgentString,
        nullable: false,
      )!,
      senderAgentId: requiredAgentValue(
        json,
        'sender_agent_id',
        'AgentSessionSendSubagentInputCallItemResource.senderAgentId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionSendSubagentInputCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionSendSubagentInputCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'content',
            'id',
            'recipient_agent_id',
            'sender_agent_id',
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
    validateAgentCount(
      content.length,
      'AgentSessionSendSubagentInputCallItemResource.content',
      min: 0,
      max: 2000,
    );
    for (final item in content) {
      item.validate();
    }
    validateAgentLength(
      id,
      'AgentSessionSendSubagentInputCallItemResource.id',
      min: 0,
    );
    validateAgentLength(
      recipientAgentId,
      'AgentSessionSendSubagentInputCallItemResource.recipientAgentId',
      min: 0,
    );
    validateAgentLength(
      senderAgentId,
      'AgentSessionSendSubagentInputCallItemResource.senderAgentId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionSendSubagentInputCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content': content.map((value) => value.toJson()).toList(),
    'id': id,
    'recipient_agent_id': recipientAgentId,
    'sender_agent_id': senderAgentId,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSendSubagentInputCallItemResource copyWith({
    List<AgentSessionContent>? content,
    String? id,
    String? recipientAgentId,
    String? senderAgentId,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSendSubagentInputCallItemResource(
    content: content ?? this.content,
    id: id ?? this.id,
    recipientAgentId: recipientAgentId ?? this.recipientAgentId,
    senderAgentId: senderAgentId ?? this.senderAgentId,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A subagent created within a session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSubagent extends AgentJsonModel {
  /// Creates a validated [AgentSessionSubagent].
  AgentSessionSubagent({
    required this.closedAt,
    required this.id,
    required List<AgentSessionContent>? instructions,
    required this.name,
    required this.object,
    required this.openedAt,
    required this.parentAgentId,
    required this.sessionId,
    required this.status,
    Map<String, dynamic> rawJson = const {},
  }) : instructions = ownAgentValue<List<AgentSessionContent>>(
         instructions,
         List.unmodifiable,
       ),
       rawJson = agentExtras(rawJson, const [
         'closed_at',
         'id',
         'instructions',
         'name',
         'object',
         'opened_at',
         'parent_agent_id',
         'session_id',
         'status',
       ], 'AgentSessionSubagent') {
    validate();
  }

  /// The Unix timestamp, in seconds, when the subagent was closed. Null while active, including after resume.
  final int? closedAt;

  /// The ID of the subagent.
  final String id;

  /// Initial task content, or null when unavailable. Text may contain placeholders for images or audio when only a preview is available.
  final List<AgentSessionContent>? instructions;

  /// The runner-assigned nickname, or null when unavailable.
  final String? name;

  /// The object type. Always `agent.session.subagent`.
  final AgentSessionSubagentObjectResource object;

  /// The Unix timestamp, in seconds, when the subagent was first opened. Resuming does not change it.
  final int openedAt;

  /// The ID of the agent that created this subagent.
  final String parentAgentId;

  /// The ID of the session that owns the subagent.
  final String sessionId;

  /// The current status of the subagent.
  final AgentSessionSubagentStatusResource status;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSubagent] with contextual, payload-free errors.
  factory AgentSessionSubagent.fromJson(Map<String, dynamic> json) {
    return AgentSessionSubagent(
      closedAt: requiredAgentValue(
        json,
        'closed_at',
        'AgentSessionSubagent.closedAt',
        requireAgentInt,
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionSubagent.id',
        requireAgentString,
        nullable: false,
      )!,
      instructions: requiredAgentValue(
        json,
        'instructions',
        'AgentSessionSubagent.instructions',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionContent.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionSubagent.name',
        requireAgentString,
        nullable: true,
      ),
      object: requiredAgentValue(
        json,
        'object',
        'AgentSessionSubagent.object',
        (value, context) => AgentSessionSubagentObjectResource.fromJson(value),
        nullable: false,
      )!,
      openedAt: requiredAgentValue(
        json,
        'opened_at',
        'AgentSessionSubagent.openedAt',
        requireAgentInt,
        nullable: false,
      )!,
      parentAgentId: requiredAgentValue(
        json,
        'parent_agent_id',
        'AgentSessionSubagent.parentAgentId',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionSubagent.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionSubagent.status',
        (value, context) => AgentSessionSubagentStatusResource.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'closed_at',
            'id',
            'instructions',
            'name',
            'object',
            'opened_at',
            'parent_agent_id',
            'session_id',
            'status',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (closedAt != null) {
      validateAgentInt(closedAt!, 'AgentSessionSubagent.closedAt');
    }
    validateAgentLength(id, 'AgentSessionSubagent.id', min: 0);
    if (instructions != null) {
      validateAgentCount(
        instructions!.length,
        'AgentSessionSubagent.instructions',
        min: 0,
        max: 2000,
      );
      for (final item in instructions!) {
        item.validate();
      }
    }
    if (name != null) {
      validateAgentLength(name!, 'AgentSessionSubagent.name', min: 0);
    }
    validateAgentEnum(object.value, [
      'agent.session.subagent',
    ], 'AgentSessionSubagent.object');
    validateAgentInt(openedAt, 'AgentSessionSubagent.openedAt');
    validateAgentLength(
      parentAgentId,
      'AgentSessionSubagent.parentAgentId',
      min: 0,
    );
    validateAgentLength(sessionId, 'AgentSessionSubagent.sessionId', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'closed_at': closedAt,
    'id': id,
    'instructions': instructions?.map((value) => value.toJson()).toList(),
    'name': name,
    'object': object.toJson(),
    'opened_at': openedAt,
    'parent_agent_id': parentAgentId,
    'session_id': sessionId,
    'status': status.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSubagent copyWith({
    Object? closedAt = unsetCopyWithValue,
    String? id,
    Object? instructions = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    AgentSessionSubagentObjectResource? object,
    int? openedAt,
    String? parentAgentId,
    String? sessionId,
    AgentSessionSubagentStatusResource? status,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSubagent(
    closedAt: copyAgentValue<int>(
      closedAt,
      this.closedAt,
      'AgentSessionSubagent.closedAt',
    ),
    id: id ?? this.id,
    instructions: copyAgentValue<List<AgentSessionContent>>(
      instructions,
      this.instructions,
      'AgentSessionSubagent.instructions',
    ),
    name: copyAgentValue<String>(name, this.name, 'AgentSessionSubagent.name'),
    object: object ?? this.object,
    openedAt: openedAt ?? this.openedAt,
    parentAgentId: parentAgentId ?? this.parentAgentId,
    sessionId: sessionId ?? this.sessionId,
    status: status ?? this.status,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A reasoning summary content part.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSummaryTextResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionSummaryTextResource].
  AgentSessionSummaryTextResource({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'text',
         'type',
       ], 'AgentSessionSummaryTextResource') {
    validate();
  }

  /// The reasoning summary text.
  final String text;

  /// The content type. Always `summary_text`.
  String get type => 'summary_text';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSummaryTextResource] with contextual, payload-free errors.
  factory AgentSessionSummaryTextResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'summary_text',
      'AgentSessionSummaryTextResource',
    );
    return AgentSessionSummaryTextResource(
      text: requiredAgentValue(
        json,
        'text',
        'AgentSessionSummaryTextResource.text',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['text', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(text, 'AgentSessionSummaryTextResource.text', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'text': text, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSummaryTextResource copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSummaryTextResource(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Recorded token usage for a session or turn. Usage is best effort and may change.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTokenUsageResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionTokenUsageResource].
  AgentSessionTokenUsageResource({
    required this.inputTokens,
    required this.inputTokensDetails,
    required this.outputTokens,
    required this.outputTokensDetails,
    required this.totalTokens,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'input_tokens',
         'input_tokens_details',
         'output_tokens',
         'output_tokens_details',
         'total_tokens',
       ], 'AgentSessionTokenUsageResource') {
    validate();
  }

  /// The number of input tokens used by the agent.
  final int inputTokens;

  /// A breakdown of the agent's input token usage.
  final AgentSessionInputTokensDetailsResourceDetails inputTokensDetails;

  /// The number of output tokens generated by the agent.
  final int outputTokens;

  /// A breakdown of the agent's output token usage.
  final AgentSessionOutputTokensDetailsResourceDetails outputTokensDetails;

  /// The total number of input and output tokens used by the agent.
  final int totalTokens;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTokenUsageResource] with contextual, payload-free errors.
  factory AgentSessionTokenUsageResource.fromJson(Map<String, dynamic> json) {
    return AgentSessionTokenUsageResource(
      inputTokens: requiredAgentValue(
        json,
        'input_tokens',
        'AgentSessionTokenUsageResource.inputTokens',
        requireAgentInt,
        nullable: false,
      )!,
      inputTokensDetails: requiredAgentValue(
        json,
        'input_tokens_details',
        'AgentSessionTokenUsageResource.inputTokensDetails',
        (value, context) =>
            AgentSessionInputTokensDetailsResourceDetails.fromJson(
              requireAgentObject(value, context),
            ),
        nullable: false,
      )!,
      outputTokens: requiredAgentValue(
        json,
        'output_tokens',
        'AgentSessionTokenUsageResource.outputTokens',
        requireAgentInt,
        nullable: false,
      )!,
      outputTokensDetails: requiredAgentValue(
        json,
        'output_tokens_details',
        'AgentSessionTokenUsageResource.outputTokensDetails',
        (value, context) =>
            AgentSessionOutputTokensDetailsResourceDetails.fromJson(
              requireAgentObject(value, context),
            ),
        nullable: false,
      )!,
      totalTokens: requiredAgentValue(
        json,
        'total_tokens',
        'AgentSessionTokenUsageResource.totalTokens',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'input_tokens',
            'input_tokens_details',
            'output_tokens',
            'output_tokens_details',
            'total_tokens',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(inputTokens, 'AgentSessionTokenUsageResource.inputTokens');
    inputTokensDetails.validate();
    validateAgentInt(
      outputTokens,
      'AgentSessionTokenUsageResource.outputTokens',
    );
    outputTokensDetails.validate();
    validateAgentInt(totalTokens, 'AgentSessionTokenUsageResource.totalTokens');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'input_tokens': inputTokens,
    'input_tokens_details': inputTokensDetails.toJson(),
    'output_tokens': outputTokens,
    'output_tokens_details': outputTokensDetails.toJson(),
    'total_tokens': totalTokens,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTokenUsageResource copyWith({
    int? inputTokens,
    AgentSessionInputTokensDetailsResourceDetails? inputTokensDetails,
    int? outputTokens,
    AgentSessionOutputTokensDetailsResourceDetails? outputTokensDetails,
    int? totalTokens,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTokenUsageResource(
    inputTokens: inputTokens ?? this.inputTokens,
    inputTokensDetails: inputTokensDetails ?? this.inputTokensDetails,
    outputTokens: outputTokens ?? this.outputTokens,
    outputTokensDetails: outputTokensDetails ?? this.outputTokensDetails,
    totalTokens: totalTokens ?? this.totalTokens,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The canonical public representation of a session turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionTurn extends AgentJsonModel {
  /// Creates a validated [AgentSessionTurn].
  AgentSessionTurn({
    required this.agentId,
    required this.completedAt,
    required this.createdAt,
    required this.error,
    required this.id,
    required this.object,
    required this.sessionId,
    required this.startedAt,
    required this.status,
    required this.subagentId,
    required this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'agent_id',
         'completed_at',
         'created_at',
         'error',
         'id',
         'object',
         'session_id',
         'started_at',
         'status',
         'subagent_id',
         'usage',
       ], 'AgentSessionTurn') {
    validate();
  }

  /// The ID of the agent that ran the turn.
  final String agentId;

  /// The Unix timestamp, in seconds, when the turn reached a terminal state.
  final int? completedAt;

  /// The Unix timestamp, in seconds, used to order the turn by creation time. Subagent turns use their start time, falling back to completion time or the subagent opening time when the preceding timestamps are unavailable.
  final int createdAt;

  /// A customer-safe error. Non-null only for a failed turn.
  final AgentSessionTurnErrorResource? error;

  /// The ID of the turn.
  final String id;

  /// The object type. Always `agent.session.turn`.
  final AgentSessionTurnObjectResource object;

  /// The ID of the session that owns the turn.
  final String sessionId;

  /// The Unix timestamp, in seconds, when the turn started.
  final int? startedAt;

  /// The current status of the turn.
  final AgentSessionTurnStatusResource status;

  /// The ID of the subagent that ran the turn, if applicable.
  final String? subagentId;

  /// Best-effort token usage for the turn, or null if unknown. Recorded usage may change.
  final AgentSessionTokenUsageResource? usage;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionTurn] with contextual, payload-free errors.
  factory AgentSessionTurn.fromJson(Map<String, dynamic> json) {
    return AgentSessionTurn(
      agentId: requiredAgentValue(
        json,
        'agent_id',
        'AgentSessionTurn.agentId',
        requireAgentString,
        nullable: false,
      )!,
      completedAt: requiredAgentValue(
        json,
        'completed_at',
        'AgentSessionTurn.completedAt',
        requireAgentInt,
        nullable: true,
      ),
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentSessionTurn.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      error: requiredAgentValue(
        json,
        'error',
        'AgentSessionTurn.error',
        (value, context) => AgentSessionTurnErrorResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionTurn.id',
        requireAgentString,
        nullable: false,
      )!,
      object: requiredAgentValue(
        json,
        'object',
        'AgentSessionTurn.object',
        (value, context) => AgentSessionTurnObjectResource.fromJson(value),
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurn.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      startedAt: requiredAgentValue(
        json,
        'started_at',
        'AgentSessionTurn.startedAt',
        requireAgentInt,
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionTurn.status',
        (value, context) => AgentSessionTurnStatusResource.fromJson(value),
        nullable: false,
      )!,
      subagentId: requiredAgentValue(
        json,
        'subagent_id',
        'AgentSessionTurn.subagentId',
        requireAgentString,
        nullable: true,
      ),
      usage: requiredAgentValue(
        json,
        'usage',
        'AgentSessionTurn.usage',
        (value, context) => AgentSessionTokenUsageResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'agent_id',
            'completed_at',
            'created_at',
            'error',
            'id',
            'object',
            'session_id',
            'started_at',
            'status',
            'subagent_id',
            'usage',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(agentId, 'AgentSessionTurn.agentId', min: 0);
    if (completedAt != null) {
      validateAgentInt(completedAt!, 'AgentSessionTurn.completedAt');
    }
    validateAgentInt(createdAt, 'AgentSessionTurn.createdAt');
    if (error != null) {
      error!.validate();
    }
    validateAgentLength(id, 'AgentSessionTurn.id', min: 0);
    validateAgentEnum(object.value, [
      'agent.session.turn',
    ], 'AgentSessionTurn.object');
    validateAgentLength(sessionId, 'AgentSessionTurn.sessionId', min: 0);
    if (startedAt != null) {
      validateAgentInt(startedAt!, 'AgentSessionTurn.startedAt');
    }
    if (subagentId != null) {
      validateAgentLength(subagentId!, 'AgentSessionTurn.subagentId', min: 0);
    }
    if (usage != null) {
      usage!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'agent_id': agentId,
    'completed_at': completedAt,
    'created_at': createdAt,
    'error': error?.toJson(),
    'id': id,
    'object': object.toJson(),
    'session_id': sessionId,
    'started_at': startedAt,
    'status': status.toJson(),
    'subagent_id': subagentId,
    'usage': usage?.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionTurn copyWith({
    String? agentId,
    Object? completedAt = unsetCopyWithValue,
    int? createdAt,
    Object? error = unsetCopyWithValue,
    String? id,
    AgentSessionTurnObjectResource? object,
    String? sessionId,
    Object? startedAt = unsetCopyWithValue,
    AgentSessionTurnStatusResource? status,
    Object? subagentId = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurn(
    agentId: agentId ?? this.agentId,
    completedAt: copyAgentValue<int>(
      completedAt,
      this.completedAt,
      'AgentSessionTurn.completedAt',
    ),
    createdAt: createdAt ?? this.createdAt,
    error: copyAgentValue<AgentSessionTurnErrorResource>(
      error,
      this.error,
      'AgentSessionTurn.error',
    ),
    id: id ?? this.id,
    object: object ?? this.object,
    sessionId: sessionId ?? this.sessionId,
    startedAt: copyAgentValue<int>(
      startedAt,
      this.startedAt,
      'AgentSessionTurn.startedAt',
    ),
    status: status ?? this.status,
    subagentId: copyAgentValue<String>(
      subagentId,
      this.subagentId,
      'AgentSessionTurn.subagentId',
    ),
    usage: copyAgentValue<AgentSessionTokenUsageResource>(
      usage,
      this.usage,
      'AgentSessionTurn.usage',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A request to wait for one or more subagents.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWaitForSubagentsCallItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionWaitForSubagentsCallItemResource].
  AgentSessionWaitForSubagentsCallItemResource({
    required this.id,
    required List<String> recipientAgentIds,
    required this.senderAgentId,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : recipientAgentIds = List.unmodifiable(recipientAgentIds),
       rawJson = agentExtras(rawJson, const [
         'id',
         'recipient_agent_ids',
         'sender_agent_id',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionWaitForSubagentsCallItemResource') {
    validate();
  }

  /// The ID of the tool call item.
  final String id;

  /// The IDs of the agents to wait for.
  final List<String> recipientAgentIds;

  /// The ID of the agent waiting for results.
  final String senderAgentId;

  /// The status of the tool call.
  final AgentSessionFunctionCallStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `wait_for_subagents_call`.
  @override
  String get type => 'wait_for_subagents_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWaitForSubagentsCallItemResource] with contextual, payload-free errors.
  factory AgentSessionWaitForSubagentsCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'wait_for_subagents_call',
      'AgentSessionWaitForSubagentsCallItemResource',
    );
    return AgentSessionWaitForSubagentsCallItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionWaitForSubagentsCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      recipientAgentIds: requiredAgentValue(
        json,
        'recipient_agent_ids',
        'AgentSessionWaitForSubagentsCallItemResource.recipientAgentIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      senderAgentId: requiredAgentValue(
        json,
        'sender_agent_id',
        'AgentSessionWaitForSubagentsCallItemResource.senderAgentId',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionWaitForSubagentsCallItemResource.status',
        (value, context) =>
            AgentSessionFunctionCallStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionWaitForSubagentsCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'recipient_agent_ids',
            'sender_agent_id',
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
      id,
      'AgentSessionWaitForSubagentsCallItemResource.id',
      min: 0,
    );
    validateAgentCount(
      recipientAgentIds.length,
      'AgentSessionWaitForSubagentsCallItemResource.recipientAgentIds',
      min: 0,
      max: 2000,
    );
    for (final item in recipientAgentIds) {
      validateAgentLength(
        item,
        'AgentSessionWaitForSubagentsCallItemResource.recipientAgentIds',
        min: 0,
      );
    }
    validateAgentLength(
      senderAgentId,
      'AgentSessionWaitForSubagentsCallItemResource.senderAgentId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionWaitForSubagentsCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'recipient_agent_ids': recipientAgentIds.map((value) => value).toList(),
    'sender_agent_id': senderAgentId,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWaitForSubagentsCallItemResource copyWith({
    String? id,
    List<String>? recipientAgentIds,
    String? senderAgentId,
    AgentSessionFunctionCallStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWaitForSubagentsCallItemResource(
    id: id ?? this.id,
    recipientAgentIds: recipientAgentIds ?? this.recipientAgentIds,
    senderAgentId: senderAgentId ?? this.senderAgentId,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An action performed by the web search tool.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionWebSearchActionResource extends AgentJsonModel {
  const AgentSessionWebSearchActionResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionWebSearchActionResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionWebSearchActionResource.type',
    )) {
      'find_in_page' => AgentSessionWebSearchActionResourceFindInPage.fromJson(
        json,
      ),
      'open_page' => AgentSessionWebSearchActionResourceOpenPage.fromJson(json),
      'other' => AgentSessionWebSearchActionResourceOther.fromJson(json),
      'search' => AgentSessionWebSearchActionResourceSearch.fromJson(json),
      _ => UnknownAgentSessionWebSearchActionResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `find_in_page` contract.
  factory AgentSessionWebSearchActionResource.findInPage({
    required String? pattern,
    required String? url,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchActionResourceFindInPage;

  /// Builds the `open_page` contract.
  factory AgentSessionWebSearchActionResource.openPage({
    required String? url,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchActionResourceOpenPage;

  /// Builds the `other` contract.
  factory AgentSessionWebSearchActionResource.other({
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchActionResourceOther;

  /// Builds the `search` contract.
  factory AgentSessionWebSearchActionResource.search({
    required List<String>? queries,
    required String? query,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchActionResourceSearch;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionWebSearchActionResource
    extends AgentSessionWebSearchActionResource {
  const UnknownAgentSessionWebSearchActionResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionWebSearchActionResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionWebSearchActionResource.type',
    );
    if (const ['find_in_page', 'open_page', 'other', 'search'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionWebSearchActionResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionWebSearchActionResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionWebSearchActionResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionWebSearchActionResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionWebSearchActionResource.fromJson(
    rawJson ?? this.rawJson,
  );
}

/// Finds text within a web page.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWebSearchActionResourceFindInPage
    extends AgentSessionWebSearchActionResource {
  /// Creates a validated [AgentSessionWebSearchActionResourceFindInPage].
  AgentSessionWebSearchActionResourceFindInPage({
    required this.pattern,
    required this.url,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'pattern',
         'type',
         'url',
       ], 'AgentSessionWebSearchActionResourceFindInPage') {
    validate();
  }

  /// The text pattern that was searched for.
  final String? pattern;

  /// The type of the object. Always `find_in_page`.
  @override
  String get type => 'find_in_page';

  /// The URL of the page that was searched.
  final String? url;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWebSearchActionResourceFindInPage] with contextual, payload-free errors.
  factory AgentSessionWebSearchActionResourceFindInPage.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'find_in_page',
      'AgentSessionWebSearchActionResourceFindInPage',
    );
    return AgentSessionWebSearchActionResourceFindInPage(
      pattern: requiredAgentValue(
        json,
        'pattern',
        'AgentSessionWebSearchActionResourceFindInPage.pattern',
        requireAgentString,
        nullable: true,
      ),
      url: requiredAgentValue(
        json,
        'url',
        'AgentSessionWebSearchActionResourceFindInPage.url',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['pattern', 'type', 'url'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (pattern != null) {
      validateAgentLength(
        pattern!,
        'AgentSessionWebSearchActionResourceFindInPage.pattern',
        min: 0,
      );
    }
    if (url != null) {
      validateAgentLength(
        url!,
        'AgentSessionWebSearchActionResourceFindInPage.url',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'pattern': pattern,
    'type': type,
    'url': url,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchActionResourceFindInPage copyWith({
    Object? pattern = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWebSearchActionResourceFindInPage(
    pattern: copyAgentValue<String>(
      pattern,
      this.pattern,
      'AgentSessionWebSearchActionResourceFindInPage.pattern',
    ),
    url: copyAgentValue<String>(
      url,
      this.url,
      'AgentSessionWebSearchActionResourceFindInPage.url',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Opens a web page.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWebSearchActionResourceOpenPage
    extends AgentSessionWebSearchActionResource {
  /// Creates a validated [AgentSessionWebSearchActionResourceOpenPage].
  AgentSessionWebSearchActionResourceOpenPage({
    required this.url,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
         'url',
       ], 'AgentSessionWebSearchActionResourceOpenPage') {
    validate();
  }

  /// The type of the object. Always `open_page`.
  @override
  String get type => 'open_page';

  /// The URL of the page that was opened.
  final String? url;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWebSearchActionResourceOpenPage] with contextual, payload-free errors.
  factory AgentSessionWebSearchActionResourceOpenPage.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'open_page',
      'AgentSessionWebSearchActionResourceOpenPage',
    );
    return AgentSessionWebSearchActionResourceOpenPage(
      url: requiredAgentValue(
        json,
        'url',
        'AgentSessionWebSearchActionResourceOpenPage.url',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type', 'url'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (url != null) {
      validateAgentLength(
        url!,
        'AgentSessionWebSearchActionResourceOpenPage.url',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type, 'url': url};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchActionResourceOpenPage copyWith({
    Object? url = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWebSearchActionResourceOpenPage(
    url: copyAgentValue<String>(
      url,
      this.url,
      'AgentSessionWebSearchActionResourceOpenPage.url',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Another web search action.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWebSearchActionResourceOther
    extends AgentSessionWebSearchActionResource {
  /// Creates a validated [AgentSessionWebSearchActionResourceOther].
  AgentSessionWebSearchActionResourceOther({
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
       ], 'AgentSessionWebSearchActionResourceOther') {
    validate();
  }

  /// The type of the object. Always `other`.
  @override
  String get type => 'other';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWebSearchActionResourceOther] with contextual, payload-free errors.
  factory AgentSessionWebSearchActionResourceOther.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'other',
      'AgentSessionWebSearchActionResourceOther',
    );
    return AgentSessionWebSearchActionResourceOther(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchActionResourceOther copyWith({
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWebSearchActionResourceOther(
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A search query or group of search queries.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWebSearchActionResourceSearch
    extends AgentSessionWebSearchActionResource {
  /// Creates a validated [AgentSessionWebSearchActionResourceSearch].
  AgentSessionWebSearchActionResourceSearch({
    required List<String>? queries,
    required this.query,
    Map<String, dynamic> rawJson = const {},
  }) : queries = ownAgentValue<List<String>>(queries, List.unmodifiable),
       rawJson = agentExtras(rawJson, const [
         'queries',
         'query',
         'type',
       ], 'AgentSessionWebSearchActionResourceSearch') {
    validate();
  }

  /// The search queries, when multiple queries were used.
  final List<String>? queries;

  /// The search query, when a single query was used.
  final String? query;

  /// The type of the object. Always `search`.
  @override
  String get type => 'search';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWebSearchActionResourceSearch] with contextual, payload-free errors.
  factory AgentSessionWebSearchActionResourceSearch.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'search',
      'AgentSessionWebSearchActionResourceSearch',
    );
    return AgentSessionWebSearchActionResourceSearch(
      queries: requiredAgentValue(
        json,
        'queries',
        'AgentSessionWebSearchActionResourceSearch.queries',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      query: requiredAgentValue(
        json,
        'query',
        'AgentSessionWebSearchActionResourceSearch.query',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['queries', 'query', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (queries != null) {
      validateAgentCount(
        queries!.length,
        'AgentSessionWebSearchActionResourceSearch.queries',
        min: 0,
        max: 2000,
      );
      for (final item in queries!) {
        validateAgentLength(
          item,
          'AgentSessionWebSearchActionResourceSearch.queries',
          min: 0,
        );
      }
    }
    if (query != null) {
      validateAgentLength(
        query!,
        'AgentSessionWebSearchActionResourceSearch.query',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'queries': queries?.map((value) => value).toList(),
    'query': query,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchActionResourceSearch copyWith({
    Object? queries = unsetCopyWithValue,
    Object? query = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWebSearchActionResourceSearch(
    queries: copyAgentValue<List<String>>(
      queries,
      this.queries,
      'AgentSessionWebSearchActionResourceSearch.queries',
    ),
    query: copyAgentValue<String>(
      query,
      this.query,
      'AgentSessionWebSearchActionResourceSearch.query',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A web search call produced by the agent.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWebSearchCallItemResource extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionWebSearchCallItemResource].
  AgentSessionWebSearchCallItemResource({
    required this.action,
    required this.id,
    required this.status,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'action',
         'id',
         'status',
         'turn_id',
         'type',
       ], 'AgentSessionWebSearchCallItemResource') {
    validate();
  }

  /// The action performed by the web search tool.
  final AgentSessionWebSearchActionResource? action;

  /// The ID of the web search call.
  final String id;

  /// The status of the web search call.
  final AgentSessionOutputItemStatusResource status;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The item type. Always `web_search_call`.
  @override
  String get type => 'web_search_call';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWebSearchCallItemResource] with contextual, payload-free errors.
  factory AgentSessionWebSearchCallItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'web_search_call',
      'AgentSessionWebSearchCallItemResource',
    );
    return AgentSessionWebSearchCallItemResource(
      action: requiredAgentValue(
        json,
        'action',
        'AgentSessionWebSearchCallItemResource.action',
        (value, context) => AgentSessionWebSearchActionResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionWebSearchCallItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentSessionWebSearchCallItemResource.status',
        (value, context) =>
            AgentSessionOutputItemStatusResource.fromJson(value),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionWebSearchCallItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'action',
            'id',
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
    if (action != null) {
      action!.validate();
    }
    validateAgentLength(id, 'AgentSessionWebSearchCallItemResource.id', min: 0);
    validateAgentLength(
      turnId,
      'AgentSessionWebSearchCallItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'action': action?.toJson(),
    'id': id,
    'status': status.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchCallItemResource copyWith({
    Object? action = unsetCopyWithValue,
    String? id,
    AgentSessionOutputItemStatusResource? status,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWebSearchCallItemResource(
    action: copyAgentValue<AgentSessionWebSearchActionResource>(
      action,
      this.action,
      'AgentSessionWebSearchCallItemResource.action',
    ),
    id: id ?? this.id,
    status: status ?? this.status,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}
