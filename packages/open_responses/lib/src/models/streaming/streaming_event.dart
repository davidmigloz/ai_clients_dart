import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../content/annotation.dart';
import '../content/logprob.dart';
import '../content/output_content.dart';
import '../content/reasoning_summary_content.dart';
import '../items/output_item.dart';
import '../response/error_payload.dart';
import '../response/response_resource.dart';

/// Server-sent event for response streaming.
sealed class StreamingEvent {
  /// Creates a [StreamingEvent].
  const StreamingEvent();

  /// Creates a [StreamingEvent] from JSON.
  factory StreamingEvent.fromJson(Map<String, dynamic> json) {
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

      // Reasoning events
      'response.reasoning.delta' => ReasoningDeltaEvent.fromJson(json),
      'response.reasoning.done' => ReasoningDoneEvent.fromJson(json),
      // OpenAI/LM Studio reasoning text events (maps to Open Responses events)
      'response.reasoning_text.delta' => ReasoningDeltaEvent.fromJson(json),
      'response.reasoning_text.done' => ReasoningDoneEvent.fromJson(json),
      'response.reasoning_summary_part.added' =>
        ReasoningSummaryPartAddedEvent.fromJson(json),
      'response.reasoning_summary_part.done' =>
        ReasoningSummaryPartDoneEvent.fromJson(json),
      // Canonical reasoning summary text events
      'response.reasoning_summary_text.delta' =>
        ReasoningSummaryDeltaEvent.fromJson(json),
      'response.reasoning_summary_text.done' =>
        ReasoningSummaryDoneEvent.fromJson(json),
      // Provider alias (without _text suffix)
      'response.reasoning_summary.delta' => ReasoningSummaryDeltaEvent.fromJson(
        json,
      ),
      'response.reasoning_summary.done' => ReasoningSummaryDoneEvent.fromJson(
        json,
      ),

      // Error event
      'error' => ErrorEvent.fromJson(json),

      _ => UnknownEvent(rawType: type, rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

// ============================================================================
// Response lifecycle events
// ============================================================================

/// Event indicating a response was created.
@immutable
class ResponseCreatedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.created';

  /// The sequence number of the event.
  ///
  /// Defaults to 0 if not provided by the server, for compatibility with
  /// providers that don't include this field in their responses.
  final int sequenceNumber;

  /// The created response.
  final ResponseResource response;

  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({
    required this.sequenceNumber,
    required this.response,
  });

  /// Creates a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCreatedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.created',
    'sequence_number': sequenceNumber,
    'response': response.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseCreatedEvent copyWith({
    int? sequenceNumber,
    ResponseResource? response,
  }) {
    return ResponseCreatedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          response == other.response;

  @override
  int get hashCode => Object.hash(sequenceNumber, response);

  @override
  String toString() =>
      'ResponseCreatedEvent(sequenceNumber: $sequenceNumber, response: $response)';
}

/// Event indicating a response was queued.
@immutable
class ResponseQueuedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.queued';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The queued response.
  final ResponseResource response;

  /// Creates a [ResponseQueuedEvent].
  const ResponseQueuedEvent({
    required this.sequenceNumber,
    required this.response,
  });

  /// Creates a [ResponseQueuedEvent] from JSON.
  factory ResponseQueuedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseQueuedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.queued',
    'sequence_number': sequenceNumber,
    'response': response.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseQueuedEvent copyWith({
    int? sequenceNumber,
    ResponseResource? response,
  }) {
    return ResponseQueuedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseQueuedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          response == other.response;

  @override
  int get hashCode => Object.hash(sequenceNumber, response);

  @override
  String toString() =>
      'ResponseQueuedEvent(sequenceNumber: $sequenceNumber, response: $response)';
}

/// Event indicating a response is in progress.
@immutable
class ResponseInProgressEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.in_progress';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The in-progress response.
  final ResponseResource response;

  /// Creates a [ResponseInProgressEvent].
  const ResponseInProgressEvent({
    required this.sequenceNumber,
    required this.response,
  });

  /// Creates a [ResponseInProgressEvent] from JSON.
  factory ResponseInProgressEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInProgressEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.in_progress',
    'sequence_number': sequenceNumber,
    'response': response.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseInProgressEvent copyWith({
    int? sequenceNumber,
    ResponseResource? response,
  }) {
    return ResponseInProgressEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInProgressEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          response == other.response;

  @override
  int get hashCode => Object.hash(sequenceNumber, response);

  @override
  String toString() =>
      'ResponseInProgressEvent(sequenceNumber: $sequenceNumber, response: $response)';
}

/// Event indicating a response completed successfully.
@immutable
class ResponseCompletedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.completed';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The completed response.
  final ResponseResource response;

  /// Creates a [ResponseCompletedEvent].
  const ResponseCompletedEvent({
    required this.sequenceNumber,
    required this.response,
  });

  /// Creates a [ResponseCompletedEvent] from JSON.
  factory ResponseCompletedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCompletedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.completed',
    'sequence_number': sequenceNumber,
    'response': response.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseCompletedEvent copyWith({
    int? sequenceNumber,
    ResponseResource? response,
  }) {
    return ResponseCompletedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompletedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          response == other.response;

  @override
  int get hashCode => Object.hash(sequenceNumber, response);

  @override
  String toString() =>
      'ResponseCompletedEvent(sequenceNumber: $sequenceNumber, response: $response)';
}

/// Event indicating a response failed.
@immutable
class ResponseFailedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.failed';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The failed response.
  final ResponseResource response;

  /// Creates a [ResponseFailedEvent].
  const ResponseFailedEvent({
    required this.sequenceNumber,
    required this.response,
  });

  /// Creates a [ResponseFailedEvent] from JSON.
  factory ResponseFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseFailedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.failed',
    'sequence_number': sequenceNumber,
    'response': response.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseFailedEvent copyWith({
    int? sequenceNumber,
    ResponseResource? response,
  }) {
    return ResponseFailedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFailedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          response == other.response;

  @override
  int get hashCode => Object.hash(sequenceNumber, response);

  @override
  String toString() =>
      'ResponseFailedEvent(sequenceNumber: $sequenceNumber, response: $response)';
}

/// Event indicating a response was incomplete.
@immutable
class ResponseIncompleteEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.incomplete';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The incomplete response.
  final ResponseResource response;

  /// Creates a [ResponseIncompleteEvent].
  const ResponseIncompleteEvent({
    required this.sequenceNumber,
    required this.response,
  });

  /// Creates a [ResponseIncompleteEvent] from JSON.
  factory ResponseIncompleteEvent.fromJson(Map<String, dynamic> json) {
    return ResponseIncompleteEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.incomplete',
    'sequence_number': sequenceNumber,
    'response': response.toJson(),
  };

  /// Creates a copy with replaced values.
  ResponseIncompleteEvent copyWith({
    int? sequenceNumber,
    ResponseResource? response,
  }) {
    return ResponseIncompleteEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseIncompleteEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          response == other.response;

  @override
  int get hashCode => Object.hash(sequenceNumber, response);

  @override
  String toString() =>
      'ResponseIncompleteEvent(sequenceNumber: $sequenceNumber, response: $response)';
}

// ============================================================================
// Output item events
// ============================================================================

/// Event indicating an output item was added.
@immutable
class OutputItemAddedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.output_item.added';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The index of the output item.
  final int outputIndex;

  /// The added item.
  final OutputItem item;

  /// Creates an [OutputItemAddedEvent].
  const OutputItemAddedEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.item,
  });

