import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

void main() {
  test('session spending and cache options serialize and round-trip', () async {
    final requests = <http.Request>[];
    final client = _client((request) async {
      requests.add(request);
      return _json({
        ..._session(),
        'spend_control': {'limit': null, 'consumed': null},
        'prompt_cache_options': {'ttl': '12h'},
      }, requests.length == 1 ? 201 : 200);
    });
    final sessions = client.agents.sessions;
    final request = _create().copyWith(
      spendControl: AgentSessionSpendControlConfig(limit: 420),
      promptCacheOptions: const AgentSessionPromptCacheConfig(
        ttl: AgentSessionPromptCacheTtl.hours12,
      ),
    );
    final created = await sessions.create(request);
    expect(created.spendControl!.consumed, isNull);
    expect(created.spendControl!.limit, isNull);
    expect(created.promptCacheOptions!.ttl, AgentSessionPromptCacheTtl.hours12);
    expect(created.copyWith(), created);
    expect(AgentSession.fromJson(created.toJson()).hashCode, created.hashCode);
    expect(
      created
          .copyWith(promptCacheOptions: null)
          .toJson()['prompt_cache_options'],
      isNull,
    );
    expect(
      created
          .copyWith(promptCacheOptions: null, hasPromptCacheOptions: false)
          .toJson(),
      isNot(contains('prompt_cache_options')),
    );
    expect(AgentSession.fromJson(_session()).spendControl, isNull);
    expect(
      AgentSession.fromJson(_session()).toJson(),
      isNot(contains('spend_control')),
    );

    await sessions.update(
      created.id,
      UpdateAgentSessionRequest(
        clearPromptCacheOptions: true,
        spendControl: AgentSessionSpendControlConfig(limit: null),
      ),
    );
    await sessions.update(
      created.id,
      UpdateAgentSessionRequest(clearSpendControl: true),
    );
    expect(requests.map((request) => jsonDecode(request.body)), [
      {
        ..._create().toJson(),
        'spend_control': {'limit': 420},
        'prompt_cache_options': {'ttl': '12h'},
      },
      {
        'prompt_cache_options': null,
        'spend_control': {'limit': null},
      },
      {'spend_control': null},
    ]);
  });

  test(
    'stream options use the creation body and only the GET events query',
    () async {
      final client = _client((request) async {
        if (request.url.path == '/v1/agents/sessions') {
          expect(request.url.queryParameters, isEmpty);
          expect(jsonDecode(request.body), {
            ..._create().toJson(),
            'stream': true,
            'stream_options': {'include_obfuscation': false},
          });
          return _sse([_event(_error())], 201);
        }
        if (request.method == 'GET') {
          expect(request.url.queryParameters, {'include_obfuscation': 'false'});
          expect(request.body, isEmpty);
          return _sse([
            _event(_error(), name: 'error', removeType: true),
            _event(_budget()),
          ]);
        }
        expect(request.url.queryParameters, isEmpty);
        expect(jsonDecode(request.body), {'events': <Object>[]});
        return http.Response('', 202);
      });
      final sessions = client.agents.sessions;
      final request = _create().copyWith(
        streamOptions: const AgentSessionStreamOptions(
          includeObfuscation: false,
        ),
      );
      expect(request.stream, isTrue);
      expect(CreateAgentSessionRequest.fromJson(request.toJson()), request);
      expect(() => sessions.create(request), throwsFormatException);
      expect(() => request.copyWith(stream: false), throwsFormatException);
      final createdEvents = await sessions.createStream(request).toList();
      expect(createdEvents.single, isA<AgentSessionErrorEvent>());

      final watched = await sessions.events
          .stream('session', includeObfuscation: false)
          .toList();
      final error = watched.first as AgentSessionErrorEvent;
      expect(error.obfuscation, '1234');
      final budget = watched.last as AgentSessionBudgetReachedEvent;
      expect(budget.session.status, AgentSessionStatusResource.budgetReached);
      expect(budget.session.status.isKnown, isTrue);
      expect(budget.obfuscation, '6789');
      expect(budget.toJson(), _budget());
      expect(
        AgentSessionEvent.fromJson(budget.toJson()).hashCode,
        budget.hashCode,
      );
      expect(
        () => budget.copyWith(rawJson: const {'obfuscation': null}),
        throwsFormatException,
      );
      await sessions.events.create(
        'session',
        CreateAgentSessionEventsRequest(events: const []),
      );
    },
  );

  test(
    'typed helper delivers an error before premature EOF, which stays a failure',
    () async {
      final client = _client((_) async => _sse([_event(_error())], 201));
      final run = client.agents.sessions.createRun(_create());
      addTearDown(run.close);

      expect(await run.nextEvent(), isA<AgentSessionErrorEvent>());
      await expectLater(run.nextEvent(), throwsA(isA<StreamException>()));
    },
  );

  test(
    'budget boundary reaches progress and cannot produce a successful run result',
    () async {
      final client = _client(
        (_) async => _sse([
          _event({
            'type': 'agent.session.created',
            'event_id': 'fixture-created',
            'session': _session(),
          }),
          _event(_error()),
          _event(_budget()),
        ], 201),
      );
      final sessions = client.agents.sessions;
      final progress = await sessions.createRun(_create()).events.toList();
      expect(progress[1], isA<AgentSessionErrorEvent>());
      expect(progress.last, isA<AgentSessionBudgetReachedEvent>());
      await expectLater(
        sessions.createRun(_create()).finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>().having(
            (error) => error.reason,
            'reason',
            AgentSessionRunResultReason.budgetReached,
          ),
        ),
      );
    },
  );

  test('a spending pause alone cannot establish a creation identity', () async {
    final client = _client((_) async => _sse([_event(_budget())], 201));
    final run = client.agents.sessions.createRun(_create());
    addTearDown(run.close);

    expect(await run.nextEvent(), isA<AgentSessionBudgetReachedEvent>());
    expect(run.observedSessionId, isNull);
    expect(await run.nextEvent(), isNull);
  });

  test('HTTP and malformed SSE errors stay exceptions', () async {
    var calls = 0;
    final client = _client(
      (_) async => ++calls == 1
          ? _json({
              'error': {'message': 'Rejected fixture'},
            }, 400)
          : _sse(['event: error\ndata: {invalid\n\n']),
    );

    final events = client.agents.sessions.events;
    await expectLater(
      events.stream('session').toList(),
      throwsA(isA<BadRequestException>()),
    );
    await expectLater(
      events.stream('session').toList(),
      throwsA(isA<ParseException>()),
    );
  });

  test(
    'turn history reads the applied cache lifetime and new error codes',
    () async {
      for (final code in [
        AgentSessionTurnErrorCodeResource.apiKeySpendLimitExceeded,
        AgentSessionTurnErrorCodeResource.sessionBudgetExceeded,
        AgentSessionTurnErrorCodeResource.maxOutputTokens,
      ]) {
        final client = _client((request) async {
          expect(request.url.path, '/v1/agents/sessions/session/turns/turn');
          return _json({
            ..._wire('TurnResource'),
            'session_id': 'session',
            'id': 'turn',
            'status': 'failed',
            'error': {'code': code.toJson(), 'message': 'Fixture failure'},
            'prompt_cache_options': {'ttl': '30m'},
          });
        });
        final turn = await client.agents.sessions.turns.retrieve(
          'session',
          'turn',
        );
        expect(
          turn.promptCacheOptions!.ttl,
          AgentSessionPromptCacheTtl.minutes30,
        );
        expect(turn.error!.code, code);
        expect(turn.error!.code.isKnown, isTrue);
        expect(AgentSessionTurn.fromJson(turn.toJson()), turn);
      }
    },
  );

  test(
    'automation retrieval reads reason and preserves null or omission',
    () async {
      final client = _client((request) async {
        final kind = request.url.pathSegments.last;
        return _json({
          'type': kind,
          'id': kind,
          'object': 'agent.automation',
          'created_at': 100,
          'name': 'Fixture',
          'target': {
            'type': 'existing_session',
            'session_id': 'session',
            'instructions': 'Fixture task',
          },
          'metadata': <String, String>{},
          'created_by': {'type': 'developer'},
          if (kind == 'once')
            'run_at': 200
          else ...{
            'expression': '0 1 * * *',
            'timezone': 'UTC',
          },
          'status': 'paused',
          'pause_reason': 'target_session_failed',
        });
      });
      for (final kind in ['once', 'periodic']) {
        final schedule = await client.agents.automations.retrieve(kind);
        expect(
          schedule.pauseReason,
          AgentAutomationPauseReason.targetSessionFailed,
        );
        expect(schedule.hasPauseReason, isTrue);
        final nil = AgentAutomation.fromJson(
          schedule.toJson()..['pause_reason'] = null,
        );
        expect(nil.pauseReason, isNull);
        expect(nil.hasPauseReason, isTrue);
        expect(nil.toJson(), containsPair('pause_reason', null));
        final omitted = AgentAutomation.fromJson(
          schedule.toJson()..remove('pause_reason'),
        );
        expect(omitted.hasPauseReason, isFalse);
        expect(omitted.toJson(), isNot(contains('pause_reason')));
      }
    },
  );
}

