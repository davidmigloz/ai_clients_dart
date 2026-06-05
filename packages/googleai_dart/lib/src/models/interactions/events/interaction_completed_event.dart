part of 'events.dart';

/// An event indicating that an interaction has completed.
///
/// Carries the completed [Interaction] resource. Per the spec, the `steps`
/// list is empty on this event to reduce payload size — the caller should
/// reconstruct steps from preceding `step.delta` and `step.start`/`step.stop`
/// events.
class InteractionCompletedEvent extends InteractionEvent {
  @override
  String get eventType => 'interaction.completed';

  /// The completed interaction.
  final Interaction interaction;

  /// Optional metadata accompanying this streamed event.
  final StreamMetadata? metadata;

  /// Creates an [InteractionCompletedEvent] instance.
  const InteractionCompletedEvent({
    required this.interaction,
    this.metadata,
    super.eventId,
  });

  /// Creates an [InteractionCompletedEvent] from JSON.
  factory InteractionCompletedEvent.fromJson(Map<String, dynamic> json) {
    final interaction = json['interaction'];
    if (interaction is! Map<String, dynamic>) {
      throw const FormatException(
        'InteractionCompletedEvent: missing required "interaction"',
      );
    }
    return InteractionCompletedEvent(
      interaction: Interaction.fromJson(interaction),
      metadata: json['metadata'] != null
          ? StreamMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      eventId: json['event_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'interaction': interaction.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
