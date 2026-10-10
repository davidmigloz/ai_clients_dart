import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const artifact = <String, Object>{
  'id': 'PRIVATE-artifact',
  'object': 'agent.session.artifact',
  'session_id': 'PRIVATE-session',
  'environment_id': 'PRIVATE-environment',
  'turn_id': 'PRIVATE-turn',
  'path': '/workspace/outputs/PRIVATE.bin',
  'size_bytes': 4,
  'created_at': -1,
};
const file = <String, Object>{
  'object': 'agent.environment.file',
  'environment_id': 'PRIVATE-environment',
  'path': '/workspace/PRIVATE.bin',
  'size_bytes': 4,
};
const opaque = 'PRIVATE/%2F?🚀';
const operations = [
  'fileId',
  'inline',
  'files',
  'artifacts',
  'retrieve',
  'delete',
  'download',
  'stream',
];
Future<Object> call(
  OpenAIClient client,
  String op, {
  Map<String, String>? headers,
  Future<void>? abort,
}) {
  final f = client.agents.environments.files;
  final a = client.agents.sessions.artifacts;
  return switch (op) {
    'fileId' => f.create(
      opaque,
      AgentSessionHostedEnvironmentFileConfig.fileId(
        fileId: 'PRIVATE-file',
        path: '/workspace/PRIVATE.bin',
      ),
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'inline' => f.create(
      opaque,
      AgentSessionHostedEnvironmentFileConfig.inline(
        data: 'AP+A',
        path: '/workspace/PRIVATE.bin',
      ),
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'files' => f.list(
      opaque,
      path: '/workspace',
      limit: 100,
      order: AgentListOrder.asc,
      page: opaque,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'artifacts' => a.list(
      opaque,
      limit: 100,
      order: AgentListOrder.asc,
      after: opaque,
      environmentId: opaque,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'retrieve' => a.retrieve(
      opaque,
      opaque,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'delete' => a.delete(
      opaque,
      opaque,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'download' => a.download(
      opaque,
      opaque,
      additionalHeaders: headers,
      abortTrigger: abort,
    ),
    'stream' =>
      a
          .downloadStream(
            opaque,
            opaque,
            additionalHeaders: headers,
            abortTrigger: abort,
          )
          .expand((b) => b)
          .toList(),
    _ => throw StateError('Unknown fixture'),
  };
}

http.Response response(String op) {
  if (op == 'download' || op == 'stream') {
    return http.Response.bytes(
      [0, 255, 128, 0],
      200,
      headers: {'content-type': 'application/octet-stream'},
    );
  }
  final Object body = switch (op) {
    'fileId' || 'inline' => file,
    'files' => {
      'object': 'page',
      'data': [file],
      'next': null,
      'has_more': false,
    },
    'artifacts' => {
      'object': 'list',
      'data': [artifact],
      'first_id': 'PRIVATE-artifact',
      'last_id': 'PRIVATE-artifact',
      'has_more': false,
    },
    'delete' => {
      'id': 'PRIVATE-artifact',
      'object': 'agent.session.artifact.deleted',
      'deleted': true,
    },
    _ => artifact,
  };
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    op == 'fileId' || op == 'inline' ? 201 : 200,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  final previous = hierarchicalLoggingEnabled;
  setUpAll(() => hierarchicalLoggingEnabled = true);
  tearDownAll(() => hierarchicalLoggingEnabled = previous);
  for (final op in operations) {
    test(
      '$op: actual exported path, body, auth, forced media and borrowed transport',
      () async {
        final captures = <http.Request>[];
        final spy = Spy(
          MockClient((r) async {
            captures.add(r);
            return response(op);
          }),
        );
        addTearDown(spy.inner.close);
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/custom/v1',
            authProvider: FixtureAuth(),
            organization: 'org',
            project: 'project',
            defaultHeaders: const {'OpenAI-Beta': 'wrong', 'Accept': 'wrong'},
          ),
          httpClient: spy,
        );
        final records = <LogRecord>[];
        final logger = Logger('files-$op')..level = Level.ALL;
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
        final value = await call(client, op, headers: headers);
        final r = captures.single;
        final segments = op == 'fileId' || op == 'inline' || op == 'files'
            ? ['custom', 'v1', 'agents', 'environments', opaque, 'files']
            : [
                'custom',
                'v1',
                'agents',
                'sessions',
                opaque,
                'artifacts',
                if (op != 'artifacts') opaque,
                if (op == 'download' || op == 'stream') 'content',
              ];
        expect(r.url.pathSegments, segments);
        expect(
          r.method,
          op == 'delete'
              ? 'DELETE'
              : op == 'fileId' || op == 'inline'
              ? 'POST'
              : 'GET',
        );
        expect(r.headers['openai-beta'], 'agents=v1');
        expect(
          r.headers['accept'],
          op == 'download' || op == 'stream'
              ? 'application/octet-stream'
              : 'application/json',
        );
        expect(r.headers['authorization'], 'Bearer synthetic');
        expect(r.headers['openai-organization'], 'org');
        expect(r.headers['openai-project'], 'project');
        expect(r.headers['x-caller'], 'original');
        if (op == 'fileId' || op == 'inline') {
          expect(r.headers['content-type'], 'application/json; charset=utf-8');
          expect(jsonDecode(utf8.decode(r.bodyBytes)), {
            'type': op == 'inline' ? 'inline' : 'file_id',
            op == 'inline' ? 'data' : 'file_id': op == 'inline'
                ? 'AP+A'
                : 'PRIVATE-file',
            'path': '/workspace/PRIVATE.bin',
          });
        } else {
          expect(r.headers.containsKey('content-type'), isFalse);
          expect(r.bodyBytes, isEmpty);
        }
        if (op == 'files') {
          expect(r.url.queryParameters, {
            'path': '/workspace',
            'limit': '100',
            'order': 'asc',
            'page': opaque,
          });
        } else if (op == 'artifacts') {
          expect(r.url.queryParameters, {
            'limit': '100',
            'order': 'asc',
            'after': opaque,
            'environment_id': opaque,
          });
        } else {
          expect(r.url.query, isEmpty);
        }
        if (op == 'download' || op == 'stream') {
          expect(value, [0, 255, 128, 0]);
        } else {
          expect(
            (value as AgentJsonModel).toJson(),
            jsonDecode(response(op).body),
          );
        }
        expect(
          records.map((r) => r.message).join(),
          isNot(contains('PRIVATE')),
        );
        expect(
          identical(
            client.agents.environments.files,
            client.agents.environments.files,
          ),
          isTrue,
        );
        expect(
          identical(
            client.agents.sessions.artifacts,
            client.agents.sessions.artifacts,
          ),
          isTrue,
        );
        client.close();
        expect(spy.closed, 0);
        await logs.cancel();
      },
    );
    test('$op: completed abort dispatches nothing', () async {
      var sent = 0;
      final transport = MockClient((r) async {
        sent++;
        return response(op);
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
        call(client, op, abort: abort.future),
        throwsA(isA<AbortedException>()),
      );
      expect(sent, 0);
    });
    test(
      '$op: HTTP error retains explicit body but diagnostics are private',
      () async {
        final transport = MockClient(
          (r) async => http.Response(
            jsonEncode({
              'error': {
                'type': 'invalid_request_error',
                'code': 'conflict',
                'message': 'PRIVATE-error',
                'param': null,
              },
            }),
            409,
          ),
        );
        final client = OpenAIClient.withApiKey(
          'synthetic',
          httpClient: transport,
        );
        addTearDown(() {
          client.close();
          transport.close();
        });
        await expectLater(
          call(client, op),
          throwsA(
            isA<ApiException>().having(
              (e) => e.toString(),
              'private',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
      },
    );
  }
  for (final op in [
    'fileId',
    'inline',
    'files',
    'artifacts',
    'retrieve',
    'delete',
  ]) {
    test('$op: malformed known JSON fails privately', () async {
      final peer = MockClient(
        (r) async => http.Response(
          '{"object":"PRIVATE-wrong"}',
          op == 'fileId' || op == 'inline' ? 201 : 200,
        ),
      );
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(() {
        client.close();
        peer.close();
      });
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
    });
    test('$op: unexpected success status rejected', () async {
      final peer = MockClient(
        (r) async => http.Response.bytes(
          response(op).bodyBytes,
          op == 'fileId' || op == 'inline' ? 200 : 201,
        ),
      );
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(() {
        client.close();
        peer.close();
      });
      await expectLater(call(client, op), throwsA(isA<ParseException>()));
    });
  }
  for (final streamed in [false, true]) {
    test('empty binary contents survive: streamed=$streamed', () async {
      final peer = MockClient(
        (r) async => http.Response.bytes(
          [],
          200,
          headers: {'content-type': 'application/octet-stream'},
        ),
      );
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(() {
        client.close();
        peer.close();
      });
      final bytes = streamed
          ? await client.agents.sessions.artifacts
                .downloadStream('s', 'a')
                .expand((b) => b)
                .toList()
          : await client.agents.sessions.artifacts.download('s', 'a');
      expect(bytes, isEmpty);
    });
    test(
      'unexpected response stream errors stay private: streamed=$streamed',
      () async {
        final peer = BodyClient(
          Stream<List<int>>.error(StateError('PRIVATE-body-error')),
        );
        final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
        addTearDown(client.close);
        final result = streamed
            ? client.agents.sessions.artifacts.downloadStream('s', 'a').toList()
            : client.agents.sessions.artifacts.download('s', 'a');
        await expectLater(
          result,
          throwsA(
            isA<ConnectionException>()
                .having(
                  (e) => e.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                )
                .having((e) => e.cause, 'explicit cause', isA<StateError>()),
          ),
        );
        expect(peer.closed, 0);
      },
    );
  }
  for (final owned in [false, true]) {
    test('normal binary EOF preserves ownership: owned=$owned', () async {
      final peer = Spy(MockClient((r) async => response('download')));
      final borrowed = Spy(MockClient((r) async => response('download')));
      addTearDown(() {
        peer.inner.close();
        borrowed.inner.close();
      });
      final client = OpenAIClient.withApiKey(
        'synthetic',
        httpClient: owned ? borrowed : peer,
        streamClientFactory: owned ? () => peer : null,
      );
      expect(await client.agents.sessions.artifacts.download('s', 'a'), [
        0,
        255,
        128,
        0,
      ]);
      expect(peer.closed, owned ? 1 : 0);
      expect(borrowed.closed, 0);
      client.close();
      expect(borrowed.closed, 0);
    });
  }
  test(
    'two live pages retain path/order/limit; artifact ID pages and null filters differ',
    () async {
      final capture = <http.Request>[];
      final transport = MockClient((r) async {
        capture.add(r);
        final live = r.url.pathSegments.last == 'files';
        final second = r.url.queryParameters.containsKey(
          live ? 'page' : 'after',
        );
        return http.Response.bytes(
          utf8.encode(
            jsonEncode(
              live
                  ? {
                      'object': 'page',
                      'data': second ? <Object>[] : [file],
                      'next': second ? null : opaque,
                      'has_more': !second,
                    }
                  : {
                      'object': 'list',
                      'data': second ? <Object>[] : [artifact],
                      'first_id': second ? null : opaque,
                      'last_id': second ? null : opaque,
                      'has_more': !second,
                    },
            ),
          ),
          200,
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
      final f = client.agents.environments.files;
      final p = await f.list(
        'e',
        path: '/workspace',
        limit: 1,
        order: AgentListOrder.asc,
      );
      final end = await f.list(
        'e',
        path: '/workspace',
        limit: 1,
        order: AgentListOrder.asc,
        page: p.next,
      );
      expect(end.next, isNull);
      expect(end.hasMore, isFalse);
      expect(end.data, isEmpty);
      expect(capture[1].url.queryParameters, {
        'path': '/workspace',
        'limit': '1',
        'order': 'asc',
        'page': opaque,
      });
      final a = client.agents.sessions.artifacts;
      final first = await a.list('s', limit: 1, environmentId: null);
      final last = await a.list(
        's',
        limit: 1,
        after: first.lastId,
        environmentId: null,
      );
      expect(last.firstId, isNull);
      expect(last.lastId, isNull);
      expect(last.data, isEmpty);
      expect(capture[3].url.queryParameters, {'limit': '1', 'after': opaque});
    },
  );
  test('closed client and reserved/invalid segment guards', () {
    var sent = 0;
    final transport = MockClient((r) async {
      sent++;
      return response('retrieve');
    });
    final client = OpenAIClient.withApiKey('synthetic', httpClient: transport);
    addTearDown(transport.close);
    for (final id in ['', '.', '..']) {
      expect(
        () => client.agents.environments.files.list(id),
        throwsFormatException,
      );
      expect(
        () => client.agents.sessions.artifacts.retrieve('s', id),
        throwsFormatException,
      );
      expect(
        () => client.agents.sessions.artifacts.downloadStream(id, 'a'),
        throwsFormatException,
      );
    }
    for (final limit in [0, 101]) {
      expect(
        () => client.agents.environments.files.list('e', limit: limit),
        throwsFormatException,
      );
    }
    expect(
      () => client.agents.environments.files.list(
        'e',
        order: AgentListOrder.fromJson('future'),
      ),
      throwsFormatException,
    );
    expect(sent, 0);
    client.close();
    expect(() => client.agents.sessions.artifacts, throwsStateError);
  });
  for (final streamed in [false, true]) {
    test(
      'unexpected connector failures stay private: streamed=$streamed',
      () async {
        final peer = FailingClient();
        final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
        addTearDown(client.close);
        final operation = streamed
            ? client.agents.sessions.artifacts.downloadStream('s', 'a').toList()
            : client.agents.sessions.artifacts.download('s', 'a');
        await expectLater(
          operation,
          throwsA(
            isA<ConnectionException>()
                .having(
                  (e) => e.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                )
                .having((e) => e.cause, 'explicit cause', isA<StateError>()),
          ),
        );
      },
    );
  }
  for (final mode in ['send', 'body', 'provider', 'factory']) {
    for (final streamed in [false, true]) {
      for (final error in <OpenAIException>[
        const ConnectionException(message: 'PRIVATE-sdk-message'),
        const ApiException(message: 'PRIVATE-api-message', statusCode: 400),
      ]) {
        test(
          'external SDK exceptions stay private: $mode $streamed ${error.runtimeType}',
          () async {
            final peer = ErrorClient(error);
            final client = OpenAIClient(
              config: OpenAIConfig(
                authProvider: mode == 'provider'
                    ? ErrorAuth(error)
                    : FixtureAuth(),
              ),
              httpClient: mode == 'body'
                  ? BodyClient(Stream<List<int>>.error(error))
                  : peer,
              streamClientFactory: mode == 'factory' ? () => throw error : null,
            );
            addTearDown(client.close);
            final result = streamed
                ? client.agents.sessions.artifacts
                      .downloadStream('s', 'a')
                      .toList()
                : client.agents.sessions.artifacts.download('s', 'a');
            await expectLater(
              result,
              throwsA(
                isA<ConnectionException>()
                    .having(
                      (e) => e.toString(),
                      'private',
                      isNot(contains('PRIVATE')),
                    )
                    .having((e) => e.cause, 'original cause', same(error)),
              ),
            );
          },
        );
      }
    }
  }
  test(
    'binary HTTP error binds privacy to actual route despite foreign response request',
    () async {
      final peer = ForeignResponseClient();
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(client.close);
      await expectLater(
        client.agents.sessions.artifacts.download('s', 'a'),
        throwsA(
          isA<BadRequestException>()
              .having(
                (e) => e.toString(),
                'private',
                isNot(contains('PRIVATE')),
              )
              .having((e) => e.statusCode, 'status', 400)
              .having(
                (e) => e.message,
                'explicit message',
                'PRIVATE-http-message',
              ),
        ),
      );
    },
  );
  for (final streamed in [false, true]) {
    test(
      'synchronous connector subscription errors stay private: $streamed',
      () async {
        final peer = BodyClient(FailingListenStream());
        final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
        addTearDown(client.close);
        final result = streamed
            ? client.agents.sessions.artifacts.downloadStream('s', 'a').toList()
            : client.agents.sessions.artifacts.download('s', 'a');
        await expectLater(
          result,
          throwsA(
            isA<ConnectionException>()
                .having(
                  (e) => e.toString(),
                  'private',
                  isNot(contains('PRIVATE')),
                )
                .having((e) => e.cause, 'explicit cause', isA<StateError>()),
          ),
        );
      },
    );
  }
  for (final status in [201, 204, 206]) {
    test('binary exact 200 rejects $status', () async {
      final transport = MockClient(
        (r) async => http.Response.bytes([0, 255], status),
      );
      final client = OpenAIClient.withApiKey(
        'synthetic',
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      await expectLater(
        client.agents.sessions.artifacts.download('s', 'a'),
        throwsA(isA<ParseException>()),
      );
    });
  }
  test('binary mode rejects JSON content type', () async {
    final transport = MockClient(
      (r) async => http.Response(
        '{}',
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final client = OpenAIClient.withApiKey('synthetic', httpClient: transport);
    addTearDown(() {
      client.close();
      transport.close();
    });
    await expectLater(
      client.agents.sessions.artifacts.download('s', 'a'),
      throwsA(isA<ParseException>()),
    );
  });
  for (final owned in [false, true]) {
    test(
      'cancel before headers releases operation only: owned=$owned',
      () async {
        final peer = PendingClient();
        final borrowed = PendingClient();
        final client = OpenAIClient.withApiKey(
          'synthetic',
          httpClient: owned ? borrowed : peer,
          streamClientFactory: owned ? () => peer : null,
        );
        addTearDown(client.close);
        final sub = client.agents.sessions.artifacts
            .downloadStream('s', 'a')
            .listen((_) {}, onError: (Object e) {});
        await peer.started.future;
        await sub.cancel();
        expect(peer.closed, owned ? 1 : 0);
        expect(borrowed.closed, 0);
        final body = StreamController<List<int>>();
        var canceled = false;
        body.onCancel = () {
          canceled = true;
        };
        peer.pending.complete(
          http.StreamedResponse(
            body.stream,
            200,
            headers: {'content-type': 'application/octet-stream'},
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(canceled, isTrue);
        expect(peer.request.abortTrigger, isNotNull);
        await body.close();
      },
    );
  }
  test(
    'abort during binary body preserves borrowed client and exact prefix',
    () async {
      final body = StreamController<List<int>>();
      var canceled = false;
      body.onCancel = () {
        canceled = true;
      };
      final peer = BodyClient(body.stream);
      final abort = Completer<void>();
      final client = OpenAIClient.withApiKey('synthetic', httpClient: peer);
      addTearDown(client.close);
      final chunks = <List<int>>[];
      final failure = Completer<Object>();
      final sub = client.agents.sessions.artifacts
          .downloadStream('s', 'a', abortTrigger: abort.future)
          .listen(chunks.add, onError: failure.complete);
      await peer.started.future;
      body.add([0, 255]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      abort.complete();
      expect(await failure.future, isA<AbortedException>());
      expect(chunks, [
        [0, 255],
      ]);
      await sub.cancel();
      expect(canceled, isTrue);
      expect(peer.closed, 0);
      await body.close();
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

class PendingClient extends http.BaseClient {
  final started = Completer<void>();
  final pending = Completer<http.StreamedResponse>();
  late http.AbortableRequest request;
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) {
    request = r as http.AbortableRequest;
    started.complete();
    return pending.future;
  }

  @override
  void close() {
    closed++;
  }
}

class BodyClient extends http.BaseClient {
  BodyClient(this.body);
  final Stream<List<int>> body;
  final started = Completer<void>();
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) async {
    started.complete();
    return http.StreamedResponse(
      body,
      200,
      headers: {'content-type': 'application/octet-stream'},
      request: r,
    );
  }

  @override
  void close() {
    closed++;
  }
}

class FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      throw StateError('PRIVATE-connector-context');
}

class ErrorClient extends http.BaseClient {
  ErrorClient(this.error);
  final OpenAIException error;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      throw error;
}

class ErrorAuth implements AuthProvider {
  ErrorAuth(this.error);
  final OpenAIException error;
  @override
  Map<String, String> getHeaders() => throw error;
}

class ForeignResponseClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'error': {
                'type': 'invalid_request_error',
                'code': 'invalid',
                'message': 'PRIVATE-http-message',
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
        headers: {'content-type': 'application/json'},
      );
}

class FailingListenStream extends Stream<List<int>> {
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => throw StateError('PRIVATE-listen');
}
