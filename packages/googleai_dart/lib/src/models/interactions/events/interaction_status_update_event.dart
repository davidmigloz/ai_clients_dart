part of 'events.dart';

/// An event indicating that an interaction's status has been updated.
class InteractionStatusUpdateEvent extends InteractionEvent {
  @override
  String get eventType => 'interaction.status_update';

  /// The ID of the interaction.
  final String? interactionId;

  /// The new status of the interaction.
  final InteractionStatus? status;

  /// Optional metadata accompanying this streamed event.
  final StreamMetadata? metadata;

  /// Creates an [InteractionStatusUpdateEvent] instance.
  const InteractionStatusUpdateEvent({
    this.interactionId,
    this.status,
    this.metadata,
    super.eventId,
  });

  /// Creates an [InteractionStatusUpdateEvent] from JSON.
  factory InteractionStatusUpdateEvent.fromJson(Map<String, dynamic> json) =>
      InteractionStatusUpdateEvent(
        interactionId: json['interaction_id'] as String?,
        status: json['status'] != null
            ? InteractionStatus.fromString(json['status'] as String)
            : null,
        metadata: json['metadata'] != null
            ? StreamMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
            : null,
        eventId: json['event_id'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    if (interactionId != null) 'interaction_id': interactionId,
    if (status != null) 'status': status!.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
