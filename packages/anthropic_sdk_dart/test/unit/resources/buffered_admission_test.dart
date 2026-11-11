import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _deadline = Duration(seconds: 2);
final _request = MessageCreateRequest(
  model: 'claude-fixture',
  maxTokens: 32,
  messages: [InputMessage.user('Hello')],
);
final _bytes = Uint8List.fromList([0, 255, 128]);
final _skillFiles = [SkillFile(path: 'fixture/SKILL.md', bytes: _bytes)];

void main() {
  test('buffered abort during auth rejects late transport admission', () async {
    final auth = _GatedAuth();
    final abort = Completer<void>();
    final transport = _Transport();
    final client = _client(transport, auth: auth);
    addTearDown(client.close);
    addTearDown(auth.release);

    final request = client.messages.create(
      _request,
      abortTrigger: abort.future,
    );
    final aborted = expectLater(
      request.timeout(_deadline),
      throwsA(
        isA<AbortedException>()
            .having(
              (error) => error.stage,
              'stage',
              AbortionStage.beforeRequest,
            )
            .having(
              (error) => error.correlationId,
              'correlationId',
              'local-id',
            ),
      ),
    );
    await auth.entered.future.timeout(_deadline);
    abort.complete();
    await aborted;
    expect(transport.requests, isEmpty);

    auth.release();
    await Future<void>.delayed(Duration.zero);
    expect(transport.requests, isEmpty);

    final message = await client.messages.create(_request);
    expect(message.id, 'msg_fixture');
    expect(transport.requests.single.headers['x-api-key'], 'fixture-key');
    expect(transport.requests.single.headers['X-Request-ID'], 'local-id');
    expect(transport.closeCount, 0);
  });

  for (final deferAbort in [false, true]) {
    test(
      'buffered abort prevents dispatch when credentials resolve in the same '
      'event turn (deferAbort=$deferAbort)',
      () async {
        final auth = _GatedAuth();
        final abort = Completer<void>();
        final transport = _Transport();
        final client = _client(transport, auth: auth);
        addTearDown(client.close);
        addTearDown(auth.release);

        final aborted = expectLater(
          client.messages
              .create(_request, abortTrigger: abort.future)
              .timeout(_deadline),
          throwsA(
            isA<AbortedException>()
                .having(
                  (error) => error.stage,
                  'stage',
                  AbortionStage.beforeRequest,
                )
                .having(
                  (error) => error.correlationId,
                  'correlationId',
                  'local-id',
                ),
          ),
        );
        await auth.entered.future.timeout(_deadline);
        auth.release();
        if (deferAbort) {
          scheduleMicrotask(abort.complete);
        } else {
          abort.complete();
        }
        await aborted;
        expect(transport.requests, isEmpty);

        expect((await client.messages.create(_request)).id, 'msg_fixture');
        expect(transport.requests, hasLength(1));
        expect(transport.closeCount, 0);
      },
    );
  }

  test(
    'already-completed buffered abort prevents dispatch without auth',
    () async {
      final transport = _Transport();
      final client = _client(transport);
      addTearDown(client.close);

      await expectLater(
        client.messages.create(_request, abortTrigger: Future<void>.value()),
        throwsA(
          isA<AbortedException>().having(
            (error) => error.stage,
            'stage',
            AbortionStage.beforeRequest,
          ),
        ),
      );
      expect(transport.requests, isEmpty);
      expect((await client.messages.create(_request)).id, 'msg_fixture');
      expect(transport.closeCount, 0);
    },
  );

  test('buffered close during authentication rejects late dispatch', () async {
    final auth = _GatedAuth();
    final transport = _Transport();
    final client = _client(transport, auth: auth);
    addTearDown(client.close);
    addTearDown(auth.release);

    final rejected = expectLater(
      client.messages.create(_request).timeout(_deadline),
      throwsStateError,
    );
    await auth.entered.future.timeout(_deadline);
    client.close();
    auth.release();
    await rejected;
    expect(transport.requests, isEmpty);
    expect(transport.closeCount, 0);
  });

  test('closing during backoff prevents a new buffered attempt', () async {
    const retryDelay = Duration(seconds: 12);
    var backoffs = 0;
    var attempts = 0;
    final transport = _Transport(
      respond: (_) async {
        if (attempts++ == 0) return http.Response('Rate limited', 429);
        return http.Response(
          '{"input_tokens":7}',
          200,
          headers: {'content-type': 'application/json'},
        );
      },
    );
    final client = _client(
      transport,
      retryPolicy: const RetryPolicy(
        maxRetries: 1,
        initialDelay: retryDelay,
        jitter: 0,
      ),
    );
    addTearDown(client.close);
    final request = TokenCountRequest(
      model: _request.model,
      messages: _request.messages,
    );
    final response = runZoned(
      () => client.messages.countTokens(request),
      zoneSpecification: ZoneSpecification(
        createTimer: (self, parent, zone, delay, callback) {
          if (delay == retryDelay) {
            backoffs++;
            client.close();
            return parent.createTimer(zone, Duration.zero, callback);
          }
          return parent.createTimer(zone, delay, callback);
        },
      ),
    );
    await expectLater(response.timeout(_deadline), throwsStateError);
    expect(backoffs, 1);
    expect(transport.requests, hasLength(1));
    expect(transport.closeCount, 0);

    final sibling = _client(transport);
    addTearDown(sibling.close);
    expect((await sibling.messages.countTokens(request)).inputTokens, 7);
    expect(transport.requests, hasLength(2));
  });

  final streams =
      <String, Stream<Object?> Function(AnthropicClient, Future<void>?)>{
        'Messages SSE': (client, abort) =>
            client.messages.createStream(_request, abortTrigger: abort),
        'Batch JSONL': (client, abort) => client.messages.batches.results(
          'msgbatch_fixture',
          abortTrigger: abort,
        ),
      };

  for (final stream in streams.entries) {
    test('${stream.key} rejects close during authentication', () async {
      final auth = _GatedAuth();
      final transport = _Transport();
      final client = _client(transport, auth: auth);
      addTearDown(client.close);
      addTearDown(auth.release);

      final rejected = expectLater(
        stream.value(client, null).toList().timeout(_deadline),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Client has been closed',
          ),
        ),
      );
      await auth.entered.future.timeout(_deadline);
      client.close();
      auth.release();
      await rejected;
      expect(transport.requests, isEmpty);
      expect(transport.closeCount, 0);
    });

    for (final deferAbort in [false, true]) {
      test('${stream.key} rejects a same-turn abort before dispatch '
          '(deferAbort=$deferAbort)', () async {
        final auth = _GatedAuth();
        final abort = Completer<void>();
        final transport = _Transport(
          respond: (_) async => http.Response('', 200),
        );
        final client = _client(transport, auth: auth);
        addTearDown(client.close);
        addTearDown(auth.release);

        final rejected = expectLater(
          stream.value(client, abort.future).toList().timeout(_deadline),
          throwsA(isA<AbortedException>()),
        );
        await auth.entered.future.timeout(_deadline);
        auth.release();
        if (deferAbort) {
          scheduleMicrotask(abort.complete);
        } else {
          abort.complete();
        }
        await rejected;
        expect(transport.requests, isEmpty);
        expect(transport.closeCount, 0);

        expect(await stream.value(client, null).toList(), isEmpty);
        expect(transport.requests, hasLength(1));
      });
    }
  }

  group('direct Files and Skills admission', () {
    late Directory directory;
    late File file;
    setUpAll(() {
      directory = Directory.systemTemp.createTempSync('anthropic-admission-');
      file = File('${directory.path}/fixture.txt')..writeAsBytesSync(_bytes);
    });
    tearDownAll(() => directory.deleteSync(recursive: true));

    final operations =
        <String, Future<Object?> Function(AnthropicClient, String)>{
          'Files path upload': (client, path) =>
              client.files.upload(filePath: path),
          'Files byte upload': (client, _) =>
              client.files.uploadBytes(bytes: _bytes, fileName: 'fixture.txt'),
          'Files download': (client, _) =>
              client.files.download(fileId: 'file_fixture'),
          'Skills create': (client, _) =>
              client.skills.create(files: _skillFiles),
          'Skills create version': (client, _) => client.skills.createVersion(
            skillId: 'skill_fixture',
            files: _skillFiles,
          ),
        };

    for (final operation in operations.entries) {
      test('${operation.key} rejects a closed client before I/O', () async {
        final auth = _GatedAuth();
        final transport = _Transport();
        final client = _client(transport, auth: auth)..close();
        addTearDown(auth.release);

        // A missing file distinguishes the lifecycle guard from a disk error.
        await expectLater(
          operation.value(client, '${file.path}.missing').timeout(_deadline),
          throwsStateError,
        );
        expect(auth.entered.isCompleted, isFalse);
        expect(transport.requests, isEmpty);
        expect(transport.closeCount, 0);
      });

      test('${operation.key} rejects close during authentication', () async {
        final auth = _GatedAuth();
        final transport = _Transport();
        final client = _client(transport, auth: auth);
        addTearDown(client.close);
        addTearDown(auth.release);

        final rejected = expectLater(
          operation.value(client, file.path).timeout(_deadline),
          throwsStateError,
        );
        await auth.entered.future.timeout(_deadline);
        client.close();
        auth.release();
        await rejected;
        expect(transport.requests, isEmpty);
        expect(transport.closeCount, 0);

        final sibling = _client(transport);
        addTearDown(sibling.close);
        final result = await operation.value(sibling, file.path);
        expect(result, isNotNull);
        expect(transport.requests, hasLength(1));
      });
    }
  });
}

