@TestOn('vm')
library;

import 'package:http/http.dart' as http;
import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('OpenResponsesClient', () {
    group('close', () {
      test('can be called multiple times safely', () {
        final client = OpenResponsesClient()..close();
        expect(client.close, returnsNormally);
      });

      test('throws StateError when used after close', () async {
        final client = OpenResponsesClient()..close();
        await expectLater(
          client.responses.create(
            const CreateResponseRequest(
              model: 'gpt-4o',
              input: ResponseTextInput('Hello'),
            ),
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('does not close custom httpClient', () {
        final httpClient = _SpyHttpClient();
        // ignore: unused_local_variable
        final client = OpenResponsesClient(httpClient: httpClient)..close();
        expect(httpClient.closeCalled, isFalse);
      });
    });

    group('withApiKey', () {
      test('propagates baseUrl and defaultHeaders to config', () {
        final client = OpenResponsesClient.withApiKey(
          'test-key',
          baseUrl: 'https://custom.api.com/v1',
          defaultHeaders: {'X-Custom': 'value'},
        );
        addTearDown(client.close);

        expect(client.config.baseUrl, 'https://custom.api.com/v1');
        expect(client.config.defaultHeaders, {'X-Custom': 'value'});
        expect(client.config.authProvider, isA<BearerTokenProvider>());
      });

      test('uses defaults when baseUrl and defaultHeaders are omitted', () {
        final client = OpenResponsesClient.withApiKey('test-key');
        addTearDown(client.close);

        expect(client.config.baseUrl, 'https://api.openai.com/v1');
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
