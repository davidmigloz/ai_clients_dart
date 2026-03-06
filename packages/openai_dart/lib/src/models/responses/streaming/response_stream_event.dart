import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../content/annotation.dart';
import '../content/logprob.dart';
import '../content/output_content.dart';
import '../items/output_item.dart';
import '../response.dart';

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
/// - **Audio events**: delta, done, transcript delta, transcript done
/// - **Web search events**: in_progress, searching, completed
/// - **File search events**: in_progress, searching, completed
/// - **Code interpreter events**: in_progress, interpreting, code delta, code done, completed
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
    final type = json['type'] as String;
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

  /// Whether this event indicates the stream has ended.
  bool get isFinal =>
      this is ResponseCompletedEvent ||
      this is ResponseFailedEvent ||
      this is ResponseIncompleteEvent;
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

  /// The response that was created.
  final Response response;

  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({required this.response, this.sequenceNumber});

  /// Creates a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCreatedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(response, sequenceNumber);

  @override
  String toString() => 'ResponseCreatedEvent(response: ${response.id})';
}

/// Event emitted when a response is queued for processing.
@immutable
class ResponseQueuedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.queued';

  @override
  final int? sequenceNumber;

  /// The response that was queued.
  final Response response;

  /// Creates a [ResponseQueuedEvent].
  const ResponseQueuedEvent({required this.response, this.sequenceNumber});

  /// Creates a [ResponseQueuedEvent] from JSON.
  factory ResponseQueuedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseQueuedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseQueuedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(response, sequenceNumber);

  @override
  String toString() => 'ResponseQueuedEvent(response: ${response.id})';
}

/// Event emitted when a response is in progress.
@immutable
class ResponseInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.in_progress';

  @override
  final int? sequenceNumber;

  /// The response that is in progress.
  final Response response;

  /// Creates a [ResponseInProgressEvent].
  const ResponseInProgressEvent({required this.response, this.sequenceNumber});

  /// Creates a [ResponseInProgressEvent] from JSON.
  factory ResponseInProgressEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInProgressEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInProgressEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(response, sequenceNumber);

  @override
  String toString() => 'ResponseInProgressEvent(response: ${response.id})';
}

/// Event emitted when a response is completed.
@immutable
class ResponseCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.completed';

  @override
  final int? sequenceNumber;

  /// The completed response.
  final Response response;

  /// Creates a [ResponseCompletedEvent].
  const ResponseCompletedEvent({required this.response, this.sequenceNumber});

  /// Creates a [ResponseCompletedEvent] from JSON.
  factory ResponseCompletedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCompletedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompletedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(response, sequenceNumber);

  @override
  String toString() => 'ResponseCompletedEvent(response: ${response.id})';
}

/// Event emitted when a response fails.
@immutable
class ResponseFailedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.failed';

  @override
  final int? sequenceNumber;

  /// The failed response.
  final Response response;

  /// Creates a [ResponseFailedEvent].
  const ResponseFailedEvent({required this.response, this.sequenceNumber});

  /// Creates a [ResponseFailedEvent] from JSON.
  factory ResponseFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseFailedEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFailedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(response, sequenceNumber);

  @override
  String toString() => 'ResponseFailedEvent(response: ${response.id})';
}

