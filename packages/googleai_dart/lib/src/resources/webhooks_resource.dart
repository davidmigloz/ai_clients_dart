import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/webhooks/list_webhooks_response.dart';
import '../models/webhooks/rotate_signing_secret_request.dart';
import '../models/webhooks/rotate_signing_secret_response.dart';
import '../models/webhooks/webhook.dart';
import '../models/webhooks/webhook_update.dart';
import 'base_resource.dart';

/// Resource for the Webhooks API.
///
/// Provides CRUD operations on webhook subscriptions plus the `:ping` and
/// `:rotateSigningSecret` server-side actions.
///
/// **Note:** the Webhooks API is part of the experimental Interactions API.
class WebhooksResource extends ResourceBase {
  /// Creates a [WebhooksResource].
  WebhooksResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new [Webhook].
  ///
  /// Returns the created webhook with its server-assigned [Webhook.id],
  /// [Webhook.signingSecrets], and [Webhook.newSigningSecret] populated.
  Future<Webhook> create({required Webhook webhook}) async {
    final url = requestBuilder.buildUrl('/{version}/webhooks');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(webhook.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Webhook.fromJson(responseBody);
  }

  /// Lists all webhooks.
  ///
  /// [pageSize] caps the maximum number of webhooks per page (default 50,
  /// max 1000). [pageToken] is used for pagination.
  Future<ListWebhooksResponse> list({int? pageSize, String? pageToken}) async {
    final queryParams = <String, String>{
      if (pageSize != null) 'pageSize': pageSize.toString(),
      'pageToken': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/webhooks',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListWebhooksResponse.fromJson(responseBody);
  }

  /// Gets a specific webhook by [id].
  Future<Webhook> get(String id) async {
    final url = requestBuilder.buildUrl('/{version}/webhooks/$id');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Webhook.fromJson(responseBody);
  }

  /// Updates an existing webhook.
  ///
  /// [updateMask] is a comma-separated list of field names to update
  /// (e.g. `"name,uri"`). If omitted, the server uses default field
  /// substitution rules.
  Future<Webhook> update({
    required String id,
    required WebhookUpdate update,
    String? updateMask,
  }) async {
    final queryParams = <String, String>{'updateMask': ?updateMask};

    final url = requestBuilder.buildUrl(
      '/{version}/webhooks/$id',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(update.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Webhook.fromJson(responseBody);
  }

  /// Deletes a webhook by [id].
  Future<void> delete(String id) async {
    final url = requestBuilder.buildUrl('/{version}/webhooks/$id');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Sends a test ping to the webhook.
  ///
  /// The server delivers a ping payload to the registered URI; this method
  /// returns once the request has been accepted (no response body to parse).
  Future<void> ping(String id) async {
    final url = requestBuilder.buildUrl('/{version}/webhooks/$id:ping');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    await interceptorChain.execute(httpRequest);
  }

  /// Rotates the signing secret for a webhook.
  ///
  /// If [request] is omitted, the server uses its default revocation behavior
  /// (24-hour grace period before previous secrets are revoked).
  Future<RotateSigningSecretResponse> rotateSigningSecret({
    required String id,
    RotateSigningSecretRequest? request,
  }) async {
    final url = requestBuilder.buildUrl(
      '/{version}/webhooks/$id:rotateSigningSecret',
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = jsonEncode(request?.toJson() ?? <String, dynamic>{});

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return RotateSigningSecretResponse.fromJson(responseBody);
  }
}
