import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_resource_fixtures.dart';

void main() {
  group('session metadata filters', () {
    test(
      'deep-object pairs retain cursor, order, agent and base query',
      () async {
        final requests = <http.Request>[];
        final metadata = {'tenant': 'café🚀 &+/%', 'a[b]% key': ''};
        final client = OpenAIClient(
          config: const OpenAIConfig(
            baseUrl: 'https://fixture.invalid/v1?base=kept&k=a&k=b',
          ),
          httpClient: MockClient((request) async {
            requests.add(request);
            return _json(_sessionPage(hasMore: requests.length == 1));
          }),
        );
        addTearDown(client.close);
        final first = client.agents.sessions.list(
          limit: 1,
          order: AgentListOrder.asc,
          agentId: 'agent/🚀',
          metadata: metadata,
        );
        metadata.clear();
        final page = await first;
        await client.agents.sessions.list(
          limit: 1,
          order: AgentListOrder.asc,
          agentId: 'agent/🚀',
          after: page.lastId,
          metadata: {'tenant': 'café🚀 &+/%', 'a[b]% key': ''},
        );
        for (var index = 0; index < requests.length; index++) {
          final request = requests[index];
          expect(request.method, 'GET');
          expect(request.url.path, '/v1/agents/sessions');
          expect(request.bodyBytes, isEmpty);
          expect(request.url.queryParametersAll, {
            'base': ['kept'],
            'k': ['a', 'b'],
            'limit': ['1'],
            'order': ['asc'],
            'agent_id': ['agent/🚀'],
            'metadata[tenant]': ['café🚀 &+/%'],
            'metadata[a[b]% key]': [''],
            if (index == 1) 'after': ['session_fixture'],
          });
          expect(request.url.query, contains('metadata%5Btenant%5D='));
          expect(request.url.queryParameters.containsKey('metadata'), isFalse);
          expect(request.headers['openai-beta'], 'agents=v1');
        }
      },
    );

    test('omitted and empty maps emit no query field or defaults', () async {
      final requests = <http.Request>[];
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json(_sessionPage());
        }),
      );
      addTearDown(client.close);
      await client.agents.sessions.list();
      await client.agents.sessions.list(metadata: {});
      expect(requests.map((request) => request.url.query), everyElement(''));
    });

    test(
      'all canonical count/Unicode length boundaries are admitted',
      () async {
        final client = OpenAIClient(
          httpClient: MockClient((request) async {
            expect(
              request.url.queryParameters['metadata[${'😀' * 64}]'],
              '😀' * 512,
            );
            expect(request.url.queryParameters.length, 16);
            return _json(_sessionPage());
          }),
        );
        addTearDown(client.close);
        await client.agents.sessions.list(
          metadata: {
            '😀' * 64: '😀' * 512,
            for (var i = 0; i < 15; i++) 'key_$i': '',
          },
        );
      },
    );

    test(
      'valid UTF-16 surrogate pairs reach exact matching unchanged',
      () async {
        final auth = _Auth();
        final key = String.fromCharCodes([0xd83d, 0xde00]);
        final value = String.fromCharCodes([0xd83d, 0xde80]);
        var dispatched = false;
        final client = OpenAIClient(
          config: OpenAIConfig(authProvider: auth),
          httpClient: MockClient((request) async {
            dispatched = true;
            expect(request.url.queryParameters['metadata[$key]'], value);
            return _json(_sessionPage());
          }),
        );
        addTearDown(client.close);
        await client.agents.sessions.list(metadata: {key: value});
        expect(auth.calls, greaterThan(0));
        expect(dispatched, isTrue);
      },
    );

    for (final invalid in [
      <String, String>{'': 'PRIVATE_VALUE'},
      <String, String>{'😀' * 65: 'PRIVATE_VALUE'},
      <String, String>{'PRIVATE_KEY': '😀' * 513},
      <String, String>{for (var i = 0; i < 17; i++) 'PRIVATE_$i': 'value'},
      for (final surrogate in [0xd800, 0xdc00]) ...[
        <String, String>{String.fromCharCode(surrogate): 'PRIVATE_VALUE'},
        <String, String>{'PRIVATE_KEY': String.fromCharCode(surrogate)},
      ],
    ]) {
      test('invalid metadata rejects privately before auth/dispatch', () {
        final auth = _Auth();
        var dispatched = false;
        final client = OpenAIClient(
          config: OpenAIConfig(authProvider: auth),
          httpClient: MockClient((request) {
            dispatched = true;
            throw StateError('No dispatch expected.');
          }),
        );
        addTearDown(client.close);
        expect(
          () => client.agents.sessions.list(metadata: invalid),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'private metadata',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        expect(auth.calls, 0);
        expect(dispatched, isFalse);
      });
    }
  });

  test(
    'saved create/update/retrieve/list carry settings and ultrafast',
    () async {
      final requests = <http.Request>[];
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET' && request.url.path == '/v1/agents') {
            return _json({
              'object': 'list',
              'data': [_savedAgent()],
              'first_id': 'agent_fixture',
              'last_id': 'agent_fixture',
              'has_more': false,
            });
          }
          return _json(
            _savedAgent(),
            request.method == 'POST' && request.url.path == '/v1/agents'
                ? 201
                : 200,
          );
        }),
      );
      addTearDown(client.close);
      final createWire = <String, dynamic>{
        'model': 'gpt-6-sol',
        'service_tier': 'ultrafast',
        'compaction': {'async': null},
        'experimental': {'time_awareness': true},
      };
      final created = await client.agents.create(
        CreateAgentRequest.fromJson(createWire),
      );
      expect(jsonDecode(requests.last.body), createWire);
      expect(created.compaction!.async, isTrue);
      expect(created.experimental!.timeAwareness, isTrue);
      for (final updateWire in <Map<String, dynamic>>[
        {},
        {'compaction': null, 'experimental': <String, dynamic>{}},
        {
          'compaction': {'async': false},
          'experimental': {'time_awareness': false},
          'service_tier': 'ultrafast',
        },
      ]) {
        await client.agents.update(
          'agent_fixture',
          UpdateAgentRequest.fromJson(updateWire),
        );
        expect(jsonDecode(requests.last.body), updateWire);
      }
      final retrieved = await client.agents.retrieve('agent_fixture');
      final listed = await client.agents.list();
      expect(retrieved.toJson(), _savedAgent());
      expect(listed.data.single.toJson(), _savedAgent());
      expect(
        requests.every((request) => !request.body.contains('spend_control')),
        isTrue,
      );
    },
  );

  test(
    'session JSON creation receives resolved settings and independent review',
    () async {
      final requests = <http.Request>[];
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json(_session(), 201);
        }),
      );
      addTearDown(client.close);
      for (final review in [null, 'none', 'auto_review']) {
        final wire = _createSessionWire(review: review);
        final session = await client.agents.sessions.create(
          CreateAgentSessionRequest.fromJson(wire),
        );
        expect(jsonDecode(requests.last.body), wire);
        expect(session.review!.value, 'auto_review');
        expect(session.agent.compaction!.async, isTrue);
        expect(session.agent.experimental!.timeAwareness, isTrue);
        expect(session.agent.serviceTier.value, 'ultrafast');
        expect(session.toJson(), _session());
      }
      final overrides = {
        'agent_id': 'agent_fixture',
        'agent': {'compaction': null, 'experimental': <String, dynamic>{}},
        'environment': {'type': 'none'},
        'input': 'Start using saved settings.',
      };
      await client.agents.sessions.create(
        CreateAgentSessionRequest.fromJson(overrides),
      );
      expect(jsonDecode(requests.last.body), overrides);
      expect(
        requests.every((request) => !request.body.contains('spend_control')),
        isTrue,
      );
    },
  );

  test(
    'session update keeps tools omitted/null/empty independent of review and tier',
    () async {
      final requests = <http.Request>[];
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json(_session(review: null));
        }),
      );
      addTearDown(client.close);
      for (final wire in <Map<String, dynamic>>[
        {},
        {'review': 'none', 'metadata': null},
        {
          'review': 'auto_review',
          'agent': {'tools': null, 'service_tier': 'ultrafast'},
        },
        {
          'agent': {'tools': <Object>[], 'service_tier': null},
        },
        {
          'agent': {
            'tools': [
              {'type': 'tool_search'},
            ],
          },
        },
      ]) {
        final session = await client.agents.sessions.update(
          'session_fixture',
          UpdateAgentSessionRequest.fromJson(wire),
        );
        expect(jsonDecode(requests.last.body), wire);
        expect(session.review, isNull);
        expect(session.toJson().containsKey('review'), isFalse);
        expect(requests.last.url.path, '/v1/agents/sessions/session_fixture');
      }
      final retrieved = await client.agents.sessions.retrieve(
        'session_fixture',
      );
      expect(retrieved.toJson(), _session(review: null));
      expect(
        requests.every((request) => !request.body.contains('spend_control')),
        isTrue,
      );
    },
  );

  test(
    'streamed creation and observation retain resolved settings and review',
    () async {
      final requests = <http.Request>[];
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            'event: agent.session.created\ndata: ${jsonEncode({'type': 'agent.session.created', 'event_id': 'created', 'session': _session()})}\n\n'
            'event: agent.session.idle\ndata: ${jsonEncode({'type': 'agent.session.idle', 'event_id': 'idle', 'session': _session(review: null)})}\n\n',
            request.method == 'POST' ? 201 : 200,
            headers: {'content-type': 'text/event-stream; charset=utf-8'},
          );
        }),
      );
      addTearDown(client.close);
      final wire = _createSessionWire(review: 'auto_review');
      final created = await client.agents.sessions
          .createStream(CreateAgentSessionRequest.fromJson(wire))
          .toList();
      expect(jsonDecode(requests.last.body), {...wire, 'stream': true});
      final observed = await client.agents.sessions.events
          .stream('session_fixture')
          .toList();
      for (final events in [created, observed]) {
        expect(events, hasLength(2));
        final session = (events.first as AgentSessionCreatedEvent).session;
        expect(session.review!.value, 'auto_review');
        expect(session.agent.compaction!.async, isTrue);
        expect(session.agent.experimental!.timeAwareness, isTrue);
        expect(session.agent.serviceTier.value, 'ultrafast');
        expect(events.first.toJson()['session'], _session());
        final idle = (events.last as AgentSessionIdleEvent).session;
        expect(idle.review, isNull);
        expect(idle.toJson().containsKey('review'), isFalse);
      }
      expect(requests.last.body, isEmpty);
      expect(
        requests.map((request) => request.headers['accept']),
        everyElement('text/event-stream'),
      );
    },
  );
}