/// Event emitted when a response is incomplete.
@immutable
class ResponseIncompleteEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.incomplete';

  @override
  final int? sequenceNumber;

  /// The incomplete response.
  final Response response;

  /// Creates a [ResponseIncompleteEvent].
  const ResponseIncompleteEvent({required this.response, this.sequenceNumber});

  /// Creates a [ResponseIncompleteEvent] from JSON.
  factory ResponseIncompleteEvent.fromJson(Map<String, dynamic> json) {
    return ResponseIncompleteEvent(
      response: Response.fromJson(json['response'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'response': response.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseIncompleteEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(response, sequenceNumber);

  @override
  String toString() => 'ResponseIncompleteEvent(response: ${response.id})';
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

  /// The index of the output item.
  final int outputIndex;

  /// The added output item.
  final OutputItem item;

  /// Creates an [OutputItemAddedEvent].
  const OutputItemAddedEvent({
    required this.outputIndex,
    required this.item,
    this.sequenceNumber,
  });

  /// Creates an [OutputItemAddedEvent] from JSON.
  factory OutputItemAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemAddedEvent(
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'output_index': outputIndex,
    'item': item.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemAddedEvent &&
          runtimeType == other.runtimeType &&
          outputIndex == other.outputIndex &&
          item == other.item &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(outputIndex, item, sequenceNumber);

  @override
  String toString() => 'OutputItemAddedEvent(outputIndex: $outputIndex)';
}

/// Event emitted when an output item is complete.
@immutable
class OutputItemDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_item.done';

  @override
  final int? sequenceNumber;

  /// The index of the output item.
  final int outputIndex;

  /// The completed output item.
  final OutputItem item;

  /// Creates an [OutputItemDoneEvent].
  const OutputItemDoneEvent({
    required this.outputIndex,
    required this.item,
    this.sequenceNumber,
  });

  /// Creates an [OutputItemDoneEvent] from JSON.
  factory OutputItemDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemDoneEvent(
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'output_index': outputIndex,
    'item': item.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemDoneEvent &&
          runtimeType == other.runtimeType &&
          outputIndex == other.outputIndex &&
          item == other.item &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(outputIndex, item, sequenceNumber);

  @override
  String toString() => 'OutputItemDoneEvent(outputIndex: $outputIndex)';
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
  });

  /// Creates a [ContentPartAddedEvent] from JSON.
  factory ContentPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartAddedEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, part, sequenceNumber);

  @override
  String toString() =>
      'ContentPartAddedEvent(outputIndex: $outputIndex, contentIndex: $contentIndex)';
}

/// Event emitted when a content part is complete.
@immutable
class ContentPartDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.content_part.done';

  @override
  final int? sequenceNumber;

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
  });

  /// Creates a [ContentPartDoneEvent] from JSON.
  factory ContentPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, part, sequenceNumber);

  @override
  String toString() =>
      'ContentPartDoneEvent(outputIndex: $outputIndex, contentIndex: $contentIndex)';
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, delta, sequenceNumber);

  @override
  String toString() => 'OutputTextDeltaEvent(delta: $delta)';
}

/// Event emitted when text generation is complete.
@immutable
class OutputTextDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_text.done';

  @override
  final int? sequenceNumber;

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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, text, sequenceNumber);

  @override
  String toString() =>
      'OutputTextDoneEvent(text: ${text.length > 50 ? '${text.substring(0, 50)}...' : text})';
}

/// Event emitted when a text annotation is added.
@immutable
class OutputTextAnnotationAddedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.output_text.annotation.added';

  @override
  final int? sequenceNumber;

  /// The ID of the item containing this annotation.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the content part.
  final int contentIndex;

  /// The index of the annotation.
  final int annotationIndex;

  /// The annotation that was added.
  final Annotation annotation;

  /// Creates an [OutputTextAnnotationAddedEvent].
  const OutputTextAnnotationAddedEvent({
    required this.outputIndex,
    required this.contentIndex,
    required this.annotationIndex,
    required this.annotation,
    this.itemId,
    this.sequenceNumber,
  });

  /// Creates an [OutputTextAnnotationAddedEvent] from JSON.
  factory OutputTextAnnotationAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextAnnotationAddedEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      annotationIndex: json['annotation_index'] as int,
      annotation: Annotation.fromJson(
        json['annotation'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'annotation_index': annotationIndex,
    'annotation': annotation.toJson(),
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    annotationIndex,
    annotation,
    sequenceNumber,
  );

  @override
  String toString() =>
      'OutputTextAnnotationAddedEvent(annotationIndex: $annotationIndex)';
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
  });

  /// Creates a [RefusalDeltaEvent] from JSON.
  factory RefusalDeltaEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, delta, sequenceNumber);

  @override
  String toString() => 'RefusalDeltaEvent(delta: $delta)';
}

/// Event emitted when refusal generation is complete.
@immutable
class RefusalDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.refusal.done';

  @override
  final int? sequenceNumber;

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
  });

  /// Creates a [RefusalDoneEvent] from JSON.
  factory RefusalDoneEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      refusal: json['refusal'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, refusal, sequenceNumber);

  @override
  String toString() => 'RefusalDoneEvent(refusal: $refusal)';
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
  });

  /// Creates a [FunctionCallArgumentsDeltaEvent] from JSON.
  factory FunctionCallArgumentsDeltaEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemId != null) 'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, delta, sequenceNumber);

  @override
  String toString() =>
      'FunctionCallArgumentsDeltaEvent(itemId: $itemId, delta: $delta)';
}

