import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CompletionPrompt', () {
    test('text() creates single text prompt', () {
      const prompt = CompletionPrompt.text('Hello');
      expect(prompt, isA<CompletionPromptText>());
      expect(prompt.toJson(), 'Hello');
    });

    test('texts() creates multiple text prompts', () {
      const prompt = CompletionPrompt.texts(['Hello', 'World']);
      expect(prompt, isA<CompletionPromptTexts>());
      expect(prompt.toJson(), ['Hello', 'World']);
    });

    test('tokens() creates token prompt', () {
      const prompt = CompletionPrompt.tokens([1234, 5678]);
      expect(prompt, isA<CompletionPromptTokens>());
      expect(prompt.toJson(), [1234, 5678]);
    });

    test('tokenLists() creates multiple token prompts', () {
      const prompt = CompletionPrompt.tokenLists([
        [1, 2],
        [3, 4],
      ]);
      expect(prompt, isA<CompletionPromptTokenLists>());
      expect(prompt.toJson(), [
        [1, 2],
        [3, 4],
      ]);
    });

    test('fromJson parses string', () {
      final prompt = CompletionPrompt.fromJson('Hello');
      expect(prompt, isA<CompletionPromptText>());
      expect((prompt as CompletionPromptText).text, 'Hello');
    });

    test('fromJson parses string list', () {
      final prompt = CompletionPrompt.fromJson(['Hello', 'World']);
      expect(prompt, isA<CompletionPromptTexts>());
      expect((prompt as CompletionPromptTexts).texts, ['Hello', 'World']);
    });

    test('fromJson parses int list', () {
      final prompt = CompletionPrompt.fromJson([1234, 5678]);
      expect(prompt, isA<CompletionPromptTokens>());
      expect((prompt as CompletionPromptTokens).tokens, [1234, 5678]);
    });

    test('fromJson parses nested int lists', () {
      final prompt = CompletionPrompt.fromJson([
        [1, 2],
        [3, 4],
      ]);
      expect(prompt, isA<CompletionPromptTokenLists>());
    });

    test('fromJson parses empty list as texts', () {
      final prompt = CompletionPrompt.fromJson(<String>[]);
      expect(prompt, isA<CompletionPromptTexts>());
      expect((prompt as CompletionPromptTexts).texts, isEmpty);
    });

    test('equality works correctly', () {
      expect(
        const CompletionPromptText('Hello'),
        equals(const CompletionPromptText('Hello')),
      );
      expect(
        const CompletionPromptText('Hello'),
        isNot(equals(const CompletionPromptText('World'))),
      );
      expect(
        const CompletionPromptTexts(['a', 'b']),
        equals(const CompletionPromptTexts(['a', 'b'])),
      );
      expect(
        const CompletionPromptTokens([1, 2]),
        equals(const CompletionPromptTokens([1, 2])),
      );
    });
  });

  group('StopSequence', () {
    test('single() creates single stop', () {
      const stop = StopSequence.single('\n');
      expect(stop, isA<StopSequenceSingle>());
      expect(stop.toJson(), '\n');
    });

    test('multiple() creates multiple stops', () {
      const stop = StopSequence.multiple(['\n', '###', 'END']);
      expect(stop, isA<StopSequenceMultiple>());
      expect(stop.toJson(), ['\n', '###', 'END']);
    });

    test('fromJson parses string', () {
      final stop = StopSequence.fromJson('\n');
      expect(stop, isA<StopSequenceSingle>());
      expect((stop as StopSequenceSingle).stop, '\n');
    });

    test('fromJson parses list', () {
      final stop = StopSequence.fromJson(['stop1', 'stop2']);
      expect(stop, isA<StopSequenceMultiple>());
      expect((stop as StopSequenceMultiple).stops, ['stop1', 'stop2']);
    });

    test('fromJson throws on invalid value', () {
      expect(() => StopSequence.fromJson(123), throwsFormatException);
    });

    test('equality works correctly', () {
      expect(
        const StopSequenceSingle('\n'),
        equals(const StopSequenceSingle('\n')),
      );
      expect(
        const StopSequenceMultiple(['a', 'b']),
        equals(const StopSequenceMultiple(['a', 'b'])),
      );
    });
  });

  group('CompletionRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'model': 'gpt-3.5-turbo-instruct',
        'prompt': 'Say hello',
        'max_tokens': 100,
        'temperature': 0.7,
        'stop': '\n',
        'n': 1,
      };

      final request = CompletionRequest.fromJson(json);

      expect(request.model, 'gpt-3.5-turbo-instruct');
      expect(request.prompt, isA<CompletionPromptText>());
      expect((request.prompt! as CompletionPromptText).text, 'Say hello');
      expect(request.maxTokens, 100);
      expect(request.temperature, 0.7);
      expect(request.stop, isA<StopSequenceSingle>());
      expect(request.n, 1);
    });

    test('fromJson parses array prompt', () {
      final json = {
        'model': 'gpt-3.5-turbo-instruct',
        'prompt': ['Hello', 'World'],
        'stop': ['\n', '###'],
      };

      final request = CompletionRequest.fromJson(json);

      expect(request.prompt, isA<CompletionPromptTexts>());
      expect(request.stop, isA<StopSequenceMultiple>());
    });

    test('toJson serializes correctly', () {
      const request = CompletionRequest(
        model: 'gpt-3.5-turbo-instruct',
        prompt: CompletionPromptText('Hello'),
        maxTokens: 50,
        stop: StopSequenceSingle('\n'),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-3.5-turbo-instruct');
      expect(json['prompt'], 'Hello');
      expect(json['max_tokens'], 50);
      expect(json['stop'], '\n');
    });

    test('toJson serializes array values', () {
      const request = CompletionRequest(
        model: 'gpt-3.5-turbo-instruct',
        prompt: CompletionPromptTexts(['Hello', 'World']),
        stop: StopSequenceMultiple(['end1', 'end2']),
      );

      final json = request.toJson();

      expect(json['prompt'], ['Hello', 'World']);
      expect(json['stop'], ['end1', 'end2']);
    });

    test('toJson omits null fields', () {
      const request = CompletionRequest(model: 'gpt-3.5-turbo-instruct');

      final json = request.toJson();

      expect(json['model'], 'gpt-3.5-turbo-instruct');
      expect(json.containsKey('prompt'), isFalse);
      expect(json.containsKey('stop'), isFalse);
      expect(json.containsKey('max_tokens'), isFalse);
    });
  });

  group('Completion', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'cmpl-abc123',
        'object': 'text_completion',
        'created': 1699472000,
        'model': 'gpt-3.5-turbo-instruct',
        'choices': [
          {'index': 0, 'text': 'Hello, world!', 'finish_reason': 'stop'},
        ],
        'usage': {
          'prompt_tokens': 5,
          'completion_tokens': 10,
          'total_tokens': 15,
        },
      };

      final completion = Completion.fromJson(json);

      expect(completion.id, 'cmpl-abc123');
      expect(completion.object, 'text_completion');
      expect(completion.created, 1699472000);
      expect(completion.model, 'gpt-3.5-turbo-instruct');
      expect(completion.choices.length, 1);
      expect(completion.choices[0].text, 'Hello, world!');
      expect(completion.choices[0].finishReason, FinishReason.stop);
      expect(completion.text, 'Hello, world!');
    });

    test('fromJson handles missing usage (streaming chunks)', () {
      final json = {
        'id': 'cmpl-abc123',
        'object': 'text_completion',
        'created': 1699472000,
        'model': 'gpt-3.5-turbo-instruct',
        'choices': [
          {'index': 0, 'text': 'Hello', 'finish_reason': null},
        ],
      };

      final completion = Completion.fromJson(json);

      expect(completion.usage, isNull);
      expect(completion.text, 'Hello');
    });

    test('toJson serializes correctly', () {
      const completion = Completion(
        id: 'cmpl-abc123',
        object: 'text_completion',
        created: 1699472000,
        model: 'gpt-3.5-turbo-instruct',
        choices: [
          CompletionChoice(
            index: 0,
            text: 'Hello',
            finishReason: FinishReason.stop,
          ),
        ],
        usage: Usage(promptTokens: 5, completionTokens: 10, totalTokens: 15),
      );

      final json = completion.toJson();

      expect(json['id'], 'cmpl-abc123');
      expect(((json['choices'] as List)[0] as Map)['text'], 'Hello');
    });

    test('fromJson handles missing created (provider compatibility)', () {
      final json = {
        'id': 'cmpl-abc123',
        'object': 'text_completion',
        // No 'created' field
        'model': 'gpt-3.5-turbo-instruct',
        'choices': [
          {'index': 0, 'text': 'Hello', 'finish_reason': 'stop'},
        ],
      };

      final completion = Completion.fromJson(json);

      expect(completion.created, isNull);
      expect(completion.text, 'Hello');
    });

    test('toJson omits created when null', () {
      const completion = Completion(
        id: 'cmpl-abc123',
        object: 'text_completion',
        model: 'gpt-3.5-turbo-instruct',
        choices: [CompletionChoice(index: 0, text: 'Hello')],
      );

      final json = completion.toJson();

      expect(json.containsKey('created'), isFalse);
      expect(json['id'], 'cmpl-abc123');
    });

    test('text returns null for empty choices list', () {
      const completion = Completion(
        id: 'cmpl-abc123',
        object: 'text_completion',
        model: 'gpt-3.5-turbo-instruct',
        choices: [],
      );

      expect(completion.text, isNull);
    });

    test('toJson omits null usage', () {
      const completion = Completion(
        id: 'cmpl-abc123',
        object: 'text_completion',
        created: 1699472000,
        model: 'gpt-3.5-turbo-instruct',
        choices: [CompletionChoice(index: 0, text: 'Hello')],
      );

      final json = completion.toJson();

      expect(json.containsKey('usage'), isFalse);
    });
  });

  group('CompletionChoice', () {
    test('fromJson parses correctly', () {
      final json = {'index': 0, 'text': 'Hello', 'finish_reason': 'length'};

      final choice = CompletionChoice.fromJson(json);

      expect(choice.index, 0);
      expect(choice.text, 'Hello');
      expect(choice.finishReason, FinishReason.length);
    });

    test('handles null finish_reason', () {
      final json = {'index': 0, 'text': 'Hello'};

      final choice = CompletionChoice.fromJson(json);

      expect(choice.finishReason, isNull);
    });
  });
}