  /// Creates an [OutputItemAddedEvent] from JSON.
  factory OutputItemAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemAddedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_item.added',
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'item': item.toJson(),
  };

  /// Creates a copy with replaced values.
  OutputItemAddedEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    OutputItem? item,
  }) {
    return OutputItemAddedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      outputIndex: outputIndex ?? this.outputIndex,
      item: item ?? this.item,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemAddedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          item == other.item;

  @override
  int get hashCode => Object.hash(sequenceNumber, outputIndex, item);

  @override
  String toString() =>
      'OutputItemAddedEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, item: $item)';
}

/// Event indicating an output item is done.
@immutable
class OutputItemDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.output_item.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The index of the output item.
  final int outputIndex;

  /// The completed item.
  final OutputItem item;

  /// Creates an [OutputItemDoneEvent].
  const OutputItemDoneEvent({
    required this.sequenceNumber,
    required this.outputIndex,
    required this.item,
  });

  /// Creates an [OutputItemDoneEvent] from JSON.
  factory OutputItemDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_item.done',
    'sequence_number': sequenceNumber,
    'output_index': outputIndex,
    'item': item.toJson(),
  };

  /// Creates a copy with replaced values.
  OutputItemDoneEvent copyWith({
    int? sequenceNumber,
    int? outputIndex,
    OutputItem? item,
  }) {
    return OutputItemDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      outputIndex: outputIndex ?? this.outputIndex,
      item: item ?? this.item,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          outputIndex == other.outputIndex &&
          item == other.item;

  @override
  int get hashCode => Object.hash(sequenceNumber, outputIndex, item);

  @override
  String toString() =>
      'OutputItemDoneEvent(sequenceNumber: $sequenceNumber, outputIndex: $outputIndex, item: $item)';
}

