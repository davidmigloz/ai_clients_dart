@TestOn('vm')
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'downloads raw bytes across a native signed redirect without client credentials',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requests = <(String, String?, String?, Map<String, String>)>[];
      const bytes = [0, 129, 255, 10];
      server.listen((request) async {
        requests.add((
          request.uri.path,
          request.headers.value('x-goog-api-key'),
          request.headers.value('authorization'),
          request.uri.queryParameters,
        ));
        final response = request.response;
        if (request.uri.path == '/v1beta/files/media-fixture:download') {
          response
            ..statusCode = 302
            ..headers.set(
              HttpHeaders.locationHeader,
              'http://localhost:${server.port}/signed?signature=fixture-only',
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
            'private-fixture',
            placement: AuthPlacement.header,
          ),
          defaultHeaders: const {'Authorization': 'Bearer gateway-fixture'},
        ),
      );
      addTearDown(client.close);
      expect(await client.files.download(name: 'media-fixture'), bytes);
      expect(requests[0].$1, '/v1beta/files/media-fixture:download');
      expect(requests[0].$2, 'private-fixture');
      expect(requests[0].$3, 'Bearer gateway-fixture');
      expect(requests[0].$4, {'alt': 'media'});
      expect(requests[1].$1, '/signed');
      expect(requests[1].$2, isNull);
      expect(requests[1].$3, isNull);
      expect(requests[1].$4, {'signature': 'fixture-only'});
      expect(requests, hasLength(2));
    },
  );
}
