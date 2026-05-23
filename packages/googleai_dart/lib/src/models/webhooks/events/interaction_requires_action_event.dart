part of 'webhook_event.dart';

/// An `interaction.requires_action` webhook event.
///
/// Delivered when an interaction requires action (e.g. function calling).
class WebhookInteractionRequiresActionEvent extends WebhookEvent {
  @override
  String get type => 'interaction.requires_action';

  /// The ID of the interaction.
  final String id;

  /// Creates a [WebhookInteractionRequiresActionEvent] instance.
  const WebhookInteractionRequiresActionEvent({
    required this.id,
    super.version,
    super.timestamp,
  });

  /// Creates a [WebhookInteractionRequiresActionEvent] from JSON.
  factory WebhookInteractionRequiresActionEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] != 'interaction.requires_action') {
      throw FormatException(
        'Expected type "interaction.requires_action" but got "${json['type']}"',
      );
    }
    return WebhookInteractionRequiresActionEvent(
      id: _requireDataId(json, 'WebhookInteractionRequiresActionEvent'),
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
