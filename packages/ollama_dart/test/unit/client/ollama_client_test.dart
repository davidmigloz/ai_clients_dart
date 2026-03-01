@TestOn('vm')
library;

import 'package:http/http.dart' as http;
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OllamaClient', () {
    group('close', () {
      test('can be called multiple times safely', () {
        final client = OllamaClient()..close();
        expect(client.close, returnsNormally);
      });

      test('throws StateError when used after close', () {
        final client = OllamaClient()..close();
        expect(() => client.models.list(), throwsA(isA<StateError>()));
      });

      test('does not close custom httpClient', () {
        final httpClient = http.Client();
        final client = OllamaClient(httpClient: httpClient)..close();
        // httpClient should still be usable
        expect(client.close, returnsNormally);
      });
    });
  });
}
