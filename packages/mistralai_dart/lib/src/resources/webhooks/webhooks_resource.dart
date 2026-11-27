import '../../models/webhooks/webhook.dart';
import '../base_resource.dart';
import '../platform_resource.dart';

/// Manages inbound webhook sources for platform triggers (beta).
class WebhooksResource extends ResourceBase with PlatformResource {
  /// Creates a [WebhooksResource].
  WebhooksResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _path = '/v1/webhooks';

  String _webhook(String id) => '$_path/${Uri.encodeComponent(id)}';

  /// Lists registered webhook sources.
  Future<List<Webhook>> list() => requestPlatform(
    'GET',
    _path,
    (json) => (json! as List)
        .cast<Map<String, dynamic>>()
        .map(Webhook.fromJson)
        .toList(),
    redactErrorBody: true,
  );

  /// Registers a webhook source with the specified provider settings.
  Future<Webhook> create({required CreateWebhookRequest request}) =>
      requestPlatform(
        'POST',
        _path,
        (json) => Webhook.fromJson(json! as Map<String, dynamic>),
        body: request.toJson(),
        redactErrorBody: true,
      );

  /// Retrieves a webhook source.
  Future<Webhook> get({required String webhookId}) => requestPlatform(
    'GET',
    _webhook(webhookId),
    (json) => Webhook.fromJson(json! as Map<String, dynamic>),
    redactErrorBody: true,
  );

  /// Retrieves the configured signing secret for a webhook.
  Future<WebhookSigningSecret> getSigningSecret({required String webhookId}) =>
      requestPlatform(
        'GET',
        '${_webhook(webhookId)}/signing-secret',
        (json) => WebhookSigningSecret.fromJson(json! as Map<String, dynamic>),
        redactErrorBody: true,
      );

  /// Deletes a webhook after its attached triggers are removed.
  Future<void> delete({required String webhookId}) =>
      requestPlatform('DELETE', _webhook(webhookId), (_) {});
}
