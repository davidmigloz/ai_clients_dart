import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  test('keeps the configured route when listing without a mode', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        baseUrl: 'https://example.com/gateway',
        apiVersion: ApiVersion.v1,
      ),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/gateway/v1/environments');
        expect(request.url.queryParameters, {'page_size': '5'});
        return http.Response('{"environments":[{"id":"env"}]}', 200);
      }),
    );
    addTearDown(client.close);

    expect(
      (await client.environments.list(pageSize: 5)).environments?.single.id,
      'env',
    );
  });

  test('lists environments by compute lifecycle mode', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        authProvider: ApiKeyProvider(
          'test-key',
          placement: AuthPlacement.header,
        ),
        interactionsApiVersion: ApiVersion.v1,
      ),
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1beta/environments');
        expect(request.headers['api-revision'], '2026-05-20');
        expect(request.headers['x-goog-api-key'], 'test-key');
        expect(request.url.queryParameters, {
          'mode': 'self_hosted',
          'page_size': '10',
          'page_token': 'next+/=',
        });
        return http.Response('{"environments":[{"id":"env"}]}', 200);
      }),
    );
    addTearDown(client.close);

    final result = await client.environments.list(
      mode: EnvironmentMode.selfHosted,
      pageSize: 10,
      pageToken: 'next+/=',
    );

    expect(result.environments?.single.id, 'env');
    expect(EnvironmentMode.onDemand.value, 'on_demand');
  });

  test('lists nested paths with encoded segments and UTF-8 metadata', () async {
    final wire = {
      'files': [
        {
          'name': 'résumé #1.txt',
          'path': '資料/résumé #1.txt',
          'type': 'FILE',
          'size_bytes': '9223372036854775807',
          'mime_type': 'text/plain; charset=utf-8',
          'created': '2026-08-19T00:00:00.000Z',
          'modified': '2026-08-20T00:00:00.000Z',
        },
        {'name': 'src', 'path': '資料/src', 'type': 'directory'},
        {'name': 'link', 'path': '資料/link', 'type': 'FUTURE_TYPE'},
      ],
      'next_page_token': 'next+/=',
    };
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        baseUrl: 'https://example.com/proxy?route=one&route=two&alt=media',
        authProvider: ApiKeyProvider(
          'test-key',
          placement: AuthPlacement.header,
        ),
        interactionsApiVersion: ApiVersion.v1,
        defaultHeaders: {'Accept': 'application/octet-stream'},
        defaultQueryParams: {'alt': 'media', 'tenant': 'third'},
      ),
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.pathSegments, [
          'proxy',
          'v1beta',
          'environments',
          r'env/%?$',
          'files',
          '資料',
          'résumé #1+?.txt',
        ]);
        expect(
          request.url.toString(),
          contains('/env%2F%25%3F%24/files/%E8%B3%87%E6%96%99/r%C3%A9sum'),
        );
        expect(request.url.queryParametersAll, {
          'route': ['one', 'two'],
          'tenant': ['third'],
          'page_size': ['20'],
          'page_token': ['previous+/='],
          'recursive': ['false'],
        });
        expect(request.url.fragment, isEmpty);
        expect(request.headers['api-revision'], '2026-05-20');
        expect(request.headers['x-goog-api-key'], 'test-key');
        expect(request.headers['accept'], 'application/json');
        return http.Response.bytes(
          utf8.encode(jsonEncode(wire)),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.close);

    final EnvironmentFilesResource files = client.environments.files;
    final result = await files.list(
      environment: r'environments/env/%?$',
      path: '/資料/résumé #1+?.txt',
      pageSize: 20,
      pageToken: 'previous+/=',
      recursive: false,
    );

    final entries = result.files!;
    expect(entries.first.name, 'résumé #1.txt');
    expect(entries.first.path, '資料/résumé #1.txt');
    expect(entries.first.type?.isFile, isTrue);
    expect(entries.first.sizeBytes, '9223372036854775807');
    expect(entries.first.mimeType, 'text/plain; charset=utf-8');
    expect(entries.first.created, DateTime.utc(2026, 8, 19));
    expect(entries.first.modified, DateTime.utc(2026, 8, 20));
    expect(entries[1].type?.isDirectory, isTrue);
    expect(entries[1].sizeBytes, isNull);
    expect(entries.last.type?.value, 'FUTURE_TYPE');
    expect(result.nextPageToken, 'next+/=');
    expect(result.toJson(), wire);
    expect(
      entries.first.copyWith(type: EnvironmentFileType.directory).type?.value,
      'DIRECTORY',
    );
    expect(
      entries.first.copyWith(sizeBytes: null).toJson(),
      isNot(contains('size_bytes')),
    );
    expect(
      result.copyWith(nextPageToken: null).toJson(),
      isNot(contains('next_page_token')),
    );
  });

  test('lists the root and downloads raw file and directory bytes', () async {
    const rawBytes = [0, 1, 128, 255, 10];
    var callCount = 0;
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        authProvider: ApiKeyProvider(
          'test-key',
          placement: AuthPlacement.header,
        ),
        defaultHeaders: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['api-revision'], '2026-05-20');
        expect(request.headers['x-goog-api-key'], 'test-key');
        switch (callCount++) {
          case 0:
            expect(request.url.path, '/v1beta/environments/env/files');
            expect(request.url.queryParameters, isEmpty);
            return http.Response('{"files":[]}', 200);
          case 1:
            expect(request.url.path, '/v1beta/environments/env/files');
            expect(request.url.queryParameters, {
              'alt': 'media',
              'recursive': 'true',
            });
          case 2:
            expect(
              request.url.path,
              '/v1beta/environments/env/files/src/file.bin',
            );
            expect(request.url.queryParameters, {'alt': 'media'});
          default:
            fail('Unexpected request: ${request.url}');
        }
        expect(request.headers['accept'], '*/*');
        expect(request.headers, isNot(contains('content-type')));
        return http.Response.bytes(rawBytes, 200);
      }),
    );
    addTearDown(client.close);

    final files = client.environments.files;
    expect((await files.list(environment: 'env')).files, isEmpty);
    expect(await files.download(environment: 'env', recursive: true), rawBytes);
    expect(
      await files.download(environment: 'env', path: 'src/file.bin'),
      rawBytes,
    );
    expect(callCount, 3);
  });

  test('rejects invalid path segments without sending a request', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async => fail('Unexpected request.')),
    );
    addTearDown(client.close);

    await expectLater(
      client.environments.files.list(environment: 'environments/'),
      throwsArgumentError,
    );
    await expectLater(
      client.environments.files.download(environment: 'env', path: 'src/../x'),
      throwsArgumentError,
    );
  });

  test('downloads bytes without logging workspace content at FINE', () async {
    final previousHierarchy = hierarchicalLoggingEnabled;
    hierarchicalLoggingEnabled = true;
    addTearDown(() => hierarchicalLoggingEnabled = previousHierarchy);
    final logger = Logger('GoogleAI.HTTP');
    final previousLevel = logger.level;
    addTearDown(() => logger.level = previousLevel);
    final records = <LogRecord>[];
    final subscription = logger.onRecord.listen(records.add);
    addTearDown(subscription.cancel);
    final bytes = [...utf8.encode('private workspace contents'), 0xff];

    final client = GoogleAIClient(
      config: const GoogleAIConfig(logLevel: Level.FINE),
      httpClient: MockClient((request) async {
        expect(request.url.queryParameters['alt'], 'media');
        return http.Response.bytes(
          bytes,
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.close);

    expect(
      await client.environments.files.download(environment: 'env', path: 'log'),
      bytes,
    );
    expect(
      records.any((record) => record.message.startsWith('RESPONSE')),
      isTrue,
    );
    expect(
      records.any((record) => record.message.startsWith('Body:')),
      isFalse,
    );
    expect(
      records.map((record) => record.message).join(),
      isNot(contains('private workspace contents')),
    );
  });

  for (final config in [
    const GoogleAIConfig(apiVersion: ApiVersion.v1),
    const GoogleAIConfig(apiMode: ApiMode.vertexAI),
  ]) {
    test('rejects ${config.apiMode} ${config.apiVersion} locally', () async {
      final client = GoogleAIClient(
        config: config,
        httpClient: MockClient((request) async => fail('Unexpected request.')),
      );
      addTearDown(client.close);

      await expectLater(
        client.environments.list(mode: EnvironmentMode.onDemand),
        throwsUnsupportedError,
      );
      await expectLater(
        client.environments.files.list(environment: 'env'),
        throwsUnsupportedError,
      );
      await expectLater(
        client.environments.files.download(environment: 'env'),
        throwsUnsupportedError,
      );
    });
  }
}
