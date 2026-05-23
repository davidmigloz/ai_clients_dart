part of 'events.dart';

/// An event indicating that an interaction has been created.
///
/// Emitted at the start of an SSE stream and carries the initial
/// [Interaction] resource (with empty `steps`).
class InteractionCreatedEvent extends InteractionEvent {
  @override
  String get eventType => 'interaction.created';

  /// The created interaction.
  final Interaction interaction;

  /// Creates an [InteractionCreatedEvent] instance.
  const InteractionCreatedEvent({required this.interaction, super.eventId});

  /// Creates an [InteractionCreatedEvent] from JSON.
  factory InteractionCreatedEvent.fromJson(Map<String, dynamic> json) {
    final interaction = json['interaction'];
    if (interaction is! Map<String, dynamic>) {
      throw const FormatException(
        'InteractionCreatedEvent: missing required "interaction"',
      );
    }
    return InteractionCreatedEvent(
      interaction: Interaction.fromJson(interaction),
      eventId: json['event_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'interaction': interaction.toJson(),
    if (eventId != null) 'event_id': eventId,
  };
}