/// Event emitted when function call arguments are complete.
@immutable
class FunctionCallArgumentsDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.function_call_arguments.done';

  @override
  final int? sequenceNumber;

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
  });

  /// Creates a [FunctionCallArgumentsDoneEvent] from JSON.
  factory FunctionCallArgumentsDoneEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      name: json['name'] as String?,
      arguments: json['arguments'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, name, arguments, sequenceNumber);

  @override
  String toString() =>
      'FunctionCallArgumentsDoneEvent(itemId: $itemId, name: $name, arguments: $arguments)';
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
  });

  /// Creates a [ReasoningTextDeltaEvent] from JSON.
  factory ReasoningTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningTextDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int?,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, delta, sequenceNumber);

  @override
  String toString() => 'ReasoningTextDeltaEvent(delta: $delta)';
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
  });

  /// Creates a [ReasoningTextDoneEvent] from JSON.
  factory ReasoningTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningTextDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int?,
      text: json['text'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, contentIndex, text, sequenceNumber);

  @override
  String toString() => 'ReasoningTextDoneEvent(text: $text)';
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
  });

  /// Creates a [ReasoningSummaryPartAddedEvent] from JSON.
  factory ReasoningSummaryPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartAddedEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      part: json['part'] as Map<String, dynamic>,
      sequenceNumber: json['sequence_number'] as int?,
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
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartAddedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, summaryIndex, part, sequenceNumber);

  @override
  String toString() =>
      'ReasoningSummaryPartAddedEvent(outputIndex: $outputIndex, summaryIndex: $summaryIndex)';
}

/// Event emitted when a reasoning summary part is complete.
@immutable
class ReasoningSummaryPartDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_part.done';

  @override
  final int? sequenceNumber;

  /// The ID of the item containing this reasoning summary.
  final String? itemId;

  /// The index of the output item.
  final int outputIndex;

  /// The index of the summary part.
  final int summaryIndex;

  /// The summary part.
  final Map<String, dynamic> part;

  /// Creates a [ReasoningSummaryPartDoneEvent].
  const ReasoningSummaryPartDoneEvent({
    required this.outputIndex,
    required this.summaryIndex,
    required this.part,
    this.itemId,
    this.sequenceNumber,
  });

  /// Creates a [ReasoningSummaryPartDoneEvent] from JSON.
  factory ReasoningSummaryPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      part: json['part'] as Map<String, dynamic>,
      sequenceNumber: json['sequence_number'] as int?,
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
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, summaryIndex, part, sequenceNumber);

  @override
  String toString() =>
      'ReasoningSummaryPartDoneEvent(outputIndex: $outputIndex, summaryIndex: $summaryIndex)';
}

/// Event emitted when reasoning summary text is generated (delta).
@immutable
class ReasoningSummaryTextDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_text.delta';

  @override
  final int? sequenceNumber;

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
  });

  /// Creates a [ReasoningSummaryTextDeltaEvent] from JSON.
  factory ReasoningSummaryTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryTextDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, summaryIndex, delta, sequenceNumber);

  @override
  String toString() =>
      'ReasoningSummaryTextDeltaEvent(outputIndex: $outputIndex, delta: $delta)';
}

/// Event emitted when reasoning summary text is complete.
@immutable
class ReasoningSummaryTextDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.reasoning_summary_text.done';

  @override
  final int? sequenceNumber;

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
  });

  /// Creates a [ReasoningSummaryTextDoneEvent] from JSON.
  factory ReasoningSummaryTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryTextDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      text: json['text'] as String,
      sequenceNumber: json['sequence_number'] as int?,
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
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, summaryIndex, text, sequenceNumber);

  @override
  String toString() =>
      'ReasoningSummaryTextDoneEvent(outputIndex: $outputIndex, text: $text)';
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

  /// The base64-encoded audio delta.
  final String delta;

  /// Creates a [ResponseAudioDeltaEvent].
  const ResponseAudioDeltaEvent({required this.delta, this.sequenceNumber});

  /// Creates a [ResponseAudioDeltaEvent] from JSON.
  factory ResponseAudioDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioDeltaEvent(
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(delta, sequenceNumber);

  @override
  String toString() => 'ResponseAudioDeltaEvent(deltaLength: ${delta.length})';
}

/// Event emitted when audio generation is complete.
@immutable
class ResponseAudioDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.done';

  @override
  final int? sequenceNumber;

  /// Creates a [ResponseAudioDoneEvent].
  const ResponseAudioDoneEvent({this.sequenceNumber});

  /// Creates a [ResponseAudioDoneEvent] from JSON.
  factory ResponseAudioDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioDoneEvent(
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => sequenceNumber.hashCode;

  @override
  String toString() => 'ResponseAudioDoneEvent()';
}

