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

      test('system() creates system message with text', () {
        final message = InputMessage.system('Answer in French.');

        expect(message.role, MessageRole.system);
        expect(
          (message.content as TextMessageContent).text,
          'Answer in French.',
        );
        expect(message.toJson()['role'], 'system');
      });

      test('systemBlocks() creates system message with blocks', () {
        final message = InputMessage.systemBlocks([
          InputContentBlock.text('Answer in French.'),
        ]);

        expect(message.role, MessageRole.system);
        expect(message.content, isA<BlocksMessageContent>());
      });

      test('system() accepts clearAt', () {
        final message = InputMessage.system(
          'Reminder.',
          clearAt: SystemMessageClearAt.nextUserMessage,
        );

        expect(message.clearAt, SystemMessageClearAt.nextUserMessage);
      });

      test('systemBlocks() accepts clearAt', () {
        final message = InputMessage.systemBlocks([
          InputContentBlock.text('Reminder.'),
        ], clearAt: SystemMessageClearAt.nextUserMessage);

        expect(message.clearAt, SystemMessageClearAt.nextUserMessage);
      });

      test('systemEffort() creates an effort-only system message', () {
        final message = InputMessage.systemEffort(EffortLevel.low);

        expect(message.role, MessageRole.system);
        expect(message.content, isA<BlocksMessageContent>());
        expect((message.content as BlocksMessageContent).blocks, isEmpty);
        expect(message.outputConfig?.effort, EffortLevel.low);
        expect(message.toJson(), {
          'role': 'system',
          'content': <dynamic>[],
          'output_config': {'effort': 'low'},
        });
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

      test('parses system role (spec adds system to InputMessage.role)', () {
        final json = {'role': 'system', 'content': 'Answer in French.'};

        final message = InputMessage.fromJson(json);

        expect(message.role, MessageRole.system);
        expect(message.toJson()['role'], 'system');
      });

      test('parses clear_at', () {
        final json = {
          'role': 'system',
          'content': 'Reminder.',
          'clear_at': 'next_user_message',
        };

        final message = InputMessage.fromJson(json);

        expect(message.clearAt, SystemMessageClearAt.nextUserMessage);
      });

      test('parses output_config', () {
        final json = {
          'role': 'system',
          'content': <dynamic>[],
          'output_config': {'effort': 'high'},
        };

        final message = InputMessage.fromJson(json);

        expect(message.outputConfig?.effort, EffortLevel.high);
      });

      test('absence of clear_at and output_config leaves them null', () {
        final json = {'role': 'user', 'content': 'Hello'};

        final message = InputMessage.fromJson(json);

        expect(message.clearAt, isNull);
        expect(message.outputConfig, isNull);
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

      test('serializes clear_at when present', () {
        final message = InputMessage.system(
          'Reminder.',
          clearAt: SystemMessageClearAt.nextUserMessage,
        );

        expect(message.toJson()['clear_at'], 'next_user_message');
      });

      test('omits clear_at when absent', () {
        final message = InputMessage.system('Reminder.');

        expect(message.toJson().containsKey('clear_at'), isFalse);
      });

      test('serializes output_config when present', () {
        final message = InputMessage.systemEffort(EffortLevel.max);

        expect(message.toJson()['output_config'], {'effort': 'max'});
      });

      test('omits output_config when absent', () {
        final message = InputMessage.user('Hello');

        expect(message.toJson().containsKey('output_config'), isFalse);
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

      test('can set and clear clearAt', () {
        final original = InputMessage.system('Reminder.');

        final withClearAt = original.copyWith(
          clearAt: SystemMessageClearAt.nextUserMessage,
        );
        expect(withClearAt.clearAt, SystemMessageClearAt.nextUserMessage);

        final cleared = withClearAt.copyWith(clearAt: null);
        expect(cleared.clearAt, isNull);
      });

      test('can set and clear outputConfig', () {
        final original = InputMessage.system('Reminder.');

        final withConfig = original.copyWith(
          outputConfig: const SystemMessageOutputConfig(
            effort: EffortLevel.high,
          ),
        );
        expect(withConfig.outputConfig?.effort, EffortLevel.high);

        final cleared = withConfig.copyWith(outputConfig: null);
        expect(cleared.outputConfig, isNull);
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

      test('different clearAt means not equal', () {
        final m1 = InputMessage.system('Reminder.');
        final m2 = InputMessage.system(
          'Reminder.',
          clearAt: SystemMessageClearAt.nextUserMessage,
        );

        expect(m1, isNot(equals(m2)));
      });

      test('different outputConfig means not equal', () {
        final m1 = InputMessage.systemEffort(EffortLevel.low);
        final m2 = InputMessage.systemEffort(EffortLevel.high);

        expect(m1, isNot(equals(m2)));
      });
    });
  });

  group('SystemMessageClearAt', () {
    test('fromJson parses known values', () {
      expect(
        SystemMessageClearAt.fromJson('next_user_message'),
        SystemMessageClearAt.nextUserMessage,
      );
      expect(
        SystemMessageClearAt.fromJson('never'),
        SystemMessageClearAt.never,
      );
    });

    test('fromJson throws on unknown value', () {
      expect(
        () => SystemMessageClearAt.fromJson('sometimes'),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson serializes correctly', () {
      expect(
        SystemMessageClearAt.nextUserMessage.toJson(),
        'next_user_message',
      );
      expect(SystemMessageClearAt.never.toJson(), 'never');
    });
  });

  group('SystemMessageOutputConfig', () {
    test('can be created empty', () {
      const config = SystemMessageOutputConfig();

      expect(config.effort, isNull);
    });

    test('fromJson parses effort', () {
      final config = SystemMessageOutputConfig.fromJson(const {
        'effort': 'xhigh',
      });

      expect(config.effort, EffortLevel.xhigh);
    });

    test('fromJson parses empty object', () {
      final config = SystemMessageOutputConfig.fromJson(const {});

      expect(config.effort, isNull);
    });

    test('toJson omits null effort', () {
      const config = SystemMessageOutputConfig();

      expect(config.toJson(), isEmpty);
    });

    test('toJson serializes effort', () {
      const config = SystemMessageOutputConfig(effort: EffortLevel.medium);

      expect(config.toJson(), {'effort': 'medium'});
    });

    test('copyWith replaces and clears effort', () {
      const original = SystemMessageOutputConfig(effort: EffortLevel.low);

      final modified = original.copyWith(effort: EffortLevel.high);
      expect(modified.effort, EffortLevel.high);

      final cleared = original.copyWith(effort: null);
      expect(cleared.effort, isNull);
    });

    test('equality and hashCode', () {
      const c1 = SystemMessageOutputConfig(effort: EffortLevel.low);
      const c2 = SystemMessageOutputConfig(effort: EffortLevel.low);
      const c3 = SystemMessageOutputConfig(effort: EffortLevel.high);

      expect(c1, equals(c2));
      expect(c1.hashCode, c2.hashCode);
      expect(c1, isNot(equals(c3)));
    });

    test('toString includes effort', () {
      const config = SystemMessageOutputConfig(effort: EffortLevel.low);

      expect(config.toString(), contains('low'));
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

  group('MessageRole', () {
    test('round-trips user, assistant, and system', () {
      for (final role in MessageRole.values) {
        expect(MessageRole.fromJson(role.toJson()), role);
      }
      expect(MessageRole.fromJson('system'), MessageRole.system);
      expect(MessageRole.system.toJson(), 'system');
    });

    test('throws on unknown role', () {
      expect(() => MessageRole.fromJson('tool'), throwsFormatException);
    });
  });
}
