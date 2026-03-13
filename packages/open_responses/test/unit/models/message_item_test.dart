import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('MessageItem', () {
    group('UserMessageItem', () {
      test('userText creates a user message with text content', () {
        final item = MessageItem.userText('Hello', id: 'msg_1');
        expect(item, isA<UserMessageItem>());
        final user = item as UserMessageItem;
        expect(user.id, 'msg_1');
        expect(user.role, MessageRole.user);
        expect(user.content, isA<UserMessageTextContent>());
        expect(user.content.text, 'Hello');
      });

      test('user creates a user message with parts content', () {
        final item = MessageItem.user([
          const InputTextContent(text: 'Hello'),
          const InputImageContent.url('https://example.com/img.png'),
        ]);
        expect(item, isA<UserMessageItem>());
        final user = item as UserMessageItem;
        expect(user.role, MessageRole.user);
        expect(user.content, isA<UserMessagePartsContent>());
        final parts = (user.content as UserMessagePartsContent).parts;
        expect(parts, hasLength(2));
        expect(parts[0], isA<InputTextContent>());
        expect(parts[1], isA<InputImageContent>());
      });

      test('fromJson/toJson round-trip with text content', () {
        final original = MessageItem.userText('Hi', id: 'u1');
        final json = original.toJson();
        final restored = MessageItem.fromJson(json) as UserMessageItem;
        // Text content serializes as a list, so it deserializes as parts
        expect(restored.id, 'u1');
        expect(restored.role, MessageRole.user);
        expect(restored.content.text, 'Hi');
      });

      test('fromJson/toJson round-trip with parts content', () {
        final original = MessageItem.user([
          const InputTextContent(text: 'Describe this'),
        ], id: 'u2');
        final json = original.toJson();
        final restored = MessageItem.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson parses list content format', () {
        final json = {
          'type': 'message',
          'id': 'u1',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'Hello'},
          ],
        };
        final item = MessageItem.fromJson(json);
        expect(item, isA<UserMessageItem>());
        expect((item as UserMessageItem).content.text, 'Hello');
      });

      test('fromJson parses string content format', () {
        final json = {
          'type': 'message',
          'id': 'u1',
          'role': 'user',
          'content': 'Hello',
        };
        final item = MessageItem.fromJson(json);
        expect(item, isA<UserMessageItem>());
        expect((item as UserMessageItem).content.text, 'Hello');
      });

      test('copyWith replaces content', () {
        final original = MessageItem.userText('Hello') as UserMessageItem;
        final modified = original.copyWith(
          content: const UserMessageTextContent('Goodbye'),
          id: 'new_id',
        );
        expect(modified.content.text, 'Goodbye');
        expect(modified.id, 'new_id');
      });

      test('copyWith preserves values when not specified', () {
        final original =
            MessageItem.userText(
                  'Hello',
                  id: 'u1',
                  status: ItemStatus.completed,
                )
                as UserMessageItem;
        final copy = original.copyWith();
        expect(copy.id, 'u1');
        expect(copy.content.text, 'Hello');
        expect(copy.status, ItemStatus.completed);
      });

      test('equality for identical items', () {
        final a = MessageItem.userText('Hello', id: 'u1');
        final b = MessageItem.userText('Hello', id: 'u1');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('inequality for different items', () {
        final a = MessageItem.userText('Hello');
        final b = MessageItem.userText('World');
        expect(a, isNot(equals(b)));
      });

      test('UserMessageContent.text returns joined text for parts', () {
        const content = UserMessagePartsContent([
          InputTextContent(text: 'Hello '),
          InputTextContent(text: 'World'),
        ]);
        expect(content.text, 'Hello World');
      });

      test('UserMessageContent.text returns null for non-text parts', () {
        const content = UserMessagePartsContent([
          InputImageContent.url('https://example.com/img.png'),
        ]);
        expect(content.text, isNull);
      });
    });

    group('SystemMessageItem', () {
      test('systemText creates a system message', () {
        final item = MessageItem.systemText('Be helpful', id: 'sys_1');
        expect(item, isA<SystemMessageItem>());
        final sys = item as SystemMessageItem;
        expect(sys.id, 'sys_1');
        expect(sys.role, MessageRole.system);
        expect(sys.content, 'Be helpful');
      });

      test('system creates from InputContent list', () {
        final item = MessageItem.system([
          const InputTextContent(text: 'Be '),
          const InputTextContent(text: 'helpful'),
        ]);
        expect(item, isA<SystemMessageItem>());
        expect((item as SystemMessageItem).content, 'Be helpful');
      });

      test('fromJson/toJson round-trip', () {
        final original = MessageItem.systemText('Instructions', id: 's1');
        final json = original.toJson();
        final restored = MessageItem.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson handles string content', () {
        final json = {
          'type': 'message',
          'role': 'system',
          'content': 'Be concise',
        };
        final item = MessageItem.fromJson(json) as SystemMessageItem;
        expect(item.content, 'Be concise');
      });

      test('fromJson handles list content', () {
        final json = {
          'type': 'message',
          'role': 'system',
          'content': [
            {'type': 'input_text', 'text': 'Be concise'},
          ],
        };
        final item = MessageItem.fromJson(json) as SystemMessageItem;
        expect(item.content, 'Be concise');
      });

      test('copyWith replaces content', () {
        final original = MessageItem.systemText('Old') as SystemMessageItem;
        final modified = original.copyWith(content: 'New');
        expect(modified.content, 'New');
      });

      test('equality', () {
        final a = MessageItem.systemText('Hello', id: 's1');
        final b = MessageItem.systemText('Hello', id: 's1');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('DeveloperMessageItem', () {
      test('developerText creates a developer message', () {
        final item = MessageItem.developerText('Debug info', id: 'dev_1');
        expect(item, isA<DeveloperMessageItem>());
        final dev = item as DeveloperMessageItem;
        expect(dev.id, 'dev_1');
        expect(dev.role, MessageRole.developer);
        expect(dev.content, 'Debug info');
      });

      test('developer creates from InputContent list', () {
        final item = MessageItem.developer([
          const InputTextContent(text: 'Dev '),
          const InputTextContent(text: 'instructions'),
        ]);
        expect(item, isA<DeveloperMessageItem>());
        expect((item as DeveloperMessageItem).content, 'Dev instructions');
      });

      test('fromJson/toJson round-trip', () {
        final original = MessageItem.developerText('Debug', id: 'd1');
        final json = original.toJson();
        final restored = MessageItem.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson handles string content', () {
        final json = {
          'type': 'message',
          'role': 'developer',
          'content': 'Dev note',
        };
        final item = MessageItem.fromJson(json) as DeveloperMessageItem;
        expect(item.content, 'Dev note');
      });

      test('fromJson handles list content', () {
        final json = {
          'type': 'message',
          'role': 'developer',
          'content': [
            {'type': 'input_text', 'text': 'Dev note'},
          ],
        };
        final item = MessageItem.fromJson(json) as DeveloperMessageItem;
        expect(item.content, 'Dev note');
      });

      test('copyWith replaces content', () {
        final original =
            MessageItem.developerText('Old') as DeveloperMessageItem;
        final modified = original.copyWith(content: 'New');
        expect(modified.content, 'New');
      });

      test('equality', () {
        final a = MessageItem.developerText('Hello', id: 'd1');
        final b = MessageItem.developerText('Hello', id: 'd1');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('AssistantMessageItem', () {
      test('assistantText creates an assistant message with text', () {
        final item = MessageItem.assistantText('Hi there', id: 'a_1');
        expect(item, isA<AssistantMessageItem>());
        final asst = item as AssistantMessageItem;
        expect(asst.id, 'a_1');
        expect(asst.role, MessageRole.assistant);
        expect(asst.content, isA<AssistantMessageTextContent>());
        expect(asst.content.text, 'Hi there');
      });

      test('assistant creates with output content parts', () {
        final item = MessageItem.assistant([
          const OutputTextContent(text: 'Answer'),
          const RefusalContent(refusal: 'Cannot do that'),
        ]);
        expect(item, isA<AssistantMessageItem>());
        final asst = item as AssistantMessageItem;
        expect(asst.content, isA<AssistantMessagePartsContent>());
        final parts = (asst.content as AssistantMessagePartsContent).parts;
        expect(parts, hasLength(2));
        expect(parts[0], isA<OutputTextContent>());
        expect(parts[1], isA<RefusalContent>());
      });

      test('fromJson/toJson round-trip with text content', () {
        final original = MessageItem.assistantText('Reply', id: 'a1');
        final json = original.toJson();
        final restored = MessageItem.fromJson(json) as AssistantMessageItem;
        // Text content serializes as a list, so it deserializes as parts
        expect(restored.id, 'a1');
        expect(restored.role, MessageRole.assistant);
        expect(restored.content.text, 'Reply');
      });

      test('fromJson/toJson round-trip with parts content', () {
        final original = MessageItem.assistant([
          const OutputTextContent(text: 'Answer'),
        ], id: 'a2');
        final json = original.toJson();
        final restored = MessageItem.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson parses string content', () {
        final json = {
          'type': 'message',
          'id': 'a1',
          'role': 'assistant',
          'content': 'Hello',
        };
        final item = MessageItem.fromJson(json) as AssistantMessageItem;
        expect(item.content.text, 'Hello');
      });

      test('fromJson parses list content', () {
        final json = {
          'type': 'message',
          'id': 'a1',
          'role': 'assistant',
          'content': [
            {'type': 'output_text', 'text': 'Hello'},
          ],
        };
        final item = MessageItem.fromJson(json) as AssistantMessageItem;
        expect(item.content.text, 'Hello');
      });

      test('copyWith replaces content', () {
        final original =
            MessageItem.assistantText('Old') as AssistantMessageItem;
        final modified = original.copyWith(
          content: const AssistantMessageTextContent('New'),
        );
        expect(modified.content.text, 'New');
      });

      test('copyWith preserves values when not specified', () {
        final original =
            MessageItem.assistantText(
                  'Hello',
                  id: 'a1',
                  status: ItemStatus.completed,
                )
                as AssistantMessageItem;
        final copy = original.copyWith();
        expect(copy.id, 'a1');
        expect(copy.content.text, 'Hello');
        expect(copy.status, ItemStatus.completed);
      });

      test('equality', () {
        final a = MessageItem.assistantText('Hi', id: 'a1');
        final b = MessageItem.assistantText('Hi', id: 'a1');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('AssistantMessageContent.text returns joined text for parts', () {
        const content = AssistantMessagePartsContent([
          OutputTextContent(text: 'Hello '),
          OutputTextContent(text: 'World'),
        ]);
        expect(content.text, 'Hello World');
      });

      test('AssistantMessageContent.text returns null for non-text parts', () {
        const content = AssistantMessagePartsContent([
          RefusalContent(refusal: 'Refused'),
        ]);
        expect(content.text, isNull);
      });
    });

    group('role dispatch', () {
      test('switch on MessageItem dispatches correctly', () {
        final items = <MessageItem>[
          MessageItem.userText('user msg'),
          MessageItem.systemText('system msg'),
          MessageItem.developerText('dev msg'),
          MessageItem.assistantText('assistant msg'),
        ];

        final roles = items.map((item) {
          return switch (item) {
            UserMessageItem() => 'user',
            SystemMessageItem() => 'system',
            DeveloperMessageItem() => 'developer',
            AssistantMessageItem() => 'assistant',
          };
        }).toList();

        expect(roles, ['user', 'system', 'developer', 'assistant']);
      });
    });

    group('Item.fromJson', () {
      test('dispatches message type', () {
        final json = {'type': 'message', 'role': 'user', 'content': 'Hello'};
        expect(Item.fromJson(json), isA<UserMessageItem>());
      });

      test('dispatches function_call type', () {
        final json = {
          'type': 'function_call',
          'call_id': 'c1',
          'name': 'fn',
          'arguments': '{}',
        };
        expect(Item.fromJson(json), isA<FunctionCallItem>());
      });

      test('dispatches function_call_output type', () {
        final json = {
          'type': 'function_call_output',
          'call_id': 'c1',
          'output': 'result',
        };
        expect(Item.fromJson(json), isA<FunctionCallOutputItem>());
      });

      test('throws on unknown type', () {
        expect(
          () => Item.fromJson({'type': 'unknown'}),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
