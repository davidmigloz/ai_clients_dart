part of 'events.dart';

/// An event carrying a partial update for a step in the interaction.
class StepDeltaEvent extends InteractionEvent {
  @override
  String get eventType => 'step.delta';

  /// The index of the step in the interaction's `steps` list.
  final int index;

  /// The delta payload for the step.
  final StepDeltaData delta;

  /// Optional metadata accompanying this streamed event.
  final StreamMetadata? metadata;

  /// Creates a [StepDeltaEvent] instance.
  const StepDeltaEvent({
    required this.index,
    required this.delta,
    this.metadata,
    super.eventId,
  });

  /// Creates a [StepDeltaEvent] from JSON.
  factory StepDeltaEvent.fromJson(Map<String, dynamic> json) {
    final index = json['index'];
    if (index is! int) {
      throw const FormatException('StepDeltaEvent: missing required "index"');
    }
    final delta = json['delta'];
    if (delta is! Map<String, dynamic>) {
      throw const FormatException('StepDeltaEvent: missing required "delta"');
    }
    return StepDeltaEvent(
      index: index,
      delta: StepDeltaData.fromJson(delta),
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
    'delta': delta.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
