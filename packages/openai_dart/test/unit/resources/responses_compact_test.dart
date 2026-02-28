import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Responses.compact', () {
    test('POST /responses/compact with expected payload', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          jsonEncode({
            'id': 'cmp_123',
            'object': 'response.compaction',
            'created_at': 1234567890,
            'output': [
              {
                'type': 'compaction',
                'id': 'cmp_item_1',
                'encrypted_content': 'ciphertext',
              },
            ],
            'usage': {
              'input_tokens': 10,
              'output_tokens': 2,
              'total_tokens': 12,
            },
          }),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final response = await client.responses.compact(
        const CompactResponseRequest(
          model: 'gpt-5.1-codex-max',
          input: ResponseInput.text('compact this'),
          previousResponseId: 'resp_123',
        ),
      );

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(request.method, equals('POST'));
      expect(request.url.path, endsWith('/responses/compact'));
      expect(body['model'], equals('gpt-5.1-codex-max'));
      expect(body['input'], equals('compact this'));
      expect(body['previous_response_id'], equals('resp_123'));
      expect(response.object, equals('response.compaction'));
      expect(response.output.first, isA<CompactionOutputItem>());
    });

    test(
      'compact response with input_text user messages deserializes',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'id': 'cmp_456',
              'object': 'response.compaction',
              'created_at': 1234567890,
              'output': [
                {
                  'type': 'message',
                  'id': 'msg_1',
                  'role': 'user',
                  'status': 'completed',
                  'content': [
                    {'type': 'input_text', 'text': 'What is the weather?'},
                  ],
                },
                {
                  'type': 'compaction',
                  'id': 'cmp_item_1',
                  'encrypted_content': 'encrypted_data',
                },
              ],
              'usage': {
                'input_tokens': 50,
                'output_tokens': 5,
                'total_tokens': 55,
              },
            }),
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        final response = await client.responses.compact(
          const CompactResponseRequest(
            model: 'gpt-4o',
            input: ResponseInput.text('compact'),
          ),
        );

        expect(response.output, hasLength(2));

        final msg = response.output[0] as MessageOutputItem;
        expect(msg.role, equals(MessageRole.user));
        expect(msg.content.first, isA<InputTextOutputContent>());
        expect(
          (msg.content.first as InputTextOutputContent).text,
          equals('What is the weather?'),
        );

        expect(response.output[1], isA<CompactionOutputItem>());
      },
    );

    test('compact response toInput() produces valid input JSON', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'id': 'cmp_789',
            'object': 'response.compaction',
            'created_at': 1234567890,
            'output': [
              {
                'type': 'compaction',
                'id': 'cmp_item_1',
                'encrypted_content': 'abc',
              },
            ],
            'usage': {
              'input_tokens': 10,
              'output_tokens': 2,
              'total_tokens': 12,
            },
          }),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final compaction = await client.responses.compact(
        const CompactResponseRequest(
          model: 'gpt-4o',
          input: ResponseInput.text('compact'),
        ),
      );

      final input = compaction.toInput();
      expect(input, isA<ResponseInputRawJson>());

      final json = input.toJson() as List;
      expect(json, hasLength(1));
      final item = json[0] as Map<String, dynamic>;
      expect(item['type'], equals('compaction'));
      expect(item['encrypted_content'], equals('abc'));
    });
  });
}
