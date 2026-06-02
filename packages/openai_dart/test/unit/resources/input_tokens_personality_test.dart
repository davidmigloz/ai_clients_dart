import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InputTokensResource.count personality', () {
    OpenAIClient buildClient(MockClient mockClient) => OpenAIClient(
      config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
      httpClient: mockClient,
    );

    http.Response okResponse(int tokens) => http.Response(
      jsonEncode({'input_tokens': tokens, 'object': 'response.input_tokens'}),
      200,
    );

    test('serializes personality into the request body', () async {
      final requestCompleter = Completer<http.BaseRequest>();
      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return okResponse(7);
      });
      final client = buildClient(mockClient);

      final result = await client.responses.inputTokens.count(
        model: 'gpt-4o',
        input: const ResponseInput.text('Hello'),
        personality: const Personality.friendly(),
      );

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(request.method, equals('POST'));
      expect(request.url.path, endsWith('/responses/input_tokens'));
      expect(body['personality'], equals('friendly'));
      expect(result.inputTokens, equals(7));
    });

    test('omits personality when not provided', () async {
      final requestCompleter = Completer<http.BaseRequest>();
      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return okResponse(3);
      });
      final client = buildClient(mockClient);

      await client.responses.inputTokens.count(
        model: 'gpt-4o',
        input: const ResponseInput.text('Hello'),
      );

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body.containsKey('personality'), isFalse);
    });
  });
}
