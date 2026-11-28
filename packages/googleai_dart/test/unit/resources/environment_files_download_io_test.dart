@TestOn('vm')
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  test('follows signed file redirects without forwarding credentials', () async {
    final previousHierarchy = hierarchicalLoggingEnabled;
    hierarchicalLoggingEnabled = true;
    addTearDown(() => hierarchicalLoggingEnabled = previousHierarchy);
    final logger = Logger('GoogleAI.HTTP');
    final previousLevel = logger.level;
    addTearDown(() => logger.level = previousLevel);
    final logs = <LogRecord>[];
    final logSubscription = logger.onRecord.listen(logs.add);
    addTearDown(logSubscription.cancel);

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final requests = <({Uri uri, String? key, String? auth, String? tenant})>[];
    const bytes = [0, 123, 128, 255];
    server.listen((request) async {
      requests.add((
        uri: request.uri,
        key: request.headers.value('x-goog-api-key'),
        auth: request.headers.value('authorization'),
        tenant: request.headers.value('x-tenant'),
      ));
      final response = request.response;
      if (request.uri.path == '/v1beta/environments/env/files/report.bin') {
        response
          ..statusCode = 302
          ..headers.set(
            'location',
            'http://localhost:${server.port}/signed?signature=private-download-token',
          );
      } else {
        response
          ..headers.contentType = ContentType.binary
          ..add(bytes);
      }
      await response.close();
    });
    final client = GoogleAIClient(
      config: GoogleAIConfig(
        baseUrl: 'http://127.0.0.1:${server.port}',
        authProvider: const ApiKeyProvider(
          'api-secret',
          placement: AuthPlacement.header,
        ),
        defaultHeaders: const {
          'Authorization': 'Bearer gateway-secret',
          'X-Tenant': 'private-tenant',
        },
        defaultQueryParams: const {'gateway': 'configured'},
        logLevel: Level.FINE,
      ),
    );
    addTearDown(client.close);

    expect(
      await client.environments.files.download(
        environment: 'env',
        path: 'report.bin',
      ),
      bytes,
    );
    expect(requests, hasLength(2));
    expect(requests.first.key, 'api-secret');
    expect(requests.first.auth, 'Bearer gateway-secret');
    expect(requests.first.tenant, 'private-tenant');
    expect(requests.first.uri.queryParameters, {
      'alt': 'media',
      'gateway': 'configured',
    });
    expect(requests.last.key, isNull);
    expect(requests.last.auth, isNull);
    expect(requests.last.tenant, isNull);
    expect(requests.last.uri.path, '/signed');
    expect(requests.last.uri.queryParameters, {
      'signature': 'private-download-token',
    });
    expect(logs.any((record) => record.message.startsWith('RESPONSE')), isTrue);
    expect(
      logs.map((record) => record.message).join(),
      isNot(contains('private-download-token')),
    );
  });
}
