import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ContentBlockConversion', () {
    test('TextBlock converts to TextInputBlock preserving text', () {
      const block = TextBlock(text: 'Hello, Claude!');

      final input = block.toInputBlock();

      expect(input, isA<TextInputBlock>());
      expect((input as TextInputBlock).text, 'Hello, Claude!');
    });

    test('TextBlock with citations converts preserving citations', () {
      const block = TextBlock(
        text: 'Earth orbits the Sun.',
        citations: [
          CharLocationCitation(
            citedText: 'Earth orbits the Sun.',
            documentIndex: 0,
            documentTitle: 'Astronomy',
            startCharIndex: 0,
            endCharIndex: 22,
          ),
        ],
      );

      final input = block.toInputBlock();

      expect(input, isA<TextInputBlock>());
      final textInput = input as TextInputBlock;
      expect(textInput.text, 'Earth orbits the Sun.');
      expect(textInput.citations, isNotNull);
      expect(textInput.citations, hasLength(1));
    });

    test('ThinkingBlock converts to ThinkingInputBlock verbatim', () {
      const block = ThinkingBlock(
        thinking: 'reasoning...',
        signature: 'sig123',
      );

      final input = block.toInputBlock();

      expect(input, isA<ThinkingInputBlock>());
      final thinkingInput = input as ThinkingInputBlock;
      expect(thinkingInput.thinking, 'reasoning...');
      expect(thinkingInput.signature, 'sig123');
    });

    test(
      'RedactedThinkingBlock converts to RedactedThinkingInputBlock verbatim',
      () {
        const block = RedactedThinkingBlock(data: 'opaque');

        final input = block.toInputBlock();

        expect(input, isA<RedactedThinkingInputBlock>());
        expect((input as RedactedThinkingInputBlock).data, 'opaque');
      },
    );

    test('ToolUseBlock converts to ToolUseInputBlock preserving fields', () {
      const block = ToolUseBlock(
        id: 'tu_1',
        name: 'get_weather',
        input: {'city': 'San Francisco'},
      );

      final input = block.toInputBlock();

      expect(input, isA<ToolUseInputBlock>());
      final toolUseInput = input as ToolUseInputBlock;
      expect(toolUseInput.id, 'tu_1');
      expect(toolUseInput.name, 'get_weather');
      expect(toolUseInput.input, {'city': 'San Francisco'});
    });

    test('ServerToolUseBlock converts to ServerToolUseInputBlock preserving '
        'fields', () {
      const block = ServerToolUseBlock(
        id: 'stu_1',
        name: 'web_search',
        input: {'query': 'dart sdk'},
      );

      final input = block.toInputBlock();

      expect(input, isA<ServerToolUseInputBlock>());
      final serverToolUseInput = input as ServerToolUseInputBlock;
      expect(serverToolUseInput.id, 'stu_1');
      expect(serverToolUseInput.name, 'web_search');
      expect(serverToolUseInput.input, {'query': 'dart sdk'});
    });

    test('CompactionBlock converts to CompactionInputBlock preserving '
        'encryptedContent', () {
      const block = CompactionBlock(
        content: 'Conversation summary',
        encryptedContent: 'enc_payload_xyz',
      );

      final input = block.toInputBlock();

      expect(input, isA<CompactionInputBlock>());
      final compactionInput = input as CompactionInputBlock;
      expect(compactionInput.content, 'Conversation summary');
      expect(compactionInput.encryptedContent, 'enc_payload_xyz');
    });

    test('unknown response block converts to UnknownInputContentBlock '
        'preserving raw payload', () {
      final json = {'type': 'made_up_block', 'foo': 'bar'};
      final block = ContentBlock.fromJson(json);
      expect(block, isA<UnknownContentBlock>());

      final input = block.toInputBlock();

      expect(input, isA<UnknownInputContentBlock>());
      expect(input.toJson(), json);
    });
  });

  group('MessageExtensions.toInputMessage', () {
    Message buildMessage() => const Message(
      id: 'msg_1',
      role: MessageRole.assistant,
      content: [
        ThinkingBlock(thinking: 'Let me think...', signature: 'sig123'),
        TextBlock(text: 'Here is my answer.'),
        ToolUseBlock(id: 'tu_1', name: 'get_weather', input: {'city': 'NYC'}),
      ],
      model: 'claude-sonnet-4-6',
      stopReason: StopReason.toolUse,
      usage: Usage(inputTokens: 10, outputTokens: 20),
    );

    test('returns an assistant InputMessage', () {
      final inputMessage = buildMessage().toInputMessage();

      expect(inputMessage.role, MessageRole.assistant);
      expect(inputMessage.content, isA<BlocksMessageContent>());
    });

    test('preserves block order: thinking, text, tool use', () {
      final inputMessage = buildMessage().toInputMessage();
      final blocks = (inputMessage.content as BlocksMessageContent).blocks;

      expect(blocks, hasLength(3));
      expect(blocks[0], isA<ThinkingInputBlock>());
      expect(blocks[1], isA<TextInputBlock>());
      expect(blocks[2], isA<ToolUseInputBlock>());
    });

    test('serialized request JSON has thinking block first with signature', () {
      final inputMessage = buildMessage().toInputMessage();
      final json = inputMessage.toJson();
      final content = json['content'] as List;

      final firstBlock = content.first as Map<String, dynamic>;
      expect(firstBlock['type'], 'thinking');
      expect(firstBlock['thinking'], 'Let me think...');
      expect(firstBlock['signature'], 'sig123');
    });
  });

  group('MessageExtensions getters', () {
    Message buildMessage() => const Message(
      id: 'msg_1',
      role: MessageRole.assistant,
      content: [
        ThinkingBlock(thinking: 'Let me think...', signature: 'sig123'),
        TextBlock(text: 'Here is my answer.'),
        ToolUseBlock(id: 'tu_1', name: 'get_weather', input: {'city': 'NYC'}),
      ],
      model: 'claude-sonnet-4-6',
      stopReason: StopReason.toolUse,
      usage: Usage(inputTokens: 10, outputTokens: 20),
    );

    test('text concatenates text blocks', () {
      expect(buildMessage().text, 'Here is my answer.');
    });

    test('thinkingBlocks and hasThinking', () {
      final message = buildMessage();
      expect(message.thinkingBlocks, hasLength(1));
      expect(message.hasThinking, isTrue);
    });

    test('toolUseBlocks and hasToolUse', () {
      final message = buildMessage();
      expect(message.toolUseBlocks, hasLength(1));
      expect(message.hasToolUse, isTrue);
    });
  });
}
