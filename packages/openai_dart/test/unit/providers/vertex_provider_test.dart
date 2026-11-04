import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _root = 'https://vertex.invalid/custom/projects/p/locations/l/openai/v1';
const _noRetry = RetryPolicy(maxRetries: 0);

Map<String, dynamic> _response() => {
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'output': <Object?>[],
};

http.Response _ok() => http.Response(jsonEncode(_response()), 200);

CreateResponseRequest _create() => const CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.text('Synthetic request; no cloud call.'),
);

VertexProvider _provider(VertexTokenProvider token, {String baseUrl = _root}) =>
    VertexProvider(baseUrl: baseUrl, tokenProvider: token);

OpenAIConfig _config(
  VertexTokenProvider token, {
  String baseUrl = _root,
  Duration timeout = const Duration(seconds: 2),
  RetryPolicy retryPolicy = _noRetry,
}) => OpenAIConfig.vertex(
  provider: _provider(token, baseUrl: baseUrl),
  timeout: timeout,
  retryPolicy: retryPolicy,
);

void main() {
  group('Vertex definition and regional endpoint factories', () {
    test('builds regional/global and legacy project roots exactly', () {
      expect(
        VertexProvider(
          project: 'legacy.example:project',
          location: 'us-central1',
          tokenProvider: () => 't',
        ).baseUrl,
        'https://us-central1-aiplatform.googleapis.com/v1/projects/legacy.example:project/locations/us-central1/publishers/openai/v1',
      );
      expect(
        VertexProvider(
          project: '_p',
          location: 'global',
          tokenProvider: () => 't',
        ).baseUrl,
        'https://aiplatform.googleapis.com/v1/projects/_p/locations/global/publishers/openai/v1',
      );
      expect(
        _provider(() => 't', baseUrl: 'http://localhost:1234/proxy///').baseUrl,
        'http://localhost:1234/proxy',
      );
      expect(
        VertexProvider(
          baseUrl: _root,
          project: '../ignored',
          location: '?',
          tokenProvider: () => 't',
        ).baseUrl,
        _root,
      );
    });

    test(
      'rejects malformed roots and identifiers without echoing their values',
      () {
        for (final root in [
          'file:///private/secret',
          'https://user:secret@vertex.invalid/v1',
          'https://vertex.invalid/v1?private=secret',
          'https://vertex.invalid/v1#secret',
          'http://aiplatform.googleapis.com/v1',
          'http://googleapis.com./v1',
          'https:///missing-host',
          'https://[invalid',
        ]) {
          expect(
            () => _provider(() => 't', baseUrl: root),
            throwsArgumentError,
          );
        }
        for (final project in [
          '',
          '..',
          '../secret',
          'secret\n',
          'a/b',
          'a?b',
        ]) {
          expect(
            () => VertexProvider(
              project: project,
              location: 'global',
              tokenProvider: () => 't',
            ),
            throwsArgumentError,
          );
        }
        for (final location in ['', 'us/EU', 'US', 'global\n', 'x?y']) {
          expect(
            () => VertexProvider(
              project: 'p',
              location: location,
              tokenProvider: () => 't',
            ),
            throwsArgumentError,
          );
        }
        expect(
          _provider(() => 'private-token').toString(),
          isNot(contains('private')),
        );
      },
    );

    test(
      'regional selections preserve explicit OpenAI auth and do not add defaults',
      () {
        for (final region in OpenAIDataResidency.values) {
          final config = OpenAIConfig.forDataResidency(
            region,
            authProvider: const ApiKeyProvider('fixture'),
            project: 'project',
          );
          expect(config.baseUrl, region.baseUrl);
          expect(config.vertexProvider, isNull);
          expect(config.authProvider, const ApiKeyProvider('fixture'));
          expect(config.organization, isNull);
        }
        expect(OpenAIDataResidency.values.map((r) => r.baseUrl), [
          'https://api.openai.com/v1',
          'https://us.api.openai.com/v1',
          'https://eu.api.openai.com/v1',
          'https://ae.api.openai.com/v1',
        ]);
      },
    );

    test(
      'copy omission/clear/provider selection and equality include provider identity',
      () {
        final first = _config(() => 'first');
        final other = _provider(
          () => 'other',
          baseUrl: 'https://other.invalid/v1',
        );
        expect(first.copyWith(), first);
        expect(first.copyWith().hashCode, first.hashCode);
        final changed = first.copyWith(vertexProvider: other);
        expect(changed.vertexProvider, same(other));
        expect(changed.baseUrl, other.baseUrl);
        expect(changed, isNot(first));
        expect(first.copyWith(vertexProvider: null).vertexProvider, isNull);
        expect(
          first.copyWith(vertexProvider: null).baseUrl,
          'https://api.openai.com/v1',
        );
        expect(
          () => first.copyWith(vertexProvider: 'private-value'),
          throwsArgumentError,
        );
      },
    );

    test('configuration conflicts fail atomically before auth/transport', () {
      var tokens = 0;
      final config = _config(() {
        tokens++;
        return 't';
      });
      final raw = MockClient((_) async => _ok());
      for (final candidate in [
        config.copyWith(baseUrl: 'https://other.invalid/v1'),
        config.copyWith(authProvider: const ApiKeyProvider('private-key')),
        config.copyWith(organization: ''),
        config.copyWith(project: 'p'),
        config.copyWith(timeout: Duration.zero),
        for (final header in [
          'Authorization',
          'API-KEY',
          'X-API-Key',
          'OpenAI-API-Key',
          'OPENAI-Organization',
          'openai-PROJECT',
        ])
          config.copyWith(defaultHeaders: {header: 'private-value'}),
      ]) {
        expect(
          () => OpenAIClient(config: candidate, httpClient: raw),
          throwsArgumentError,
        );
      }
      final client = OpenAIClient(config: config, httpClient: raw);
      final retained = client.responses;
      expect(
        () => client.updateConfig(project: 'conflict'),
        throwsArgumentError,
      );
      expect(client.responses, same(retained));
      expect(client.config, config);
      expect(tokens, 0);
      client.close();
    });
  });

  test(
    'all six lifecycle routes preserve complete API root and query arrays',
    () async {
      final sent = <http.Request>[];
      var tokens = 0;
      final client = OpenAIClient(
        config: _config(() => 'token-${++tokens}'),
        httpClient: MockClient((request) async {
          sent.add(request);
          if (request.url.path.endsWith('/input_items')) {
            return http.Response(
              jsonEncode({
                'object': 'list',
                'data': <Object?>[],
                'has_more': false,
                'first_id': null,
                'last_id': null,
              }),
              200,
            );
          }
          if (request.method == 'POST' &&
              request.url.path.endsWith('/compact')) {
            return http.Response(
              jsonEncode({
                'id': 'compact_fixture',
                'object': 'response.compaction',
                'created_at': 1,
                'output': <Object?>[],
                'usage': {
                  'input_tokens': 1,
                  'output_tokens': 1,
                  'total_tokens': 2,
                },
              }),
              200,
            );
          }
          if (request.method == 'DELETE') {
            return http.Response(
              jsonEncode({
                'id': 'resp_fixture',
                'object': 'response',
                'deleted': true,
              }),
              200,
            );
          }
          return _ok();
        }),
      );
      await client.responses.create(_create());
      await client.responses.retrieve(
        'resp_fixture',
        include: [Include.fileSearchResults],
      );
      await client.responses.cancel('resp_fixture');
      await client.responses.delete('resp_fixture');
      await client.responses.inputItems.list(
        'resp_fixture',
        after: 'cursor',
        include: [Include.fileSearchResults],
      );
      await client.responses.compact(
        const CompactResponseRequest(model: 'fixture-model'),
      );
      expect(sent.map((r) => '${r.method} ${r.url.path}'), [
        'POST ${Uri.parse(_root).path}/responses',
        'GET ${Uri.parse(_root).path}/responses/resp_fixture',
        'POST ${Uri.parse(_root).path}/responses/resp_fixture/cancel',
        'DELETE ${Uri.parse(_root).path}/responses/resp_fixture',
        'GET ${Uri.parse(_root).path}/responses/resp_fixture/input_items',
        'POST ${Uri.parse(_root).path}/responses/compact',
      ]);
      expect(sent[1].url.queryParametersAll['include[]'], [
        'file_search_call.results',
      ]);
      expect(sent[4].url.queryParameters['after'], 'cursor');
      expect(sent.map((r) => r.headers['authorization']), [
        for (var i = 1; i <= 6; i++) 'Bearer token-$i',
      ]);
      for (final request in sent) {
        expect(request.followRedirects, isFalse);
        expect(request.maxRedirects, 0);
        expect(
          request.headers.keys.map((h) => h.toLowerCase()),
          isNot(
            contains(anyOf('openai-project', 'openai-organization', 'api-key')),
          ),
        );
      }
      // Response IDs are opaque; compaction's POST route does not reserve the
      // same text in GET/DELETE or child lifecycle operations.
      await client.responses.retrieve('compact');
      await client.responses.inputItems.list('compact');
      expect(sent[sent.length - 2].url.pathSegments.last, 'compact');
      expect(
        sent.last.url.pathSegments.sublist(
          sent.last.url.pathSegments.length - 2,
        ),
        ['compact', 'input_items'],
      );
      client.close();
    },
  );

  test(
    'concurrent callbacks complete out of order without sharing bearer state',
    () async {
      final callbacks = <Completer<String>>[];
      final sent = <http.Request>[];
      final client = OpenAIClient(
        config: _config(() {
          final token = Completer<String>();
          callbacks.add(token);
          return token.future;
        }),
        httpClient: MockClient((request) async {
          sent.add(request);
          return _ok();
        }),
      );
      final first = client.responses.retrieve('first');
      final second = client.responses.retrieve('second');
      await _until(() => callbacks.length == 2);
      callbacks[1].complete('second-token');
      await second;
      callbacks[0].complete('first-token');
      await first;
      expect(sent.map((r) => r.url.pathSegments.last), ['second', 'first']);
      expect(sent.map((r) => r.headers['authorization']), [
        'Bearer second-token',
        'Bearer first-token',
      ]);
      client.close();
    },
  );

  test(
    'retry acquires a fresh token per attempt and never mutates caller headers',
    () async {
      var tokens = 0;
      final sent = <http.Request>[];
      final client = OpenAIClient(
        config: _config(
          () => 't${++tokens}',
          retryPolicy: const RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration(milliseconds: 1),
            maxDelay: Duration(milliseconds: 1),
            jitter: 0,
          ),
        ),
        httpClient: MockClient((request) async {
          sent.add(request);
          return sent.length == 1
              ? http.Response('{"error":{"message":"wait"}}', 429)
              : _ok();
        }),
      );
      final original = http.Request(
        'GET',
        Uri.parse('$_root/responses/resp_fixture'),
      );
      await client.interceptorChain.execute(original);
      expect(tokens, 2);
      expect(sent.map((r) => r.headers['authorization']), [
        'Bearer t1',
        'Bearer t2',
      ]);
      expect(original.headers.containsKey('authorization'), isFalse);
      client.close();
    },
  );

  test(
    'wrong origins, paths and auth header injection reject before token acquisition',
    () async {
      var tokens = 0;
      var sends = 0;
      final client = OpenAIClient(
        config: _config(() {
          tokens++;
          return 't';
        }),
        httpClient: MockClient((_) async {
          sends++;
          return _ok();
        }),
      );
      for (final url in [
        'https://other.invalid/v1/responses/resp',
        'http://vertex.invalid${Uri.parse(_root).path}/responses/resp',
        '$_root/../responses/resp',
        '$_root/responses/../models',
        '$_root/responses/%2Foutside',
        '$_root/models',
        '$_root/',
        '$_root/responses',
        '$_root/responses/resp/unsupported',
      ]) {
        await expectLater(
          client.interceptorChain.execute(http.Request('GET', Uri.parse(url))),
          throwsA(anyOf(isA<ArgumentError>(), isA<UnsupportedError>())),
        );
      }
      for (final header in [
        'authorization',
        'API-Key',
        'OpenAI-Organization',
        'openai-PROJECT',
        'X-API-Key',
        'OpenAI-API-Key',
      ]) {
        final request = http.Request('GET', Uri.parse('$_root/responses/resp'))
          ..headers[header] = 'private-value';
        await expectLater(
          client.interceptorChain.execute(request),
          throwsArgumentError,
        );
      }
      expect(tokens, 0);
      expect(sends, 0);
      client.close();
    },
  );

  test(
    'unsupported resources and Responses WebSocket reject before any callback',
    () async {
      var tokens = 0;
      var connects = 0;
      final client = OpenAIClient(
        config: _config(() {
          tokens++;
          return 't';
        }),
        httpClient: MockClient((_) async => _ok()),
      );
      for (final getter in <Object Function()>[
        () => client.models,
        () => client.chat,
        () => client.agents,
        () => client.audio,
        () => client.images,
        () => client.live,
        () => client.realtime,
        () => client.realtimeSessions,
        () => client.beta,
      ]) {
        expect(getter, throwsUnsupportedError);
      }
      expect(
        () => client.responses.connect(
          connector: (uri, {headers}) {
            connects++;
            throw StateError('must not dial');
          },
        ),
        throwsUnsupportedError,
      );
      await expectLater(client.responses.list(), throwsUnsupportedError);
      expect(tokens, 0);
      expect(connects, 0);
      client.close();
    },
  );

  test(
    'timeout discards late credentials without a delayed HTTP dispatch',
    () async {
      final token = Completer<String>();
      var calls = 0;
      var sends = 0;
      final client = OpenAIClient(
        config: _config(() {
          calls++;
          return token.future;
        }, timeout: const Duration(milliseconds: 20)),
        httpClient: MockClient((_) async {
          sends++;
          return _ok();
        }),
      );
      await expectLater(
        client.responses.create(_create()),
        throwsA(isA<RequestTimeoutException>()),
      );
      expect(calls, 1);
      token.complete('late-token');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(sends, 0);
      client.close();
    },
  );

  test(
    'abort discards late credentials and already-completed abort skips callback',
    () async {
      final token = Completer<String>();
      final abort = Completer<void>();
      var calls = 0;
      var sends = 0;
      final client = OpenAIClient(
        config: _config(() {
          calls++;
          return token.future;
        }),
        httpClient: MockClient((_) async {
          sends++;
          return _ok();
        }),
      );
      final pending = client.responses.create(
        _create(),
        abortTrigger: abort.future,
      );
      final assertion = expectLater(pending, throwsA(isA<AbortedException>()));
      await _until(() => calls == 1);
      abort.complete();
      await assertion;
      token.complete('late-token');
      await Future<void>.delayed(Duration.zero);
      expect(sends, 0);
      await expectLater(
        client.responses.create(_create(), abortTrigger: Future<void>.value()),
        throwsA(isA<AbortedException>()),
      );
      expect(calls, 1);
      expect(sends, 0);
      client.close();
    },
  );

  test(
    'client closure promptly aborts an unresolved credential future without closing the pool',
    () async {
      final token = Completer<String>();
      var calls = 0;
      final raw = _StreamClient();
      final client = OpenAIClient(
        config: _config(() {
          calls++;
          return token.future;
        }),
        httpClient: raw,
      );
      final pending = client.responses.create(_create());
      final assertion = expectLater(pending, throwsA(isA<AbortedException>()));
      await _until(() => calls == 1);
      client.close();
      await assertion.timeout(const Duration(seconds: 1));
      expect(raw.closes, 0);
      token.complete('late');
      await Future<void>.delayed(Duration.zero);
      expect(raw.sent, isEmpty);
    },
  );

  test(
    'client close reaches retained generations and pending dedicated streams',
    () async {
      final tokens = <Completer<String>>[];
      Future<String> callback() {
        final token = Completer<String>();
        tokens.add(token);
        return token.future;
      }

      final shared = _StreamClient();
      final dedicated = _StreamClient();
      final client = OpenAIClient(
        config: _config(callback),
        httpClient: shared,
        streamClientFactory: () => dedicated,
      );
      final first = expectLater(
        client.responses.retrieve('first'),
        throwsA(isA<AbortedException>()),
      );
      await _until(() => tokens.length == 1);
      client.updateConfig(
        vertexProvider: _provider(callback, baseUrl: 'https://new.invalid/v1'),
      );
      final second = expectLater(
        client.responses.retrieve('second'),
        throwsA(isA<AbortedException>()),
      );
      final stream = expectLater(
        client.responses
            .createStream(_create(), abortTrigger: Completer<void>().future)
            .toList(),
        throwsA(isA<AbortedException>()),
      );
      await _until(() => tokens.length == 3);
      client.close();
      await Future.wait([
        first,
        second,
        stream,
      ]).timeout(const Duration(seconds: 1));
      expect(shared.closes, 0);
      expect(dedicated.closes, 1);
      for (final token in tokens) {
        token.complete('late');
      }
      await Future<void>.delayed(Duration.zero);
      expect(shared.sent, isEmpty);
      expect(dedicated.sent, isEmpty);
    },
  );

  test(
    'hostile dedicated close cannot leak its error or strand later adapters',
    () async {
      final tokens = <Completer<String>>[];
      Future<String> callback() {
        final token = Completer<String>();
        tokens.add(token);
        return token.future;
      }

      final shared = _StreamClient();
      final dedicated = _HostileCloseClient();
      final client = OpenAIClient(
        config: _config(callback),
        httpClient: shared,
        streamClientFactory: () => dedicated,
      );
      final stream = expectLater(
        client.responses
            .createStream(_create(), abortTrigger: Completer<void>().future)
            .toList(),
        throwsA(isA<AbortedException>()),
      );
      await _until(() => tokens.length == 1);
      client.updateConfig(
        vertexProvider: _provider(callback, baseUrl: 'https://new.invalid/v1'),
      );
      final later = expectLater(
        client.responses.retrieve('later'),
        throwsA(isA<AbortedException>()),
      );
      await _until(() => tokens.length == 2);
      expect(client.close, returnsNormally);
      await Future.wait([stream, later]).timeout(const Duration(seconds: 1));
      expect(shared.closes, 0);
      expect(dedicated.closes, 1);
      client.close();
      expect(dedicated.closes, 1);
      for (final token in tokens) {
        token.complete('late');
      }
      await Future<void>.delayed(Duration.zero);
      expect(shared.sent, isEmpty);
      expect(dedicated.sent, isEmpty);
    },
  );

  test(
    'logical close ends idle buffered and SSE bodies without transport cooperation',
    () async {
      final raw = _IdleBodyClient();
      final client = OpenAIClient(config: _config(() => 't'), httpClient: raw);
      final buffered = expectLater(
        client.responses.create(_create()),
        throwsA(isA<AbortedException>()),
      );
      final streaming = expectLater(
        client.responses.createStream(_create()).toList(),
        throwsA(isA<AbortedException>()),
      );
      await _until(() => raw.listeners == 2);
      client.close();
      await Future.wait([
        buffered,
        streaming,
      ]).timeout(const Duration(seconds: 1));
      expect(raw.cancellations, 2);
      expect(raw.closes, 0);
      raw.close();
      expect(raw.closes, 1);
    },
  );

  test(
    'synchronous callback elapsed time cannot evade the authentication budget',
    () async {
      var sends = 0;
      final client = OpenAIClient(
        config: _config(() {
          final clock = Stopwatch()..start();
          while (clock.elapsedMilliseconds < 15) {
            /* synthetic blocking callback */
          }
          return 'late';
        }, timeout: const Duration(milliseconds: 5)),
        httpClient: MockClient((_) async {
          sends++;
          return _ok();
        }),
      );
      await expectLater(
        client.responses.create(_create()),
        throwsA(isA<RequestTimeoutException>()),
      );
      expect(sends, 0);
      client.close();
    },
  );

  test(
    'invalid tokens and callback exceptions are sanitized without HTTP or retry',
    () async {
      var sends = 0;
      final raw = MockClient((_) async {
        sends++;
        return _ok();
      });
      for (final token in ['', 'has space', 'a\nb', 'a\tb', 'é', '\u007f']) {
        final client = OpenAIClient(
          config: _config(() => token),
          httpClient: raw,
        );
        await expectLater(
          client.responses.create(_create()),
          throwsA(isA<VertexAuthenticationException>()),
        );
        client.close();
      }
      var callbacks = 0;
      final client = OpenAIClient(
        config: _config(() {
          callbacks++;
          return Future<String>.error(StateError('private-key-material'));
        }),
        httpClient: raw,
      );
      try {
        await client.responses.retrieve('resp');
        fail('expected auth failure');
      } on VertexAuthenticationException catch (error) {
        expect(error.toString(), isNot(contains('private-key-material')));
      }
      expect(callbacks, 1);
      expect(sends, 0);
      client.close();
    },
  );

  test(
    'runtime updates preserve retained providers and pending request generations',
    () async {
      final firstToken = Completer<String>();
      var firstCalls = 0;
      final sent = <http.Request>[];
      final client = OpenAIClient(
        config: _config(() {
          firstCalls++;
          return firstToken.future;
        }),
        httpClient: MockClient((request) async {
          sent.add(request);
          return _ok();
        }),
      );
      final retained = client.responses;
      final oldPending = retained.retrieve('old');
      await _until(() => firstCalls == 1);
      client.updateConfig(
        vertexProvider: _provider(
          () => 'new-token',
          baseUrl: 'https://new.invalid/root',
        ),
      );
      await client.responses.retrieve('new');
      firstToken.complete('old-token');
      await oldPending;
      await retained.retrieve('retained');
      expect(sent.map((r) => r.url.host), [
        'new.invalid',
        'vertex.invalid',
        'vertex.invalid',
      ]);
      expect(sent.map((r) => r.headers['authorization']), [
        'Bearer new-token',
        'Bearer old-token',
        'Bearer old-token',
      ]);
      client.updateConfig(
        vertexProvider: null,
        authProvider: const ApiKeyProvider('openai-token'),
      );
      expect(client.config.baseUrl, 'https://api.openai.com/v1');
      await client.responses.retrieve('ordinary');
      expect(sent.last.headers['authorization'], 'Bearer openai-token');
      expect(sent.last.url.host, 'api.openai.com');
      client.close();
    },
  );

  test(
    'SSE uses per-request credentials with borrowed/dedicated ownership',
    () async {
      var tokens = 0;
      final shared = _StreamClient();
      final dedicated = _StreamClient();
      final client = OpenAIClient(
        config: _config(() => 'stream-${++tokens}'),
        httpClient: shared,
        streamClientFactory: () => dedicated,
      );
      await client.responses.createStream(_create()).toList();
      expect(shared.sent.single.headers['authorization'], 'Bearer stream-1');
      expect(shared.closes, 0);
      await client.responses
          .createStream(_create(), abortTrigger: Completer<void>().future)
          .toList();
      expect(dedicated.sent.single.headers['authorization'], 'Bearer stream-2');
      expect(dedicated.closes, 1);
      client.close();
      expect(shared.closes, 0);
      expect(dedicated.closes, 1);
    },
  );

  test(
    'a stream factory returning the borrowed pool cannot close that pool',
    () async {
      final shared = _StreamClient();
      final client = OpenAIClient(
        config: _config(() => 't'),
        httpClient: shared,
        streamClientFactory: () => shared,
      );
      await client.responses
          .createStream(_create(), abortTrigger: Completer<void>().future)
          .toList();
      await client.responses.createStream(_create()).toList();
      expect(shared.sent, hasLength(2));
      expect(shared.closes, 0);
      client.close();
      expect(shared.closes, 0);
    },
  );

  test(
    'SSE timeout/abort while auth is pending never opens a delayed stream',
    () async {
      final pendingTokens = <Completer<String>>[];
      final raw = _StreamClient();
      final client = OpenAIClient(
        config: _config(() {
          final token = Completer<String>();
          pendingTokens.add(token);
          return token.future;
        }, timeout: const Duration(milliseconds: 20)),
        httpClient: raw,
      );
      await expectLater(
        client.responses.createStream(_create()).toList(),
        throwsA(isA<RequestTimeoutException>()),
      );
      pendingTokens[0].complete('late-timeout');
      final abort = Completer<void>();
      final events = client.responses
          .createStream(_create(), abortTrigger: abort.future)
          .toList();
      final assertion = expectLater(events, throwsA(isA<AbortedException>()));
      await _until(() => pendingTokens.length == 2);
      abort.complete();
      await assertion;
      pendingTokens[1].complete('late-abort');
      await Future<void>.delayed(Duration.zero);
      expect(raw.sent, isEmpty);
      expect(raw.closes, 0);
      client.close();
    },
  );

  test(
    'credential-bearing transport and body exceptions have safe diagnostics',
    () async {
      final raw = _FailingClient();
      final client = OpenAIClient(
        config: _config(() => 'private-token'),
        httpClient: raw,
      );
      for (final bodyError in [false, true]) {
        raw.bodyError = bodyError;
        try {
          await client.responses.create(_create());
          fail('expected transport failure');
        } on http.ClientException catch (error) {
          expect(error.toString(), isNot(contains('private-token')));
        }
      }
      client.close();
    },
  );
}

