import 'package:meta/meta.dart';

import '../content/annotation.dart';
import '../content/output_content.dart';
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
      'response.reasoning_summary_part.added' =>
        ReasoningSummaryPartAddedEvent.fromJson(json),
      'response.reasoning_summary_part.done' =>
        ReasoningSummaryPartDoneEvent.fromJson(json),
      'response.reasoning_summary.delta' => ReasoningSummaryDeltaEvent.fromJson(
        json,
      ),
      'response.reasoning_summary.done' => ReasoningSummaryDoneEvent.fromJson(
        json,
      ),
      // Ollama-specific reasoning events (maps to standard events)
      'response.reasoning_summary_text.delta' =>
        ReasoningSummaryDeltaEvent.fromJson(json),
      'response.reasoning_summary_text.done' =>
        ReasoningSummaryDoneEvent.fromJson(json),

      // Error event
      'error' => ErrorEvent.fromJson(json),

      _ => throw FormatException('Unknown StreamingEvent type: $type'),
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
  /// The created response.
  final ResponseResource response;

  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({required this.response});

  /// Creates a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCreatedEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.created',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseCreatedEvent(response: $response)';
}

/// Event indicating a response was queued.
@immutable
class ResponseQueuedEvent extends StreamingEvent {
  /// The queued response.
  final ResponseResource response;

  /// Creates a [ResponseQueuedEvent].
  const ResponseQueuedEvent({required this.response});

  /// Creates a [ResponseQueuedEvent] from JSON.
  factory ResponseQueuedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseQueuedEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.queued',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseQueuedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseQueuedEvent(response: $response)';
}

/// Event indicating a response is in progress.
@immutable
class ResponseInProgressEvent extends StreamingEvent {
  /// The in-progress response.
  final ResponseResource response;

  /// Creates a [ResponseInProgressEvent].
  const ResponseInProgressEvent({required this.response});

  /// Creates a [ResponseInProgressEvent] from JSON.
  factory ResponseInProgressEvent.fromJson(Map<String, dynamic> json) {
    return ResponseInProgressEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.in_progress',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInProgressEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseInProgressEvent(response: $response)';
}

/// Event indicating a response completed successfully.
@immutable
class ResponseCompletedEvent extends StreamingEvent {
  /// The completed response.
  final ResponseResource response;

  /// Creates a [ResponseCompletedEvent].
  const ResponseCompletedEvent({required this.response});

  /// Creates a [ResponseCompletedEvent] from JSON.
  factory ResponseCompletedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCompletedEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.completed',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompletedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseCompletedEvent(response: $response)';
}

/// Event indicating a response failed.
@immutable
class ResponseFailedEvent extends StreamingEvent {
  /// The failed response.
  final ResponseResource response;

  /// Creates a [ResponseFailedEvent].
  const ResponseFailedEvent({required this.response});

  /// Creates a [ResponseFailedEvent] from JSON.
  factory ResponseFailedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseFailedEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.failed',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFailedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseFailedEvent(response: $response)';
}

/// Event indicating a response was incomplete.
@immutable
class ResponseIncompleteEvent extends StreamingEvent {
  /// The incomplete response.
  final ResponseResource response;

  /// Creates a [ResponseIncompleteEvent].
  const ResponseIncompleteEvent({required this.response});

  /// Creates a [ResponseIncompleteEvent] from JSON.
  factory ResponseIncompleteEvent.fromJson(Map<String, dynamic> json) {
    return ResponseIncompleteEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.incomplete',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseIncompleteEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseIncompleteEvent(response: $response)';
}

// ============================================================================
// Output item events
// ============================================================================

/// Event indicating an output item was added.
@immutable
class OutputItemAddedEvent extends StreamingEvent {
  /// The index of the output item.
  final int outputIndex;

  /// The added item.
  final OutputItem item;

  /// Creates an [OutputItemAddedEvent].
  const OutputItemAddedEvent({required this.outputIndex, required this.item});

