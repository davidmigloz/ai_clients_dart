import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/webhooks/webhook_endpoint.dart';
import '../models/webhooks/webhook_event.dart';
import 'base_resource.dart';
import 'webhooks/webhook_event_types_resource.dart';
import 'webhooks/webhook_verifier.dart';

/// Project webhook endpoint management and local signed-delivery verification.
///
/// Endpoint methods use the client's authenticated HTTP transport. Local
/// verification and parsing use no HTTP request, authentication provider or
/// client lifetime check. Applications own acknowledgment and later handling.
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

  static const _endpoint = '/webhook_endpoints';

  WebhookEventTypesResource? _eventTypes;

  /// Discovers the event types available to the authenticated project.
  ///
  /// Returned strings remain open to future event types. Writable subscription
  /// choices use the separate [WebhookEventType] enum.
  WebhookEventTypesResource get eventTypes =>
      _eventTypes ??= WebhookEventTypesResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );

  /// Lists project endpoints using the server's pagination cursors.
  ///
  /// [limit] must be between 1 and 100 when supplied; the server defaults to 20.
  /// Pass the returned page's `lastId` as [after] to request the next page.
  Future<WebhookEndpointList> list({
    int? limit,
    String? after,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (limit != null && (limit < 1 || limit > 100)) {
      throw ArgumentError('Webhook endpoint limit must be between 1 and 100.');
    }
    final query = <String, String>{
      if (limit != null) 'limit': limit.toString(),
      'after': ?after,
    };
    final response = await _execute(
      'GET',
      _endpoint,
      query: query,
      abortTrigger: abortTrigger,
    );
    return _parseResponse(
      response,
      WebhookEndpointList.fromJson,
      'WebhookEndpointList',
    );
  }

  /// Creates an endpoint and returns its signing secret once.
  ///
  /// Store the returned secret in application-managed secret storage. This does
  /// not change the client's configured local verification secret.
  Future<WebhookEndpointWithSecret> create(
    WebhookEndpointCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final body = request.toJson();
    final response = await _execute(
      'POST',
      _endpoint,
      body: body,
      abortTrigger: abortTrigger,
    );
    return _parseResponse(
      response,
      WebhookEndpointWithSecret.fromJson,
      'WebhookEndpointWithSecret',
    );
  }

  /// Retrieves a project endpoint without exposing its signing secret.
  Future<WebhookEndpoint> retrieve(
    String webhookEndpointId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = _endpointPath(webhookEndpointId);
    final response = await _execute('GET', path, abortTrigger: abortTrigger);
    return _parseResponse(
      response,
      WebhookEndpoint.fromJson,
      'WebhookEndpoint',
    );
  }

  /// Updates any subset of endpoint configuration; an empty update is allowed.
  ///
  /// Supplying `eventTypes` replaces the complete subscription set.
  Future<WebhookEndpoint> update(
    String webhookEndpointId,
    WebhookEndpointUpdateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = _endpointPath(webhookEndpointId);
    final body = request.toJson();
    final response = await _execute(
      'POST',
      path,
      body: body,
      abortTrigger: abortTrigger,
    );
    return _parseResponse(
      response,
      WebhookEndpoint.fromJson,
      'WebhookEndpoint',
    );
  }

  /// Deletes a project webhook endpoint.
  Future<DeletedWebhookEndpoint> delete(
    String webhookEndpointId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = _endpointPath(webhookEndpointId);
    final response = await _execute('DELETE', path, abortTrigger: abortTrigger);
    return _parseResponse(
      response,
      DeletedWebhookEndpoint.fromJson,
      'DeletedWebhookEndpoint',
    );
  }

  /// Rotates an endpoint's signing secret and returns the new secret once.
  ///
  /// Omitting [request] sends no request body. The default option invalidates
  /// the old secret immediately. Setting `keepOldSecretActiveFor24Hours` to true
  /// keeps the previous secret valid for a 24-hour overlap.
  ///
  /// Rotation does not update the client's configured local verification secret.
  Future<WebhookEndpointWithSecret> rotateSecret(
    String webhookEndpointId, {
    WebhookEndpointRotateSecretRequest? request,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = '${_endpointPath(webhookEndpointId)}/rotate_secret';
    final body = request?.toJson();
    final response = await _execute(
      'POST',
      path,
      body: body,
      abortTrigger: abortTrigger,
    );
    return _parseResponse(
      response,
      WebhookEndpointWithSecret.fromJson,
      'WebhookEndpointWithSecret',
    );
  }

  /// Sends a real sample webhook delivery to this endpoint.
  ///
  /// A returned `success: true` means the test request completed. Inspect the
  /// result's `statusCode` separately, because the receiver may return 4xx/5xx.
  Future<WebhookEndpointTestResult> test(
    String webhookEndpointId,
    WebhookEndpointTestRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = '${_endpointPath(webhookEndpointId)}/test';
    final body = request.toJson();
    final response = await _execute(
      'POST',
      path,
      body: body,
      abortTrigger: abortTrigger,
    );
    return _parseResponse(
      response,
      WebhookEndpointTestResult.fromJson,
      'WebhookEndpointTestResult',
    );
  }

  Future<http.Response> _execute(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    Future<void>? abortTrigger,
  }) {
    final request = http.Request(
      method,
      requestBuilder.buildUrl(path, queryParams: query),
    )..headers.addAll(requestBuilder.buildHeaders());
    if (body != null) request.body = jsonEncode(body);
    return interceptorChain.execute(request, abortTrigger: abortTrigger);
  }

  String _endpointPath(String id) {
    // Dart Uri normalizes literal and escaped dot segments. Reject only those
    // unsendable IDs; all other identifiers are encoded as one path segment.
    if (id.isEmpty || id == '.' || id == '..') {
      throw ArgumentError(
        'Webhook endpoint ID must be a nonempty path segment.',
      );
    }
    return '$_endpoint/${Uri.encodeComponent(id)}';
  }

  T _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parse,
    String context,
  ) {
    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return parse(json);
    } on FormatException {
      throw FormatException('Invalid $context response.');
    } on TypeError {
      throw FormatException('Invalid $context response.');
    } on ArgumentError {
      throw FormatException('Invalid $context response.');
    }
  }

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
