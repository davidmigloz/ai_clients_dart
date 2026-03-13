@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:io';

import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('Ollama Responses API tests', skip: _skipReason, () {
    late OpenResponsesClient client;
    late String model;

    setUpAll(() {
      client = OpenResponsesClient(
        config: const OpenResponsesConfig(
          baseUrl: 'http://localhost:11434/v1',
          // No auth needed for local Ollama
        ),
      );
      model = Platform.environment['OLLAMA_MODEL'] ?? 'llama3.2';
    });

    tearDownAll(() {
      client.close();
    });

    test('basic text response', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('Say "Hello" and nothing else.'),
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.output, isNotEmpty);
      expect(response.outputText, isNotNull);
    });

    test('basic with instructions', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('What is 2 + 2?'),
          instructions: 'You are a math tutor. Always show your work.',
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText, contains('4'));
    });

    test('streaming response', () async {
      final events = <StreamingEvent>[];

      await client.responses
          .createStream(
            CreateResponseRequest(
              model: model,
              input: const ResponseTextInput('Count from 1 to 3.'),
            ),
          )
          .forEach(events.add);

      expect(events, isNotEmpty);
      expect(events.first, isA<ResponseCreatedEvent>());
      expect(events.last, isA<ResponseCompletedEvent>());

      // Should have text delta events
      final textDeltas = events
          .whereType<OutputTextDeltaEvent>()
          .map((e) => e.delta)
          .join();
      expect(textDeltas, isNotEmpty);
    });

    test('streaming with builder pattern', () async {
      final textBuffer = StringBuffer();

      final runner = client.responses.stream(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('Say "test".'),
        ),
      )..onTextDelta(textBuffer.write);

      final finalResponse = await runner.finalResponse;

      expect(textBuffer.toString(), isNotEmpty);
      expect(finalResponse, isNotNull);
      expect(finalResponse!.status, ResponseStatus.completed);
    });

    test('tool calling', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('What is the weather in Paris?'),
          tools: const [
            FunctionTool(
              name: 'get_weather',
              description: 'Get the current weather for a location',
              parameters: {
                'type': 'object',
                'properties': {
                  'location': {
                    'type': 'string',
                    'description': 'The city name',
                  },
                },
                'required': ['location'],
              },
            ),
          ],
        ),
      );

      expect(response.status, ResponseStatus.completed);
      // Ollama tool support depends on the model
      if (response.hasToolCalls) {
        expect(response.functionCalls, isNotEmpty);
        expect(response.functionCalls.first.name, 'get_weather');
      }
    });

    test('multi-message input', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: ResponseItemsInput([
            MessageItem.systemText('You are a helpful assistant.'),
            MessageItem.userText('What is the capital of France?'),
          ]),
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText?.toLowerCase(), contains('paris'));
    });

    test('usage tracking', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('Hello'),
        ),
      );

      // Ollama may or may not return usage depending on version
      if (response.usage != null) {
        expect(response.usage!.inputTokens, greaterThanOrEqualTo(0));
        expect(response.usage!.outputTokens, greaterThanOrEqualTo(0));
      }
    });

    test('temperature parameter', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('What is 1 + 1?'),
          temperature: 0,
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText, contains('2'));
    });

    test('response extensions work correctly', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: const ResponseTextInput('Say hello.'),
        ),
      );

      expect(response.isCompleted, isTrue);
      expect(response.isFailed, isFalse);
      expect(response.outputText, isNotNull);
    });
  });
}

String? get _skipReason {
  // Check if Ollama is likely running by checking for common indicators
  // In CI, you might set OLLAMA_HOST or similar
  final ollamaHost = Platform.environment['OLLAMA_HOST'];
  final runOllamaTests = Platform.environment['RUN_OLLAMA_TESTS'];

  if (ollamaHost != null || runOllamaTests == 'true') {
    return null; // Run tests
  }

  return 'Set OLLAMA_HOST or RUN_OLLAMA_TESTS=true to run Ollama integration tests';
}
