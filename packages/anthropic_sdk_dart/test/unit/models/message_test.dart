import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    test('fromJson parses a simple text message', () {
      final json = {
        'id': 'msg_123',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-20250514',
        'content': [
          {'type': 'text', 'text': 'Hello, world!'},
        ],
        'stop_reason': 'end_turn',
        'stop_sequence': null,
        'usage': {'input_tokens': 10, 'output_tokens': 5},
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg_123');
      expect(message.type, 'message');
      expect(message.role, 'assistant');
      expect(message.model, 'claude-sonnet-4-20250514');
      expect(message.content, hasLength(1));
      expect(message.content.first, isA<TextBlock>());
      expect((message.content.first as TextBlock).text, 'Hello, world!');
      expect(message.stopReason, StopReason.endTurn);
      expect(message.stopSequence, isNull);
      expect(message.usage.inputTokens, 10);
      expect(message.usage.outputTokens, 5);
    });

    test('fromJson parses message with tool use', () {
      final json = {
        'id': 'msg_456',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-20250514',
        'content': [
          {'type': 'text', 'text': 'Let me check the weather.'},
          {
            'type': 'tool_use',
            'id': 'tu_789',
            'name': 'get_weather',
            'input': {'city': 'San Francisco'},
          },
        ],
        'stop_reason': 'tool_use',
        'stop_sequence': null,
        'usage': {'input_tokens': 20, 'output_tokens': 30},
      };

      final message = Message.fromJson(json);

      expect(message.content, hasLength(2));
      expect(message.content[0], isA<TextBlock>());
      expect(message.content[1], isA<ToolUseBlock>());

      final toolUse = message.content[1] as ToolUseBlock;
      expect(toolUse.id, 'tu_789');
      expect(toolUse.name, 'get_weather');
      expect(toolUse.input, {'city': 'San Francisco'});
      expect(message.stopReason, StopReason.toolUse);
    });

    test('fromJson parses message with thinking blocks', () {
      final json = {
        'id': 'msg_think',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-20250514',
        'content': [
          {
            'type': 'thinking',
            'thinking': 'Let me think about this...',
            'signature': 'sig123',
          },
          {'type': 'text', 'text': 'Here is my answer.'},
        ],
        'stop_reason': 'end_turn',
        'stop_sequence': null,
        'usage': {'input_tokens': 15, 'output_tokens': 25},
      };

      final message = Message.fromJson(json);

      expect(message.content, hasLength(2));
      expect(message.content[0], isA<ThinkingBlock>());
      expect(message.content[1], isA<TextBlock>());

      final thinking = message.content[0] as ThinkingBlock;
      expect(thinking.thinking, 'Let me think about this...');
      expect(thinking.signature, 'sig123');
    });

    test('toJson produces valid JSON', () {
      const message = Message(
        id: 'msg_test',
        role: 'assistant',
        content: [TextBlock(text: 'Test response')],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 5, outputTokens: 3),
      );

      final json = message.toJson();

      expect(json['id'], 'msg_test');
      expect(json['role'], 'assistant');
      expect(json['model'], 'claude-sonnet-4-20250514');
      expect(json['stop_reason'], 'end_turn');
      expect(json['content'], hasLength(1));
      expect(
        ((json['content'] as List)[0] as Map<String, dynamic>)['type'],
        'text',
      );
    });

    test('copyWith creates a modified copy', () {
      const original = Message(
        id: 'msg_orig',
        role: 'assistant',
        content: [TextBlock(text: 'Original')],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 10, outputTokens: 5),
      );

      final modified = original.copyWith(
        id: 'msg_copy',
        content: [const TextBlock(text: 'Modified')],
      );

      expect(modified.id, 'msg_copy');
      expect((modified.content.first as TextBlock).text, 'Modified');
      expect(modified.role, 'assistant'); // Unchanged
      expect(modified.model, 'claude-sonnet-4-20250514'); // Unchanged
    });
  });

  group('MessageExtensions', () {
    test('text getter concatenates all text blocks', () {
      const message = Message(
        id: 'msg_1',
        role: 'assistant',
        content: [
          TextBlock(text: 'Hello, '),
          TextBlock(text: 'world!'),
        ],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 5, outputTokens: 3),
      );

      expect(message.text, 'Hello, world!');
    });

    test('toolUseBlocks returns only tool use blocks', () {
      const message = Message(
        id: 'msg_1',
        role: 'assistant',
        content: [
          TextBlock(text: 'Let me help.'),
          ToolUseBlock(id: 'tu_1', name: 'tool1', input: {}),
          ToolUseBlock(id: 'tu_2', name: 'tool2', input: {}),
        ],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.toolUse,
        usage: Usage(inputTokens: 10, outputTokens: 20),
      );

      expect(message.toolUseBlocks, hasLength(2));
      expect(message.hasToolUse, isTrue);
    });

    test('thinkingBlocks returns only thinking blocks', () {
      const message = Message(
        id: 'msg_1',
        role: 'assistant',
        content: [
          ThinkingBlock(thinking: 'Thinking 1...', signature: 'sig1'),
          TextBlock(text: 'Response'),
          ThinkingBlock(thinking: 'Thinking 2...', signature: 'sig2'),
        ],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 10, outputTokens: 20),
      );

      expect(message.thinkingBlocks, hasLength(2));
      expect(message.hasThinking, isTrue);
      expect(message.thinking, 'Thinking 1...Thinking 2...');
    });

    test('isEndTurn returns true for end_turn stop reason', () {
      const message = Message(
        id: 'msg_1',
        role: 'assistant',
        content: [TextBlock(text: 'Done')],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 5, outputTokens: 3),
      );

      expect(message.isEndTurn, isTrue);
      expect(message.isMaxTokens, isFalse);
      expect(message.isToolUse, isFalse);
    });

    test('isMaxTokens returns true for max_tokens stop reason', () {
      const message = Message(
        id: 'msg_1',
        role: 'assistant',
        content: [TextBlock(text: 'Truncated...')],
        model: 'claude-sonnet-4-20250514',
        stopReason: StopReason.maxTokens,
        usage: Usage(inputTokens: 5, outputTokens: 100),
      );

      expect(message.isMaxTokens, isTrue);
      expect(message.isEndTurn, isFalse);
    });
  });
}
