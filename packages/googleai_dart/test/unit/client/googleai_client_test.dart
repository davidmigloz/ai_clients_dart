@TestOn('vm')
library;

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('GoogleAIClient', () {
    group('close', () {
      test('can be called multiple times safely', () {
        final client = GoogleAIClient()..close();
        expect(client.close, returnsNormally);
      });

      test('throws StateError when used after close', () {
        final client = GoogleAIClient()..close();
        expect(() => client.models.list(), throwsA(isA<StateError>()));
      });

      test('does not close custom httpClient', () {
        final httpClient = http.Client();
        final client = GoogleAIClient(httpClient: httpClient)..close();
        // httpClient should still be usable
        expect(client.close, returnsNormally);
      });
    });
  });
}
