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

      test('throws StateError when used after close', () {
        final client = OpenResponsesClient()..close();
        expect(
          () => client.responses.create(
            const CreateResponseRequest(model: 'gpt-4o', input: 'Hello'),
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('does not close custom httpClient', () {
        final httpClient = http.Client();
        final client = OpenResponsesClient(httpClient: httpClient)..close();
        // httpClient should still be usable
        expect(client.close, returnsNormally);
      });
    });
  });
}
