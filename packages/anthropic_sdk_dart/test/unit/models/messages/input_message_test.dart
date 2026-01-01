import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InputMessage', () {
    group('factory constructors', () {
      test('user() creates user message with text', () {
        final message = InputMessage.user('Hello');

        expect(message.role, MessageRole.user);
        expect(message.content, isA<TextMessageContent>());
        expect((message.content as TextMessageContent).text, 'Hello');
      });

      test('assistant() creates assistant message with text', () {
        final message = InputMessage.assistant('Hi there');

        expect(message.role, MessageRole.assistant);
        expect(message.content, isA<TextMessageContent>());
        expect((message.content as TextMessageContent).text, 'Hi there');
      });

      test('userBlocks() creates user message with blocks', () {
        final message = InputMessage.userBlocks([
          InputContentBlock.text('Hello'),
        ]);

        expect(message.role, MessageRole.user);
        expect(message.content, isA<BlocksMessageContent>());
        expect((message.content as BlocksMessageContent).blocks, hasLength(1));
      });

      test('assistantBlocks() creates assistant message with blocks', () {
        final message = InputMessage.assistantBlocks([
          InputContentBlock.text('Response'),
        ]);

        expect(message.role, MessageRole.assistant);
        expect(message.content, isA<BlocksMessageContent>());
      });
    });

    group('fromJson', () {
      test('parses user message with text content', () {
        final json = {'role': 'user', 'content': 'Hello, Claude!'};

        final message = InputMessage.fromJson(json);

        expect(message.role, MessageRole.user);
        expect(message.content, isA<TextMessageContent>());
        expect((message.content as TextMessageContent).text, 'Hello, Claude!');
      });

      test('parses assistant message with text content', () {
        final json = {'role': 'assistant', 'content': 'Hello! How can I help?'};

        final message = InputMessage.fromJson(json);

        expect(message.role, MessageRole.assistant);
        expect(
          (message.content as TextMessageContent).text,
          'Hello! How can I help?',
        );
      });

      test('parses message with blocks content', () {
        final json = {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Look at this'},
          ],
        };

        final message = InputMessage.fromJson(json);

        expect(message.content, isA<BlocksMessageContent>());
        expect((message.content as BlocksMessageContent).blocks, hasLength(1));
      });
    });

    group('toJson', () {
      test('serializes user message with text', () {
        final message = InputMessage.user('Hello');

        final json = message.toJson();

        expect(json['role'], 'user');
        expect(json['content'], 'Hello');
      });

      test('serializes assistant message', () {
        final message = InputMessage.assistant('Response');

        final json = message.toJson();

        expect(json['role'], 'assistant');
        expect(json['content'], 'Response');
      });

      test('serializes message with blocks', () {
        final message = InputMessage.userBlocks([
          InputContentBlock.text('Part 1'),
        ]);

        final json = message.toJson();

        expect(json['role'], 'user');
        expect(json['content'], isList);
        expect(json['content'], hasLength(1));
      });
    });

    group('copyWith', () {
      test('creates copy with updated role', () {
        final original = InputMessage.user('Hello');

        final copy = original.copyWith(role: MessageRole.assistant);

        expect(copy.role, MessageRole.assistant);
        expect((copy.content as TextMessageContent).text, 'Hello');
      });

      test('creates copy with updated content', () {
        final original = InputMessage.user('Hello');

        final copy = original.copyWith(content: MessageContent.text('Goodbye'));

        expect(copy.role, MessageRole.user);
        expect((copy.content as TextMessageContent).text, 'Goodbye');
      });
    });

    group('equality', () {
      test('equal messages are equal', () {
        final m1 = InputMessage.user('Hello');
        final m2 = InputMessage.user('Hello');

        expect(m1, equals(m2));
        expect(m1.hashCode, m2.hashCode);
      });

      test('different content means not equal', () {
        final m1 = InputMessage.user('Hello');
        final m2 = InputMessage.user('World');

        expect(m1, isNot(equals(m2)));
      });

      test('different role means not equal', () {
        final m1 = InputMessage.user('Hello');
        final m2 = InputMessage.assistant('Hello');

        expect(m1, isNot(equals(m2)));
      });
    });
  });

  group('MessageContent', () {
    group('text factory', () {
      test('creates TextMessageContent', () {
        final content = MessageContent.text('Hello');

        expect(content, isA<TextMessageContent>());
        expect((content as TextMessageContent).text, 'Hello');
      });
    });

    group('blocks factory', () {
      test('creates BlocksMessageContent', () {
        final content = MessageContent.blocks([
          InputContentBlock.text('Part 1'),
        ]);

        expect(content, isA<BlocksMessageContent>());
        expect((content as BlocksMessageContent).blocks, hasLength(1));
      });
    });

    group('fromJson', () {
      test('parses string as text content', () {
        final content = MessageContent.fromJson('Hello');

        expect(content, isA<TextMessageContent>());
      });

      test('parses list as blocks content', () {
        final content = MessageContent.fromJson([
          {'type': 'text', 'text': 'Hello'},
        ]);

        expect(content, isA<BlocksMessageContent>());
      });

      test('throws on invalid JSON', () {
        expect(
          () => MessageContent.fromJson(123),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
