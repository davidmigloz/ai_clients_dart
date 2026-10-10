import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_subagent_wire_fixtures.dart';

const ops = ['list', 'retrieve', 'items', 'turns', 'turn', 'turnItems'];
const id = 'PRIVATE/%2F?🚀';
String schema(String op) => switch (op) {
  'list' =>
    '#/paths/~1agents~1sessions~1{session_id}~1subagents/get/responses/200/content/application~1json/schema',
  'retrieve' => 'SubagentResource',
  'turn' => 'TurnResource',
  'turns' => 'SessionTurnListResource',
  _ => 'SessionItemListResource',
};
Map<String, dynamic> wire(String op) => Map<String, dynamic>.from(
  subagentWireFixtures.singleWhere((f) => f.schema == schema(op)).full! as Map,
);
Future<AgentJsonModel> call(
  OpenAIClient c,
  String op, {
  Map<String, String>? headers,
  Future<void>? abort,
}) {
  final s = c.agents.sessions.subagents;
  return switch (op) {
    'list' => s.list(
      id,
      limit: 100,
      order: AgentListOrder.asc,
      after: id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'retrieve' => s.retrieve(
      id,
      id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'items' => s.items.list(
      id,
      id,
      limit: 100,
      order: AgentListOrder.asc,
      after: id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'turns' => s.turns.list(
      id,
      id,
      limit: 100,
      order: AgentListOrder.asc,
      after: id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'turn' => s.turns.retrieve(
      id,
      id,
      id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'turnItems' => s.turns.items.list(
      id,
      id,
      id,
      limit: 100,
      order: AgentListOrder.asc,
      after: id,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    _ => throw StateError('Unknown fixture'),
  };
}

bool isList(String op) => !['retrieve', 'turn'].contains(op);
void main() {
  final previous = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previous);
  for (final op in ops) {
    test(
      '$op: actual nested GET, headers/auth/query, private logs and borrowed transport',
      () async {
        final captures = <http.Request>[];
        final expected = wire(op);
        final peer = Spy(
          MockClient((r) async {
            captures.add(r);
            return http.Response.bytes(
              utf8.encode(jsonEncode(expected)),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        addTearDown(peer.inner.close);
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/custom/v1',
            organization: 'org',
            project: 'project',
            authProvider: FixtureAuth(),
            defaultHeaders: const {'OpenAI-Beta': 'wrong', 'Accept': 'wrong'},
          ),
          httpClient: peer,
        );
        final records = <LogRecord>[];
        final logger = Logger('subagents-$op')..level = Level.ALL;
        final logs = logger.onRecord.listen(records.add);
        client.interceptorChain.interceptors.add(
          LoggingInterceptor(logger: logger),
        );
        final headers = {
          'oPeNaI-bEtA': 'wrong',
          'ACCEPT': 'wrong',
          'Content-Type': 'text/plain; charset=latin1',
          'X-Caller': 'original',
        };
        final pending = call(client, op, headers: headers);
        headers['X-Caller'] = 'changed';
        final result = await pending;
        final r = captures.single;
        expect(r.method, 'GET');
        expect(r.bodyBytes, isEmpty);
        expect(r.headers['accept'], 'application/json');
        expect(r.headers['openai-beta'], 'agents=v1');
        expect(r.headers.containsKey('content-type'), isFalse);
        expect(r.headers['authorization'], 'Bearer synthetic');
        expect(r.headers['openai-organization'], 'org');
        expect(r.headers['openai-project'], 'project');
        expect(r.headers['x-caller'], 'original');
        expect(r.url.pathSegments, [
          'custom',
          'v1',
          'agents',
          'sessions',
          id,
          'subagents',
          if (op != 'list') id,
          if (op == 'items') 'items',
          if (['turns', 'turn', 'turnItems'].contains(op)) 'turns',
          if (['turn', 'turnItems'].contains(op)) id,
          if (op == 'turnItems') 'items',
        ]);
        expect(
          r.url.queryParameters,
          isList(op)
              ? {'limit': '100', 'order': 'asc', 'after': id}
              : <String, String>{},
        );
        expect(result.toJson(), expected);
        expect(result.toString(), isNot(contains('PRIVATE')));
        expect(records, isNotEmpty);
        expect(
          records.map((r) => r.message).join(),
          isNot(contains('PRIVATE')),
        );
        final s = client.agents.sessions.subagents;
        expect(identical(s, client.agents.sessions.subagents), isTrue);
        expect(identical(s.items, s.items), isTrue);
        expect(identical(s.turns, s.turns), isTrue);
        expect(identical(s.turns.items, s.turns.items), isTrue);
        client.close();
        expect(peer.closed, 0);
        await logs.cancel();
      },
    );
    test('$op: completed abort precedes provider/dispatch', () async {
      var sent = 0;
      final peer = MockClient((r) async {
        sent++;
        return http.Response('{}', 200);
      });
      final client = OpenAIClient(
        config: OpenAIConfig(authProvider: ErrorAuth(StateError('PRIVATE'))),
        httpClient: peer,
      );
      addTearDown(() {
        client.close();
        peer.close();
      });
      final abort = Completer<void>()..complete();
      await expectLater(
        call(client, op, abort: abort.future),
        throwsA(isA<AbortedException>()),
      );
      expect(sent, 0);
    });
    test(
      '$op: malformed known and wrong success status fail privately',
      () async {
        for (final malformed in [true, false]) {
          final peer = MockClient(
            (r) async => http.Response.bytes(
              utf8.encode(
                jsonEncode(malformed ? {'object': 'PRIVATE-wrong'} : wire(op)),
              ),
              malformed ? 200 : 201,
            ),
          );
          final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
          try {
            await expectLater(
              call(client, op),
              throwsA(
                isA<ParseException>().having(
                  (e) => e.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                ),
              ),
            );
          } finally {
            client.close();
            peer.close();
          }
        }
      },
    );
    test(
      '$op: HTTP failures bind actual private route despite a foreign response request',
      () async {
        final peer = ForeignClient();
        final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
        addTearDown(client.close);
        await expectLater(
          call(client, op),
          throwsA(
            isA<BadRequestException>()
                .having(
                  (e) => e.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                )
                .having(
                  (e) => e.message,
                  'explicit message',
                  'PRIVATE-http-message',
                ),
          ),
        );
      },
    );
  }
  for (final op in ['list', 'items', 'turns', 'turnItems']) {
    test(
      '$op: nonempty then empty ID pages retain order and exclusive after',
      () async {
        final captures = <http.Request>[];
        final full = wire(op);
        final peer = MockClient((r) async {
          captures.add(r);
          return http.Response.bytes(
            utf8.encode(
              jsonEncode(
                captures.length == 1
                    ? full
                    : {
                        'object': 'list',
                        'data': <Object>[],
                        'first_id': null,
                        'last_id': null,
                        'has_more': false,
                      },
              ),
            ),
            200,
          );
        });
        final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
        addTearDown(() {
          client.close();
          peer.close();
        });
        final s = client.agents.sessions.subagents;
        Future<AgentJsonModel> page(String? after) => switch (op) {
          'list' => s.list(
            's',
            limit: 1,
            order: AgentListOrder.desc,
            after: after,
          ),
          'items' => s.items.list(
            's',
            'c',
            limit: 1,
            order: AgentListOrder.desc,
            after: after,
          ),
          'turns' => s.turns.list(
            's',
            'c',
            limit: 1,
            order: AgentListOrder.desc,
            after: after,
          ),
          _ => s.turns.items.list(
            's',
            'c',
            't',
            limit: 1,
            order: AgentListOrder.desc,
            after: after,
          ),
        };
        final first = await page(null);
        final last = await page((first.toJson() as Map)['last_id'] as String?);
        expect(captures[0].url.queryParameters, {
          'limit': '1',
          'order': 'desc',
        });
        expect(captures[1].url.queryParameters, {
          'limit': '1',
          'order': 'desc',
          'after': full['last_id'],
        });
        expect(last.toJson(), {
          'object': 'list',
          'data': <Object>[],
          'first_id': null,
          'last_id': null,
          'has_more': false,
        });
      },
    );
  }
  for (final error in <Object>[
    StateError('PRIVATE-connector'),
    const ConnectionException(message: 'PRIVATE-sdk'),
    const ApiException(message: 'PRIVATE-sdk', statusCode: 400),
  ]) {
    for (final mode in ['send', 'body', 'provider']) {
      test('external failures private: $mode ${error.runtimeType}', () async {
        final peer = ErrorClient(error, body: mode == 'body');
        final client = OpenAIClient(
          config: OpenAIConfig(
            authProvider: mode == 'provider' ? ErrorAuth(error) : FixtureAuth(),
          ),
          httpClient: peer,
        );
        addTearDown(client.close);
        await expectLater(
          call(client, 'retrieve'),
          throwsA(
            isA<ConnectionException>()
                .having(
                  (e) => e.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                )
                .having((e) => e.cause, 'explicit cause', same(error)),
          ),
        );
      });
    }
  }
  test(
    'external native provider failure stays private before dispatch',
    () async {
      final error = http.RequestAbortedException(
        Uri.parse('https://private.invalid/PRIVATE-token'),
      );
      final peer = PendingClient();
      final client = OpenAIClient(
        config: OpenAIConfig(authProvider: ErrorAuth(error)),
        httpClient: peer,
      );
      addTearDown(client.close);
      await expectLater(
        call(client, 'retrieve'),
        throwsA(
          isA<ConnectionException>()
              .having(
                (e) => e.toString(),
                'private',
                isNot(contains('PRIVATE')),
              )
              .having((e) => e.cause, 'explicit native cause', same(error)),
        ),
      );
    },
  );
  test(
    'native during-request abortion retains type and borrowed ownership',
    () async {
      final peer = AbortClient();
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(client.close);
      final abort = Completer<void>();
      final result = call(client, 'retrieve', abort: abort.future);
      await peer.started.future;
      abort.complete();
      await expectLater(result, throwsA(isA<AbortedException>()));
      expect(peer.closed, 0);
    },
  );
  test('local timeout retains its established class', () async {
    final peer = PendingClient();
    final client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: FixtureAuth(),
        timeout: const Duration(milliseconds: 20),
      ),
      httpClient: peer,
    );
    addTearDown(client.close);
    await expectLater(
      call(client, 'retrieve'),
      throwsA(isA<RequestTimeoutException>()),
    );
  });
  test(
    'closed resources and opaque IDs reject locally at each nesting level',
    () {
      var sent = 0;
      final peer = MockClient((r) async {
        sent++;
        return http.Response('{}', 200);
      });
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(peer.close);
      final s = client.agents.sessions.subagents;
      for (final bad in ['', '.', '..']) {
        expect(() => s.list(bad), throwsFormatException);
        expect(() => s.retrieve('s', bad), throwsFormatException);
        expect(() => s.turns.items.list('s', 'c', bad), throwsFormatException);
      }
      for (final limit in [0, 101]) {
        expect(
          () => s.items.list('s', 'c', limit: limit),
          throwsFormatException,
        );
      }
      expect(
        () => s.turns.list('s', 'c', order: AgentListOrder.fromJson('future')),
        throwsFormatException,
      );
      expect(sent, 0);
      client.close();
      expect(() => s.list('s'), throwsStateError);
      expect(() => s.items, throwsStateError);
      expect(() => s.turns.items, throwsStateError);
    },
  );
}

class FixtureAuth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic',
    'Accept': 'wrong',
    'OpenAI-Beta': 'wrong',
    'Content-Type': 'text/plain; charset=latin1',
  };
}

class ErrorAuth implements AuthProvider {
  ErrorAuth(this.error);
  final Object error;
  @override
  Map<String, String> getHeaders() {
    if (error is Exception) throw error as Exception;
    throw error as Error;
  }
}

class Spy extends http.BaseClient {
  Spy(this.inner);
  final http.Client inner;
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) => inner.send(r);
  @override
  void close() {
    closed++;
  }
}

class ErrorClient extends http.BaseClient {
  ErrorClient(this.error, {required this.body});
  final Object error;
  final bool body;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) async {
    if (body) {
      return http.StreamedResponse(
        Stream<List<int>>.error(error),
        200,
        request: r,
      );
    }
    if (error is Exception) throw error as Exception;
    throw error as Error;
  }
}

class ForeignClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) async =>
      http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'error': {
                'type': 'invalid_request_error',
                'message': 'PRIVATE-http-message',
                'code': 'bad',
                'param': null,
              },
            }),
          ),
        ),
        400,
        request: http.Request(
          'GET',
          Uri.parse('https://foreign.invalid/unrelated'),
        ),
      );
}

class AbortClient extends http.BaseClient {
  final started = Completer<void>();
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) async {
    started.complete();
    await (r as http.Abortable).abortTrigger;
    throw http.RequestAbortedException(r.url);
  }

  @override
  void close() {
    closed++;
  }
}

class PendingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) =>
      Completer<http.StreamedResponse>().future;
}