  /// Creates an [OutputItemAddedEvent] from JSON.
  factory OutputItemAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemAddedEvent(
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_item.added',
    'output_index': outputIndex,
    'item': item.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemAddedEvent &&
          runtimeType == other.runtimeType &&
          outputIndex == other.outputIndex &&
          item == other.item;

  @override
  int get hashCode => Object.hash(outputIndex, item);

  @override
  String toString() =>
      'OutputItemAddedEvent(outputIndex: $outputIndex, item: $item)';
}

/// Event indicating an output item is done.
@immutable
class OutputItemDoneEvent extends StreamingEvent {
  /// The index of the output item.
  final int outputIndex;

  /// The completed item.
  final OutputItem item;

  /// Creates an [OutputItemDoneEvent].
  const OutputItemDoneEvent({required this.outputIndex, required this.item});

  /// Creates an [OutputItemDoneEvent] from JSON.
  factory OutputItemDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputItemDoneEvent(
      outputIndex: json['output_index'] as int,
      item: OutputItem.fromJson(json['item'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_item.done',
    'output_index': outputIndex,
    'item': item.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputItemDoneEvent &&
          runtimeType == other.runtimeType &&
          outputIndex == other.outputIndex &&
          item == other.item;

  @override
  int get hashCode => Object.hash(outputIndex, item);

  @override
  String toString() =>
      'OutputItemDoneEvent(outputIndex: $outputIndex, item: $item)';
}

// ============================================================================
// Content part events
// ============================================================================

/// Event indicating a content part was added.
@immutable
class ContentPartAddedEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
  });

  /// Creates a [ContentPartAddedEvent] from JSON.
  factory ContentPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartAddedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.content_part.added',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPartAddedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          part == other.part;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, part);

  @override
  String toString() =>
      'ContentPartAddedEvent(itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex)';
}

/// Event indicating a content part is done.
@immutable
class ContentPartDoneEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.part,
  });

