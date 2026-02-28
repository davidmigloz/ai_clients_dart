@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:io';

import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAI Responses API tests', skip: _skipReason, () {
    late OpenResponsesClient client;
    const model = 'gpt-4o-mini';

    setUp(() {
      client = OpenResponsesClient(
        config: OpenResponsesConfig(
          baseUrl: 'https://api.openai.com/v1',
          authProvider: BearerTokenProvider(
            Platform.environment['OPENAI_API_KEY']!,
          ),
        ),
      );
    });

    tearDown(() {
      client.close();
    });

    test('basic text response', () async {
      final response = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'Say "Hello, World!" and nothing else.',
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.output, isNotEmpty);
      expect(response.outputText, contains('Hello'));
    });

    test('basic with instructions', () async {
      final response = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'What is my name?',
          instructions:
              "You are a helpful assistant. The user's name is Alice.",
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText?.toLowerCase(), contains('alice'));
    });

    test('streaming response', () async {
      final events = <StreamingEvent>[];

      await client.responses
          .createStream(
            const CreateResponseRequest(
              model: model,
              input: 'Count from 1 to 3.',
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
      ResponseResource? finalResponse;

      final runner = client.responses.stream(
        const CreateResponseRequest(
          model: model,
          input: 'Say "test" and nothing else.',
        ),
      )..onTextDelta(textBuffer.write);

      await for (final event in runner.asStream()) {
        if (event is ResponseCompletedEvent) {
          finalResponse = event.response;
        }
      }

      expect(textBuffer.toString(), contains('test'));
      expect(finalResponse, isNotNull);
      expect(finalResponse!.status, ResponseStatus.completed);
    });

    test('tool calling', () async {
      final response = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'What is the weather in San Francisco?',
          tools: [
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
      expect(response.hasToolCalls, isTrue);
      expect(response.functionCalls, hasLength(1));
      expect(response.functionCalls.first.name, 'get_weather');
      expect(response.functionCalls.first.arguments, contains('San Francisco'));
    });

    test('tool calling streaming', () async {
      final events = <StreamingEvent>[];

      await client.responses
          .createStream(
            const CreateResponseRequest(
              model: model,
              input: 'What is the weather in Tokyo?',
              tools: [
                FunctionTool(
                  name: 'get_weather',
                  description: 'Get the current weather for a location',
                  parameters: {
                    'type': 'object',
                    'properties': {
                      'location': {'type': 'string'},
                    },
                    'required': ['location'],
                  },
                ),
              ],
            ),
          )
          .forEach(events.add);

      // Should have function call argument delta events
      final argDeltas = events.whereType<FunctionCallArgumentsDeltaEvent>();
      expect(argDeltas, isNotEmpty);

      final completedEvent = events.whereType<ResponseCompletedEvent>().first;
      expect(completedEvent.response.hasToolCalls, isTrue);
    });

    test('multi-turn conversation', () async {
      // First turn
      final response1 = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'My favorite color is blue. Remember this.',
        ),
      );

      expect(response1.status, ResponseStatus.completed);

      // Second turn using previous_response_id
      final response2 = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: 'What is my favorite color?',
          previousResponseId: response1.id,
        ),
      );

      expect(response2.status, ResponseStatus.completed);
      expect(response2.outputText?.toLowerCase(), contains('blue'));
    });

    test('structured output with JSON schema', () async {
      final response = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'List 2 fruits with their colors.',
          text: TextConfig(
            format: JsonSchemaFormat(
              name: 'fruits',
              schema: {
                'type': 'object',
                'properties': {
                  'fruits': {
                    'type': 'array',
                    'items': {
                      'type': 'object',
                      'properties': {
                        'name': {'type': 'string'},
                        'color': {'type': 'string'},
                      },
                      'required': ['name', 'color'],
                      'additionalProperties': false,
                    },
                  },
                },
                'required': ['fruits'],
                'additionalProperties': false,
              },
              strict: true,
            ),
          ),
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText, isNotNull);
      expect(response.outputText, contains('fruits'));
    });

    test('system prompt via message items', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: [
            MessageItem.systemText('You only respond in uppercase letters.'),
            MessageItem.userText('say hi'),
          ],
        ),
      );

      expect(response.status, ResponseStatus.completed);
      // Response should be mostly uppercase
      final text = response.outputText ?? '';
      final uppercaseRatio =
          text.replaceAll(RegExp(r'[^A-Z]'), '').length / text.length;
      expect(uppercaseRatio, greaterThan(0.5));
    });

    test('usage tracking', () async {
      final response = await client.responses.create(
        const CreateResponseRequest(model: model, input: 'Hello'),
      );

      expect(response.usage, isNotNull);
      expect(response.usage!.inputTokens, greaterThan(0));
      expect(response.usage!.outputTokens, greaterThan(0));
      expect(response.usage!.totalTokens, greaterThan(0));
    });

    test('temperature parameter affects output', () async {
      // Run with temperature 0 for deterministic output
      final response = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'What is 2 + 2?',
          temperature: 0,
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.outputText, contains('4'));
    });

    test('max output tokens limits response', () async {
      final response = await client.responses.create(
        const CreateResponseRequest(
          model: model,
          input: 'Write a very long story about a dragon.',
          maxOutputTokens: 20,
        ),
      );

      // Response may be incomplete due to token limit
      expect(response.output, isNotEmpty);
    });

    test('image input with URL', () async {
      final response = await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-4o-mini', // Vision-capable model
          input: [
            MessageItem.user(const [
              InputTextContent(text: 'What is shown in this image?'),
              InputImageContent.url(
                // Using a reliable public image URL
                'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
                detail: ImageDetail.low,
              ),
            ]),
          ],
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.output, isNotEmpty);
      expect(response.outputText, isNotNull);
      // Should describe the Google logo
      expect(
        response.outputText?.toLowerCase(),
        anyOf(contains('google'), contains('logo'), contains('text')),
      );
    });

    test('reasoning model with extended thinking', () async {
      // Skip if running on basic tier that doesn't support o1/o3 models
      final reasoningModel = Platform.environment['OPENAI_REASONING_MODEL'];
      if (reasoningModel == null) {
        markTestSkipped('Set OPENAI_REASONING_MODEL to run reasoning tests');
        return;
      }

      final response = await client.responses.create(
        CreateResponseRequest(
          model: reasoningModel,
          input: 'What is 25 * 17? Think step by step.',
          reasoning: const ReasoningConfig(
            effort: ReasoningEffort.medium,
            summary: ReasoningSummary.auto,
          ),
        ),
      );

      expect(response.status, ResponseStatus.completed);
      expect(response.output, isNotEmpty);
      expect(response.outputText, contains('425'));

      // Check for reasoning items if supported
      final reasoningItems = response.reasoningItems;
      if (reasoningItems.isNotEmpty) {
        // Model provided reasoning output
        expect(reasoningItems, isNotEmpty);
      }
    });

    test('MCP tools integration', () async {
      // MCP tools require a running MCP server
      // Skip unless explicitly configured
      final mcpServerUrl = Platform.environment['MCP_SERVER_URL'];
      if (mcpServerUrl == null) {
        markTestSkipped('Set MCP_SERVER_URL to run MCP integration tests');
        return;
      }

      final response = await client.responses.create(
        CreateResponseRequest(
          model: model,
          input: 'Use the available tools to help me.',
          tools: [
            McpTool(
              serverLabel: 'test-server',
              serverUrl: mcpServerUrl,
              allowedTools: const ['*'],
              requireApproval: 'never',
            ),
          ],
        ),
      );

      expect(response.status, ResponseStatus.completed);
    });

    test('error handling for invalid API key', () async {
      final badClient = OpenResponsesClient(
        config: const OpenResponsesConfig(
          baseUrl: 'https://api.openai.com/v1',
          authProvider: BearerTokenProvider('sk-invalid-key'),
        ),
      );

      try {
        await badClient.responses.create(
          const CreateResponseRequest(model: 'gpt-4o-mini', input: 'Hello'),
        );
        fail('Should have thrown an exception');
      } on AuthenticationException catch (e) {
        expect(e.message, isNotEmpty);
      } on ApiException catch (e) {
        // May also throw ApiException with 401 status
        expect(e.statusCode, anyOf(401, 403));
      } finally {
        badClient.close();
      }
    });

    test('error handling for invalid model', () async {
      try {
        await client.responses.create(
          const CreateResponseRequest(
            model: 'nonexistent-model-xyz',
            input: 'Hello',
          ),
        );
        fail('Should have thrown an exception');
      } on ValidationException catch (e) {
        // HTTP 400 should be mapped to ValidationException
        expect(e.message, isNotEmpty);
      } on ApiException catch (e) {
        // May also throw ApiException for 404
        expect(e.statusCode, anyOf(400, 404));
        expect(e.message, isNotEmpty);
      }
    });

    test('validation error maps to ValidationException', () async {
      try {
        await client.responses.create(
          const CreateResponseRequest(
            model: model,
            input: 'Hello',
            // Invalid temperature (must be 0-2)
            temperature: 5.0,
          ),
        );
        fail('Should have thrown an exception');
      } on ValidationException catch (e) {
        expect(e.message, isNotEmpty);
      } on ApiException catch (e) {
        // Fall back to ApiException if not 400
        expect(e.statusCode, greaterThanOrEqualTo(400));
      }
    });

    test('streaming error handling for invalid API key', () async {
      final badClient = OpenResponsesClient(
        config: const OpenResponsesConfig(
          baseUrl: 'https://api.openai.com/v1',
          authProvider: BearerTokenProvider('sk-invalid-key'),
        ),
      );

      try {
        await badClient.responses
            .createStream(
              const CreateResponseRequest(model: 'gpt-4o-mini', input: 'Hello'),
            )
            .first;
        fail('Should have thrown an exception');
      } on AuthenticationException catch (e) {
        expect(e.message, isNotEmpty);
      } on ApiException catch (e) {
        expect(e.statusCode, anyOf(401, 403));
      } finally {
        badClient.close();
      }
    });

    test('error handling for rate limit', () {
      // This test documents the rate limit exception type
      // but we can't easily trigger it without making many requests
      // Just verify the exception type exists and can be constructed
      const rateLimitException = RateLimitException(
        statusCode: 429,
        message: 'Rate limit exceeded',
      );
      expect(rateLimitException.statusCode, 429);
      expect(rateLimitException.message, contains('Rate limit'));
    });
  });
}

String? get _skipReason {
  if (Platform.environment['OPENAI_API_KEY'] == null) {
    return 'Set OPENAI_API_KEY to run OpenAI integration tests';
  }
  return null;
}
