@TestOn('vm')
library;

import 'package:http/http.dart' as http;
import 'package:open_responses_dart/open_responses_dart.dart';
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
            const CreateResponseRequest(model: 'gpt-4o', input: 'Hello'),
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
