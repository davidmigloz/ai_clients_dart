import '../../models/organization/organization_page.dart';
import '../../models/organization/organization_webhook.dart';
import 'organization_transport.dart';

const _webhooksPath = '/webhooks';
const _webhooksBeta = 'webhooks-2026-10-07';

/// Organization webhook endpoints on the Claude API (beta).
///
/// Anthropic must enable access for the organization. The organization must
/// have a default workspace and cannot have HIPAA readiness enabled or use
/// customer-managed encryption in the default workspace.
final class OrganizationWebhooksResource {
  /// Creates a resource on the organization transport.
  const OrganizationWebhooksResource(this._transport);

  final OrganizationTransport _transport;

  /// Registers an HTTPS receiver and returns its one-time signing secret.
  Future<NewOrganizationWebhookEndpoint> create({
    required String url,
    required List<OrganizationWebhookEventType> enabledEvents,
    String? name,
    String? description,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) {
    if (enabledEvents.isEmpty) {
      throw ArgumentError('At least one webhook event must be enabled');
    }
    return _send(
      'POST',
      _webhooksPath,
      NewOrganizationWebhookEndpoint.fromJson,
      sensitiveResponse: true,
      body: {
        'url': url,
        'enabled_events': enabledEvents.map((event) => event.value).toList(),
        'name': ?name,
        'description': ?description,
      },
      betas: betas,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists organization webhook endpoints ordered by creation time.
  Future<OrganizationPage<OrganizationWebhookEndpoint>> list({
    String? beforeId,
    String? afterId,
    int? limit,
    String? order,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    _webhooksPath,
    (json) =>
        OrganizationPage.fromJson(json, OrganizationWebhookEndpoint.fromJson),
    query: {
      ...organizationPageQuery(beforeId, afterId, limit),
      'order': ?order,
    },
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Reads the current endpoint configuration.
  Future<OrganizationWebhookEndpoint> retrieve(
    String endpointId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    _endpointPath(endpointId),
    OrganizationWebhookEndpoint.fromJson,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Updates only the supplied settings. An empty event list leaves it unchanged.
  Future<OrganizationWebhookEndpoint> update(
    String endpointId, {
    String? url,
    List<OrganizationWebhookEventType>? enabledEvents,
    String? name,
    String? description,
    OrganizationWebhookState? state,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    _endpointPath(endpointId),
    OrganizationWebhookEndpoint.fromJson,
    body: {
      'url': ?url,
      'enabled_events': ?enabledEvents?.map((event) => event.value).toList(),
      'name': ?name,
      'description': ?description,
      'state': ?state?.name,
    },
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Deletes the endpoint and stops new deliveries.
  Future<DeletedOrganizationWebhookEndpoint> delete(
    String endpointId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'DELETE',
    _endpointPath(endpointId),
    DeletedOrganizationWebhookEndpoint.fromJson,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  /// Rotates the secret, invalidating the previous value immediately.
  Future<OrganizationWebhookSigningSecret> regenerateSigningSecret(
    String endpointId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    '${_endpointPath(endpointId)}/regenerate_signing_secret',
    OrganizationWebhookSigningSecret.fromJson,
    sensitiveResponse: true,
    betas: betas,
    abortTrigger: abortTrigger,
  );

  Future<T> _send<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    bool sensitiveResponse = false,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    method,
    path,
    decode,
    body: body,
    query: query,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _webhooksBeta,
    sensitiveResponse: sensitiveResponse,
    abortTrigger: abortTrigger,
  );

  static String _endpointPath(String endpointId) =>
      '$_webhooksPath/${organizationIdSegment(endpointId, 'endpointId')}';
}