class _StreamClient extends http.BaseClient {
  final sent = <http.BaseRequest>[];
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sent.add(request);
    await request.finalize().drain<void>();
    return http.StreamedResponse(
      Stream.value(utf8.encode('data: {"type":"fixture"}\n\ndata: [DONE]\n\n')),
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  }

  @override
  void close() {
    closes++;
  }
}

class _HostileCloseClient extends _StreamClient {
  @override
  void close() {
    super.close();
    throw StateError('private-google-close-failure');
  }
}

class _IdleBodyClient extends http.BaseClient {
  int listeners = 0;
  int cancellations = 0;
  int closes = 0;
  final bodies = <StreamController<List<int>>>[];
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await request.finalize().drain<void>();
    // Intentionally ignore Abortable and never emit a body chunk. Cancellation
    // also never settles, to prove the public result does not await the peer.
    final body = StreamController<List<int>>(
      onListen: () {
        listeners++;
      },
      onCancel: () {
        cancellations++;
        return Completer<void>().future;
      },
    );
    bodies.add(body);
    return http.StreamedResponse(
      body.stream,
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  }

  @override
  void close() {
    closes++;
    for (final body in bodies) {
      body.close().ignore();
    }
  }
}

class _FailingClient extends http.BaseClient {
  bool bodyError = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await request.finalize().drain<void>();
    if (bodyError) {
      return http.StreamedResponse(
        Stream.error(StateError('private-token')),
        200,
      );
    }
    throw http.ClientException('private-token');
  }

  @override
  void close() {}
}

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 1000; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Synthetic fixture did not settle.');
}
