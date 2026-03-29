// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Integration tests for the Interactions API.
///
/// These tests require a real API key set in the GEMINI_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  String? apiKey;
  GoogleAIClient? client;

  setUpAll(() {
    final key = Platform.environment['GEMINI_API_KEY'];
    apiKey = (key != null && key.isNotEmpty) ? key : null;
    if (apiKey == null) {
      print(
        '⚠️  GEMINI_API_KEY not set. Integration tests will be skipped.\n'
        '   To run these tests, export GEMINI_API_KEY=your_api_key',
      );
    } else {
      client = GoogleAIClient(
        config: GoogleAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Interactions - Basic', () {
    test('creates a simple text interaction', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text(
          'Say "Hello, World!" and nothing else.',
        ),
      );

      expect(interaction.id, isNotEmpty);
      expect(interaction.status, InteractionStatus.completed);
      expect(interaction.model, contains('gemini'));
      expect(interaction.text, isNotNull);
      expect(interaction.text!.toLowerCase(), contains('hello'));
    });

    test('creates interaction with system instruction', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('What are you?'),
        systemInstruction:
            'You are a helpful pirate. Always respond with pirate language.',
      );

      expect(interaction.status, InteractionStatus.completed);
      expect(interaction.text, isNotNull);
    });

    test('creates interaction with generation config', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('Count from 1 to 3.'),
        generationConfig: const InteractionGenerationConfig(
          temperature: 0.1,
          maxOutputTokens: 200,
        ),
      );

      // Status may be 'incomplete' if thinking tokens consume the budget
      expect(
        interaction.status,
        anyOf(InteractionStatus.completed, InteractionStatus.incomplete),
      );
      expect(interaction.text, isNotNull);

      // Usage should be populated
      expect(interaction.usage, isNotNull);
      expect(interaction.usage!.totalInputTokens, greaterThan(0));
      expect(interaction.usage!.totalOutputTokens, greaterThan(0));
    });

    test('returns usage metadata', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('Hi'),
      );

      expect(interaction.usage, isNotNull);
      expect(interaction.usage!.totalInputTokens, greaterThan(0));
      expect(interaction.usage!.totalOutputTokens, greaterThan(0));
      expect(interaction.usage!.totalTokens, greaterThan(0));
    });
  });

  group('Interactions - Get and Delete', () {
    test('retrieves an interaction by ID', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      // Create an interaction first
      final created = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('What is 2 + 2?'),
      );

      // Retrieve it by ID
      final retrieved = await client!.interactions.get(created.id);

      expect(retrieved.id, equals(created.id));
      expect(retrieved.status, InteractionStatus.completed);
      expect(retrieved.text, isNotNull);
    });

    test('retrieves interaction with input included', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final created = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('Hello there'),
      );

      final retrieved = await client!.interactions.get(
        created.id,
        includeInput: true,
      );

      expect(retrieved.id, equals(created.id));
      expect(retrieved.input, isNotNull);
    });

    test('deletes an interaction', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final created = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('Temporary message'),
      );

      // Delete it
      await client!.interactions.delete(created.id);

      // Attempting to get it should fail
      expect(
        () => client!.interactions.get(created.id),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('Interactions - Multi-turn', () {
    test('maintains context across turns with previousInteractionId', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      // First turn: introduce a name
      final turn1 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('My name is Alice.'),
      );
      expect(turn1.status, InteractionStatus.completed);

      // Second turn: ask about the name, referencing the first interaction
      final turn2 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('What is my name?'),
        previousInteractionId: turn1.id,
      );
      expect(turn2.status, InteractionStatus.completed);
      expect(turn2.text!.toLowerCase(), contains('alice'));
      // previousInteractionId may not be echoed back in all API versions
    });

    test('supports three-turn conversation', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final turn1 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text(
          'Remember this number: 42. Just acknowledge.',
        ),
      );

      final turn2 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text(
          'Now remember this color: blue. Just acknowledge.',
        ),
        previousInteractionId: turn1.id,
      );

      final turn3 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text(
          'What number and color did I tell you to remember?',
        ),
        previousInteractionId: turn2.id,
      );

      expect(turn3.status, InteractionStatus.completed);
      final text = turn3.text!.toLowerCase();
      expect(text, contains('42'));
      expect(text, contains('blue'));
    });

    test('supports turns input for providing conversation history', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.turns([
          Turn(role: 'user', content: TurnTextContent('My name is Bob.')),
          Turn(
            role: 'model',
            content: TurnTextContent('Nice to meet you, Bob!'),
          ),
          Turn(role: 'user', content: TurnTextContent('What is my name?')),
        ]),
      );

      expect(interaction.status, InteractionStatus.completed);
      expect(interaction.text!.toLowerCase(), contains('bob'));
    });
  });

  group('Interactions - Function Calling', () {
    test(
      'triggers a function call and returns requires_action status',
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        const tools = [
          FunctionTool(
            name: 'get_weather',
            description: 'Get the current weather for a location.',
            parameters: {
              'type': 'object',
              'properties': {
                'location': {'type': 'string', 'description': 'The city name'},
              },
              'required': <dynamic>['location'],
            },
          ),
        ];

        final interaction = await client!.interactions.create(
          model: defaultInteractionsModel,
          input: const InteractionInput.text(
            'What is the weather in Paris right now?',
          ),
          tools: tools,
        );

        expect(interaction.status, InteractionStatus.requiresAction);
        expect(interaction.hasFunctionCalls, isTrue);

        final functionCalls = interaction.functionCallOutputs;
        expect(functionCalls, isNotEmpty);
        expect(functionCalls.first.name, equals('get_weather'));
        expect(functionCalls.first.arguments, isNotNull);
        expect(
          functionCalls.first.arguments['location'].toString().toLowerCase(),
          contains('paris'),
        );
      },
    );

    test('completes function call round-trip', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      const tools = [
        FunctionTool(
          name: 'get_temperature',
          description: 'Get the temperature for a city in Celsius.',
          parameters: {
            'type': 'object',
            'properties': {
              'city': {'type': 'string', 'description': 'The city name'},
            },
            'required': <dynamic>['city'],
          },
        ),
      ];

      // Step 1: Send request that triggers function call
      final step1 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text(
          'What is the temperature in London?',
        ),
        tools: tools,
      );

      expect(step1.status, InteractionStatus.requiresAction);
      final functionCall = step1.functionCallOutputs.first;

      // Step 2: Return the function result
      final step2 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: InteractionInput.singleContent(
          FunctionResultContent(
            callId: functionCall.id,
            name: functionCall.name,
            result: const ToolResult.text('15 degrees Celsius'),
          ),
        ),
        tools: tools,
        previousInteractionId: step1.id,
      );

      expect(step2.status, InteractionStatus.completed);
      expect(step2.text, isNotNull);
      expect(step2.text!.toLowerCase(), contains('15'));
    });
  });

  group('Interactions - Google Search', () {
    test('uses google search tool for real-time information', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('What is the current date today?'),
        tools: const [GoogleSearchTool()],
      );

      expect(interaction.status, InteractionStatus.completed);
      expect(interaction.text, isNotNull);
      expect(interaction.text, isNotEmpty);

      // Should have google search related outputs
      final outputs = interaction.outputs ?? [];
      final hasSearchOutput = outputs.any(
        (o) => o is GoogleSearchCallContent || o is GoogleSearchResultContent,
      );
      expect(hasSearchOutput, isTrue);
    });
  });

  group('Interactions - URL Context', () {
    test(
      'fetches and analyzes content from a URL',
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final interaction = await client!.interactions.create(
          model: defaultInteractionsModel,
          input: const InteractionInput.text(
            'What is Dart according to https://dart.dev/overview ?',
          ),
          tools: const [UrlContextTool()],
        );

        expect(interaction.status, InteractionStatus.completed);
        expect(interaction.text, isNotNull);
        // Should reference Dart programming language
        expect(interaction.text!.toLowerCase(), contains('dart'));
      },
      timeout: const Timeout(Duration(seconds: 120)),
    );
  });

  group('Interactions - Streaming', () {
    test('streams events for a simple interaction', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final events = <InteractionEvent>[];
      await client!.interactions
          .createStream(
            model: defaultInteractionsModel,
            input: const InteractionInput.text('Say "hello" and nothing else.'),
          )
          .forEach(events.add);

      // Should have start, content events, and complete
      expect(events, isNotEmpty);

      // First event should be InteractionStartEvent
      expect(events.first, isA<InteractionStartEvent>());
      final startEvent = events.first as InteractionStartEvent;
      expect(startEvent.interaction?.id, isNotNull);

      // Last event should be InteractionCompleteEvent
      expect(events.last, isA<InteractionCompleteEvent>());
      final completeEvent = events.last as InteractionCompleteEvent;
      expect(completeEvent.interaction?.status, InteractionStatus.completed);

      // Should have content delta events with text
      final textDeltas = events
          .whereType<ContentDeltaEvent>()
          .where((d) => d.delta is TextDelta)
          .toList();
      expect(textDeltas, isNotEmpty);

      // Accumulate text from deltas
      final text = textDeltas
          .map((d) => (d.delta! as TextDelta).text ?? '')
          .join();
      expect(text.toLowerCase(), contains('hello'));
    });

    test('streams content start and stop events', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final events = <InteractionEvent>[];
      await client!.interactions
          .createStream(
            model: defaultInteractionsModel,
            input: const InteractionInput.text('Say "test".'),
          )
          .forEach(events.add);

      final contentStarts = events.whereType<ContentStartEvent>().toList();
      final contentStops = events.whereType<ContentStopEvent>().toList();

      // Should have at least one content start and stop pair
      expect(contentStarts, isNotEmpty);
      expect(contentStops, isNotEmpty);
      // Each start should have a matching stop
      expect(contentStarts.length, equals(contentStops.length));
    });

    test('streams function call events', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      const tools = [
        FunctionTool(
          name: 'get_weather',
          description: 'Get weather for a location.',
          parameters: {
            'type': 'object',
            'properties': {
              'location': {'type': 'string', 'description': 'City name'},
            },
            'required': <dynamic>['location'],
          },
        ),
      ];

      final events = <InteractionEvent>[];
      await client!.interactions
          .createStream(
            model: defaultInteractionsModel,
            input: const InteractionInput.text('What is the weather in Tokyo?'),
            tools: tools,
          )
          .forEach(events.add);

      // Should complete with requires_action status
      final completeEvent = events.whereType<InteractionCompleteEvent>().first;
      expect(
        completeEvent.interaction?.status,
        InteractionStatus.requiresAction,
      );

      // Should have function call content start
      final functionCallStarts = events
          .whereType<ContentStartEvent>()
          .where((e) => e.content is FunctionCallContent)
          .toList();
      expect(functionCallStarts, isNotEmpty);
    });

    test('streams multi-turn with previousInteractionId', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      // First turn (non-streaming to get the ID)
      final turn1 = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('My favorite color is green.'),
      );

      // Second turn (streaming with reference to first)
      final events = <InteractionEvent>[];
      await client!.interactions
          .createStream(
            model: defaultInteractionsModel,
            input: const InteractionInput.text('What is my favorite color?'),
            previousInteractionId: turn1.id,
          )
          .forEach(events.add);

      // Accumulate text from deltas
      final text = events
          .whereType<ContentDeltaEvent>()
          .where((d) => d.delta is TextDelta)
          .map((d) => (d.delta! as TextDelta).text ?? '')
          .join();
      expect(text.toLowerCase(), contains('green'));
    });

    test('streams google search interaction', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final events = <InteractionEvent>[];
      await client!.interactions
          .createStream(
            model: defaultInteractionsModel,
            input: const InteractionInput.text(
              'What day of the week is it today?',
            ),
            tools: const [GoogleSearchTool()],
          )
          .forEach(events.add);

      expect(events, isNotEmpty);

      // Should complete successfully
      final completeEvent = events.whereType<InteractionCompleteEvent>().first;
      expect(completeEvent.interaction?.status, InteractionStatus.completed);

      // Should have google search related events (content starts or deltas)
      final hasSearchEvents = events.any(
        (e) =>
            (e is ContentStartEvent &&
                (e.content is GoogleSearchCallContent ||
                    e.content is GoogleSearchResultContent)) ||
            (e is ContentDeltaEvent &&
                (e.delta is GoogleSearchCallDelta ||
                    e.delta is GoogleSearchResultDelta)),
      );
      expect(hasSearchEvents, isTrue);
    });
  });

  group('Interactions - Extensions', () {
    test('text extension concatenates multiple text outputs', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text(
          'Write two short sentences about Dart.',
        ),
      );

      expect(interaction.text, isNotNull);
      expect(interaction.text, isNotEmpty);
      expect(interaction.hasTextOutput, isTrue);
      expect(interaction.textOutputs, isNotEmpty);
    });

    test('functionCallOutputs extension extracts function calls', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final interaction = await client!.interactions.create(
        model: defaultInteractionsModel,
        input: const InteractionInput.text('Get weather in Berlin.'),
        tools: const [
          FunctionTool(
            name: 'get_weather',
            description: 'Get the weather for a location.',
            parameters: {
              'type': 'object',
              'properties': {
                'location': {'type': 'string'},
              },
              'required': <dynamic>['location'],
            },
          ),
        ],
      );

      expect(interaction.hasFunctionCalls, isTrue);
      expect(interaction.functionCallOutputs, isNotEmpty);
      expect(interaction.functionCallOutputs.first.name, 'get_weather');
    });
  });

  group('Interactions - Error Handling', () {
    test('throws ApiException for invalid model', () {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      expect(
        () => client!.interactions.create(
          model: 'invalid-model-name-xyz',
          input: const InteractionInput.text('Hello'),
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException for invalid interaction ID on get', () {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      expect(
        () => client!.interactions.get('non-existent-id'),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException for streaming with invalid model', () {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final stream = client!.interactions.createStream(
        model: 'invalid-model-for-streaming',
        input: const InteractionInput.text('Hello'),
      );

      expect(() async {
        await for (final _ in stream) {
          // Should throw before yielding
        }
      }, throwsA(isA<ApiException>()));
    });
  });
}
