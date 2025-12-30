import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MessageRole', () {
    test('messageRoleFromString returns correct enum values', () {
      expect(messageRoleFromString('system'), MessageRole.system);
      expect(messageRoleFromString('user'), MessageRole.user);
      expect(messageRoleFromString('assistant'), MessageRole.assistant);
      expect(messageRoleFromString('tool'), MessageRole.tool);
    });

    test('messageRoleFromString defaults to user for unknown values', () {
      expect(messageRoleFromString('unknown'), MessageRole.user);
      expect(messageRoleFromString(null), MessageRole.user);
    });

    test('messageRoleToString returns correct string values', () {
      expect(messageRoleToString(MessageRole.system), 'system');
      expect(messageRoleToString(MessageRole.user), 'user');
      expect(messageRoleToString(MessageRole.assistant), 'assistant');
      expect(messageRoleToString(MessageRole.tool), 'tool');
    });
  });

  group('ChatMessage', () {
    test('fromJson creates message correctly', () {
      final json = {'role': 'user', 'content': 'Hello, world!'};

      final message = ChatMessage.fromJson(json);

      expect(message.role, MessageRole.user);
      expect(message.content, 'Hello, world!');
      expect(message.images, isNull);
      expect(message.toolCalls, isNull);
    });

    test('toJson converts message correctly', () {
      const message = ChatMessage(
        role: MessageRole.assistant,
        content: 'Hello!',
      );

      final json = message.toJson();

      expect(json['role'], 'assistant');
      expect(json['content'], 'Hello!');
      expect(json.containsKey('images'), isFalse);
    });

    test('factory constructors work correctly', () {
      const system = ChatMessage.system('You are helpful');
      expect(system.role, MessageRole.system);
      expect(system.content, 'You are helpful');

      const user = ChatMessage.user('Hi');
      expect(user.role, MessageRole.user);
      expect(user.content, 'Hi');

      const assistant = ChatMessage.assistant('Hello');
      expect(assistant.role, MessageRole.assistant);
      expect(assistant.content, 'Hello');

      const tool = ChatMessage.tool('{"result": 42}');
      expect(tool.role, MessageRole.tool);
      expect(tool.content, '{"result": 42}');
    });

    test('copyWith preserves values when not specified', () {
      const original = ChatMessage(role: MessageRole.user, content: 'Original');

      final copied = original.copyWith(content: 'Modified');

      expect(copied.role, MessageRole.user);
      expect(copied.content, 'Modified');
    });

    test('equality works correctly', () {
      const message1 = ChatMessage(role: MessageRole.user, content: 'Hello');
      const message2 = ChatMessage(role: MessageRole.user, content: 'Hello');
      const message3 = ChatMessage(
        role: MessageRole.assistant,
        content: 'Hello',
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });

    test('handles tool calls', () {
      final toolCalls = [
        const ToolCall(
          function: ToolCallFunction(
            name: 'get_weather',
            arguments: {'city': 'London'},
          ),
        ),
      ];

      final message = ChatMessage(
        role: MessageRole.assistant,
        content: '',
        toolCalls: toolCalls,
      );

      final json = message.toJson();
      expect(json['tool_calls'], isNotNull);
      expect((json['tool_calls'] as List).length, 1);

      final restored = ChatMessage.fromJson(json);
      expect(restored.toolCalls?.length, 1);
      expect(restored.toolCalls!.first.function?.name, 'get_weather');
    });
  });
}
