// ignore_for_file: avoid_print

import 'dart:io';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Integration tests for chat completions.
///
/// These tests require a real API key set in the MISTRAL_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  String? apiKey;
  MistralClient? client;

  setUpAll(() {
    apiKey = Platform.environment[apiKeyEnvVar];
    if (apiKey == null || apiKey!.isEmpty) {
      print(
        '⚠️  $apiKeyEnvVar not set. Integration tests will be skipped.\n'
        '   To run these tests, export $apiKeyEnvVar=your_api_key',
      );
    } else {
      client = MistralClient.withApiKey(apiKey!);
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Chat - Integration', () {
    test('generates a simple response', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('Say "Hello, World!" and nothing else.')],
        ),
      );

      expect(response, isNotNull);
      expect(response.choices, isNotEmpty);
      expect(response.text, isNotNull);
      expect(response.text!.toLowerCase(), contains('hello'));
    });

    test('supports multi-turn conversation', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [
            ChatMessage.user('My favorite color is blue.'),
            ChatMessage.assistant('Nice! Blue is a great color.'),
            ChatMessage.user('What is my favorite color?'),
          ],
        ),
      );

      expect(response, isNotNull);
      expect(response.text, isNotNull);
      expect(response.text!.toLowerCase(), contains('blue'));
    });

    test('supports system message', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [
            ChatMessage.system(
              'You are a pirate. Always respond in pirate speak.',
            ),
            ChatMessage.user('How are you today?'),
          ],
        ),
      );

      expect(response, isNotNull);
      expect(response.text, isNotNull);
      // Should use pirate-like language
      final text = response.text!.toLowerCase();
      expect(
        text.contains('arr') ||
            text.contains('matey') ||
            text.contains('ahoy') ||
            text.contains('ye') ||
            text.contains('cap'),
        isTrue,
      );
    });

    test('respects max_tokens', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('Write a long essay about AI.')],
          maxTokens: 10,
        ),
      );

      expect(response, isNotNull);
      expect(response.usage, isNotNull);
      expect(response.usage!.completionTokens, lessThanOrEqualTo(15));
    });

    test('returns usage information', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('Say hello.')],
        ),
      );

      expect(response, isNotNull);
      expect(response.usage, isNotNull);
      expect(response.usage!.promptTokens, greaterThan(0));
      expect(response.usage!.completionTokens, greaterThan(0));
      expect(response.usage!.totalTokens, greaterThan(0));
    });

    test('supports JSON response format', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [
            ChatMessage.user(
              'Return a JSON object with a "greeting" key set to "hello". '
              'Respond only with valid JSON.',
            ),
          ],
          responseFormat: const ResponseFormatJsonObject(),
        ),
      );

      expect(response, isNotNull);
      expect(response.text, isNotNull);
      expect(response.text, contains('"greeting"'));
    });
  });

  group('Chat Streaming - Integration', () {
    test('streams response chunks', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final stream = client!.chat.createStream(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('Count from 1 to 5.')],
        ),
      );

      final chunks = await stream.toList();

      expect(chunks, isNotEmpty);
      expect(chunks.length, greaterThan(1));

      // Collect all text
      final fullText = chunks.map((c) => c.text ?? '').join();
      expect(fullText.toLowerCase(), contains('1'));
      expect(fullText.toLowerCase(), contains('5'));
    });

    test('stream extension collects text', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final stream = client!.chat.createStream(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('Say "Hello, World!" and nothing else.')],
        ),
      );

      final text = await stream.text;
      expect(text.toLowerCase(), contains('hello'));
    });
  });

  group('Tool Calling - Integration', () {
    test('invokes a simple tool', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('What is the weather in Paris?')],
          tools: [
            Tool.function(
              name: 'get_weather',
              description: 'Get the current weather in a location',
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
          toolChoice: const ToolChoiceAny(),
        ),
      );

      expect(response, isNotNull);
      expect(response.hasToolCalls, isTrue);
      expect(response.toolCalls, isNotEmpty);

      final toolCall = response.toolCalls.first;
      expect(toolCall.function.name, 'get_weather');
      expect(toolCall.function.arguments.toLowerCase(), contains('paris'));
    });

    test('returns tool response in conversation', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      // First call - model invokes tool
      final response1 = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [ChatMessage.user('What is the weather in Paris?')],
          tools: [
            Tool.function(
              name: 'get_weather',
              description: 'Get the current weather',
              parameters: const {
                'type': 'object',
                'properties': {
                  'location': {'type': 'string'},
                },
              },
            ),
          ],
          toolChoice: const ToolChoiceAny(),
        ),
      );

      expect(response1.hasToolCalls, isTrue);
      final toolCall = response1.toolCalls.first;

      // Second call - provide tool result
      final response2 = await client!.chat.create(
        request: ChatCompletionRequest(
          model: defaultChatModel,
          messages: [
            ChatMessage.user('What is the weather in Paris?'),
            ChatMessage.assistant(null, toolCalls: response1.toolCalls),
            ChatMessage.tool(
              toolCallId: toolCall.id,
              content: '{"temperature": 22, "condition": "sunny"}',
            ),
          ],
          tools: [
            Tool.function(
              name: 'get_weather',
              description: 'Get the current weather',
              parameters: const {
                'type': 'object',
                'properties': {
                  'location': {'type': 'string'},
                },
              },
            ),
          ],
        ),
      );

      expect(response2, isNotNull);
      expect(response2.text, isNotNull);
      expect(
        response2.text!.toLowerCase(),
        anyOf(contains('22'), contains('sunny')),
      );
    });
  });

  group('Error Handling - Integration', () {
    test('throws ApiException for invalid model', () {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      expect(
        () => client!.chat.create(
          request: ChatCompletionRequest(
            model: 'invalid-model-name-xyz',
            messages: [ChatMessage.user('Hello')],
          ),
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException for invalid API key', () async {
      final badClient = MistralClient.withApiKey('invalid-key');

      try {
        await badClient.chat.create(
          request: ChatCompletionRequest(
            model: defaultChatModel,
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected ApiException to be thrown');
      } on ApiException catch (e) {
        expect(e.code, anyOf(equals(401), equals(403)));
      } finally {
        badClient.close();
      }
    });
  });
}
