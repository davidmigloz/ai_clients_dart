@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentsResource.listPages', () {
    late http.Request captured;

    MistralClient clientReturning(Object body) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('hits GET /v1/agents/pages and plumbs query params', () async {
      final client = clientReturning({
        'data': [
          {
            'id': 'agent-1',
            'name': 'My Agent',
            'model': 'mistral-large-latest',
            'instructions': 'Be helpful',
          },
        ],
        'next_page_token': 'cursor-1',
      });
      addTearDown(client.close);

      final result = await client.agents.listPages(
        pageSize: 10,
        deploymentChat: true,
        sources: const ['api', 'playground'],
        name: 'My Agent',
        search: 'helpful',
        id: 'agent-1',
        pageToken: 'cursor-0',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/agents/pages');
      expect(captured.url.queryParameters['page_size'], '10');
      expect(captured.url.queryParameters['deployment_chat'], 'true');
      expect(captured.url.queryParametersAll['sources'], ['api', 'playground']);
      expect(captured.url.queryParameters['name'], 'My Agent');
      expect(captured.url.queryParameters['search'], 'helpful');
      expect(captured.url.queryParameters['id'], 'agent-1');
      expect(captured.url.queryParameters['page_token'], 'cursor-0');
      expect(result.data, hasLength(1));
      expect(result.nextPageToken, 'cursor-1');
    });

    test('JSON-encodes the metadata filter into the query value', () async {
      final client = clientReturning({'data': <dynamic>[]});
      addTearDown(client.close);

      await client.agents.listPages(metadata: const {'env': 'prod'});

      expect(
        captured.url.queryParameters['metadata'],
        jsonEncode({'env': 'prod'}),
      );
    });
  });
}
