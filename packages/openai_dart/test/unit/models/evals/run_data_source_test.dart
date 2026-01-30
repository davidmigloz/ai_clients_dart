import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EvalRunDataSource', () {
    test('fromJson parses jsonl type', () {
      final json = {
        'type': 'jsonl',
        'source': {'type': 'file_id', 'file_id': 'file-abc123'},
      };

      final dataSource = EvalRunDataSource.fromJson(json);

      expect(dataSource, isA<JsonlRunDataSource>());
      final jsonl = dataSource as JsonlRunDataSource;
      expect(jsonl.type, 'jsonl');
      expect(jsonl.source, isA<JsonlFileSource>());
    });

    test('fromJson parses completions type', () {
      final json = {
        'type': 'completions',
        'source': {'type': 'stored_completions'},
        'model': 'gpt-4o-mini',
      };

      final dataSource = EvalRunDataSource.fromJson(json);

      expect(dataSource, isA<CompletionsRunDataSource>());
      final completions = dataSource as CompletionsRunDataSource;
      expect(completions.type, 'completions');
      expect(completions.model, 'gpt-4o-mini');
    });

    test('fromJson parses responses type', () {
      final json = {
        'type': 'responses',
        'source': {'type': 'file_id', 'file_id': 'file-123'},
        'model': 'gpt-4o',
        'input_messages': {
          'type': 'template',
          'template': [
            {'role': 'user', 'content': '{{item.prompt}}'},
          ],
        },
        'sampling_params': {'temperature': 0.7, 'max_completion_tokens': 100},
      };

      final dataSource = EvalRunDataSource.fromJson(json);

      expect(dataSource, isA<ResponsesRunDataSource>());
      final responses = dataSource as ResponsesRunDataSource;
      expect(responses.type, 'responses');
      expect(responses.model, 'gpt-4o');
      expect(responses.inputMessages, isA<InputMessagesTemplate>());
      expect(
        (responses.inputMessages! as InputMessagesTemplate).template,
        hasLength(1),
      );
      expect(responses.samplingParams?.temperature, 0.7);
    });

    test('fromJson throws on unknown type', () {
      final json = {'type': 'unknown'};

      expect(
        () => EvalRunDataSource.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('JsonlRunDataSource', () {
    test('static factory creates file source', () {
      final dataSource = EvalRunDataSource.jsonlFile('file-abc123');

      expect(dataSource, isA<JsonlRunDataSource>());
      expect(dataSource.source, isA<JsonlFileSource>());
      expect((dataSource.source as JsonlFileSource).fileId, 'file-abc123');
    });

    test('static factory creates content source', () {
      final dataSource = EvalRunDataSource.jsonlContent([
        {'prompt': 'Hello', 'expected': 'Hi'},
      ]);

      expect(dataSource, isA<JsonlRunDataSource>());
      expect(dataSource.source, isA<JsonlContentSource>());
      expect((dataSource.source as JsonlContentSource).content, hasLength(1));
    });

    test('toJson serializes correctly', () {
      const dataSource = JsonlRunDataSource(
        source: JsonlFileSource(fileId: 'file-abc123'),
      );

      final json = dataSource.toJson();

      expect(json['type'], 'jsonl');
      final source = json['source'] as Map<String, dynamic>;
      expect(source['type'], 'file_id');
      expect(source['file_id'], 'file-abc123');
    });
  });

  group('JsonlSource', () {
    test('fromJson parses file_id type', () {
      final json = {'type': 'file_id', 'file_id': 'file-123'};

      final source = JsonlSource.fromJson(json);

      expect(source, isA<JsonlFileSource>());
      expect((source as JsonlFileSource).fileId, 'file-123');
    });

    test('fromJson parses file_content type', () {
      final json = {
        'type': 'file_content',
        'content': [
          {'a': 1},
          {'b': 2},
        ],
      };

      final source = JsonlSource.fromJson(json);

      expect(source, isA<JsonlContentSource>());
      expect((source as JsonlContentSource).content, hasLength(2));
    });
  });

  group('ResponsesRunDataSource', () {
    test('static factory creates correctly', () {
      final dataSource = EvalRunDataSource.responses(
        source: const ResponsesFileSource(fileId: 'file-123'),
        model: 'gpt-4o',
        inputMessages: InputMessages.template([
          const InputMessage.user('{{item.prompt}}'),
        ]),
        samplingParams: const EvalSamplingParams(
          temperature: 0.5,
          maxCompletionsTokens: 200,
        ),
      );

      expect(dataSource, isA<ResponsesRunDataSource>());
      expect(dataSource.model, 'gpt-4o');
      expect(dataSource.inputMessages, isA<InputMessagesTemplate>());
      expect(
        (dataSource.inputMessages! as InputMessagesTemplate).template,
        hasLength(1),
      );
      expect(dataSource.samplingParams?.temperature, 0.5);
    });

    test('toJson serializes correctly', () {
      final dataSource = ResponsesRunDataSource(
        source: const ResponsesFileSource(fileId: 'file-abc'),
        model: 'gpt-4o-mini',
        inputMessages: InputMessages.template([
          const InputMessage.user('Test'),
        ]),
        samplingParams: const EvalSamplingParams(temperature: 0.8),
      );

      final json = dataSource.toJson();

      expect(json['type'], 'responses');
      expect((json['source'] as Map<String, dynamic>)['file_id'], 'file-abc');
      expect(json['model'], 'gpt-4o-mini');
      final inputMessages = json['input_messages'] as Map<String, dynamic>;
      expect(inputMessages['type'], 'template');
      expect(inputMessages['template'], hasLength(1));
      expect(
        (json['sampling_params'] as Map<String, dynamic>)['temperature'],
        0.8,
      );
    });
  });

  group('InputMessage', () {
    test('fromJson parses correctly', () {
      final json = {'role': 'user', 'content': 'Hello {{item.name}}'};

      final message = InputMessage.fromJson(json);

      expect(message.role, 'user');
      expect(message.content, 'Hello {{item.name}}');
    });

    test('named constructors create correct roles', () {
      expect(const InputMessage.system('test').role, 'system');
      expect(const InputMessage.user('test').role, 'user');
      expect(const InputMessage.assistant('test').role, 'assistant');
    });
  });

  group('EvalSamplingParams', () {
    test('fromJson parses correctly', () {
      final json = {
        'max_completions_tokens': 100,
        'temperature': 0.7,
        'top_p': 0.9,
        'seed': 42,
        'reasoning_effort': 'medium',
      };

      final params = EvalSamplingParams.fromJson(json);

      expect(params.maxCompletionsTokens, 100);
      expect(params.temperature, 0.7);
      expect(params.topP, 0.9);
      expect(params.seed, 42);
      expect(params.reasoningEffort, 'medium');
    });

    test('toJson serializes correctly', () {
      const params = EvalSamplingParams(
        maxCompletionsTokens: 200,
        temperature: 0.5,
        topP: 0.95,
      );

      final json = params.toJson();

      expect(json['max_completions_tokens'], 200);
      expect(json['temperature'], 0.5);
      expect(json['top_p'], 0.95);
      expect(json.containsKey('seed'), isFalse);
    });
  });
}
