import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import 'webhook_verifier_vectors.dart';

const List<WebhookEventType> _types = [
  WebhookEventType.agentEnvironmentReady,
  WebhookEventType.agentEnvironmentFailed,
  WebhookEventType.agentEnvironmentSuspended,
  WebhookEventType.agentEnvironmentExpired,
];

void main() {
  test(
    'all four subscriptions survive public project create/update/read/list',
    () async {
      final requests = <http.Request>[];
      final endpoint = <String, dynamic>{
        'id': 'endpoint_environment',
        'object': 'webhook_endpoint',
        'created_at': 1,
        'name': 'Environment receiver',
        'url': 'https://receiver.example/environment',
        'event_types': _types.map((type) => type.toJson()).toList(),
        'signing_secret_hint': null,
      };
      final transport = MockClient((request) async {
        requests.add(request);
        final json =
            request.method == 'GET' &&
                request.url.path.endsWith('/webhook_endpoints')
            ? {
                'object': 'list',
                'data': [endpoint],
                'first_id': endpoint['id'],
                'last_id': endpoint['id'],
                'has_more': false,
              }
            : request.method == 'POST' &&
                  request.url.path.endsWith('/webhook_endpoints')
            ? {...endpoint, 'signing_secret': 'synthetic-secret-returned-once'}
            : endpoint;
        return http.Response(jsonEncode(json), 200);
      });
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('synthetic-api-key'),
          project: 'project-selected',
          organization: 'organization-selected',
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      final created = await client.webhooks.create(
        WebhookEndpointCreateRequest(
          name: 'Environment receiver',
          url: 'https://receiver.example/environment',
          eventTypes: _types,
        ),
      );
      final updated = await client.webhooks.update(
        created.id,
        WebhookEndpointUpdateRequest(eventTypes: _types),
      );
      final retrieved = await client.webhooks.retrieve(created.id);
      final listed = await client.webhooks.list();
      final expected = _types.map((type) => type.value).toList();
      for (final value in [
        created.eventTypes,
        updated.eventTypes,
        retrieved.eventTypes,
        listed.data.single.eventTypes,
      ]) {
        expect(value, expected);
      }
      expect(requests.map((request) => request.method), [
        'POST',
        'POST',
        'GET',
        'GET',
      ]);
      for (final request in requests) {
        expect(request.headers['authorization'], 'Bearer synthetic-api-key');
        expect(request.headers['openai-project'], 'project-selected');
        expect(request.headers['openai-organization'], 'organization-selected');
        expect(request.headers.containsKey('openai-beta'), isFalse);
        if (request.method == 'POST') {
          expect((jsonDecode(request.body) as Map)['event_types'], expected);
        }
      }
      for (final choice in _types) {
        expect(WebhookEventType.fromJson(choice.value), choice);
        expect(WebhookEndpointTestRequest(eventType: choice).toJson(), {
          'event_type': choice.value,
        });
      }
    },
  );

  for (final choice in _types) {
    test('${choice.value} authenticates original bytes before handling', () {
      var httpCalls = 0;
      final transport = MockClient((request) {
        httpCalls++;
        throw StateError('Local verification must not use HTTP');
      });
      final client = OpenAIClient(
        config: const OpenAIConfig(webhookSecret: officialWebhookTestSecret),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      final body = utf8.encode(
        ' \n${jsonEncode({
          'id': 'PRIVATE-event',
          'object': 'event',
          'created_at': 1,
          'type': choice.value,
          'data': {'id': 'PRIVATE-environment'},
          'future': {'label': 'café 🚀 é'},
        })}\r\n',
      );
      final headers = _signed(body);
      final event = client.webhooks.unwrapBytes(body, headers);
      expect(event.type, choice.value);
      expect((event.data! as WebhookIdData).id, 'PRIVATE-environment');
      expect(event, client.webhooks.unwrapBytes(body, headers));
      expect(event.toString(), isNot(contains('PRIVATE')));
      for (final changed in [
        <int>[...body, 32],
        utf8.encode('{}'),
      ]) {
        expect(
          () => client.webhooks.unwrapBytes(changed, headers),
          throwsA(isA<InvalidWebhookSignatureException>()),
        );
      }
      expect(
        () => client.webhooks.unwrapBytes(body, {
          ...headers,
          'webhook-signature': 'v1,invalid',
        }),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
      final old = _signed(body, offset: const Duration(minutes: -10));
      expect(
        () => client.webhooks.unwrapBytes(body, old),
        throwsA(isA<InvalidWebhookSignatureException>()),
      );
      expect(httpCalls, 0);
    });
  }

  test(
    'new typed notifications coexist with existing Agent session and future events',
    () {
      expect(
        WebhookEvent.fromJson(const {
          'id': 'evt',
          'object': 'event',
          'created_at': 1,
          'type': 'agent.session.idle',
          'data': {'id': 'session', 'environment_type': 'none'},
        }),
        isA<AgentSessionIdleWebhookEvent>(),
      );
      expect(
        WebhookEvent.fromJson(const {
          'type': 'future.notification',
          'data': {'private': 'value'},
        }),
        isA<UnknownWebhookEvent>(),
      );
    },
  );
}

Map<String, String> _signed(
  List<int> bytes, {
  Duration offset = Duration.zero,
}) {
  final timestamp = DateTime.now().add(offset).millisecondsSinceEpoch ~/ 1000;
  final signed = <int>[...utf8.encode('delivery.$timestamp.'), ...bytes];
  final signature = Hmac(
    sha256,
    base64Decode(officialWebhookKeyBase64),
  ).convert(signed).bytes;
  return {
    'webhook-id': 'delivery',
    'webhook-timestamp': '$timestamp',
    'webhook-signature': 'v1,${base64Encode(signature)}',
  };
}
