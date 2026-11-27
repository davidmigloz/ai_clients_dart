import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentsResource entity wire contract', () {
    const agent = {
      'object': 'agent',
      'id': 'agent-42',
      'model': 'mistral-large-latest',
      'name': 'Test',
      'version': 2,
      'versions': [1, 2],
      'created_at': '2026-11-27T13:04:05.123456Z',
      'updated_at': '2026-11-27T13:04:09.123459Z',
      'deployment_chat': true,
      'source': 'api',
      'owner_id': 'owner-1',
      'handoffs': ['agent-next'],
      'completion_args': {'max_tokens': 128, 'tool_choice': 'required'},
    };
    const alias = {
      'alias': 'stable',
      'version': 2,
      'created_at': '2026-11-27T13:04:05.000Z',
      'updated_at': '2026-11-27T13:04:09.000Z',
    };
    late MistralClient client;
    late List<http.Request> requests;
    late Object body;

    setUp(() {
      requests = [];
      client = MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('fixture')),
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.method == 'DELETE') return http.Response('', 204);
          return http.Response(
            jsonEncode(body),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
    });

    test('reads the legacy offset route as a bare array', () async {
      body = [agent];
      final result = await client.agents.list(
        page: 1,
        pageSize: 10,
        deploymentChat: true,
        sources: ['api', 'playground'],
        metadata: {'team': 'fixtures'},
      );
      final request = requests.single;
      expect(request.method, 'GET');
      expect(request.url.path, '/v1/agents');
      expect(request.url.queryParametersAll, {
        'page': ['1'],
        'page_size': ['10'],
        'deployment_chat': ['true'],
        'sources': ['api', 'playground'],
        'metadata': ['{"team":"fixtures"}'],
      });
      expect(result.data.single.toJson(), agent);
      expect(result.data.single.versions, [1, 2]);
    });

    test(
      'writes creation and update configuration to the correct keys',
      () async {
        body = agent;
        final created = await client.agents.create(
          request: const CreateAgentRequest(
            name: 'Test',
            model: 'mistral-large-latest',
            handoffs: ['agent-next'],
            completionArgs: CompletionArgs(
              maxTokens: 128,
              toolChoice: ToolChoice.required,
            ),
          ),
        );
        await client.agents.update(
          agentId: created.id,
          request: const UpdateAgentRequest(
            deploymentChat: false,
            handoffs: [],
            completionArgs: CompletionArgs(temperature: 0.25),
          ),
        );
        expect(requests.map((request) => request.method), ['POST', 'PATCH']);
        expect(requests.map((request) => request.url.path), [
          '/v1/agents',
          '/v1/agents/agent-42',
        ]);
        expect(jsonDecode(requests.first.body), {
          'name': 'Test',
          'model': 'mistral-large-latest',
          'handoffs': ['agent-next'],
          'completion_args': {'max_tokens': 128, 'tool_choice': 'required'},
        });
        expect(jsonDecode(requests.last.body), {
          'deployment_chat': false,
          'handoffs': <String>[],
          'completion_args': {'temperature': 0.25},
        });
      },
    );

    test(
      'retrieves by version or alias and activates a version with PATCH',
      () async {
        body = agent;
        final selected = await client.agents.retrieve(
          agentId: 'agent-42',
          version: 2,
        );
        await client.agents.retrieve(agentId: 'agent/42', versionAlias: 'prod');
        final activated = await client.agents.updateVersion(
          agentId: selected.id,
          version: selected.version,
        );
        expect(activated.version, 2);
        expect(requests.map((request) => request.method), [
          'GET',
          'GET',
          'PATCH',
        ]);
        expect(requests[0].url.path, '/v1/agents/agent-42');
        expect(requests[1].url.pathSegments, ['v1', 'agents', 'agent/42']);
        expect(requests[2].url.path, '/v1/agents/agent-42/version');
        expect(requests.map((request) => request.url.queryParameters), [
          {'agent_version': '2'},
          {'agent_version': 'prod'},
          {'version': '2'},
        ]);
        expect(requests.last.body, isEmpty);
        await expectLater(
          client.agents.retrieve(
            agentId: 'agent-42',
            version: 2,
            versionAlias: 'prod',
          ),
          throwsArgumentError,
        );
        expect(requests, hasLength(3));
      },
    );

    test('lists and retrieves versions and manages aliases', () async {
      body = [agent];
      final listed = await client.agents.listVersions(
        agentId: 'agent-42',
        page: 2,
        pageSize: 10,
      );
      body = agent;
      await client.agents.retrieveVersion(
        agentId: 'agent-42',
        version: 'stable',
      );

      body = alias;
      final updated = await client.agents.createOrUpdateAlias(
        agentId: 'agent-42',
        alias: 'stable',
        version: 2,
      );
      body = [alias];
      expect(await client.agents.listAliases(agentId: 'agent-42'), [updated]);
      await client.agents.deleteAlias(agentId: 'agent-42', alias: 'stable');
      expect(listed.single.version, updated.version);
      expect(updated.alias, 'stable');
      expect(requests.map((request) => request.method), [
        'GET',
        'GET',
        'PUT',
        'GET',
        'DELETE',
      ]);
      expect(requests.map((request) => request.url.path), [
        '/v1/agents/agent-42/versions',
        '/v1/agents/agent-42/versions/stable',
        '/v1/agents/agent-42/aliases',
        '/v1/agents/agent-42/aliases',
        '/v1/agents/agent-42/aliases',
      ]);
      expect(requests.map((request) => request.url.queryParameters), [
        {'page': '2', 'page_size': '10'},
        <String, String>{},
        {'alias': 'stable', 'version': '2'},
        <String, String>{},
        {'alias': 'stable'},
      ]);
    });
  });

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

    test('guards against a closed client', () async {
      final client = clientReturning({'data': <dynamic>[]})..close();

      // listPages is a regular `async` method: per Dart semantics a throw
      // before the first `await` still completes the returned Future with
      // the error rather than throwing synchronously at the call site, so
      // this is checked by awaiting the Future, not via `throwsStateError`
      // on the call expression itself.
      await expectLater(client.agents.listPages(), throwsStateError);
    });
  });

  group('AgentsResource.completeStream', () {
    test('guards against a closed client eagerly (before subscription)', () {
      final client = MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: MockClient((_) async => http.Response('', 200)),
      )..close();

      expect(
        () => client.agents.completeStream(
          request: const AgentCompletionRequest(
            agentId: 'agent-1',
            messages: [],
          ),
        ),
        throwsStateError,
      );
    });
  });
}
