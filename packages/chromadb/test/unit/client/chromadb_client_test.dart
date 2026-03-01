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

      test('throws StateError when used after close', () {
        final client = ChromaClient()..close();
        expect(() => client.health.heartbeat(), throwsA(isA<StateError>()));
      });

      test('does not close custom httpClient', () {
        final httpClient = http.Client();
        final client = ChromaClient(httpClient: httpClient)..close();
        // httpClient should still be usable
        expect(client.close, returnsNormally);
      });
    });
  });
}
