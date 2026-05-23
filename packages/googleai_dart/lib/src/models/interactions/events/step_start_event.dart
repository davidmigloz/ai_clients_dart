part of 'events.dart';

/// An event indicating that a new step has started in the interaction.
class StepStartEvent extends InteractionEvent {
  @override
  String get eventType => 'step.start';

  /// The index of the step in the interaction's `steps` list.
  final int index;

  /// The starting step.
  final InteractionStep step;

  /// Creates a [StepStartEvent] instance.
  const StepStartEvent({
    required this.index,
    required this.step,
    super.eventId,
  });

  /// Creates a [StepStartEvent] from JSON.
  factory StepStartEvent.fromJson(Map<String, dynamic> json) {
    final index = json['index'];
    if (index is! int) {
      throw const FormatException('StepStartEvent: missing required "index"');
    }
    final step = json['step'];
    if (step is! Map<String, dynamic>) {
      throw const FormatException('StepStartEvent: missing required "step"');
    }
    return StepStartEvent(
      index: index,
      step: InteractionStep.fromJson(step),
      eventId: json['event_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'index': index,
    'step': step.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
