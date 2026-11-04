import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _session = 'session /?🚀';
const _turn = 'turn_private';
const _path = '/workspace/outputs/private.bin';
Map<String, dynamic> _row({
  Object? id = 'artifact_private',
  String session = _session,
  String turn = _turn,
  String path = _path,
}) => {
  'id': id,
  'object': 'agent.session.artifact',
  'created_at': 1,
  'environment_id': 'environment_expired',
  'path': path,
  'session_id': session,
  'size_bytes': 5,
  'turn_id': turn,
};
http.StreamedResponse _page(
  List<Map<String, dynamic>> rows, {
  bool more = false,
  String? cursor,
}) => http.StreamedResponse(
  Stream.value(
    utf8.encode(
      jsonEncode({
        'object': 'list',
        'data': rows,
        'first_id': null,
        'last_id': cursor,
        'has_more': more,
      }),
    ),
  ),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
OpenAIClient _client(_Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    baseUrl: 'https://fixture.invalid/proxy/v1',
    authProvider: ApiKeyProvider('fixture'),
    timeout: Duration(seconds: 5),
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);
AgentSessionRunResult _result() => AgentSessionRunResult(
  turn: AgentSessionTurn.fromJson(const {
    'object': 'agent.session.turn',
    'id': _turn,
    'session_id': _session,
    'agent_id': 'agent_fixture',
    'subagent_id': null,
    'created_at': 0,
    'started_at': 0,
    'completed_at': 1,
    'status': 'completed',
    'error': null,
    'usage': null,
  }),
  messages: const [],
);
AgentResultArtifacts _artifacts(OpenAIClient client) =>
    AgentResultArtifacts(client: client, result: _result());
Matcher _failure(AgentArtifactSelectionFailure reason) =>
    isA<AgentArtifactSelectionException>().having(
      (error) => error.reason,
      'selection reason',
      reason,
    );

void main() {
  test(
    'lossy opaque query cursors fail before a second page without inventing path restrictions',
    () async {
      for (final invalid in ['\ud800', '\udfff']) {
        final transport = _Client(
          (_) async => _page([], more: true, cursor: invalid),
        );
        final client = _client(transport);
        await expectLater(
          _artifacts(client).find(_path),
          throwsA(_failure(AgentArtifactSelectionFailure.pagination)),
        );
        expect(transport.sends, 1);
        client.close();
      }
      var requests = 0;
      final client = _client(
        _Client((request) async {
          if (++requests == 1) return _page([], more: true, cursor: '..');
          expect(request.url.queryParameters['after'], '..');
          return _page([_row()]);
        }),
      );
      await _artifacts(client).find(_path);
      client.close();
    },
  );

  test(
    'lossy result session IDs reject before lookup and malformed observed artifact IDs never route content',
    () async {
      for (final invalid in ['\ud800', '\udfff']) {
        final transport = _Client((_) async => _page([_row(id: invalid)]));
        final client = _client(transport);
        expect(
          () => AgentResultArtifacts(
            client: client,
            result: AgentSessionRunResult(
              turn: _result().turn.copyWith(sessionId: invalid),
              messages: const [],
            ),
          ),
          throwsFormatException,
        );
        expect(transport.sends, 0);
        await expectLater(
          _artifacts(client).downloadTo(_path, sink: (_) {}),
          throwsFormatException,
        );
        expect(transport.sends, 1);
        client.close();
      }
    },
  );

  test(
    'public completed-result adapter captures actual identity and resource generation',
    () async {
      final requests = <http.BaseRequest>[];
      final client = _client(
        _Client((request) async {
          requests.add(request);
          return _page([_row()]);
        }),
      );
      final artifacts = AgentResultArtifacts(client: client, result: _result());
      client.updateConfig(defaultHeaders: {'x-future': 'new-generation'});
      expect(artifacts.sessionId, _session);
      expect(artifacts.turnId, _turn);
      await artifacts.find(_path);
      expect(requests.single.headers.containsKey('x-future'), isFalse);
      expect(artifacts.toString(), isNot(contains(_session)));
      client.close();
    },
  );

  test(
    'every page uses actual opaque cursor and exact turn/session/path without environment filter',
    () async {
      final requests = <http.BaseRequest>[];
      const cursor = 'opaque /?%🚀';
      final client = _client(
        _Client((request) async {
          requests.add(request);
          if (requests.length == 1) {
            return _page(
              [
                _row(id: null, turn: 'other'),
                _row(id: null, path: '$_path/other'),
                _row(id: null, session: 'other'),
              ],
              more: true,
              cursor: cursor,
            );
          }
          return _page([_row()]);
        }),
      );
      final headers = {'x-fixture': 'snapshot'};
      final pending = _artifacts(
        client,
      ).find(_path, additionalHeaders: headers);
      headers['x-fixture'] = 'changed';
      final selected = await pending;
      expect(selected.id, 'artifact_private');
      expect(selected.environmentId, 'environment_expired');
      expect(requests, hasLength(2));
      expect(requests.last.url.queryParameters, {
        'limit': '100',
        'order': 'asc',
        'after': cursor,
      });
      for (final request in requests) {
        expect(request.method, 'GET');
        expect(request.url.pathSegments[4], _session);
        expect(
          request.url.queryParameters.containsKey('environment_id'),
          isFalse,
        );
        expect(request.headers['openai-beta'], 'agents=v1');
        expect(request.headers['authorization'], 'Bearer fixture');
        expect(request.headers['x-fixture'], 'snapshot');
      }
      client.close();
    },
  );

  test(
    'selection never normalizes paths or silently chooses zero/multiple/legacy matches',
    () async {
      final cases =
          <(List<Map<String, dynamic>>, AgentArtifactSelectionFailure)>[
            ([], AgentArtifactSelectionFailure.notFound),
            (
              [_row(path: '/workspace/outputs/./private.bin')],
              AgentArtifactSelectionFailure.notFound,
            ),
            (
              [_row(), _row(id: 'second')],
              AgentArtifactSelectionFailure.multiple,
            ),
            ([_row(id: null), _row()], AgentArtifactSelectionFailure.multiple),
            (
              [_row(id: null)..['file_id'] = 'cannot-substitute'],
              AgentArtifactSelectionFailure.missingIdentifier,
            ),
            ([_row(id: '')], AgentArtifactSelectionFailure.missingIdentifier),
          ];
      for (final (rows, reason) in cases) {
        final transport = _Client((_) async => _page(rows));
        final client = _client(transport);
        await expectLater(
          _artifacts(client).find(_path),
          throwsA(_failure(reason)),
        );
        expect(transport.sends, 1);
        client.close();
      }
    },
  );

  test(
    'missing/empty/repeated/cyclic cursor fails without inferred row identifiers',
    () async {
      for (final cursors in <List<String?>>[
        [null],
        [''],
        ['a', 'a'],
        ['a', 'b', 'a'],
      ]) {
        var index = 0;
        final transport = _Client(
          (_) async => _page(
            [_row(turn: 'other')],
            more: true,
            cursor: cursors[index++],
          ),
        );
        final client = _client(transport);
        await expectLater(
          _artifacts(client).find(_path),
          throwsA(_failure(AgentArtifactSelectionFailure.pagination)),
        );
        expect(transport.sends, cursors.length);
        client.close();
      }
    },
  );

  test(
    'empty pages may advance with actual cursor and matches are counted across pages',
    () async {
      var count = 0;
      final client = _client(
        _Client((_) async {
          if (++count == 1) return _page([], more: true, cursor: 'empty-page');
          if (count == 2) return _page([_row()], more: true, cursor: 'next');
          return _page([_row(id: null)]);
        }),
      );
      await expectLater(
        _artifacts(client).find(_path),
        throwsA(_failure(AgentArtifactSelectionFailure.multiple)),
      );
      expect(count, 3);
      client.close();
    },
  );

  test(
    'binary chunks are detached/read-only and sink futures apply backpressure',
    () async {
      final bytes = [0, 255, 128, 13, 10];
      final release = Completer<void>();
      final first = Completer<void>();
      var produced = 0;
      Stream<List<int>> source() async* {
        produced++;
        yield bytes;
        produced++;
        yield [42];
      }

      final transport = _Client(
        (request) async => request.url.path.endsWith('/content')
            ? http.StreamedResponse(
                source(),
                200,
                headers: {'content-type': 'application/octet-stream'},
              )
            : _page([_row()]),
      );
      final client = _client(transport);
      final received = <Uint8List>[];
      final pending = _artifacts(client).downloadTo(
        _path,
        sink: (chunk) async {
          received.add(chunk);
          expect(() => chunk[0] = 2, throwsUnsupportedError);
          if (received.length == 1) {
            first.complete();
            await release.future;
          }
        },
      );
      await first.future;
      await Future<void>.delayed(Duration.zero);
      // The shared byte-stream adapter may prefetch one source chunk; it
      // must not invoke another sink until this callback has completed.
      expect(produced, lessThanOrEqualTo(2));
      expect(received, hasLength(1));
      expect(received.single, bytes);
      bytes[0] = 7;
      expect(received.single[0], 0);
      release.complete();
      final selected = await pending;
      expect(selected.id, 'artifact_private');
      expect(received.expand((chunk) => chunk), [0, 255, 128, 13, 10, 42]);
      client.close();
      expect(transport.closes, 0);
    },
  );

  test(
    'sink error cancels upstream and preserves private explicit cause',
    () async {
      var canceled = 0;
      final body = StreamController<List<int>>(
        onCancel: () {
          canceled++;
        },
      );
      final sinkStarted = Completer<void>();
      final client = _client(
        _Client(
          (request) async => request.url.path.endsWith('/content')
              ? http.StreamedResponse(body.stream, 200)
              : _page([_row()]),
        ),
      );
      final cause = StateError('private local filename');
      final pending = _artifacts(client).downloadTo(
        _path,
        sink: (_) {
          sinkStarted.complete();
          throw cause;
        },
      );
      final assertion = expectLater(
        pending,
        throwsA(
          isA<ConnectionException>()
              .having(
                (error) => error.cause,
                'explicit sink cause',
                same(cause),
              )
              .having(
                (error) => error.toString(),
                'private diagnostics',
                isNot(contains('private local filename')),
              ),
        ),
      );
      body.add([1]);
      await sinkStarted.future;
      await assertion;
      await Future<void>.delayed(Duration.zero);
      expect(canceled, 1);
      client.close();
      await body.close();
    },
  );

  test(
    'abort ends never-completing sink promptly and observes its later error',
    () async {
      final zoneErrors = <Object>[];
      await runZonedGuarded(
        () async {
          final body = StreamController<List<int>>();
          final sink = Completer<void>();
          final started = Completer<void>();
          final abort = Completer<void>();
          final client = _client(
            _Client(
              (request) async => request.url.path.endsWith('/content')
                  ? http.StreamedResponse(body.stream, 200)
                  : _page([_row()]),
            ),
          );
          final pending = _artifacts(client).downloadTo(
            _path,
            abortTrigger: abort.future,
            sink: (_) {
              started.complete();
              return sink.future;
            },
          );
          final assertion = expectLater(
            pending,
            throwsA(isA<AbortedException>()),
          );
          body.add([1]);
          await started.future;
          abort.complete();
          await assertion.timeout(const Duration(seconds: 1));
          sink.completeError(StateError('late private sink error'));
          await Future<void>.delayed(Duration.zero);
          client.close();
          await body.close();
        },
        (error, _) {
          zoneErrors.add(error);
        },
      );
      expect(zoneErrors, isEmpty);
    },
  );

  test(
    'lookup-to-content startup abort has one observed failure and no content request',
    () async {
      final zoneErrors = <Object>[];
      await runZonedGuarded(
        () async {
          final transport = _Client((_) async => _page([_row()]));
          final client = _client(transport);
          var sinks = 0;
          await expectLater(
            _artifacts(client).downloadTo(
              _path,
              abortTrigger: _AbortOnSecondWatch(),
              sink: (_) {
                sinks++;
              },
            ),
            throwsA(isA<AbortedException>()),
          );
          await Future<void>.delayed(Duration.zero);
          expect(transport.sends, 1);
          expect(sinks, 0);
          client.close();
        },
        (error, _) {
          zoneErrors.add(error);
        },
      );
      expect(zoneErrors, isEmpty);
    },
  );

  test(
    'content HTTP errors retain exact type/body while automatic strings stay private',
    () async {
      final client = _client(
        _Client(
          (request) async => request.url.path.endsWith('/content')
              ? http.StreamedResponse(
                  Stream.value(
                    utf8.encode('{"error":{"message":"private-output-path"}}'),
                  ),
                  403,
                  headers: {'content-type': 'application/json'},
                )
              : _page([_row()]),
        ),
      );
      await expectLater(
        _artifacts(client).downloadTo(_path, sink: (_) {}),
        throwsA(
          isA<PermissionDeniedException>()
              .having((error) => error.body, 'exact body', {
                'error': {'message': 'private-output-path'},
              })
              .having(
                (error) => error.toString(),
                'private summary',
                isNot(contains('private-output-path')),
              ),
        ),
      );
      client.close();
    },
  );

  test(
    'selection failures have complete value/copy contracts and private summaries',
    () {
      const failure = AgentArtifactSelectionException(
        reason: AgentArtifactSelectionFailure.notFound,
        sessionId: _session,
        turnId: _turn,
        path: _path,
      );
      expect(failure.copyWith(), failure);
      expect(failure.copyWith().hashCode, failure.hashCode);
      for (final changed in [
        failure.copyWith(reason: AgentArtifactSelectionFailure.multiple),
        failure.copyWith(sessionId: 'other'),
        failure.copyWith(turnId: 'other'),
        failure.copyWith(path: 'other'),
      ]) {
        expect(changed, isNot(failure));
      }
      expect(failure.toString(), isNot(contains(_session)));
      expect(failure.toString(), isNot(contains(_turn)));
      expect(failure.toString(), isNot(contains(_path)));
    },
  );
}

class _Client extends http.BaseClient {
  _Client(this.respond);
  final Future<http.StreamedResponse> Function(http.BaseRequest) respond;
  int sends = 0;
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    sends++;
    return respond(request);
  }

  @override
  void close() {
    closes++;
  }
}

class _AbortOnSecondWatch implements Future<void> {
  final _completion = Completer<void>();
  int watches = 0;
  @override
  Future<R> then<R>(FutureOr<R> Function(void) onValue, {Function? onError}) {
    if (++watches == 2) _completion.complete();
    return _completion.future.then(onValue, onError: onError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Only then is used.');
}
