part of 'events.dart';

/// An [InteractionEvent] whose `event_type` is not one of the documented
/// variants.
///
/// The Interactions API is experimental and evolving; new SSE event types may
/// be emitted before this client models them. Such events are surfaced here
/// with their raw JSON preserved instead of failing the stream, keeping SSE
/// parsing resilient and forward-compatible.
class UnknownInteractionEvent extends InteractionEvent {
  @override
  final String eventType;

  /// The raw JSON payload of the event, preserved verbatim.
  final Map<String, dynamic> json;

  /// Creates an [UnknownInteractionEvent] instance.
  const UnknownInteractionEvent({
    required this.eventType,
    required this.json,
    super.eventId,
  });

  /// Creates an [UnknownInteractionEvent] from JSON.
  factory UnknownInteractionEvent.fromJson(Map<String, dynamic> json) =>
      UnknownInteractionEvent(
        eventType: json['event_type'] as String? ?? '',
        json: json,
        eventId: json['event_id'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => json;
}
