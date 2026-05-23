part 'batch_expired_event.dart';
part 'batch_failed_event.dart';
part 'batch_succeeded_event.dart';
part 'interaction_completed_event.dart';
part 'interaction_failed_event.dart';
part 'interaction_requires_action_event.dart';
part 'video_generated_event.dart';

/// A webhook delivery event.
///
/// This is a sealed class with 7 subtypes covering all documented event
/// types delivered by the Gemini API webhook system. The wire envelope
/// always contains:
///   - `type` — string discriminator (e.g. `"interaction.completed"`)
///   - `version` — schema version (e.g. `"v1"`)
///   - `timestamp` — RFC3339 timestamp
///   - `data` — event-specific payload (flattened into per-variant fields)
///
/// HTTP delivery headers (`webhook-id`, `webhook-signature`,
/// `webhook-timestamp`) are not represented here — those live on the
/// transport (e.g. `shelf` `Request.headers`) rather than in the JSON body.
sealed class WebhookEvent {
  /// The event type discriminator.
  String get type;

  /// The schema version (e.g. `"v1"`).
  final String? version;

  /// The timestamp at which the event was emitted.
  final DateTime? timestamp;

  /// Creates a [WebhookEvent].
  const WebhookEvent({this.version, this.timestamp});

  /// Creates a [WebhookEvent] from JSON.
  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'batch.succeeded' => WebhookBatchSucceededEvent.fromJson(json),
      'batch.expired' => WebhookBatchExpiredEvent.fromJson(json),
      'batch.failed' => WebhookBatchFailedEvent.fromJson(json),
      'interaction.requires_action' =>
        WebhookInteractionRequiresActionEvent.fromJson(json),
      'interaction.completed' => WebhookInteractionCompletedEvent.fromJson(
        json,
      ),
      'interaction.failed' => WebhookInteractionFailedEvent.fromJson(json),
      'video.generated' => WebhookVideoGeneratedEvent.fromJson(json),
      _ => throw ArgumentError('Unknown webhook event type: ${json['type']}'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Reads the required `id` from a webhook event's `data` payload.
String _requireDataId(Map<String, dynamic> json, String eventType) {
  final data = json['data'];
  if (data is! Map<String, dynamic>) {
    throw FormatException('$eventType: missing required "data"');
  }
  final id = data['id'];
  if (id is! String) {
    throw FormatException('$eventType: missing required "data.id"');
  }
  return id;
}

/// Reads the optional `data` map (used to extract additional fields).
Map<String, dynamic>? _readData(Map<String, dynamic> json) {
  final data = json['data'];
  return data is Map<String, dynamic> ? data : null;
}

/// Parses an optional ISO 8601 timestamp from JSON.
DateTime? _readTimestamp(Map<String, dynamic> json) {
  final ts = json['timestamp'];
  return ts is String ? DateTime.parse(ts) : null;
}
