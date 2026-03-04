// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  // ==========================================================================
  // Group 1: Basic Responses
  // ==========================================================================

  group('Basic Responses', () {
    test(
      'creates a simple response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text(
              'What is 2 + 2? Reply with just the number.',
            ),
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.status, ResponseStatus.completed);
        expect(response.outputText, contains('4'));
        expect(response.usage, isNotNull);
        expect(response.usage!.inputTokens, greaterThan(0));
        expect(response.usage!.outputTokens, greaterThan(0));
      },
    );

    test(
      'creates response with instructions',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Hello'),
            instructions: 'Always respond in uppercase.',
          ),
        );

        expect(response.outputText, isNotEmpty);
        // Response should be in uppercase
        final outputText = response.outputText;
        expect(outputText, equals(outputText.toUpperCase()));
      },
    );

    test(
      'creates multi-turn conversation with previousResponseId',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First turn
        final response1 = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('My name is Alice.'),
            store: true, // Required for previousResponseId
          ),
        );

        expect(response1.status, ResponseStatus.completed);

        // Second turn using previousResponseId
        final response2 = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text('What is my name?'),
            previousResponseId: response1.id,
          ),
        );

        expect(response2.status, ResponseStatus.completed);
        expect(response2.outputText.toLowerCase(), contains('alice'));
        expect(response2.previousResponseId, response1.id);

        // Cleanup
        await client!.responses.delete(response1.id);
      },
    );

    test(
      'respects maxOutputTokens limit',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text(
              'Tell me a very long story about a dragon.',
            ),
            maxOutputTokens: 16, // Minimum allowed value
          ),
        );

        // With maxOutputTokens=16, the response should be incomplete
        expect(response.status, ResponseStatus.incomplete);
        expect(response.usage!.outputTokens, lessThanOrEqualTo(20));
      },
    );

    test(
      'creates response with message item input',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Note: Assistant messages require output_text type, not input_text
        // This test uses only user messages with string input for simplicity
        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.items([
              MessageItem(
                role: MessageRole.user,
                content: [InputContent.text('My favorite number is 7.')],
              ),
              MessageItem(
                role: MessageRole.user,
                content: [InputContent.text('What is my favorite number?')],
              ),
            ]),
          ),
        );

        expect(response.status, ResponseStatus.completed);
        expect(response.outputText, contains('7'));
      },
    );
  });

  // ==========================================================================
  // Group 2: Streaming
  // ==========================================================================

  group('Streaming', () {
    test(
      'streams response events',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStream(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Count from 1 to 5.'),
          ),
        );

        final events = <ResponseStreamEvent>[];
        await stream.forEach(events.add);

        expect(events, isNotEmpty);
        expect(events.whereType<OutputTextDeltaEvent>(), isNotEmpty);
        expect(events.last, isA<ResponseCompletedEvent>());

        final buffer = StringBuffer();
        events.whereType<OutputTextDeltaEvent>().forEach(
          (e) => buffer.write(e.delta),
        );
        final text = buffer.toString();
        expect(text, contains('1'));
        expect(text, contains('5'));
      },
    );

    test(
      'streams to response.completed event',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStream(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Say hello.'),
          ),
        );

        final events = await stream.toList();

        // Verify lifecycle events
        expect(events.whereType<ResponseCreatedEvent>(), isNotEmpty);
        expect(events.whereType<ResponseInProgressEvent>(), isNotEmpty);
        expect(events.whereType<ResponseCompletedEvent>(), hasLength(1));

        final completedEvent = events.whereType<ResponseCompletedEvent>().first;
        expect(completedEvent.response.status, ResponseStatus.completed);
        expect(completedEvent.response.usage, isNotNull);
      },
    );

    test(
      'createStreamWithAccumulator provides accumulated state',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStreamWithAccumulator(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Say hello.'),
          ),
        );

        ResponseStreamAccumulator? finalAccumulator;
        await for (final accumulator in stream) {
          finalAccumulator = accumulator;
        }

        expect(finalAccumulator, isNotNull);
        expect(finalAccumulator!.isComplete, isTrue);
        expect(finalAccumulator.isSuccessful, isTrue);
        expect(finalAccumulator.text.toLowerCase(), contains('hello'));
        expect(finalAccumulator.usage, isNotNull);
      },
    );

    test(
      'accumulator tracks text, status, and usage',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStreamWithAccumulator(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Count 1, 2, 3.'),
          ),
        );

        var sawInProgress = false;
        var textGrowingCorrectly = true;
        var previousTextLength = 0;

        ResponseStreamAccumulator? finalAccumulator;
        await for (final accumulator in stream) {
          if (accumulator.status == ResponseStatus.inProgress) {
            sawInProgress = true;
          }
          // Text should only grow or stay the same
          if (accumulator.text.length < previousTextLength) {
            textGrowingCorrectly = false;
          }
          previousTextLength = accumulator.text.length;
          finalAccumulator = accumulator;
        }

        expect(sawInProgress, isTrue);
        expect(textGrowingCorrectly, isTrue);
        expect(finalAccumulator!.status, ResponseStatus.completed);
        expect(finalAccumulator.usage!.totalTokens, greaterThan(0));
        expect(finalAccumulator.responseId, isNotNull);
      },
    );
  });

  // ==========================================================================
  // Group 3: Function Tools
  // ==========================================================================

  group('Function Tools', () {
    test(
      'invokes function tool',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text("What's the weather in Tokyo?"),
            tools: [
              ResponseTool.function(
                name: 'get_weather',
                description: 'Get the current weather for a location',
                parameters: const {
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
            toolChoice: ResponseToolChoice.function(name: 'get_weather'),
          ),
        );

        expect(response.hasToolCalls, isTrue);
        final funcCall = response.functionCalls.first;
        expect(funcCall.name, 'get_weather');
        expect(funcCall.arguments, isNotEmpty);

        final args = jsonDecode(funcCall.arguments) as Map<String, dynamic>;
        expect(args['location'].toString().toLowerCase(), contains('tokyo'));
      },
    );

    test(
      'function tool round-trip (non-streaming)',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Step 1: Get function call
        final response1 = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text(
              'What is 5 + 3? Use the add_numbers function.',
            ),
            tools: [
              ResponseTool.function(
                name: 'add_numbers',
                description: 'Add two numbers',
                parameters: const {
                  'type': 'object',
                  'properties': {
                    'a': {'type': 'integer'},
                    'b': {'type': 'integer'},
                  },
                  'required': ['a', 'b'],
                },
              ),
            ],
            toolChoice: ResponseToolChoice.function(name: 'add_numbers'),
            store: true,
          ),
        );

        expect(response1.hasToolCalls, isTrue);
        final funcCall = response1.functionCalls.first;
        expect(funcCall.name, 'add_numbers');

        // Parse arguments and compute result
        final args = jsonDecode(funcCall.arguments) as Map<String, dynamic>;
        final result = (args['a'] as int) + (args['b'] as int);

        // Step 2: Submit function output and get final response
        final response2 = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            previousResponseId: response1.id,
            input: ResponseInput.items([
              FunctionCallOutputItem.string(
                callId: funcCall.callId,
                output: result.toString(),
              ),
            ]),
          ),
        );

        expect(response2.status, ResponseStatus.completed);
        expect(response2.outputText, contains('8'));

        // Cleanup
        await client!.responses.delete(response1.id);
      },
    );

    test(
      'function tool round-trip (streaming)',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Step 1: Stream function call
        final stream = client!.responses.createStreamWithAccumulator(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text(
              'What is 7 * 6? Use the multiply function.',
            ),
            tools: [
              ResponseTool.function(
                name: 'multiply',
                description: 'Multiply two numbers',
                parameters: const {
                  'type': 'object',
                  'properties': {
                    'a': {'type': 'integer'},
                    'b': {'type': 'integer'},
                  },
                  'required': ['a', 'b'],
                },
              ),
            ],
            toolChoice: ResponseToolChoice.function(name: 'multiply'),
            store: true,
          ),
        );

        // Verify we receive function call arguments via delta events
        var sawArgsDelta = false;
        ResponseStreamAccumulator? finalAccumulator;
        await for (final accumulator in stream) {
          if (accumulator.functionArguments.isNotEmpty) {
            sawArgsDelta = true;
          }
          finalAccumulator = accumulator;
        }

        expect(sawArgsDelta, isTrue);
        expect(finalAccumulator!.isComplete, isTrue);

        final response1 = finalAccumulator.response!;
        expect(response1.hasToolCalls, isTrue);

        final funcCall = response1.functionCalls.first;
        final args = jsonDecode(funcCall.arguments) as Map<String, dynamic>;
        final result = (args['a'] as int) * (args['b'] as int);

        // Step 2: Submit result
        final response2 = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            previousResponseId: response1.id,
            input: ResponseInput.items([
              FunctionCallOutputItem.string(
                callId: funcCall.callId,
                output: result.toString(),
              ),
            ]),
          ),
        );

        expect(response2.outputText, contains('42'));

        // Cleanup
        await client!.responses.delete(response1.id);
      },
    );

    test(
      'function tool returns rich content types',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First get a function call
        final response1 = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text('Get info about item A.'),
            tools: [
              ResponseTool.function(
                name: 'get_item_info',
                description: 'Get information about an item',
                parameters: const {
                  'type': 'object',
                  'properties': {
                    'item_id': {'type': 'string'},
                  },
                  'required': ['item_id'],
                },
              ),
            ],
            toolChoice: ResponseToolChoice.function(name: 'get_item_info'),
            store: true,
          ),
        );

        final funcCall = response1.functionCalls.first;

        // Return structured content with rich types
        final response2 = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            previousResponseId: response1.id,
            input: ResponseInput.items([
              FunctionCallOutputItem(
                callId: funcCall.callId,
                output: const FunctionCallOutputContent([
                  InputContent.text(r'Item A: Premium Widget - $99.99'),
                ]),
              ),
            ]),
          ),
        );

        expect(response2.status, ResponseStatus.completed);
        expect(response2.outputText.toLowerCase(), contains('widget'));

        // Cleanup
        await client!.responses.delete(response1.id);
      },
    );
  });

  // ==========================================================================
  // Group 4: Built-in Tools
  // ==========================================================================

  group('Built-in Tools', () {
    test(
      'streams web search events',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStream(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text(
              'What is the latest news about AI? Search the web.',
            ),
            tools: [ResponseTool.webSearch()],
          ),
        );

        final events = await stream.toList();

        // Check for web search lifecycle events
        final webSearchEvents = events.where(
          (e) =>
              e is ResponseWebSearchCallInProgressEvent ||
              e is ResponseWebSearchCallSearchingEvent ||
              e is ResponseWebSearchCallCompletedEvent,
        );
        expect(webSearchEvents, isNotEmpty);

        // Verify completion
        expect(events.whereType<ResponseCompletedEvent>(), hasLength(1));
      },
    );

    test(
      'streams code interpreter events with container ID',
      skip: 'Requires pre-created container (Containers API)',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Note: Code interpreter now requires a container.
        // To run this test, create a container first using the Containers API
        // and pass the container ID (starts with 'cntr_') here.
        final stream = client!.responses.createStream(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text(
              'Write Python code to calculate 2^20.',
            ),
            tools: [
              ResponseTool.codeInterpreter(
                container: CodeInterpreterContainer.id('cntr_...'),
              ),
            ],
          ),
        );

        final events = await stream.toList();

        // Check for code interpreter lifecycle events
        final codeEvents = events.where(
          (e) =>
              e is ResponseCodeInterpreterCallInProgressEvent ||
              e is ResponseCodeInterpreterCallInterpretingEvent ||
              e is ResponseCodeInterpreterCallCodeDeltaEvent ||
              e is ResponseCodeInterpreterCallCompletedEvent,
        );
        expect(codeEvents, isNotEmpty);

        // Verify completion
        expect(events.whereType<ResponseCompletedEvent>(), hasLength(1));
      },
    );

    test(
      'streams code interpreter events with auto container',
      skip: 'Expensive - run manually',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStream(
          CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: const ResponseInput.text(
              'Write Python code to calculate 2^20.',
            ),
            tools: [
              ResponseTool.codeInterpreter(
                container: CodeInterpreterContainer.auto(),
              ),
            ],
          ),
        );

        final events = await stream.toList();

        // Check for code interpreter lifecycle events
        final codeEvents = events.where(
          (e) =>
              e is ResponseCodeInterpreterCallInProgressEvent ||
              e is ResponseCodeInterpreterCallInterpretingEvent ||
              e is ResponseCodeInterpreterCallCodeDeltaEvent ||
              e is ResponseCodeInterpreterCallCompletedEvent,
        );
        expect(codeEvents, isNotEmpty);

        // Verify completion
        expect(events.whereType<ResponseCompletedEvent>(), hasLength(1));
      },
    );
  });

  // ==========================================================================
  // Group 5: Advanced Features
  // ==========================================================================

  group('Advanced Features', () {
    test(
      'creates response with structured output (JSON schema)',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Extract info: John is 30 years old.'),
            text: TextConfig(
              format: JsonSchemaFormat(
                name: 'person',
                schema: {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string'},
                    'age': {'type': 'integer'},
                  },
                  'required': ['name', 'age'],
                  'additionalProperties': false,
                },
                strict: true,
              ),
            ),
          ),
        );

        expect(response.status, ResponseStatus.completed);

        final json = jsonDecode(response.outputText) as Map<String, dynamic>;
        expect(json['name'], 'John');
        expect(json['age'], 30);
      },
    );

    test(
      'uses reasoning with effort levels',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'o4-mini',
            input: ResponseInput.text('What is 15 * 17?'),
            reasoning: ReasoningConfig(
              effort: ReasoningEffort.medium,
              summary: ReasoningSummary.auto,
            ),
          ),
        );

        expect(response.status, ResponseStatus.completed);
        expect(response.reasoningItems, isNotEmpty);
        expect(response.outputText, contains('255'));
      },
    );

    test(
      'streams reasoning delta events',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.responses.createStreamWithAccumulator(
          const CreateResponseRequest(
            model: 'o4-mini',
            input: ResponseInput.text('What is 123 + 456?'),
            reasoning: ReasoningConfig(
              effort: ReasoningEffort.low,
              summary: ReasoningSummary.auto,
            ),
          ),
        );

        ResponseStreamAccumulator? finalAccumulator;

        await for (final accumulator in stream) {
          finalAccumulator = accumulator;
        }

        // Verify completion and result
        expect(finalAccumulator!.isSuccessful, isTrue);
        expect(finalAccumulator.response!.outputText, contains('579'));
        // Reasoning items should be present in the final response
        expect(finalAccumulator.response!.reasoningItems, isNotEmpty);
      },
    );

    test(
      'counts input tokens',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final tokenCount = await client!.responses.inputTokens.count(
          model: 'gpt-4o-mini',
          input: const ResponseInput.text('Hello, how are you today?'),
        );

        expect(tokenCount.inputTokens, greaterThan(0));
        expect(tokenCount.inputTokens, lessThan(20)); // Sanity check
      },
    );
  });

  // ==========================================================================
  // Group 6: Response Management
  // ==========================================================================

  group('Response Management', () {
    test(
      'retrieves a stored response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a response with store: true
        final created = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Say hello'),
            store: true,
          ),
        );

        // Retrieve by ID
        final retrieved = await client!.responses.retrieve(created.id);

        expect(retrieved.id, created.id);
        expect(retrieved.status, ResponseStatus.completed);
        expect(retrieved.outputText, isNotEmpty);

        // Cleanup
        await client!.responses.delete(created.id);
      },
    );

    test(
      'lists stored responses with pagination',
      skip: 'Requires session key (browser-only API)',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a stored response
        final response = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Hello for list test'),
            store: true,
          ),
        );

        try {
          // List responses - requires session key from browser
          final list = await client!.responses.list(limit: 10);

          expect(list.data, isNotEmpty);
          expect(list.data.any((r) => r.id == response.id), isTrue);
          expect(list.object, 'list');
        } finally {
          await client!.responses.delete(response.id);
        }
      },
    );

    test(
      'deletes a stored response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a stored response
        final created = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text('Hello for delete test'),
            store: true,
          ),
        );

        // Delete it
        final result = await client!.responses.delete(created.id);

        expect(result.id, created.id);
        expect(result.deleted, isTrue);

        // Verify it's deleted by trying to retrieve (should throw)
        try {
          await client!.responses.retrieve(created.id);
          fail('Expected exception when retrieving deleted response');
        } on ApiException catch (e) {
          expect(e.statusCode, 404);
        }
      },
    );

    test(
      'cancels a background response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a background response (streaming not started yet)
        final created = await client!.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o-mini',
            input: ResponseInput.text(
              'Write a very long essay about the history of computing.',
            ),
            background: true,
          ),
        );

        // Response should be queued or in progress
        expect(
          created.status,
          anyOf(ResponseStatus.queued, ResponseStatus.inProgress),
        );

        // Cancel it
        final cancelled = await client!.responses.cancel(created.id);

        expect(cancelled.id, created.id);
        expect(cancelled.status, ResponseStatus.cancelled);
      },
    );
  });

  // ==========================================================================
  // Group 7: Optional/Expensive Tests (Skipped by Default)
  // ==========================================================================

  group('Optional Tests', skip: 'Expensive/slow tests - run manually', () {
    test(
      'processes image input (vision)',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Use a simple red pixel as base64 PNG
        // 1x1 red PNG
        const base64Image =
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';

        final response = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseInput.items([
              MessageItem.user(const [
                InputContent.text('What color is this image?'),
                InputImageContent.url('data:image/png;base64,$base64Image'),
              ]),
            ]),
          ),
        );

        expect(response.status, ResponseStatus.completed);
        expect(response.outputText.toLowerCase(), contains('red'));
      },
    );

    test(
      'generates image with tool',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o',
            input: const ResponseInput.text(
              'Generate a simple image of a red circle on white background.',
            ),
            tools: [
              ResponseTool.imageGeneration(quality: 'low', size: '1024x1024'),
            ],
          ),
        );

        expect(response.status, ResponseStatus.completed);
        // Image generation should produce some output
        expect(response.output, isNotEmpty);
      },
    );

    test(
      'generates image with partialImages',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.responses.create(
          CreateResponseRequest(
            model: 'gpt-4o',
            input: const ResponseInput.text(
              'Generate a simple image of a blue square.',
            ),
            tools: [
              ResponseTool.imageGeneration(
                quality: 'low',
                size: '1024x1024',
                partialImages: 2,
              ),
            ],
          ),
        );

        expect(response.status, ResponseStatus.completed);
        expect(response.output, isNotEmpty);
      },
    );

    test(
      'performs file search with vector store',
      timeout: const Timeout(Duration(minutes: 3)),
      () {
        // Note: This test requires a pre-created vector store
        // Skip if no vector store is available
        markTestSkipped('Requires vector store setup');
      },
    );

    test(
      'lists MCP server tools',
      timeout: const Timeout(Duration(minutes: 2)),
      () {
        // Note: This test requires an MCP server
        markTestSkipped('Requires MCP server setup');
      },
    );
  });
}
