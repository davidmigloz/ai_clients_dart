import 'dart:async' show Completer, StreamController;

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/files/files_resource_stub.dart'
    as stub;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const _bytes = [0, 129, 255, 10];
const _generated = 'generatedFiles/media-fixture';

GoogleAIClient _client(
  http.Client transport, {
  GoogleAIConfig config = const GoogleAIConfig(),
}) {
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

void main() {
  for (final version in [ApiVersion.v1, ApiVersion.v1beta]) {
    test(
      'downloads generated Files bytes with ${version.value} media routing',
      () async {
        final transport = MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.path,
            '/${version.value}/files/media-fixture:download',
          );
          expect(request.url.queryParameters, {
            'alt': 'media',
            'key': 'fixture-key',
          });
          expect(request.headers['accept'], '*/*');
          expect(request.followRedirects, isFalse);
          return http.Response.bytes(_bytes, 200);
        });
        final client = _client(
          transport,
          config: GoogleAIConfig(
            apiVersion: version,
            authProvider: const ApiKeyProvider('fixture-key'),
            defaultQueryParams: const {'alt': 'json'},
          ),
        );
        expect(
          await client.files.download(name: 'files/media-fixture'),
          _bytes,
        );
        expect(await client.files.download(name: 'media-fixture'), _bytes);
      },
    );
  }

  test('retains the configured Files download version on gateways', () async {
    final client = _client(
      MockClient((request) async {
        expect(request.url.host, 'gateway.example');
        expect(request.url.path, '/v1beta1/files/media-fixture:download');
        expect(request.url.queryParameters, {'alt': 'media'});
        return http.Response.bytes(_bytes, 200);
      }),
      config: const GoogleAIConfig(
        baseUrl: 'https://gateway.example',
        apiVersion: ApiVersion.v1beta1,
      ),
    );

    expect(await client.files.download(name: 'files/media-fixture'), _bytes);
    await expectLater(
      client.generatedFiles.download(name: _generated),
      throwsUnsupportedError,
    );
  });

  test(
    'retains generatedFiles metadata and returns raw media separately',
    () async {
      final level = Logger.root.level;
      Logger.root.level = Level.FINE;
      addTearDown(() => Logger.root.level = level);
      final logs = <LogRecord>[];
      final listener = Logger.root.onRecord.listen(logs.add);
      addTearDown(listener.cancel);
      final calls = <Uri>[];
      final client = _client(
        MockClient((request) async {
          calls.add(request.url);
          expect(request.url.path, '/v1beta/$_generated');
          if (request.url.queryParameters['alt'] == 'media') {
            return http.Response.bytes(_bytes, 200);
          }
          return http.Response('{"name":"$_generated"}', 200);
        }),
      );
      expect(
        (await client.generatedFiles.get(name: _generated)).name,
        _generated,
      );
      expect(await client.generatedFiles.download(name: _generated), _bytes);
      expect(calls.map((call) => call.queryParameters), [
        isEmpty,
        {'alt': 'media'},
      ]);
      final bodyLogs = logs.where(
        (record) => record.message.startsWith('Body:'),
      );
      expect(bodyLogs, hasLength(1));
      expect(bodyLogs.single.message, contains(_generated));
    },
  );

  test(
    'uses the same binary API on the fallback Files implementation',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.path, '/v1beta/files/media-fixture:download');
        expect(request.url.queryParameters, {'alt': 'media'});
        return http.Response.bytes(_bytes, 200);
      });
      addTearDown(transport.close);
      const config = GoogleAIConfig();
      final files = stub.FilesResource(
        config: config,
        httpClient: transport,
        interceptorChain: InterceptorChain(
          interceptors: const [],
          httpClient: transport,
        ),
        requestBuilder: const RequestBuilder(config: config),
      );
      expect(await files.download(name: 'media-fixture'), _bytes);
    },
  );

  test(
    'uses only the signed URL for redirected media and omits its diagnostics',
    () async {
      const signed =
          'https://storage.example/download?signature=signed-fixture';
      final level = Logger.root.level;
      Logger.root.level = Level.FINE;
      addTearDown(() => Logger.root.level = level);
      final logs = <LogRecord>[];
      final listener = Logger.root.onRecord.listen(logs.add);
      addTearDown(listener.cancel);
      var hits = 0;
      final client = _client(
        MockClient((request) async {
          expect(request.followRedirects, isFalse);
          if (hits++ == 0) {
            expect(request.headers['authorization'], 'Bearer fixture-token');
            expect(request.headers['x-gateway'], 'gateway-fixture');
            expect(request.url.queryParameters, {
              'alt': 'media',
              'tenant': 'gateway-fixture',
            });
            return http.Response('', 307, headers: {'location': signed});
          }
          expect(request.url.toString(), signed);
          expect(request.headers.keys.map((key) => key.toLowerCase()), [
            'accept',
          ]);
          expect(request.headers['accept'], '*/*');
          throw http.ClientException('Could not download $signed', request.url);
        }),
        config: const GoogleAIConfig(
          authProvider: BearerTokenProvider('fixture-token'),
          defaultHeaders: {'X-Gateway': 'gateway-fixture'},
          defaultQueryParams: {'tenant': 'gateway-fixture'},
          logLevel: Level.FINE,
        ),
      );
      await expectLater(
        client.generatedFiles.download(name: _generated),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'transport status', 0)
              .having(
                (e) => e.toString(),
                'diagnostics',
                isNot(contains(signed)),
              ),
        ),
      );
      expect(hits, 2);
      expect(
        logs.any((record) => record.message.startsWith('RESPONSE')),
        isTrue,
      );
      expect(
        logs.map((record) => '${record.message} ${record.error}').join(' '),
        isNot(contains('signed-fixture')),
      );
    },
  );

  test(
    'rejects non-HTTPS redirects from HTTPS and excludes their details',
    () async {
      var calls = 0;
      final client = _client(
        MockClient((request) async {
          calls++;
          return http.Response(
            '',
            302,
            headers: {
              'location': 'http://storage.example/path?sig=masked-fixture',
            },
          );
        }),
      );
      await expectLater(
        client.files.download(name: 'media-fixture'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 302)
              .having(
                (e) => e.toString(),
                'diagnostics',
                isNot(contains('masked-fixture')),
              ),
        ),
      );
      expect(calls, 1);
    },
  );

  test(
    'removes aborted transport URLs before logging and exposing the error',
    () async {
      const key = 'opaque-fixture-key';
      final level = Logger.root.level;
      Logger.root.level = Level.FINE;
      addTearDown(() => Logger.root.level = level);
      final logs = <LogRecord>[];
      final listener = Logger.root.onRecord.listen(logs.add);
      addTearDown(listener.cancel);
      final client = _client(
        MockClient(
          (request) async => throw http.RequestAbortedException(request.url),
        ),
        config: const GoogleAIConfig(
          authProvider: ApiKeyProvider(key),
          logLevel: Level.FINE,
        ),
      );
      await expectLater(
        client.files.download(name: 'media-fixture'),
        throwsA(
          isA<AbortedException>()
              .having((e) => e.reason, 'reason', isNull)
              .having((e) => e.cause, 'cause', isNull),
        ),
      );
      final loggedAbort = logs
          .map((record) => record.error)
          .whereType<AbortedException>();
      expect(loggedAbort, isNotEmpty);
      expect(loggedAbort.map((error) => error.reason), everyElement(isNull));
      expect(
        logs.map((record) => record.message).join(' '),
        isNot(contains(key)),
      );
    },
  );

  test('rejects invalid names and unsupported backends or versions', () async {
    final transport = MockClient((_) async => fail('Unexpected request'));
    final vertex = _client(
      transport,
      config: GoogleAIConfig.vertexAI(
        projectId: 'fixture',
        authProvider: const BearerTokenProvider('fixture-token'),
      ),
    );
    await expectLater(
      vertex.files.download(name: 'fixture'),
      throwsUnsupportedError,
    );
    await expectLater(
      vertex.generatedFiles.download(name: 'fixture'),
      throwsUnsupportedError,
    );
    final stable = _client(
      transport,
      config: const GoogleAIConfig(apiVersion: ApiVersion.v1),
    );
    await expectLater(
      stable.generatedFiles.download(name: _generated),
      throwsUnsupportedError,
    );
    for (final name in ['', '../fixture', 'https://other.example/fixture']) {
      await expectLater(stable.files.download(name: name), throwsArgumentError);
    }
  });

  test('cancels a pending signed media response', () async {
    final listening = Completer<void>();
    final cancelled = Completer<void>();
    final abort = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: listening.complete,
      onCancel: cancelled.complete,
    );
    addTearDown(body.close);
    var calls = 0;
    final client = _client(
      MockClient.streaming((request, bytes) async {
        await bytes.drain<void>();
        if (calls++ == 0) {
          return http.StreamedResponse(
            const Stream.empty(),
            307,
            headers: const {'location': 'https://media.example/fixture'},
          );
        }
        return http.StreamedResponse(body.stream, 200);
      }),
    );
    final result = expectLater(
      client.files.download(name: 'media-fixture', abortTrigger: abort.future),
      throwsA(isA<AbortedException>()),
    );
    await listening.future;
    abort.complete();
    await result;
    await cancelled.future;
    expect(calls, 2);
  });
}
