import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AgentCompletionResponse', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'mistral-large-latest',
          choices: [],
        );
        expect(response.id, 'resp-123');
        expect(response.created, 1705312800);
        expect(response.model, 'mistral-large-latest');
        expect(response.choices, isEmpty);
        expect(response.object, 'chat.completion');
        expect(response.usage, isNull);
      });

      test('creates with all parameters', () {
        const response = AgentCompletionResponse(
          id: 'resp-456',
          object: 'chat.completion',
          created: 1705312800,
          model: 'codestral-latest',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'Hello!'),
              finishReason: FinishReason.stop,
            ),
          ],
          usage: UsageInfo(
            promptTokens: 10,
            completionTokens: 5,
            totalTokens: 15,
          ),
        );
        expect(response.id, 'resp-456');
        expect(response.object, 'chat.completion');
        expect(response.created, 1705312800);
        expect(response.model, 'codestral-latest');
        expect(response.choices, hasLength(1));
        expect(response.usage?.totalTokens, 15);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'mistral-large-latest',
          choices: [],
        );
        final json = response.toJson();
        expect(json['id'], 'resp-123');
        expect(json['object'], 'chat.completion');
        expect(json['created'], 1705312800);
        expect(json['model'], 'mistral-large-latest');
        expect(json['choices'], isEmpty);
        expect(json.containsKey('usage'), isFalse);
      });

      test('serializes all fields', () {
        const response = AgentCompletionResponse(
          id: 'resp-456',
          created: 1705312800,
          model: 'mistral-large-latest',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'Response'),
              finishReason: FinishReason.stop,
            ),
          ],
          usage: UsageInfo(
            promptTokens: 20,
            completionTokens: 10,
            totalTokens: 30,
          ),
        );
        final json = response.toJson();
        expect(json['id'], 'resp-456');
        expect(json['object'], 'chat.completion');
        expect(json['created'], 1705312800);
        expect(json['model'], 'mistral-large-latest');
        expect(json['choices'], hasLength(1));
        expect(json['usage'], isNotNull);
        expect((json['usage'] as Map<String, dynamic>)['total_tokens'], 30);
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{
          'id': 'resp-789',
          'created': 1705312800,
          'model': 'mistral-small-latest',
          'choices': <dynamic>[],
        };
        final response = AgentCompletionResponse.fromJson(json);
        expect(response.id, 'resp-789');
        expect(response.created, 1705312800);
        expect(response.model, 'mistral-small-latest');
        expect(response.choices, isEmpty);
        expect(response.object, 'chat.completion');
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'id': 'resp-full',
          'object': 'chat.completion',
          'created': 1705312800,
          'model': 'mistral-large-latest',
          'choices': [
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'Full response'},
              'finish_reason': 'stop',
            },
          ],
          'usage': {
            'prompt_tokens': 15,
            'completion_tokens': 25,
            'total_tokens': 40,
          },
        };
        final response = AgentCompletionResponse.fromJson(json);
        expect(response.id, 'resp-full');
        expect(response.object, 'chat.completion');
        expect(response.created, 1705312800);
        expect(response.model, 'mistral-large-latest');
        expect(response.choices, hasLength(1));
        expect(response.choices.first.message.content, 'Full response');
        expect(response.usage?.totalTokens, 40);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'id': 'minimal',
          'created': 1705312800,
          'model': 'model',
          'choices': <dynamic>[],
        };
        final response = AgentCompletionResponse.fromJson(json);
        expect(response.usage, isNull);
      });

      test('handles empty JSON with defaults', () {
        final json = <String, dynamic>{};
        final response = AgentCompletionResponse.fromJson(json);
        expect(response.id, '');
        expect(response.object, 'chat.completion');
        expect(response.created, 0);
        expect(response.model, '');
        expect(response.choices, isEmpty);
      });
    });

    group('convenience getters', () {
      test('firstChoice returns first choice', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'model',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'First'),
              finishReason: FinishReason.stop,
            ),
            ChatChoice(
              index: 1,
              message: AssistantMessage(content: 'Second'),
              finishReason: FinishReason.stop,
            ),
          ],
        );
        expect(response.firstChoice?.message.content, 'First');
      });

      test('firstChoice returns null for empty choices', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'model',
          choices: [],
        );
        expect(response.firstChoice, isNull);
      });

      test('text returns content from first choice', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'model',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'Hello world!'),
              finishReason: FinishReason.stop,
            ),
          ],
        );
        expect(response.text, 'Hello world!');
      });

      test('text returns null for empty choices', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'model',
          choices: [],
        );
        expect(response.text, isNull);
      });
    });

    group('equality', () {
      test('equals with same id', () {
        const response1 = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'model-a',
          choices: [],
        );
        const response2 = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312900,
          model: 'model-b',
          choices: [],
        );
        expect(response1, equals(response2));
        expect(response1.hashCode, response2.hashCode);
      });

      test('not equals with different id', () {
        const response1 = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'model',
          choices: [],
        );
        const response2 = AgentCompletionResponse(
          id: 'resp-456',
          created: 1705312800,
          model: 'model',
          choices: [],
        );
        expect(response1, isNot(equals(response2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const response = AgentCompletionResponse(
          id: 'resp-123',
          created: 1705312800,
          model: 'mistral-large-latest',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'Hi'),
              finishReason: FinishReason.stop,
            ),
          ],
        );
        expect(
          response.toString(),
          'AgentCompletionResponse(id: resp-123, model: mistral-large-latest, choices: 1)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = AgentCompletionResponse(
          id: 'resp-roundtrip',
          object: 'chat.completion',
          created: 1705312800,
          model: 'mistral-large-latest',
          choices: [
            ChatChoice(
              index: 0,
              message: AssistantMessage(content: 'Round-trip content'),
              finishReason: FinishReason.stop,
            ),
          ],
          usage: UsageInfo(
            promptTokens: 50,
            completionTokens: 100,
            totalTokens: 150,
          ),
        );
        final json = original.toJson();
        final restored = AgentCompletionResponse.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.object, original.object);
        expect(restored.created, original.created);
        expect(restored.model, original.model);
        expect(restored.choices.length, original.choices.length);
        expect(restored.usage?.totalTokens, original.usage?.totalTokens);
      });
    });
  });
}
