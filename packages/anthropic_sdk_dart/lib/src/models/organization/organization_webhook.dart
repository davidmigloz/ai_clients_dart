import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// Event subscriptions available to organization webhook endpoints.
enum OrganizationWebhookEventType {
  /// Anthropic opened a user-profile enforcement action.
  enforcementActionOpened('user_profile.enforcement_action_opened'),

  /// A user-profile enforcement action was resolved or expired.
  enforcementActionResolved('user_profile.enforcement_action_resolved'),

  /// The program status of a user profile changed.
  programStatusUpdated('user_profile.program_status_updated');

  const OrganizationWebhookEventType(this.value);

  /// Name used in subscription requests and event payloads.
  final String value;
}

/// Desired delivery state for an organization webhook endpoint.
enum OrganizationWebhookState {
  /// Anthropic can deliver events to the endpoint.
  enabled,

  /// Anthropic will skip deliveries to the endpoint.
  disabled,
}

/// An organization webhook endpoint, without its signing secret.
@immutable
final class OrganizationWebhookEndpoint {
  /// Parses the webhook endpoint returned by the Admin API.
  OrganizationWebhookEndpoint.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(json, 'id', _model),
      url = requiredOrganizationField<String>(json, 'url', _model),
      name = requiredOrganizationField<String>(json, 'name', _model),
      description = requiredOrganizationField<String>(
        json,
        'description',
        _model,
      ),
      state = requiredOrganizationField<String>(json, 'state', _model),
      disabledReason = requiredOrganizationField<String>(
        json,
        'disabled_reason',
        _model,
      ),
      enabledEvents = List.unmodifiable(
        requiredOrganizationField<List<Object?>>(
          json,
          'enabled_events',
          _model,
        ).cast<String>(),
      ),
      createdAt = DateTime.parse(
        requiredOrganizationField<String>(json, 'created_at', _model),
      ),
      updatedAt = DateTime.parse(
        requiredOrganizationField<String>(json, 'updated_at', _model),
      );

  static const _model = 'OrganizationWebhookEndpoint';

  /// Webhook endpoint ID.
  final String id;

  /// Destination HTTPS URL.
  final String url;

  /// Display name.
  final String name;

  /// Endpoint description.
  final String description;

  /// Delivery state as returned by the API, including future values.
  final String state;

  /// Why Anthropic disabled this endpoint, or the empty string.
  final String disabledReason;

  /// Subscribed wire event names, including future values.
  final List<String> enabledEvents;

  /// When the endpoint was registered.
  final DateTime createdAt;

  /// When the endpoint was last updated.
  final DateTime updatedAt;

  /// Serializes the endpoint without its signing secret.
  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'name': name,
    'description': description,
    'state': state,
    'disabled_reason': disabledReason,
    'enabled_events': enabledEvents,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationWebhookEndpoint &&
          id == other.id &&
          url == other.url &&
          name == other.name &&
          description == other.description &&
          state == other.state &&
          disabledReason == other.disabledReason &&
          listsEqual(enabledEvents, other.enabledEvents) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    url,
    name,
    description,
    state,
    disabledReason,
    listHash(enabledEvents),
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'OrganizationWebhookEndpoint(id: $id, state: $state)';
}

/// A newly registered webhook endpoint and its one-time signing secret.
@immutable
final class NewOrganizationWebhookEndpoint {
  /// Parses a registration response.
  NewOrganizationWebhookEndpoint.fromJson(Map<String, dynamic> json)
    : endpoint = OrganizationWebhookEndpoint.fromJson(json),
      signingSecret = requiredOrganizationField<String>(
        json,
        'signing_secret',
        'NewOrganizationWebhookEndpoint',
      );

  /// The new endpoint.
  final OrganizationWebhookEndpoint endpoint;

  /// Credential for verifying deliveries. Store it when first returned.
  final String signingSecret;

  /// Serializes the registration result, including its signing secret.
  Map<String, dynamic> toJson() => {
    ...endpoint.toJson(),
    'signing_secret': signingSecret,
  };

  @override
  bool operator ==(Object other) =>
      other is NewOrganizationWebhookEndpoint &&
      endpoint == other.endpoint &&
      signingSecret == other.signingSecret;

  @override
  int get hashCode => Object.hash(endpoint, signingSecret);

  @override
  String toString() => 'NewOrganizationWebhookEndpoint(endpoint: $endpoint)';
}

/// The replacement signing secret returned by a rotation request.
@immutable
final class OrganizationWebhookSigningSecret {
  /// Parses a secret rotation response.
  OrganizationWebhookSigningSecret.fromJson(Map<String, dynamic> json)
    : signingSecret = requiredOrganizationField<String>(
        json,
        'signing_secret',
        'OrganizationWebhookSigningSecret',
      );

  /// New signing credential. The previous credential stops working immediately.
  final String signingSecret;

  /// Serializes the response, including the replacement credential.
  Map<String, dynamic> toJson() => {'signing_secret': signingSecret};

  @override
  bool operator ==(Object other) =>
      other is OrganizationWebhookSigningSecret &&
      signingSecret == other.signingSecret;

  @override
  int get hashCode => signingSecret.hashCode;

  @override
  String toString() => 'OrganizationWebhookSigningSecret([redacted])';
}

/// Confirmation that a webhook endpoint was deleted.
@immutable
final class DeletedOrganizationWebhookEndpoint {
  /// Parses the deletion confirmation.
  DeletedOrganizationWebhookEndpoint.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(
        json,
        'id',
        'DeletedOrganizationWebhookEndpoint',
      ) {
    checkOrganizationType(json, type);
  }

  /// The deleted endpoint's ID.
  final String id;

  /// The wire response discriminator.
  String get type => 'webhook_endpoint_deleted';

  /// Serializes the deletion confirmation.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  @override
  bool operator ==(Object other) =>
      other is DeletedOrganizationWebhookEndpoint && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
