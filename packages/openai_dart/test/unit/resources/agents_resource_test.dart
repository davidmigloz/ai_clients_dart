import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_resource_fixtures.dart';

const _opaqueId = 'PRIVATE/id%2F?café🚀';
const _private = 'PRIVATE-value';

void main() {
  final previousHierarchy = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previousHierarchy);
  test('Agents getter caches without authentication or transport', () {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    expect(fixture.client.agents, same(fixture.client.agents));
    expect(fixture.auth.calls, 0);
    expect(fixture.transport.requests, isEmpty);
    expect(fixture.factoryCalls, 0);
  });

  for (final operation in ['create', 'list', 'retrieve', 'update', 'delete']) {
    test(
      '$operation exact public method/path/header/auth/body/result',
      () async {
        final fixture = _Fixture(response: _success(operation));
        addTearDown(fixture.close);
        final requestHeaders = {
          'oPeNaI-bEtA': 'caller-invalid',
          'X-Caller': _private,
        };
        final result = await _invoke(
          fixture.client,
          operation,
          headers: requestHeaders,
        );
        final request = fixture.transport.requests.single;
        final body = fixture.transport.bodies.single;
        expect(
          request.method,
          {
            'create': 'POST',
            'list': 'GET',
            'retrieve': 'GET',
            'update': 'POST',
            'delete': 'DELETE',
          }[operation],
        );
        expect(request.url.pathSegments, [
          'proxy',
          'v1',
          'agents',
          if (!['create', 'list'].contains(operation)) _opaqueId,
        ]);
        expect(request.url.queryParametersAll, {
          'token': [_private],
          'k': ['a', 'b'],
          if (operation == 'list') 'limit': ['17'],
          if (operation == 'list') 'order': ['asc'],
          if (operation == 'list') 'after': [_opaqueId],
        });
        expect(request.headers['openai-beta'], 'agents=v1');
        expect(request.headers['authorization'], 'Bearer synthetic-agent-test');
        expect(request.headers['openai-project'], 'project-test');
        expect(request.headers['openai-organization'], 'organization-test');
        expect(request.headers['x-caller'], _private);
        expect(request.headers['accept'], 'application/json');
        expect(requestHeaders['oPeNaI-bEtA'], 'caller-invalid');
        if (operation == 'create') {
          expect(jsonDecode(utf8.decode(body)), {
            'model': 'requested-model',
            'name': 'name',
            'service_tier': 'fast',
            'tools': [
              {'type': 'tool_search'},
            ],
          });
          expect(
            result,
            isA<Agent>().having(
              (agent) => agent.model,
              'model',
              'requested-model',
            ),
          );
        } else if (operation == 'update') {
          expect(jsonDecode(utf8.decode(body)), {
            'name': null,
            'reasoning': null,
            'tools': <Object>[],
          });
          expect(result, isA<Agent>());
        } else {
          expect(body, isEmpty);
          expect(request.headers.containsKey('content-type'), false);
          expect(
            result,
            operation == 'list'
                ? isA<AgentList>()
                : operation == 'delete'
                ? isA<DeletedAgent>()
                : isA<Agent>(),
          );
        }
        expect(fixture.factoryCalls, 0);
      },
    );

    test(
      '$operation closed guard and already-aborted request avoid auth',
      () async {
        final fixture = _Fixture(response: _success(operation));
        addTearDown(fixture.close);
        await expectLater(
          _invoke(fixture.client, operation, abort: Future<void>.value()),
          throwsA(isA<AbortedException>()),
        );
        expect(fixture.auth.calls, 0);
        expect(fixture.transport.requests, isEmpty);
        fixture.client.close();
        expect(() => _invoke(fixture.client, operation), throwsStateError);
        expect(fixture.transport.closed, false);
      },
    );

    test(
      '$operation preserves ordinary shared HTTP error classification privately',
      () async {
        final fixture = _Fixture(
          response: _utf8Response(
            jsonEncode({
              'error': {
                'type': _private,
                'code': _private,
                'message': _private,
                'param': _private,
              },
            }),
            403,
            headers: {'x-request-id': _private},
          ),
        );
        addTearDown(fixture.close);
        try {
          await _invoke(fixture.client, operation);
          fail('Expected HTTP rejection');
        } on PermissionDeniedException catch (error) {
          expect(error.message, _private);
          expect(error.body, isNotNull);
          expect(error.cause, isA<http.Response>());
          expect(error.toString(), isNot(contains(_private)));
          expect(error.toString(), isNot(contains(_opaqueId)));
        }
      },
    );

    test('$operation transport diagnostics remain private', () async {
      final fixture = _Fixture(
        failure: http.ClientException(
          _private,
          Uri.parse('https://fixture.invalid/$_private'),
        ),
      );
      addTearDown(fixture.close);
      await expectLater(
        _invoke(fixture.client, operation),
        throwsA(
          isA<ConnectionException>().having(
            (error) => error.toString(),
            'diagnostics',
            isNot(contains(_private)),
          ),
        ),
      );
    });
  }

  test(
    'Opaque IDs retain slashes, percent strings, query punctuation and Unicode',
    () async {
      final fixture = _Fixture();
      addTearDown(fixture.close);
      for (final id in [
        'agent/id',
        '%2F',
        '?x#y',
        'café🚀',
        ' whitespace ',
        'agent.dot',
      ]) {
        await fixture.client.agents.retrieve(id);
        expect(fixture.transport.requests.last.url.pathSegments.last, id);
      }
      final before = fixture.auth.calls;
      for (final id in ['', '.', '..', List.filled(1048577, 'a').join()]) {
        expect(
          () => fixture.client.agents.retrieve(id),
          throwsA(isA<FormatException>()),
        );
      }
      expect(fixture.auth.calls, before);
    },
  );

  test('Invalid list/request bounds fail before authentication or sending', () {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    for (final limit in [0, 101]) {
      expect(
        () => fixture.client.agents.list(limit: limit),
        throwsA(isA<FormatException>()),
      );
    }
    expect(
      () => fixture.client.agents.list(
        order: AgentListOrder.fromJson('PRIVATE-order'),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => fixture.client.agents.list(after: List.filled(1048577, 'a').join()),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => fixture.client.agents.create(
        CreateAgentRequest(model: '', name: List.filled(129, 'a').join()),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => fixture.client.agents.update(
        _opaqueId,
        UpdateAgentRequest.fromJson(const {'model': null}),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(fixture.auth.calls, 0);
    expect(fixture.transport.requests, isEmpty);
  });

  test('Nullable page cursors and second-page context remain exact', () async {
    final fixture = _Fixture(
      response: _utf8Response(
        jsonEncode({
          'object': 'list',
          'data': [savedAgentWire(id: _opaqueId)],
          'first_id': _opaqueId,
          'last_id': _opaqueId,
          'has_more': true,
        }),
        200,
      ),
    );
    addTearDown(fixture.close);
    final first = await fixture.client.agents.list(
      limit: 3,
      order: AgentListOrder.asc,
    );
    expect(first.hasMore, true);
    fixture.transport.response = _utf8Response(
      jsonEncode(emptyAgentPageWire()),
      200,
    );
    final second = await fixture.client.agents.list(
      limit: 3,
      order: AgentListOrder.asc,
      after: first.lastId,
    );
    expect(second.firstId, null);
    expect(second.lastId, null);
    expect(second.toJson(), emptyAgentPageWire());
    expect(
      fixture.transport.requests.last.url.queryParameters['after'],
      _opaqueId,
    );
    expect(fixture.transport.requests.last.url.queryParameters['order'], 'asc');
    expect(fixture.transport.requests.last.url.queryParameters['limit'], '3');
  });

  test(
    'Omitted list fields preserve base parameters and request defaults',
    () async {
      final fixture = _Fixture(
        response: _utf8Response(jsonEncode(emptyAgentPageWire()), 200),
      );
      addTearDown(fixture.close);
      await fixture.client.agents.list();
      expect(fixture.transport.requests.single.url.queryParametersAll, {
        'token': [_private],
        'k': ['a', 'b'],
      });
    },
  );

  test(
    'Borrowed client stays open and no Agents header leaks to other resources',
    () async {
      final fixture = _Fixture();
      addTearDown(fixture.close);
      await fixture.client.agents.retrieve('agent');
      fixture.transport.response = _utf8Response(
        '{"object":"list","data":[]}',
        200,
      );
      await fixture.client.models.list();
      expect(
        fixture.transport.requests.last.headers['openai-beta'],
        'default-invalid',
      );
      fixture.client.close();
      expect(fixture.transport.closed, false);
      await fixture.transport.get(
        Uri.parse('https://fixture.invalid/borrowed'),
      );
      expect(fixture.transport.requests, hasLength(3));
    },
  );

  test('Late native abort is forwarded to the injected transport', () async {
    final abort = Completer<void>();
    final entered = Completer<void>();
    final transport = _AbortTransport(entered);
    final client = OpenAIClient.withApiKey(
      'synthetic-agent-test',
      httpClient: transport,
    );
    addTearDown(() {
      client.close();
      transport.close();
    });
    final pending = client.agents.retrieve('agent', abortTrigger: abort.future);
    await entered.future;
    abort.complete();
    await expectLater(pending, throwsA(isA<AbortedException>()));
  });

  test(
    'Logging never renders private saved configuration or request context',
    () async {
      final records = <String>[];
      final previous = Logger.root.level;
      Logger.root.level = Level.ALL;
      final subscription = Logger.root.onRecord.listen(
        (record) => records.add('${record.message} ${record.error ?? ''}'),
      );
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previous;
      });
      final fixture = _Fixture(
        log: true,
        response: _utf8Response(
          jsonEncode(
            savedAgentWire()
              ..['instructions'] = _private
              ..['metadata'] = {'private-key': _private},
          ),
          201,
        ),
      );
      addTearDown(fixture.close);
      await fixture.client.agents.create(
        CreateAgentRequest(
          model: _private,
          instructions: _private,
          metadata: const {'private-key': _private},
          tools: [
            AgentTool.mcp(
              serverLabel: _private,
              transport: AgentMcpTransport.stdio(
                command: _private,
                cwd: _private,
              ),
            ),
          ],
        ),
      );
      expect(records, isNotEmpty);
      expect(records.join('\n'), isNot(contains(_private)));
      expect(records.join('\n'), isNot(contains('synthetic-agent-test')));
      expect(records.join('\n'), isNot(contains('private-key')));
    },
  );

  test(
    'Malformed response bodies, fields and noncanonical success status fail safely',
    () async {
      final fixture = _Fixture();
      addTearDown(fixture.close);
      for (final body in [
        'PRIVATE-not-json',
        jsonEncode({'private': _private}),
        jsonEncode(savedAgentWire()..remove('name')),
        jsonEncode(
          savedAgentWire()..['reasoning'] = {'effort': 7, 'summary': null},
        ),
      ]) {
        fixture.transport.response = _utf8Response(body, 200);
        await expectLater(
          fixture.client.agents.retrieve('agent'),
          throwsA(
            isA<ParseException>().having(
              (error) => error.toString(),
              'diagnostics',
              isNot(contains(_private)),
            ),
          ),
        );
      }
      fixture.transport.response = _utf8Response(
        jsonEncode(savedAgentWire()),
        200,
      );
      await expectLater(
        fixture.client.agents.create(CreateAgentRequest(model: 'model')),
        throwsA(isA<ParseException>()),
      );
    },
  );
}

Future<Object> _invoke(
  OpenAIClient client,
  String operation, {
  Map<String, String>? headers,
  Future<void>? abort,
}) => switch (operation) {
  'create' => client.agents.create(
    CreateAgentRequest(
      model: 'requested-model',
      name: 'name',
      serviceTier: AgentServiceTierParam.fast,
      tools: const [AgentTool.toolSearch()],
    ),
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'list' => client.agents.list(
    limit: 17,
    order: AgentListOrder.asc,
    after: _opaqueId,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'retrieve' => client.agents.retrieve(
    _opaqueId,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'update' => client.agents.update(
    _opaqueId,
    UpdateAgentRequest(clearName: true, clearReasoning: true, tools: const []),
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  'delete' => client.agents.delete(
    _opaqueId,
    additionalHeaders: headers,
    abortTrigger: abort,
  ),
  _ => throw StateError('Unknown test operation'),
};

http.Response _success(String operation) => _utf8Response(
  jsonEncode(switch (operation) {
    'list' => emptyAgentPageWire(),
    'delete' => {'id': _opaqueId, 'object': 'agent.deleted', 'deleted': true},
    _ => savedAgentWire(id: _opaqueId),
  }),
  operation == 'create' ? 201 : 200,
);

class _Fixture {
  _Fixture({http.Response? response, Exception? failure, bool log = false})
    : transport = _Transport(response ?? _success('retrieve'), failure) {
    client = OpenAIClient(
      config: OpenAIConfig(
        baseUrl: 'https://fixture.invalid/proxy/v1?token=$_private&k=a&k=b',
        authProvider: auth,
        project: 'project-test',
        organization: 'organization-test',
        defaultHeaders: const {'OpenAI-Beta': 'default-invalid'},
        logLevel: log ? Level.ALL : Level.OFF,
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
      streamClientFactory: () {
        factoryCalls++;
        return _Transport(_success('retrieve'), null);
      },
    );
  }
  final _Auth auth = _Auth();
  final _Transport transport;
  late final OpenAIClient client;
  int factoryCalls = 0;
  void close() {
    client.close();
    transport.close();
  }
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'Bearer synthetic-agent-test'};
  }
}

class _Transport extends http.BaseClient {
  _Transport(this.response, this.failure);
  http.Response response;
  final Exception? failure;
  bool closed = false;
  final requests = <http.BaseRequest>[];
  final bodies = <List<int>>[];
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    bodies.add(await request.finalize().toBytes());
    if (failure != null) throw failure!;
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }

  @override
  void close() => closed = true;
}

class _AbortTransport extends http.BaseClient {
  _AbortTransport(this.entered);
  final Completer<void> entered;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    expect(request, isA<http.Abortable>());
    entered.complete();
    await (request as http.Abortable).abortTrigger;
    throw http.RequestAbortedException(request.url);
  }
}

http.Response _utf8Response(
  String body,
  int status, {
  Map<String, String> headers = const {},
}) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8', ...headers},
);
