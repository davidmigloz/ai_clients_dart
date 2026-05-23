import '../deltas/deltas.dart';
import '../interaction.dart';
import '../interaction_status.dart';
import '../steps/steps.dart';

part 'error_event.dart';
part 'interaction_completed_event.dart';
part 'interaction_created_event.dart';
part 'interaction_error.dart';
part 'interaction_status_update_event.dart';
part 'step_delta_event.dart';
part 'step_start_event.dart';
part 'step_stop_event.dart';
part 'unknown_interaction_event.dart';

/// An event from the Interactions API streaming response.
///
/// This is a sealed class with subtypes for the different `event_type`
/// values produced by `step.*` and `interaction.*` SSE events, plus an
/// [UnknownInteractionEvent] fallback for any `event_type` this client does
/// not yet model.
sealed class InteractionEvent {
  /// The event type discriminator.
  String get eventType;

  /// The event ID token to resume the stream from this event.
  final String? eventId;

  const InteractionEvent({this.eventId});

  /// Creates an [InteractionEvent] from JSON.
  ///
  /// Unrecognized `event_type` values are surfaced as [UnknownInteractionEvent]
  /// (raw JSON preserved) so a new/undocumented event type cannot break the
  /// SSE stream.
  factory InteractionEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['event_type'] as String?;
    return switch (eventType) {
      'interaction.created' => InteractionCreatedEvent.fromJson(json),
      'interaction.completed' => InteractionCompletedEvent.fromJson(json),
      'interaction.status_update' => InteractionStatusUpdateEvent.fromJson(
        json,
      ),
      'step.start' => StepStartEvent.fromJson(json),
      'step.delta' => StepDeltaEvent.fromJson(json),
      'step.stop' => StepStopEvent.fromJson(json),
      'error' => ErrorEvent.fromJson(json),
      _ => UnknownInteractionEvent.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
