import 'dart:async' show Completer, FutureOr, StreamController;
import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/auth/workload_identity.dart'
    show WorkloadIdentityAuthProvider;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _assertion = 'synthetic.identity.secret';
const _token = 'synthetic-access-token';
const _beta = 'oauth-2025-04-20';
const _baseUrl = 'https://fixture.invalid/proxy/';
const _tokenPath = '/proxy/v1/oauth/token';
const ({String rule, String organization, String account, String workspace})
_ids = (
  rule: 'fdrl_fixture',
  organization: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  account: 'svac_fixture',
  workspace: 'wrkspc_fixture',
);
const _date = '2026-11-11T00:00:00Z';

void main() {
  test(
    'exchanges the RFC 7523 JWT without resource auth or version headers',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        return _tokenResponse();
      });
      addTearDown(transport.close);
      final exchange = _exchange(transport);
      final token = await _mint(exchange);
      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, _tokenPath);
      expect(request.followRedirects, isFalse);
      expect(request.headers['authorization'], isNull);
      expect(request.headers['x-api-key'], isNull);
      expect(request.headers['anthropic-version'], isNull);
      expect(request.headers['content-type'], 'application/json');
      expect(
        request.headers['anthropic-beta'],
        '$_beta,oidc-federation-2026-04-01',
      );
      expect(jsonDecode(request.body), {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': _assertion,
        'federation_rule_id': _ids.rule,
        'organization_id': _ids.organization,
        'service_account_id': _ids.account,
        'workspace_id': _ids.workspace,
      });
      expect(token.accessToken, _token);
      expect(token.expiresIn, const Duration(seconds: 600));
      expect(token.scope, 'workspace:inference');
      expect(token.toString(), isNot(contains(_token)));
    },
  );

  test('safely preserves status, ID and Retry-After on token errors', () async {
    final transport = MockClient(
      (_) async => _json(
        {
          'request_id': 'req_body',
          'error': {'type': 'rate_limit_error', 'message': _assertion},
          'access_token': _token,
        },
        status: 429,
        headers: {
          'request-id': 'req_header',
          'retry-after': '2',
          'set-cookie': 'private',
        },
      ),
    );
    addTearDown(transport.close);
    await expectLater(
      _mint(_exchange(transport)),
      throwsA(
        isA<RateLimitException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.requestId, 'provider ID', 'req_header')
            .having((e) => e.retryAfter, 'retryAfter', isNotNull)
            .having((e) => e.responseMetadata?.bodyExcerpt, 'body excerpt', '')
            .having(
              (e) => e.responseMetadata?.headers,
              'safe headers',
              isNot(contains('set-cookie')),
            )
            .having(
              (e) => e.toString(),
              'formatted error',
              allOf(isNot(contains(_assertion)), isNot(contains(_token))),
            ),
      ),
    );
  });

  test('removes the submitted assertion from error metadata', () async {
    final transport = MockClient(
      (_) async => _json(
        {
          'request_id': _assertion,
          'error': {'type': 'rate_limit_error', 'message': _assertion},
        },
        status: 429,
        headers: {
          'request-id': 'proxy-$_assertion',
          'retry-after': _assertion,
          'retry-after-ms': '2000',
        },
      ),
    );
    addTearDown(transport.close);
    await expectLater(
      _mint(_exchange(transport)),
      throwsA(
        isA<RateLimitException>()
            .having((error) => error.requestId, 'provider ID', isNull)
            .having(
              (error) => error.responseMetadata?.headers,
              'safe headers',
              {'retry-after-ms': '2000'},
            )
            .having(
              (error) => error.responseMetadata?.bodyRequestId,
              'body ID',
              isNull,
            )
            .having((error) => error.retryAfter, 'retry deadline', isNotNull),
      ),
    );
  });

  test('retains a safe body ID when the header echoes the assertion', () async {
    final transport = MockClient(
      (_) async => _json(
        {
          'request_id': 'req_safe_body',
          'error': {'type': 'invalid_request_error', 'message': _assertion},
        },
        status: 400,
        headers: {'request-id': 'proxy-$_assertion'},
      ),
    );
    addTearDown(transport.close);
    final client = _client(transport, () => _assertion);
    addTearDown(client.close);
    await expectLater(
      client.messages.countTokens(_countRequest),
      throwsA(
        isA<ApiException>()
            .having((error) => error.requestId, 'provider ID', 'req_safe_body')
            .having(
              (error) => error.responseMetadata?.headers,
              'headers',
              isEmpty,
            ),
      ),
    );
  });

  test('does not follow redirects or retain Location', () async {
    var sends = 0;
    final transport = MockClient((request) async {
      sends++;
      expect(request.followRedirects, isFalse);
      return http.Response(
        _assertion,
        307,
        headers: {
          'request-id': 'req_redirect',
          'location': 'https://other.invalid/$_assertion',
        },
      );
    });
    addTearDown(transport.close);
    await expectLater(
      _mint(_exchange(transport)),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 307)
            .having((e) => e.requestId, 'request ID', 'req_redirect')
            .having(
              (e) => e.responseMetadata?.headers,
              'safe headers',
              isNot(contains('location')),
            ),
      ),
    );
    expect(sends, 1);
  });

  test(
    'malformed token success never retains the raw body as a cause',
    () async {
      final transport = MockClient(
        (_) async => http.Response('["$_token"', 200),
      );
      addTearDown(transport.close);
      await expectLater(
        _mint(_exchange(transport)),
        throwsA(
          isA<FormatException>()
              .having((e) => e.source, 'source', isNull)
              .having(
                (e) => e.toString(),
                'formatted error',
                isNot(contains(_token)),
              ),
        ),
      );
    },
  );

  test('oversized token responses retain safe diagnostics', () async {
    final transport = MockClient(
      (_) async => http.Response.bytes(
        Uint8List(1024 * 1024 + 1),
        200,
        headers: {'request-id': 'req_large'},
      ),
    );
    addTearDown(transport.close);
    await expectLater(
      _mint(_exchange(transport)),
      throwsA(
        isA<ApiException>()
            .having((error) => error.requestId, 'request ID', 'req_large')
            .having(
              (error) => error.responseMetadata?.bodyExcerpt,
              'body excerpt',
              '',
            ),
      ),
    );
  });

  test('the exchange timeout signals the borrowed HTTP transport', () async {
    final transport = _PendingTransport();
    final exchange = WorkloadIdentityTokenExchange(
      httpClient: transport,
      baseUrl: _baseUrl,
      timeout: const Duration(milliseconds: 20),
    );
    await expectLater(_mint(exchange), throwsA(isA<TimeoutException>()));
    await transport.abortTrigger!.timeout(const Duration(seconds: 2));
    transport.complete();
    expect(transport.closed, isFalse);
  });

  test(
    'timeout cancels a stalled token body even without native abort',
    () async {
      final transport = _StalledBodyTransport();
      final exchange = WorkloadIdentityTokenExchange(
        httpClient: transport,
        baseUrl: _baseUrl,
        timeout: const Duration(milliseconds: 20),
      );
      addTearDown(transport.body.close);
      await expectLater(_mint(exchange), throwsA(isA<TimeoutException>()));
      await transport.canceled.future.timeout(const Duration(seconds: 2));
      expect(transport.body.hasListener, isFalse);
    },
  );

  test(
    'client close releases blocked identity waiters without late dispatch',
    () async {
      final started = Completer<void>();
      final identity = Completer<String>();
      var sends = 0;
      final transport = MockClient((request) async {
        sends++;
        return _tokenResponse();
      });
      addTearDown(transport.close);
      final client = _client(transport, () {
        started.complete();
        return identity.future;
      });
      addTearDown(client.close);
      final first = expectLater(
        client.messages.countTokens(_countRequest),
        throwsStateError,
      );
      final sibling = expectLater(
        client.messages.countTokens(_countRequest),
        throwsStateError,
      );
      await started.future;
      client.close();
      await Future.wait([first, sibling]).timeout(const Duration(seconds: 2));
      identity.complete(_assertion);
      await Future<void>.delayed(Duration.zero);
      expect(sends, 0);
    },
  );

  test(
    'client close aborts token exchange and discards late response headers',
    () async {
      final transport = _PendingTransport();
      final client = _client(transport, () => _assertion);
      addTearDown(client.close);
      final result = expectLater(
        client.messages.countTokens(_countRequest),
        throwsStateError,
      );
      await transport.started.future;
      client.close();
      await result.timeout(const Duration(seconds: 2));
      await transport.abortTrigger!.timeout(const Duration(seconds: 2));

      final canceled = Completer<void>();
      final body = StreamController<List<int>>(onCancel: canceled.complete);
      transport.complete(body.stream);
      await canceled.future.timeout(const Duration(seconds: 2));
      await body.close();
      expect(transport.closed, isFalse);
    },
  );

  test(
    'client close cancels an in-progress borrowed token response body',
    () async {
      final transport = _StalledBodyTransport();
      final client = _client(transport, () => _assertion);
      addTearDown(client.close);
      final result = expectLater(
        client.messages.countTokens(_countRequest),
        throwsStateError,
      );
      await transport.listening.future;
      client.close();
      await result.timeout(const Duration(seconds: 2));
      await transport.abortTrigger!.timeout(const Duration(seconds: 2));
      await transport.canceled.future.timeout(const Duration(seconds: 2));
      expect(transport.body.hasListener, isFalse);
      expect(transport.closed, isFalse);
      await transport.body.close();
    },
  );

  test('bounds assertion bytes and requires a secure exchange URL', () {
    final transport = MockClient(
      (_) async => throw StateError('unexpected send'),
    );
    addTearDown(transport.close);
    expect(
      () => WorkloadIdentityTokenExchange(
        httpClient: transport,
        baseUrl: 'http://localhost.example.invalid',
      ),
      throwsArgumentError,
    );
    expect(
      () => _mint(_exchange(transport), assertion: 'é' * 8193),
      throwsArgumentError,
    );
  });

  test(
    'client coalesces exchange and reuses the token for public calls',
    () async {
      final identity = Completer<String>();
      var identityCalls = 0;
      var tokenCalls = 0;
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        if (request.url.path == _tokenPath) {
          tokenCalls++;
          return _tokenResponse();
        }
        expect(request.headers['authorization'], 'Bearer $_token');
        expect(request.headers['x-api-key'], isNull);
        expect(request.headers['anthropic-workspace-id'], isNull);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['anthropic-beta'], 'fixture-beta,$_beta');
        return _json({'input_tokens': 11});
      });
      addTearDown(transport.close);
      final client = _client(transport, () {
        identityCalls++;
        return identity.future;
      }, defaultHeaders: {'Anthropic-Beta': 'fixture-beta'});
      addTearDown(client.close);
      final first = client.messages.countTokens(_countRequest);
      final second = client.messages.countTokens(_countRequest);
      identity.complete(_assertion);
      final responses = await Future.wait([first, second]);
      expect(responses.map((response) => response.inputTokens), [11, 11]);
      expect(
        (await client.messages.countTokens(_countRequest)).inputTokens,
        11,
      );
      expect(identityCalls, 1);
      expect(tokenCalls, 1);
      expect(requests.map((request) => request.url.path), [
        _tokenPath,
        ...List.filled(3, '/proxy/v1/messages/count_tokens'),
      ]);
    },
  );

  test(
    'explicit auth overrides skip exchange and workspace override fails',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/proxy/v1/messages/count_tokens');
        expect(request.headers['x-api-key'], 'explicit');
        expect(request.headers['authorization'], isNull);
        return _json({'input_tokens': 3});
      });
      addTearDown(transport.close);
      String unexpectedIdentity() =>
          throw StateError('Unexpected identity call');
      final overridden = _client(
        transport,
        unexpectedIdentity,
        defaultHeaders: {'X-API-KEY': 'explicit'},
      );
      addTearDown(overridden.close);
      expect(
        (await overridden.messages.countTokens(_countRequest)).inputTokens,
        3,
      );
      final scoped = _client(transport, unexpectedIdentity);
      addTearDown(scoped.close);
      await expectLater(
        scoped.messages.countTokens(_countRequest, workspaceId: 'other'),
        throwsArgumentError,
      );
    },
  );

  test(
    'mandatory refresh reads a fresh assertion and coalesces callers',
    () async {
      var now = DateTime.utc(2026, 11, 11);
      var assertionCount = 0;
      final assertions = <String>[];
      final transport = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        assertions.add(body['assertion'] as String);
        return _tokenResponse(token: 'access-${assertions.length}');
      });
      addTearDown(transport.close);
      final provider = WorkloadIdentityAuthProvider(
        exchange: _exchange(transport),
        identityTokenProvider: () => 'assertion-${++assertionCount}',
        federationRuleId: _ids.rule,
        organizationId: _ids.organization,
        serviceAccountId: _ids.account,
        now: () => now,
      );
      expect((await provider.getCredentials()).token, 'access-1');
      now = now.add(const Duration(seconds: 575));
      final refreshed = await Future.wait([
        provider.getCredentials(),
        provider.getCredentials(),
      ]);
      expect(refreshed.map((credential) => credential.token), [
        'access-2',
        'access-2',
      ]);
      expect(assertions, ['assertion-1', 'assertion-2']);
    },
  );

  test(
    'advisory refresh failure retains a valid token and backs off',
    () async {
      var now = DateTime.utc(2026, 11, 11);
      var exchanges = 0;
      final refreshStarted = Completer<void>();
      final refreshResponse = Completer<http.Response>();
      final transport = MockClient((request) async {
        exchanges++;
        if (exchanges == 2) {
          refreshStarted.complete();
          return refreshResponse.future;
        }
        return _tokenResponse(token: 'access-$exchanges');
      });
      addTearDown(transport.close);
      final provider = WorkloadIdentityAuthProvider(
        exchange: _exchange(transport),
        identityTokenProvider: () => _assertion,
        federationRuleId: _ids.rule,
        organizationId: _ids.organization,
        serviceAccountId: _ids.account,
        now: () => now,
      );
      expect((await provider.getCredentials()).token, 'access-1');
      now = now.add(const Duration(seconds: 500));
      expect((await provider.getCredentials()).token, 'access-1');
      await refreshStarted.future;
      expect((await provider.getCredentials()).token, 'access-1');
      refreshResponse.complete(
        _json({
          'error': {'type': 'authentication_error'},
        }, status: 401),
      );
      await Future<void>.delayed(Duration.zero);
      expect((await provider.getCredentials()).token, 'access-1');
      await Future<void>.delayed(Duration.zero);
      expect(exchanges, 2);
    },
  );

  test(
    'OAuth beta and bearer auth reach SSE and direct Files and Skills',
    () async {
      final paths = <String>[];
      final transport = MockClient((request) async {
        final path = request.url.path;
        paths.add(path);
        expect(request.headers['authorization'], 'Bearer $_token');
        expect(request.headers['x-api-key'], isNull);
        expect(request.headers['anthropic-beta'], 'fixture-beta,$_beta');
        if (path == '/proxy/v1/messages') {
          return http.Response(
            'event: ping\ndata: {"type":"ping"}\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        if (path == '/proxy/v1/files/file_fixture/content') {
          return http.Response.bytes([0, 255], 200);
        }
        return _json({
          'id': 'skill_fixture',
          'display_name': 'Fixture',
          'latest_version_id': 'skillver_fixture',
          'source': {'type': 'custom'},
          'created_at': _date,
          'updated_at': _date,
        });
      });
      addTearDown(transport.close);
      final client = AnthropicClient.withAuthToken(
        _token,
        config: const AnthropicConfig(
          baseUrl: _baseUrl,
          defaultHeaders: {'anthropic-beta': 'fixture-beta,$_beta'},
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      final events = await client.messages
          .createStream(
            MessageCreateRequest(
              model: 'claude-fixture',
              maxTokens: 12,
              messages: [InputMessage.user('Hello')],
            ),
          )
          .toList();
      expect(events.single, isA<PingEvent>());
      expect(await client.files.download(fileId: 'file_fixture'), [0, 255]);
      final skill = await client.skills.create(
        files: [
          SkillFile(path: 'fixture/SKILL.md', bytes: Uint8List.fromList([65])),
        ],
      );
      expect(skill.id, 'skill_fixture');
      expect(paths, [
        '/proxy/v1/messages',
        '/proxy/v1/files/file_fixture/content',
        '/proxy/v1/skills',
      ]);
      expect(
        const BearerTokenCredentials(_token).toString(),
        isNot(contains(_token)),
      );
      expect(
        const BearerTokenProvider(_token).toString(),
        isNot(contains(_token)),
      );
    },
  );
}

final _countRequest = TokenCountRequest(
  model: 'claude-fixture',
  messages: [InputMessage.user('Hello')],
);

AnthropicClient _client(
  http.Client transport,
  FutureOr<String> Function() identityTokenProvider, {
  Map<String, String> defaultHeaders = const {},
}) => AnthropicClient.withWorkloadIdentity(
  identityTokenProvider: identityTokenProvider,
  federationRuleId: _ids.rule,
  organizationId: _ids.organization,
  serviceAccountId: _ids.account,
  workspaceId: _ids.workspace,
  config: AnthropicConfig(baseUrl: _baseUrl, defaultHeaders: defaultHeaders),
  httpClient: transport,
);

WorkloadIdentityTokenExchange _exchange(http.Client transport) =>
    WorkloadIdentityTokenExchange(httpClient: transport, baseUrl: _baseUrl);

Future<WorkloadIdentityAccessToken> _mint(
  WorkloadIdentityTokenExchange exchange, {
  String assertion = _assertion,
}) => exchange.exchange(
  assertion: assertion,
  federationRuleId: _ids.rule,
  organizationId: _ids.organization,
  serviceAccountId: _ids.account,
  workspaceId: _ids.workspace,
);

http.Response _tokenResponse({String token = _token}) => _json({
  'access_token': token,
  'expires_in': 600,
  'token_type': 'Bearer',
  'scope': 'workspace:inference',
});

http.Response _json(
  Map<String, Object?> body, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json', ...headers},
);

class _PendingTransport extends http.BaseClient {
  final _response = Completer<http.StreamedResponse>();
  final started = Completer<void>();
  Future<void>? abortTrigger;
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    abortTrigger = (request as http.Abortable).abortTrigger;
    started.complete();
    return _response.future;
  }

  void complete([Stream<List<int>> body = const Stream.empty()]) =>
      _response.complete(http.StreamedResponse(body, 200));

  @override
  void close() => closed = true;
}

class _StalledBodyTransport extends http.BaseClient {
  final listening = Completer<void>();
  final canceled = Completer<void>();
  late final body = StreamController<List<int>>(
    onListen: listening.complete,
    onCancel: canceled.complete,
  );
  Future<void>? abortTrigger;
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    abortTrigger = (request as http.Abortable).abortTrigger;
    return http.StreamedResponse(body.stream, 200);
  }

  @override
  void close() => closed = true;
}
