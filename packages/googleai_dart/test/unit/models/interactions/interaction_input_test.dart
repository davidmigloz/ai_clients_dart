import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionInput', () {
    group('TextInput', () {
      test('factory constructor', () {
        const input = InteractionInput.text('Hello');
        expect(input, isA<TextInput>());
        expect((input as TextInput).text, 'Hello');
      });

      test('fromJson with string', () {
        final input = InteractionInput.fromJson('Hello world');
        expect(input, isA<TextInput>());
        expect((input as TextInput).text, 'Hello world');
      });

      test('toJson returns string', () {
        const input = TextInput('Hello');
        expect(input.toJson(), 'Hello');
      });

      test('round-trip preserves value', () {
        const original = TextInput('Test message');
        final json = original.toJson();
        final restored = InteractionInput.fromJson(json);
        expect(restored, isA<TextInput>());
        expect((restored as TextInput).text, 'Test message');
      });
    });

    group('ContentListInput', () {
      test('factory constructor', () {
        const input = InteractionInput.contentList([
          TextContent(text: 'Hello'),
        ]);
        expect(input, isA<ContentListInput>());
        expect((input as ContentListInput).content, hasLength(1));
      });

      test('fromJson with list of content maps', () {
        final input = InteractionInput.fromJson([
          {'type': 'text', 'text': 'Hello'},
          {'type': 'text', 'text': 'World'},
        ]);
        expect(input, isA<ContentListInput>());
        final contentList = input as ContentListInput;
        expect(contentList.content, hasLength(2));
        expect(contentList.content[0], isA<TextContent>());
        expect(contentList.content[1], isA<TextContent>());
      });

      test('fromJson with empty list', () {
        final input = InteractionInput.fromJson(<dynamic>[]);
        expect(input, isA<ContentListInput>());
        expect((input as ContentListInput).content, isEmpty);
      });

      test('toJson returns list of maps', () {
        const input = ContentListInput([TextContent(text: 'Hello')]);
        final json = input.toJson() as List<dynamic>;
        expect(json, hasLength(1));
        expect((json[0] as Map<String, dynamic>)['type'], 'text');
        expect((json[0] as Map<String, dynamic>)['text'], 'Hello');
      });

      test('round-trip preserves value', () {
        const original = ContentListInput([
          TextContent(text: 'Hello'),
          FunctionCallContent(
            id: 'call-1',
            name: 'test',
            arguments: {'key': 'value'},
          ),
        ]);
        final json = original.toJson();
        final restored = InteractionInput.fromJson(json);
        expect(restored, isA<ContentListInput>());
        final contentList = restored as ContentListInput;
        expect(contentList.content, hasLength(2));
        expect(contentList.content[0], isA<TextContent>());
        expect(contentList.content[1], isA<FunctionCallContent>());
      });
    });

    group('SingleContentInput', () {
      test('factory constructor', () {
        const input = InteractionInput.singleContent(
          TextContent(text: 'Hello'),
        );
        expect(input, isA<SingleContentInput>());
        expect((input as SingleContentInput).content, isA<TextContent>());
      });

      test('fromJson with single content map', () {
        final input = InteractionInput.fromJson({
          'type': 'text',
          'text': 'Hello',
        });
        expect(input, isA<SingleContentInput>());
        final single = input as SingleContentInput;
        expect(single.content, isA<TextContent>());
        expect((single.content as TextContent).text, 'Hello');
      });

      test('toJson returns map', () {
        const input = SingleContentInput(TextContent(text: 'Hello'));
        final json = input.toJson() as Map<String, dynamic>;
        expect(json['type'], 'text');
        expect(json['text'], 'Hello');
      });

      test('round-trip preserves value', () {
        const original = SingleContentInput(
          FunctionCallContent(
            id: 'call-1',
            name: 'test',
            arguments: {'key': 'value'},
          ),
        );
        final json = original.toJson();
        final restored = InteractionInput.fromJson(json);
        expect(restored, isA<SingleContentInput>());
        final single = restored as SingleContentInput;
        expect(single.content, isA<FunctionCallContent>());
        expect((single.content as FunctionCallContent).name, 'test');
      });
    });

    group('TurnsInput', () {
      test('factory constructor', () {
        const input = InteractionInput.turns([
          Turn(role: 'user', content: TurnTextContent('Hello')),
          Turn(role: 'model', content: TurnTextContent('Hi there')),
        ]);
        expect(input, isA<TurnsInput>());
        expect((input as TurnsInput).turns, hasLength(2));
      });

      test('fromJson with list of turn maps', () {
        final input = InteractionInput.fromJson([
          {'role': 'user', 'content': 'Hello'},
          {'role': 'model', 'content': 'Hi there'},
        ]);
        expect(input, isA<TurnsInput>());
        final turns = input as TurnsInput;
        expect(turns.turns, hasLength(2));
        expect(turns.turns[0].role, 'user');
        expect(turns.turns[1].role, 'model');
      });

      test('toJson returns list of maps', () {
        const input = TurnsInput([
          Turn(role: 'user', content: TurnTextContent('Hello')),
        ]);
        final json = input.toJson() as List<dynamic>;
        expect(json, hasLength(1));
        expect((json[0] as Map<String, dynamic>)['role'], 'user');
        expect((json[0] as Map<String, dynamic>)['content'], 'Hello');
      });

      test('round-trip preserves value', () {
        const original = TurnsInput([
          Turn(role: 'user', content: TurnTextContent('What is AI?')),
          Turn(role: 'model', content: TurnTextContent('AI is...')),
        ]);
        final json = original.toJson();
        final restored = InteractionInput.fromJson(json);
        expect(restored, isA<TurnsInput>());
        final turns = restored as TurnsInput;
        expect(turns.turns, hasLength(2));
        expect(turns.turns[0].role, 'user');
        expect(
          (turns.turns[0].content! as TurnTextContent).text,
          'What is AI?',
        );
      });
    });

    group('fromJson error handling', () {
      test('throws ArgumentError for unsupported type', () {
        expect(() => InteractionInput.fromJson(42), throwsArgumentError);
      });
    });
  });

  group('TurnContent', () {
    group('TurnTextContent', () {
      test('factory constructor', () {
        const content = TurnContent.text('Hello');
        expect(content, isA<TurnTextContent>());
        expect((content as TurnTextContent).text, 'Hello');
      });

      test('fromJson with string', () {
        final content = TurnContent.fromJson('Hello');
        expect(content, isA<TurnTextContent>());
        expect((content as TurnTextContent).text, 'Hello');
      });

      test('toJson returns string', () {
        const content = TurnTextContent('Hello');
        expect(content.toJson(), 'Hello');
      });
    });

    group('TurnContentList', () {
      test('factory constructor', () {
        const content = TurnContent.contentList([TextContent(text: 'Hello')]);
        expect(content, isA<TurnContentList>());
        expect((content as TurnContentList).content, hasLength(1));
      });

      test('fromJson with list', () {
        final content = TurnContent.fromJson([
          {'type': 'text', 'text': 'Hello'},
        ]);
        expect(content, isA<TurnContentList>());
        final list = content as TurnContentList;
        expect(list.content, hasLength(1));
        expect(list.content.first, isA<TextContent>());
      });

      test('toJson returns list of maps', () {
        const content = TurnContentList([TextContent(text: 'Hello')]);
        final json = content.toJson() as List<dynamic>;
        expect(json, hasLength(1));
        expect((json[0] as Map<String, dynamic>)['text'], 'Hello');
      });
    });

    group('fromJson error handling', () {
      test('throws ArgumentError for unsupported type', () {
        expect(() => TurnContent.fromJson(42), throwsArgumentError);
      });
    });
  });

  group('CreateModelInteractionParams with InteractionInput', () {
    test('fromJson parses text input', () {
      final json = {'model': 'gemini-2.0-flash', 'input': 'Hello'};
      final params = CreateModelInteractionParams.fromJson(json);
      expect(params.input, isA<TextInput>());
      expect((params.input! as TextInput).text, 'Hello');
    });

    test('toJson serializes InteractionInput', () {
      const params = CreateModelInteractionParams(
        model: 'gemini-2.0-flash',
        input: TextInput('Hello'),
      );
      final json = params.toJson();
      expect(json['input'], 'Hello');
    });

    test('handles null input', () {
      final json = {'model': 'gemini-2.0-flash'};
      final params = CreateModelInteractionParams.fromJson(json);
      expect(params.input, isNull);
    });
  });

  group('CreateAgentInteractionParams with InteractionInput', () {
    test('fromJson parses text input', () {
      final json = {'agent': 'deep-research', 'input': 'Research this topic'};
      final params = CreateAgentInteractionParams.fromJson(json);
      expect(params.input, isA<TextInput>());
      expect((params.input! as TextInput).text, 'Research this topic');
    });

    test('toJson serializes InteractionInput', () {
      const params = CreateAgentInteractionParams(
        agent: 'deep-research',
        input: TextInput('Research this topic'),
      );
      final json = params.toJson();
      expect(json['input'], 'Research this topic');
    });
  });
}
