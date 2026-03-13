@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:io';

import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('Hugging Face Responses API tests', skip: _skipReason, () {
    late OpenResponsesClient client;

    setUpAll(() {
      client = OpenResponsesClient(
        config: OpenResponsesConfig(
          baseUrl:
              Platform.environment['HF_RESPONSES_URL'] ??
              'https://evalstate-openresponses.hf.space/v1',
          authProvider: BearerTokenProvider(
            Platform.environment['HF_API_KEY']!,
          ),
        ),
      );
    });

    tearDownAll(() {
      client.close();
    });

    test('basic text response', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: _model,
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
          model: _model,
          input: const ResponseTextInput('What is 5 + 3?'),
          instructions:
              'You are a math assistant. Give only the numeric answer.',
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText, contains('8'));
    });

    // TODO(open_responses): Re-enable when upstream bug is fixed.
    // Bug in responses.js server (discovered 2025-01): streaming fails with
    // "Cannot set headers after they are sent to the client" regardless of
    // provider. Non-streaming works fine.
    // Upstream: https://huggingface.co/spaces/evalstate/openresponses
    // Track: https://github.com/anthropics/responses.js/issues (if reported)
    test(
      'streaming response',
      skip: 'Upstream responses.js bug: headers set after stream started',
      () async {
        final events = <StreamingEvent>[];

        await client.responses
            .createStream(
              CreateResponseRequest(
                model: _model,
                input: const ResponseTextInput('Count from 1 to 3.'),
              ),
            )
            .forEach(events.add);

        expect(events, isNotEmpty);

        // Should have response created event
        expect(events.whereType<ResponseCreatedEvent>(), isNotEmpty);

        // Should have response completed event
        expect(events.whereType<ResponseCompletedEvent>(), isNotEmpty);
      },
    );

    test(
      'streaming with builder pattern',
      skip: 'responses.js bug: headers set after stream started',
      () async {
        final textBuffer = StringBuffer();

        final runner = client.responses.stream(
          CreateResponseRequest(
            model: _model,
            input: const ResponseTextInput('Say "test".'),
          ),
        )..onTextDelta(textBuffer.write);

        final finalResponse = await runner.finalResponse;

        expect(textBuffer.toString(), isNotEmpty);
        expect(finalResponse, isNotNull);
      },
    );

    test('tool calling', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: _model,
          input: const ResponseTextInput('What is the weather in London?'),
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
      // Tool calling support depends on the model
      if (response.hasToolCalls) {
        expect(response.functionCalls, isNotEmpty);
      }
    });

    test('multi-message input', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: _model,
          input: ResponseItemsInput([
            MessageItem.systemText('You are a geography expert.'),
            MessageItem.userText('What is the capital of Japan?'),
          ]),
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText?.toLowerCase(), contains('tokyo'));
    });

    test('structured output with JSON schema', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: _model,
          input: const ResponseTextInput('Name 2 colors.'),
          text: const TextConfig(
            format: JsonSchemaFormat(
              name: 'colors',
              schema: {
                'type': 'object',
                'properties': {
                  'colors': {
                    'type': 'array',
                    'items': {'type': 'string'},
                  },
                },
                'required': ['colors'],
              },
              strict: true,
            ),
          ),
        ),
      );

      expect(response.status, ResponseStatus.completed);
      if (response.outputText != null) {
        // May contain JSON output
        expect(response.outputText, isNotEmpty);
      }
    });

    test('response extensions', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: _model,
          input: const ResponseTextInput('Hello'),
        ),
      );

      expect(response.isCompleted, isTrue);
      expect(response.isFailed, isFalse);
    });

    test('usage tracking', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: _model,
          input: const ResponseTextInput('Hello'),
        ),
      );

      // Usage may or may not be available depending on the HF space
      if (response.usage != null) {
        expect(response.usage!.totalTokens, greaterThanOrEqualTo(0));
      }
    });
  });
}

String get _model => Platform.environment['HF_MODEL'] ?? 'openai/gpt-oss-120b';

String? get _skipReason {
  if (Platform.environment['HF_API_KEY'] == null) {
    return 'Set HF_API_KEY to run Hugging Face integration tests';
  }
  return null;
}
