import '../copy_with_sentinel.dart';
import 'signing_secret.dart';
import 'webhook_state.dart';

/// A Webhook resource.
///
/// Represents a webhook subscription that delivers events for batches and
/// interactions. Output-only fields (e.g. [id], [createTime], [signingSecrets])
/// are populated on responses; for the create-request body, callers supply
/// [uri], [subscribedEvents], and optionally [name].
///
/// `subscribedEvents` is an open list of strings; the documented event names
/// are:
///   - `batch.succeeded` — Batch processing finished successfully.
///   - `batch.expired` — Batch was not processed within the 48h timeframe.
///   - `batch.failed` — Batch job failed.
///   - `interaction.requires_action` — Interaction requires action
///     (e.g. function calling).
///   - `interaction.completed` — Interaction completed successfully.
///   - `interaction.failed` — Interaction failed.
///   - `video.generated` — Video generation completed.
class Webhook {
  /// The URI to which webhook events will be sent.
  final String uri;

  /// The events that the webhook is subscribed to.
  final List<String> subscribedEvents;

  /// The user-provided name of the webhook.
  final String? name;

  /// The ID of the webhook.
  final String? id;

  /// The state of the webhook.
  final WebhookState? state;

  /// The timestamp when the webhook was created.
  final DateTime? createTime;

  /// The timestamp when the webhook was last updated.
  final DateTime? updateTime;

  /// The signing secrets associated with this webhook.
  final List<SigningSecret>? signingSecrets;

  /// The new signing secret. Only populated on create.
  final String? newSigningSecret;

  /// Creates a [Webhook] instance.
  const Webhook({
    required this.uri,
    required this.subscribedEvents,
    this.name,
    this.id,
    this.state,
    this.createTime,
    this.updateTime,
    this.signingSecrets,
    this.newSigningSecret,
  });

  /// Creates a [Webhook] from JSON.
  factory Webhook.fromJson(Map<String, dynamic> json) => Webhook(
    uri: json['uri'] as String,
    subscribedEvents: (json['subscribed_events'] as List<dynamic>)
        .cast<String>(),
    name: json['name'] as String?,
    id: json['id'] as String?,
    state: webhookStateFromString(json['state'] as String?),
    createTime: json['create_time'] != null
        ? DateTime.parse(json['create_time'] as String)
        : null,
    updateTime: json['update_time'] != null
        ? DateTime.parse(json['update_time'] as String)
        : null,
    signingSecrets: (json['signing_secrets'] as List<dynamic>?)
        ?.map((e) => SigningSecret.fromJson(e as Map<String, dynamic>))
        .toList(),
    newSigningSecret: json['new_signing_secret'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'uri': uri,
    'subscribed_events': subscribedEvents,
    if (name != null) 'name': name,
    if (id != null) 'id': id,
    if (state != null) 'state': webhookStateToString(state!),
    if (createTime != null) 'create_time': createTime!.toIso8601String(),
    if (updateTime != null) 'update_time': updateTime!.toIso8601String(),
    if (signingSecrets != null)
      'signing_secrets': signingSecrets!.map((e) => e.toJson()).toList(),
    if (newSigningSecret != null) 'new_signing_secret': newSigningSecret,
  };

  /// Creates a copy with replaced values.
  Webhook copyWith({
    Object? uri = unsetCopyWithValue,
    Object? subscribedEvents = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? id = unsetCopyWithValue,
    Object? state = unsetCopyWithValue,
    Object? createTime = unsetCopyWithValue,
    Object? updateTime = unsetCopyWithValue,
    Object? signingSecrets = unsetCopyWithValue,
    Object? newSigningSecret = unsetCopyWithValue,
  }) {
    return Webhook(
      uri: uri == unsetCopyWithValue ? this.uri : uri! as String,
      subscribedEvents: subscribedEvents == unsetCopyWithValue
          ? this.subscribedEvents
          : subscribedEvents! as List<String>,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      id: id == unsetCopyWithValue ? this.id : id as String?,
      state: state == unsetCopyWithValue ? this.state : state as WebhookState?,
      createTime: createTime == unsetCopyWithValue
          ? this.createTime
          : createTime as DateTime?,
      updateTime: updateTime == unsetCopyWithValue
          ? this.updateTime
          : updateTime as DateTime?,
      signingSecrets: signingSecrets == unsetCopyWithValue
          ? this.signingSecrets
          : signingSecrets as List<SigningSecret>?,
      newSigningSecret: newSigningSecret == unsetCopyWithValue
          ? this.newSigningSecret
          : newSigningSecret as String?,
    );
  }
}
