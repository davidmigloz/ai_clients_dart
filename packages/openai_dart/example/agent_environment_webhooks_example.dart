/// Receives synthetic signed environment notifications using local HTTP mocks.
/// No API key, provisioning request, external delivery or cloud compute is used.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final key = utf8.encode('public-offline-environment-fixture');
  final secret = 'whsec_${base64Encode(key)}';
  const subscriptions = [
    WebhookEventType.agentEnvironmentReady,
    WebhookEventType.agentEnvironmentFailed,
    WebhookEventType.agentEnvironmentSuspended,
    WebhookEventType.agentEnvironmentExpired,
  ];
  var currentStatus = 'ready';
  var retrieves = 0;
  final transport = MockClient((request) async {
    if (request.headers['openai-project'] != 'project_example') {
      throw StateError('Select the intended project explicitly.');
    }
    if (request.method == 'POST' &&
        request.url.path == '/v1/webhook_endpoints') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({
        'id': 'endpoint_fixture',
        'object': 'webhook_endpoint',
        'created_at': 1,
        ...body,
        'signing_secret_hint': null,
        'signing_secret': secret,
      });
    }
    if (request.method == 'GET' &&
        request.url.path == '/v1/agents/environments/environment_fixture') {
      retrieves++;
      return _json({
        'id': 'environment_fixture',
        'object': 'agent.environment',
        'type': 'openai_hosted',
        'status': currentStatus,
        'files': <Object?>[],
        'skills': <Object?>[],
        'plugins': <Object?>[],
      });
    }
    throw StateError('Unexpected synthetic HTTP request.');
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(project: 'project_example'),
    httpClient: transport,
  );
  try {
    final endpoint = await client.webhooks.create(
      WebhookEndpointCreateRequest(
        name: 'Environment notifications',
        url: 'https://receiver.example/environments',
        eventTypes: subscriptions,
      ),
    );
    // Production applications store this one-time secret in secret storage.
    // Deduplication/acknowledgment belongs to the receiver, not the API client.
    final seen = <String>{};
    for (final status in ['ready', 'ready', 'failed', 'suspended', 'expired']) {
      currentStatus = status;
      final bytes = utf8.encode(
        jsonEncode({
          'id': 'event_$status',
          'object': 'event',
          'created_at': 1,
          'type': 'agent.environment.$status',
          'data': {'id': 'environment_fixture'},
        }),
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = Hmac(
        sha256,
        key,
      ).convert([...utf8.encode('delivery.$timestamp.'), ...bytes]);
      final event = client.webhooks.unwrapBytes(bytes, {
        'webhook-id': 'delivery',
        'webhook-timestamp': '$timestamp',
        'webhook-signature': 'v1,${base64Encode(signature.bytes)}',
      }, secret: endpoint.signingSecret);
      if (event is! WebhookAgentSessionEnvelope ||
          event.data is! WebhookIdData) {
        throw StateError('Unexpected synthetic environment notification.');
      }
      if (!seen.add(event.id)) continue;
      final environment = await client.agents.environments.retrieve(
        (event.data! as WebhookIdData).id,
      );
      if (environment.status.value != status) {
        throw StateError('Unexpected state.');
      }
      // ready/failed describe prewarm setup. Suspended may resume from its
      // snapshot; expired cannot. Receipt grants no lifecycle-control operation.
    }
    if (retrieves != 4) throw StateError('Application deduplication failed.');
    stdout
      ..writeln(
        'Verified four environment event types; ignored one repeated ID.',
      )
      ..writeln('Zero external API requests or environment provisioning.');
  } finally {
    client.close();
    transport.close();
  }
}

http.Response _json(Map<String, dynamic> value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json'},
);