AnthropicClient _client(
  _Transport transport, {
  AuthProvider? auth,
  RetryPolicy retryPolicy = const RetryPolicy(maxRetries: 0),
}) => AnthropicClient(
  config: AnthropicConfig(
    authProvider: auth,
    defaultHeaders: const {'X-Request-ID': 'local-id'},
    retryPolicy: retryPolicy,
  ),
  httpClient: transport,
);

class _GatedAuth implements AuthProvider {
  final entered = Completer<void>();
  final _credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    if (!entered.isCompleted) entered.complete();
    return _credentials.future;
  }

  void release() {
    if (!_credentials.isCompleted) {
      _credentials.complete(const ApiKeyCredentials('fixture-key'));
    }
  }
}

class _Transport extends http.BaseClient {
  _Transport({this.respond});

  final Future<http.Response> Function(http.Request)? respond;
  final requests = <http.BaseRequest>[];
  int closeCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request);
    return MockClient(respond ?? _respond).send(request);
  }

  @override
  void close() => closeCount++;

  Future<http.Response> _respond(http.Request request) async {
    const date = '2026-11-11T00:00:00Z';
    final Object body;
    switch (request.url.path) {
      case '/v1/messages':
        body = {
          'id': 'msg_fixture',
          'type': 'message',
          'role': 'assistant',
          'content': <Map<String, Object?>>[],
          'model': 'claude-fixture',
          'stop_reason': 'end_turn',
          'stop_sequence': null,
          'usage': {'input_tokens': 3, 'output_tokens': 1},
        };
      case '/v1/files':
        body = {
          'id': 'file_fixture',
          'filename': 'fixture.txt',
          'mime_type': 'text/plain',
          'size_bytes': _bytes.length,
          'created_at': date,
        };
      case '/v1/files/file_fixture/content':
        return http.Response.bytes(
          _bytes,
          200,
          headers: {'content-type': 'application/octet-stream'},
        );
      case '/v1/skills':
        body = {
          'id': 'skill_fixture',
          'display_name': 'Fixture',
          'latest_version_id': 'skillver_fixture',
          'source': {'type': 'custom'},
          'created_at': date,
          'updated_at': date,
        };
      case '/v1/skills/skill_fixture/versions':
        body = {
          'id': 'skillver_fixture',
          'skill_id': 'skill_fixture',
          'name': 'Fixture',
          'description': 'Fixture',
          'created_at': date,
        };
      default:
        throw StateError('Unexpected request path ${request.url.path}');
    }
    return http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
