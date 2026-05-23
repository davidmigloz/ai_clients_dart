part of 'webhook_event.dart';

/// An `interaction.completed` webhook event.
///
/// Delivered when an interaction completes successfully.
///
/// Named [WebhookInteractionCompletedEvent] to avoid collision with the SSE
/// `InteractionCompletedEvent` in `interactions/events/`.
class WebhookInteractionCompletedEvent extends WebhookEvent {
  @override
  String get type => 'interaction.completed';

  /// The ID of the interaction.
  final String id;

  /// Creates a [WebhookInteractionCompletedEvent] instance.
  const WebhookInteractionCompletedEvent({
    required this.id,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookInteractionCompletedEvent] from JSON.
  factory WebhookInteractionCompletedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'interaction.completed') {
      throw FormatException(
        'Expected type "interaction.completed" but got "${json['type']}"',
      );
    }
    return WebhookInteractionCompletedEvent(
      id: _requireDataId(json, 'WebhookInteractionCompletedEvent'),
      version: json['version'] as String?,
      timestamp: _readTimestamp(json),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (version != null) 'version': version,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    'data': {'id': id},
  };
}