CreateAgentSessionRequest _create() => CreateAgentSessionRequest(
  agent: AgentSessionAgentConfig(model: 'fixture-model'),
  environment: AgentSessionEnvironment.none(),
  input: AgentSessionInitialInput.text('fixture'),
);

Map<String, dynamic> _wire(String schema) {
  final fixture = agentSessionWireFixtures.singleWhere(
    (fixture) => fixture.schema == schema,
  );
  return Map.of(fixture.minimal! as Map<String, dynamic>);
}

Map<String, dynamic> _session() => _wire('SessionResource')..['id'] = 'session';

Map<String, dynamic> _error() => {
  ..._wire('SessionEventError'),
  'event_id': 'fixture-error',
  'session_id': 'session',
  'obfuscation': '1234',
};

Map<String, dynamic> _budget() => {
  'type': 'agent.session.budget_reached',
  'event_id': 'fixture-budget',
  'session': {
    ..._session(),
    'status': 'budget_reached',
    'spend_control': {'limit': 420, 'consumed': 420},
  },
  'obfuscation': '6789',
};

String _event(
  Map<String, dynamic> json, {
  String? name,
  bool removeType = false,
}) {
  final data = Map.of(json);
  if (removeType) data.remove('type');
  return "${name == null ? '' : 'event: $name\n'}data: ${jsonEncode(data)}\n\n";
}

http.Response _sse(List<String> events, [int status = 200]) => http.Response(
  events.join(),
  status,
  headers: const {'content-type': 'text/event-stream'},
);

http.Response _json(Map<String, dynamic> json, [int status = 200]) =>
    http.Response(
      jsonEncode(json),
      status,
      headers: const {'content-type': 'application/json'},
    );

OpenAIClient _client(Future<http.Response> Function(http.Request) handle) {
  final transport = MockClient(handle);
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://fixture.invalid/v1',
      authProvider: ApiKeyProvider('fixture'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}