/// Event emitted when audio transcript is generated (delta).
@immutable
class ResponseAudioTranscriptDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.transcript.delta';

  @override
  final int? sequenceNumber;

  /// The transcript delta.
  final String delta;

  /// Creates a [ResponseAudioTranscriptDeltaEvent].
  const ResponseAudioTranscriptDeltaEvent({
    required this.delta,
    this.sequenceNumber,
  });

  /// Creates a [ResponseAudioTranscriptDeltaEvent] from JSON.
  factory ResponseAudioTranscriptDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseAudioTranscriptDeltaEvent(
      delta: json['delta'] as String,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioTranscriptDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(delta, sequenceNumber);

  @override
  String toString() => 'ResponseAudioTranscriptDeltaEvent(delta: $delta)';
}

/// Event emitted when audio transcript is complete.
@immutable
class ResponseAudioTranscriptDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.audio.transcript.done';

  @override
  final int? sequenceNumber;

  /// Creates a [ResponseAudioTranscriptDoneEvent].
  const ResponseAudioTranscriptDoneEvent({this.sequenceNumber});

  /// Creates a [ResponseAudioTranscriptDoneEvent] from JSON.
  factory ResponseAudioTranscriptDoneEvent.fromJson(Map<String, dynamic> json) {
    return ResponseAudioTranscriptDoneEvent(
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAudioTranscriptDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => sequenceNumber.hashCode;

  @override
  String toString() => 'ResponseAudioTranscriptDoneEvent()';
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

  /// The ID of the web search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseWebSearchCallInProgressEvent].
  const ResponseWebSearchCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseWebSearchCallInProgressEvent] from JSON.
  factory ResponseWebSearchCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseWebSearchCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseWebSearchCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseWebSearchCallInProgressEvent(itemId: $itemId)';
}

/// Event emitted when a web search call is searching.
@immutable
class ResponseWebSearchCallSearchingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.web_search_call.searching';

  @override
  final int? sequenceNumber;

  /// The ID of the web search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseWebSearchCallSearchingEvent].
  const ResponseWebSearchCallSearchingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseWebSearchCallSearchingEvent] from JSON.
  factory ResponseWebSearchCallSearchingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseWebSearchCallSearchingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseWebSearchCallSearchingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseWebSearchCallSearchingEvent(itemId: $itemId)';
}

/// Event emitted when a web search call is completed.
@immutable
class ResponseWebSearchCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.web_search_call.completed';

  @override
  final int? sequenceNumber;

  /// The ID of the web search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseWebSearchCallCompletedEvent].
  const ResponseWebSearchCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseWebSearchCallCompletedEvent] from JSON.
  factory ResponseWebSearchCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseWebSearchCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseWebSearchCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseWebSearchCallCompletedEvent(itemId: $itemId)';
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

  /// The ID of the file search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseFileSearchCallInProgressEvent].
  const ResponseFileSearchCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseFileSearchCallInProgressEvent] from JSON.
  factory ResponseFileSearchCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFileSearchCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileSearchCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseFileSearchCallInProgressEvent(itemId: $itemId)';
}

/// Event emitted when a file search call is searching.
@immutable
class ResponseFileSearchCallSearchingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.file_search_call.searching';

  @override
  final int? sequenceNumber;

  /// The ID of the file search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseFileSearchCallSearchingEvent].
  const ResponseFileSearchCallSearchingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseFileSearchCallSearchingEvent] from JSON.
  factory ResponseFileSearchCallSearchingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFileSearchCallSearchingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileSearchCallSearchingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseFileSearchCallSearchingEvent(itemId: $itemId)';
}

/// Event emitted when a file search call is completed.
@immutable
class ResponseFileSearchCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.file_search_call.completed';

  @override
  final int? sequenceNumber;

  /// The ID of the file search call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseFileSearchCallCompletedEvent].
  const ResponseFileSearchCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseFileSearchCallCompletedEvent] from JSON.
  factory ResponseFileSearchCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseFileSearchCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileSearchCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseFileSearchCallCompletedEvent(itemId: $itemId)';
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

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseCodeInterpreterCallInProgressEvent].
  const ResponseCodeInterpreterCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseCodeInterpreterCallInProgressEvent] from JSON.
  factory ResponseCodeInterpreterCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseCodeInterpreterCallInProgressEvent(itemId: $itemId)';
}

