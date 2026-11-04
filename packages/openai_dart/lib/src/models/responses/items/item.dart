import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../config/computer_call_output_status.dart';
import '../config/configuration_update_reasoning.dart';
import '../config/configuration_update_text.dart';
import '../config/function_call_output_status.dart';
import '../config/function_call_status.dart';
import '../config/item_status.dart';
import '../config/message_phase.dart';
import '../config/message_role.dart';
import '../config/program_output_status.dart';
import '../config/tool_search_execution_type.dart';
import '../config/web_search_call_status.dart';
import '../content/input_content.dart';
import '../content/output_content.dart';
import '../multi_agent/agent_tag.dart';
import '../multi_agent/multi_agent_action.dart';
import '../tools/computer_action.dart';
import '../tools/response_tool.dart';
import '../tools/shell_tool_environment.dart';
import '../tools/tool_call_caller.dart';
import '../websocket/websocket_json_helpers.dart';
import 'output_item.dart'
    show
        ReasoningSummaryContent,
        ShellCallAction,
        ShellCallOutcome,
        ShellCallOutputContent,
        ShellEnvironment;
import 'shell_call_helpers.dart';
import 'tool_search_item_helpers.dart';
import 'web_search_action.dart';
import 'web_search_result.dart';

/// Input item for a response request.
///
/// ## Supported Item Types
///
/// - [ComputerCallInputItem] - A computer call replayed as input
/// - [ComputerCallOutputInputItem] - A computer call screenshot result
/// - [MessageItem] - A message from a user or assistant
/// - [FunctionCallItem] - A function call from the model
/// - [ReasoningInputItem] - Reasoning replayed without converting it to a message
/// - [CustomToolCallInputItem] - A custom tool call replayed as input
/// - [WebSearchCallItem] - Web search actions and results retained in input history
/// - [ShellCallInputItem] - Writable shell call history
/// - [ShellCallOutputInputItem] - Writable shell results
/// - [ShellCallResourceItem] - A stored shell call returned by the resource
/// - [ShellCallOutputResourceItem] - Stored shell output returned by the resource
/// - [FunctionCallOutputItem] - Output from a function call
/// - [ItemReference] - A reference to another item
/// - [CustomToolCallOutputInputItem] - Output from a custom tool call
/// - [ToolSearchCallItemParam] - A tool search call
/// - [ToolSearchOutputItemParam] - Tool search results
/// - [ToolSearchCallResourceItem] - Stored tool search calls
/// - [ToolSearchOutputResourceItem] - Stored discovered tools
/// - [CompactionTriggerItem] - Triggers compaction of the current context
/// - [AdditionalToolsItemParam] - Additional tool definitions made available
///   mid-conversation
/// - [ConfigurationUpdateItem] - Reasoning and text configuration for subsequent responses
/// - [ConfigurationUpdateItemResponse] - A stored configuration update returned
///   by the Responses input-items resource
/// - [ProgramItem] - Programmatic tool calling source code
/// - [ProgramOutputItem] - Result of a programmatic tool calling execution
/// - [AgentMessageItem] - A message routed between agents (beta multi-agent)
/// - [MultiAgentCallItem] - A multi-agent action call (beta multi-agent)
/// - [MultiAgentCallOutputItem] - Output of a multi-agent action call (beta
///   multi-agent)
sealed class Item {
  /// Creates an [Item].
  const Item();

