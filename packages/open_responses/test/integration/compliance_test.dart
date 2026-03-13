@TestOn('vm')
@Tags(['integration', 'compliance'])
library;

import 'dart:io';

import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

/// Provider configuration for compliance testing.
class ProviderConfig {
  final String name;
  final String baseUrl;
  final AuthProvider? authProvider;
  final String model;
  final String? envKeyName;

  const ProviderConfig({
    required this.name,
    required this.baseUrl,
    this.authProvider,
    required this.model,
    this.envKeyName,
  });

  bool get isAvailable {
    if (envKeyName == null) return true;
    return Platform.environment[envKeyName] != null;
  }

  String? get skipReason {
    if (envKeyName == null) return null;
    if (Platform.environment[envKeyName] != null) return null;
    return 'Set $envKeyName to run $name compliance tests';
  }
}

/// Compliance test suite for validating OpenResponses API compatibility
/// across multiple providers.
///
/// These tests verify that all providers implement the core OpenResponses
/// specification consistently.
void main() {
  // Define available providers
  final providers = <ProviderConfig>[
    ProviderConfig(
      name: 'OpenAI',
      baseUrl: 'https://api.openai.com/v1',
      authProvider: Platform.environment['OPENAI_API_KEY'] != null
          ? BearerTokenProvider(Platform.environment['OPENAI_API_KEY']!)
          : null,
      model: 'gpt-4o-mini',
      envKeyName: 'OPENAI_API_KEY',
    ),
    ProviderConfig(
      name: 'Ollama',
      baseUrl: 'http://localhost:11434/v1',
      authProvider: null,
      model: Platform.environment['OLLAMA_MODEL'] ?? 'llama3.2',
      envKeyName: 'RUN_OLLAMA_TESTS',
    ),
    ProviderConfig(
      name: 'HuggingFace',
      baseUrl:
          Platform.environment['HF_RESPONSES_URL'] ??
          'https://evalstate-openresponses.hf.space/v1',
      authProvider: Platform.environment['HF_API_KEY'] != null
          ? BearerTokenProvider(Platform.environment['HF_API_KEY']!)
          : null,
      model: Platform.environment['HF_MODEL'] ?? 'default',
      envKeyName: 'HF_API_KEY',
    ),
  ];

  group('OpenResponses Compliance Tests', () {
    for (final provider in providers) {
      group(provider.name, skip: provider.skipReason, () {
        late OpenResponsesClient client;

        setUpAll(() {
          client = OpenResponsesClient(
            config: OpenResponsesConfig(
              baseUrl: provider.baseUrl,
              authProvider: provider.authProvider,
            ),
          );
        });

        tearDownAll(() {
          client.close();
        });

        // CORE-001: Basic text response
        test('CORE-001: Creates basic text response', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('Say "Hello" and nothing else.'),
            ),
          );

          expect(response.id, isNotEmpty);
          expect(response.status, ResponseStatus.completed);
          expect(response.output, isNotEmpty);
          expect(response.outputText, isNotNull);
          expect(response.model, isNotEmpty);
        });

        // CORE-002: Response with instructions
        test('CORE-002: Respects system instructions', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('What is 2 + 2?'),
              instructions: 'Always respond with only the numeric answer.',
            ),
          );

          expect(response.status, ResponseStatus.completed);
          expect(response.outputText, contains('4'));
        });

        // CORE-003: Multi-message input
        test('CORE-003: Handles multi-message input', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: ResponseItemsInput([
                MessageItem.systemText('You are a helpful assistant.'),
                MessageItem.userText('What is the capital of France?'),
              ]),
            ),
          );

          expect(response.status, ResponseStatus.completed);
          expect(response.outputText?.toLowerCase(), contains('paris'));
        });

        // STREAM-001: Basic streaming
        test('STREAM-001: Supports basic streaming', () async {
          final events = <StreamingEvent>[];

          await client.responses
              .createStream(
                CreateResponseRequest(
                  model: provider.model,
                  input: const ResponseTextInput('Count from 1 to 3.'),
                ),
              )
              .forEach(events.add);

          expect(events, isNotEmpty);

          // Must have response created event
          expect(events.whereType<ResponseCreatedEvent>(), isNotEmpty);

          // Must have response completed event
          expect(events.whereType<ResponseCompletedEvent>(), isNotEmpty);
        });

        // STREAM-002: Text delta streaming
        test('STREAM-002: Emits text delta events', () async {
          final deltas = <String>[];

          await client.responses
              .createStream(
                CreateResponseRequest(
                  model: provider.model,
                  input: const ResponseTextInput('Say "test".'),
                ),
              )
              .forEach((event) {
                if (event is OutputTextDeltaEvent) {
                  deltas.add(event.delta);
                }
              });

          expect(deltas.join(), isNotEmpty);
        });

        // STREAM-003: Builder pattern streaming
        test('STREAM-003: Supports builder pattern streaming', () async {
          final textBuffer = StringBuffer();

          final runner = client.responses.stream(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('Say "hello".'),
            ),
          )..onTextDelta(textBuffer.write);

          final finalResponse = await runner.finalResponse;

          expect(textBuffer.toString(), isNotEmpty);
          expect(finalResponse, isNotNull);
          expect(finalResponse!.status, ResponseStatus.completed);
        });

        // TOOL-001: Function tool definition
        test('TOOL-001: Accepts function tool definitions', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
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
          // Tool calling behavior varies by provider/model
          // Just verify the request was accepted
        });

        // EXT-001: Response extensions work
        test('EXT-001: Response extensions work correctly', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('Hello'),
            ),
          );

          // Verify all extension methods work
          expect(response.isCompleted, isTrue);
          expect(response.isFailed, isFalse);
          expect(response.isInProgress, isFalse);
          expect(response.outputText, isA<String?>());
          expect(
            response.functionCalls,
            isA<List<FunctionCallOutputItemResponse>>(),
          );
          expect(response.reasoningItems, isA<List<ReasoningItem>>());
          expect(response.hasToolCalls, isA<bool>());
        });

        // PARAM-001: Temperature parameter
        test('PARAM-001: Accepts temperature parameter', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('What is 1 + 1?'),
              temperature: 0,
            ),
          );

          expect(response.status, ResponseStatus.completed);
          expect(response.outputText, contains('2'));
        });

        // PARAM-002: Max output tokens parameter
        test('PARAM-002: Accepts max output tokens parameter', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('Write a story.'),
              maxOutputTokens: 20,
            ),
          );

          // Response should be truncated or completed
          expect(response.output, isNotEmpty);
        });

        // JSON-001: JSON serialization round-trip
        test('JSON-001: Request serializes correctly', () {
          const request = CreateResponseRequest(
            model: 'test-model',
            input: ResponseTextInput('Hello'),
            instructions: 'Be helpful',
            temperature: 0.7,
            maxOutputTokens: 100,
            tools: [
              FunctionTool(
                name: 'test_tool',
                description: 'A test tool',
                parameters: {'type': 'object'},
              ),
            ],
          );

          final json = request.toJson();

          expect(json['model'], 'test-model');
          expect(json['input'], 'Hello');
          expect(json['instructions'], 'Be helpful');
          expect(json['temperature'], 0.7);
          expect(json['max_output_tokens'], 100);
          expect(json['tools'], hasLength(1));

          // Round-trip
          final restored = CreateResponseRequest.fromJson(json);
          expect(restored.model, request.model);
          expect(restored.instructions, request.instructions);
        });

        // JSON-002: Response deserializes correctly
        test('JSON-002: Response deserializes correctly', () async {
          final response = await client.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('Hello'),
            ),
          );

          // Verify JSON round-trip
          final json = response.toJson();
          final restored = ResponseResource.fromJson(json);

          expect(restored.id, response.id);
          expect(restored.status, response.status);
          expect(restored.model, response.model);
        });
      });
    }
  });

  // Cross-provider consistency tests
  group('Cross-Provider Consistency', () {
    final availableProviders = providers.where((p) => p.isAvailable).toList();

    if (availableProviders.length < 2) {
      test(
        'skipped - need at least 2 providers',
        skip: 'Need at least 2 providers configured',
        () {},
      );
      return;
    }

    test('All providers return consistent response structure', () async {
      final clients = <String, OpenResponsesClient>{};
      final responses = <String, ResponseResource>{};

      try {
        // Create clients for all available providers
        for (final provider in availableProviders) {
          clients[provider.name] = OpenResponsesClient(
            config: OpenResponsesConfig(
              baseUrl: provider.baseUrl,
              authProvider: provider.authProvider,
            ),
          );
        }

        // Run the same request on all providers
        for (final provider in availableProviders) {
          final response = await clients[provider.name]!.responses.create(
            CreateResponseRequest(
              model: provider.model,
              input: const ResponseTextInput('Say "test".'),
            ),
          );
          responses[provider.name] = response;
        }

        // Verify all responses have consistent structure
        for (final entry in responses.entries) {
          final response = entry.value;

          expect(
            response.id,
            isNotEmpty,
            reason: '${entry.key} should have an id',
          );
          expect(
            response.status,
            ResponseStatus.completed,
            reason: '${entry.key} should complete',
          );
          expect(
            response.output,
            isNotEmpty,
            reason: '${entry.key} should have output',
          );
          expect(
            response.outputText,
            isNotNull,
            reason: '${entry.key} should have text output',
          );
        }
      } finally {
        // Clean up
        for (final client in clients.values) {
          client.close();
        }
      }
    });
  });
}