/// Event emitted when a code interpreter call is interpreting.
@immutable
class ResponseCodeInterpreterCallInterpretingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call.interpreting';

  @override
  final int? sequenceNumber;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseCodeInterpreterCallInterpretingEvent].
  const ResponseCodeInterpreterCallInterpretingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseCodeInterpreterCallInterpretingEvent] from JSON.
  factory ResponseCodeInterpreterCallInterpretingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallInterpretingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallInterpretingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseCodeInterpreterCallInterpretingEvent(itemId: $itemId)';
}

/// Event emitted when code interpreter code is generated (delta).
@immutable
class ResponseCodeInterpreterCallCodeDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call_code.delta';

  @override
  final int? sequenceNumber;

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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallCodeDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, delta, sequenceNumber);

  @override
  String toString() =>
      'ResponseCodeInterpreterCallCodeDeltaEvent(delta: $delta)';
}

/// Event emitted when code interpreter code generation is complete.
@immutable
class ResponseCodeInterpreterCallCodeDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call_code.done';

  @override
  final int? sequenceNumber;

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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'code': code,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallCodeDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          code == other.code &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, code, sequenceNumber);

  @override
  String toString() =>
      'ResponseCodeInterpreterCallCodeDoneEvent(codeLength: ${code.length})';
}

/// Event emitted when a code interpreter call is completed.
@immutable
class ResponseCodeInterpreterCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.code_interpreter_call.completed';

  @override
  final int? sequenceNumber;

  /// The ID of the code interpreter call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseCodeInterpreterCallCompletedEvent].
  const ResponseCodeInterpreterCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseCodeInterpreterCallCompletedEvent] from JSON.
  factory ResponseCodeInterpreterCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseCodeInterpreterCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCodeInterpreterCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseCodeInterpreterCallCompletedEvent(itemId: $itemId)';
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

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseImageGenerationCallInProgressEvent].
  const ResponseImageGenerationCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseImageGenerationCallInProgressEvent] from JSON.
  factory ResponseImageGenerationCallInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseImageGenerationCallInProgressEvent(itemId: $itemId)';
}

/// Event emitted when an image generation call is generating.
@immutable
class ResponseImageGenerationCallGeneratingEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.generating';

  @override
  final int? sequenceNumber;

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseImageGenerationCallGeneratingEvent].
  const ResponseImageGenerationCallGeneratingEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseImageGenerationCallGeneratingEvent] from JSON.
  factory ResponseImageGenerationCallGeneratingEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallGeneratingEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallGeneratingEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseImageGenerationCallGeneratingEvent(itemId: $itemId)';
}

/// Event emitted when a partial image is generated.
@immutable
class ResponseImageGenerationCallPartialImageEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.partial_image';

  @override
  final int? sequenceNumber;

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
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallPartialImageEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          partialImageIndex == other.partialImageIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, partialImageIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseImageGenerationCallPartialImageEvent(partialImageIndex: $partialImageIndex)';
}

/// Event emitted when an image generation call is completed.
@immutable
class ResponseImageGenerationCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.image_generation_call.completed';

  @override
  final int? sequenceNumber;

  /// The ID of the image generation call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseImageGenerationCallCompletedEvent].
  const ResponseImageGenerationCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseImageGenerationCallCompletedEvent] from JSON.
  factory ResponseImageGenerationCallCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseImageGenerationCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseImageGenerationCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() =>
      'ResponseImageGenerationCallCompletedEvent(itemId: $itemId)';
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

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpCallInProgressEvent].
  const ResponseMcpCallInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseMcpCallInProgressEvent] from JSON.
  factory ResponseMcpCallInProgressEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpCallInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseMcpCallInProgressEvent(itemId: $itemId)';
}

/// Event emitted when an MCP call is completed.
@immutable
class ResponseMcpCallCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call.completed';

  @override
  final int? sequenceNumber;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpCallCompletedEvent].
  const ResponseMcpCallCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseMcpCallCompletedEvent] from JSON.
  factory ResponseMcpCallCompletedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpCallCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseMcpCallCompletedEvent(itemId: $itemId)';
}

/// Event emitted when an MCP call fails.
@immutable
class ResponseMcpCallFailedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call.failed';

  @override
  final int? sequenceNumber;

  /// The ID of the MCP call item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpCallFailedEvent].
  const ResponseMcpCallFailedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseMcpCallFailedEvent] from JSON.
  factory ResponseMcpCallFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpCallFailedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallFailedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseMcpCallFailedEvent(itemId: $itemId)';
}