  /// Creates an [Item] from JSON.
  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'computer_call' => ComputerCallInputItem.fromJson(json),
      'computer_call_output' => ComputerCallOutputInputItem.fromJson(json),
      'message' => MessageItem.fromJson(json),
      'function_call' => FunctionCallItem.fromJson(json),
      'reasoning' => ReasoningInputItem.fromJson(json),
      'custom_tool_call' => CustomToolCallInputItem.fromJson(json),
      'web_search_call' => WebSearchCallItem.fromJson(json),
      'shell_call' => ShellCallInputItem.fromJson(json),
      'shell_call_output' => ShellCallOutputInputItem.fromJson(json),
      'function_call_output' => FunctionCallOutputItem.fromJson(json),
      'custom_tool_call_output' => CustomToolCallOutputInputItem.fromJson(json),
      'item_reference' => ItemReference.fromJson(json),
      'tool_search_call' => ToolSearchCallItemParam.fromJson(json),
      'tool_search_output' => ToolSearchOutputItemParam.fromJson(json),
      'compaction_trigger' => CompactionTriggerItem.fromJson(json),
      'additional_tools' => AdditionalToolsItemParam.fromJson(json),
      'configuration_update' => ConfigurationUpdateItem.fromJson(json),
      'program' => ProgramItem.fromJson(json),
      'program_output' => ProgramOutputItem.fromJson(json),
      'agent_message' => AgentMessageItem.fromJson(json),
      'multi_agent_call' => MultiAgentCallItem.fromJson(json),
      'multi_agent_call_output' => MultiAgentCallOutputItem.fromJson(json),
      _ => throw FormatException('Unknown Item type: $type'),
    };
  }

  /// Creates an item returned by the Responses input-items resource.
  ///
  /// Shell calls/results, tool search and stored configuration updates use
  /// distinct returned contracts. Use conversion helpers for writable items or
  /// raw output replay for arbitrary returned search arguments.
  factory Item.fromResourceJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'computer_call_output' => ComputerCallOutputResourceItem.fromJson(json),
        'configuration_update' => ConfigurationUpdateItemResponse.fromJson(
          json,
        ),
        'shell_call' => ShellCallResourceItem.fromJson(json),
        'shell_call_output' => ShellCallOutputResourceItem.fromJson(json),
        'tool_search_call' => ToolSearchCallResourceItem.fromJson(json),
        'tool_search_output' => ToolSearchOutputResourceItem.fromJson(json),
        _ => Item.fromJson(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Reasoning replayed as typed Responses input.
///
/// Keep this item alongside the corresponding assistant/tool history, in its
/// original order. Prefer converting a completed output with
/// `ReasoningItem.toInput()`; encrypted data from an in-progress streaming item
/// may be incomplete. This model follows OpenAI's required [id] and [summary]
/// contract, including an empty summary list when no summary is available.
/// Provider-specific shapes outside that contract can use raw response input.
///
/// Construction and copies snapshot collections. Content uses JSON maps like
/// the output model, with validated `reasoning_text` parts and preserved extra
/// metadata. Diagnostics exclude reasoning, summary and encrypted payloads.
@immutable
class ReasoningInputItem extends Item {
  /// Creates typed input with owned immutable content and summary snapshots.
  factory ReasoningInputItem({
    required String id,
    required List<ReasoningSummaryContent> summary,
    List<Map<String, dynamic>>? content,
    String? encryptedContent,
    bool hasEncryptedContent = false,
    ItemStatus? status,
    AgentTag? agent,
  }) => ReasoningInputItem.fromJson({
    'type': 'reasoning',
    'id': id,
    'summary': summary.map((part) => part.toJson()).toList(),
    'content': ?content,
    if (encryptedContent != null || hasEncryptedContent)
      'encrypted_content': encryptedContent,
    if (status != null) 'status': status.toJson(),
    if (agent != null) 'agent': agent.toJson(),
  });

  const ReasoningInputItem._({
    required this.id,
    required this.summary,
    required this.content,
    required this.encryptedContent,
    required this.hasEncryptedContent,
    required this.status,
    required this.agent,
  });

  /// Parses canonical input, rejecting missing required or malformed fields.
  factory ReasoningInputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ReasoningInputItem';
    requireJsonType(json, 'reasoning', context);
    final snapshot = snapshotResponsesJson(json, context);
    final id = requireJsonString(snapshot['id'], '$context.id');
    final rawSummary = snapshot['summary'];
    if (rawSummary is! List) {
      throw const FormatException('$context.summary: expected an array');
    }
    final summary = <ReasoningSummaryContent>[];
    for (var index = 0; index < rawSummary.length; index++) {
      final part = requireJsonObject(
        rawSummary[index],
        '$context.summary[$index]',
      );
      requireJsonType(part, 'summary_text', '$context.summary[$index]');
      summary.add(
        ReasoningSummaryContent(
          text: requireJsonString(
            part['text'],
            '$context.summary[$index].text',
          ),
        ),
      );
    }
    List<Map<String, dynamic>>? content;
    if (snapshot.containsKey('content')) {
      final rawContent = snapshot['content'];
      if (rawContent is! List) {
        throw const FormatException('$context.content: expected an array');
      }
      content = <Map<String, dynamic>>[];
      for (var index = 0; index < rawContent.length; index++) {
        final part = requireJsonObject(
          rawContent[index],
          '$context.content[$index]',
        );
        requireJsonType(part, 'reasoning_text', '$context.content[$index]');
        requireJsonString(part['text'], '$context.content[$index].text');
        content.add(freezeJsonObject(part));
      }
    }
    final status = snapshot.containsKey('status')
        ? ItemStatus.fromJson(
            requireJsonString(snapshot['status'], '$context.status'),
          )
        : null;
    return ReasoningInputItem._(
      id: id,
      summary: List<ReasoningSummaryContent>.unmodifiable(summary),
      content: content == null
          ? null
          : List<Map<String, dynamic>>.unmodifiable(content),
      encryptedContent: optionalJsonString(
        snapshot,
        'encrypted_content',
        context,
        nullable: true,
      ),
      hasEncryptedContent: snapshot.containsKey('encrypted_content'),
      status: status,
      agent: toolSearchJsonAgent(snapshot, context, nullable: true),
    );
  }

  /// The fixed item discriminator.
  String get type => 'reasoning';

  /// The returned reasoning item's identifier.
  final String id;

  /// Summary parts, including an empty list for models without summaries.
  final List<ReasoningSummaryContent> summary;

  /// Optional plaintext reasoning parts, separate from assistant message text.
  final List<Map<String, dynamic>>? content;

  /// Opaque reasoning state to replay unchanged, when returned by the provider.
  final String? encryptedContent;

  /// Whether the nullable encrypted key was present, including explicit null.
  /// Set this in construction to emit a null key deliberately.
  final bool hasEncryptedContent;

  /// Optional returned status, retained when replaying completed output.
  final ItemStatus? status;

  /// Producing-agent metadata on the beta multi-agent surface.
  final AgentTag? agent;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'summary': summary.map((part) => part.toJson()).toList(),
    if (content != null) 'content': content,
    if (encryptedContent != null || hasEncryptedContent)
      'encrypted_content': encryptedContent,
    if (status != null) 'status': status!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Copies every field and owns replacement collections. Null clears an
  /// optional value. For encrypted content it retains explicit null; also set
  /// [hasEncryptedContent] to false to restore omission.
  ReasoningInputItem copyWith({
    String? id,
    List<ReasoningSummaryContent>? summary,
    Object? content = unsetCopyWithValue,
    Object? encryptedContent = unsetCopyWithValue,
    bool? hasEncryptedContent,
    Object? status = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ReasoningInputItem(
    id: id ?? this.id,
    summary: summary ?? this.summary,
    content: identical(content, unsetCopyWithValue)
        ? this.content
        : _reasoningInputCopyContent(content),
    encryptedContent: identical(encryptedContent, unsetCopyWithValue)
        ? this.encryptedContent
        : encryptedContent as String?,
    hasEncryptedContent:
        hasEncryptedContent ??
        (!identical(encryptedContent, unsetCopyWithValue) ||
            this.hasEncryptedContent),
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningInputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(summary, other.summary) &&
          listOfMapsDeepEqual(content, other.content) &&
          encryptedContent == other.encryptedContent &&
          hasEncryptedContent == other.hasEncryptedContent &&
          status == other.status &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    id,
    listHash(summary),
    listOfMapsHashCode(content),
    encryptedContent,
    hasEncryptedContent,
    status,
    agent,
  );

  @override
  String toString() =>
      'ReasoningInputItem(id: [REDACTED], '
      'summary: ${summary.length} parts, '
      'content: ${content == null ? null : '${content!.length} parts'}, '
      'encryptedContent: ${encryptedContent == null ? null : '[${encryptedContent!.length} chars]'}, '
      'hasEncryptedContent: $hasEncryptedContent, status: $status, '
      'agent: ${agent == null ? null : 'present'})';
}

List<Map<String, dynamic>>? _reasoningInputCopyContent(Object? value) {
  if (value == null) return null;
  if (value is! List) {
    throw const FormatException(
      'ReasoningInputItem.content: expected an array',
    );
  }
  return [
    for (var index = 0; index < value.length; index++)
      requireJsonObject(value[index], 'ReasoningInputItem.content[$index]'),
  ];
}

/// A computer call replayed in Responses input history.
@immutable
class ComputerCallInputItem extends Item {
  /// The fixed item discriminator.
  String get type => 'computer_call';

  /// Agent metadata on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The call item ID.
  final String id;

  /// The ID used to associate the result with this call.
  final String callId;

  /// The legacy single action, when present.
  final ComputerAction? action;

  /// Ordered batched actions, when present.
  final List<ComputerAction>? actions;

  /// Safety checks returned with the call.
  final List<Map<String, dynamic>> pendingSafetyChecks;

  /// The call status.
  final ItemStatus status;

  /// Creates a computer call input item, snapshotting actions and safety checks.
  ComputerCallInputItem({
    required this.id,
    this.agent,
    required this.callId,
    ComputerAction? action,
    List<ComputerAction>? actions,
    required List<Map<String, dynamic>> pendingSafetyChecks,
    required this.status,
  }) : action = action == null ? null : _snapshotComputerAction(action),
       actions = actions == null
           ? null
           : List.unmodifiable(actions.map(_snapshotComputerAction)),
       pendingSafetyChecks = List.unmodifiable(
         pendingSafetyChecks.map(freezeJsonObject),
       );

  /// Parses a computer call input item.
  factory ComputerCallInputItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'computer_call', 'ComputerCallInputItem');
    return ComputerCallInputItem(
      id: json['id'] as String,
      agent: json['agent'] == null
          ? null
          : AgentTag.fromJson(json['agent'] as Map<String, dynamic>),
      callId: json['call_id'] as String,
      action: json['action'] == null
          ? null
          : ComputerAction.fromJson(json['action'] as Map<String, dynamic>),
      actions: (json['actions'] as List?)
          ?.map((e) => ComputerAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingSafetyChecks: (json['pending_safety_checks'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      status: ItemStatus.fromJson(json['status'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    if (action != null) 'action': action!.toJson(),
    if (actions != null) 'actions': actions!.map((e) => e.toJson()).toList(),
    'pending_safety_checks': pendingSafetyChecks,
    'status': status.toJson(),
  };

  /// Copies the item; explicit null clears optional fields.
  ComputerCallInputItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    Object? action = unsetCopyWithValue,
    Object? actions = unsetCopyWithValue,
    List<Map<String, dynamic>>? pendingSafetyChecks,
    ItemStatus? status,
  }) => ComputerCallInputItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    action: identical(action, unsetCopyWithValue)
        ? this.action
        : action as ComputerAction?,
    actions: identical(actions, unsetCopyWithValue)
        ? this.actions
        : actions as List<ComputerAction>?,
    pendingSafetyChecks: pendingSafetyChecks ?? this.pendingSafetyChecks,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerCallInputItem &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          listsEqual(actions, other.actions) &&
          listOfMapsDeepEqual(pendingSafetyChecks, other.pendingSafetyChecks) &&
          status == other.status;
  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    action,
    listHash(actions),
    listOfMapsHashCode(pendingSafetyChecks),
    status,
  );
}

// Action constructors retain caller collections for const compatibility.
// Snapshot through their codecs to detach nested keys and path coordinates;
// DragAction's parser also creates a new outer path list that must be frozen.
ComputerAction _snapshotComputerAction(ComputerAction action) {
  final snapshot = ComputerAction.fromJson(freezeJsonObject(action.toJson()));
  return switch (snapshot) {
    DragAction(:final path, :final keys) => DragAction(
      path: List.unmodifiable(path),
      keys: keys,
    ),
    _ => snapshot,
  };
}

/// A safety check acknowledged by the developer.
@immutable
class ComputerSafetyCheck {
  /// The ID of the safety check.
  final String id;

  /// The type of safety check.
  final String? code;

  /// Details about the safety check.
  final String? message;

  /// Creates a safety check.
  const ComputerSafetyCheck({required this.id, this.code, this.message});

  /// Parses a safety check.
  factory ComputerSafetyCheck.fromJson(Map<String, dynamic> json) =>
      ComputerSafetyCheck(
        id: json['id'] as String,
        code: json['code'] as String?,
        message: json['message'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (code != null) 'code': code,
    if (message != null) 'message': message,
  };

  /// Copies the check; explicit null clears optional fields.
  ComputerSafetyCheck copyWith({
    String? id,
    Object? code = unsetCopyWithValue,
    Object? message = unsetCopyWithValue,
  }) => ComputerSafetyCheck(
    id: id ?? this.id,
    code: identical(code, unsetCopyWithValue) ? this.code : code as String?,
    message: identical(message, unsetCopyWithValue)
        ? this.message
        : message as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerSafetyCheck &&
          id == other.id &&
          code == other.code &&
          message == other.message;
  @override
  int get hashCode => Object.hash(id, code, message);
}

/// A screenshot result for a computer call.
@immutable
class ComputerCallOutputInputItem extends Item {
  /// The fixed item discriminator.
  String get type => 'computer_call_output';

  /// Agent metadata on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The ID of the call being answered.
  final String callId;

  /// The screenshot captured after the actions.
  final ComputerScreenshotContent output;

  /// Optional item ID.
  final String? id;

  /// Safety checks acknowledged by the developer.
  final List<ComputerSafetyCheck>? acknowledgedSafetyChecks;

  /// Status, when returned by the input-items resource.
  final ItemStatus? status;

  /// Creates a computer call result, snapshotting acknowledged safety checks.
  ComputerCallOutputInputItem({
    required this.callId,
    required this.output,
    this.agent,
    this.id,
    List<ComputerSafetyCheck>? acknowledgedSafetyChecks,
    this.status,
  }) : acknowledgedSafetyChecks = acknowledgedSafetyChecks == null
           ? null
           : List.unmodifiable(acknowledgedSafetyChecks);

  /// Parses a computer call result.
  factory ComputerCallOutputInputItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(
      json,
      'computer_call_output',
      'ComputerCallOutputInputItem',
    );
    final output = json['output'] as Map<String, dynamic>;
    requireJsonType(
      output,
      'computer_screenshot',
      'ComputerCallOutputInputItem.output',
    );
    return ComputerCallOutputInputItem(
      callId: json['call_id'] as String,
      output: ComputerScreenshotContent.fromJson(output),
      agent: json['agent'] == null
          ? null
          : AgentTag.fromJson(json['agent'] as Map<String, dynamic>),
      id: json['id'] as String?,
      acknowledgedSafetyChecks: (json['acknowledged_safety_checks'] as List?)
          ?.map((e) => ComputerSafetyCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] == null
          ? null
          : ItemStatus.fromJson(json['status'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    if (agent != null) 'agent': agent!.toJson(),
    'output': output.toJson(),
    if (id != null) 'id': id,
    if (acknowledgedSafetyChecks != null)
      'acknowledged_safety_checks': acknowledgedSafetyChecks!
          .map((e) => e.toJson())
          .toList(),
    if (status != null) 'status': status!.toJson(),
  };

  /// Copies the item; explicit null clears optional fields.
  ComputerCallOutputInputItem copyWith({
    String? callId,
    ComputerScreenshotContent? output,
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? acknowledgedSafetyChecks = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) => ComputerCallOutputInputItem(
    callId: callId ?? this.callId,
    output: output ?? this.output,
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    acknowledgedSafetyChecks:
        identical(acknowledgedSafetyChecks, unsetCopyWithValue)
        ? this.acknowledgedSafetyChecks
        : acknowledgedSafetyChecks as List<ComputerSafetyCheck>?,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerCallOutputInputItem &&
          callId == other.callId &&
          output == other.output &&
          id == other.id &&
          agent == other.agent &&
          listsEqual(
            acknowledgedSafetyChecks,
            other.acknowledgedSafetyChecks,
          ) &&
          status == other.status;
  @override
  int get hashCode => Object.hash(
    callId,
    output,
    id,
    agent,
    listHash(acknowledgedSafetyChecks),
    status,
  );
}

/// A computer call output returned by the input-items resource.
@immutable
class ComputerCallOutputResourceItem extends Item {
  /// Agent metadata on the beta multi-agent protocol.
  final AgentTag? agent;

  /// ID of the stored output item.
  final String id;

  /// ID of the call being answered.
  final String callId;

  /// Screenshot captured after the actions.
  final ComputerScreenshotOutputContent output;

  /// Status of the stored item.
  final ComputerCallOutputStatus status;

  /// Safety checks acknowledged by the developer.
  final List<ComputerSafetyCheck>? acknowledgedSafetyChecks;

  /// Identifier of the actor that created the item.
  final String? createdBy;

  /// Creates a stored result, snapshotting acknowledged safety checks.
  ComputerCallOutputResourceItem({
    required this.id,
    required this.callId,
    required this.output,
    required this.status,
    this.agent,
    List<ComputerSafetyCheck>? acknowledgedSafetyChecks,
    this.createdBy,
  }) : acknowledgedSafetyChecks = acknowledgedSafetyChecks == null
           ? null
           : List.unmodifiable(acknowledgedSafetyChecks);

  /// Parses a stored computer call result.
  factory ComputerCallOutputResourceItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(
      json,
      'computer_call_output',
      'ComputerCallOutputResourceItem',
    );
    final output = json['output'] as Map<String, dynamic>;
    requireJsonType(
      output,
      'computer_screenshot',
      'ComputerCallOutputResourceItem.output',
    );
    return ComputerCallOutputResourceItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      output: ComputerScreenshotOutputContent.fromJson(output),
      agent: json['agent'] == null
          ? null
          : AgentTag.fromJson(json['agent'] as Map<String, dynamic>),
      status: ComputerCallOutputStatus.fromJson(json['status'] as String),
      acknowledgedSafetyChecks: (json['acknowledged_safety_checks'] as List?)
          ?.map((e) => ComputerSafetyCheck.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json['created_by'] as String?,
    );
  }

  /// Converts the stored result to writable input.
  ///
  /// Throws [StateError] for a failed or unknown status or a redacted screenshot.
  ComputerCallOutputInputItem toInputItem() {
    final inputStatus = switch (status) {
      ComputerCallOutputStatus.inProgress => ItemStatus.inProgress,
      ComputerCallOutputStatus.completed => ItemStatus.completed,
      ComputerCallOutputStatus.incomplete => ItemStatus.incomplete,
      ComputerCallOutputStatus.failed ||
      ComputerCallOutputStatus.unknown => throw StateError(
        'Cannot replay a computer call output with status ${status.value}',
      ),
    };
    if (output.imageUrl == null && output.fileId == null) {
      throw StateError(
        'Cannot replay a computer screenshot without an image URL or file ID',
      );
    }
    return ComputerCallOutputInputItem(
      id: id,
      callId: callId,
      output: ComputerScreenshotContent(
        imageUrl: output.imageUrl,
        fileId: output.fileId,
        detail: output.detail,
        promptCacheBreakpoint: output.promptCacheBreakpoint,
      ),
      agent: agent,
      status: inputStatus,
      acknowledgedSafetyChecks: acknowledgedSafetyChecks,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'computer_call_output',
    'id': id,
    'call_id': callId,
    'output': output.toJson(),
    'status': status.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
    if (acknowledgedSafetyChecks != null)
      'acknowledged_safety_checks': acknowledgedSafetyChecks!
          .map((e) => e.toJson())
          .toList(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Copies the item; explicit null clears optional metadata.
  ComputerCallOutputResourceItem copyWith({
    String? id,
    String? callId,
    ComputerScreenshotOutputContent? output,
    ComputerCallOutputStatus? status,
    Object? agent = unsetCopyWithValue,
    Object? acknowledgedSafetyChecks = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ComputerCallOutputResourceItem(
    id: id ?? this.id,
    callId: callId ?? this.callId,
    output: output ?? this.output,
    status: status ?? this.status,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    acknowledgedSafetyChecks:
        identical(acknowledgedSafetyChecks, unsetCopyWithValue)
        ? this.acknowledgedSafetyChecks
        : acknowledgedSafetyChecks as List<ComputerSafetyCheck>?,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerCallOutputResourceItem &&
          id == other.id &&
          callId == other.callId &&
          output == other.output &&
          status == other.status &&
          agent == other.agent &&
          listsEqual(
            acknowledgedSafetyChecks,
            other.acknowledgedSafetyChecks,
          ) &&
          createdBy == other.createdBy;
  @override
  int get hashCode => Object.hash(
    id,
    callId,
    output,
    status,
    agent,
    listHash(acknowledgedSafetyChecks),
    createdBy,
  );
}

/// A web search call retained in Responses input history.
///
/// The canonical input and input-resource unions share this exact call shape.
@immutable
class WebSearchCallItem extends Item {
  /// The fixed item discriminator.
  String get type => 'web_search_call';

  /// Unique identifier.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Web search status, including searching and failed states.
  ///
  /// May be null for legacy or partial responses.
  final WebSearchCallStatus? status;

  /// The action performed by the web search tool, when supplied.
  final WebSearchAction? action;

  /// Results included with `web_search_call.results`.
  ///
  /// Constructor lists are caller-owned for const compatibility and must not be
  /// mutated after construction. JSON parsing returns an unmodifiable list.
  final List<WebSearchResult>? results;

  /// Creates a [WebSearchCallItem].
  const WebSearchCallItem({
    required this.id,
    this.agent,
    this.status,
    this.action,
    this.results,
  });

  /// Creates a [WebSearchCallItem] from JSON.
  factory WebSearchCallItem.fromJson(Map<String, dynamic> json) {
    const context = 'WebSearchCallItem';
    requireJsonType(json, 'web_search_call', context);
    final agent = json['agent'] == null
        ? null
        : requireJsonObject(json['agent'], '$context.agent');
    final rawResults = json['results'];
    if (json.containsKey('results') && rawResults is! List) {
      throw const FormatException('$context.results: expected an array');
    }
    return WebSearchCallItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: agent == null
          ? null
          : AgentTag(
              agentName: requireJsonString(
                agent['agent_name'],
                '$context.agent.agent_name',
              ),
            ),
      status: json['status'] != null
          ? WebSearchCallStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            )
          : null,
      action: json.containsKey('action')
          ? WebSearchAction.fromJson(
              requireJsonObject(json['action'], '$context.action'),
              context: '$context.action',
            )
          : null,
      results: rawResults is List
          ? List.unmodifiable([
              for (var i = 0; i < rawResults.length; i++)
                WebSearchResult.fromJson(
                  requireJsonObject(rawResults[i], '$context.results[$i]'),
                  context: '$context.results[$i]',
                ),
            ])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (action != null) 'action': action!.toJson(),
    if (results != null) 'results': results!.map((e) => e.toJson()).toList(),
  };

  /// Copies every field; explicit null clears an optional value.
  WebSearchCallItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? action = unsetCopyWithValue,
    Object? results = unsetCopyWithValue,
  }) => WebSearchCallItem(
    id: id ?? this.id,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    status: status == unsetCopyWithValue
        ? this.status
        : status as WebSearchCallStatus?,
    action: action == unsetCopyWithValue
        ? this.action
        : action as WebSearchAction?,
    results: results == unsetCopyWithValue
        ? this.results
        : results as List<WebSearchResult>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          status == other.status &&
          action == other.action &&
          listsEqual(results, other.results);

  @override
  int get hashCode => Object.hash(id, agent, status, action, listHash(results));

  @override
  String toString() =>
      'WebSearchCallItem(type: $type, id: $id, agent: $agent, status: $status, action: $action, results: ${results == null ? 'null' : '${results!.length} items'})';
}

/// Changes reasoning and text configuration for subsequent responses in a conversation.
///
/// Keep request-level reasoning stable when changing effort with this item to
/// preserve the cached prefix. Persistence is managed by the server and currently
/// applies to single-agent conversations.
@immutable
class ConfigurationUpdateItem extends Item {
  /// The fixed item discriminator.
  String get type => 'configuration_update';

  /// Optional item identifier. Parsed null is normalized to omission.
  final String? id;

  /// Reasoning fields to update. When supplied, the JSON object must be nonnull.
  final ConfigurationUpdateReasoning? reasoning;

  /// Text output format to use until a subsequent update replaces it.
  final ConfigurationUpdateText? text;

  /// Agent metadata on the beta multi-agent protocol.
  ///
  /// Retained for contextual replay. Configuration persistence is currently
  /// supported only in single-agent conversations.
  final AgentTag? agent;

  /// Creates a [ConfigurationUpdateItem].
  const ConfigurationUpdateItem({
    this.id,
    this.reasoning,
    this.text,
    this.agent,
  });

  /// Creates a [ConfigurationUpdateItem] from JSON.
  factory ConfigurationUpdateItem.fromJson(Map<String, dynamic> json) {
    const context = 'ConfigurationUpdateItem';
    requireJsonType(json, 'configuration_update', context);
    final agent = json['agent'] == null
        ? null
        : requireJsonObject(json['agent'], '$context.agent');
    return ConfigurationUpdateItem(
      id: optionalJsonString(json, 'id', context, nullable: true),
      reasoning: json.containsKey('reasoning')
          ? ConfigurationUpdateReasoning.fromJson(
              requireJsonObject(json['reasoning'], '$context.reasoning'),
              context: '$context.reasoning',
            )
          : null,
      text: json.containsKey('text')
          ? ConfigurationUpdateText.fromJson(
              requireJsonObject(json['text'], '$context.text'),
              context: '$context.text',
            )
          : null,
      agent: agent == null
          ? null
          : AgentTag(
              agentName: requireJsonString(
                agent['agent_name'],
                '$context.agent.agent_name',
              ),
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (text != null) 'text': text!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Copies every field; explicit null clears an optional value.
  ConfigurationUpdateItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ConfigurationUpdateItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ConfigurationUpdateReasoning?,
    text: text == unsetCopyWithValue
        ? this.text
        : text as ConfigurationUpdateText?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationUpdateItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reasoning == other.reasoning &&
          text == other.text &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, reasoning, text, agent);

  @override
  String toString() =>
      'ConfigurationUpdateItem(type: $type, id: $id, reasoning: $reasoning, text: $text, agent: $agent)';
}

/// A stored configuration update returned by the Responses input-items resource.
///
/// The returned item requires [id]; request input [ConfigurationUpdateItem] does
/// not. This is an input-resource item rather than a response output item.
@immutable
class ConfigurationUpdateItemResponse extends Item {
  /// The fixed item discriminator.
  String get type => 'configuration_update';

  /// The identifier of the stored configuration update.
  final String id;

  /// The reasoning update, when supplied.
  final ConfigurationUpdateReasoning? reasoning;

  /// Text output format to use until a subsequent update replaces it.
  final ConfigurationUpdateText? text;

  /// Agent metadata on the beta multi-agent protocol.
  final AgentTag? agent;

  /// Creates a [ConfigurationUpdateItemResponse].
  const ConfigurationUpdateItemResponse({
    required this.id,
    this.reasoning,
    this.text,
    this.agent,
  });

  /// Creates a [ConfigurationUpdateItemResponse] from JSON.
  factory ConfigurationUpdateItemResponse.fromJson(Map<String, dynamic> json) {
    const context = 'ConfigurationUpdateItemResponse';
    requireJsonType(json, 'configuration_update', context);
    final agent = json.containsKey('agent')
        ? requireJsonObject(json['agent'], '$context.agent')
        : null;
    return ConfigurationUpdateItemResponse(
      id: requireJsonString(json['id'], '$context.id'),
      reasoning: json.containsKey('reasoning')
          ? ConfigurationUpdateReasoning.fromJson(
              requireJsonObject(json['reasoning'], '$context.reasoning'),
              context: '$context.reasoning',
            )
          : null,
      text: json.containsKey('text')
          ? ConfigurationUpdateText.fromJson(
              requireJsonObject(json['text'], '$context.text'),
              context: '$context.text',
            )
          : null,
      agent: agent == null
          ? null
          : AgentTag(
              agentName: requireJsonString(
                agent['agent_name'],
                '$context.agent.agent_name',
              ),
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (text != null) 'text': text!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Converts to request input while preserving every input-supported field.
  ConfigurationUpdateItem toConfigurationUpdateItem() =>
      ConfigurationUpdateItem(
        id: id,
        reasoning: reasoning,
        text: text,
        agent: agent,
      );

  /// Copies every field; explicit null clears an optional value.
  ConfigurationUpdateItemResponse copyWith({
    String? id,
    Object? reasoning = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ConfigurationUpdateItemResponse(
    id: id ?? this.id,
    reasoning: reasoning == unsetCopyWithValue
        ? this.reasoning
        : reasoning as ConfigurationUpdateReasoning?,
    text: text == unsetCopyWithValue
        ? this.text
        : text as ConfigurationUpdateText?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationUpdateItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reasoning == other.reasoning &&
          text == other.text &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, reasoning, text, agent);

  @override
  String toString() =>
      'ConfigurationUpdateItemResponse(type: $type, id: $id, reasoning: $reasoning, text: $text, agent: $agent)';
}

/// A message item in a conversation.
@immutable
class MessageItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The role of the message.
  final MessageRole role;

  /// The content of the message.
  final List<InputContent> content;

  /// Item status (for output items).
  final ItemStatus? status;

  /// The phase of the message.
  final MessagePhase? phase;

  /// Creates a [MessageItem].
  const MessageItem({
    this.id,
    this.agent,
    required this.role,
    required this.content,
    this.status,
    this.phase,
  });

  /// Creates a user message.
  factory MessageItem.user(List<InputContent> content) =>
      MessageItem(role: MessageRole.user, content: content);

  /// Creates a user message with simple text.
  factory MessageItem.userText(String text) =>
      MessageItem(role: MessageRole.user, content: [InputContent.text(text)]);

  /// Creates a system message.
  factory MessageItem.system(List<InputContent> content) =>
      MessageItem(role: MessageRole.system, content: content);

  /// Creates a system message with simple text.
  factory MessageItem.systemText(String text) =>
      MessageItem(role: MessageRole.system, content: [InputContent.text(text)]);

  /// Creates a developer message.
  factory MessageItem.developer(List<InputContent> content) =>
      MessageItem(role: MessageRole.developer, content: content);

  /// Creates a developer message with simple text.
  factory MessageItem.developerText(String text) => MessageItem(
    role: MessageRole.developer,
    content: [InputContent.text(text)],
  );

  /// Creates an assistant message.
  factory MessageItem.assistant(List<InputContent> content) =>
      MessageItem(role: MessageRole.assistant, content: content);

  /// Creates an assistant message with simple text.
  ///
  /// Uses [AssistantTextContent] which serializes as `output_text`,
  /// as required by the API for assistant messages in multi-turn conversations.
  factory MessageItem.assistantText(String text) => MessageItem(
    role: MessageRole.assistant,
    content: [InputContent.assistantText(text)],
  );

  /// Creates a [MessageItem] from JSON.
  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      phase: json['phase'] != null
          ? MessagePhase.fromJson(json['phase'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
    if (phase != null) 'phase': phase!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status &&
          phase == other.phase;

  @override
  int get hashCode =>
      Object.hash(id, agent, role, Object.hashAll(content), status, phase);

  @override
  String toString() =>
      'MessageItem(id: $id, agent: $agent, role: $role, content: $content, status: $status, phase: $phase)';
}

/// A function call item.
@immutable
class FunctionCallItem extends Item {
  /// The fixed discriminator for this call item.
  String get type => 'function_call';

  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID for this function call.
  final String callId;

  /// The function name.
  final String name;

  /// The function arguments as JSON string.
  final String arguments;

  /// The arguments parsed as a JSON map.
  ///
  /// Throws [FormatException] if [arguments] is not valid JSON or does not
  /// decode to a JSON object.
  Map<String, dynamic> get argumentsMap {
    final decoded = jsonDecode(arguments);
    if (decoded is! Map) {
      throw const FormatException(
        'FunctionCallItem.arguments must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  /// Item status (for output items).
  final ItemStatus? status;

  /// The namespace this function call belongs to.
  final String? namespace;

  /// The execution context that produced this tool call.
  final ToolCallCaller? caller;

  /// Whether this call may finish after the model continues working.
  ///
  /// Omitted for calls whose execution mode was not supplied.
  final bool? async;

  /// Creates a [FunctionCallItem].
  const FunctionCallItem({
    this.id,
    this.agent,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
    this.namespace,
    this.caller,
    this.async,
  });

  /// Creates a [FunctionCallItem] from JSON.
  factory FunctionCallItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'function_call', 'FunctionCallItem');
    return FunctionCallItem(
      async: optionalJsonBool(json, 'async', 'FunctionCallItem'),
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: requireJsonString(json['call_id'], 'FunctionCallItem.call_id'),
      name: requireJsonString(json['name'], 'FunctionCallItem.name'),
      arguments: requireJsonString(
        json['arguments'],
        'FunctionCallItem.arguments',
      ),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      namespace: json['namespace'] as String?,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
    if (namespace != null) 'namespace': namespace,
    if (caller != null) 'caller': caller!.toJson(),
    if (async != null) 'async': async,
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  FunctionCallItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    String? name,
    String? arguments,
    Object? status = unsetCopyWithValue,
    Object? namespace = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => FunctionCallItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    status: status == unsetCopyWithValue ? this.status : status as ItemStatus?,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          status == other.status &&
          namespace == other.namespace &&
          caller == other.caller &&
          async == other.async;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    name,
    arguments,
    status,
    namespace,
    caller,
    async,
  );

  @override
  String toString() =>
      'FunctionCallItem(id: $id, agent: $agent, callId: $callId, name: $name, arguments: <redacted>, status: $status, namespace: $namespace, caller: $caller, async: $async)';
}

/// A custom tool call replayed as input to a response.
///
/// The application executes the tool and returns its result using the original
/// [callId]. An [async] call lets the model continue before that result arrives.
/// Output-only status and creator metadata do not belong to this input shape.
@immutable
class CustomToolCallInputItem extends Item {
  /// The fixed discriminator for this call item.
  String get type => 'custom_tool_call';

  /// Unique identifier, when this call has already been recorded.
  final String? id;

  /// The agent that produced this item on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The identifier used to match this call to its result.
  final String callId;

  /// The name of the custom tool.
  final String name;

  /// The tool input. Its format is defined by the application.
  final String input;

  /// The namespace containing the custom tool.
  final String? namespace;

  /// The execution context that produced the call.
  final ToolCallCaller? caller;

  /// Whether this call may finish after the model continues working.
  final bool? async;

  /// Creates a [CustomToolCallInputItem].
  const CustomToolCallInputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.name,
    required this.input,
    this.namespace,
    this.caller,
    this.async,
  });

  /// Creates a [CustomToolCallInputItem] from JSON.
  factory CustomToolCallInputItem.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'custom_tool_call', 'CustomToolCallInputItem');
    return CustomToolCallInputItem(
      id: optionalJsonString(json, 'id', 'CustomToolCallInputItem'),
      agent: json['agent'] != null
          ? AgentTag.fromJson(
              requireJsonObject(json['agent'], 'CustomToolCallInputItem.agent'),
            )
          : null,
      callId: requireJsonString(
        json['call_id'],
        'CustomToolCallInputItem.call_id',
      ),
      name: requireJsonString(json['name'], 'CustomToolCallInputItem.name'),
      input: requireJsonString(json['input'], 'CustomToolCallInputItem.input'),
      namespace: optionalJsonString(
        json,
        'namespace',
        'CustomToolCallInputItem',
      ),
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(
              requireJsonObject(
                json['caller'],
                'CustomToolCallInputItem.caller',
              ),
            )
          : null,
      async: optionalJsonBool(json, 'async', 'CustomToolCallInputItem'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'name': name,
    'input': input,
    if (namespace != null) 'namespace': namespace,
    if (caller != null) 'caller': caller!.toJson(),
    if (async != null) 'async': async,
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  CustomToolCallInputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    String? name,
    String? input,
    Object? namespace = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => CustomToolCallInputItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    callId: callId ?? this.callId,
    name: name ?? this.name,
    input: input ?? this.input,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ToolCallCaller?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolCallInputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          name == other.name &&
          input == other.input &&
          namespace == other.namespace &&
          caller == other.caller &&
          async == other.async;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, name, input, namespace, caller, async);

  @override
  String toString() =>
      'CustomToolCallInputItem(id: $id, agent: $agent, callId: $callId, '
      'name: $name, input: <redacted>, namespace: $namespace, '
      'caller: $caller, async: $async)';
}

/// The output of a function call.
///
/// Can be either a simple string or a list of content items.
sealed class FunctionCallOutput {
  /// Creates a [FunctionCallOutput].
  const FunctionCallOutput();

  /// Creates a [FunctionCallOutput] from JSON.
  factory FunctionCallOutput.fromJson(Object json) {
    if (json is String) {
      return FunctionCallOutputString(json);
    }
    if (json is List) {
      return FunctionCallOutputContent(
        json
            .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid FunctionCallOutput format: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// A string output from a function call.
@immutable
class FunctionCallOutputString extends FunctionCallOutput {
  /// The string output.
  final String value;

  /// Creates a [FunctionCallOutputString].
  const FunctionCallOutputString(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'FunctionCallOutputString($value)';
}

/// A list of content items output from a function call.
@immutable
class FunctionCallOutputContent extends FunctionCallOutput {
  /// The content items.
  final List<InputContent> content;

  /// Creates a [FunctionCallOutputContent].
  const FunctionCallOutputContent(this.content);

  @override
  Object toJson() => content.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputContent &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content);

  @override
  int get hashCode => Object.hashAll(content);

  @override
  String toString() => 'FunctionCallOutputContent($content)';
}

/// A function call output item.
@immutable
class FunctionCallOutputItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content.
  final FunctionCallOutput output;

  /// The status of the function call.
  final FunctionCallStatus? status;

  /// The execution context that produced the tool call this output responds
  /// to.
  final ToolCallCaller? caller;

  /// Creates a [FunctionCallOutputItem].
  const FunctionCallOutputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.output,
    this.status,
    this.caller,
  });

  /// Creates a [FunctionCallOutputItem] with a simple string output.
  factory FunctionCallOutputItem.string({
    String? id,
    AgentTag? agent,
    required String callId,
    required String output,
    FunctionCallStatus? status,
    ToolCallCaller? caller,
  }) {
    return FunctionCallOutputItem(
      id: id,
      agent: agent,
      callId: callId,
      output: FunctionCallOutputString(output),
      status: status,
      caller: caller,
    );
  }

  /// Creates a [FunctionCallOutputItem] from JSON.
  factory FunctionCallOutputItem.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      status: json['status'] != null
          ? FunctionCallStatus.fromJson(json['status'] as String)
          : null,
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call_output',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'output': output.toJson(),
    if (status != null) 'status': status!.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  FunctionCallOutputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    FunctionCallOutput? output,
    Object? status = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
  }) {
    return FunctionCallOutputItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
      callId: callId ?? this.callId,
      output: output ?? this.output,
      status: status == unsetCopyWithValue
          ? this.status
          : status as FunctionCallStatus?,
      caller: caller == unsetCopyWithValue
          ? this.caller
          : caller as ToolCallCaller?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          output == other.output &&
          status == other.status &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(id, agent, callId, output, status, caller);

  @override
  String toString() =>
      'FunctionCallOutputItem(id: $id, agent: $agent, callId: $callId, output: $output, status: $status, caller: $caller)';
}

/// Reference to a previously created item.
@immutable
class ItemReference extends Item {
  /// The ID of the referenced item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Creates an [ItemReference].
  const ItemReference({required this.id, this.agent});

  /// Creates an [ItemReference] from JSON.
  factory ItemReference.fromJson(Map<String, dynamic> json) {
    return ItemReference(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'item_reference',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemReference &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(id, agent);

  @override
  String toString() => 'ItemReference(id: $id, agent: $agent)';
}

/// Triggers compaction of the current context.
///
/// Compacts the current context. Must be the final input item in the list.
@immutable
class CompactionTriggerItem extends Item {
  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Creates a [CompactionTriggerItem].
  const CompactionTriggerItem({this.agent});

  /// Creates a [CompactionTriggerItem] from JSON.
  factory CompactionTriggerItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'compaction_trigger') {
      throw FormatException('Expected type "compaction_trigger", got "$type"');
    }
    return CompactionTriggerItem(
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction_trigger',
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionTriggerItem &&
          runtimeType == other.runtimeType &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(runtimeType, agent);

  @override
  String toString() => 'CompactionTriggerItem(agent: $agent)';
}

/// A custom tool call output input item.
@immutable
class CustomToolCallOutputInputItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output from the custom tool call.
  final FunctionCallOutput output;

  /// The execution context that produced the tool call this output responds
  /// to.
  final ToolCallCaller? caller;

  /// Creates a [CustomToolCallOutputInputItem].
  const CustomToolCallOutputInputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.output,
    this.caller,
  });

  /// Creates a [CustomToolCallOutputInputItem] with a simple string output.
  factory CustomToolCallOutputInputItem.string({
    String? id,
    AgentTag? agent,
    required String callId,
    required String output,
    ToolCallCaller? caller,
  }) {
    return CustomToolCallOutputInputItem(
      id: id,
      agent: agent,
      callId: callId,
      output: FunctionCallOutputString(output),
      caller: caller,
    );
  }

  /// Creates a [CustomToolCallOutputInputItem] from JSON.
  factory CustomToolCallOutputInputItem.fromJson(Map<String, dynamic> json) {
    return CustomToolCallOutputInputItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      caller: json['caller'] != null
          ? ToolCallCaller.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom_tool_call_output',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'output': output.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolCallOutputInputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          output == other.output &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(id, agent, callId, output, caller);

  @override
  String toString() =>
      'CustomToolCallOutputInputItem(id: $id, agent: $agent, callId: $callId, output: $output, caller: $caller)';
}

/// A tool search call input item.
@immutable
class ToolSearchCallItemParam extends Item {
  /// The fixed item discriminator.
  String get type => 'tool_search_call';

  /// Unique identifier.
  final String? id;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The search call identifier, when included in request history.
  final String? callId;

  /// The server or client execution type.
  final ToolSearchExecutionType? execution;

  /// Required object-shaped search arguments, including empty objects.
  final Map<String, dynamic> arguments;

  /// The item status.
  final ItemStatus? status;

  /// Creates a [ToolSearchCallItemParam].
  ///
  /// Const construction retains caller-owned collections. Do not mutate them
  /// while this value is used as a map key or set member. Parsed collections
  /// are recursively unmodifiable snapshots.
  const ToolSearchCallItemParam({
    this.id,
    this.agent,
    this.callId,
    this.execution,
    required this.arguments,
    this.status,
  });

  /// Creates a [ToolSearchCallItemParam] from contextual tool-search JSON.
  factory ToolSearchCallItemParam.fromJson(Map<String, dynamic> json) {
    const context = 'ToolSearchCallItemParam';
    requireJsonType(json, 'tool_search_call', context);
    return ToolSearchCallItemParam(
      id: optionalJsonString(json, 'id', context, nullable: true),
      agent: toolSearchJsonAgent(json, context, nullable: true),
      callId: optionalJsonString(json, 'call_id', context, nullable: true),
      execution: toolSearchOptionalExecution(json, context),
      arguments: toolSearchInputArguments(json, context),
      status: toolSearchOptionalStatus(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    if (execution != null) 'execution': execution!.toJson(),
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with nullable fields explicitly clearable.
  ToolSearchCallItemParam copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? callId = unsetCopyWithValue,
    Object? execution = unsetCopyWithValue,
    Map<String, dynamic>? arguments,
    Object? status = unsetCopyWithValue,
  }) => ToolSearchCallItemParam(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: identical(callId, unsetCopyWithValue)
        ? this.callId
        : callId as String?,
    execution: identical(execution, unsetCopyWithValue)
        ? this.execution
        : execution as ToolSearchExecutionType?,
    arguments: arguments ?? this.arguments,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchCallItemParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          mapsDeepEqual(arguments, other.arguments) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    mapDeepHashCode(arguments),
    status,
  );

  @override
  String toString() =>
      'ToolSearchCallItemParam(id: $id, agent: ${toolSearchActorSummary(agent?.agentName)}, callId: $callId, execution: $execution, arguments: ${toolSearchArgumentsSummary(arguments)}, status: $status)';
}

/// A tool search output input item.
@immutable
class ToolSearchOutputItemParam extends Item {
  /// The fixed item discriminator.
  String get type => 'tool_search_output';

  /// Unique identifier.
  final String? id;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The search call identifier, when included in request history.
  final String? callId;

  /// The server or client execution type.
  final ToolSearchExecutionType? execution;

  /// The complete discovered tool definitions, including empty results.
  final List<ResponseTool> tools;

  /// The item status.
  final ItemStatus? status;

  /// Creates a [ToolSearchOutputItemParam].
  ///
  /// Const construction retains caller-owned collections. Do not mutate them
  /// while this value is used as a map key or set member. Parsed collections
  /// are recursively unmodifiable snapshots.
  const ToolSearchOutputItemParam({
    this.id,
    this.agent,
    this.callId,
    this.execution,
    required this.tools,
    this.status,
  });

  /// Creates a [ToolSearchOutputItemParam] from contextual tool-search JSON.
  factory ToolSearchOutputItemParam.fromJson(Map<String, dynamic> json) {
    const context = 'ToolSearchOutputItemParam';
    requireJsonType(json, 'tool_search_output', context);
    return ToolSearchOutputItemParam(
      id: optionalJsonString(json, 'id', context, nullable: true),
      agent: toolSearchJsonAgent(json, context, nullable: true),
      callId: optionalJsonString(json, 'call_id', context, nullable: true),
      execution: toolSearchOptionalExecution(json, context),
      tools: toolSearchJsonTools(json['tools'], '$context.tools'),
      status: toolSearchOptionalStatus(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    if (callId != null) 'call_id': callId,
    if (execution != null) 'execution': execution!.toJson(),
    'tools': tools.map((tool) => tool.toToolSearchOutputJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with nullable fields explicitly clearable.
  ToolSearchOutputItemParam copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? callId = unsetCopyWithValue,
    Object? execution = unsetCopyWithValue,
    List<ResponseTool>? tools,
    Object? status = unsetCopyWithValue,
  }) => ToolSearchOutputItemParam(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: identical(callId, unsetCopyWithValue)
        ? this.callId
        : callId as String?,
    execution: identical(execution, unsetCopyWithValue)
        ? this.execution
        : execution as ToolSearchExecutionType?,
    tools: tools ?? this.tools,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchOutputItemParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          listsEqual(tools, other.tools) &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, execution, Object.hashAll(tools), status);

  @override
  String toString() =>
      'ToolSearchOutputItemParam(id: $id, agent: ${toolSearchActorSummary(agent?.agentName)}, callId: $callId, execution: $execution, tools: ${tools.length} items, status: $status)';
}

/// A tool search call returned by the Responses input-items resource.
@immutable
class ToolSearchCallResourceItem extends Item {
  /// The fixed item discriminator.
  String get type => 'tool_search_call';

  /// Unique identifier.
  final String id;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The search call identifier; returned items always serialize its key.
  final String? callId;

  /// The server or client execution type.
  final ToolSearchExecutionType execution;

  /// Search arguments. Returned arguments can be any JSON value.
  final Object? arguments;

  /// The item status.
  final ItemStatus status;

  /// The actor that created this item, when provided.
  final String? createdBy;

  /// Creates a [ToolSearchCallResourceItem].
  ///
  /// Const construction retains caller-owned collections. Do not mutate them
  /// while this value is used as a map key or set member. Parsed collections
  /// are recursively unmodifiable snapshots.
  const ToolSearchCallResourceItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.execution,
    required this.arguments,
    required this.status,
    this.createdBy,
  });

  /// Creates a [ToolSearchCallResourceItem] from contextual tool-search JSON.
  factory ToolSearchCallResourceItem.fromJson(Map<String, dynamic> json) {
    const context = 'ToolSearchCallResourceItem';
    requireJsonType(json, 'tool_search_call', context);
    return ToolSearchCallResourceItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: toolSearchJsonAgent(json, context),
      callId: toolSearchRequiredCallId(json, context),
      execution: ToolSearchExecutionType.fromJson(
        requireJsonString(json['execution'], '$context.execution'),
      ),
      arguments: toolSearchReturnedArguments(json, context),
      status: ItemStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'execution': execution.toJson(),
    'arguments': arguments,
    'status': status.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy with nullable fields explicitly clearable.
  ToolSearchCallResourceItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? callId = unsetCopyWithValue,
    ToolSearchExecutionType? execution,
    Object? arguments = unsetCopyWithValue,
    ItemStatus? status,
    Object? createdBy = unsetCopyWithValue,
  }) => ToolSearchCallResourceItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: identical(callId, unsetCopyWithValue)
        ? this.callId
        : callId as String?,
    execution: execution ?? this.execution,
    arguments: identical(arguments, unsetCopyWithValue)
        ? this.arguments
        : arguments,
    status: status ?? this.status,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  /// Converts a stored object-shaped search call to writable input.
  ///
  /// Arbitrary returned JSON requires raw replay via
  /// `ResponseInput.fromOutputItems`; it cannot become a typed request object.
  ToolSearchCallItemParam toToolSearchCallItemParam() {
    if (arguments is! Map) {
      throw StateError(
        'ToolSearchCallResourceItem.arguments: typed input requires an object',
      );
    }
    return ToolSearchCallItemParam(
      id: id,
      agent: agent,
      callId: callId,
      execution: execution,
      arguments: requireJsonObject(
        arguments,
        'ToolSearchCallResourceItem.arguments',
      ),
      status: status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchCallResourceItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          toolSearchArgumentsEqual(arguments, other.arguments) &&
          status == other.status &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    toolSearchArgumentsHash(arguments),
    status,
    createdBy,
  );

  @override
  String toString() =>
      'ToolSearchCallResourceItem(id: $id, agent: ${toolSearchActorSummary(agent?.agentName)}, callId: $callId, execution: $execution, arguments: ${toolSearchArgumentsSummary(arguments)}, status: $status, createdBy: ${toolSearchActorSummary(createdBy)})';
}

/// A tool search output returned by the Responses input-items resource.
@immutable
class ToolSearchOutputResourceItem extends Item {
  /// The fixed item discriminator.
  String get type => 'tool_search_output';

  /// Unique identifier.
  final String id;

  /// The producing agent on the beta multi-agent protocol.
  final AgentTag? agent;

  /// The search call identifier; returned items always serialize its key.
  final String? callId;

  /// The server or client execution type.
  final ToolSearchExecutionType execution;

  /// The complete discovered tool definitions, including empty results.
  final List<ResponseTool> tools;

  /// The item status.
  final FunctionCallOutputStatus status;

  /// The actor that created this item, when provided.
  final String? createdBy;

  /// Creates a [ToolSearchOutputResourceItem].
  ///
  /// Const construction retains caller-owned collections. Do not mutate them
  /// while this value is used as a map key or set member. Parsed collections
  /// are recursively unmodifiable snapshots.
  const ToolSearchOutputResourceItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.execution,
    required this.tools,
    required this.status,
    this.createdBy,
  });

  /// Creates a [ToolSearchOutputResourceItem] from contextual tool-search JSON.
  factory ToolSearchOutputResourceItem.fromJson(Map<String, dynamic> json) {
    const context = 'ToolSearchOutputResourceItem';
    requireJsonType(json, 'tool_search_output', context);
    return ToolSearchOutputResourceItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: toolSearchJsonAgent(json, context),
      callId: toolSearchRequiredCallId(json, context),
      execution: ToolSearchExecutionType.fromJson(
        requireJsonString(json['execution'], '$context.execution'),
      ),
      tools: toolSearchJsonTools(json['tools'], '$context.tools'),
      status: FunctionCallOutputStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'execution': execution.toJson(),
    'tools': tools.map((tool) => tool.toToolSearchOutputJson()).toList(),
    'status': status.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy with nullable fields explicitly clearable.
  ToolSearchOutputResourceItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    Object? callId = unsetCopyWithValue,
    ToolSearchExecutionType? execution,
    List<ResponseTool>? tools,
    FunctionCallOutputStatus? status,
    Object? createdBy = unsetCopyWithValue,
  }) => ToolSearchOutputResourceItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: identical(callId, unsetCopyWithValue)
        ? this.callId
        : callId as String?,
    execution: execution ?? this.execution,
    tools: tools ?? this.tools,
    status: status ?? this.status,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  /// Converts discovered tools to writable input, omitting creator metadata.
  ToolSearchOutputItemParam toToolSearchOutputItemParam() =>
      ToolSearchOutputItemParam(
        id: id,
        agent: agent,
        callId: callId,
        execution: execution,
        tools: tools,
        status: ItemStatus.fromJson(status.toJson()),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchOutputResourceItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          execution == other.execution &&
          listsEqual(tools, other.tools) &&
          status == other.status &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    execution,
    Object.hashAll(tools),
    status,
    createdBy,
  );

  @override
  String toString() =>
      'ToolSearchOutputResourceItem(id: $id, agent: ${toolSearchActorSummary(agent?.agentName)}, callId: $callId, execution: $execution, tools: ${tools.length} items, status: $status, createdBy: ${toolSearchActorSummary(createdBy)})';
}

/// An additional tools input item.
///
/// Makes a list of additional tool definitions available mid-conversation.
/// Only the `developer` role is supported.
@immutable
class AdditionalToolsItemParam extends Item {
  /// Unique identifier of this additional tools item.
  final String? id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// A list of additional tools made available at this item.
  final List<ResponseTool> tools;

  /// Creates an [AdditionalToolsItemParam].
  const AdditionalToolsItemParam({this.id, this.agent, required this.tools});

  /// Creates an [AdditionalToolsItemParam] from JSON.
  factory AdditionalToolsItemParam.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'additional_tools') {
      throw FormatException('Expected type "additional_tools", got "$type"');
    }
    // Only the `developer` role is supported (spec const). Reject other values
    // when present rather than silently normalizing them on re-serialization.
    final role = json['role'] as String?;
    if (role != null && role != 'developer') {
      throw FormatException(
        'Expected "additional_tools" role "developer", got "$role"',
      );
    }
    return AdditionalToolsItemParam(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      tools: (json['tools'] as List)
          .map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'additional_tools',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    // Only the `developer` role is supported for this item.
    'role': 'developer',
    'tools': tools.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalToolsItemParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(id, agent, Object.hashAll(tools));

  @override
  String toString() =>
      'AdditionalToolsItemParam(id: $id, agent: $agent, tools: $tools)';
}

/// Programmatic tool calling source code, as an input item.
///
/// Mirrors the `ProgramItemParam` schema.
@immutable
class ProgramItem extends Item {
  /// The unique ID of this program item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The stable call ID of the program item.
  final String callId;

  /// The JavaScript source executed by programmatic tool calling.
  final String code;

  /// Opaque program replay fingerprint that must be round-tripped.
  final String fingerprint;

  /// Creates a [ProgramItem].
  const ProgramItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.code,
    required this.fingerprint,
  });

  /// Creates a [ProgramItem] from JSON.
  factory ProgramItem.fromJson(Map<String, dynamic> json) {
    return ProgramItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      code: json['code'] as String,
      fingerprint: json['fingerprint'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'program',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'code': code,
    'fingerprint': fingerprint,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          code == other.code &&
          fingerprint == other.fingerprint;

  @override
  int get hashCode => Object.hash(id, agent, callId, code, fingerprint);

  @override
  String toString() =>
      'ProgramItem(id: $id, agent: $agent, callId: $callId, code: $code, fingerprint: $fingerprint)';
}

/// The result of a programmatic tool calling execution, as an input item.
///
/// Mirrors the `ProgramOutputItemParam` schema.
@immutable
class ProgramOutputItem extends Item {
  /// The unique ID of this program output item.
  final String id;

  /// The agent that produced this item.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The call ID of the program item.
  final String callId;

  /// The result produced by the program item.
  final String result;

  /// The terminal status of the program output.
  final ProgramOutputStatus status;

  /// Creates a [ProgramOutputItem].
  const ProgramOutputItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.result,
    required this.status,
  });

  /// Creates a [ProgramOutputItem] from JSON.
  factory ProgramOutputItem.fromJson(Map<String, dynamic> json) {
    return ProgramOutputItem(
      id: json['id'] as String,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      result: json['result'] as String,
      status: ProgramOutputStatus.fromJson(json['status'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'program_output',
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'result': result,
    'status': status.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          result == other.result &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, agent, callId, result, status);

  @override
  String toString() =>
      'ProgramOutputItem(id: $id, agent: $agent, callId: $callId, result: $result, status: $status)';
}

/// A message routed between agents, as an input item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaAgentMessageItemParam` schema.
@immutable
class AgentMessageItem extends Item {
  /// The unique ID of this agent message item.
  final String? id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The sending agent identity.
  final String author;

  /// The destination agent identity.
  final String recipient;

  /// Plaintext, image, or encrypted content sent between agents.
  final List<InputContent> content;

  /// Creates an [AgentMessageItem].
  const AgentMessageItem({
    this.id,
    this.agent,
    required this.author,
    required this.recipient,
    required this.content,
  });

  /// Creates an [AgentMessageItem] from JSON.
  factory AgentMessageItem.fromJson(Map<String, dynamic> json) {
    return AgentMessageItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      author: json['author'] as String,
      recipient: json['recipient'] as String,
      content: (json['content'] as List)
          .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'agent_message',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'author': author,
    'recipient': recipient,
    'content': content.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          author == other.author &&
          recipient == other.recipient &&
          listsEqual(content, other.content);

  @override
  int get hashCode =>
      Object.hash(id, agent, author, recipient, Object.hashAll(content));

  @override
  String toString() =>
      'AgentMessageItem(id: $id, agent: $agent, author: $author, recipient: $recipient, content: $content)';
}

/// A multi-agent action call, as an input item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaMultiAgentCallItemParam` schema.
@immutable
class MultiAgentCallItem extends Item {
  /// The unique ID of this multi-agent call.
  final String? id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The unique ID linking this call to its output.
  final String callId;

  /// The multi-agent action that was executed.
  final MultiAgentAction action;

  /// The action arguments as a JSON string.
  final String arguments;

  /// Creates a [MultiAgentCallItem].
  const MultiAgentCallItem({
    this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.arguments,
  });

  /// Creates a [MultiAgentCallItem] from JSON.
  factory MultiAgentCallItem.fromJson(Map<String, dynamic> json) {
    return MultiAgentCallItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: MultiAgentAction.fromJson(json['action'] as String),
      arguments: json['arguments'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'multi_agent_call',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentCallItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(id, agent, callId, action, arguments);

  @override
  String toString() =>
      'MultiAgentCallItem(id: $id, agent: $agent, callId: $callId, action: $action, arguments: $arguments)';
}

/// The output of a multi-agent action call, as an input item.
///
/// This belongs to the beta multi-agent protocol
/// (`OpenAI-Beta: responses_multi_agent=v1`). Mirrors the
/// `BetaMultiAgentCallOutputItemParam` schema.
@immutable
class MultiAgentCallOutputItem extends Item {
  /// The unique ID of this multi-agent call output.
  final String? id;

  /// The agent that produced this item.
  final AgentTag? agent;

  /// The unique ID of the multi-agent call.
  final String callId;

  /// The multi-agent action that produced this result.
  final MultiAgentAction action;

  /// Text output returned by the multi-agent action.
  final List<OutputTextContent> output;

  /// Creates a [MultiAgentCallOutputItem].
  const MultiAgentCallOutputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.output,
  });

  /// Creates a [MultiAgentCallOutputItem] from JSON.
  factory MultiAgentCallOutputItem.fromJson(Map<String, dynamic> json) {
    return MultiAgentCallOutputItem(
      id: json['id'] as String?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      callId: json['call_id'] as String,
      action: MultiAgentAction.fromJson(json['action'] as String),
      output: (json['output'] as List)
          .map((e) => OutputTextContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'multi_agent_call_output',
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'output': output.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiAgentCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          listsEqual(output, other.output);

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, action, Object.hashAll(output));

  @override
  String toString() =>
      'MultiAgentCallOutputItem(id: $id, agent: $agent, callId: $callId, action: $action, output: $output)';
}

/// A returned shell call with the exact resource contract.
@immutable
class ShellCallResourceItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call';

  /// Unique identifier.
  final String id;

  /// Optional beta agent metadata. Explicit JSON null is invalid.
  final AgentTag? agent;

  /// The shell call identifier.
  final String callId;

  /// Commands and execution limits returned by the service.
  final ShellCallAction action;

  /// The status of this shell item.
  final ItemStatus status;

  /// Returned environment. This required JSON key may be null.
  final ShellEnvironment? environment;

  /// Optional nullable execution context.
  final ToolCallCaller? caller;

  /// Optional creator identifier. Explicit JSON null is invalid.
  final String? createdBy;

  /// Creates a [ShellCallResourceItem].
  const ShellCallResourceItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.action,
    required this.status,
    required this.environment,
    this.caller,
    this.createdBy,
  });

  /// Creates a [ShellCallResourceItem] from JSON.
  factory ShellCallResourceItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallResourceItem';
    requireJsonType(json, 'shell_call', context);
    if (!json.containsKey('environment')) {
      throw const FormatException('$context.environment: required key missing');
    }
    return ShellCallResourceItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: shellJsonAgent(json, context, nullable: false),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      action: ShellCallAction.fromJson(
        requireJsonObject(json['action'], '$context.action'),
        context: '$context.action',
      ),
      status: ItemStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      environment: json['environment'] == null
          ? null
          : ShellEnvironment.fromJson(
              requireJsonObject(json['environment'], '$context.environment'),
              context: '$context.environment',
            ),
      caller: shellJsonCaller(json, context),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'action': action.toJson(),
    'status': status.toJson(),
    'environment': environment?.toJson(),
    if (caller != null) 'caller': caller!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallResourceItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ShellCallAction? action,
    ItemStatus? status,
    Object? environment = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallResourceItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    action: action ?? this.action,
    status: status ?? this.status,
    environment: identical(environment, unsetCopyWithValue)
        ? this.environment
        : environment as ShellEnvironment?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  /// Converts to writable input, omitting returned-only creator metadata.
  ShellCallInputItem toShellCallInputItem() => ShellCallInputItem(
    id: id,
    agent: agent,
    callId: callId,
    action: action.toInput(),
    status: status,
    environment: environment?.toInput(),
    caller: caller,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallResourceItem &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          status == other.status &&
          environment == other.environment &&
          caller == other.caller &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    action,
    status,
    environment,
    caller,
    createdBy,
  );

  @override
  String toString() =>
      'ShellCallResourceItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, action: $action, status: $status, environment: $environment, caller: ${caller == null ? 'null' : caller.runtimeType}, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
}

/// A returned shell result with the exact resource contract.
@immutable
class ShellCallOutputResourceItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call_output';

  /// Unique identifier.
  final String id;

  /// Optional beta agent metadata. Explicit JSON null is invalid.
  final AgentTag? agent;

  /// The shell call identifier.
  final String callId;

  /// The status of this shell item.
  final ItemStatus status;

  /// Returned output chunks. Constructor lists are caller-owned for const compatibility; parsed lists are unmodifiable.
  final List<ShellCallOutputContent> output;

  /// Output limit. This required JSON key may be null.
  final int? maxOutputLength;

  /// Optional nullable execution context.
  final ToolCallCaller? caller;

  /// Optional creator identifier. Explicit JSON null is invalid.
  final String? createdBy;

  /// Creates a [ShellCallOutputResourceItem].
  const ShellCallOutputResourceItem({
    required this.id,
    this.agent,
    required this.callId,
    required this.status,
    required this.output,
    required this.maxOutputLength,
    this.caller,
    this.createdBy,
  });

  /// Creates a [ShellCallOutputResourceItem] from JSON.
  factory ShellCallOutputResourceItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallOutputResourceItem';
    requireJsonType(json, 'shell_call_output', context);
    return ShellCallOutputResourceItem(
      id: requireJsonString(json['id'], '$context.id'),
      agent: shellJsonAgent(json, context, nullable: false),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      status: ItemStatus.fromJson(
        requireJsonString(json['status'], '$context.status'),
      ),
      output: shellJsonList(
        json['output'],
        '$context.output',
        (value, path) => ShellCallOutputContent.fromJson(
          requireJsonObject(value, path),
          context: path,
        ),
      ),
      maxOutputLength: shellRequiredNullableInt(
        json,
        'max_output_length',
        context,
      ),
      caller: shellJsonCaller(json, context),
      createdBy: optionalJsonString(json, 'created_by', context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    'status': status.toJson(),
    'output': output.map((chunk) => chunk.toJson()).toList(),
    'max_output_length': maxOutputLength,
    if (caller != null) 'caller': caller!.toJson(),
    if (createdBy != null) 'created_by': createdBy,
  };

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallOutputResourceItem copyWith({
    String? id,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ItemStatus? status,
    List<ShellCallOutputContent>? output,
    Object? maxOutputLength = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
  }) => ShellCallOutputResourceItem(
    id: id ?? this.id,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    status: status ?? this.status,
    output: output ?? this.output,
    maxOutputLength: identical(maxOutputLength, unsetCopyWithValue)
        ? this.maxOutputLength
        : maxOutputLength as int?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
    createdBy: identical(createdBy, unsetCopyWithValue)
        ? this.createdBy
        : createdBy as String?,
  );

  /// Converts to writable input, omitting returned-only creator metadata.
  ShellCallOutputInputItem toShellCallOutputInputItem() =>
      ShellCallOutputInputItem(
        id: id,
        agent: agent,
        callId: callId,
        status: status,
        output: List<ShellCallOutputContentInput>.unmodifiable(
          output.map((chunk) => chunk.toInput()),
        ),
        maxOutputLength: maxOutputLength,
        caller: caller,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputResourceItem &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          status == other.status &&
          listsEqual(output, other.output) &&
          maxOutputLength == other.maxOutputLength &&
          caller == other.caller &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    status,
    Object.hashAll(output),
    maxOutputLength,
    caller,
    createdBy,
  );

  @override
  String toString() =>
      'ShellCallOutputResourceItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, status: $status, output: ${output.length} chunks, maxOutputLength: $maxOutputLength, caller: ${caller == null ? 'null' : caller.runtimeType}, createdBy: ${createdBy == null ? 'null' : '[${createdBy!.length} chars]'})';
}

ShellToolEnvironment? _shellInputEnvironment(Object? value, String context) {
  if (value == null) return null;
  final json = requireJsonObject(value, context);
  final type = requireJsonString(json['type'], '$context.type');
  if (type == 'container_auto') {
    throw FormatException(
      '$context.type: container_auto is not permitted in call input',
    );
  }
  try {
    return ShellToolEnvironment.fromJson(json);
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}

/// Commands and optional nullable limits in a writable shell call.
@immutable
class ShellCallActionInput {
  /// An immutable snapshot of ordered commands.
  final List<String> commands;

  /// Optional nullable timeout in milliseconds; null normalizes to omission.
  final int? timeoutMs;

  /// Optional nullable maximum output length; null normalizes to omission.
  final int? maxOutputLength;

  /// Creates a [ShellCallActionInput], taking a command snapshot.
  ShellCallActionInput({
    required List<String> commands,
    this.timeoutMs,
    this.maxOutputLength,
  }) : commands = List<String>.unmodifiable(commands);

  /// Creates a [ShellCallActionInput] from JSON.
  factory ShellCallActionInput.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallActionInput',
  }) => ShellCallActionInput(
    commands: shellJsonList(
      json['commands'],
      '$context.commands',
      requireJsonString,
    ),
    timeoutMs: shellOptionalNullableInt(json, 'timeout_ms', context),
    maxOutputLength: shellOptionalNullableInt(
      json,
      'max_output_length',
      context,
    ),
  );

  /// Converts to JSON, omitting unset request limits.
  Map<String, dynamic> toJson() => {
    'commands': commands,
    if (timeoutMs != null) 'timeout_ms': timeoutMs,
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
  };

  /// Creates a copy; explicit null clears either limit.
  ShellCallActionInput copyWith({
    List<String>? commands,
    Object? timeoutMs = unsetCopyWithValue,
    Object? maxOutputLength = unsetCopyWithValue,
  }) => ShellCallActionInput(
    commands: commands ?? this.commands,
    timeoutMs: identical(timeoutMs, unsetCopyWithValue)
        ? this.timeoutMs
        : timeoutMs as int?,
    maxOutputLength: identical(maxOutputLength, unsetCopyWithValue)
        ? this.maxOutputLength
        : maxOutputLength as int?,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallActionInput &&
          listsEqual(commands, other.commands) &&
          timeoutMs == other.timeoutMs &&
          maxOutputLength == other.maxOutputLength;
  @override
  int get hashCode =>
      Object.hash(Object.hashAll(commands), timeoutMs, maxOutputLength);
  @override
  String toString() =>
      'ShellCallActionInput(commands: ${commands.length} commands, timeoutMs: $timeoutMs, maxOutputLength: $maxOutputLength)';
}

/// Writable stdout/stderr/outcome content; returned created_by is omitted.
@immutable
class ShellCallOutputContentInput {
  /// Captured standard output.
  final String stdout;

  /// Captured standard error.
  final String stderr;

  /// The exit or timeout outcome.
  final ShellCallOutcome outcome;

  /// Creates a [ShellCallOutputContentInput].
  const ShellCallOutputContentInput({
    required this.stdout,
    required this.stderr,
    required this.outcome,
  });

  /// Creates a [ShellCallOutputContentInput] from JSON.
  factory ShellCallOutputContentInput.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallOutputContentInput',
  }) => ShellCallOutputContentInput(
    stdout: requireJsonString(json['stdout'], '$context.stdout'),
    stderr: requireJsonString(json['stderr'], '$context.stderr'),
    outcome: ShellCallOutcome.fromJson(
      requireJsonObject(json['outcome'], '$context.outcome'),
      context: '$context.outcome',
    ),
  );

  /// Converts to JSON without read-only creator metadata.
  Map<String, dynamic> toJson() => {
    'stdout': stdout,
    'stderr': stderr,
    'outcome': outcome.toJson(),
  };

  /// Creates a copy with replacements.
  ShellCallOutputContentInput copyWith({
    String? stdout,
    String? stderr,
    ShellCallOutcome? outcome,
  }) => ShellCallOutputContentInput(
    stdout: stdout ?? this.stdout,
    stderr: stderr ?? this.stderr,
    outcome: outcome ?? this.outcome,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputContentInput &&
          stdout == other.stdout &&
          stderr == other.stderr &&
          outcome == other.outcome;
  @override
  int get hashCode => Object.hash(stdout, stderr, outcome);
  @override
  String toString() =>
      'ShellCallOutputContentInput(stdout: ${stdout.length} chars, stderr: ${stderr.length} chars, outcome: $outcome)';
}

/// Writable shell call history with the request parameter contract.
@immutable
class ShellCallInputItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call';

  /// Optional nullable id.
  final String? id;

  /// Optional nullable agent.
  final AgentTag? agent;

  /// Required call id.
  final String callId;

  /// Required action.
  final ShellCallActionInput action;

  /// Optional nullable status.
  final ItemStatus? status;

  /// Local/reference only. A container_auto definition cannot be replayed here.
  final ShellToolEnvironment? environment;

  /// Optional nullable caller.
  final ToolCallCaller? caller;

  /// Creates a [ShellCallInputItem].
  const ShellCallInputItem({
    this.id,
    this.agent,
    required this.callId,
    required this.action,
    this.status,
    this.environment,
    this.caller,
  });

  /// Creates a [ShellCallInputItem] from JSON.
  factory ShellCallInputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallInputItem';
    requireJsonType(json, 'shell_call', context);
    return ShellCallInputItem(
      id: optionalJsonString(json, 'id', context, nullable: true),
      agent: shellJsonAgent(json, context),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      action: ShellCallActionInput.fromJson(
        requireJsonObject(json['action'], '$context.action'),
        context: '$context.action',
      ),
      status: json['status'] == null
          ? null
          : ItemStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            ),
      environment: _shellInputEnvironment(
        json['environment'],
        '$context.environment',
      ),
      caller: shellJsonCaller(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final environmentJson = environment?.toJson();
    if (environmentJson?['type'] == 'container_auto') {
      throw ArgumentError.value(
        environment,
        'environment',
        'ShellCallInputItem accepts only local/reference environments',
      );
    }
    return {
      'type': type,
      if (id != null) 'id': id,
      if (agent != null) 'agent': agent!.toJson(),
      'call_id': callId,
      'action': action.toJson(),
      if (status != null) 'status': status!.toJson(),
      if (environment != null) 'environment': environmentJson,
      if (caller != null) 'caller': caller!.toJson(),
    };
  }

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallInputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    ShellCallActionInput? action,
    Object? status = unsetCopyWithValue,
    Object? environment = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
  }) => ShellCallInputItem(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    action: action ?? this.action,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
    environment: identical(environment, unsetCopyWithValue)
        ? this.environment
        : environment as ShellToolEnvironment?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallInputItem &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          action == other.action &&
          status == other.status &&
          environment == other.environment &&
          caller == other.caller;

  @override
  int get hashCode =>
      Object.hash(id, agent, callId, action, status, environment, caller);

  @override
  String toString() =>
      'ShellCallInputItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, action: $action, status: $status, environment: $environment, caller: ${caller == null ? 'null' : caller.runtimeType})';
}

/// Writable shell results with the request parameter contract.
@immutable
class ShellCallOutputInputItem extends Item {
  /// The fixed item discriminator.
  String get type => 'shell_call_output';

  /// Optional nullable id.
  final String? id;

  /// Optional nullable agent.
  final AgentTag? agent;

  /// Required call id.
  final String callId;

  /// Optional nullable status.
  final ItemStatus? status;

  /// Required output.
  final List<ShellCallOutputContentInput> output;

  /// Optional nullable max output length.
  final int? maxOutputLength;

  /// Optional nullable caller.
  final ToolCallCaller? caller;

  /// Creates a [ShellCallOutputInputItem].
  ShellCallOutputInputItem({
    this.id,
    this.agent,
    required this.callId,
    this.status,
    required List<ShellCallOutputContentInput> output,
    this.maxOutputLength,
    this.caller,
  }) : output = List<ShellCallOutputContentInput>.unmodifiable(output);

  /// Creates a [ShellCallOutputInputItem] from JSON.
  factory ShellCallOutputInputItem.fromJson(Map<String, dynamic> json) {
    const context = 'ShellCallOutputInputItem';
    requireJsonType(json, 'shell_call_output', context);
    return ShellCallOutputInputItem(
      id: optionalJsonString(json, 'id', context, nullable: true),
      agent: shellJsonAgent(json, context),
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      status: json['status'] == null
          ? null
          : ItemStatus.fromJson(
              requireJsonString(json['status'], '$context.status'),
            ),
      output: shellJsonList(
        json['output'],
        '$context.output',
        (value, path) => ShellCallOutputContentInput.fromJson(
          requireJsonObject(value, path),
          context: path,
        ),
      ),
      maxOutputLength: shellOptionalNullableInt(
        json,
        'max_output_length',
        context,
      ),
      caller: shellJsonCaller(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (agent != null) 'agent': agent!.toJson(),
    'call_id': callId,
    if (status != null) 'status': status!.toJson(),
    'output': output.map((chunk) => chunk.toJson()).toList(),
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
    if (caller != null) 'caller': caller!.toJson(),
  };

  /// Creates a copy; explicit null clears nullable metadata.
  ShellCallOutputInputItem copyWith({
    Object? id = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    String? callId,
    Object? status = unsetCopyWithValue,
    List<ShellCallOutputContentInput>? output,
    Object? maxOutputLength = unsetCopyWithValue,
    Object? caller = unsetCopyWithValue,
  }) => ShellCallOutputInputItem(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
    callId: callId ?? this.callId,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as ItemStatus?,
    output: output ?? this.output,
    maxOutputLength: identical(maxOutputLength, unsetCopyWithValue)
        ? this.maxOutputLength
        : maxOutputLength as int?,
    caller: identical(caller, unsetCopyWithValue)
        ? this.caller
        : caller as ToolCallCaller?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputInputItem &&
          id == other.id &&
          agent == other.agent &&
          callId == other.callId &&
          status == other.status &&
          listsEqual(output, other.output) &&
          maxOutputLength == other.maxOutputLength &&
          caller == other.caller;

  @override
  int get hashCode => Object.hash(
    id,
    agent,
    callId,
    status,
    Object.hashAll(output),
    maxOutputLength,
    caller,
  );

  @override
  String toString() =>
      'ShellCallOutputInputItem(id: $id, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'}, callId: $callId, status: $status, output: ${output.length} chunks, maxOutputLength: $maxOutputLength, caller: ${caller == null ? 'null' : caller.runtimeType})';
}