  /// Creates a [ContentPartDoneEvent] from JSON.
  factory ContentPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ContentPartDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      part: OutputContent.fromJson(json['part'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.content_part.done',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'part': part.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPartDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          part == other.part;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, part);

  @override
  String toString() =>
      'ContentPartDoneEvent(itemId: $itemId, outputIndex: $outputIndex, contentIndex: $contentIndex)';
}

// ============================================================================
// Text events
// ============================================================================

/// Event with a text delta.
@immutable
class OutputTextDeltaEvent extends StreamingEvent {
  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The text delta.
  final String delta;

  /// Creates an [OutputTextDeltaEvent].
  const OutputTextDeltaEvent({
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates an [OutputTextDeltaEvent] from JSON.
  factory OutputTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_text.delta',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, delta);

  @override
  String toString() => 'OutputTextDeltaEvent(delta: $delta)';
}

/// Event indicating output text is done.
@immutable
class OutputTextDoneEvent extends StreamingEvent {
  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The complete text.
  final String text;

  /// Creates an [OutputTextDoneEvent].
  const OutputTextDoneEvent({
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.text,
  });

  /// Creates an [OutputTextDoneEvent] from JSON.
  factory OutputTextDoneEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.output_text.done',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'text': text,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          text == other.text;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, text);

  @override
  String toString() => 'OutputTextDoneEvent(text: $text)';
}

/// Event indicating an annotation was added.
@immutable
class OutputTextAnnotationAddedEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.annotationIndex,
    required this.annotation,
  });

  /// Creates an [OutputTextAnnotationAddedEvent] from JSON.
  factory OutputTextAnnotationAddedEvent.fromJson(Map<String, dynamic> json) {
    return OutputTextAnnotationAddedEvent(
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
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'annotation_index': annotationIndex,
    'annotation': annotation.toJson(),
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
          annotation == other.annotation;

  @override
  int get hashCode => Object.hash(
    itemId,
    outputIndex,
    contentIndex,
    annotationIndex,
    annotation,
  );

  @override
  String toString() =>
      'OutputTextAnnotationAddedEvent(annotationIndex: $annotationIndex, annotation: $annotation)';
}

// ============================================================================
// Refusal events
// ============================================================================

/// Event with a refusal delta.
@immutable
class RefusalDeltaEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates a [RefusalDeltaEvent] from JSON.
  factory RefusalDeltaEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.refusal.delta',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, delta);

  @override
  String toString() => 'RefusalDeltaEvent(delta: $delta)';
}

/// Event indicating refusal is done.
@immutable
class RefusalDoneEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.refusal,
  });

  /// Creates a [RefusalDoneEvent] from JSON.
  factory RefusalDoneEvent.fromJson(Map<String, dynamic> json) {
    return RefusalDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      refusal: json['refusal'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.refusal.done',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'refusal': refusal,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          refusal == other.refusal;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, refusal);

  @override
  String toString() => 'RefusalDoneEvent(refusal: $refusal)';
}

// ============================================================================
// Function call events
// ============================================================================

/// Event with function call arguments delta.
@immutable
class FunctionCallArgumentsDeltaEvent extends StreamingEvent {
  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The call ID.
  final String callId;

  /// The arguments delta.
  final String delta;

  /// Creates a [FunctionCallArgumentsDeltaEvent].
  const FunctionCallArgumentsDeltaEvent({
    required this.itemId,
    required this.outputIndex,
    required this.callId,
    required this.delta,
  });

  /// Creates a [FunctionCallArgumentsDeltaEvent] from JSON.
  factory FunctionCallArgumentsDeltaEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      callId: json['call_id'] as String,
      delta: json['delta'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.function_call_arguments.delta',
    'item_id': itemId,
    'output_index': outputIndex,
    'call_id': callId,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          callId == other.callId &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, callId, delta);

  @override
  String toString() =>
      'FunctionCallArgumentsDeltaEvent(callId: $callId, delta: $delta)';
}

/// Event indicating function call arguments are done.
@immutable
class FunctionCallArgumentsDoneEvent extends StreamingEvent {
  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The call ID.
  final String callId;

  /// The complete arguments.
  final String arguments;

  /// Creates a [FunctionCallArgumentsDoneEvent].
  const FunctionCallArgumentsDoneEvent({
    required this.itemId,
    required this.outputIndex,
    required this.callId,
    required this.arguments,
  });

  /// Creates a [FunctionCallArgumentsDoneEvent] from JSON.
  factory FunctionCallArgumentsDoneEvent.fromJson(Map<String, dynamic> json) {
    return FunctionCallArgumentsDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      callId: json['call_id'] as String,
      arguments: json['arguments'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.function_call_arguments.done',
    'item_id': itemId,
    'output_index': outputIndex,
    'call_id': callId,
    'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          callId == other.callId &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, callId, arguments);

  @override
  String toString() =>
      'FunctionCallArgumentsDoneEvent(callId: $callId, arguments: $arguments)';
}

// ============================================================================
// Reasoning events
// ============================================================================

/// Event with reasoning delta.
@immutable
class ReasoningDeltaEvent extends StreamingEvent {
  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The content index.
  final int contentIndex;

  /// The reasoning delta.
  final String delta;

  /// Creates a [ReasoningDeltaEvent].
  const ReasoningDeltaEvent({
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.delta,
  });

  /// Creates a [ReasoningDeltaEvent] from JSON.
  factory ReasoningDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningDeltaEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning.delta',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, delta);

  @override
  String toString() => 'ReasoningDeltaEvent(delta: $delta)';
}

/// Event indicating reasoning is done.
@immutable
class ReasoningDoneEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.contentIndex,
    required this.text,
  });

  /// Creates a [ReasoningDoneEvent] from JSON.
  factory ReasoningDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningDoneEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      contentIndex: json['content_index'] as int,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning.done',
    'item_id': itemId,
    'output_index': outputIndex,
    'content_index': contentIndex,
    'text': text,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          contentIndex == other.contentIndex &&
          text == other.text;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, contentIndex, text);

  @override
  String toString() => 'ReasoningDoneEvent(text: $text)';
}

/// Event indicating a reasoning summary part was added.
@immutable
class ReasoningSummaryPartAddedEvent extends StreamingEvent {
  /// The item ID.
  final String itemId;

