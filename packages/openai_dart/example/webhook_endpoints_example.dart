// ignore_for_file: avoid_print
/// Offline webhook endpoint lifecycle using only MockClient responses.
/// Run: dart run example/webhook_endpoints_example.dart
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var rotations = 0;
  var requests = 0;
  var endpointName = 'demo';
  var subscriptions = <String>['response.completed'];
  int? updatedAt;
  Map<String, dynamic> endpoint({String id = 'whe_demo'}) => {
    'id': id,
    'object': 'webhook_endpoint',
    'created_at': 1,
    'name': endpointName,
    'url': 'https://receiver.example/webhook',
    'event_types': List<String>.of(subscriptions),
    'updated_at': ?updatedAt,
    'signing_secret_hint': null,
  };
  final transport = MockClient((request) async {
    requests++;
    final path = request.url.path;
    final Object result;
    if (path.endsWith('/webhook_event_types')) {
      result = {
        'object': 'list',
        'data': [
          'response.completed',
          'video.completed',
          'future.project.event',
        ],
      };
    } else if (path.endsWith('/rotate_secret')) {
      rotations++;
      updatedAt = 2 + rotations;
      result = {
        ...endpoint(),
        'signing_secret': 'synthetic_rotation_$rotations',
      };
    } else if (path.endsWith('/test')) {
      result = {
        'object': 'webhook_endpoint.test',
        'webhook_endpoint_id': 'whe_demo',
        'event_type': 'response.completed',
        'success': true,
        'status_code': 500,
      };
    } else if (request.method == 'DELETE') {
      result = {
        'id': 'whe_demo',
        'object': 'webhook_endpoint.deleted',
        'deleted': true,
      };
    } else if (path.endsWith('/webhook_endpoints') && request.method == 'GET') {
      final lastPage = request.url.queryParameters.containsKey('after');
      final id = lastPage ? 'whe_other' : 'whe_demo';
      result = {
        'object': 'list',
        'data': [endpoint(id: id)],
        'first_id': id,
        'last_id': id,
        'has_more': !lastPage,
      };
    } else if (path.endsWith('/webhook_endpoints') &&
        request.method == 'POST') {
      final input = jsonDecode(request.body) as Map<String, dynamic>;
      endpointName = input['name'] as String;
      subscriptions = (input['event_types'] as List).cast<String>();
      result = {...endpoint(), 'signing_secret': 'synthetic_created_secret'};
    } else {
      if (request.method == 'POST') {
        final input = jsonDecode(request.body) as Map<String, dynamic>;
        endpointName = input['name'] as String? ?? endpointName;
        if (input.containsKey('event_types')) {
          subscriptions = (input['event_types'] as List).cast<String>();
        }
        if (input.isNotEmpty) updatedAt = 2;
      }
      result = endpoint();
    }
    return http.Response(jsonEncode(result), 200);
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('synthetic-api-key'),
      webhookSecret: 'synthetic_local_secret',
    ),
    httpClient: transport,
  );
  // This in-memory store is only for synthetic demo values. Deployed applications
  // store returned keys in secure secret storage and manage verification updates.
  final storedSecrets = <String, String>{};
  try {
    final available = await client.webhooks.eventTypes.list();
    print('Discovered ${available.data.length} open event strings.');
    final created = await client.webhooks.create(
      WebhookEndpointCreateRequest(
        name: 'demo',
        url: 'https://receiver.example/webhook',
        eventTypes: const [
          WebhookEventType.responseCompleted,
          WebhookEventType.videoCompleted,
        ],
      ),
    );
    storedSecrets[created.id] = created.signingSecret;
    print('Created endpoint and stored the synthetic signing key.');

    final first = await client.webhooks.list(limit: 1);
    if (!first.hasMore || first.lastId == null) {
      throw StateError('Expected demo cursor.');
    }
    final second = await client.webhooks.list(limit: 1, after: first.lastId);
    print(
      'Listed ${first.data.length + second.data.length} endpoints using returned cursors.',
    );
    await client.webhooks.retrieve(created.id);
    await client.webhooks.update(
      created.id,
      WebhookEndpointUpdateRequest(
        name: 'updated demo',
        eventTypes: const [WebhookEventType.responseCompleted],
      ),
    ); // eventTypes replaces the complete subscription set; {} is also valid.

    // Default false: old secret invalidated immediately. No body is sent.
    final rotated = await client.webhooks.rotateSecret(created.id);
    storedSecrets[created.id] = rotated.signingSecret;
    // Explicit true: retain the previous key for a 24-hour overlap. Applications
    // coordinate stored keys and receiver verification during this overlap.
    final overlap = await client.webhooks.rotateSecret(
      created.id,
      request: WebhookEndpointRotateSecretRequest(
        keepOldSecretActiveFor24Hours: true,
      ),
    );
    storedSecrets[created.id] = overlap.signingSecret;
    if (client.config.webhookSecret != 'synthetic_local_secret') {
      throw StateError(
        'Rotation must not mutate local verifier configuration.',
      );
    }
    if (storedSecrets[created.id] != 'synthetic_rotation_2') {
      throw StateError('Expected explicit application storage update.');
    }

    // Real endpoint.test sends an external delivery. This example mocks it.
    final tested = await client.webhooks.test(
      created.id,
      WebhookEndpointTestRequest(eventType: WebhookEventType.responseCompleted),
    );
    final acknowledged = tested.statusCode >= 200 && tested.statusCode < 300;
    print(
      'Test request completed: ${tested.success}; receiver status: ${tested.statusCode}; acknowledged: $acknowledged.',
    );
    final deleted = await client.webhooks.delete(created.id);
    if (!deleted.deleted) throw StateError('Expected demo deletion.');
    storedSecrets.remove(created.id);
    print('Deleted demo endpoint; $requests mocked requests, no API charges.');
  } finally {
    client.close();
    transport.close();
  }
}