// ============================================================================
// Content part events
// ============================================================================

/// Event indicating a content part was added.
@immutable
class ContentPartAddedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.content_part.added';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The added content part.
  final OutputContent part;

  /// Creates a [ContentPartAddedEvent].
  const ContentPartAddedEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
  });

  /// Creates a [ContentPartAddedEvent] from JSON.
  factory ContentPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartAddedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.content_part.added',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
  };

  /// Creates a copy with replaced values.
  ContentPartAddedEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    OutputContent? part,
  }) {
    return ContentPartAddedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      part: part ?? this.part,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPartAddedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          part == other.part;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, contentIndex, part);

  @override
  String toString() =>
      'ContentPartAddedEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, part: $part)';
}

/// Event indicating a content part is done.
@immutable
class ContentPartDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.content_part.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The completed content part.
  final OutputContent part;

  /// Creates a [ContentPartDoneEvent].
  const ContentPartDoneEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
  });

  /// Creates a [ContentPartDoneEvent] from JSON.
  factory ContentPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.content_part.done',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
  };

  /// Creates a copy with replaced values.
  ContentPartDoneEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    OutputContent? part,
  }) {
    return ContentPartDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      part: part ?? this.part,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPartDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          part == other.part;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, contentIndex, part);

  @override
  String toString() =>
      'ContentPartDoneEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, part: $part)';
}

// ============================================================================
// Text events
// ============================================================================

/// Event with a text delta.
@immutable
class OutputTextDeltaEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.output_text.delta';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The text delta.
  final String delta;

  /// Token log probabilities emitted with the delta.
  final List<LogProb> logprobs;

  /// An obfuscation string added to pad the event payload.
  final String? obfuscation;

  /// Creates an [OutputTextDeltaEvent].
  const OutputTextDeltaEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
    this.logprobs = const [],
    this.obfuscation,
  });

  /// Creates an [OutputTextDeltaEvent] from JSON.
  factory OutputTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextDeltaEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      logprobs:
          (json['logprobs'] as List?)
              ?.map((e) => LogProb.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      obfuscation: json['obfuscation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_text.delta',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
    if (logprobs.isNotEmpty)
      'logprobs': logprobs.map((e) => e.toJson()).toList(),
    if (obfuscation != null) 'obfuscation': obfuscation,
  };

  /// Creates a copy with replaced values.
  OutputTextDeltaEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    String? delta,
    List<LogProb>? logprobs,
    Object? obfuscation = unsetCopyWithValue,
  }) {
    return OutputTextDeltaEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      delta: delta ?? this.delta,
      logprobs: logprobs ?? this.logprobs,
      obfuscation: obfuscation == unsetCopyWithValue
          ? this.obfuscation
          : obfuscation as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          listsEqual(logprobs, other.logprobs) &&
          obfuscation == other.obfuscation;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    itemId,
    outputIndex,
    contentIndex,
    delta,
    Object.hashAll(logprobs),
    obfuscation,
  );

  @override
  String toString() =>
      'OutputTextDeltaEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, delta: $delta, logprobs: $logprobs, obfuscation: $obfuscation)';
}

