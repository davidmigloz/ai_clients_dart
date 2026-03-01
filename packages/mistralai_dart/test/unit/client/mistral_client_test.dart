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
