import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../content/annotation.dart';
import '../content/logprob.dart';
import '../content/output_content.dart';
import '../items/output_item.dart';
import '../multi_agent/agent_tag.dart';
import '../response.dart';
import '../websocket/websocket_json_helpers.dart';
import 'shell_call_output_delta.dart';

/// A streaming event from the Responses API.
///
/// The Responses API emits a rich set of streaming events during response
/// generation. Events are categorized into:
///
/// - **Response lifecycle events**: created, queued, in_progress, completed, failed, incomplete
/// - **Output item events**: added, done
/// - **Content part events**: added, done
/// - **Text events**: delta, done, annotation added
/// - **Refusal events**: delta, done
/// - **Function call events**: arguments delta, arguments done
/// - **Reasoning events**: text delta, text done, summary events
/// - **Compaction events**: [ResponseCompactionCompactingEvent]
/// - **Audio events**: delta, done, transcript delta, transcript done
/// - **Web search events**: in_progress, searching, completed
/// - **File search events**: in_progress, searching, completed
/// - **Code interpreter events**: in_progress, interpreting, code delta, code done, completed
/// - **Shell events**: [ResponseShellCallCommandAddedEvent],
///   [ResponseShellCallCommandDeltaEvent], [ResponseShellCallCommandDoneEvent],
///   [ResponseShellCallOutputContentDeltaEvent], and
///   [ResponseShellCallOutputContentDoneEvent]
/// - **Image generation events**: in_progress, generating, partial_image, completed
/// - **MCP events**: call events, list tools events, arguments events
/// - **Custom tool events**: input delta, input done
/// - **Error events**: error details
/// - **Unknown events**: any unrecognized event type (e.g. `keepalive`)
sealed class ResponseStreamEvent {
  /// Creates a [ResponseStreamEvent].
  const ResponseStreamEvent();

  /// Creates a [ResponseStreamEvent] from JSON.
  factory ResponseStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = requireJsonString(json['type'], 'ResponseStreamEvent.type');
    return switch (type) {
      // Response lifecycle events
      'response.created' => ResponseCreatedEvent.fromJson(json),
      'response.queued' => ResponseQueuedEvent.fromJson(json),
      'response.in_progress' => ResponseInProgressEvent.fromJson(json),
      'response.completed' => ResponseCompletedEvent.fromJson(json),
      'response.failed' => ResponseFailedEvent.fromJson(json),
      'response.incomplete' => ResponseIncompleteEvent.fromJson(json),

      // Output item events
      'response.output_item.added' => OutputItemAddedEvent.fromJson(json),
      'response.output_item.done' => OutputItemDoneEvent.fromJson(json),

      // Content part events
      'response.content_part.added' => ContentPartAddedEvent.fromJson(json),
      'response.content_part.done' => ContentPartDoneEvent.fromJson(json),

      // Text events
      'response.output_text.delta' => OutputTextDeltaEvent.fromJson(json),
      'response.output_text.done' => OutputTextDoneEvent.fromJson(json),
      'response.output_text.annotation.added' =>
        OutputTextAnnotationAddedEvent.fromJson(json),

      // Refusal events
      'response.refusal.delta' => RefusalDeltaEvent.fromJson(json),
      'response.refusal.done' => RefusalDoneEvent.fromJson(json),

      // Function call events
      'response.function_call_arguments.delta' =>
        FunctionCallArgumentsDeltaEvent.fromJson(json),
      'response.function_call_arguments.done' =>
        FunctionCallArgumentsDoneEvent.fromJson(json),

      // Reasoning text events (note: type string is reasoning_text, not reasoning)
      'response.reasoning_text.delta' => ReasoningTextDeltaEvent.fromJson(json),
      'response.reasoning_text.done' => ReasoningTextDoneEvent.fromJson(json),

      // Reasoning summary events
      'response.reasoning_summary_part.added' =>
        ReasoningSummaryPartAddedEvent.fromJson(json),
      'response.reasoning_summary_part.done' =>
        ReasoningSummaryPartDoneEvent.fromJson(json),
      'response.reasoning_summary_text.delta' =>
        ReasoningSummaryTextDeltaEvent.fromJson(json),
      'response.reasoning_summary_text.done' =>
        ReasoningSummaryTextDoneEvent.fromJson(json),

      // Compaction events
      'response.compaction.compacting' =>
        ResponseCompactionCompactingEvent.fromJson(json),

      // Audio events
      'response.audio.delta' => ResponseAudioDeltaEvent.fromJson(json),
      'response.audio.done' => ResponseAudioDoneEvent.fromJson(json),
      'response.audio.transcript.delta' =>
        ResponseAudioTranscriptDeltaEvent.fromJson(json),
      'response.audio.transcript.done' =>
        ResponseAudioTranscriptDoneEvent.fromJson(json),

      // Web search events
      'response.web_search_call.in_progress' =>
        ResponseWebSearchCallInProgressEvent.fromJson(json),
      'response.web_search_call.searching' =>
        ResponseWebSearchCallSearchingEvent.fromJson(json),
      'response.web_search_call.completed' =>
        ResponseWebSearchCallCompletedEvent.fromJson(json),

      // File search events
      'response.file_search_call.in_progress' =>
        ResponseFileSearchCallInProgressEvent.fromJson(json),
      'response.file_search_call.searching' =>
        ResponseFileSearchCallSearchingEvent.fromJson(json),
      'response.file_search_call.completed' =>
        ResponseFileSearchCallCompletedEvent.fromJson(json),

      // Code interpreter events
      'response.code_interpreter_call.in_progress' =>
        ResponseCodeInterpreterCallInProgressEvent.fromJson(json),
      'response.code_interpreter_call.interpreting' =>
        ResponseCodeInterpreterCallInterpretingEvent.fromJson(json),
      'response.code_interpreter_call_code.delta' =>
        ResponseCodeInterpreterCallCodeDeltaEvent.fromJson(json),
      'response.code_interpreter_call_code.done' =>
        ResponseCodeInterpreterCallCodeDoneEvent.fromJson(json),
      'response.code_interpreter_call.completed' =>
        ResponseCodeInterpreterCallCompletedEvent.fromJson(json),

      // Shell events
      'response.shell_call_command.added' =>
        ResponseShellCallCommandAddedEvent.fromJson(json),
      'response.shell_call_command.delta' =>
        ResponseShellCallCommandDeltaEvent.fromJson(json),
      'response.shell_call_command.done' =>
        ResponseShellCallCommandDoneEvent.fromJson(json),
      'response.shell_call_output_content.delta' =>
        ResponseShellCallOutputContentDeltaEvent.fromJson(json),
      'response.shell_call_output_content.done' =>
        ResponseShellCallOutputContentDoneEvent.fromJson(json),

      // Image generation events
      'response.image_generation_call.in_progress' =>
        ResponseImageGenerationCallInProgressEvent.fromJson(json),
      'response.image_generation_call.generating' =>
        ResponseImageGenerationCallGeneratingEvent.fromJson(json),
      'response.image_generation_call.partial_image' =>
        ResponseImageGenerationCallPartialImageEvent.fromJson(json),
      'response.image_generation_call.completed' =>
        ResponseImageGenerationCallCompletedEvent.fromJson(json),

      // MCP events
      'response.mcp_call.in_progress' =>
        ResponseMcpCallInProgressEvent.fromJson(json),
      'response.mcp_call.completed' => ResponseMcpCallCompletedEvent.fromJson(
        json,
      ),
      'response.mcp_call.failed' => ResponseMcpCallFailedEvent.fromJson(json),
      'response.mcp_call_arguments.delta' =>
        ResponseMcpCallArgumentsDeltaEvent.fromJson(json),
      'response.mcp_call_arguments.done' =>
        ResponseMcpCallArgumentsDoneEvent.fromJson(json),
      'response.mcp_list_tools.in_progress' =>
        ResponseMcpListToolsInProgressEvent.fromJson(json),
      'response.mcp_list_tools.completed' =>
        ResponseMcpListToolsCompletedEvent.fromJson(json),
      'response.mcp_list_tools.failed' =>
        ResponseMcpListToolsFailedEvent.fromJson(json),

      // Custom tool events
      'response.custom_tool_call_input.delta' =>
        ResponseCustomToolCallInputDeltaEvent.fromJson(json),
      'response.custom_tool_call_input.done' =>
        ResponseCustomToolCallInputDoneEvent.fromJson(json),

      // Error events
      'error' => ErrorEvent.fromJson(json),

      _ => UnknownEvent.fromJson(json),
    };
  }

  /// The type of the event.
  String get type;

  /// The sequence number for ordering events.
  int? get sequenceNumber;

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  /// Whether this event signals the end of the stream.
  ///
  /// Returns `true` for [ResponseCompletedEvent], [ResponseFailedEvent],
  /// and [ResponseIncompleteEvent].
  bool get isFinal => false;
}

// ============================================================
// Compaction Events
// ============================================================

