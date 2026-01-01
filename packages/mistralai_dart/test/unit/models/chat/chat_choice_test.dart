import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatChoice', () {
    test('creates with required fields', () {
      const choice = ChatChoice(
        index: 0,
        message: AssistantMessage(content: 'Hello!'),
      );

      expect(choice.index, 0);
      expect(choice.message.content, 'Hello!');
      expect(choice.finishReason, isNull);
    });

    test('creates with finish reason', () {
      const choice = ChatChoice(
        index: 1,
        message: AssistantMessage(content: 'Done'),
        finishReason: FinishReason.stop,
      );

      expect(choice.finishReason, FinishReason.stop);
    });

    test('creates with tool calls', () {
      const choice = ChatChoice(
        index: 0,
        message: AssistantMessage(
          content: null,
          toolCalls: [
            ToolCall(
              id: 'call_123',
              function: FunctionCall(
                name: 'get_weather',
                arguments: '{"location": "Paris"}',
              ),
            ),
          ],
        ),
        finishReason: FinishReason.toolCalls,
      );

      expect(choice.message.toolCalls, hasLength(1));
      expect(choice.finishReason, FinishReason.toolCalls);
    });

    test('deserializes from JSON', () {
      final json = {
        'index': 0,
        'message': {'role': 'assistant', 'content': 'Test response'},
        'finish_reason': 'stop',
      };
      final choice = ChatChoice.fromJson(json);

      expect(choice.index, 0);
      expect(choice.message.content, 'Test response');
      expect(choice.finishReason, FinishReason.stop);
    });

    test('deserializes with tool calls', () {
      final json = {
        'index': 0,
        'message': {
          'role': 'assistant',
          'tool_calls': [
            {
              'id': 'call_abc',
              'type': 'function',
              'function': {'name': 'test_func', 'arguments': '{}'},
            },
          ],
        },
        'finish_reason': 'tool_calls',
      };
      final choice = ChatChoice.fromJson(json);

      expect(choice.message.toolCalls, hasLength(1));
      expect(choice.message.toolCalls!.first.id, 'call_abc');
      expect(choice.finishReason, FinishReason.toolCalls);
    });

    test('serializes to JSON', () {
      const choice = ChatChoice(
        index: 0,
        message: AssistantMessage(content: 'Hello'),
        finishReason: FinishReason.stop,
      );
      final json = choice.toJson();

      expect(json['index'], 0);
      expect(json['message'], isA<Map<String, dynamic>>());
      expect((json['message'] as Map)['content'], 'Hello');
      expect(json['finish_reason'], 'stop');
    });

    test('equality works correctly', () {
      const choice1 = ChatChoice(
        index: 0,
        message: AssistantMessage(content: 'Test'),
        finishReason: FinishReason.stop,
      );
      const choice2 = ChatChoice(
        index: 0,
        message: AssistantMessage(content: 'Test'),
        finishReason: FinishReason.stop,
      );
      const choice3 = ChatChoice(
        index: 1,
        message: AssistantMessage(content: 'Test'),
        finishReason: FinishReason.stop,
      );

      expect(choice1, equals(choice2));
      expect(choice1.hashCode, equals(choice2.hashCode));
      expect(choice1, isNot(equals(choice3)));
    });
  });
}
