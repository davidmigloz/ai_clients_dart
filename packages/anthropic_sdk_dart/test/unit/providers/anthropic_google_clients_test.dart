import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _project = 'fixture-project';
const _workspace = 'wrkspc_fixture';
const _model = 'claude-fixture';
const _token = 'fixture-google-token';
const _proxyHeaders = {
  'X-API-Key': 'discard-claude-key',
  'API-KEY': 'discard-azure-key',
  'X-Goog-User-Project': 'fixture-quota-project',
};

void main() {
  test(
    'Google native user profile malformed success does not echo OAuth',
    () async {
      final client = AnthropicGoogleCloudClient(
        projectId: 'fixture',
        accessToken: _token,
        httpClient: MockClient(
          (request) async => http.Response(
            '$_token not JSON',
            200,
            headers: const {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.userProfiles.current.list(),
        throwsA(
          isA<FormatException>().having(
            (error) => '${error.source} $error',
            'no raw OAuth',
            isNot(contains(_token)),
          ),
        ),
      );
    },
  );
  for (final vertex in [false, true]) {
    test('Google vertex=$vertex preserves explicit Authorization', () async {
      for (final provideCallback in [false, true]) {
        var credentialCalls = 0;
        CloudAccessTokenProvider? provider;
        if (provideCallback) {
          provider = () {
            credentialCalls++;
            return _token;
          };
        }
        const config = AnthropicConfig(
          defaultHeaders: {
            'Authorization': 'Bearer explicit-google-token',
            'X-API-Key': 'unrelated-api-key',
          },
        );
        final transport = MockClient((request) async {
          expect(
            request.headers['authorization'],
            'Bearer explicit-google-token',
          );
          expect(request.headers['x-api-key'], isNull);
          return _message();
        });
        final client = vertex
            ? AnthropicVertexClient(
                projectId: _project,
                region: 'us-east5',
                tokenProvider: provider,
                config: config,
                httpClient: transport,
              )
            : AnthropicGoogleCloudClient(
                projectId: _project,
                workspaceId: _workspace,
                tokenProvider: provider,
                config: config,
                httpClient: transport,
              );
        addTearDown(client.close);
        expect((await client.messages.create(_request())).id, 'msg_fixture');
        expect(credentialCalls, 0);
      }
    });
  }

  test(
    'Vertex rejects server-held threads before resolving credentials',
    () async {
      var sends = 0;
      var credentialCalls = 0;
      final client = AnthropicVertexClient(
        projectId: _project,
        region: 'us-east5',
        tokenProvider: () {
          credentialCalls++;
          return _token;
        },
        httpClient: MockClient((_) async {
          sends++;
          return _message();
        }),
      );
      addTearDown(client.close);
      expect(
        () => client.messages.createThread(_request()),
        throwsUnsupportedError,
      );
      final threaded = _request().copyWith(
        thread: const MessageThreadParam.create(),
      );
      const betas = ['message-threads-2026-08-12'];
      await expectLater(
        client.messages.create(threaded, betas: betas),
        throwsUnsupportedError,
      );
      await expectLater(
        client.messages.createStream(threaded, betas: betas).drain<void>(),
        throwsUnsupportedError,
      );
      expect(sends, 0);
      expect(credentialCalls, 0);
      expect((await client.messages.create(_request())).id, 'msg_fixture');
      expect(sends, 1);
    },
  );

  test(
    'Google native gateway carries threads and polls workspace workers',
    () async {
      final client = AnthropicGoogleCloudClient(
        projectId: _project,
        workspaceId: _workspace,
        accessToken: _token,
        httpClient: MockClient((request) async {
          const base =
              '/v1/projects/$_project/locations/global/workspaces/$_workspace/invoke/v1';
          expect(request.headers['authorization'], 'Bearer $_token');
          expect(request.headers['anthropic-workspace-id'], isNull);
          if (request.method == 'GET') {
            expect(
              request.url.path,
              '$base/environments/env_fixture/work/poll',
            );
            expect(request.url.queryParameters['block_ms'], '100');
            return _json('null');
          }
          expect(request.url.path, '$base/messages');
          expect(
            request.headers['anthropic-beta'],
            contains('message-threads-2026-08-12'),
          );
          expect(
            jsonDecode(request.body),
            containsPair('thread', {'type': 'create'}),
          );
          return _message();
        }),
      );
      addTearDown(client.close);
      expect(
        (await client.messages.createThread(_request()).send()).id,
        'msg_fixture',
      );
      expect(
        await client.environments.work('env_fixture').poll(blockMs: 100),
        isNull,
      );
    },
  );

  test(
    'Anthropic-managed Google routes workspace and organization scopes',
    () async {
      final requests = <http.Request>[];
      var credentials = 0;
      final client = AnthropicGoogleCloudClient(
        projectId: _project,
        workspaceId: _workspace,
        tokenProvider: () => Future.value('$_token-${++credentials}'),
        config: const AnthropicConfig(defaultHeaders: _proxyHeaders),
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.url.path.endsWith('/user_profiles')) {
            return _json('{"data":[],"next_page":"cursor_2"}');
          }
          if (request.url.path.endsWith('/count_tokens')) {
            return _json('{"input_tokens":3}');
          }
          if ((jsonDecode(request.body) as Map<String, dynamic>)['stream'] ==
              true) {
            return _stream();
          }
          return _message();
        }),
      );
      addTearDown(client.close);

      expect(
        (await client.messages.create(_request(), workspaceId: 'ignored')).id,
        'msg_fixture',
      );
      expect(
        await client.messages.createStream(_request()).single,
        isA<MessageStopEvent>(),
      );
      expect((await client.messages.countTokens(_count())).inputTokens, 3);
      expect(
        (await client.userProfiles.current.list(page: 'cursor_1')).nextPage,
        'cursor_2',
      );
      const root = '/v1/projects/$_project/locations/global';
      const workspaceRoot = '$root/workspaces/$_workspace/invoke/v1';
      expect(requests.map((r) => r.url.path), [
        '$workspaceRoot/messages',
        '$workspaceRoot/messages',
        '$workspaceRoot/messages/count_tokens',
        '$root/claudeOrganization/invoke/v1/user_profiles',
      ]);
      expect(requests.last.url.queryParameters, {'page': 'cursor_1'});
      for (final (index, request) in requests.indexed) {
        expect(request.url.host, 'claude.googleapis.com');
        expect(request.headers['authorization'], 'Bearer $_token-${index + 1}');
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['x-goog-user-project'], 'fixture-quota-project');
        expect(request.headers, isNot(contains('anthropic-workspace-id')));
        expect(request.headers, isNot(contains('x-api-key')));
        expect(request.headers, isNot(contains('api-key')));
      }
      expect(jsonDecode(requests.first.body), containsPair('model', _model));
    },
  );

  test('Google organization access can omit workspace selection', () async {
    var sends = 0;
    final client = AnthropicGoogleCloudClient(
      projectId: _project,
      accessToken: _token,
      httpClient: MockClient((request) async {
        sends++;
        expect(
          request.url.path,
          '/v1/projects/$_project/locations/global/claudeOrganization/invoke/v1/user_profiles',
        );
        return _json('{"data":[],"next_page":null}');
      }),
    );
    addTearDown(client.close);
    expect((await client.userProfiles.current.list()).data, isEmpty);
    await expectLater(client.messages.create(_request()), throwsArgumentError);
    expect(sends, 1);
  });

  test(
    'Google custom gateway keeps routing and repeated query parameters',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicGoogleCloudClient(
        baseUrl: 'https://fixture.invalid/proxy/?tag=a&tag=b',
        skipAuth: true,
        config: const AnthropicConfig(
          defaultHeaders: {
            'Authorization': 'custom-gateway',
            'X-API-Key': 'gateway-key',
            'API-Key': 'gateway-secondary-key',
          },
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json('{"data":[],"next_page":null}');
        }),
      );
      addTearDown(client.close);
      expect((await client.userProfiles.current.list()).data, isEmpty);
      expect(requests.single.url.path, '/proxy/v1/user_profiles');
      expect(requests.single.url.queryParametersAll, {
        'tag': ['a', 'b'],
      });
      expect(requests.single.headers['authorization'], 'custom-gateway');
      expect(requests.single.headers['x-api-key'], 'gateway-key');
      expect(requests.single.headers['api-key'], 'gateway-secondary-key');
      await expectLater(client.tunnels.list(), throwsUnsupportedError);
      expect(requests, hasLength(1));
    },
  );

  test('Vertex selects global, multi-region and regional hosts', () async {
    for (final (region, host) in [
      ('global', 'aiplatform.googleapis.com'),
      ('us', 'aiplatform.us.rep.googleapis.com'),
      ('eu', 'aiplatform.eu.rep.googleapis.com'),
      ('us-east5', 'us-east5-aiplatform.googleapis.com'),
    ]) {
      final client = AnthropicVertexClient(
        projectId: _project,
        region: region,
        accessToken: _token,
        httpClient: MockClient((request) async {
          expect(request.url.host, host);
          expect(
            request.url.path,
            '/v1/projects/$_project/locations/$region/publishers/anthropic/models/$_model:rawPredict',
          );
          expect(
            jsonDecode(request.body),
            containsPair('anthropic_version', '2026-10-21'),
          );
          return _message();
        }),
      );
      addTearDown(client.close);
      expect((await client.messages.create(_request())).id, 'msg_fixture');
    }
  });

  test(
    'Vertex rewrites model/version, counts tokens, and preserves attribution',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicVertexClient(
        projectId: _project,
        region: 'eu',
        baseUrl: 'https://fixture.invalid/custom/v1/?beta=true&tag=a&tag=b',
        accessToken: _token,
        config: const AnthropicConfig(
          apiVersion: 'vertex-2023-10-16',
          defaultHeaders: _proxyHeaders,
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.url.path.endsWith('count-tokens:rawPredict')) {
            return _json('{"input_tokens":3}');
          }
          return _stream();
        }),
      );
      addTearDown(client.close);
      final events = await client.messages
          .createStream(
            _request('claude/path;fixture'),
            betas: ['fixture-beta'],
            userProfileId: 'uprof_fixture',
          )
          .toList();
      expect(events.single, isA<MessageStopEvent>());
      expect((await client.messages.countTokens(_count())).inputTokens, 3);
      const prefix =
          '/custom/v1/projects/$_project/locations/eu/publishers/anthropic/models';
      expect(requests.map((r) => r.url.path), [
        '$prefix/claude%2Fpath%3Bfixture:streamRawPredict',
        '$prefix/count-tokens:rawPredict',
      ]);
      expect(requests.first.headers['anthropic-beta'], 'fixture-beta');
      expect(
        requests.first.headers['anthropic-user-profile-id'],
        'uprof_fixture',
      );
      final streamBody = jsonDecode(requests.first.body);
      expect(streamBody, isNot(contains('model')));
      expect(streamBody, containsPair('stream', true));
      expect(jsonDecode(requests.last.body), containsPair('model', _model));
      for (final request in requests) {
        expect(request.url.queryParametersAll, {
          'tag': ['a', 'b'],
        });
        expect(request.headers['authorization'], 'Bearer $_token');
        expect(request.headers, isNot(contains('anthropic-version')));
        expect(request.headers, isNot(contains('x-api-key')));
        expect(request.headers, isNot(contains('api-key')));
        expect(
          jsonDecode(request.body),
          containsPair('anthropic_version', 'vertex-2023-10-16'),
        );
      }
      await expectLater(
        client.messages.create(_request('..;fixture')),
        throwsArgumentError,
      );
      await expectLater(client.models.list(), throwsUnsupportedError);
      await expectLater(
        client.userProfiles.current.list(),
        throwsUnsupportedError,
      );
      await expectLater(
        client.messages.create(
          _request().copyWith(fallbacks: const FallbacksParam.defaultMode()),
        ),
        throwsUnsupportedError,
      );
      expect(requests, hasLength(2));
    },
  );

  test('aborting Vertex token acquisition prevents late dispatch', () async {
    final entered = Completer<void>();
    final token = Completer<String>();
    final abort = Completer<void>();
    var sends = 0;
    final client = AnthropicVertexClient(
      projectId: _project,
      region: 'global',
      tokenProvider: () {
        if (!entered.isCompleted) entered.complete();
        return token.future;
      },
      httpClient: MockClient((_) async {
        sends++;
        return _message();
      }),
    );
    addTearDown(client.close);
    final canceled = expectLater(
      client.messages
          .create(_request(), abortTrigger: abort.future)
          .timeout(const Duration(seconds: 2)),
      throwsA(isA<AbortedException>()),
    );
    await entered.future;
    abort.complete();
    await canceled;
    token.complete(_token);
    await Future<void>.delayed(Duration.zero);
    expect(sends, 0);
    expect((await client.messages.create(_request())).id, 'msg_fixture');
    expect(sends, 1);
  });
}

MessageCreateRequest _request([String model = _model]) => MessageCreateRequest(
  model: model,
  maxTokens: 32,
  messages: [InputMessage.user('Hello')],
);

TokenCountRequest _count() =>
    TokenCountRequest(model: _model, messages: [InputMessage.user('Hello')]);

http.Response _message() => _json(
  '{"id":"msg_fixture","type":"message","role":"assistant",'
  '"model":"claude-fixture","content":[],"stop_reason":"end_turn",'
  '"stop_sequence":null,"usage":{"input_tokens":3,"output_tokens":1}}',
);

http.Response _json(String body) =>
    http.Response(body, 200, headers: {'content-type': 'application/json'});

http.Response _stream() => http.Response(
  'data: {"type":"message_stop"}\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);
