import '../copy_with_sentinel.dart';
import 'webhook_state.dart';

/// Update payload for a [Webhook]. All fields are optional.
class WebhookUpdate {
  /// The user-provided name of the webhook.
  final String? name;

  /// The state of the webhook.
  final WebhookState? state;

  /// The events that the webhook is subscribed to.
  final List<String>? subscribedEvents;

  /// The URI to which webhook events will be sent.
  final String? uri;

  /// Creates a [WebhookUpdate] instance.
  const WebhookUpdate({this.name, this.state, this.subscribedEvents, this.uri});

  /// Creates a [WebhookUpdate] from JSON.
  factory WebhookUpdate.fromJson(Map<String, dynamic> json) => WebhookUpdate(
    name: json['name'] as String?,
    state: webhookStateFromString(json['state'] as String?),
    subscribedEvents: (json['subscribed_events'] as List<dynamic>?)
        ?.cast<String>(),
    uri: json['uri'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (state != null) 'state': webhookStateToString(state!),
    if (subscribedEvents != null) 'subscribed_events': subscribedEvents,
    if (uri != null) 'uri': uri,
  };

  /// Creates a copy with replaced values.
  WebhookUpdate copyWith({
    Object? name = unsetCopyWithValue,
    Object? state = unsetCopyWithValue,
    Object? subscribedEvents = unsetCopyWithValue,
    Object? uri = unsetCopyWithValue,
  }) {
    return WebhookUpdate(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      state: state == unsetCopyWithValue ? this.state : state as WebhookState?,
      subscribedEvents: subscribedEvents == unsetCopyWithValue
          ? this.subscribedEvents
          : subscribedEvents as List<String>?,
      uri: uri == unsetCopyWithValue ? this.uri : uri as String?,
    );
  }
}