/// Event emitted when summary content is sampled for a compaction trigger.
///
/// This is a progress notification. It contains no summary or encrypted content
/// and does not signal the end of the response stream.
@immutable
class ResponseCompactionCompactingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.compaction.compacting';

  /// The sequence number for ordering events.
  @override
  final int sequenceNumber;

  /// The index of the compaction output item.
  final int outputIndex;

  /// The ID of the compaction output item.
  final String itemId;

  /// The beta multi-agent owner, when the event includes one.
  final AgentTag? agent;

  /// Creates a [ResponseCompactionCompactingEvent].
  const ResponseCompactionCompactingEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.itemId,
    this.agent,
  });

  /// Creates a [ResponseCompactionCompactingEvent] from JSON.
  factory ResponseCompactionCompactingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponseCompactionCompactingEvent';
    requireJsonType(json, 'response.compaction.compacting', context);
    return ResponseCompactionCompactingEvent(
      sequenceNumber: requireJsonInt(
        json['sequence_number'],
        '$context.sequence_number',
      ),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      itemId: requireJsonString(json['item_id'], '$context.item_id'),
      agent: _streamEventAgent(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'item_id': itemId,
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Passing `null` for [agent] removes that optional key.
  ResponseCompactionCompactingEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    String? itemId,
    Object? agent = unsetCopyWithValue,
  }) => ResponseCompactionCompactingEvent(
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    outputIndex: outputIndex ?? this.outputIndex,
    itemId: itemId ?? this.itemId,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompactionCompactingEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          itemId == other.itemId &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(sequenceNumber, outputIndex, itemId, agent);

  @override
  String toString() =>
      'ResponseCompactionCompactingEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, itemId: $itemId, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'})';
}

// ============================================================
// Response Lifecycle Events
// ============================================================

