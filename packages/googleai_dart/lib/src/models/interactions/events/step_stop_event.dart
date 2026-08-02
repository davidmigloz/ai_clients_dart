part of 'events.dart';

/// An event indicating that a step has finished in the interaction.
class StepStopEvent extends InteractionEvent {
  @override
  String get eventType => 'step.stop';

  /// The index of the step in the interaction's `steps` list.
  final int index;

  /// Cumulative model usage stats from the start of the session.
  final InteractionUsage? usage;

  /// Model usage stats for this specific step.
  final InteractionUsage? stepUsage;

  /// Creates a [StepStopEvent] instance.
  const StepStopEvent({
    required this.index,
    this.usage,
    this.stepUsage,
    super.eventId,
  });

  /// Creates a [StepStopEvent] from JSON.
  factory StepStopEvent.fromJson(Map<String, dynamic> json) {
    final index = json['index'];
    if (index is! int) {
      throw const FormatException('StepStopEvent: missing required "index"');
    }
    return StepStopEvent(
      index: index,
      usage: json['usage'] != null
          ? InteractionUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      stepUsage: json['step_usage'] != null
          ? InteractionUsage.fromJson(
              json['step_usage'] as Map<String, dynamic>,
            )
          : null,
      eventId: json['event_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'index': index,
    if (usage != null) 'usage': usage!.toJson(),
    if (stepUsage != null) 'step_usage': stepUsage!.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
