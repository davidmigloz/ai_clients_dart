import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/webhooks_resource.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

http.StreamedResponse _jsonResponse(Object? body, {int status = 200}) {
  final encoded = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream.value(encoded),
    status,
    headers: {
      'content-type': 'application/json',
      'content-length': '${encoded.length}',
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  late _MockHttpClient mockHttpClient;
  late WebhooksResource resource;
  late List<http.BaseRequest> capturedRequests;
  late List<List<int>?> capturedBodies;

  void stubJsonResponse(Object? body, {int status = 200}) {
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      final req = invocation.positionalArguments.first as http.BaseRequest;
      capturedRequests.add(req);
      if (req is http.Request) {
        capturedBodies.add(req.bodyBytes);
      } else {
        capturedBodies.add(null);
      }
      return _jsonResponse(body, status: status);
    });
  }

  setUp(() {
    mockHttpClient = _MockHttpClient();
    capturedRequests = <http.BaseRequest>[];
    capturedBodies = <List<int>?>[];

    const config = GoogleAIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com',
      authProvider: ApiKeyProvider('test-key'),
    );
    resource = WebhooksResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('WebhooksResource', () {
    test('create() POSTs JSON-encoded webhook and parses response', () async {
      stubJsonResponse({
        'uri': 'https://example.com/hook',
        'subscribed_events': ['interaction.completed'],
        'id': 'wh_123',
      });

      final result = await resource.create(
        webhook: const Webhook(
          uri: 'https://example.com/hook',
          subscribedEvents: ['interaction.completed'],
        ),
      );

      expect(capturedRequests, hasLength(1));
      final req = capturedRequests.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/v1beta/webhooks');
      final body =
          jsonDecode(utf8.decode(capturedBodies.single!))
              as Map<String, dynamic>;
      expect(body['uri'], 'https://example.com/hook');
      expect(body['subscribed_events'], ['interaction.completed']);

      expect(result.id, 'wh_123');
      expect(result.uri, 'https://example.com/hook');
    });

    test('list() GETs /webhooks with optional query params', () async {
      stubJsonResponse({
        'webhooks': [
          {
            'uri': 'https://example.com/hook',
            'subscribed_events': ['interaction.completed'],
            'id': 'wh_1',
          },
        ],
        'next_page_token': 'next',
      });

      final response = await resource.list(pageSize: 25, pageToken: 'token-1');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/webhooks');
      expect(req.url.queryParameters['pageSize'], '25');
      expect(req.url.queryParameters['pageToken'], 'token-1');

      expect(response.webhooks, hasLength(1));
      expect(response.webhooks!.first.id, 'wh_1');
      expect(response.nextPageToken, 'next');
    });

    test('get(id) GETs /webhooks/{id}', () async {
      stubJsonResponse({
        'uri': 'https://example.com/hook',
        'subscribed_events': ['video.generated'],
        'id': 'wh_42',
      });

      final webhook = await resource.get('wh_42');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/webhooks/wh_42');

      expect(webhook.id, 'wh_42');
      expect(webhook.subscribedEvents, ['video.generated']);
    });

    test('update() PATCHes /webhooks/{id} with updateMask', () async {
      stubJsonResponse({
        'uri': 'https://example.com/hook',
        'subscribed_events': ['interaction.completed'],
        'id': 'wh_42',
        'name': 'renamed',
      });

      final webhook = await resource.update(
        id: 'wh_42',
        update: const WebhookUpdate(name: 'renamed'),
        updateMask: 'name',
      );

      final req = capturedRequests.single;
      expect(req.method, 'PATCH');
      expect(req.url.path, '/v1beta/webhooks/wh_42');
      expect(req.url.queryParameters['updateMask'], 'name');

      final body =
          jsonDecode(utf8.decode(capturedBodies.single!))
              as Map<String, dynamic>;
      expect(body, {'name': 'renamed'});

      expect(webhook.name, 'renamed');
    });

    test('delete(id) DELETEs /webhooks/{id} and resolves to void', () async {
      stubJsonResponse(<String, dynamic>{});

      await resource.delete('wh_42');

      final req = capturedRequests.single;
      expect(req.method, 'DELETE');
      expect(req.url.path, '/v1beta/webhooks/wh_42');
    });

    test('ping(id) POSTs /webhooks/{id}:ping with empty body', () async {
      stubJsonResponse(<String, dynamic>{});

      await resource.ping('wh_42');

      final req = capturedRequests.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/v1beta/webhooks/wh_42:ping');
      final body =
          jsonDecode(utf8.decode(capturedBodies.single!))
              as Map<String, dynamic>;
      expect(body, isEmpty);
    });

    test(
      'rotateSigningSecret() POSTs colon-action with optional request body',
      () async {
        stubJsonResponse({'secret': 'new-secret-value'});

        final response = await resource.rotateSigningSecret(
          id: 'wh_42',
          request: const RotateSigningSecretRequest(
            revocationBehavior: SigningSecretRevocationBehavior
                .revokePreviousSecretsImmediately,
          ),
        );

        final req = capturedRequests.single;
        expect(req.method, 'POST');
        expect(req.url.path, '/v1beta/webhooks/wh_42:rotateSigningSecret');

        final body =
            jsonDecode(utf8.decode(capturedBodies.single!))
                as Map<String, dynamic>;
        expect(body, {
          'revocation_behavior': 'revoke_previous_secrets_immediately',
        });

        expect(response.secret, 'new-secret-value');
      },
    );

    test(
      'rotateSigningSecret() sends empty body when request is null',
      () async {
        stubJsonResponse({'secret': 's'});

        await resource.rotateSigningSecret(id: 'wh_42');

        final body =
            jsonDecode(utf8.decode(capturedBodies.single!))
                as Map<String, dynamic>;
        expect(body, isEmpty);
      },
    );
  });
}