/// Event indicating output text is done.
@immutable
class OutputTextDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.output_text.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The complete text.
  final String text;

  /// Token log probabilities for the complete text.
  final List<LogProb> logprobs;

  /// Creates an [OutputTextDoneEvent].
  const OutputTextDoneEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.text,
    this.logprobs = const [],
  });

  /// Creates an [OutputTextDoneEvent] from JSON.
  factory OutputTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
      logprobs:
          (json['logprobs'] as List?)
              ?.map((e) => LogProb.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_text.done',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'text': text,
    if (logprobs.isNotEmpty)
      'logprobs': logprobs.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  OutputTextDoneEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    String? text,
    List<LogProb>? logprobs,
  }) {
    return OutputTextDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      text: text ?? this.text,
      logprobs: logprobs ?? this.logprobs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          text == other.text &&
          listsEqual(logprobs, other.logprobs);

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    itemId,
    outputIndex,
    contentIndex,
    text,
    Object.hashAll(logprobs),
  );

  @override
  String toString() =>
      'OutputTextDoneEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, text: $text, logprobs: $logprobs)';
}

/// Event indicating an annotation was added.
@immutable
class OutputTextAnnotationAddedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.output_text.annotation.added';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The annotation index.
  final int annotationIndex;

  /// The added annotation.
  final Annotation annotation;

  /// Creates an [OutputTextAnnotationAddedEvent].
  const OutputTextAnnotationAddedEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.annotationIndex,
    required this.annotation,
  });

  /// Creates an [OutputTextAnnotationAddedEvent] from JSON.
  factory OutputTextAnnotationAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextAnnotationAddedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      annotationIndex: json['annotation_index'] as int,
      annotation: Annotation.fromJson(
        json['annotation'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_text.annotation.added',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'annotation_index': annotationIndex,
    'annotation': annotation.toJson(),
  };

  /// Creates a copy with replaced values.
  OutputTextAnnotationAddedEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    int? annotationIndex,
    Annotation? annotation,
  }) {
    return OutputTextAnnotationAddedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      annotationIndex: annotationIndex ?? this.annotationIndex,
      annotation: annotation ?? this.annotation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextAnnotationAddedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          annotationIndex == other.annotationIndex &&
          annotation == other.annotation;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    itemId,
    outputIndex,
    contentIndex,
    annotationIndex,
    annotation,
  );

  @override
  String toString() =>
      'OutputTextAnnotationAddedEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, annotationIndex: $annotationIndex, annotation: $annotation)';
}

// ============================================================================
// Refusal events
// ============================================================================

/// Event with a refusal delta.
@immutable
class RefusalDeltaEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.refusal.delta';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The refusal delta.
  final String delta;

  /// Creates a [RefusalDeltaEvent].
  const RefusalDeltaEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates a [RefusalDeltaEvent] from JSON.
  factory RefusalDeltaEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDeltaEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.refusal.delta',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  /// Creates a copy with replaced values.
  RefusalDeltaEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    String? delta,
  }) {
    return RefusalDeltaEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      delta: delta ?? this.delta,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, contentIndex, delta);

  @override
  String toString() =>
      'RefusalDeltaEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, delta: $delta)';
}

/// Event indicating refusal is done.
@immutable
class RefusalDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.refusal.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The complete refusal.
  final String refusal;

  /// Creates a [RefusalDoneEvent].
  const RefusalDoneEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.refusal,
  });

  /// Creates a [RefusalDoneEvent] from JSON.
  factory RefusalDoneEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      refusal: json['refusal'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.refusal.done',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'refusal': refusal,
  };

  /// Creates a copy with replaced values.
  RefusalDoneEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    String? refusal,
  }) {
    return RefusalDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      refusal: refusal ?? this.refusal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          refusal == other.refusal;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, contentIndex, refusal);

  @override
  String toString() =>
      'RefusalDoneEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, refusal: $refusal)';
}

// ============================================================================
// Function call events
// ============================================================================

/// Event with function call arguments delta.
@immutable
class FunctionCallArgumentsDeltaEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.function_call_arguments.delta';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The arguments delta.
  final String delta;

  /// An obfuscation string added to pad the event payload.
  final String? obfuscation;

  /// Creates a [FunctionCallArgumentsDeltaEvent].
  const FunctionCallArgumentsDeltaEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.delta,
    this.obfuscation,
  });

  /// Creates a [FunctionCallArgumentsDeltaEvent] from JSON.
  factory FunctionCallArgumentsDeltaEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDeltaEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      delta: json['delta'] as String,
      obfuscation: json['obfuscation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.function_call_arguments.delta',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'delta': delta,
    if (obfuscation != null) 'obfuscation': obfuscation,
  };

  /// Creates a copy with replaced values.
  FunctionCallArgumentsDeltaEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    String? delta,
    Object? obfuscation = unsetCopyWithValue,
  }) {
    return FunctionCallArgumentsDeltaEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      delta: delta ?? this.delta,
      obfuscation: obfuscation == unsetCopyWithValue
          ? this.obfuscation
          : obfuscation as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          delta == other.delta &&
          obfuscation == other.obfuscation;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, delta, obfuscation);

  @override
  String toString() =>
      'FunctionCallArgumentsDeltaEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, delta: $delta, obfuscation: $obfuscation)';
}

