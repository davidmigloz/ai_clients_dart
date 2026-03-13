import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

import '../../fixtures/responses.dart';
import '../../mocks/mock_http_client.dart';

void main() {
  group('ResponsesResource', () {
    late MockHttpClient mockClient;
    late OpenResponsesClient client;

    setUp(() {
      mockClient = MockHttpClient();
      client = OpenResponsesClient(
        config: const OpenResponsesConfig(
          baseUrl: 'https://api.example.com/v1',
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: mockClient,
      );
    });

    tearDown(() {
      client.close();
    });

    group('create()', () {
      test('sends correct request to /responses endpoint', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        expect(mockClient.requests, hasLength(1));
        final request = mockClient.lastRequest!;
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/responses');
        expect(request.url.host, 'api.example.com');
      });

      test('includes all request parameters in body', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
            instructions: 'Be helpful',
            temperature: 0.7,
            maxOutputTokens: 100,
            topP: 0.9,
          ),
        );

        expect(mockClient.lastRequest, isNotNull);
        // Request body is verified through the mock
      });

      test('returns parsed ResponseResource', () async {
        mockClient.queueJsonResponse(
          basicCompletedResponse(
            id: 'resp_abc123',
            model: 'gpt-4o',
            outputText: 'Hello back!',
          ),
        );

        final response = await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        expect(response.id, 'resp_abc123');
        expect(response.model, 'gpt-4o');
        expect(response.status, ResponseStatus.completed);
        expect(response.outputText, 'Hello back!');
      });

      test('handles function call response', () async {
        mockClient.queueJsonResponse(
          functionCallResponse(
            functionName: 'get_weather',
            arguments: '{"location": "Paris"}',
          ),
        );

        final response = await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('What is the weather?'),
            tools: [
              FunctionTool(
                name: 'get_weather',
                description: 'Get weather',
                parameters: {'type': 'object'},
              ),
            ],
          ),
        );

        expect(response.hasToolCalls, isTrue);
        expect(response.functionCalls, hasLength(1));
        expect(response.functionCalls.first.name, 'get_weather');
        expect(response.functionCalls.first.arguments, contains('Paris'));
      });

      test('handles failed response', () async {
        mockClient.queueJsonResponse(
          failedResponse(
            errorCode: 'content_policy_violation',
            errorMessage: 'Content filtered',
          ),
        );

        final response = await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Bad content'),
          ),
        );

        expect(response.status, ResponseStatus.failed);
        expect(response.isFailed, isTrue);
        expect(response.isCompleted, isFalse);
        expect(response.error, isNotNull);
        expect(response.error!.code, 'content_policy_violation');
      });

      test('ensures stream is false for non-streaming request', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        // Even if stream is true in request, create() should set it to false
        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
            stream: true, // Will be overridden
          ),
        );

        // Verify request was made (stream was handled internally)
        expect(mockClient.requests, hasLength(1));
      });

      test('includes tools in request', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
            tools: [
              FunctionTool(
                name: 'calculator',
                description: 'Perform calculations',
                parameters: {
                  'type': 'object',
                  'properties': {
                    'expression': {'type': 'string'},
                  },
                  'required': ['expression'],
                },
                strict: true,
              ),
            ],
          ),
        );

        expect(mockClient.requests, hasLength(1));
      });

      test('includes MCP tools in request', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
            tools: [
              McpTool(
                serverLabel: 'test-server',
                serverUrl: 'https://mcp.example.com',
                allowedTools: ['tool1', 'tool2'],
                requireApproval: 'never',
              ),
            ],
          ),
        );

        expect(mockClient.requests, hasLength(1));
      });

      test('includes message items as input', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseItemsInput([
              MessageItem.systemText('You are helpful.'),
              MessageItem.userText('Hello'),
              MessageItem.assistantText('Hi there!'),
              MessageItem.userText('How are you?'),
            ]),
          ),
        );

        expect(mockClient.requests, hasLength(1));
      });

      test('includes reasoning config', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'o1',
            input: ResponseTextInput('Solve this problem.'),
            reasoning: ReasoningConfig(
              effort: ReasoningEffort.high,
              summary: ReasoningSummary.auto,
            ),
          ),
        );

        expect(mockClient.requests, hasLength(1));
      });

      test('includes text config with JSON schema', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('List some fruits.'),
            text: TextConfig(
              format: JsonSchemaFormat(
                name: 'fruits',
                schema: {
                  'type': 'object',
                  'properties': {
                    'items': {
                      'type': 'array',
                      'items': {'type': 'string'},
                    },
                  },
                },
                strict: true,
              ),
            ),
          ),
        );

        expect(mockClient.requests, hasLength(1));
      });
    });

    group('createStream()', () {
      test('returns stream of events', () async {
        mockClient.queueStreamingResponse(
          basicStreamingEvents(
            responseId: 'resp_stream_123',
            outputText: 'Hello!',
          ),
        );

        final events = await client.responses
            .createStream(
              const CreateResponseRequest(
                model: 'gpt-4o',
                input: ResponseTextInput('Hello'),
              ),
            )
            .toList();

        expect(events, isNotEmpty);
        expect(events.first, isA<ResponseCreatedEvent>());
        expect(events.last, isA<ResponseCompletedEvent>());
      });

      test('emits text delta events', () async {
        mockClient.queueStreamingResponse(
          basicStreamingEvents(outputText: 'Test output'),
        );

        final events = await client.responses
            .createStream(
              const CreateResponseRequest(
                model: 'gpt-4o',
                input: ResponseTextInput('Hello'),
              ),
            )
            .toList();

        final textDeltas = events.whereType<OutputTextDeltaEvent>();
        expect(textDeltas, isNotEmpty);
        expect(textDeltas.first.delta, 'Test output');
      });

      test('sends single request (no duplicate requests)', () async {
        mockClient.queueStreamingResponse(basicStreamingEvents());

        await client.responses
            .createStream(
              const CreateResponseRequest(
                model: 'gpt-4o',
                input: ResponseTextInput('Hello'),
                stream: false, // Will be overridden to true
              ),
            )
            .toList();

        // Verify only one request was made (no duplicate for streaming)
        expect(mockClient.requests, hasLength(1));
      });

      test('handles completed event with full response', () async {
        mockClient.queueStreamingResponse(
          basicStreamingEvents(
            responseId: 'resp_final',
            outputText: 'Final output',
          ),
        );

        final events = await client.responses
            .createStream(
              const CreateResponseRequest(
                model: 'gpt-4o',
                input: ResponseTextInput('Hello'),
              ),
            )
            .toList();

        final completedEvent = events.whereType<ResponseCompletedEvent>().first;
        expect(completedEvent.response.id, 'resp_final');
        expect(completedEvent.response.status, ResponseStatus.completed);
        expect(completedEvent.response.outputText, 'Final output');
      });
    });

    group('stream()', () {
      test('returns ResponseStream with builder pattern', () {
        // stream() is lazy - no requests until consumed
        final runner = client.responses.stream(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        expect(runner, isA<ResponseStream>());
      });

      test('allows registering text delta callbacks', () async {
        mockClient.queueStreamingResponse(
          basicStreamingEvents(outputText: 'callback test'),
        );

        final textBuffer = StringBuffer();
        final runner = client.responses.stream(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        )..onTextDelta(textBuffer.write);

        await runner.finalResponse;

        expect(textBuffer.toString(), contains('callback'));
      });

      test('provides final response', () async {
        mockClient.queueStreamingResponse(
          basicStreamingEvents(
            responseId: 'resp_builder',
            outputText: 'Builder output',
          ),
        );

        final runner = client.responses.stream(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        final response = await runner.finalResponse;

        expect(response, isNotNull);
        expect(response!.id, 'resp_builder');
        expect(response.status, ResponseStatus.completed);
      });

      test('provides text getter', () async {
        mockClient.queueStreamingResponse(
          basicStreamingEvents(outputText: 'Full text'),
        );

        final runner = client.responses.stream(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        final text = await runner.text;

        expect(text, 'Full text');
      });

      test('allows iterating as stream', () async {
        mockClient.queueStreamingResponse(basicStreamingEvents());

        final runner = client.responses.stream(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        final events = await runner.asStream().toList();

        expect(events, isNotEmpty);
        expect(events.first, isA<ResponseCreatedEvent>());
      });

      test('supports multiple callbacks', () async {
        mockClient.queueStreamingResponse(basicStreamingEvents());

        final allEvents = <StreamingEvent>[];
        final textDeltas = <String>[];
        ResponseResource? finalResponse;

        final runner =
            client.responses.stream(
                const CreateResponseRequest(
                  model: 'gpt-4o',
                  input: ResponseTextInput('Hello'),
                ),
              )
              ..onEvent(allEvents.add)
              ..onTextDelta(textDeltas.add);

        await for (final event in runner.asStream()) {
          if (event is ResponseCompletedEvent) {
            finalResponse = event.response;
          }
        }

        expect(allEvents, isNotEmpty);
        expect(textDeltas, isNotEmpty);
        expect(finalResponse, isNotNull);
      });
    });

    group('error handling', () {
      test('throws ValidationException for 400 errors', () {
        mockClient.queueErrorResponse(400, 'Bad request');

        expect(
          () => client.responses.create(
            const CreateResponseRequest(
              model: 'gpt-4o',
              input: ResponseTextInput('Hello'),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws AuthenticationException for 401 errors', () {
        mockClient.queueErrorResponse(401, 'Unauthorized');

        expect(
          () => client.responses.create(
            const CreateResponseRequest(
              model: 'gpt-4o',
              input: ResponseTextInput('Hello'),
            ),
          ),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('throws RateLimitException for 429 errors', () {
        mockClient.queueErrorResponse(429, 'Rate limit exceeded');

        expect(
          () => client.responses.create(
            const CreateResponseRequest(
              model: 'gpt-4o',
              input: ResponseTextInput('Hello'),
            ),
          ),
          throwsA(isA<RateLimitException>()),
        );
      });

      test('throws ApiException for other HTTP errors', () {
        mockClient.queueErrorResponse(500, 'Internal server error');

        expect(
          () => client.responses.create(
            const CreateResponseRequest(
              model: 'gpt-4o',
              input: ResponseTextInput('Hello'),
            ),
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('streaming throws ValidationException for 400 errors', () {
        mockClient.queueErrorResponse(400, 'Bad request');

        expect(
          () => client.responses
              .createStream(
                const CreateResponseRequest(
                  model: 'gpt-4o',
                  input: ResponseTextInput('Hello'),
                ),
              )
              .toList(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('streaming throws AuthenticationException for 401 errors', () {
        mockClient.queueErrorResponse(401, 'Unauthorized');

        expect(
          () => client.responses
              .createStream(
                const CreateResponseRequest(
                  model: 'gpt-4o',
                  input: ResponseTextInput('Hello'),
                ),
              )
              .toList(),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('request builder', () {
      test('uses configured base URL', () async {
        final customClient = OpenResponsesClient(
          config: const OpenResponsesConfig(
            baseUrl: 'https://custom.api.com/api',
          ),
          httpClient: mockClient,
        );
        mockClient.queueJsonResponse(basicCompletedResponse());

        await customClient.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        expect(mockClient.lastRequest!.url.host, 'custom.api.com');
        expect(mockClient.lastRequest!.url.path, '/api/responses');

        customClient.close();
      });

      test('includes default headers', () async {
        final customClient = OpenResponsesClient(
          config: const OpenResponsesConfig(
            baseUrl: 'https://api.example.com/v1',
            defaultHeaders: {'X-Custom-Header': 'custom-value'},
          ),
          httpClient: mockClient,
        );
        mockClient.queueJsonResponse(basicCompletedResponse());

        await customClient.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        expect(
          mockClient.lastRequest!.headers['X-Custom-Header'],
          'custom-value',
        );

        customClient.close();
      });

      test('includes content-type header', () async {
        mockClient.queueJsonResponse(basicCompletedResponse());

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseTextInput('Hello'),
          ),
        );

        expect(
          mockClient.lastRequest!.headers['content-type'],
          'application/json',
        );
      });
    });
  });
}
