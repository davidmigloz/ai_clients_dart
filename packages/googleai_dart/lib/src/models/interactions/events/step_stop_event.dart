part of 'events.dart';

/// An event indicating that a step has finished in the interaction.
class StepStopEvent extends InteractionEvent {
  @override
  String get eventType => 'step.stop';

  /// The index of the step in the interaction's `steps` list.
  final int index;

  /// Optional metadata accompanying this streamed event.
  final StreamMetadata? metadata;

  /// Creates a [StepStopEvent] instance.
  const StepStopEvent({required this.index, this.metadata, super.eventId});

  /// Creates a [StepStopEvent] from JSON.
  factory StepStopEvent.fromJson(Map<String, dynamic> json) {
    final index = json['index'];
    if (index is! int) {
      throw const FormatException('StepStopEvent: missing required "index"');
    }
    return StepStopEvent(
      index: index,
      metadata: json['metadata'] != null
          ? StreamMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      eventId: json['event_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'index': index,
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
