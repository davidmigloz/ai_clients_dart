import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseInput', () {
    group('ResponseTextInput', () {
      test('text() construction', () {
        final input = ResponseInput.text('Hello');
        expect(input, isA<ResponseTextInput>());
        expect((input as ResponseTextInput).text, 'Hello');
      });

      test('toJson returns string', () {
        const input = ResponseTextInput('Hello');
        expect(input.toJson(), 'Hello');
      });

      test('fromJson parses string', () {
        final input = ResponseInput.fromJson('Hello');
        expect(input, isA<ResponseTextInput>());
        expect((input as ResponseTextInput).text, 'Hello');
      });

      test('round-trip', () {
        const original = ResponseTextInput('Hello world');
        final json = original.toJson();
        final restored = ResponseInput.fromJson(json);
        expect(restored, equals(original));
      });

      test('equality', () {
        const a = ResponseTextInput('Hello');
        const b = ResponseTextInput('Hello');
        const c = ResponseTextInput('World');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });
    });

    group('ResponseItemsInput', () {
      test('items() construction', () {
        final input = ResponseInput.items([MessageItem.userText('Hello')]);
        expect(input, isA<ResponseItemsInput>());
        final items = (input as ResponseItemsInput).items;
        expect(items, hasLength(1));
        expect(items.first, isA<UserMessageItem>());
      });

      test('toJson returns list', () {
        final input = ResponseItemsInput([MessageItem.userText('Hello')]);
        final json = input.toJson();
        expect(json, isList);
        final list = json as List;
        expect(list, hasLength(1));
        expect((list.first as Map<String, dynamic>)['type'], 'message');
      });

      test('fromJson parses list', () {
        final json = [
          {
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Hello'},
            ],
          },
        ];
        final input = ResponseInput.fromJson(json);
        expect(input, isA<ResponseItemsInput>());
        final items = (input as ResponseItemsInput).items;
        expect(items, hasLength(1));
        expect(items.first, isA<UserMessageItem>());
      });

      test('round-trip with multiple items', () {
        // Use parts-based content so round-trip equality works
        // (text content serializes as list, so fromJson returns parts variant)
        final original = ResponseItemsInput([
          MessageItem.user([const InputTextContent(text: 'Hello')]),
          MessageItem.assistant([const OutputTextContent(text: 'Hi there')]),
          MessageItem.user([const InputTextContent(text: 'How are you?')]),
        ]);
        final json = original.toJson();
        final restored = ResponseInput.fromJson(json);
        expect(restored, equals(original));
      });

      test('equality', () {
        final a = ResponseItemsInput([MessageItem.userText('Hello')]);
        final b = ResponseItemsInput([MessageItem.userText('Hello')]);
        final c = ResponseItemsInput([MessageItem.userText('World')]);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      });
    });

    group('fromJson dispatch', () {
      test('throws on invalid format', () {
        expect(
          () => ResponseInput.fromJson(123),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });

  group('CreateResponseRequest with ResponseInput', () {
    test('with ResponseTextInput', () {
      const request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseTextInput('Hello'),
      );
      final json = request.toJson();
      expect(json['input'], 'Hello');

      final restored = CreateResponseRequest.fromJson(json);
      expect(restored.input, isA<ResponseTextInput>());
      expect((restored.input as ResponseTextInput).text, 'Hello');
    });

    test('with ResponseItemsInput', () {
      final request = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseItemsInput([
          MessageItem.userText('Hello'),
          MessageItem.systemText('Be helpful'),
        ]),
      );
      final json = request.toJson();
      expect(json['input'], isList);

      final restored = CreateResponseRequest.fromJson(json);
      expect(restored.input, isA<ResponseItemsInput>());
      final items = (restored.input as ResponseItemsInput).items;
      expect(items, hasLength(2));
      expect(items[0], isA<UserMessageItem>());
      expect(items[1], isA<SystemMessageItem>());
    });

    test('text factory creates ResponseTextInput', () {
      final request = CreateResponseRequest.text(
        model: 'gpt-4o',
        input: 'Hello',
        instructions: 'Be helpful',
        maxOutputTokens: 100,
        temperature: 0.5,
      );
      expect(request.input, isA<ResponseTextInput>());
      expect((request.input as ResponseTextInput).text, 'Hello');
      expect(request.instructions, 'Be helpful');
      expect(request.maxOutputTokens, 100);
      expect(request.temperature, 0.5);
    });

    test('fromJson round-trip with text input', () {
      const original = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseTextInput('Hello'),
        instructions: 'Be concise',
        temperature: 0.7,
      );
      final json = original.toJson();
      final restored = CreateResponseRequest.fromJson(json);
      expect(restored.model, original.model);
      expect(restored.input, original.input);
      expect(restored.instructions, original.instructions);
      expect(restored.temperature, original.temperature);
    });

    test('fromJson round-trip with items input', () {
      // Use parts-based content for exact equality through round-trip
      final original = CreateResponseRequest(
        model: 'gpt-4o',
        input: ResponseItemsInput([
          MessageItem.user([const InputTextContent(text: 'Hello')]),
        ]),
        tools: const [FunctionTool(name: 'get_weather')],
        toolChoice: const ToolChoiceAuto(),
      );
      final json = original.toJson();
      final restored = CreateResponseRequest.fromJson(json);
      expect(restored.model, original.model);
      expect(restored.input, original.input);
      expect(restored.toolChoice, isA<ToolChoiceAuto>());
    });
  });
}
