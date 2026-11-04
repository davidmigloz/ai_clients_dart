import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/utils/speech_redaction.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE café🚀';
const _automationId = 'PRIVATE/id%2F?café🚀';
const _invocationId = 'PRIVATE/invocation%2F?雪';
const _operations = [
  'create',
  'retrieve',
  'update',
  'list',
  'delete',
  'pause',
  'resume',
  'invoke',
  'invocations.list',
  'invocations.retrieve',
];

void main() {
  final previousHierarchy = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previousHierarchy);

  test('automation and invocation getters cache without auth or dispatch', () {
    final auth = _Auth();
    final transport = _Transport(
      (request) async => throw StateError('no send'),
    );
    final client = OpenAIClient(
      config: OpenAIConfig(authProvider: auth),
      httpClient: transport,
    );
    addTearDown(client.close);
    expect(client.agents.automations, same(client.agents.automations));
    expect(
      client.agents.automations.invocations,
      same(client.agents.automations.invocations),
    );
    expect(auth.calls, 0);
    expect(transport.requests, isEmpty);
    final resource = client.agents.automations;
    client.close();
    expect(() => resource.invocations, throwsStateError);
    expect(transport.closed, 0);
  });

  for (final operation in _operations) {
    test(
      '$operation exact exported HTTP contract and option snapshots',
      () async {
        final transport = _Transport((request) async => _success(operation));
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/proxy/v1?token=PRIVATE&k=a&k=b',
            authProvider: _Auth(conflicting: true),
            organization: 'org_fixture',
            project: 'project_fixture',
            retryPolicy: const RetryPolicy(maxRetries: 0),
            defaultHeaders: const {
              'OpenAI-Beta': 'default-invalid',
              'Content-Type': 'text/plain; charset=iso-8859-1',
            },
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        final headers = {
          'X-Captured': 'at-call',
          'oPeNaI-bEtA': 'caller-invalid',
          'ACCEPT': 'caller-invalid',
          'CONTENT-TYPE': 'application/json; charset=iso-8859-1',
        };
        final pending = _call(client, operation, headers: headers);
        headers.clear();
        final result = await pending;
        expect(transport.requests, hasLength(1));
        final request = transport.requests.single;
        expect(request.method, _method(operation));
        expect(request.url.pathSegments, [
          'proxy',
          'v1',
          'agents',
          'automations',
          if (!const {'create', 'list'}.contains(operation)) _automationId,
          if (const {'pause', 'resume'}.contains(operation)) operation,
          if (operation.startsWith('invocations.') || operation == 'invoke')
            'invocations',
          if (operation == 'invocations.retrieve') _invocationId,
        ]);
        expect(request.url.queryParametersAll, {
          'token': ['PRIVATE'],
          'k': ['a', 'b'],
          if (operation.endsWith('list')) 'limit': ['17'],
          if (operation.endsWith('list')) 'order': ['asc'],
          if (operation.endsWith('list')) 'after': [_private],
          if (operation == 'list') 'session_id': [_private],
        });
        expect(request.headers['openai-beta'], 'agents=v1');
        expect(request.headers['accept'], 'application/json');
        expect(
          request.headers['authorization'],
          'Bearer synthetic_automations',
        );
        expect(request.headers['openai-organization'], 'org_fixture');
        expect(request.headers['openai-project'], 'project_fixture');
        expect(request.headers['x-captured'], 'at-call');
        if (operation == 'create' || operation == 'update') {
          expect(request.headers['content-type'], contains('utf-8'));
          expect(
            jsonDecode(utf8.decode(transport.bodies.single)),
            operation == 'create' ? _createWire() : _updateWire(),
          );
        } else {
          expect(transport.bodies.single, isEmpty);
          expect(request.headers.containsKey('content-type'), isFalse);
        }
        expect(result, switch (operation) {
          'list' => isA<AgentAutomationList>(),
          'delete' => isA<DeletedAgentAutomation>(),
          'invoke' ||
          'invocations.retrieve' => isA<AgentAutomationInvocation>(),
          'invocations.list' => isA<AgentAutomationInvocationList>(),
          _ => isA<AgentAutomation>(),
        });
        expect(transport.closed, 0);
      },
    );

    test(
      '$operation closed/pre-aborted requests avoid auth and send',
      () async {
        final auth = _Auth();
        final transport = _Transport((request) async => _success(operation));
        final client = OpenAIClient(
          config: OpenAIConfig(authProvider: auth),
          httpClient: transport,
        );
        await expectLater(
          _call(client, operation, abort: Future<void>.value()),
          throwsA(isA<AbortedException>()),
        );
        expect(auth.calls, 0);
        expect(transport.requests, isEmpty);
        client.close();
        expect(() => _call(client, operation), throwsStateError);
        expect(transport.closed, 0);
      },
    );

    test(
      '$operation HTTP errors and logger keep private fields out of diagnostics',
      () async {
        final records = <String>[];
        final tap = Logger.root.onRecord.listen((record) {
          records.add('${record.message} ${record.error ?? ''}');
        });
        addTearDown(tap.cancel);
        final transport = _Transport((request) async => _error(403));
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/proxy/v1?token=PRIVATE',
            authProvider: _Auth(),
            retryPolicy: const RetryPolicy(maxRetries: 0),
            logLevel: Level.FINEST,
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        try {
          await _call(client, operation);
          fail('Expected rejection.');
        } on PermissionDeniedException catch (error) {
          expect(error.statusCode, 403);
          expect(error.message, _private);
          expect(error.requestId, 'PRIVATE-request');
          expect(error.body, isNotNull);
          expect(error.toString(), isNot(contains('PRIVATE')));
        }
        expect(records, isNotEmpty);
        expect(records.join(), isNot(contains('PRIVATE')));
        expect(transport.requests, hasLength(1));
      },
    );
  }

  test('exact ten routes are classified without adding other operations', () {
    for (final operation in _operations) {
      final path = switch (operation) {
        'create' || 'list' => '/agents/automations',
        'pause' || 'resume' => '/agents/automations/a/$operation',
        'invoke' || 'invocations.list' => '/agents/automations/a/invocations',
        'invocations.retrieve' => '/agents/automations/a/invocations/i',
        _ => '/agents/automations/a',
      };
      final request = http.Request(
        _method(operation),
        Uri.parse('https://fixture.invalid/proxy/v1$path'),
      );
      expect(isAgentAutomationRequest(request), isTrue);
      expect(isAgentsApiRequest(request), isTrue);
      expect(isPrivateAudioRequest(request), isTrue);
    }
    for (final (method, path) in [
      ('PATCH', '/agents/automations/a'),
      ('GET', '/agents/automations/a/pause'),
      ('DELETE', '/agents/automations/a/invocations'),
      ('POST', '/agents/automations/a/invocations/i'),
      ('GET', '/agents/automations/a/unknown'),
      ('GET', '/agents/sessions/a'),
    ]) {
      expect(
        isAgentAutomationRequest(
          http.Request(
            method,
            Uri.parse('https://fixture.invalid/proxy/v1$path'),
          ),
        ),
        isFalse,
      );
    }
  });

  test(
    'both create schedule/target branches submit exact JSON without invoking',
    () async {
      final transport = _Transport((request) async {
        final wire = jsonDecode(request.body) as Map<String, dynamic>;
        return _json(
          _automation(
            type: wire['type'] as String,
            newSession: (wire['target'] as Map)['type'] == 'new_session',
          ),
          201,
        );
      });
      final client = OpenAIClient(httpClient: transport);
      addTearDown(client.close);
      for (final periodic in [false, true]) {
        for (final newSession in [false, true]) {
          final wire = _createWire(periodic: periodic, newSession: newSession);
          final result = await client.agents.automations.create(
            CreateAgentAutomationRequest.fromJson(wire),
          );
          expect(jsonDecode(utf8.decode(transport.bodies.last)), wire);
          expect(result.toJson()['type'], periodic ? 'periodic' : 'once');
          expect(
            (result.toJson()['target'] as Map)['type'],
            newSession ? 'new_session' : 'existing_session',
          );
        }
      }
      expect(transport.requests, hasLength(4));
      expect(
        transport.requests.every(
          (request) => request.url.path == '/v1/agents/automations',
        ),
        isTrue,
      );
    },
  );

  for (final operation in ['create', 'invoke']) {
    test(
      '$operation retains caller idempotency header through provider refresh',
      () async {
        final auth = _Auth(conflicting: true);
        final transport = _Transport((request) async => _success(operation));
        final client = OpenAIClient(
          config: OpenAIConfig(authProvider: auth),
          httpClient: transport,
        );
        addTearDown(client.close);
        await _call(
          client,
          operation,
          headers: {'iDeMpOtEnCy-KeY': 'caller-existing-value'},
        );
        expect(auth.calls, greaterThanOrEqualTo(2));
        expect(
          transport.requests.single.headers['idempotency-key'],
          'caller-existing-value',
        );
      },
    );
  }

  for (final invocation in [false, true]) {
    test(
      '${invocation ? 'invocation' : 'automation'} pages retain filters and nonadvancing cursors',
      () async {
        final pages = [
          _page(invocations: invocation, hasMore: true, lastId: 'cursor'),
          _page(invocations: invocation, hasMore: true, lastId: 'cursor'),
          _page(invocations: invocation, hasMore: true, empty: true),
        ];
        final transport = _Transport(
          (request) async => _json(pages.removeAt(0)),
        );
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        final first = invocation
            ? (await client.agents.automations.invocations.list(
                _automationId,
                limit: 1,
                order: AgentListOrder.desc,
              )).toJson()
            : (await client.agents.automations.list(
                limit: 1,
                order: AgentListOrder.desc,
                sessionId: '',
              )).toJson();
        final cursor = first['last_id'] as String;
        final second = invocation
            ? (await client.agents.automations.invocations.list(
                _automationId,
                limit: 1,
                order: AgentListOrder.desc,
                after: cursor,
              )).toJson()
            : (await client.agents.automations.list(
                limit: 1,
                order: AgentListOrder.desc,
                sessionId: '',
                after: cursor,
              )).toJson();
        expect(second['last_id'], cursor);
        expect(transport.requests, hasLength(2));
        expect(transport.requests.last.url.queryParameters, {
          'limit': '1',
          'order': 'desc',
          'after': 'cursor',
          if (!invocation) 'session_id': '',
        });
        final empty = invocation
            ? (await client.agents.automations.invocations.list(
                _automationId,
              )).toJson()
            : (await client.agents.automations.list()).toJson();
        expect(empty, {
          'object': 'list',
          'data': <Object>[],
          'has_more': true,
          'first_id': null,
          'last_id': null,
        });
        expect(transport.requests, hasLength(3));
        expect(transport.requests.last.url.query, '');
      },
    );
  }

  test(
    'received creator, target, environment and schedule status branches survive HTTP',
    () async {
      final agentCreated = _automation()
        ..['status'] = 'completed'
        ..['created_by'] = {
          'type': 'agent',
          'session_id': 'session_fixture',
          'tool_call_id': 'call_fixture',
        };
      final wires = <Map<String, dynamic>>[
        agentCreated,
        for (final environment in <Map<String, dynamic>>[
          {'type': 'none'},
          {
            'type': 'self_hosted',
            'environment_id': null,
            'workspace_directory': '/workspace',
            'capability_directories': <String>[],
          },
          {
            'type': 'openai_hosted',
            'environment_id': null,
            'environment_template_id': null,
            'container_size': null,
            'packages': null,
            'network': null,
            'desktop': null,
            'capability_directories': null,
            'skills': null,
            'plugins': null,
            'files': null,
          },
        ])
          {
            ..._automation(type: 'periodic', newSession: true),
            'status': 'paused',
            'target': {
              'type': 'new_session',
              'agent_id': null,
              'agent': {
                'model': 'gpt-6.1-sol',
                'instructions': null,
                'reasoning': {'effort': null, 'summary': null},
                'text': {
                  'format': {'type': 'text'},
                  'verbosity': 'medium',
                },
                'service_tier': 'ultrafast',
                'tools': <Object>[],
                'multi_agent': {
                  'enabled': false,
                  'max_concurrent_subagents': null,
                },
              },
              'environment': environment,
              'input': <Object>[],
              'vault_ids': <String>[],
              'metadata': <String, String>{},
            },
          },
      ];
      var index = 0;
      final transport = _Transport((request) async => _json(wires[index++]));
      final client = OpenAIClient(httpClient: transport);
      addTearDown(client.close);
      for (final wire in wires) {
        final result = await client.agents.automations.retrieve(_automationId);
        expect(result.toJson(), wire);
      }
      expect(transport.requests, hasLength(wires.length));
      expect(
        transport.requests.every((request) => request.method == 'GET'),
        isTrue,
      );
    },
  );

  test(
    'manual and scheduled delivery states preserve source/error/nulls without session work',
    () async {
      final wires = [
        for (final status in ['queued', 'completed', 'failed', 'skipped'])
          _invocation(status: status, scheduled: status != 'queued'),
      ];
      final transport = _Transport((request) async => _json(wires.removeAt(0)));
      final client = OpenAIClient(httpClient: transport);
      addTearDown(client.close);
      for (final status in ['queued', 'completed', 'failed', 'skipped']) {
        final result = await client.agents.automations.invocations.retrieve(
          _automationId,
          _invocationId,
        );
        expect(
          result.toJson(),
          _invocation(status: status, scheduled: status != 'queued'),
        );
      }
      expect(transport.requests, hasLength(4));
      expect(
        transport.requests.every(
          (request) =>
              request.method == 'GET' &&
              request.url.path.contains('/automations/'),
        ),
        isTrue,
      );
    },
  );

  test('invalid path/query values fail privately before auth or dispatch', () {
    final auth = _Auth();
    final transport = _Transport(
      (request) async => throw StateError('no send'),
    );
    final client = OpenAIClient(
      config: OpenAIConfig(authProvider: auth),
      httpClient: transport,
    );
    addTearDown(client.close);
    for (final id in ['', '.', '..', 'a' * 1048577, '\uD800', '\uDC00']) {
      expect(
        () => client.agents.automations.retrieve(id),
        throwsFormatException,
      );
      expect(
        () => client.agents.automations.invocations.retrieve('a', id),
        throwsFormatException,
      );
    }
    for (final call in <void Function()>[
      () => client.agents.automations.list(limit: 0),
      () => client.agents.automations.list(limit: 101),
      () => client.agents.automations.list(
        order: AgentListOrder.fromJson('PRIVATE-invalid'),
      ),
      () => client.agents.automations.list(after: '\uD800'),
      () => client.agents.automations.list(sessionId: '\uDC00'),
      () => client.agents.automations.invocations.list('a', after: '\uDC00'),
      () => client.agents.automations.invocations.list('a', limit: 101),
    ]) {
      expect(
        call,
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
    }
    expect(auth.calls, 0);
    expect(transport.requests, isEmpty);
  });

  for (final status in [400, 401, 403, 404, 409, 500, 501, 503]) {
    test(
      'ordinary HTTP $status classification remains explicit and private',
      () async {
        final transport = _Transport((request) async => _error(status));
        final client = OpenAIClient(
          config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
          httpClient: transport,
        );
        addTearDown(client.close);
        await expectLater(
          client.agents.automations.list(),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'raw status', status)
                .having((error) => error.message, 'explicit message', _private)
                .having(
                  (error) => error.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                ),
          ),
        );
        expect(transport.requests, hasLength(1));
      },
    );
  }

  for (final operation in ['create', 'invoke', 'delete']) {
    test(
      '$operation rejects unexpected successful status without assuming completion',
      () async {
        final status = operation == 'create'
            ? 200
            : operation == 'delete'
            ? 204
            : 201;
        final transport = _Transport(
          (request) async => _json(_automation(), status),
        );
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        await expectLater(
          _call(client, operation),
          throwsA(isA<ParseException>()),
        );
        expect(transport.requests, hasLength(1));
      },
    );
  }

  for (final body in <List<int>>[
    utf8.encode('PRIVATE-not-json'),
    [255],
    utf8.encode(jsonEncode({'type': 'once', 'id': _private})),
  ]) {
    test('malformed response is private (${body.length} bytes)', () async {
      final transport = _Transport(
        (request) async => http.Response.bytes(body, 200),
      );
      final client = OpenAIClient(httpClient: transport);
      addTearDown(client.close);
      await expectLater(
        client.agents.automations.retrieve('a'),
        throwsA(
          isA<ParseException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
    });
  }

  for (final failAt in [1, 2]) {
    test('provider failure $failAt remains private before any send', () async {
      final transport = _Transport((request) async => _json(_automation()));
      final client = OpenAIClient(
        config: OpenAIConfig(authProvider: _Auth(failAt: failAt)),
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.agents.automations.retrieve('a'),
        throwsA(
          isA<ConnectionException>()
              .having(
                (error) => error.toString(),
                'private',
                isNot(contains('PRIVATE')),
              )
              .having(
                (error) => error.cause,
                'explicit cause',
                isA<StateError>(),
              ),
        ),
      );
      expect(transport.requests, isEmpty);
    });
    test('typed provider failure $failAt is guarded at its origin', () async {
      const failure = ApiException(message: _private, statusCode: 400);
      final transport = _Transport((request) async => _json(_automation()));
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: _Auth(failAt: failAt, failure: failure),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.agents.automations.retrieve('a'),
        throwsA(
          isA<ConnectionException>()
              .having(
                (error) => error.toString(),
                'private',
                isNot(contains('PRIVATE')),
              )
              .having(
                (error) => error.cause,
                'explicit original failure',
                same(failure),
              ),
        ),
      );
      expect(transport.requests, isEmpty);
    });
  }

  for (final mode in ['send', 'body']) {
    test(
      'typed external $mode error stays distinct from local HTTP errors',
      () async {
        const failure = ApiException(message: _private, statusCode: 400);
        final transport = _FailureTransport(mode, failure);
        final client = OpenAIClient(
          config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
          httpClient: transport,
        );
        addTearDown(client.close);
        await expectLater(
          client.agents.automations.invocations.create('a'),
          throwsA(
            isA<ConnectionException>()
                .having(
                  (error) => error.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                )
                .having(
                  (error) => error.cause,
                  'explicit original failure',
                  same(failure),
                ),
          ),
        );
        expect(transport.calls, 1);
      },
    );
  }

  test(
    'transport callback failure and in-flight abort create no lifecycle actions',
    () async {
      final failing = _Transport((request) => throw StateError(_private));
      final failureClient = OpenAIClient(
        config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
        httpClient: failing,
      );
      addTearDown(failureClient.close);
      await expectLater(
        failureClient.agents.automations.pause('a'),
        throwsA(
          isA<ConnectionException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
      expect(failing.requests, hasLength(1));

      final transport = _AbortTransport();
      final client = OpenAIClient(
        config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
        httpClient: transport,
      );
      addTearDown(client.close);
      final abort = Completer<void>();
      final pending = client.agents.automations.invocations.create(
        'a',
        abortTrigger: abort.future,
      );
      await transport.sent.future;
      abort.complete();
      await expectLater(pending, throwsA(isA<AbortedException>()));
      expect(transport.requests, hasLength(1));
      expect(transport.requests.single.method, 'POST');
      expect(
        transport.requests.single.url.path,
        '/v1/agents/automations/a/invocations',
      );
      expect(transport.closed, 0);
    },
  );
}

Future<Object?> _call(
  OpenAIClient client,
  String operation, {
  Map<String, String>? headers,
  Future<void>? abort,
}) {
  final resource = client.agents.automations;
  return switch (operation) {
    'create' => resource.create(
      CreateAgentAutomationRequest.fromJson(_createWire()),
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'retrieve' => resource.retrieve(
      _automationId,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'update' => resource.update(
      _automationId,
      UpdateAgentAutomationRequest.fromJson(_updateWire()),
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'list' => resource.list(
      limit: 17,
      order: AgentListOrder.asc,
      after: _private,
      sessionId: _private,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'delete' => resource.delete(
      _automationId,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'pause' => resource.pause(
      _automationId,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'resume' => resource.resume(
      _automationId,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'invoke' => resource.invocations.create(
      _automationId,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'invocations.list' => resource.invocations.list(
      _automationId,
      limit: 17,
      order: AgentListOrder.asc,
      after: _private,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'invocations.retrieve' => resource.invocations.retrieve(
      _automationId,
      _invocationId,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    _ => throw StateError('Unknown fixture operation.'),
  };
}

String _method(String operation) => switch (operation) {
  'create' || 'update' || 'pause' || 'resume' || 'invoke' => 'POST',
  'delete' => 'DELETE',
  _ => 'GET',
};

Map<String, dynamic> _createWire({
  bool periodic = false,
  bool newSession = false,
}) => {
  'type': periodic ? 'periodic' : 'once',
  'name': _private,
  'target': newSession
      ? {
          'type': 'new_session',
          'agent_id': 'agent_fixture',
          'environment': {'type': 'none'},
          'input': <Object>[],
          'vault_ids': null,
          'metadata': null,
        }
      : {
          'type': 'existing_session',
          'session_id': 'session_fixture',
          'instructions': _private,
        },
  'metadata': {'fixture': _private},
  if (periodic) ...{
    'expression': '0 9 * * *',
    'timezone': 'Europe/Madrid',
  } else
    'run_at': 2000000000,
};

Map<String, dynamic> _updateWire() => {
  'name': _private,
  'metadata': <String, String>{},
  'target': {
    'type': 'existing_session',
    'session_id': 'session_fixture',
    'instructions': _private,
  },
  'run_at': 2000000000,
};

Map<String, dynamic> _automation({
  String type = 'once',
  bool newSession = false,
}) => {
  'type': type,
  'id': _automationId,
  'object': 'agent.automation',
  'created_at': 100,
  'name': _private,
  'target': newSession
      ? {
          'type': 'new_session',
          'agent_id': 'agent_fixture',
          'agent': null,
          'environment': {'type': 'none'},
          'input': <Object>[],
          'vault_ids': <String>[],
          'metadata': <String, String>{},
        }
      : {
          'type': 'existing_session',
          'session_id': 'session_fixture',
          'instructions': _private,
        },
  'metadata': {'fixture': _private},
  'created_by': {'type': 'developer'},
  if (type == 'once')
    'run_at': 2000000000
  else ...{
    'expression': '0 9 * * *',
    'timezone': 'Europe/Madrid',
  },
  'status': 'active',
};

Map<String, dynamic> _invocation({
  String status = 'queued',
  bool scheduled = false,
}) => {
  'id': _invocationId,
  'object': 'agent.automation.invocation',
  'automation_id': _automationId,
  'created_at': 100,
  'source': scheduled
      ? {'type': 'automation', 'automation': _automation()}
      : {'type': 'manual'},
  'scheduled_at': scheduled ? 2000000000 : null,
  'session_id': status == 'queued' ? null : 'session_fixture',
  'status': status,
  'skip_reason': status == 'skipped' ? 'pending_delivery' : null,
  'error': status == 'failed' ? {'code': _private, 'message': _private} : null,
};

Map<String, dynamic> _page({
  bool invocations = false,
  bool hasMore = false,
  String? lastId,
  bool empty = false,
}) => {
  'object': 'list',
  'data': empty
      ? <Object>[]
      : [if (invocations) _invocation() else _automation()],
  'first_id': empty
      ? null
      : invocations
      ? _invocationId
      : _automationId,
  'last_id': empty
      ? null
      : lastId ?? (invocations ? _invocationId : _automationId),
  'has_more': hasMore,
};

http.Response _success(String operation) => _json(switch (operation) {
  'list' => _page(),
  'invocations.list' => _page(invocations: true),
  'delete' => {
    'id': _automationId,
    'object': 'agent.automation.deleted',
    'deleted': true,
  },
  'invoke' || 'invocations.retrieve' => _invocation(),
  _ => _automation(),
}, operation == 'create' ? 201 : 200);

http.Response _json(Object? body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _error(int status) => http.Response.bytes(
  utf8.encode(
    jsonEncode({
      'error': {
        'message': _private,
        'type': _private,
        'code': _private,
        'param': _private,
      },
    }),
  ),
  status,
  headers: {
    'content-type': 'application/json; charset=utf-8',
    'x-request-id': 'PRIVATE-request',
  },
);

class _Auth implements AuthProvider {
  _Auth({this.conflicting = false, this.failAt, this.failure});
  final bool conflicting;
  final int? failAt;
  final Exception? failure;
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    if (calls == failAt) {
      if (failure case final error?) throw error;
      throw StateError(_private);
    }
    return {
      'Authorization': 'Bearer synthetic_automations',
      if (conflicting) ...{
        'oPeNaI-BeTa': 'provider-invalid',
        'ACCEPT': 'provider-invalid',
        'CONTENT-TYPE': 'text/plain; charset=iso-8859-1',
        'Idempotency-Key': 'provider-invalid',
      },
    };
  }
}

class _FailureTransport extends http.BaseClient {
  _FailureTransport(this.mode, this.failure);
  final String mode;
  final Exception failure;
  int calls = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls++;
    await request.finalize().drain<void>();
    if (mode == 'send') throw failure;
    return http.StreamedResponse(
      Stream<List<int>>.error(failure),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _AbortTransport extends http.BaseClient {
  final sent = Completer<void>();
  final requests = <http.BaseRequest>[];
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    await request.finalize().drain<void>();
    sent.complete();
    await (request as http.Abortable).abortTrigger;
    throw http.RequestAbortedException(request.url);
  }

  @override
  void close() {
    closed++;
  }
}

class _Transport extends http.BaseClient {
  _Transport(this.handle);
  final Future<http.Response> Function(http.Request) handle;
  final requests = <http.Request>[];
  final bodies = <List<int>>[];
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = await request.finalize().toBytes();
    final captured = http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..bodyBytes = bytes;
    requests.add(captured);
    bodies.add(bytes);
    final response = await handle(captured);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }

  @override
  void close() {
    closed++;
  }
}
