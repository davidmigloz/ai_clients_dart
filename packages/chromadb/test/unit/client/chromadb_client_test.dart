@TestOn('vm')
library;

import 'package:chromadb/chromadb.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('ChromaClient', () {
    group('close', () {
      test('can be called multiple times safely', () {
        final client = ChromaClient()..close();
        expect(client.close, returnsNormally);
      });

      test('throws StateError when used after close', () async {
        final client = ChromaClient()..close();
        await expectLater(
          client.health.heartbeat(),
          throwsA(isA<StateError>()),
        );
      });

      test('does not close custom httpClient', () {
        final httpClient = _SpyHttpClient();
        // ignore: unused_local_variable
        final client = ChromaClient(httpClient: httpClient)..close();
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