  /// The output index.
  final int outputIndex;

  /// The summary index.
  final int summaryIndex;

  /// Creates a [ReasoningSummaryPartAddedEvent].
  const ReasoningSummaryPartAddedEvent({
    required this.itemId,
    required this.outputIndex,
    required this.summaryIndex,
  });

  /// Creates a [ReasoningSummaryPartAddedEvent] from JSON.
  factory ReasoningSummaryPartAddedEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartAddedEvent(
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      summaryIndex: json['summary_index'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary_part.added',
    'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartAddedEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, summaryIndex);

  @override
  String toString() =>
      'ReasoningSummaryPartAddedEvent(summaryIndex: $summaryIndex)';
}

/// Event indicating a reasoning summary part is done.
@immutable
class ReasoningSummaryPartDoneEvent extends StreamingEvent {
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
    required this.itemId,
    required this.outputIndex,
    required this.summaryIndex,
    required this.part,
  });

  /// Creates a [ReasoningSummaryPartDoneEvent] from JSON.
  factory ReasoningSummaryPartDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryPartDoneEvent(
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
    'item_id': itemId,
    'output_index': outputIndex,
    'summary_index': summaryIndex,
    'part': part.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryPartDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          part == other.part;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, summaryIndex, part);

  @override
  String toString() =>
      'ReasoningSummaryPartDoneEvent(summaryIndex: $summaryIndex, part: $part)';
}

/// Event with reasoning summary delta.
@immutable
class ReasoningSummaryDeltaEvent extends StreamingEvent {
  /// The item ID.
  final String? itemId;

  /// The output index.
  final int? outputIndex;

  /// The summary index.
  final int? summaryIndex;

  /// The summary delta.
  final String delta;

  /// Creates a [ReasoningSummaryDeltaEvent].
  const ReasoningSummaryDeltaEvent({
    this.itemId,
    this.outputIndex,
    this.summaryIndex,
    required this.delta,
  });

  /// Creates a [ReasoningSummaryDeltaEvent] from JSON.
  factory ReasoningSummaryDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryDeltaEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int?,
      summaryIndex: json['summary_index'] as int?,
      delta: json['delta'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary.delta',
    if (itemId != null) 'item_id': itemId,
    if (outputIndex != null) 'output_index': outputIndex,
    if (summaryIndex != null) 'summary_index': summaryIndex,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryDeltaEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, summaryIndex, delta);

  @override
  String toString() => 'ReasoningSummaryDeltaEvent(delta: $delta)';
}

/// Event indicating reasoning summary is done.
@immutable
class ReasoningSummaryDoneEvent extends StreamingEvent {
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
    this.itemId,
    this.outputIndex,
    this.summaryIndex,
    required this.text,
  });

  /// Creates a [ReasoningSummaryDoneEvent] from JSON.
  factory ReasoningSummaryDoneEvent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryDoneEvent(
      itemId: json['item_id'] as String?,
      outputIndex: json['output_index'] as int?,
      summaryIndex: json['summary_index'] as int?,
      text: json['text'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.reasoning_summary.done',
    if (itemId != null) 'item_id': itemId,
    if (outputIndex != null) 'output_index': outputIndex,
    if (summaryIndex != null) 'summary_index': summaryIndex,
    'text': text,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryDoneEvent &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          summaryIndex == other.summaryIndex &&
          text == other.text;

  @override
  int get hashCode => Object.hash(itemId, outputIndex, summaryIndex, text);

  @override
  String toString() => 'ReasoningSummaryDoneEvent(text: $text)';
}

// ============================================================================
// Error event
// ============================================================================

/// Error event during streaming.
@immutable
class ErrorEvent extends StreamingEvent {
  /// The error information.
  final ErrorPayload error;

  /// Creates an [ErrorEvent].
  const ErrorEvent({required this.error});

  /// Creates an [ErrorEvent] from JSON.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      error: ErrorPayload.fromJson(json['error'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'error', 'error': error.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'ErrorEvent(error: $error)';
}