Map<String, dynamic> _savedAgent() => {
  ...savedAgentWire(),
  'model': 'gpt-6-sol',
  'service_tier': 'ultrafast',
  'compaction': {'async': true},
  'experimental': {'time_awareness': true},
};

Map<String, dynamic> _session({String? review = 'auto_review'}) => {
  'review': ?review,
  'metadata': <String, String>{},
  'id': 'session_fixture',
  'object': 'agent.session',
  'created_at': 100,
  'last_active_at': 101,
  'status': 'idle',
  'required_actions': <Object>[],
  'error': null,
  'agent': {
    'id': 'agent_session_fixture',
    'name': null,
    'model': 'gpt-6-sol',
    'reasoning': {'effort': null, 'summary': null},
    'text': {
      'format': {'type': 'text'},
      'verbosity': 'medium',
    },
    'service_tier': 'ultrafast',
    'instructions': null,
    'tools': <Object>[],
    'multi_agent': {'enabled': false, 'max_concurrent_subagents': null},
    'compaction': {'async': true},
    'experimental': {'time_awareness': true},
  },
  'environment': {'type': 'none'},
  'vault_ids': <String>[],
  'usage': null,
};

Map<String, dynamic> _createSessionWire({String? review}) => {
  'agent': {
    'model': 'gpt-6-sol',
    'service_tier': 'ultrafast',
    'compaction': {'async': null},
    'experimental': {'time_awareness': true},
  },
  'review': ?review,
  'environment': {'type': 'none'},
  'input': 'Start the session.',
};

Map<String, dynamic> _sessionPage({bool hasMore = false}) => {
  'object': 'list',
  'data': [_session()],
  'first_id': 'session_fixture',
  'last_id': 'session_fixture',
  'has_more': hasMore,
};

http.Response _json(Object? value, [int status = 200]) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'Bearer synthetic_agent_settings'};
  }
}