/// Event emitted when a response is created.
@immutable
class ResponseCreatedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.created';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The response that was created.
  final Response response;

  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({
    required this.response,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCreatedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(response, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCreatedEvent copyWith({
    Response? response,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCreatedEvent(
      response: response ?? this.response,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCreatedEvent(response: ${response.id}, agent: $agent)';
}

/// Event emitted when a response is queued for processing.
@immutable
class ResponseQueuedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.queued';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The response that was queued.
  final Response response;

  /// Creates a [ResponseQueuedEvent].
  const ResponseQueuedEvent({
    required this.response,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseQueuedEvent] from JSON.
  factory ResponseQueuedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseQueuedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseQueuedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(response, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseQueuedEvent copyWith({
    Response? response,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseQueuedEvent(
      response: response ?? this.response,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseQueuedEvent(response: ${response.id}, agent: $agent)';
}

/// Event emitted when a response is in progress.
@immutable
class ResponseInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The response that is in progress.
  final Response response;

  /// Creates a [ResponseInProgressEvent].
  const ResponseInProgressEvent({
    required this.response,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseInProgressEvent] from JSON.
  factory ResponseInProgressEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInProgressEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInProgressEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(response, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseInProgressEvent copyWith({
    Response? response,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseInProgressEvent(
      response: response ?? this.response,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseInProgressEvent(response: ${response.id}, agent: $agent)';
}

/// Event emitted when a response is completed.
@immutable
class ResponseCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The completed response.
  final Response response;

  /// Creates a [ResponseCompletedEvent].
  const ResponseCompletedEvent({
    required this.response,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCompletedEvent] from JSON.
  factory ResponseCompletedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCompletedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompletedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(response, sequenceNumber, agent);

  @override
  bool get isFinal => true;

  /// Creates a copy with replaced values.
  ResponseCompletedEvent copyWith({
    Response? response,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCompletedEvent(
      response: response ?? this.response,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCompletedEvent(response: ${response.id}, agent: $agent)';
}

/// Event emitted when a response fails.
@immutable
class ResponseFailedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.failed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The failed response.
  final Response response;

  /// Creates a [ResponseFailedEvent].
  const ResponseFailedEvent({
    required this.response,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseFailedEvent] from JSON.
  factory ResponseFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseFailedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFailedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(response, sequenceNumber, agent);

  @override
  bool get isFinal => true;

  /// Creates a copy with replaced values.
  ResponseFailedEvent copyWith({
    Response? response,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseFailedEvent(
      response: response ?? this.response,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() {
    final monitored =
        response.error?.misalignment != null ||
        response.error?.code == 'misalignment_policy_violation';
    return monitored
        ? 'ResponseFailedEvent(response: [REDACTED], '
              'sequenceNumber: $sequenceNumber, '
              'agent: ${responsesPresence(agent)})'
        : 'ResponseFailedEvent(response: ${response.id}, agent: $agent)';
  }
}

/// Event emitted when a response is incomplete.
@immutable
class ResponseIncompleteEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.incomplete';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The incomplete response.
  final Response response;

  /// Creates a [ResponseIncompleteEvent].
  const ResponseIncompleteEvent({
    required this.response,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseIncompleteEvent] from JSON.
  factory ResponseIncompleteEvent.fromJson(Map<String, dynamic> json) {
    return ResponseIncompleteEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseIncompleteEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(response, sequenceNumber, agent);

  @override
  bool get isFinal => true;

  /// Creates a copy with replaced values.
  ResponseIncompleteEvent copyWith({
    Response? response,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseIncompleteEvent(
      response: response ?? this.response,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseIncompleteEvent(response: ${response.id}, agent: $agent)';
}

// ============================================================
// Output Item Events
// ============================================================

/// Event emitted when an output item is added.
@immutable
class OutputItemAddedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_item.added';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The index of the output item.
  final int outputIndex;

  /// The added output item.
  final OutputItem item;

  /// Creates an [OutputItemAddedEvent].
  const OutputItemAddedEvent({
    required this.outputIndex,
    required this.item,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates an [OutputItemAddedEvent] from JSON.
  factory OutputItemAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemAddedEvent(
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'output_index': outputIndex,
    'item': item.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemAddedEvent &&
          runtimeType == other.runtimeType &&
          outputIndex == other.outputIndex &&
          item == other.item &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(outputIndex, item, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  OutputItemAddedEvent copyWith({
    int? outputIndex,
    OutputItem? item,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return OutputItemAddedEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      item: item ?? this.item,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'OutputItemAddedEvent(outputIndex: $outputIndex, agent: $agent)';
}

/// Event emitted when an output item is complete.
@immutable
class OutputItemDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_item.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The index of the output item.
  final int outputIndex;

  /// The completed output item.
  final OutputItem item;

  /// Creates an [OutputItemDoneEvent].
  const OutputItemDoneEvent({
    required this.outputIndex,
    required this.item,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates an [OutputItemDoneEvent] from JSON.
  factory OutputItemDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemDoneEvent(
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'output_index': outputIndex,
    'item': item.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemDoneEvent &&
          runtimeType == other.runtimeType &&
          outputIndex == other.outputIndex &&
          item == other.item &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(outputIndex, item, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  OutputItemDoneEvent copyWith({
    int? outputIndex,
    OutputItem? item,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return OutputItemDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      item: item ?? this.item,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'OutputItemDoneEvent(outputIndex: $outputIndex, agent: $agent)';
}

// ============================================================
// Content Part Events
// ============================================================

/// Event emitted when a content part is added.
@immutable
class ContentPartAddedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.content_part.added';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this content part.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The added content part.
  final OutputContent part;

  /// Creates a [ContentPartAddedEvent].
  const ContentPartAddedEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ContentPartAddedEvent] from JSON.
  factory ContentPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartAddedEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPartAddedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          part == other.part &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    part,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ContentPartAddedEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    OutputContent? part,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ContentPartAddedEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      part: part ?? this.part,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ContentPartAddedEvent(outputIndex: $outputIndex, contentIndex: $contentIndex, agent: $agent)';
}

/// Event emitted when a content part is complete.
@immutable
class ContentPartDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.content_part.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this content part.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The completed content part.
  final OutputContent part;

  /// Creates a [ContentPartDoneEvent].
  const ContentPartDoneEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ContentPartDoneEvent] from JSON.
  factory ContentPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPartDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          part == other.part &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    part,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ContentPartDoneEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    OutputContent? part,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ContentPartDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      part: part ?? this.part,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ContentPartDoneEvent(outputIndex: $outputIndex, contentIndex: $contentIndex, agent: $agent)';
}

// ============================================================
// Text Events
// ============================================================

/// Event emitted when text is generated (delta).
@immutable
class OutputTextDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_text.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this text.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The text delta.
  final String delta;

  /// Log probability information for the delta, if available.
  final List<LogProb>? logprobs;

  /// Creates an [OutputTextDeltaEvent].
  const OutputTextDeltaEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
    this.itemId,
    this.logprobs,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates an [OutputTextDeltaEvent] from JSON.
  factory OutputTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      logprobs: (json['logprobs'] as List?)
          ?.map((e) => LogProb.fromJson(e as Map<String, dynamic>))
          .toList(),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
    if (logprobs != null) 'logprobs': logprobs!.map((e) => e.toJson()).toList(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    delta,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  OutputTextDeltaEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    String? delta,
    Object? itemId = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return OutputTextDeltaEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      delta: delta ?? this.delta,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<LogProb>?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'OutputTextDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when text generation is complete.
@immutable
class OutputTextDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_text.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this text.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The complete text.
  final String text;

  /// Log probability information for the complete text, if available.
  final List<LogProb>? logprobs;

  /// Creates an [OutputTextDoneEvent].
  const OutputTextDoneEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.text,
    this.itemId,
    this.logprobs,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates an [OutputTextDoneEvent] from JSON.
  factory OutputTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
      logprobs: (json['logprobs'] as List?)
          ?.map((e) => LogProb.fromJson(e as Map<String, dynamic>))
          .toList(),
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'text': text,
    if (logprobs != null) 'logprobs': logprobs!.map((e) => e.toJson()).toList(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          text == other.text &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    text,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  OutputTextDoneEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    String? text,
    Object? itemId = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return OutputTextDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      text: text ?? this.text,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<LogProb>?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'OutputTextDoneEvent(text: ${text.length > 50 ? '${text.substring(0, 50)}...' : text}, agent: $agent)';
}

/// Event emitted when a text annotation is added.
@immutable
class OutputTextAnnotationAddedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_text.annotation.added';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this annotation.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The index of the annotation.
  final int annotationIndex;

  /// The annotation that was added, or null when the server supplies no object.
  ///
  /// The JSON key is required even when its value is null.
  final Annotation? annotation;

  /// Creates an [OutputTextAnnotationAddedEvent].
  const OutputTextAnnotationAddedEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.annotationIndex,
    required this.annotation,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates an [OutputTextAnnotationAddedEvent] from JSON.
  factory OutputTextAnnotationAddedEvent.fromJson(Map<String, dynamic> json) {
    const context = 'OutputTextAnnotationAddedEvent';
    requireJsonType(json, 'response.output_text.annotation.added', context);
    if (!json.containsKey('annotation')) {
      throw const FormatException(
        '$context.annotation: required nullable key is missing',
      );
    }
    Annotation? annotation;
    if (json['annotation'] != null) {
      try {
        annotation = Annotation.fromJson(
          requireJsonObject(json['annotation'], '$context.annotation'),
        );
      } on FormatException {
        throw const FormatException(
          '$context.annotation: malformed annotation',
        );
      } on TypeError {
        throw const FormatException(
          '$context.annotation: malformed annotation',
        );
      }
    }
    AgentTag? agent;
    if (json['agent'] != null) {
      final value = requireJsonObject(json['agent'], '$context.agent');
      agent = AgentTag(
        agentName: requireJsonString(
          value['agent_name'],
          '$context.agent.agent_name',
        ),
      );
    }
    return OutputTextAnnotationAddedEvent(
      itemId: optionalJsonString(json, 'item_id', context, nullable: true),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      contentIndex: requireJsonInt(
        json['content_index'],
        '$context.content_index',
      ),
      annotationIndex: requireJsonInt(
        json['annotation_index'],
        '$context.annotation_index',
      ),
      annotation: annotation,
      sequenceNumber: json['sequence_number'] == null
          ? null
          : requireJsonInt(json['sequence_number'], '$context.sequence_number'),
      agent: agent,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'annotation_index': annotationIndex,
    'annotation': annotation?.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextAnnotationAddedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          annotationIndex == other.annotationIndex &&
          annotation == other.annotation &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    annotationIndex,
    annotation,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values. Explicit null clears nullable fields;
  /// clearing [annotation] still emits its required nullable JSON key.
  OutputTextAnnotationAddedEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    int? annotationIndex,
    Object? annotation = unsetCopyWithValue,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return OutputTextAnnotationAddedEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      annotationIndex: annotationIndex ?? this.annotationIndex,
      annotation: identical(annotation, unsetCopyWithValue)
          ? this.annotation
          : annotation as Annotation?,
      itemId: identical(itemId, unsetCopyWithValue)
          ? this.itemId
          : itemId as String?,
      sequenceNumber: identical(sequenceNumber, unsetCopyWithValue)
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: identical(agent, unsetCopyWithValue)
          ? this.agent
          : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'OutputTextAnnotationAddedEvent(sequenceNumber: $sequenceNumber, '
      'itemId: ${itemId == null ? 'null' : '[REDACTED]'}, '
      'outputIndex: $outputIndex, contentIndex: $contentIndex, '
      'annotationIndex: $annotationIndex, '
      'annotation: ${annotation == null ? 'null' : '[REDACTED]'}, '
      'agent: ${agent == null ? 'null' : '[REDACTED]'})';
}

// ============================================================
// Refusal Events
// ============================================================

/// Event emitted when refusal content is generated (delta).
@immutable
class RefusalDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.refusal.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this refusal.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The refusal delta.
  final String delta;

  /// Creates a [RefusalDeltaEvent].
  const RefusalDeltaEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [RefusalDeltaEvent] from JSON.
  factory RefusalDeltaEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    delta,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  RefusalDeltaEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    String? delta,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return RefusalDeltaEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      delta: delta ?? this.delta,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'RefusalDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when refusal generation is complete.
@immutable
class RefusalDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.refusal.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this refusal.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The complete refusal.
  final String refusal;

  /// Creates a [RefusalDoneEvent].
  const RefusalDoneEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.refusal,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [RefusalDoneEvent] from JSON.
  factory RefusalDoneEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      refusal: json['refusal'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'refusal': refusal,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          refusal == other.refusal &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    refusal,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  RefusalDoneEvent copyWith({
    int? outputIndex,
    int? contentIndex,
    String? refusal,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return RefusalDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      refusal: refusal ?? this.refusal,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'RefusalDoneEvent(refusal: $refusal, agent: $agent)';
}

// ============================================================
// Function Call Events
// ============================================================

/// Event emitted when function call arguments are generated (delta).
@immutable
class FunctionCallArgumentsDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.function_call_arguments.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the function call item.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The arguments delta.
  final String delta;

  /// Creates a [FunctionCallArgumentsDeltaEvent].
  const FunctionCallArgumentsDeltaEvent({
    required this.outputIndex,
    required this.delta,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [FunctionCallArgumentsDeltaEvent] from JSON.
  factory FunctionCallArgumentsDeltaEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, delta, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  FunctionCallArgumentsDeltaEvent copyWith({
    int? outputIndex,
    String? delta,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return FunctionCallArgumentsDeltaEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      delta: delta ?? this.delta,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'FunctionCallArgumentsDeltaEvent(itemId: $itemId, delta: $delta, agent: $agent)';
}

/// Event emitted when function call arguments are complete.
@immutable
class FunctionCallArgumentsDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.function_call_arguments.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the function call item.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The name of the function being called.
  final String? name;

  /// The complete arguments.
  final String arguments;

  /// Creates a [FunctionCallArgumentsDoneEvent].
  const FunctionCallArgumentsDoneEvent({
    required this.outputIndex,
    required this.arguments,
    this.itemId,
    this.name,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [FunctionCallArgumentsDoneEvent] from JSON.
  factory FunctionCallArgumentsDoneEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      name: json['name'] as String?,
      arguments: json['arguments'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    if (name != null) 'name': name,
    'arguments': arguments,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          name == other.name &&
          arguments == other.arguments &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, name, arguments, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  FunctionCallArgumentsDoneEvent copyWith({
    int? outputIndex,
    String? arguments,
    Object? itemId = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return FunctionCallArgumentsDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      arguments: arguments ?? this.arguments,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'FunctionCallArgumentsDoneEvent(itemId: $itemId, name: $name, arguments: $arguments, agent: $agent)';
}

// ============================================================
// Reasoning Text Events
// ============================================================

/// Event emitted when reasoning text is generated (delta).
///
/// Note: The API type string is `response.reasoning_text.delta`.
@immutable
class ReasoningTextDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_text.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this reasoning.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part within the reasoning.
  final int? contentIndex;

  /// The reasoning delta.
  final String delta;

  /// Creates a [ReasoningTextDeltaEvent].
  const ReasoningTextDeltaEvent({
    required this.outputIndex,
    required this.delta,
    this.itemId,
    this.contentIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ReasoningTextDeltaEvent] from JSON.
  factory ReasoningTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningTextDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int?,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    if (contentIndex != null) 'content_index': contentIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    delta,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ReasoningTextDeltaEvent copyWith({
    int? outputIndex,
    String? delta,
    Object? itemId = unsetCopyWithValue,
    Object? contentIndex = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ReasoningTextDeltaEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      delta: delta ?? this.delta,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      contentIndex: contentIndex == unsetCopyWithValue
          ? this.contentIndex
          : contentIndex as int?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'ReasoningTextDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when reasoning text is complete.
///
/// Note: The API type string is `response.reasoning_text.done`.
@immutable
class ReasoningTextDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_text.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this reasoning.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part within the reasoning.
  final int? contentIndex;

  /// The complete reasoning text.
  final String text;

  /// Creates a [ReasoningTextDoneEvent].
  const ReasoningTextDoneEvent({
    required this.outputIndex,
    required this.text,
    this.itemId,
    this.contentIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ReasoningTextDoneEvent] from JSON.
  factory ReasoningTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningTextDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int?,
      text: json['text'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    if (contentIndex != null) 'content_index': contentIndex,
    'text': text,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningTextDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          text == other.text &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    text,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ReasoningTextDoneEvent copyWith({
    int? outputIndex,
    String? text,
    Object? itemId = unsetCopyWithValue,
    Object? contentIndex = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ReasoningTextDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      text: text ?? this.text,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      contentIndex: contentIndex == unsetCopyWithValue
          ? this.contentIndex
          : contentIndex as int?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'ReasoningTextDoneEvent(text: $text, agent: $agent)';
}

// Deprecated aliases for migration
/// Use [ReasoningTextDeltaEvent] instead.
@Deprecated('Use ReasoningTextDeltaEvent instead')
typedef ReasoningDeltaEvent = ReasoningTextDeltaEvent;

/// Use [ReasoningTextDoneEvent] instead.
@Deprecated('Use ReasoningTextDoneEvent instead')
typedef ReasoningDoneEvent = ReasoningTextDoneEvent;

// ============================================================
// Reasoning Summary Events
// ============================================================

/// Event emitted when a reasoning summary part is added.
@immutable
class ReasoningSummaryPartAddedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_part.added';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this reasoning summary.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the summary part.
  final int summaryIndex;

  /// The summary part.
  final Map<String, dynamic> part;

  /// Creates a [ReasoningSummaryPartAddedEvent].
  const ReasoningSummaryPartAddedEvent({
    required this.outputIndex,
    required this.summaryIndex,
    required this.part,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ReasoningSummaryPartAddedEvent] from JSON.
  factory ReasoningSummaryPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartAddedEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      part: json['part'] as Map<String, dynamic>,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    'part': part,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartAddedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    summaryIndex,
    part,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ReasoningSummaryPartAddedEvent copyWith({
    int? outputIndex,
    int? summaryIndex,
    Map<String, dynamic>? part,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ReasoningSummaryPartAddedEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      summaryIndex: summaryIndex ?? this.summaryIndex,
      part: part ?? this.part,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ReasoningSummaryPartAddedEvent(outputIndex: $outputIndex, summaryIndex: $summaryIndex, agent: $agent)';
}

/// Event emitted when a reasoning summary part is complete.
@immutable
class ReasoningSummaryPartDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_part.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this reasoning summary.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the summary part.
  final int summaryIndex;

  /// The summary part.
  final Map<String, dynamic> part;

  /// The completion status of the summary part.
  ///
  /// Omitted when the part completed normally and set to `incomplete` when
  /// generation was interrupted.
  final ReasoningSummaryPartStatus? status;

  /// Creates a [ReasoningSummaryPartDoneEvent].
  const ReasoningSummaryPartDoneEvent({
    required this.outputIndex,
    required this.summaryIndex,
    required this.part,
    this.itemId,
    this.sequenceNumber,
    this.status,
    this.agent,
  });

  /// Creates a [ReasoningSummaryPartDoneEvent] from JSON.
  factory ReasoningSummaryPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      part: json['part'] as Map<String, dynamic>,
      sequenceNumber: json['sequence_number'] as int?,
      status: json['status'] != null
          ? ReasoningSummaryPartStatus.fromJson(json['status'] as String)
          : null,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    'part': part,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (status != null) 'status': status!.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          mapsEqual(part, other.part) &&
          sequenceNumber == other.sequenceNumber &&
          status == other.status &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    summaryIndex,
    mapHash(part),
    sequenceNumber,
    status,
    agent,
  );

  /// Creates a copy with replaced values.
  ReasoningSummaryPartDoneEvent copyWith({
    int? outputIndex,
    int? summaryIndex,
    Map<String, dynamic>? part,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ReasoningSummaryPartDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      summaryIndex: summaryIndex ?? this.summaryIndex,
      part: part ?? this.part,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as ReasoningSummaryPartStatus?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ReasoningSummaryPartDoneEvent(outputIndex: $outputIndex, summaryIndex: $summaryIndex, status: $status, agent: $agent)';
}

/// The completion status of a reasoning summary part.
enum ReasoningSummaryPartStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Generation was interrupted before the summary part completed normally.
  incomplete('incomplete');

  /// The JSON value for this status.
  final String value;

  const ReasoningSummaryPartStatus(this.value);

  /// Creates a [ReasoningSummaryPartStatus] from a JSON value.
  factory ReasoningSummaryPartStatus.fromJson(String json) {
    return ReasoningSummaryPartStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ReasoningSummaryPartStatus.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// Event emitted when reasoning summary text is generated (delta).
@immutable
class ReasoningSummaryTextDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_text.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this reasoning summary.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the summary part.
  final int summaryIndex;

  /// The text delta.
  final String delta;

  /// Creates a [ReasoningSummaryTextDeltaEvent].
  const ReasoningSummaryTextDeltaEvent({
    required this.outputIndex,
    required this.summaryIndex,
    required this.delta,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ReasoningSummaryTextDeltaEvent] from JSON.
  factory ReasoningSummaryTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryTextDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    summaryIndex,
    delta,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ReasoningSummaryTextDeltaEvent copyWith({
    int? outputIndex,
    int? summaryIndex,
    String? delta,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ReasoningSummaryTextDeltaEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      summaryIndex: summaryIndex ?? this.summaryIndex,
      delta: delta ?? this.delta,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ReasoningSummaryTextDeltaEvent(outputIndex: $outputIndex, delta: $delta, agent: $agent)';
}

/// Event emitted when reasoning summary text is complete.
@immutable
class ReasoningSummaryTextDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_text.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the item containing this reasoning summary.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the summary part.
  final int summaryIndex;

  /// The complete text.
  final String text;

  /// Creates a [ReasoningSummaryTextDoneEvent].
  const ReasoningSummaryTextDoneEvent({
    required this.outputIndex,
    required this.summaryIndex,
    required this.text,
    this.itemId,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ReasoningSummaryTextDoneEvent] from JSON.
  factory ReasoningSummaryTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryTextDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      text: json['text'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    'text': text,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryTextDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          text == other.text &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    summaryIndex,
    text,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ReasoningSummaryTextDoneEvent copyWith({
    int? outputIndex,
    int? summaryIndex,
    String? text,
    Object? itemId = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ReasoningSummaryTextDoneEvent(
      outputIndex: outputIndex ?? this.outputIndex,
      summaryIndex: summaryIndex ?? this.summaryIndex,
      text: text ?? this.text,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ReasoningSummaryTextDoneEvent(outputIndex: $outputIndex, text: $text, agent: $agent)';
}

// ============================================================
// Audio Events
// ============================================================

/// Event emitted when audio content is generated (delta).
@immutable
class ResponseAudioDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The base64-encoded audio delta.
  final String delta;

  /// Creates a [ResponseAudioDeltaEvent].
  const ResponseAudioDeltaEvent({
    required this.delta,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseAudioDeltaEvent] from JSON.
  factory ResponseAudioDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioDeltaEvent(
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(delta, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseAudioDeltaEvent copyWith({
    String? delta,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseAudioDeltaEvent(
      delta: delta ?? this.delta,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseAudioDeltaEvent(deltaLength: ${delta.length}, agent: $agent)';
}

/// Event emitted when audio generation is complete.
@immutable
class ResponseAudioDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Creates a [ResponseAudioDoneEvent].
  const ResponseAudioDoneEvent({this.sequenceNumber, this.agent});

  /// Creates a [ResponseAudioDoneEvent] from JSON.
  factory ResponseAudioDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioDoneEvent(
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseAudioDoneEvent copyWith({
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseAudioDoneEvent(
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'ResponseAudioDoneEvent(agent: $agent)';
}

/// Event emitted when audio transcript is generated (delta).
@immutable
class ResponseAudioTranscriptDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.transcript.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The transcript delta.
  final String delta;

  /// Creates a [ResponseAudioTranscriptDeltaEvent].
  const ResponseAudioTranscriptDeltaEvent({
    required this.delta,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseAudioTranscriptDeltaEvent] from JSON.
  factory ResponseAudioTranscriptDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseAudioTranscriptDeltaEvent(
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioTranscriptDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(delta, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseAudioTranscriptDeltaEvent copyWith({
    String? delta,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseAudioTranscriptDeltaEvent(
      delta: delta ?? this.delta,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseAudioTranscriptDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when audio transcript is complete.
@immutable
class ResponseAudioTranscriptDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.transcript.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// Creates a [ResponseAudioTranscriptDoneEvent].
  const ResponseAudioTranscriptDoneEvent({this.sequenceNumber, this.agent});

  /// Creates a [ResponseAudioTranscriptDoneEvent] from JSON.
  factory ResponseAudioTranscriptDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioTranscriptDoneEvent(
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioTranscriptDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseAudioTranscriptDoneEvent copyWith({
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseAudioTranscriptDoneEvent(
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() => 'ResponseAudioTranscriptDoneEvent(agent: $agent)';
}

// ============================================================
// Web Search Events
// ============================================================

/// Event emitted when a web search call is in progress.
@immutable
class ResponseWebSearchCallInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.web_search_call.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the web search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseWebSearchCallInProgressEvent].
  const ResponseWebSearchCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseWebSearchCallInProgressEvent] from JSON.
  factory ResponseWebSearchCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseWebSearchCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseWebSearchCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseWebSearchCallInProgressEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseWebSearchCallInProgressEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseWebSearchCallInProgressEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when a web search call is searching.
@immutable
class ResponseWebSearchCallSearchingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.web_search_call.searching';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the web search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseWebSearchCallSearchingEvent].
  const ResponseWebSearchCallSearchingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseWebSearchCallSearchingEvent] from JSON.
  factory ResponseWebSearchCallSearchingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseWebSearchCallSearchingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseWebSearchCallSearchingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseWebSearchCallSearchingEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseWebSearchCallSearchingEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseWebSearchCallSearchingEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when a web search call is completed.
@immutable
class ResponseWebSearchCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.web_search_call.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the web search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseWebSearchCallCompletedEvent].
  const ResponseWebSearchCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseWebSearchCallCompletedEvent] from JSON.
  factory ResponseWebSearchCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseWebSearchCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseWebSearchCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseWebSearchCallCompletedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseWebSearchCallCompletedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseWebSearchCallCompletedEvent(itemId: $itemId, agent: $agent)';
}

// ============================================================
// File Search Events
// ============================================================

/// Event emitted when a file search call is in progress.
@immutable
class ResponseFileSearchCallInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.file_search_call.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the file search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseFileSearchCallInProgressEvent].
  const ResponseFileSearchCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseFileSearchCallInProgressEvent] from JSON.
  factory ResponseFileSearchCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFileSearchCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileSearchCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseFileSearchCallInProgressEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseFileSearchCallInProgressEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseFileSearchCallInProgressEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when a file search call is searching.
@immutable
class ResponseFileSearchCallSearchingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.file_search_call.searching';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the file search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseFileSearchCallSearchingEvent].
  const ResponseFileSearchCallSearchingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseFileSearchCallSearchingEvent] from JSON.
  factory ResponseFileSearchCallSearchingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFileSearchCallSearchingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileSearchCallSearchingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseFileSearchCallSearchingEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseFileSearchCallSearchingEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseFileSearchCallSearchingEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when a file search call is completed.
@immutable
class ResponseFileSearchCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.file_search_call.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the file search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseFileSearchCallCompletedEvent].
  const ResponseFileSearchCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseFileSearchCallCompletedEvent] from JSON.
  factory ResponseFileSearchCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFileSearchCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileSearchCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseFileSearchCallCompletedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseFileSearchCallCompletedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseFileSearchCallCompletedEvent(itemId: $itemId, agent: $agent)';
}

// ============================================================
// Code Interpreter Events
// ============================================================

/// Event emitted when a code interpreter call is in progress.
@immutable
class ResponseCodeInterpreterCallInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseCodeInterpreterCallInProgressEvent].
  const ResponseCodeInterpreterCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCodeInterpreterCallInProgressEvent] from JSON.
  factory ResponseCodeInterpreterCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCodeInterpreterCallInProgressEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCodeInterpreterCallInProgressEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCodeInterpreterCallInProgressEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when a code interpreter call is interpreting.
@immutable
class ResponseCodeInterpreterCallInterpretingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call.interpreting';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseCodeInterpreterCallInterpretingEvent].
  const ResponseCodeInterpreterCallInterpretingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCodeInterpreterCallInterpretingEvent] from JSON.
  factory ResponseCodeInterpreterCallInterpretingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallInterpretingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallInterpretingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCodeInterpreterCallInterpretingEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCodeInterpreterCallInterpretingEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCodeInterpreterCallInterpretingEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when code interpreter code is generated (delta).
@immutable
class ResponseCodeInterpreterCallCodeDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call_code.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The code delta.
  final String delta;

  /// Creates a [ResponseCodeInterpreterCallCodeDeltaEvent].
  const ResponseCodeInterpreterCallCodeDeltaEvent({
    required this.itemId,
    required this.outputIndex,
    required this.delta,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCodeInterpreterCallCodeDeltaEvent] from JSON.
  factory ResponseCodeInterpreterCallCodeDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallCodeDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallCodeDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, delta, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCodeInterpreterCallCodeDeltaEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? delta,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCodeInterpreterCallCodeDeltaEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      delta: delta ?? this.delta,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCodeInterpreterCallCodeDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when code interpreter code generation is complete.
@immutable
class ResponseCodeInterpreterCallCodeDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call_code.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The complete code.
  final String code;

  /// Creates a [ResponseCodeInterpreterCallCodeDoneEvent].
  const ResponseCodeInterpreterCallCodeDoneEvent({
    required this.itemId,
    required this.outputIndex,
    required this.code,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCodeInterpreterCallCodeDoneEvent] from JSON.
  factory ResponseCodeInterpreterCallCodeDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallCodeDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      code: json['code'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'code': code,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallCodeDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          code == other.code &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, code, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCodeInterpreterCallCodeDoneEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? code,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCodeInterpreterCallCodeDoneEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      code: code ?? this.code,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCodeInterpreterCallCodeDoneEvent(codeLength: ${code.length}, agent: $agent)';
}

/// Event emitted when a code interpreter call is completed.
@immutable
class ResponseCodeInterpreterCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseCodeInterpreterCallCompletedEvent].
  const ResponseCodeInterpreterCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCodeInterpreterCallCompletedEvent] from JSON.
  factory ResponseCodeInterpreterCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCodeInterpreterCallCompletedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCodeInterpreterCallCompletedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCodeInterpreterCallCompletedEvent(itemId: $itemId, agent: $agent)';
}

// ============================================================
// Shell Events
// ============================================================

AgentTag? _streamEventAgent(Map<String, dynamic> json, String context) {
  if (!json.containsKey('agent')) return null;
  final value = requireJsonObject(json['agent'], '$context.agent');
  return AgentTag(
    agentName: requireJsonString(
      value['agent_name'],
      '$context.agent.agent_name',
    ),
  );
}

/// Event emitted when a shell command is added.
@immutable
class ResponseShellCallCommandAddedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.shell_call_command.added';

  /// The sequence number for ordering events.
  @override
  final int sequenceNumber;

  /// The index of the shell call output item.
  final int outputIndex;

  /// The index of the shell command within the call.
  final int commandIndex;

  /// The generated shell command. This event does not execute it.
  final String command;

  /// The beta multi-agent owner, when the event includes one.
  final AgentTag? agent;

  /// Creates a [ResponseShellCallCommandAddedEvent].
  const ResponseShellCallCommandAddedEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.commandIndex,
    required this.command,
    this.agent,
  });

  /// Creates a [ResponseShellCallCommandAddedEvent] from JSON.
  factory ResponseShellCallCommandAddedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponseShellCallCommandAddedEvent';
    requireJsonType(json, 'response.shell_call_command.added', context);
    return ResponseShellCallCommandAddedEvent(
      sequenceNumber: requireJsonInt(
        json['sequence_number'],
        '$context.sequence_number',
      ),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      commandIndex: requireJsonInt(
        json['command_index'],
        '$context.command_index',
      ),
      command: requireJsonString(json['command'], '$context.command'),
      agent: _streamEventAgent(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'command_index': commandIndex,
    'command': command,
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Passing `null` for [agent] removes that optional key.
  ResponseShellCallCommandAddedEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    int? commandIndex,
    String? command,
    Object? agent = unsetCopyWithValue,
  }) => ResponseShellCallCommandAddedEvent(
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    outputIndex: outputIndex ?? this.outputIndex,
    commandIndex: commandIndex ?? this.commandIndex,
    command: command ?? this.command,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseShellCallCommandAddedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          commandIndex == other.commandIndex &&
          command == other.command &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, outputIndex, commandIndex, command, agent);

  @override
  String toString() =>
      'ResponseShellCallCommandAddedEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, commandIndex: $commandIndex, command: [${command.length} chars], agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'})';
}

/// Event emitted when a shell command receives a text fragment.
@immutable
class ResponseShellCallCommandDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.shell_call_command.delta';

  /// The sequence number for ordering events.
  @override
  final int sequenceNumber;

  /// The index of the shell call output item.
  final int outputIndex;

  /// The index of the shell command within the call.
  final int commandIndex;

  /// The shell command fragment, which may be empty.
  final String delta;

  /// Opaque padding metadata; it is not part of the shell command.
  final String? obfuscation;

  /// The beta multi-agent owner, when the event includes one.
  final AgentTag? agent;

  /// Creates a [ResponseShellCallCommandDeltaEvent].
  const ResponseShellCallCommandDeltaEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.commandIndex,
    required this.delta,
    this.obfuscation,
    this.agent,
  });

  /// Creates a [ResponseShellCallCommandDeltaEvent] from JSON.
  factory ResponseShellCallCommandDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponseShellCallCommandDeltaEvent';
    requireJsonType(json, 'response.shell_call_command.delta', context);
    return ResponseShellCallCommandDeltaEvent(
      sequenceNumber: requireJsonInt(
        json['sequence_number'],
        '$context.sequence_number',
      ),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      commandIndex: requireJsonInt(
        json['command_index'],
        '$context.command_index',
      ),
      delta: requireJsonString(json['delta'], '$context.delta'),
      obfuscation: optionalJsonString(json, 'obfuscation', context),
      agent: _streamEventAgent(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'command_index': commandIndex,
    'delta': delta,
    if (obfuscation != null) 'obfuscation': obfuscation,
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Passing `null` for [obfuscation] or [agent] removes that optional key.
  ResponseShellCallCommandDeltaEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    int? commandIndex,
    String? delta,
    Object? obfuscation = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) => ResponseShellCallCommandDeltaEvent(
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    outputIndex: outputIndex ?? this.outputIndex,
    commandIndex: commandIndex ?? this.commandIndex,
    delta: delta ?? this.delta,
    obfuscation: identical(obfuscation, unsetCopyWithValue)
        ? this.obfuscation
        : obfuscation as String?,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseShellCallCommandDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          commandIndex == other.commandIndex &&
          delta == other.delta &&
          obfuscation == other.obfuscation &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    outputIndex,
    commandIndex,
    delta,
    obfuscation,
    agent,
  );

  @override
  String toString() =>
      'ResponseShellCallCommandDeltaEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, commandIndex: $commandIndex, delta: [${delta.length} chars], obfuscation: ${obfuscation == null ? 'null' : '[${obfuscation!.length} chars]'}, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'})';
}

/// Event emitted when a shell command has been fully generated.
@immutable
class ResponseShellCallCommandDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.shell_call_command.done';

  /// The sequence number for ordering events.
  @override
  final int sequenceNumber;

  /// The index of the shell call output item.
  final int outputIndex;

  /// The index of the shell command within the call.
  final int commandIndex;

  /// The generated shell command. This event does not execute it.
  final String command;

  /// The beta multi-agent owner, when the event includes one.
  final AgentTag? agent;

  /// Creates a [ResponseShellCallCommandDoneEvent].
  const ResponseShellCallCommandDoneEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.commandIndex,
    required this.command,
    this.agent,
  });

  /// Creates a [ResponseShellCallCommandDoneEvent] from JSON.
  factory ResponseShellCallCommandDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponseShellCallCommandDoneEvent';
    requireJsonType(json, 'response.shell_call_command.done', context);
    return ResponseShellCallCommandDoneEvent(
      sequenceNumber: requireJsonInt(
        json['sequence_number'],
        '$context.sequence_number',
      ),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      commandIndex: requireJsonInt(
        json['command_index'],
        '$context.command_index',
      ),
      command: requireJsonString(json['command'], '$context.command'),
      agent: _streamEventAgent(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'command_index': commandIndex,
    'command': command,
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Passing `null` for [agent] removes that optional key.
  ResponseShellCallCommandDoneEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    int? commandIndex,
    String? command,
    Object? agent = unsetCopyWithValue,
  }) => ResponseShellCallCommandDoneEvent(
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    outputIndex: outputIndex ?? this.outputIndex,
    commandIndex: commandIndex ?? this.commandIndex,
    command: command ?? this.command,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseShellCallCommandDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          commandIndex == other.commandIndex &&
          command == other.command &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, outputIndex, commandIndex, command, agent);

  @override
  String toString() =>
      'ResponseShellCallCommandDoneEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, commandIndex: $commandIndex, command: [${command.length} chars], agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'})';
}

/// Event emitted when stdout or stderr receives a fragment.
@immutable
class ResponseShellCallOutputContentDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.shell_call_output_content.delta';

  /// The sequence number for ordering events.
  @override
  final int sequenceNumber;

  /// The index of the shell call output item.
  final int outputIndex;

  /// The index of the shell command within the call.
  final int commandIndex;

  /// The ID of the shell call output item.
  final String itemId;

  /// The stdout and stderr fragments, which may both be absent.
  final ShellCallOutputDelta delta;

  /// The beta multi-agent owner, when the event includes one.
  final AgentTag? agent;

  /// Creates a [ResponseShellCallOutputContentDeltaEvent].
  const ResponseShellCallOutputContentDeltaEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.commandIndex,
    required this.itemId,
    required this.delta,
    this.agent,
  });

  /// Creates a [ResponseShellCallOutputContentDeltaEvent] from JSON.
  factory ResponseShellCallOutputContentDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponseShellCallOutputContentDeltaEvent';
    requireJsonType(json, 'response.shell_call_output_content.delta', context);
    return ResponseShellCallOutputContentDeltaEvent(
      sequenceNumber: requireJsonInt(
        json['sequence_number'],
        '$context.sequence_number',
      ),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      commandIndex: requireJsonInt(
        json['command_index'],
        '$context.command_index',
      ),
      itemId: requireJsonString(json['item_id'], '$context.item_id'),
      delta: ShellCallOutputDelta.fromJson(
        requireJsonObject(json['delta'], '$context.delta'),
        context: '$context.delta',
      ),
      agent: _streamEventAgent(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'command_index': commandIndex,
    'item_id': itemId,
    'delta': delta.toJson(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Passing `null` for [agent] removes that optional key.
  ResponseShellCallOutputContentDeltaEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    int? commandIndex,
    String? itemId,
    ShellCallOutputDelta? delta,
    Object? agent = unsetCopyWithValue,
  }) => ResponseShellCallOutputContentDeltaEvent(
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    outputIndex: outputIndex ?? this.outputIndex,
    commandIndex: commandIndex ?? this.commandIndex,
    itemId: itemId ?? this.itemId,
    delta: delta ?? this.delta,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseShellCallOutputContentDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          commandIndex == other.commandIndex &&
          itemId == other.itemId &&
          delta == other.delta &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    outputIndex,
    commandIndex,
    itemId,
    delta,
    agent,
  );

  @override
  String toString() =>
      'ResponseShellCallOutputContentDeltaEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, commandIndex: $commandIndex, itemId: $itemId, delta: $delta, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'})';
}

/// Event emitted when the output of a shell command is complete.
@immutable
class ResponseShellCallOutputContentDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.shell_call_output_content.done';

  /// The sequence number for ordering events.
  @override
  final int sequenceNumber;

  /// The index of the shell call output item.
  final int outputIndex;

  /// The index of the shell command within the call.
  final int commandIndex;

  /// The ID of the shell call output item.
  final String itemId;

  /// The complete output contents for this command.
  final List<ShellCallOutputContent> output;

  /// The beta multi-agent owner, when the event includes one.
  final AgentTag? agent;

  /// Creates a [ResponseShellCallOutputContentDoneEvent].
  ///
  /// Takes an unmodifiable snapshot of [output].
  ResponseShellCallOutputContentDoneEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.commandIndex,
    required this.itemId,
    required List<ShellCallOutputContent> output,
    this.agent,
  }) : output = List<ShellCallOutputContent>.unmodifiable(output);

  /// Creates a [ResponseShellCallOutputContentDoneEvent] from JSON.
  factory ResponseShellCallOutputContentDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ResponseShellCallOutputContentDoneEvent';
    requireJsonType(json, 'response.shell_call_output_content.done', context);
    final rawOutput = json['output'];
    if (rawOutput is! List) {
      throw const FormatException('$context.output: expected an array');
    }
    final output = <ShellCallOutputContent>[];
    for (var i = 0; i < rawOutput.length; i++) {
      output.add(
        ShellCallOutputContent.fromJson(
          requireJsonObject(rawOutput[i], '$context.output[$i]'),
          context: '$context.output[$i]',
        ),
      );
    }
    return ResponseShellCallOutputContentDoneEvent(
      sequenceNumber: requireJsonInt(
        json['sequence_number'],
        '$context.sequence_number',
      ),
      outputIndex: requireJsonInt(
        json['output_index'],
        '$context.output_index',
      ),
      commandIndex: requireJsonInt(
        json['command_index'],
        '$context.command_index',
      ),
      itemId: requireJsonString(json['item_id'], '$context.item_id'),
      output: output,
      agent: _streamEventAgent(json, context),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'command_index': commandIndex,
    'item_id': itemId,
    'output': output.map((content) => content.toJson()).toList(),
    if (agent != null) 'agent': agent!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Passing `null` for [agent] removes that optional key.
  ResponseShellCallOutputContentDoneEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    int? commandIndex,
    String? itemId,
    List<ShellCallOutputContent>? output,
    Object? agent = unsetCopyWithValue,
  }) => ResponseShellCallOutputContentDoneEvent(
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    outputIndex: outputIndex ?? this.outputIndex,
    commandIndex: commandIndex ?? this.commandIndex,
    itemId: itemId ?? this.itemId,
    output: output ?? this.output,
    agent: identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseShellCallOutputContentDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          commandIndex == other.commandIndex &&
          itemId == other.itemId &&
          listsEqual(output, other.output) &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    outputIndex,
    commandIndex,
    itemId,
    listHash(output),
    agent,
  );

  @override
  String toString() =>
      'ResponseShellCallOutputContentDoneEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, commandIndex: $commandIndex, itemId: $itemId, output: ${output.length} chunks, agent: ${agent == null ? 'null' : '[${agent!.agentName.length} chars]'})';
}

// ============================================================
// Image Generation Events
// ============================================================

/// Event emitted when an image generation call is in progress.
@immutable
class ResponseImageGenerationCallInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseImageGenerationCallInProgressEvent].
  const ResponseImageGenerationCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseImageGenerationCallInProgressEvent] from JSON.
  factory ResponseImageGenerationCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseImageGenerationCallInProgressEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseImageGenerationCallInProgressEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseImageGenerationCallInProgressEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when an image generation call is generating.
@immutable
class ResponseImageGenerationCallGeneratingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.generating';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseImageGenerationCallGeneratingEvent].
  const ResponseImageGenerationCallGeneratingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseImageGenerationCallGeneratingEvent] from JSON.
  factory ResponseImageGenerationCallGeneratingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallGeneratingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallGeneratingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseImageGenerationCallGeneratingEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseImageGenerationCallGeneratingEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseImageGenerationCallGeneratingEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when a partial image is generated.
@immutable
class ResponseImageGenerationCallPartialImageEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.partial_image';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The base64-encoded partial image data.
  final String partialImageB64;

  /// The index of this partial image.
  final int partialImageIndex;

  /// Creates a [ResponseImageGenerationCallPartialImageEvent].
  const ResponseImageGenerationCallPartialImageEvent({
    required this.itemId,
    required this.outputIndex,
    required this.partialImageB64,
    required this.partialImageIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseImageGenerationCallPartialImageEvent] from JSON.
  factory ResponseImageGenerationCallPartialImageEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallPartialImageEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      partialImageB64: json['partial_image_b64'] as String,
      partialImageIndex: json['partial_image_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'partial_image_b64': partialImageB64,
    'partial_image_index': partialImageIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallPartialImageEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          partialImageIndex == other.partialImageIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    partialImageIndex,
    sequenceNumber,
    agent,
  );

  /// Creates a copy with replaced values.
  ResponseImageGenerationCallPartialImageEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? partialImageB64,
    int? partialImageIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseImageGenerationCallPartialImageEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      partialImageB64: partialImageB64 ?? this.partialImageB64,
      partialImageIndex: partialImageIndex ?? this.partialImageIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseImageGenerationCallPartialImageEvent(partialImageIndex: $partialImageIndex, agent: $agent)';
}

/// Event emitted when an image generation call is completed.
@immutable
class ResponseImageGenerationCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseImageGenerationCallCompletedEvent].
  const ResponseImageGenerationCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseImageGenerationCallCompletedEvent] from JSON.
  factory ResponseImageGenerationCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseImageGenerationCallCompletedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseImageGenerationCallCompletedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseImageGenerationCallCompletedEvent(itemId: $itemId, agent: $agent)';
}

// ============================================================
// MCP Events
// ============================================================

/// Event emitted when an MCP call is in progress.
@immutable
class ResponseMcpCallInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpCallInProgressEvent].
  const ResponseMcpCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpCallInProgressEvent] from JSON.
  factory ResponseMcpCallInProgressEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpCallInProgressEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpCallInProgressEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpCallInProgressEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when an MCP call is completed.
@immutable
class ResponseMcpCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpCallCompletedEvent].
  const ResponseMcpCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpCallCompletedEvent] from JSON.
  factory ResponseMcpCallCompletedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpCallCompletedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpCallCompletedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpCallCompletedEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when an MCP call fails.
@immutable
class ResponseMcpCallFailedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call.failed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpCallFailedEvent].
  const ResponseMcpCallFailedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpCallFailedEvent] from JSON.
  factory ResponseMcpCallFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpCallFailedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallFailedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpCallFailedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpCallFailedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpCallFailedEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when MCP call arguments are generated (delta).
@immutable
class ResponseMcpCallArgumentsDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call_arguments.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The arguments delta.
  final String delta;

  /// Creates a [ResponseMcpCallArgumentsDeltaEvent].
  const ResponseMcpCallArgumentsDeltaEvent({
    required this.itemId,
    required this.outputIndex,
    required this.delta,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpCallArgumentsDeltaEvent] from JSON.
  factory ResponseMcpCallArgumentsDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseMcpCallArgumentsDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, delta, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpCallArgumentsDeltaEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? delta,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpCallArgumentsDeltaEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      delta: delta ?? this.delta,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpCallArgumentsDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when MCP call arguments are complete.
@immutable
class ResponseMcpCallArgumentsDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call_arguments.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The complete arguments.
  final String arguments;

  /// Creates a [ResponseMcpCallArgumentsDoneEvent].
  const ResponseMcpCallArgumentsDoneEvent({
    required this.itemId,
    required this.outputIndex,
    required this.arguments,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpCallArgumentsDoneEvent] from JSON.
  factory ResponseMcpCallArgumentsDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseMcpCallArgumentsDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      arguments: json['arguments'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'arguments': arguments,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          arguments == other.arguments &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, arguments, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpCallArgumentsDoneEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? arguments,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpCallArgumentsDoneEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      arguments: arguments ?? this.arguments,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpCallArgumentsDoneEvent(arguments: $arguments, agent: $agent)';
}

/// Event emitted when MCP list tools is in progress.
@immutable
class ResponseMcpListToolsInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_list_tools.in_progress';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP list tools item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpListToolsInProgressEvent].
  const ResponseMcpListToolsInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpListToolsInProgressEvent] from JSON.
  factory ResponseMcpListToolsInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseMcpListToolsInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpListToolsInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpListToolsInProgressEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpListToolsInProgressEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpListToolsInProgressEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when MCP list tools is completed.
@immutable
class ResponseMcpListToolsCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_list_tools.completed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP list tools item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpListToolsCompletedEvent].
  const ResponseMcpListToolsCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpListToolsCompletedEvent] from JSON.
  factory ResponseMcpListToolsCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseMcpListToolsCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpListToolsCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpListToolsCompletedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpListToolsCompletedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpListToolsCompletedEvent(itemId: $itemId, agent: $agent)';
}

/// Event emitted when MCP list tools fails.
@immutable
class ResponseMcpListToolsFailedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_list_tools.failed';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the MCP list tools item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpListToolsFailedEvent].
  const ResponseMcpListToolsFailedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseMcpListToolsFailedEvent] from JSON.
  factory ResponseMcpListToolsFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpListToolsFailedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpListToolsFailedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseMcpListToolsFailedEvent copyWith({
    String? itemId,
    int? outputIndex,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseMcpListToolsFailedEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseMcpListToolsFailedEvent(itemId: $itemId, agent: $agent)';
}

// ============================================================
// Custom Tool Events
// ============================================================

/// Event emitted when custom tool call input is generated (delta).
@immutable
class ResponseCustomToolCallInputDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.custom_tool_call_input.delta';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the custom tool call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The input delta.
  final String delta;

  /// Creates a [ResponseCustomToolCallInputDeltaEvent].
  const ResponseCustomToolCallInputDeltaEvent({
    required this.itemId,
    required this.outputIndex,
    required this.delta,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCustomToolCallInputDeltaEvent] from JSON.
  factory ResponseCustomToolCallInputDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCustomToolCallInputDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomToolCallInputDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, delta, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCustomToolCallInputDeltaEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? delta,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCustomToolCallInputDeltaEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      delta: delta ?? this.delta,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCustomToolCallInputDeltaEvent(delta: $delta, agent: $agent)';
}

/// Event emitted when custom tool call input is complete.
@immutable
class ResponseCustomToolCallInputDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.custom_tool_call_input.done';

  @override
  final int? sequenceNumber;

  /// The agent that owns this multi-agent streaming event.
  ///
  /// Only populated on the beta multi-agent protocol
  /// (`OpenAI-Beta: responses_multi_agent=v1`).
  final AgentTag? agent;

  /// The ID of the custom tool call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The complete input.
  final String input;

  /// Creates a [ResponseCustomToolCallInputDoneEvent].
  const ResponseCustomToolCallInputDoneEvent({
    required this.itemId,
    required this.outputIndex,
    required this.input,
    this.sequenceNumber,
    this.agent,
  });

  /// Creates a [ResponseCustomToolCallInputDoneEvent] from JSON.
  factory ResponseCustomToolCallInputDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCustomToolCallInputDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      input: json['input'] as String,
      sequenceNumber: json['sequence_number'] as int?,
      agent: json['agent'] != null
          ? AgentTag.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'input': input,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
    if (agent != null) 'agent': agent!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomToolCallInputDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          input == other.input &&
          sequenceNumber == other.sequenceNumber &&
          agent == other.agent;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, input, sequenceNumber, agent);

  /// Creates a copy with replaced values.
  ResponseCustomToolCallInputDoneEvent copyWith({
    String? itemId,
    int? outputIndex,
    String? input,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
  }) {
    return ResponseCustomToolCallInputDoneEvent(
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      input: input ?? this.input,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as AgentTag?,
    );
  }

  @override
  String toString() =>
      'ResponseCustomToolCallInputDoneEvent(input: $input, agent: $agent)';
}

// ============================================================
// Error Events
// ============================================================

/// Event emitted when an error occurs in a Responses SSE stream.
///
/// Canonical output is flat: nullable `code` and `param`, `message`, and
/// `sequence_number`. Beta multi-agent `agent` is optional and nullable. Future
/// fields are opaque metadata; this event declares no typed monitoring details.
///
/// Receiving legacy nested `error` objects remains supported. Legacy omissions
/// of code/param in either flat or nested legacy input retain
/// [hasCode]/[hasParam], rather than inventing values. Missing
/// sequence numbers remain omitted for legacy inputs and existing construction;
/// a supplied null or malformed sequence number is rejected. A message is always
/// required. Legacy nested input normalizes to flat output, with its original
/// envelope available in [rawJson].
@immutable
class ErrorEvent extends ResponseStreamEvent {
  @override
  String get type => 'error';

  /// The sequence number, or null for legacy omission.
  @override
  final int? sequenceNumber;

  /// Whether a sequence number is available rather than omitted.
  bool get hasSequenceNumber => sequenceNumber != null;

  /// The optional beta multi-agent owner.
  final AgentTag? agent;

  /// Whether the nullable beta agent key was supplied, including explicit null.
  final bool hasAgent;

  /// The nullable open provider error code.
  final String? code;

  /// Whether code is present, including explicit null.
  final bool hasCode;

  /// The error message, which can contain sensitive information.
  final String message;

  /// The nullable error parameter.
  final String? param;

  /// Whether param is present, including explicit null.
  final bool hasParam;

  /// The original input, including future metadata.
  ///
  /// Parsing and copies take deeply immutable snapshots. For const constructor
  /// compatibility, caller-supplied constructor metadata must not be mutated.
  /// Typed fields take precedence over schema-known members during serialization.
  final Map<String, dynamic> rawJson;

  final bool _legacyNestedInput;

  /// Creates an [ErrorEvent], preserving existing const construction.
  ///
  /// New construction emits canonical nullable code/param keys by default. A
  /// missing [sequenceNumber] remains omitted and does not become zero. To omit
  /// a legacy nullable key, pass null with its presence flag set to false.
  const ErrorEvent({
    required this.code,
    required this.message,
    this.param,
    this.sequenceNumber,
    this.agent,
    bool hasCode = true,
    bool hasParam = true,
    bool hasAgent = false,
    this.rawJson = const {},
  }) : hasCode = hasCode || code != null,
       hasParam = hasParam || param != null,
       hasAgent = hasAgent || agent != null,
       _legacyNestedInput = false;

  const ErrorEvent._parsed({
    required this.code,
    required this.message,
    required this.param,
    required this.sequenceNumber,
    required this.agent,
    required this.hasCode,
    required this.hasParam,
    required this.hasAgent,
    required this.rawJson,
    required this._legacyNestedInput,
  });

  /// Parses canonical flat fields or the documented legacy nested envelope.
  ///
  /// Canonical flat input requires nullable code/param keys. Receiving legacy
  /// flat or nested omissions remains supported with explicit presence flags;
  /// that tolerance does not claim canonical schema admission. Top-level message
  /// takes precedence over any opaque `error` overflow member in flat input.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'error', 'ErrorEvent');
    final snapshot = snapshotResponsesJson(json, 'ErrorEvent');
    final legacyNestedInput =
        !snapshot.containsKey('message') && snapshot['error'] != null;
    final error = legacyNestedInput
        ? requireJsonObject(snapshot['error'], 'ErrorEvent.error')
        : snapshot;
    AgentTag? agent;
    if (snapshot['agent'] != null) {
      final agentJson = requireJsonObject(
        snapshot['agent'],
        'ErrorEvent.agent',
      );
      agent = AgentTag(
        agentName: requireJsonString(
          agentJson['agent_name'],
          'ErrorEvent.agent.agent_name',
        ),
      );
    }
    return ErrorEvent._parsed(
      code: optionalJsonString(error, 'code', 'ErrorEvent', nullable: true),
      message: requireJsonString(error['message'], 'ErrorEvent.message'),
      param: optionalJsonString(error, 'param', 'ErrorEvent', nullable: true),
      sequenceNumber: optionalJsonInt(
        snapshot,
        'sequence_number',
        'ErrorEvent',
      ),
      agent: agent,
      hasCode: error.containsKey('code'),
      hasParam: error.containsKey('param'),
      hasAgent: snapshot.containsKey('agent'),
      rawJson: snapshot,
      legacyNestedInput: legacyNestedInput,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    snapshotResponsesJson(rawJson, 'ErrorEvent.rawJson');
    return mergeResponsesJson(
      rawJson,
      {
        'type',
        'code',
        'message',
        'param',
        'sequence_number',
        'agent',
        if (_legacyNestedInput) 'error',
      },
      {
        'type': type,
        if (hasCode) 'code': code,
        'message': message,
        if (hasParam) 'param': param,
        if (hasSequenceNumber) 'sequence_number': sequenceNumber,
        if (hasAgent)
          'agent': agent == null
              ? null
              : mergeResponsesModelJson(
                  rawJson['agent'],
                  agent!.toJson(),
                  const {'agent_name'},
                ),
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  /// Copies all fields. Explicit null clears code/param to a present nullable
  /// key, clears agent to explicit null, and omits a sequence number.
  ///
  /// Set a nullable presence flag to false with its value null to restore
  /// omission. A fresh agent replacement drops the old child's future metadata;
  /// an explicit parent [rawJson] override supplies metadata for the replacement.
  ErrorEvent copyWith({
    Object? code = unsetCopyWithValue,
    String? message,
    Object? param = unsetCopyWithValue,
    Object? sequenceNumber = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    bool? hasCode,
    bool? hasParam,
    bool? hasAgent,
    Map<String, dynamic>? rawJson,
  }) {
    final newCode = identical(code, unsetCopyWithValue)
        ? this.code
        : code as String?;
    final newParam = identical(param, unsetCopyWithValue)
        ? this.param
        : param as String?;
    final newAgent = identical(agent, unsetCopyWithValue)
        ? this.agent
        : agent as AgentTag?;
    final retainedRaw = rawJson ?? this.rawJson;
    final reconciledRaw =
        rawJson == null && !identical(agent, unsetCopyWithValue)
        ? (<String, dynamic>{
            ...retainedRaw,
            if (newAgent != null) 'agent': newAgent.toJson(),
          }..removeWhere((key, _) => key == 'agent' && newAgent == null))
        : retainedRaw;
    return ErrorEvent._parsed(
      code: newCode,
      message: message ?? this.message,
      param: newParam,
      sequenceNumber: identical(sequenceNumber, unsetCopyWithValue)
          ? this.sequenceNumber
          : sequenceNumber as int?,
      agent: newAgent,
      hasCode:
          (hasCode ?? (!identical(code, unsetCopyWithValue) || this.hasCode)) ||
          newCode != null,
      hasParam:
          (hasParam ??
              (!identical(param, unsetCopyWithValue) || this.hasParam)) ||
          newParam != null,
      hasAgent:
          (hasAgent ??
              (!identical(agent, unsetCopyWithValue) || this.hasAgent)) ||
          newAgent != null,
      rawJson: snapshotResponsesJson(reconciledRaw, 'ErrorEvent.rawJson'),
      legacyNestedInput: rawJson == null && _legacyNestedInput,
    );
  }

  @override
  String toString() =>
      'ErrorEvent(code: ${responsesPresence(code)}, hasCode: $hasCode, '
      'message: [REDACTED], param: ${responsesPresence(param)}, '
      'hasParam: $hasParam, sequenceNumber: $sequenceNumber, '
      'hasSequenceNumber: $hasSequenceNumber, '
      'agent: ${responsesPresence(agent)}, hasAgent: $hasAgent, '
      'rawJson: ${rawJson.length} entries)';
}

// ============================================================
// Unknown / Unrecognized Events
// ============================================================

/// An event with an unrecognized [type].
///
/// This is returned for any event type that the library does not yet handle
/// (e.g. `keepalive` events emitted during long-running streaming operations).
/// It preserves the raw JSON so callers can inspect it if needed.
@immutable
class UnknownEvent extends ResponseStreamEvent {
  @override
  final String type;

  @override
  final int? sequenceNumber;

  /// The raw JSON of the unrecognized event.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownEvent].
  const UnknownEvent({
    required this.type,
    required this.rawJson,
    this.sequenceNumber,
  });

  /// Creates an [UnknownEvent] from JSON.
  factory UnknownEvent.fromJson(Map<String, dynamic> json) {
    return UnknownEvent(
      type: json['type'] as String,
      rawJson: json,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          sequenceNumber == other.sequenceNumber &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode =>
      Object.hash(type, sequenceNumber, mapDeepHashCode(rawJson));

  /// Creates a copy with replaced values.
  UnknownEvent copyWith({
    String? type,
    Map<String, dynamic>? rawJson,
    Object? sequenceNumber = unsetCopyWithValue,
  }) {
    return UnknownEvent(
      type: type ?? this.type,
      rawJson: rawJson ?? this.rawJson,
      sequenceNumber: sequenceNumber == unsetCopyWithValue
          ? this.sequenceNumber
          : sequenceNumber as int?,
    );
  }

  @override
  String toString() => 'UnknownEvent(type: $type)';
}

// ============================================================
// Extension Methods
// ============================================================

/// Extension methods for [ResponseStreamEvent].
extension ResponseStreamEventExtensions on ResponseStreamEvent {
  /// Returns the text delta if this is a text delta event.
  String? get textDelta {
    if (this is OutputTextDeltaEvent) {
      return (this as OutputTextDeltaEvent).delta;
    }
    return null;
  }

  /// Returns the final response if this is a completion event.
  Response? get finalResponse {
    if (this is ResponseCompletedEvent) {
      return (this as ResponseCompletedEvent).response;
    }
    if (this is ResponseFailedEvent) {
      return (this as ResponseFailedEvent).response;
    }
    if (this is ResponseIncompleteEvent) {
      return (this as ResponseIncompleteEvent).response;
    }
    return null;
  }
}
