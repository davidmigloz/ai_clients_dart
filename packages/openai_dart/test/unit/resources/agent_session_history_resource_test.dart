import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_session_history_fixtures.dart';
import '../fixtures/agent_session_wire_fixtures.dart';

Map<String, dynamic> _wire(String schema, {bool empty = false}) {
  final fixture = agentSessionHistoryFixtures.singleWhere(
    (f) => f.schema == schema,
  );
  return empty ? fixture.minimal : fixture.full;
}

Future<Object> _call(
  OpenAIClient client,
  String op, {
  int? limit,
  AgentListOrder? order,
  String? after,
  Map<String, String>? headers,
  Future<void>? abort,
}) {
  const session = 'session/%2F?🚀';
  const turn = 'turn/%2F?🚀';
  final s = client.agents.sessions;
  return switch (op) {
    'items' => s.items.list(
      session,
      limit: limit,
      order: order,
      after: after,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'turns' => s.turns.list(
      session,
      limit: limit,
      order: order,
      after: after,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'turn' => s.turns.retrieve(
      session,
      turn,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'turnItems' => s.turns.items.list(
      session,
      turn,
      limit: limit,
      order: order,
      after: after,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'traces' => s.traces.list(
      session,
      limit: limit,
      order: order,
      after: after,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    _ => throw StateError('Unknown operation'),
  };
}

void main() {
  for (final op in ['items', 'turns', 'turn', 'turnItems', 'traces']) {
    test(
      '$op public GET exact IDs/context/beta/caller snapshot/pagination',
      () async {
        final requests = <http.Request>[];
        final schema = switch (op) {
          'items' || 'turnItems' => 'SessionItemListResource',
          'turns' => 'SessionTurnListResource',
          'traces' => 'SessionTraceListResource',
          _ => 'TurnResource',
        };
        final wire = schema == 'TurnResource'
            ? agentSessionWireFixtures
                  .singleWhere((f) => f.schema == schema)
                  .minimal
            : _wire(schema);
        final transport = MockClient((r) async {
          requests.add(r);
          return http.Response.bytes(
            utf8.encode(jsonEncode(wire)),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/custom/v1',
            organization: 'org',
            project: 'proj',
            authProvider: _Auth(),
            defaultHeaders: const {'OpenAI-Beta': 'wrong', 'Accept': 'wrong'},
          ),
          httpClient: transport,
        );
        addTearDown(() {
          client.close();
          transport.close();
        });
        final headers = {
          'X-Captured': 'at-call',
          'oPeNaI-bEtA': 'wrong',
          'ACCEPT': 'wrong',
        };
        final pending = _call(
          client,
          op,
          limit: 100,
          order: AgentListOrder.asc,
          after: 'anchor/🚀',
          headers: headers,
        );
        headers.clear();
        final result = await pending as AgentJsonModel;
        expect(result.toJson(), wire);
        final request = requests.single;
        expect(request.method, 'GET');
        expect(request.bodyBytes, isEmpty);
        expect(request.headers.containsKey('content-type'), isFalse);
        expect(request.headers['x-captured'], 'at-call');
        expect(request.headers['openai-beta'], 'agents=v1');
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['openai-project'], 'proj');
        expect(request.headers['openai-organization'], 'org');
        final path = <String>[
          'custom',
          'v1',
          'agents',
          'sessions',
          'session/%2F?🚀',
          if (op == 'turn' || op == 'turnItems') ...['turns', 'turn/%2F?🚀'],
          if (op != 'turn')
            switch (op) {
              'turnItems' => 'items',
              _ => op,
            },
        ];
        expect(request.url.pathSegments, path);
        expect(
          request.url.queryParameters,
          op == 'turn'
              ? <String, String>{}
              : {'limit': '100', 'order': 'asc', 'after': 'anchor/🚀'},
        );
        if (op != 'turn') {
          await _call(client, op);
          expect(requests.last.url.queryParameters, isEmpty);
          for (final invalid in [0, 101]) {
            expect(
              () => _call(client, op, limit: invalid),
              throwsFormatException,
            );
          }
          expect(
            () => _call(client, op, order: AgentListOrder.fromJson('future')),
            throwsFormatException,
          );
        }
      },
    );
    test(
      '$op error/malformed JSON and OTLP privacy on default diagnostics',
      () async {
        final previous = hierarchicalLoggingEnabled;
        hierarchicalLoggingEnabled = true;
        final logs = <String>[];
        final subscription = Logger.root.onRecord.listen(
          (r) => logs.add('${r.message} ${r.error ?? ''}'),
        );
        var status = 404;
        var body = jsonEncode({
          'error': {
            'message': 'PRIVATE',
            'type': 'PRIVATE',
            'code': 'PRIVATE',
            'param': 'PRIVATE',
          },
        });
        final transport = MockClient(
          (r) async => http.Response(
            body,
            status,
            headers: {
              'content-type': 'application/json',
              'x-request-id': 'PRIVATE',
            },
          ),
        );
        final client = OpenAIClient(
          config: const OpenAIConfig(
            baseUrl: 'https://fixture.invalid/v1?token=PRIVATE',
            authProvider: ApiKeyProvider('PRIVATE'),
            logLevel: Level.ALL,
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        addTearDown(() async {
          client.close();
          transport.close();
          await subscription.cancel();
          hierarchicalLoggingEnabled = previous;
        });
        await expectLater(
          _call(client, op, headers: {'X-Private': 'PRIVATE'}),
          throwsA(
            isA<NotFoundException>().having(
              (e) => e.toString(),
              'private',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        status = 200;
        body = 'PRIVATE-not-json';
        await expectLater(
          _call(client, op),
          throwsA(
            isA<ParseException>().having(
              (e) => e.toString(),
              'private',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        expect(logs, isNotEmpty);
        expect(logs.join('\n'), isNot(contains('PRIVATE')));
      },
    );
    test(
      '$op already-triggered abort prevents authentication and dispatch',
      () async {
        var dispatched = 0;
        final transport = MockClient((r) async {
          dispatched++;
          return http.Response('', 200);
        });
        final client = OpenAIClient.withApiKey(
          'synthetic',
          httpClient: transport,
        );
        addTearDown(() {
          client.close();
          transport.close();
        });
        final abort = Completer<void>()..complete();
        await expectLater(
          _call(client, op, abort: abort.future),
          throwsA(isA<AbortedException>()),
        );
        expect(dispatched, 0);
      },
    );
  }
  test(
    'Empty boundaries and two trace pages preserve root-turn cursor without polling',
    () async {
      final requests = <http.Request>[];
      final trace = _wire('SessionTraceListResource')['data'] as List;
      final transport = MockClient((r) async {
        requests.add(r);
        final body = r.url.path.endsWith('/traces')
            ? r.url.queryParameters['after'] == null
                  ? {
                      'object': 'list',
                      'data': trace,
                      'first_id': 'turn_1',
                      'last_id': 'turn_1',
                      'has_more': true,
                    }
                  : {
                      'object': 'list',
                      'data': [
                        Map<String, dynamic>.of(
                          trace.first as Map<String, dynamic>,
                        )..['id'] = 'turn_3',
                      ],
                      'first_id': 'turn_3',
                      'last_id': 'turn_3',
                      'has_more': false,
                    }
            : _wire(
                r.url.path.endsWith('/turns')
                    ? 'SessionTurnListResource'
                    : 'SessionItemListResource',
                empty: true,
              );
        return http.Response.bytes(
          utf8.encode(jsonEncode(body)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final client = OpenAIClient.withApiKey(
        'synthetic',
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final traces = client.agents.sessions.traces;
      final first = await traces.list(
        'known',
        limit: 1,
        order: AgentListOrder.asc,
      );
      final second = await traces.list(
        'known',
        limit: 1,
        order: AgentListOrder.asc,
        after: first.lastId,
      );
      expect(first.data.first.id, 'turn_1');
      expect(second.data.first.id, 'turn_3');
      expect(second.hasMore, isFalse);
      expect(requests, hasLength(2));
      expect(requests.last.url.queryParameters, {
        'limit': '1',
        'order': 'asc',
        'after': 'turn_1',
      });
      final items = await client.agents.sessions.items.list('known');
      final turns = await client.agents.sessions.turns.list('known');
      final turnItems = await client.agents.sessions.turns.items.list(
        'known',
        'turn',
      );
      for (final page in [items.toJson(), turns.toJson(), turnItems.toJson()]) {
        expect(page['data'], isEmpty);
        expect(page['first_id'], isNull);
        expect(page['last_id'], isNull);
      }
      for (final id in ['', '.', '..']) {
        expect(() => traces.list(id), throwsFormatException);
        expect(
          () => client.agents.sessions.turns.retrieve('known', id),
          throwsFormatException,
        );
      }
      client.close();
      expect(() => client.agents.sessions.turns, throwsStateError);
    },
  );
}

class _Auth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic',
    'OPENAI-BETA': 'wrong',
    'AcCePt': 'wrong',
  };
}
