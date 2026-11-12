import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

typedef _Call = Future<Object?> Function(AnthropicClient, String);

void main() {
  final routes = <(String, _Call)>[
    ('files/:id/content', (client, id) => client.files.download(fileId: id)),
    (
      'messages/batches/:id/results',
      (client, id) => client.batches.results(id).drain<Object?>(),
    ),
    (
      'skills/skill_fixed/versions/:id',
      (client, id) =>
          client.skills.retrieveVersion(skillId: 'skill_fixed', version: id),
    ),
    (
      'skills/:id/versions/:id/content',
      (client, id) => client.skills.downloadVersion(skillId: id, version: id),
    ),
    ('models/:id', (client, id) => client.models.retrieve(id)),
    ('user_profiles/:id', (client, id) => client.userProfiles.retrieve(id)),
    ('agents/:id', (client, id) => client.agents.retrieve(id)),
    ('sessions/:id', (client, id) => client.sessions.retrieve(id)),
    (
      'sessions/:id/threads/:id',
      (client, id) => client.sessions.threads(id).retrieve(id),
    ),
    (
      'sessions/:id/threads/:id/stream',
      (client, id) =>
          client.sessions.threads(id).events(id).stream().drain<Object?>(),
    ),
    (
      'sessions/session_fixed/resources/:id',
      (client, id) => client.sessions.resources('session_fixed').retrieve(id),
    ),
    (
      'vaults/:id/credentials/:id',
      (client, id) => client.vaults.credentials(id).retrieve(id),
    ),
    ('memory_stores/:id', (client, id) => client.memoryStores.retrieve(id)),
    (
      'memory_stores/:id/memories/:id',
      (client, id) => client.memoryStores.memories(id).retrieve(id),
    ),
    (
      'memory_stores/:id/memory_versions/:id',
      (client, id) => client.memoryStores.memoryVersions(id).retrieve(id),
    ),
    ('deployments/:id', (client, id) => client.deployments.retrieve(id)),
    ('deployment_runs/:id', (client, id) => client.deploymentRuns.retrieve(id)),
    ('dreams/:id', (client, id) => client.dreams.retrieve(id)),
    ('environments/:id', (client, id) => client.environments.retrieve(id)),
    (
      'environments/:id/work/:id/ack',
      (client, id) => client.environments
          .work(id, bearerToken: 'environment-fixture')
          .ack(id),
    ),
    (
      'tunnels/:id',
      (client, id) => client.tunnels.withToken('tunnel-fixture').retrieve(id),
    ),
    (
      'tunnels/:id/certificates/:id',
      (client, id) => client.tunnels
          .withToken('tunnel-fixture')
          .certificates(id)
          .retrieve(id),
    ),
    (
      'organizations/workspaces/:id',
      (client, id) => client.organization.workspaces.retrieve(id),
    ),
    (
      'compliance/apps/chats/files/:id/content',
      (client, id) =>
          client.compliance.apps.downloadChatFile(id).drain<Object?>(),
    ),
  ];

  for (final (path, call) in routes) {
    test('encodes one opaque identifier per $path path parameter', () async {
      final requests = <http.Request>[];
      final client = _client(requests);
      addTearDown(client.close);

      for (final id in ['opaque/id?tenant=changed#fragment%2f', '%2E%2e']) {
        await expectLater(
          call(client, id),
          throwsA(
            isA<ApiException>().having(
              (error) => error.statusCode,
              'status',
              418,
            ),
          ),
        );
        final url = requests.last.url;
        expect(url.pathSegments, [
          'proxy',
          'scope',
          'v1',
          for (final segment in path.split('/'))
            if (segment == ':id') id else segment,
        ]);
        expect(url.hasFragment, isFalse);
        expect(url.queryParametersAll, {
          'keep': ['one', 'two'],
          'tenant': ['fixed'],
        });
        expect(url.path, contains(Uri.encodeComponent(id)));
      }
    });

    test('rejects unsafe $path identifiers before transport', () async {
      final requests = <http.Request>[];
      final client = _client(requests);
      addTearDown(client.close);
      for (final id in [
        '',
        '.',
        '..',
        '..;route',
        ';route',
        String.fromCharCode(0xd800),
      ]) {
        await expectLater(
          Future<Object?>.sync(() => call(client, id)),
          throwsArgumentError,
        );
      }
      expect(requests, isEmpty);
    });
  }
}

AnthropicClient _client(List<http.Request> requests) => AnthropicClient(
  config: const AnthropicConfig(
    baseUrl: 'https://fixture.invalid/proxy/scope/?keep=one&keep=two',
    defaultQueryParams: {'tenant': 'fixed'},
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: MockClient((request) async {
    requests.add(request);
    return http.Response(
      '{"error":{"type":"invalid_request_error","message":"fixture"}}',
      418,
      headers: {'content-type': 'application/json'},
    );
  }),
);
