import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatMessage', () {
    group('SystemMessage', () {
      test('creates system message with content', () {
        final message = ChatMessage.system('You are a helpful assistant.');
        expect(message.role, 'system');
        expect(message, isA<ChatMessage>());
        // Verify by serialization
        final json = message.toJson();
        expect(json['content'], 'You are a helpful assistant.');
      });

      test('serializes to JSON', () {
        final message = ChatMessage.system('You are a helpful assistant.');
        final json = message.toJson();
        expect(json['role'], 'system');
        expect(json['content'], 'You are a helpful assistant.');
      });

      test('deserializes from JSON', () {
        final json = {
          'role': 'system',
          'content': 'You are a helpful assistant.',
        };
        final message = ChatMessage.fromJson(json);
        expect(message.role, 'system');
        expect(message.toJson()['content'], 'You are a helpful assistant.');
      });

      test('copyWith creates a copy with new content', () {
        const original = SystemMessage(content: 'Be helpful.');
        final copied = original.copyWith(content: 'Be concise.');

        expect(copied.content, 'Be concise.');
      });

      test('copyWith preserves content when not specified', () {
        const original = SystemMessage(content: 'Be helpful.');
        final copied = original.copyWith();

        expect(copied.content, 'Be helpful.');
        expect(copied, equals(original));
      });
    });

    group('UserMessage', () {
      test('creates user message with text content', () {
        final message = ChatMessage.user('Hello!');
        expect(message.role, 'user');
        expect(message.toJson()['content'], 'Hello!');
      });

      test('creates user message with multimodal content', () {
        final message = ChatMessage.userMultimodal([
          ContentPart.text('What is in this image?'),
          ContentPart.imageUrl('https://example.com/image.jpg'),
        ]);
        expect(message.role, 'user');
        final json = message.toJson();
        expect(json['content'], isList);
        final content = json['content'] as List;
        expect(content, hasLength(2));
      });

      test('serializes text message to JSON', () {
        final message = ChatMessage.user('Hello!');
        final json = message.toJson();
        expect(json['role'], 'user');
        expect(json['content'], 'Hello!');
      });

      test('serializes multimodal message to JSON', () {
        final message = ChatMessage.userMultimodal([
          ContentPart.text('Describe this.'),
          ContentPart.imageUrl('https://example.com/img.png'),
        ]);
        final json = message.toJson();
        expect(json['role'], 'user');
        expect(json['content'], isList);
        final content = json['content'] as List;
        expect(content, hasLength(2));
        expect((content[0] as Map)['type'], 'text');
        expect((content[0] as Map)['text'], 'Describe this.');
        expect((content[1] as Map)['type'], 'image_url');
        // image_url is nested: {"url": "..."}
        expect(
          ((content[1] as Map)['image_url'] as Map)['url'],
          'https://example.com/img.png',
        );
      });

      test('deserializes text message from JSON', () {
        final json = {'role': 'user', 'content': 'Hello!'};
        final message = ChatMessage.fromJson(json);
        expect(message.role, 'user');
        expect(message.toJson()['content'], 'Hello!');
      });

      test('deserializes multimodal message from JSON', () {
        final json = {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'What is this?'},
            {
              'type': 'image_url',
              'image_url': {'url': 'https://example.com/img.png'},
            },
          ],
        };
        final message = ChatMessage.fromJson(json);
        expect(message.role, 'user');
        final messageJson = message.toJson();
        final content = messageJson['content'] as List;
        expect(content, hasLength(2));
        expect((content[0] as Map)['text'], 'What is this?');
        // image_url is nested: {"url": "..."}
        expect(
          ((content[1] as Map)['image_url'] as Map)['url'],
          'https://example.com/img.png',
        );
      });

      test('copyWith with new string content', () {
        const original = UserMessage(content: 'Hello');
        final copied = original.copyWith(content: 'Goodbye');

        expect(copied.content, 'Goodbye');
      });

      test('copyWith with new multimodal content', () {
        const original = UserMessage(content: 'Hello');
        final copied = original.copyWith(
          content: [ContentPart.text('New text')],
        );

        expect(copied.content, isA<List<ContentPart>>());
        final parts = copied.content as List<ContentPart>;
        expect(parts.first, isA<TextContentPart>());
        expect((parts.first as TextContentPart).text, 'New text');
      });

      test('copyWith preserves content when not specified', () {
        const original = UserMessage(content: 'Hello');
        final copied = original.copyWith();

        expect(copied.content, 'Hello');
        expect(copied, equals(original));
      });
    });

    group('AssistantMessage', () {
      test('creates assistant message with content', () {
        final message = ChatMessage.assistant('Hello! How can I help?');
        expect(message.role, 'assistant');
        expect(message.toJson()['content'], 'Hello! How can I help?');
      });

      test('creates assistant message with tool calls', () {
        final message = ChatMessage.assistant(
          null,
          toolCalls: [
            const ToolCall(
              id: 'call_123',
              function: FunctionCall(
                name: 'get_weather',
                arguments: '{"location": "Paris"}',
              ),
            ),
          ],
        );
        expect(message.role, 'assistant');
        final json = message.toJson();
        expect(json['tool_calls'], isList);
        final firstToolCall =
            (json['tool_calls'] as List).first as Map<String, dynamic>;
        expect(firstToolCall['id'], 'call_123');
      });

      test('serializes to JSON with tool calls', () {
        final message = ChatMessage.assistant(
          'Let me check the weather.',
          toolCalls: [
            const ToolCall(
              id: 'call_456',
              function: FunctionCall(
                name: 'get_weather',
                arguments: '{"location": "London"}',
              ),
            ),
          ],
        );
        final json = message.toJson();
        expect(json['role'], 'assistant');
        expect(json['content'], 'Let me check the weather.');
        expect(json['tool_calls'], isList);
        final firstToolCall =
            (json['tool_calls'] as List).first as Map<String, dynamic>;
        expect(firstToolCall['id'], 'call_456');
      });

      test('deserializes from JSON', () {
        final json = {
          'role': 'assistant',
          'content': 'Here is your answer.',
          'tool_calls': [
            {
              'id': 'call_789',
              'function': {'name': 'search', 'arguments': '{"q": "test"}'},
            },
          ],
        };
        final message = ChatMessage.fromJson(json);
        expect(message.role, 'assistant');
        expect(message.toJson()['content'], 'Here is your answer.');
        expect(message.toJson()['tool_calls'], isList);
      });

      test('copyWith with changes', () {
        const original = AssistantMessage(content: 'Hello', prefix: true);
        final copied = original.copyWith(content: 'Goodbye', prefix: false);

        expect(copied.content, 'Goodbye');
        expect(copied.prefix, false);
        expect(copied.toolCalls, isNull);
      });

      test('copyWith preserves values when not specified', () {
        const original = AssistantMessage(
          content: 'Hello',
          toolCalls: [
            ToolCall(
              id: 'call_1',
              function: FunctionCall(name: 'fn', arguments: '{}'),
            ),
          ],
          prefix: true,
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
        expect(copied.content, 'Hello');
        expect(copied.toolCalls, hasLength(1));
        expect(copied.prefix, true);
      });

      test('copyWith can set nullable fields to null', () {
        const original = AssistantMessage(content: 'Hello', prefix: true);
        final copied = original.copyWith(content: null, prefix: null);

        expect(copied.content, isNull);
        expect(copied.prefix, isNull);
      });
    });

    group('ToolMessage', () {
      test('creates tool message', () {
        final message = ChatMessage.tool(
          toolCallId: 'call_123',
          content: '{"temperature": 22}',
        );
        expect(message.role, 'tool');
        final json = message.toJson();
        expect(json['tool_call_id'], 'call_123');
        expect(json['content'], '{"temperature": 22}');
      });

      test('serializes to JSON', () {
        final message = ChatMessage.tool(
          toolCallId: 'call_123',
          content: '{"result": "success"}',
        );
        final json = message.toJson();
        expect(json['role'], 'tool');
        expect(json['tool_call_id'], 'call_123');
        expect(json['content'], '{"result": "success"}');
      });

      test('deserializes from JSON', () {
        final json = {
          'role': 'tool',
          'tool_call_id': 'call_456',
          'content': '{"data": 42}',
        };
        final message = ChatMessage.fromJson(json);
        expect(message.role, 'tool');
        final messageJson = message.toJson();
        expect(messageJson['tool_call_id'], 'call_456');
        expect(messageJson['content'], '{"data": 42}');
      });

      test('copyWith with changes', () {
        const original = ToolMessage(
          toolCallId: 'call_1',
          content: 'result',
          name: 'my_tool',
        );
        final copied = original.copyWith(
          toolCallId: 'call_2',
          content: 'new result',
        );

        expect(copied.toolCallId, 'call_2');
        expect(copied.content, 'new result');
        expect(copied.name, 'my_tool');
      });

      test('copyWith preserves values when not specified', () {
        const original = ToolMessage(
          toolCallId: 'call_1',
          content: 'result',
          name: 'my_tool',
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
        expect(copied.toolCallId, 'call_1');
        expect(copied.content, 'result');
        expect(copied.name, 'my_tool');
      });

      test('copyWith can set nullable name to null', () {
        const original = ToolMessage(
          toolCallId: 'call_1',
          content: 'result',
          name: 'my_tool',
        );
        final copied = original.copyWith(name: null);

        expect(copied.name, isNull);
        expect(copied.toolCallId, 'call_1');
        expect(copied.content, 'result');
      });
    });
  });
}
