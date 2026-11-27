part of 'events.dart';

/// An event indicating that an interaction's status has been updated.
class InteractionStatusUpdateEvent extends InteractionEvent {
  @override
  String get eventType => 'interaction.status_update';

  /// The ID of the interaction.
  final String? interactionId;

  /// The new status of the interaction.
  final InteractionStatus? status;

  /// Opaque token for resuming decoding from this checkpoint.
  final String? continuationToken;

  /// Cumulative usage for the current interaction up to this checkpoint.
  final InteractionUsage? usage;

  /// Creates an [InteractionStatusUpdateEvent] instance.
  const InteractionStatusUpdateEvent({
    this.interactionId,
    this.status,
    this.continuationToken,
    this.usage,
    super.eventId,
  });

  /// Creates an [InteractionStatusUpdateEvent] from JSON.
  factory InteractionStatusUpdateEvent.fromJson(Map<String, dynamic> json) =>
      InteractionStatusUpdateEvent(
        interactionId: json['interaction_id'] as String?,
        status: json['status'] != null
            ? InteractionStatus.fromString(json['status'] as String)
            : null,
        continuationToken: json['continuation_token'] as String?,
        usage: json['usage'] == null
            ? null
            : InteractionUsage.fromJson(json['usage'] as Map<String, dynamic>),
        eventId: json['event_id'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    if (interactionId != null) 'interaction_id': interactionId,
    if (status != null) 'status': status!.toJson(),
    if (continuationToken != null) 'continuation_token': continuationToken,
    if (usage != null) 'usage': usage!.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