/// Event emitted when MCP call arguments are generated (delta).
@immutable
class ResponseMcpCallArgumentsDeltaEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call_arguments.delta';

  @override
  final int? sequenceNumber;

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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, delta, sequenceNumber);

  @override
  String toString() => 'ResponseMcpCallArgumentsDeltaEvent(delta: $delta)';
}

/// Event emitted when MCP call arguments are complete.
@immutable
class ResponseMcpCallArgumentsDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_call_arguments.done';

  @override
  final int? sequenceNumber;

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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'arguments': arguments,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpCallArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          arguments == other.arguments &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode =>
      Object.hash(itemId, outputIndex, arguments, sequenceNumber);

  @override
  String toString() =>
      'ResponseMcpCallArgumentsDoneEvent(arguments: $arguments)';
}

/// Event emitted when MCP list tools is in progress.
@immutable
class ResponseMcpListToolsInProgressEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_list_tools.in_progress';

  @override
  final int? sequenceNumber;

  /// The ID of the MCP list tools item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpListToolsInProgressEvent].
  const ResponseMcpListToolsInProgressEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseMcpListToolsInProgressEvent] from JSON.
  factory ResponseMcpListToolsInProgressEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseMcpListToolsInProgressEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpListToolsInProgressEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseMcpListToolsInProgressEvent(itemId: $itemId)';
}

/// Event emitted when MCP list tools is completed.
@immutable
class ResponseMcpListToolsCompletedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_list_tools.completed';

  @override
  final int? sequenceNumber;

  /// The ID of the MCP list tools item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpListToolsCompletedEvent].
  const ResponseMcpListToolsCompletedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseMcpListToolsCompletedEvent] from JSON.
  factory ResponseMcpListToolsCompletedEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseMcpListToolsCompletedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpListToolsCompletedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseMcpListToolsCompletedEvent(itemId: $itemId)';
}

/// Event emitted when MCP list tools fails.
@immutable
class ResponseMcpListToolsFailedEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.mcp_list_tools.failed';

  @override
  final int? sequenceNumber;

  /// The ID of the MCP list tools item.
  final String itemId;

  /// The index of the output item.
  final int outputIndex;

  /// Creates a [ResponseMcpListToolsFailedEvent].
  const ResponseMcpListToolsFailedEvent({
    required this.itemId,
    required this.outputIndex,
    this.sequenceNumber,
  });

  /// Creates a [ResponseMcpListToolsFailedEvent] from JSON.
  factory ResponseMcpListToolsFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseMcpListToolsFailedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMcpListToolsFailedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, sequenceNumber);

  @override
  String toString() => 'ResponseMcpListToolsFailedEvent(itemId: $itemId)';
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomToolCallInputDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, delta, sequenceNumber);

  @override
  String toString() => 'ResponseCustomToolCallInputDeltaEvent(delta: $delta)';
}

/// Event emitted when custom tool call input is complete.
@immutable
class ResponseCustomToolCallInputDoneEvent extends ResponseStreamEvent {
  @override
  String get type => 'response.custom_tool_call_input.done';

  @override
  final int? sequenceNumber;

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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'item_id': itemId,
    'output_index': outputIndex,
    'input': input,
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCustomToolCallInputDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          input == other.input &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, input, sequenceNumber);

  @override
  String toString() => 'ResponseCustomToolCallInputDoneEvent(input: $input)';
}

// ============================================================
// Error Events
// ============================================================

/// Event emitted when an error occurs.
@immutable
class ErrorEvent extends ResponseStreamEvent {
  @override
  String get type => 'error';

  @override
  final int? sequenceNumber;

  /// The error code.
  final String code;

  /// The error message.
  final String message;

  /// The error parameter, if applicable.
  final String? param;

  /// Creates an [ErrorEvent].
  const ErrorEvent({
    required this.code,
    required this.message,
    this.param,
    this.sequenceNumber,
  });

  /// Creates an [ErrorEvent] from JSON.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>? ?? json;
    return ErrorEvent(
      code: error['code'] as String? ?? 'unknown',
      message: error['message'] as String? ?? 'Unknown error',
      param: error['param'] as String?,
      sequenceNumber: json['sequence_number'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'error': {
      'code': code,
      'message': message,
      if (param != null) 'param': param,
    },
    if (sequenceNumber != null) 'sequence_number': sequenceNumber,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          param == other.param &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(code, message, param, sequenceNumber);

  @override
  String toString() => 'ErrorEvent(code: $code, message: $message)';
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