/// Event indicating function call arguments are done.
@immutable
class FunctionCallArgumentsDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.function_call_arguments.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The complete arguments.
  final String arguments;

  /// Creates a [FunctionCallArgumentsDoneEvent].
  const FunctionCallArgumentsDoneEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.arguments,
  });

  /// Creates a [FunctionCallArgumentsDoneEvent] from JSON.
  factory FunctionCallArgumentsDoneEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      arguments: json['arguments'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.function_call_arguments.done',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'arguments': arguments,
  };

  /// Creates a copy with replaced values.
  FunctionCallArgumentsDoneEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    String? arguments,
  }) {
    return FunctionCallArgumentsDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          arguments == other.arguments;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, arguments);

  @override
  String toString() =>
      'FunctionCallArgumentsDoneEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, arguments: $arguments)';
}

// ============================================================================
// Reasoning events
// ============================================================================

/// Event with reasoning delta.
@immutable
class ReasoningDeltaEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.reasoning.delta';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The reasoning delta.
  final String delta;

  /// An obfuscation string added to pad the event payload.
  final String? obfuscation;

  /// Creates a [ReasoningDeltaEvent].
  const ReasoningDeltaEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
    this.obfuscation,
  });

  /// Creates a [ReasoningDeltaEvent] from JSON.
  factory ReasoningDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningDeltaEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      obfuscation: json['obfuscation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning.delta',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
    if (obfuscation != null) 'obfuscation': obfuscation,
  };

  /// Creates a copy with replaced values.
  ReasoningDeltaEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    String? delta,
    Object? obfuscation = unsetCopyWithValue,
  }) {
    return ReasoningDeltaEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      delta: delta ?? this.delta,
      obfuscation: obfuscation == unsetCopyWithValue
          ? this.obfuscation
          : obfuscation as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          obfuscation == other.obfuscation;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    itemId,
    outputIndex,
    contentIndex,
    delta,
    obfuscation,
  );

  @override
  String toString() =>
      'ReasoningDeltaEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, delta: $delta, obfuscation: $obfuscation)';
}

/// Event indicating reasoning is done.
@immutable
class ReasoningDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.reasoning.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The complete reasoning text.
  final String text;

  /// Creates a [ReasoningDoneEvent].
  const ReasoningDoneEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.text,
  });

  /// Creates a [ReasoningDoneEvent] from JSON.
  factory ReasoningDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning.done',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'text': text,
  };

  /// Creates a copy with replaced values.
  ReasoningDoneEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? contentIndex,
    String? text,
  }) {
    return ReasoningDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      contentIndex: contentIndex ?? this.contentIndex,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          text == other.text;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, contentIndex, text);

  @override
  String toString() =>
      'ReasoningDoneEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex, text: $text)';
}

/// Event indicating a reasoning summary part was added.
@immutable
class ReasoningSummaryPartAddedEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.reasoning_summary_part.added';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The summary index.
  final int summaryIndex;

  /// The summary part, if available.
  final ReasoningSummaryContent? part;

  /// Creates a [ReasoningSummaryPartAddedEvent].
  const ReasoningSummaryPartAddedEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.summaryIndex,
    this.part,
  });

  /// Creates a [ReasoningSummaryPartAddedEvent] from JSON.
  factory ReasoningSummaryPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartAddedEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      part: json['part'] != null
          ? ReasoningSummaryContent.fromJson(
              json['part'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary_part.added',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    if (part != null) 'part': part!.toJson(),
  };

  /// Creates a copy with replaced values.
  ReasoningSummaryPartAddedEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? summaryIndex,
    Object? part = unsetCopyWithValue,
  }) {
    return ReasoningSummaryPartAddedEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      summaryIndex: summaryIndex ?? this.summaryIndex,
      part: part == unsetCopyWithValue
          ? this.part
          : part as ReasoningSummaryContent?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartAddedEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          part == other.part;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, summaryIndex, part);

  @override
  String toString() =>
      'ReasoningSummaryPartAddedEvent(summaryIndex: $summaryIndex, part: $part)';
}

