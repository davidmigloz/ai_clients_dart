part of 'webhook_event.dart';

/// A webhook event concerning a user profile's enforcement or program status.
@immutable
final class WebhookUserProfileEventData extends WebhookEventData {
  const WebhookUserProfileEventData._({
    required this.event,
    required this.id,
    required this.organizationId,
    this.enforcementActionId,
  });

  /// Parses a supported user-profile webhook payload.
  factory WebhookUserProfileEventData.fromJson(Map<String, dynamic> json) {
    final type = requiredOrganizationField<String>(json, 'type', _model);
    final event = OrganizationWebhookEventType.values.firstWhere(
      (event) => event.value == type,
      orElse: () =>
          throw const FormatException('Unknown user-profile webhook event'),
    );
    return WebhookUserProfileEventData._(
      event: event,
      id: requiredOrganizationField<String>(json, 'id', _model),
      organizationId: requiredOrganizationField<String>(
        json,
        'organization_id',
        _model,
      ),
      enforcementActionId:
          event == OrganizationWebhookEventType.programStatusUpdated
          ? null
          : requiredOrganizationField<String>(
              json,
              'enforcement_action_id',
              _model,
            ),
    );
  }

  static const _model = 'WebhookUserProfileEventData';

  /// The typed event discriminator.
  final OrganizationWebhookEventType event;

  /// The original event name.
  String get type => event.value;

  /// The affected user-profile ID.
  final String id;

  /// The profile's organization ID.
  final String organizationId;

  /// The action ID for an opened or resolved enforcement action.
  final String? enforcementActionId;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'enforcement_action_id': ?enforcementActionId,
  };

  @override
  bool operator ==(Object other) =>
      other is WebhookUserProfileEventData &&
      event == other.event &&
      id == other.id &&
      organizationId == other.organizationId &&
      enforcementActionId == other.enforcementActionId;

  @override
  int get hashCode =>
      Object.hash(event, id, organizationId, enforcementActionId);

  @override
  String toString() => 'WebhookUserProfileEventData(type: $type, id: $id)';
}
