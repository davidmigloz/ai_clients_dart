import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/vault_wire_fixtures.dart';

const _ops = [
  'createVault',
  'listVaults',
  'retrieveVault',
  'updateVault',
  'deleteVault',
  'createCredential',
  'listCredentials',
  'retrieveCredential',
  'rotateCredential',
  'deleteCredential',
];
Map<String, dynamic> _wire(String schema, {bool minimal = false}) {
  final f = vaultWireFixtures.singleWhere((v) => v.schema == schema);
  return Map<String, dynamic>.from((minimal ? f.minimal : f.full)! as Map);
}

String _responseSchema(String op) => switch (op) {
  'listVaults' => 'VaultListResource',
  'listCredentials' => 'VaultCredentialListResource',
  'deleteVault' => 'DeletedVaultResource',
  'deleteCredential' => 'DeletedVaultCredentialResource',
  _ => op.contains('Credential') ? 'VaultCredentialResource' : 'VaultResource',
};
Future<AgentJsonModel> _call(
  OpenAIClient c,
  String op, {
  Map<String, String>? headers,
  Future<void>? abort,
  int? limit,
  Map<String, String>? metadata,
  VaultStatusFilter? status,
}) {
  const id = 'vault/%2F?🚀';
  const credential = 'credential/%2F?🚀';
  final v = c.vaults;
  final d = v.credentials;
  final a = headers;
  final b = abort;
  return switch (op) {
    'createVault' => v.create(
      CreateVaultRequest.fromJson({
        ..._wire('CreateVaultParams'),
        'name': 'café 🚀',
      }),
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'listVaults' => v.list(
      limit: limit,
      metadata: metadata,
      status: status,
      order: AgentListOrder.asc,
      after: 'anchor/🚀',
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'retrieveVault' => v.retrieve(id, additionalHeaders: a, abortTrigger: b),
    'updateVault' => v.update(
      id,
      UpdateVaultRequest.fromJson(_wire('UpdateVaultParams')),
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'deleteVault' => v.delete(id, additionalHeaders: a, abortTrigger: b),
    'createCredential' => d.create(
      id,
      CreateVaultCredentialRequest.fromJson(
        _wire('CreateVaultCredentialParams'),
      ),
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'listCredentials' => d.list(
      id,
      limit: limit,
      metadata: metadata,
      status: status,
      order: AgentListOrder.asc,
      after: 'anchor/🚀',
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'retrieveCredential' => d.retrieve(
      id,
      credential,
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'rotateCredential' => d.rotate(
      id,
      credential,
      RotateVaultCredentialRequest.fromJson(
        _wire('RotateVaultCredentialParams'),
      ),
      additionalHeaders: a,
      abortTrigger: b,
    ),
    'deleteCredential' => d.delete(
      id,
      credential,
      additionalHeaders: a,
      abortTrigger: b,
    ),
    _ => throw StateError('Unknown mock operation'),
  };
}

void main() {
  final previousLogging = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previousLogging);
  for (final op in _ops) {
    test(
      '$op exact public path/body/beta/auth/query and caller ownership',
      () async {
        final captured = <http.Request>[];
        final wire = _wire(_responseSchema(op));
        final transport = _Spy(
          MockClient((r) async {
            captured.add(r);
            return http.Response.bytes(
              utf8.encode(jsonEncode(wire)),
              op.startsWith('create') ? 201 : 200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        );
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/custom/v1?base=x&base=y',
            authProvider: _Auth(),
            project: 'project',
            organization: 'org',
            defaultHeaders: const {'OpenAI-Beta': 'wrong', 'Accept': 'wrong'},
          ),
          httpClient: transport,
        );
        addTearDown(transport.inner.close);
        final headers = {
          'X-Captured': 'at-call',
          'oPeNaI-bEtA': 'wrong',
          'ACCEPT': 'wrong',
          'Content-Type': 'application/json; charset=latin1',
        };
        final metadata = {'user/🚀': 'PRIVATE-query'};
        final pending = _call(
          client,
          op,
          headers: headers,
          limit: 100,
          metadata: metadata,
          status: VaultStatusFilter.multiple(const [
            VaultStatus.active,
            VaultStatus.archived,
          ]),
        );
        headers.clear();
        metadata.clear();
        final result = await pending;
        expect(result.toJson(), wire);
        final r = captured.single;
        final isList = op.startsWith('list');
        final isBody = [
          'createVault',
          'updateVault',
          'createCredential',
          'rotateCredential',
        ].contains(op);
        expect(
          r.method,
          isList || op.startsWith('retrieve')
              ? 'GET'
              : op.startsWith('delete')
              ? 'DELETE'
              : 'POST',
        );
        expect(r.headers['openai-beta'], 'agents=v1');
        expect(r.headers['accept'], 'application/json');
        expect(r.headers['authorization'], 'Bearer synthetic');
        expect(r.headers['openai-project'], 'project');
        expect(r.headers['openai-organization'], 'org');
        expect(r.headers['x-captured'], 'at-call');
        expect(r.url.pathSegments, [
          'custom',
          'v1',
          'vaults',
          if (!['createVault', 'listVaults'].contains(op)) 'vault/%2F?🚀',
          if (op.contains('Credential')) 'credentials',
          if ([
            'retrieveCredential',
            'rotateCredential',
            'deleteCredential',
          ].contains(op))
            'credential/%2F?🚀',
        ]);
        expect(r.url.queryParametersAll['base'], ['x', 'y']);
        if (isList) {
          expect(r.url.queryParameters['metadata[user/🚀]'], 'PRIVATE-query');
          expect(r.url.queryParametersAll['status[]'], ['active', 'archived']);
          expect(r.url.queryParameters.containsKey('status'), isFalse);
          expect(r.url.queryParameters['limit'], '100');
          expect(r.url.queryParameters['order'], 'asc');
          expect(r.url.queryParameters['after'], 'anchor/🚀');
        }
        if (isBody) {
          final schema = switch (op) {
            'createVault' => 'CreateVaultParams',
            'updateVault' => 'UpdateVaultParams',
            'createCredential' => 'CreateVaultCredentialParams',
            _ => 'RotateVaultCredentialParams',
          };
          final expected = _wire(schema);
          if (op == 'createVault') expected['name'] = 'café 🚀';
          expect(jsonDecode(utf8.decode(r.bodyBytes)), expected);
          expect(r.headers['content-type'], 'application/json; charset=utf-8');
        } else {
          expect(r.bodyBytes, isEmpty);
          expect(r.headers.containsKey('content-type'), isFalse);
        }
        client.close();
        expect(transport.closed, 0);
        expect(() => client.vaults, throwsStateError);
      },
    );

    test(
      '$op error/JSON/headers/URL/correlation/body diagnostics are private',
      () async {
        final records = <LogRecord>[];
        final logger = Logger.root..level = Level.ALL;
        final sub = logger.onRecord.listen(records.add);
        addTearDown(sub.cancel);
        final transport = MockClient(
          (r) async => http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'error': {
                  'message': 'PRIVATE-service failure',
                  'type': 'PRIVATE-error',
                  'code': 'PRIVATE-code',
                  'param': 'PRIVATE-param',
                },
              }),
            ),
            404,
            request: r,
            headers: {'x-request-id': 'PRIVATE-response-id'},
          ),
        );
        final client = OpenAIClient(
          config: OpenAIConfig(
            authProvider: _Auth(),
            logLevel: Level.ALL,
            project: 'PRIVATE-project',
            organization: 'PRIVATE-org',
          ),
          httpClient: transport,
        );
        final chain = LoggingInterceptor(
          logger: logger,
          logRequestBody: true,
          logResponseBody: true,
        );
        client.interceptorChain.interceptors.insert(0, chain);
        addTearDown(() {
          client.close();
          transport.close();
        });
        try {
          await _call(
            client,
            op,
            headers: {
              'x-request-id': 'PRIVATE-correlation',
              'X-Secret': 'PRIVATE-header',
            },
            metadata: {'PRIVATE-label': 'PRIVATE-query'},
          );
          fail('Expected error');
        } on ApiException catch (error) {
          expect(error.statusCode, 404);
          expect(error.message, contains('PRIVATE-service'));
          expect(error.toString(), isNot(contains('PRIVATE')));
        }
        expect(records, isNotEmpty);
        expect(
          records
              .map((v) => '${v.message} ${v.error} ${v.stackTrace}')
              .join('\n'),
          isNot(contains('PRIVATE')),
        );
      },
    );

    test('$op already completed abort never dispatches', () async {
      var calls = 0;
      final transport = MockClient((r) async {
        calls++;
        return http.Response('{}', 200);
      });
      final client = OpenAIClient.withApiKey(
        'synthetic',
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      await expectLater(
        _call(client, op, abort: Future<void>.value()),
        throwsA(isA<AbortedException>()),
      );
      expect(calls, 0);
    });
  }

  test(
    'list scalar/array/empty status shapes, base conflicts and empty pages',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((r) async {
        requests.add(r);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode(
              _wire(
                r.url.path.endsWith('credentials')
                    ? 'VaultCredentialListResource'
                    : 'VaultListResource',
                minimal: true,
              ),
            ),
          ),
          200,
        );
      });
      final c = OpenAIClient(
        config: OpenAIConfig(
          authProvider: _Auth(),
          baseUrl:
              'https://fixture.invalid/v1?status=archived&status[]=archived',
        ),
        httpClient: transport,
      );
      addTearDown(() {
        c.close();
        transport.close();
      });
      final empty = await c.vaults.list(
        status: VaultStatusFilter.single(VaultStatus.active),
      );
      expect(empty.data, isEmpty);
      expect(empty.firstId, isNull);
      expect(empty.lastId, isNull);
      expect(requests.last.url.queryParameters['status'], 'active');
      expect(
        requests.last.url.queryParameters.containsKey('status[]'),
        isFalse,
      );
      await c.vaults.credentials.list(
        'known',
        status: VaultStatusFilter.multiple(const [
          VaultStatus.active,
          VaultStatus.active,
        ]),
      );
      expect(requests.last.url.queryParametersAll['status[]'], [
        'active',
        'active',
      ]);
      expect(requests.last.url.queryParameters.containsKey('status'), isFalse);
      await c.vaults.list(status: VaultStatusFilter.multiple(const []));
      expect(requests.last.url.queryParameters.containsKey('status'), isFalse);
      expect(
        requests.last.url.queryParameters.containsKey('status[]'),
        isFalse,
      );
      for (final limit in [0, 101]) {
        expect(() => c.vaults.list(limit: limit), throwsFormatException);
      }
      for (final id in ['', '.', '..']) {
        expect(() => c.vaults.retrieve(id), throwsFormatException);
        expect(
          () => c.vaults.credentials.retrieve('known', id),
          throwsFormatException,
        );
      }
      expect(
        () => c.vaults.list(metadata: {'': 'PRIVATE'}),
        throwsFormatException,
      );
      expect(
        () => c.vaults.credentials.list(
          'known',
          metadata: {for (var i = 0; i < 17; i++) 'k$i': 'v'},
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'all three create and rotate auth methods are transported but read back safely',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((r) async {
        requests.add(r);
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        final type = (body['auth'] as Map<String, dynamic>)['type'];
        final suffix = switch (type) {
          'mcp_oauth' => 'McpOauth',
          'static_bearer' => 'StaticBearer',
          _ => 'EnvironmentVariable',
        };
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              ..._wire('VaultCredentialResource'),
              'auth': _wire('VaultCredentialAuthResource$suffix'),
            }),
          ),
          requests.length.isOdd ? 201 : 200,
        );
      });
      final c = OpenAIClient.withApiKey('synthetic', httpClient: transport);
      addTearDown(() {
        c.close();
        transport.close();
      });
      for (final suffix in [
        'McpOauth',
        'StaticBearer',
        'EnvironmentVariable',
      ]) {
        final create = CreateVaultCredentialRequest(
          name: 'credential',
          auth: CreateVaultCredentialAuth.fromJson(
            _wire('CreateVaultCredentialAuthParam$suffix'),
          ),
        );
        final stored = await c.vaults.credentials.create('vault', create);
        final rotated = await c.vaults.credentials.rotate(
          'vault',
          'credential',
          RotateVaultCredentialRequest(
            auth: RotateVaultCredentialAuth.fromJson(
              _wire('RotateVaultCredentialAuthParam$suffix'),
            ),
          ),
        );
        expect(jsonDecode(requests[requests.length - 2].body), create.toJson());
        for (final returned in [stored, rotated]) {
          expect(
            returned.auth.toJson().keys,
            isNot(
              anyElement(
                isIn([
                  'token',
                  'access_token',
                  'refresh_token',
                  'client_secret',
                  'secret_value',
                ]),
              ),
            ),
          );
          expect(returned.toString(), isNot(contains('PRIVATE')));
        }
        expect(requests.last.headers['openai-beta'], 'agents=v1');
      }
      expect(requests, hasLength(6));
    },
  );

  test(
    'malformed JSON and secret readback failures retain private errors',
    () async {
      for (final body in [
        'PRIVATE-invalid-json',
        jsonEncode({
          ..._wire('VaultCredentialResource'),
          'auth': {
            'type': 'static_bearer',
            'mcp_server_url': 'https://example.com',
            'token': 'PRIVATE-bad-readback',
          },
        }),
      ]) {
        final transport = MockClient(
          (r) async => http.Response.bytes(utf8.encode(body), 200),
        );
        final c = OpenAIClient.withApiKey('synthetic', httpClient: transport);
        try {
          await c.vaults.credentials.retrieve('known', 'known');
          fail('Expected parse failure');
        } on ParseException catch (error) {
          expect(error.toString(), isNot(contains('PRIVATE')));
        } finally {
          c.close();
          transport.close();
        }
      }
    },
  );
}

class _Auth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic',
    'OpenAI-Beta': 'wrong',
    'Accept': 'wrong',
    'Content-Type': 'application/json; charset=latin1',
  };
}

class _Spy extends http.BaseClient {
  _Spy(this.inner);
  final http.Client inner;
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) => inner.send(r);
  @override
  void close() {
    closed++;
    inner.close();
  }
}