/// Event indicating a reasoning summary part is done.
@immutable
class ReasoningSummaryPartDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.reasoning_summary_part.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The summary index.
  final int summaryIndex;

  /// The summary part.
  final ReasoningSummaryContent part;

  /// Creates a [ReasoningSummaryPartDoneEvent].
  const ReasoningSummaryPartDoneEvent({
    required this.sequenceNumber,
    required this.itemId,
    required this.outputIndex,
    required this.summaryIndex,
    required this.part,
  });

  /// Creates a [ReasoningSummaryPartDoneEvent] from JSON.
  factory ReasoningSummaryPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
      part: ReasoningSummaryContent.fromJson(
        json['part'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary_part.done',
    'sequence_number': sequenceNumber,
    'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    'part': part.toJson(),
  };

  /// Creates a copy with replaced values.
  ReasoningSummaryPartDoneEvent copyWith({
    int? sequenceNumber,
    String? itemId,
    int? outputIndex,
    int? summaryIndex,
    ReasoningSummaryContent? part,
  }) {
    return ReasoningSummaryPartDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId ?? this.itemId,
      outputIndex: outputIndex ?? this.outputIndex,
      summaryIndex: summaryIndex ?? this.summaryIndex,
      part: part ?? this.part,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          part == other.part;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, summaryIndex, part);

  @override
  String toString() =>
      'ReasoningSummaryPartDoneEvent(sequenceNumber: $sequenceNumber, itemId: $itemId, outputIndex: $outputIndex, summaryIndex: $summaryIndex, part: $part)';
}

/// Event with reasoning summary delta.
@immutable
class ReasoningSummaryDeltaEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.reasoning_summary.delta';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String? itemId;

  /// The output index.
  final int? outputIndex;

  /// The summary index.
  final int? summaryIndex;

  /// The summary delta.
  final String delta;

  /// An obfuscation string added to pad the event payload.
  final String? obfuscation;

  /// Creates a [ReasoningSummaryDeltaEvent].
  const ReasoningSummaryDeltaEvent({
    required this.sequenceNumber,
    this.itemId,
    this.outputIndex,
    this.summaryIndex,
    required this.delta,
    this.obfuscation,
  });

  /// Creates a [ReasoningSummaryDeltaEvent] from JSON.
  factory ReasoningSummaryDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryDeltaEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int?,
      summaryIndex: json['summary_index'] as int?,
      delta: json['delta'] as String,
      obfuscation: json['obfuscation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary.delta',
    'sequence_number': sequenceNumber,
    if (itemId != null) 'item_id': itemId,
    if (outputIndex != null) 'output_index': outputIndex,
    if (summaryIndex != null) 'summary_index': summaryIndex,
    'delta': delta,
    if (obfuscation != null) 'obfuscation': obfuscation,
  };

  /// Creates a copy with replaced values.
  ReasoningSummaryDeltaEvent copyWith({
    int? sequenceNumber,
    Object? itemId = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
    Object? summaryIndex = unsetCopyWithValue,
    String? delta,
    Object? obfuscation = unsetCopyWithValue,
  }) {
    return ReasoningSummaryDeltaEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      outputIndex: outputIndex == unsetCopyWithValue
          ? this.outputIndex
          : outputIndex as int?,
      summaryIndex: summaryIndex == unsetCopyWithValue
          ? this.summaryIndex
          : summaryIndex as int?,
      delta: delta ?? this.delta,
      obfuscation: obfuscation == unsetCopyWithValue
          ? this.obfuscation
          : obfuscation as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryDeltaEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          delta == other.delta &&
          obfuscation == other.obfuscation;

  @override
  int get hashCode => Object.hash(
    sequenceNumber,
    itemId,
    outputIndex,
    summaryIndex,
    delta,
    obfuscation,
  );

  @override
  String toString() => 'ReasoningSummaryDeltaEvent(delta: $delta)';
}

