import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatCompletionResponse', () {
    test('creates with required fields', () {
      const response = ChatCompletionResponse(
        id: 'cmpl-123',
        object: 'chat.completion',
        created: 1699000000,
        model: 'mistral-small-latest',
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Hello!'),
            finishReason: FinishReason.stop,
          ),
        ],
      );

      expect(response.id, 'cmpl-123');
      expect(response.object, 'chat.completion');
      expect(response.created, 1699000000);
      expect(response.model, 'mistral-small-latest');
      expect(response.choices, hasLength(1));
      expect(response.usage, isNull);
    });

    test('creates with usage', () {
      const response = ChatCompletionResponse(
        id: 'cmpl-456',
        object: 'chat.completion',
        created: 1699000001,
        model: 'mistral-large-latest',
        choices: [],
        usage: UsageInfo(
          promptTokens: 10,
          completionTokens: 20,
          totalTokens: 30,
        ),
      );

      expect(response.usage, isNotNull);
      expect(response.usage!.promptTokens, 10);
      expect(response.usage!.completionTokens, 20);
      expect(response.usage!.totalTokens, 30);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'cmpl-789',
        'object': 'chat.completion',
        'created': 1699000002,
        'model': 'mistral-small-latest',
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': 'Hi there!'},
            'finish_reason': 'stop',
          },
        ],
        'usage': {
          'prompt_tokens': 5,
          'completion_tokens': 10,
          'total_tokens': 15,
        },
      };
      final response = ChatCompletionResponse.fromJson(json);

      expect(response.id, 'cmpl-789');
      expect(response.model, 'mistral-small-latest');
      expect(response.choices, hasLength(1));
      expect(response.choices.first.message.content, 'Hi there!');
      expect(response.usage, isNotNull);
    });

    test('serializes to JSON', () {
      const response = ChatCompletionResponse(
        id: 'cmpl-abc',
        object: 'chat.completion',
        created: 1699000003,
        model: 'mistral-medium-latest',
        choices: [
          ChatChoice(
            index: 0,
            message: AssistantMessage(content: 'Response'),
            finishReason: FinishReason.length,
          ),
        ],
        usage: UsageInfo(
          promptTokens: 15,
          completionTokens: 25,
          totalTokens: 40,
        ),
      );
      final json = response.toJson();

      expect(json['id'], 'cmpl-abc');
      expect(json['object'], 'chat.completion');
      expect(json['created'], 1699000003);
      expect(json['model'], 'mistral-medium-latest');
      expect(json['choices'], isList);
      expect(json['usage'], isNotNull);
    });

    test('handles empty choices', () {
      final json = {
        'id': 'cmpl-empty',
        'object': 'chat.completion',
        'created': 1699000004,
        'model': 'test-model',
      };
      final response = ChatCompletionResponse.fromJson(json);

      expect(response.choices, isEmpty);
    });

    test('equality works correctly', () {
      const response1 = ChatCompletionResponse(
        id: 'test',
        object: 'chat.completion',
        created: 1699000000,
        model: 'test-model',
        choices: [],
      );
      const response2 = ChatCompletionResponse(
        id: 'test',
        object: 'chat.completion',
        created: 1699000000,
        model: 'test-model',
        choices: [],
      );

      // Note: equality is based on id, object, created, model only
      expect(response1, equals(response2));
    });
  });
}
