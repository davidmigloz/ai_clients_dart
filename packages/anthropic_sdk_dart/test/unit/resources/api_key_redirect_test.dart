@TestOn('vm')
library;

import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _fixtureKey = 'local-fixture-key-not-a-secret';
final _request = MessageCreateRequest(
  model: 'claude-fixture',
  maxTokens: 16,
  messages: [InputMessage.user('Fixture only')],
);

void main() {
  final cases = <String, Future<void> Function(AnthropicClient)>{
    'Models buffered GET': (client) async {
      await client.models.retrieve('claude-fixture');
    },
    'Files direct download GET': (client) async {
      await client.files.download(fileId: 'file_fixture');
    },
    'Files multipart POST': (client) async {
      await client.files.uploadBytes(
        bytes: Uint8List.fromList([42]),
        fileName: 'fixture.txt',
      );
    },
    'Skills ZIP GET': (client) async {
      await client.skills.downloadVersion(
        skillId: 'skill_fixture',
        version: 'v1',
      );
    },
    'Skills multipart POST': (client) async {
      await client.skills.create(
        files: [
          SkillFile(path: 'demo/SKILL.md', bytes: Uint8List.fromList([1])),
        ],
      );
    },
    'Messages buffered POST': (client) async {
      await client.messages.create(_request);
    },
    'Messages SSE POST': (client) async {
      await client.messages.createStream(_request).drain<void>();
    },
    'Batch results JSONL GET': (client) async {
      await client.batches.results('msgbatch_fixture').drain<void>();
    },
  };

  for (final host in ['127.0.0.1', 'localhost']) {
    for (final MapEntry(key: route, value: send) in cases.entries) {
      test(
        '$route blocks API-key redirects to another origin at $host',
        () async {
          final origins = await _Origins.create(host);
          addTearDown(origins.close);
          final client = AnthropicClient(
            config: AnthropicConfig(
              baseUrl: origins.url,
              authProvider: const ApiKeyProvider(_fixtureKey),
              retryPolicy: const RetryPolicy(maxRetries: 0),
              timeout: const Duration(seconds: 3),
            ),
          );
          addTearDown(client.close);

          await expectLater(
            send(client),
            throwsA(
              isA<ApiException>()
                  .having(
                    (error) => error.statusCode,
                    'status',
                    route.endsWith('POST') ? 303 : 302,
                  )
                  .having(
                    (error) => error.requestId,
                    'provider request ID',
                    'req_redirect_source',
                  )
                  .having(
                    (error) => error.responseMetadata?.headers,
                    'safe headers',
                    isNot(contains('location')),
                  ),
            ),
          );
          expect(origins.received, isEmpty);
        },
      );
    }
  }

  test('cross-origin standard Authorization is dropped by Dart IO', () async {
    final origins = await _Origins.create('127.0.0.1');
    addTearDown(origins.close);
    final client = AnthropicClient(
      config: AnthropicConfig(
        baseUrl: origins.url,
        defaultHeaders: const {'aUtHoRiZaTiOn': 'Bearer local-fixture'},
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.models.retrieve('claude-fixture'),
      throwsA(isA<ApiException>()),
    );
    expect(origins.received, [
      (method: 'GET', apiKey: null, authorization: null),
    ]);
  });

  test('an explicit mixed-case API key is also protected', () async {
    final origins = await _Origins.create('localhost');
    addTearDown(origins.close);
    final client = AnthropicClient(
      config: AnthropicConfig(
        baseUrl: origins.url,
        defaultHeaders: const {'X-Api-Key': _fixtureKey},
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.models.retrieve('claude-fixture'),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 302),
      ),
    );
    expect(origins.received, isEmpty);
  });

  test('same-origin relative redirects preserve an existing API key', () async {
    final origins = await _Origins.create('127.0.0.1', sameOrigin: true);
    addTearDown(origins.close);
    final client = AnthropicClient(
      config: AnthropicConfig(
        baseUrl: origins.url,
        authProvider: const ApiKeyProvider(_fixtureKey),
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.models.retrieve('claude-fixture'),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 418),
      ),
    );
    await expectLater(
      client.files.uploadBytes(
        bytes: Uint8List.fromList([42]),
        fileName: 'fixture.txt',
      ),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 418),
      ),
    );
    expect(
      origins.received,
      List.filled(2, (method: 'GET', apiKey: _fixtureKey, authorization: null)),
    );
  });

  test('same-origin redirect chain keeps the native hop limit', () async {
    final origin = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    addTearDown(() => origin.close(force: true));
    final paths = <String>[];
    origin.listen((request) async {
      paths.add(request.uri.path);
      await request.drain<void>();
      request.response
        ..statusCode = 302
        ..headers.set('location', '/hop/${paths.length}');
      await request.response.close();
    });
    final client = AnthropicClient(
      config: AnthropicConfig(
        baseUrl: 'http://127.0.0.1:${origin.port}',
        authProvider: const ApiKeyProvider(_fixtureKey),
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
    );
    addTearDown(client.close);

    await expectLater(
      client.models.retrieve('claude-fixture'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 302)
            .having(
              (error) => error.message,
              'message',
              'HTTP redirect limit reached',
            ),
      ),
    );
    expect(paths, [
      '/v1/models/claude-fixture',
      for (var hop = 1; hop <= 5; hop++) '/hop/$hop',
    ]);
  });

  test('an aborted response does not admit another same-origin hop', () async {
    final abort = Completer<void>();
    final requests = <Uri>[];
    final client = AnthropicClient(
      config: const AnthropicConfig(authProvider: ApiKeyProvider(_fixtureKey)),
      httpClient: MockClient((request) async {
        requests.add(request.url);
        abort.complete();
        return http.Response('', 303, headers: {'Location': '/another-hop'});
      }),
    );
    addTearDown(client.close);
    await expectLater(
      client.messages.create(_request, abortTrigger: abort.future),
      throwsA(isA<AbortedException>()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(requests.map((url) => url.path), ['/v1/messages']);
  });
}

class _Origins {
  _Origins(this.origin, this.target, this.received);
  final io.HttpServer origin;
  final io.HttpServer target;
  final List<({String method, String? apiKey, String? authorization})> received;

  String get url => 'http://127.0.0.1:${origin.port}';

  static Future<_Origins> create(
    String targetHost, {
    bool sameOrigin = false,
  }) async {
    final origin = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    final target = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    final received =
        <({String method, String? apiKey, String? authorization})>[];
    Future<void> receive(io.HttpRequest request) async {
      received.add((
        method: request.method,
        apiKey: request.headers.value('x-api-key'),
        authorization: request.headers.value('authorization'),
      ));
      await request.drain<void>();
      request.response
        ..statusCode = 418
        ..headers.contentType = io.ContentType.json
        ..write(
          '{"error":{"type":"invalid_request_error","message":"fixture"}}',
        );
      await request.response.close();
    }

    target.listen(receive);
    origin.listen((request) async {
      if (request.uri.path == '/redirected') {
        await receive(request);
        return;
      }
      await request.drain<void>();
      request.response
        ..statusCode = request.method == 'POST' ? 303 : 302
        ..headers.set(
          'location',
          sameOrigin
              ? '/redirected'
              : 'http://$targetHost:${target.port}/redirected',
        )
        ..headers.set('request-id', 'req_redirect_source');
      await request.response.close();
    });
    return _Origins(origin, target, received);
  }

  Future<void> close() async {
    await origin.close(force: true);
    await target.close(force: true);
  }
}