/// Event indicating reasoning summary is done.
@immutable
class ReasoningSummaryDoneEvent extends StreamingEvent {
  /// The event type.
  String get type => 'response.reasoning_summary.done';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The item ID.
  final String? itemId;

  /// The output index.
  final int? outputIndex;

  /// The summary index.
  final int? summaryIndex;

  /// The complete summary text.
  final String text;

  /// Creates a [ReasoningSummaryDoneEvent].
  const ReasoningSummaryDoneEvent({
    required this.sequenceNumber,
    this.itemId,
    this.outputIndex,
    this.summaryIndex,
    required this.text,
  });

  /// Creates a [ReasoningSummaryDoneEvent] from JSON.
  factory ReasoningSummaryDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryDoneEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int?,
      summaryIndex: json['summary_index'] as int?,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary.done',
    'sequence_number': sequenceNumber,
    if (itemId != null) 'item_id': itemId,
    if (outputIndex != null) 'output_index': outputIndex,
    if (summaryIndex != null) 'summary_index': summaryIndex,
    'text': text,
  };

  /// Creates a copy with replaced values.
  ReasoningSummaryDoneEvent copyWith({
    int? sequenceNumber,
    Object? itemId = unsetCopyWithValue,
    Object? outputIndex = unsetCopyWithValue,
    Object? summaryIndex = unsetCopyWithValue,
    String? text,
  }) {
    return ReasoningSummaryDoneEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      itemId: itemId == unsetCopyWithValue ? this.itemId : itemId as String?,
      outputIndex: outputIndex == unsetCopyWithValue
          ? this.outputIndex
          : outputIndex as int?,
      summaryIndex: summaryIndex == unsetCopyWithValue
          ? this.summaryIndex
          : summaryIndex as int?,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryDoneEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          text == other.text;

  @override
  int get hashCode =>
      Object.hash(sequenceNumber, itemId, outputIndex, summaryIndex, text);

  @override
  String toString() => 'ReasoningSummaryDoneEvent(text: $text)';
}

// ============================================================================
// Error event
// ============================================================================

/// Error event during streaming.
@immutable
class ErrorEvent extends StreamingEvent {
  /// The event type.
  String get type => 'error';

  /// The sequence number of the event.
  final int sequenceNumber;

  /// The error information.
  final ErrorPayload error;

  /// Creates an [ErrorEvent].
  const ErrorEvent({required this.sequenceNumber, required this.error});

  /// Creates an [ErrorEvent] from JSON.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map<String, dynamic>) {
      return ErrorEvent(
        sequenceNumber: json['sequence_number'] as int? ?? 0,
        error: ErrorPayload.fromJson(error),
      );
    }
    if (error is String) {
      return ErrorEvent(
        sequenceNumber: json['sequence_number'] as int? ?? 0,
        error: ErrorPayload(type: 'stream_error', message: error),
      );
    }
    // Handle non-JSON SSE error events (e.g., plain-text payloads)
    return ErrorEvent(
      sequenceNumber: json['sequence_number'] as int? ?? 0,
      error: ErrorPayload(
        type: 'stream_error',
        message: (json['_rawData'] as String?) ?? 'Unknown stream error',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'error',
    'sequence_number': sequenceNumber,
    'error': error.toJson(),
  };

  /// Creates a copy with replaced values.
  ErrorEvent copyWith({int? sequenceNumber, ErrorPayload? error}) {
    return ErrorEvent(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          sequenceNumber == other.sequenceNumber &&
          error == other.error;

  @override
  int get hashCode => Object.hash(sequenceNumber, error);

  @override
  String toString() =>
      'ErrorEvent(sequenceNumber: $sequenceNumber, error: $error)';
}

// ============================================================================
// Unknown event
// ============================================================================

/// An unrecognized streaming event type.
///
/// This is returned for event types not yet supported by this library,
/// allowing streams to continue processing without throwing. The raw JSON
/// is preserved for inspection.
@immutable
class UnknownEvent extends StreamingEvent {
  /// The event type string as received.
  String get type => rawType;

  /// The raw event type string.
  final String rawType;

  /// The raw JSON payload.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownEvent].
  const UnknownEvent({required this.rawType, required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownEvent &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownEvent(rawType: $rawType)';
}
