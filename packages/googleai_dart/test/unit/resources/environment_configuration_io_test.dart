@TestOn('vm')
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('rejects cross-origin redirects during environment creation', () async {
    final target = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => target.close(force: true));
    final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => source.close(force: true));

    var redirectedRequests = 0;
    target.listen((request) async {
      redirectedRequests++;
      request.response
        ..headers.contentType = ContentType.json
        ..write('{"id":"redirect-target","environment_key":"redirect-key"}');
      await request.response.close();
    });
    String? initialKey;
    source.listen((request) async {
      initialKey = request.headers.value('x-goog-api-key');
      request.response
        ..statusCode = HttpStatus.seeOther
        ..headers.set(
          HttpHeaders.locationHeader,
          'http://localhost:${target.port}/environments',
        )
        ..write('{"id":"redirect","environment_key":"redirect-key"}');
      await request.response.close();
    });

    final client = GoogleAIClient(
      config: GoogleAIConfig(
        baseUrl: 'http://127.0.0.1:${source.port}',
        authProvider: const ApiKeyProvider(
          'fixture-developer-key',
          placement: AuthPlacement.header,
        ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.environments.create(environment: const CreateEnvironmentRequest()),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'status',
          HttpStatus.seeOther,
        ),
      ),
    );
    expect(initialKey, 'fixture-developer-key');
    expect(redirectedRequests, 0);
  });
}
