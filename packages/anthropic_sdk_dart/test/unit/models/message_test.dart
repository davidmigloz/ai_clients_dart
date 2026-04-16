import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    test('fromJson parses a simple text message', () {
      final json = {
        'id': 'msg_123',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-6',
        'content': [
          {'type': 'text', 'text': 'Hello, world!'},
        ],
        'stop_reason': 'end_turn',
        'stop_sequence': null,
        'usage': {
          'input_tokens': 10,
          'output_tokens': 5,
          'inference_geo': 'us',
        },
        'container': {
          'id': 'container_123',
          'expires_at': '2026-02-20T00:00:00Z',
        },
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg_123');
      expect(message.type, 'message');
      expect(message.role, MessageRole.assistant);
      expect(message.model, 'claude-sonnet-4-6');
      expect(message.content, hasLength(1));
      expect(message.content.first, isA<TextBlock>());
      expect((message.content.first as TextBlock).text, 'Hello, world!');
      expect(message.stopReason, StopReason.endTurn);
      expect(message.stopSequence, isNull);
      expect(message.usage.inputTokens, 10);
      expect(message.usage.outputTokens, 5);
      expect(message.usage.inferenceGeo, 'us');
      expect(message.container, isNotNull);
      expect(message.container!.id, 'container_123');
    });

    test('fromJson parses message with tool use', () {
      final json = {
        'id': 'msg_456',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-6',
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
        'model': 'claude-sonnet-4-6',
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

    test('fromJson parses message with refusal stop_details', () {
      final json = {
        'id': 'msg_refusal',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-6',
        'content': [
          {'type': 'text', 'text': ''},
        ],
        'stop_reason': 'refusal',
        'stop_details': {
          'type': 'refusal',
          'category': 'cyber',
          'explanation': 'This request was refused.',
        },
        'stop_sequence': null,
        'usage': {'input_tokens': 10, 'output_tokens': 1},
      };

      final message = Message.fromJson(json);

      expect(message.stopReason, StopReason.refusal);
      expect(message.stopDetails, isNotNull);
      expect(message.stopDetails!.type, 'refusal');
      expect(message.stopDetails!.category, RefusalCategory.cyber);
      expect(message.stopDetails!.explanation, 'This request was refused.');
    });

    test('fromJson parses message with null stop_details', () {
      final json = {
        'id': 'msg_normal',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-sonnet-4-6',
        'content': [
          {'type': 'text', 'text': 'Hello!'},
        ],
        'stop_reason': 'end_turn',
        'stop_details': null,
        'stop_sequence': null,
        'usage': {'input_tokens': 10, 'output_tokens': 5},
      };

      final message = Message.fromJson(json);

      expect(message.stopReason, StopReason.endTurn);
      expect(message.stopDetails, isNull);
    });

    test('fromJson parses model_context_window_exceeded stop reason', () {
      final json = {
        'id': 'msg_ctx',
        'type': 'message',
        'role': 'assistant',
        'model': 'claude-opus-4-6-20260205',
        'content': [
          {'type': 'text', 'text': 'Response truncated by context window.'},
        ],
        'stop_reason': 'model_context_window_exceeded',
        'stop_sequence': null,
        'usage': {'input_tokens': 220000, 'output_tokens': 10},
      };

      final message = Message.fromJson(json);
      expect(message.stopReason, StopReason.modelContextWindowExceeded);
    });

    test('toJson produces valid JSON', () {
      const message = Message(
        id: 'msg_test',
        role: MessageRole.assistant,
        content: [TextBlock(text: 'Test response')],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 5, outputTokens: 3),
      );

      final json = message.toJson();

      expect(json['id'], 'msg_test');
      expect(json['role'], 'assistant');
      expect(json['model'], 'claude-sonnet-4-6');
      expect(json['stop_reason'], 'end_turn');
      expect(json['content'], hasLength(1));
      expect(
        ((json['content'] as List)[0] as Map<String, dynamic>)['type'],
        'text',
      );
    });

    test('toJson includes stop_details when present', () {
      const message = Message(
        id: 'msg_test',
        role: MessageRole.assistant,
        content: [TextBlock(text: 'Refused')],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.refusal,
        stopDetails: RefusalStopDetails(
          category: RefusalCategory.bio,
          explanation: 'Refused for bio reasons.',
        ),
        usage: Usage(inputTokens: 5, outputTokens: 1),
      );

      final json = message.toJson();

      expect(json['stop_reason'], 'refusal');
      expect(json['stop_details'], isA<Map<String, dynamic>>());
      final details = json['stop_details'] as Map<String, dynamic>;
      expect(details['type'], 'refusal');
      expect(details['category'], 'bio');
      expect(details['explanation'], 'Refused for bio reasons.');
    });

    test('toJson omits stop_details when null', () {
      const message = Message(
        id: 'msg_test',
        role: MessageRole.assistant,
        content: [TextBlock(text: 'Test')],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 5, outputTokens: 3),
      );

      final json = message.toJson();
      expect(json.containsKey('stop_details'), isFalse);
    });

    test('copyWith creates a modified copy', () {
      const original = Message(
        id: 'msg_orig',
        role: MessageRole.assistant,
        content: [TextBlock(text: 'Original')],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 10, outputTokens: 5),
      );

      final modified = original.copyWith(
        id: 'msg_copy',
        content: [const TextBlock(text: 'Modified')],
      );

      expect(modified.id, 'msg_copy');
      expect((modified.content.first as TextBlock).text, 'Modified');
      expect(modified.role, MessageRole.assistant); // Unchanged
      expect(modified.model, 'claude-sonnet-4-6'); // Unchanged
    });
  });

  group('MessageExtensions', () {
    test('text getter concatenates all text blocks', () {
      const message = Message(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [
          TextBlock(text: 'Hello, '),
          TextBlock(text: 'world!'),
        ],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.endTurn,
        usage: Usage(inputTokens: 5, outputTokens: 3),
      );

      expect(message.text, 'Hello, world!');
    });

    test('toolUseBlocks returns only tool use blocks', () {
      const message = Message(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [
          TextBlock(text: 'Let me help.'),
          ToolUseBlock(id: 'tu_1', name: 'tool1', input: {}),
          ToolUseBlock(id: 'tu_2', name: 'tool2', input: {}),
        ],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.toolUse,
        usage: Usage(inputTokens: 10, outputTokens: 20),
      );

      expect(message.toolUseBlocks, hasLength(2));
      expect(message.hasToolUse, isTrue);
    });

    test('thinkingBlocks returns only thinking blocks', () {
      const message = Message(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [
          ThinkingBlock(thinking: 'Thinking 1...', signature: 'sig1'),
          TextBlock(text: 'Response'),
          ThinkingBlock(thinking: 'Thinking 2...', signature: 'sig2'),
        ],
        model: 'claude-sonnet-4-6',
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
        role: MessageRole.assistant,
        content: [TextBlock(text: 'Done')],
        model: 'claude-sonnet-4-6',
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
        role: MessageRole.assistant,
        content: [TextBlock(text: 'Truncated...')],
        model: 'claude-sonnet-4-6',
        stopReason: StopReason.maxTokens,
        usage: Usage(inputTokens: 5, outputTokens: 100),
      );

      expect(message.isMaxTokens, isTrue);
      expect(message.isEndTurn, isFalse);
    });
  });

  group('MessageRole', () {
    test('fromJson converts known values', () {
      expect(MessageRole.fromJson('user'), MessageRole.user);
      expect(MessageRole.fromJson('assistant'), MessageRole.assistant);
    });

    test('fromJson throws for unknown values', () {
      expect(() => MessageRole.fromJson('invalid'), throwsFormatException);
      expect(() => MessageRole.fromJson('admin'), throwsFormatException);
      expect(() => MessageRole.fromJson(''), throwsFormatException);
    });

    test('toJson returns correct values', () {
      expect(MessageRole.user.toJson(), 'user');
      expect(MessageRole.assistant.toJson(), 'assistant');
    });

    test('round-trip preserves value', () {
      for (final value in MessageRole.values) {
        expect(MessageRole.fromJson(value.toJson()), value);
      }
    });

    test('value property returns correct string', () {
      expect(MessageRole.user.value, 'user');
      expect(MessageRole.assistant.value, 'assistant');
    });
  });

  group('RefusalCategory', () {
    test('fromJson parses known values', () {
      expect(RefusalCategory.fromJson('cyber'), RefusalCategory.cyber);
      expect(RefusalCategory.fromJson('bio'), RefusalCategory.bio);
    });

    test('fromJson returns unknown for unrecognized values', () {
      expect(RefusalCategory.fromJson('new_policy'), RefusalCategory.unknown);
      expect(RefusalCategory.fromJson(''), RefusalCategory.unknown);
    });

    test('round-trip preserves value', () {
      for (final value in RefusalCategory.values) {
        expect(RefusalCategory.fromJson(value.toJson()), value);
      }
    });
  });

  group('RefusalStopDetails', () {
    test('fromJson parses all fields', () {
      final json = {
        'type': 'refusal',
        'category': 'cyber',
        'explanation': 'Content blocked.',
      };

      final details = RefusalStopDetails.fromJson(json);

      expect(details.type, 'refusal');
      expect(details.category, RefusalCategory.cyber);
      expect(details.explanation, 'Content blocked.');
    });

    test('fromJson handles null category and explanation', () {
      final json = {'type': 'refusal', 'category': null, 'explanation': null};

      final details = RefusalStopDetails.fromJson(json);

      expect(details.type, 'refusal');
      expect(details.category, isNull);
      expect(details.explanation, isNull);
    });

    test('toJson always emits category and explanation', () {
      const details = RefusalStopDetails();

      final json = details.toJson();

      expect(json['type'], 'refusal');
      expect(json.containsKey('category'), isTrue);
      expect(json['category'], isNull);
      expect(json.containsKey('explanation'), isTrue);
      expect(json['explanation'], isNull);
    });

    test('toJson round-trip', () {
      const details = RefusalStopDetails(
        category: RefusalCategory.bio,
        explanation: 'Bio content.',
      );

      final roundTripped = RefusalStopDetails.fromJson(details.toJson());

      expect(roundTripped, details);
    });

    test('equality', () {
      const a = RefusalStopDetails(
        category: RefusalCategory.cyber,
        explanation: 'Blocked.',
      );
      const b = RefusalStopDetails(
        category: RefusalCategory.cyber,
        explanation: 'Blocked.',
      );
      const c = RefusalStopDetails(
        category: RefusalCategory.bio,
        explanation: 'Different.',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
