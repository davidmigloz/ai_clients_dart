import '../models/webhooks/webhook_event.dart';
import 'base_resource.dart';
import 'webhooks/webhook_verifier.dart';

/// Local verification and parsing of signed webhook deliveries.
///
/// These methods use no HTTP request, authentication provider or client lifetime
/// check. Applications own acknowledgment and all later event handling.
class WebhooksResource extends ResourceBase {
  /// Creates the webhook resource using the client's shared configuration.
  WebhooksResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  }) : _verifier = WebhookVerifier(secret: config.webhookSecret);

  final WebhookVerifier _verifier;

  /// Verifies the untouched UTF-8 encoding of [body] before any parsing.
  ///
  /// See [WebhookVerifier.verifySignature] for signature and timestamp policy.
  void verifySignature(
    String body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) => _verifier.verifySignature(
    body,
    headers,
    secret: secret,
    tolerance: tolerance,
  );

  /// Verifies the original [body] bytes without decoding or reserializing them.
  void verifySignatureBytes(
    List<int> body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) => _verifier.verifySignatureBytes(
    body,
    headers,
    secret: secret,
    tolerance: tolerance,
  );

  /// Verifies [body], then parses the authenticated event.
  ///
  /// Signature failures precede JSON/model failures. See [WebhookVerifier.unwrap]
  /// for safe failure diagnostics and application-owned handling.
  WebhookEvent unwrap(
    String body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) => _verifier.unwrap(body, headers, secret: secret, tolerance: tolerance);

  /// Verifies original bytes, then strictly decodes UTF-8/JSON and the event.
  WebhookEvent unwrapBytes(
    List<int> body,
    Map<String, String> headers, {
    String? secret,
    Duration tolerance = const Duration(minutes: 5),
  }) => _verifier.unwrapBytes(
    body,
    headers,
    secret: secret,
    tolerance: tolerance,
  );
}
