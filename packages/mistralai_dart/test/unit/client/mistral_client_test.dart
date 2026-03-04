@TestOn('vm')
library;

import 'package:http/http.dart' as http;
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MistralClient', () {
    group('close', () {
      test('can be called multiple times safely', () {
        final client = MistralClient()..close();
        expect(client.close, returnsNormally);
      });

      test('throws StateError when used after close', () async {
        final client = MistralClient()..close();
        await expectLater(client.models.list(), throwsA(isA<StateError>()));
      });

      test('does not close custom httpClient', () {
        final httpClient = _SpyHttpClient();
        // ignore: unused_local_variable
        final client = MistralClient(httpClient: httpClient)..close();
        expect(httpClient.closeCalled, isFalse);
      });
    });

    group('withApiKey', () {
      test('propagates baseUrl and defaultHeaders to config', () {
        final client = MistralClient.withApiKey(
          'test-key',
          baseUrl: 'https://custom.api.com',
          defaultHeaders: {'X-Custom': 'value'},
        );
        addTearDown(client.close);

        expect(client.config.baseUrl, 'https://custom.api.com');
        expect(client.config.defaultHeaders, {'X-Custom': 'value'});
        expect(client.config.authProvider, isA<ApiKeyProvider>());
      });

      test('uses defaults when baseUrl and defaultHeaders are omitted', () {
        final client = MistralClient.withApiKey('test-key');
        addTearDown(client.close);

        expect(client.config.baseUrl, 'https://api.mistral.ai');
        expect(client.config.defaultHeaders, isEmpty);
      });
    });
  });
}

class _SpyHttpClient extends http.BaseClient {
  bool closeCalled = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  @override
  void close() {
    closeCalled = true;
  }
}
