@TestOn('vm')
library;

import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _apiKey = 'offline-fixture-key';

void main() {
  late HttpServer origin;
  late HttpServer destination;
  late int destinationRequests;
  late List<String?> credentials;

  setUp(() async {
    destination = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => destination.close(force: true));
    origin = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => origin.close(force: true));
    destinationRequests = 0;
    credentials = [];

    destination.listen((request) async {
      destinationRequests++;
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
    });
    origin.listen((request) async {
      credentials.add(request.headers.value('x-api-key'));
      await request.response.redirect(
        Uri.parse('http://127.0.0.1:${destination.port}/redirected'),
        status: HttpStatus.found,
      );
    });
  });

  Matcher rejectsRedirect() => throwsA(
    isA<ApiException>().having(
      (error) => error.statusCode,
      'HTTP status',
      HttpStatus.found,
    ),
  );

  test(
    'dashboard auth stops at the original host for billing and identity',
    () async {
      final client = MistralClient.withApiKey(
        _apiKey,
        baseUrl: 'http://localhost:${origin.port}',
      );
      addTearDown(client.close);

      await expectLater(client.billing.getBudget(), rejectsRedirect());
      await expectLater(
        client.users.whoami(authInApiKeyHeader: true),
        rejectsRedirect(),
      );
      expect(credentials, [_apiKey, _apiKey]);
      expect(destinationRequests, 0);
    },
  );

  test(
    'an explicit x-api-key header also stops redirects on identity',
    () async {
      final client = MistralClient(
        config: MistralConfig(
          baseUrl: 'http://localhost:${origin.port}',
          defaultHeaders: const {'X-API-Key': _apiKey},
        ),
      );
      addTearDown(client.close);

      await expectLater(client.users.me(), rejectsRedirect());
      expect(credentials, [_apiKey]);
      expect(destinationRequests, 0);
    },
  );
}
