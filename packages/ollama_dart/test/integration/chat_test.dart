@Tags(['integration'])
library;

import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

/// Integration tests for the Chat API.
///
/// These tests require a running Ollama server with a chat model.
/// Set OLLAMA_MODEL environment variable to specify the model (default: gpt-oss).
/// Run with: dart test --tags=integration
void main() {
  late OllamaClient client;
  late String model;

  setUpAll(() {
    client = OllamaClient();
    model = Platform.environment['OLLAMA_MODEL'] ?? 'gpt-oss';
  });

  tearDownAll(() {
    client.close();
  });

  group('ChatResource', () {
    test('create generates a response', () async {
      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.user('Say "Hello, World!" and nothing else.'),
          ],
        ),
      );

      expect(response.message, isNotNull);
      expect(response.message!.content, contains('Hello'));
      expect(response.done, isTrue);
    });

    test('createStream yields chunks', () async {
      final chunks = <ChatStreamEvent>[];

      await client.chat
          .createStream(
            request: ChatRequest(
              model: model,
              messages: const [ChatMessage.user('Count from 1 to 3.')],
            ),
          )
          .forEach(chunks.add);

      expect(chunks, isNotEmpty);
      expect(chunks.last.done, isTrue);

      // Concatenate all content
      final fullContent = chunks.map((c) => c.message?.content ?? '').join('');
      expect(fullContent, contains('1'));
    });

    test('multi-turn conversation works', () async {
      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.user('My name is Alice.'),
            ChatMessage.assistant('Nice to meet you, Alice!'),
            ChatMessage.user('What is my name?'),
          ],
        ),
      );

      expect(response.message, isNotNull);
      expect(response.message?.content?.toLowerCase(), contains('alice'));
    });

    test('system message affects response', () async {
      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.system('You are a pirate. Always speak like a pirate.'),
            ChatMessage.user('Hello!'),
          ],
        ),
      );

      expect(response.message, isNotNull);
      // Pirate speech often contains these
      final content = response.message?.content?.toLowerCase() ?? '';
      expect(
        content.contains('ahoy') ||
            content.contains('matey') ||
            content.contains('arr'),
        isTrue,
        reason: 'Expected pirate-like language',
      );
    });

    test('JSON format constraint works', () async {
      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.user(
              'Return a JSON object with name "Alice" and age 30.',
            ),
          ],
          format: 'json',
        ),
      );

      expect(response.message, isNotNull);
      final content = response.message!.content;
      expect(content, contains('{'));
      expect(content, contains('Alice'));
    });

    test('tool calling works', () async {
      const tool = ToolDefinition(
        type: ToolType.function,
        function: ToolFunction(
          name: 'get_current_weather',
          description: 'Get the current weather in a given location',
          parameters: {
            'type': 'object',
            'properties': {
              'location': {
                'type': 'string',
                'description': 'The city and country, e.g. San Francisco, US',
              },
              'unit': {
                'type': 'string',
                'description': 'The unit of temperature to return',
                'enum': ['celsius', 'fahrenheit'],
              },
            },
            'required': ['location'],
          },
        ),
      );

      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.system('You are a helpful assistant.'),
            ChatMessage.user(
              "What's the weather like in Boston and Barcelona in celsius?",
            ),
          ],
          tools: const [tool],
        ),
      );

      expect(response.done, isTrue);
      expect(response.message, isNotNull);
      expect(response.message!.role, MessageRole.assistant);

      final toolCalls = response.message!.toolCalls;
      expect(toolCalls, isNotNull);
      expect(toolCalls, isNotEmpty);

      // At least one tool call should have the correct function name
      final hasWeatherCall = toolCalls!.any(
        (tc) => tc.function?.name == 'get_current_weather',
      );
      expect(hasWeatherCall, isTrue);
    });

    test('stop sequence works', () async {
      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.system('You are a helpful assistant.'),
            ChatMessage.user(
              'List the numbers from 1 to 9 in order. '
              'Output ONLY the numbers without spaces or commas.',
            ),
          ],
          options: const ModelOptions(stop: ['4']),
        ),
      );

      expect(response.message, isNotNull);
      final content =
          response.message!.content?.replaceAll(RegExp(r'[\s\n]'), '') ?? '';
      expect(content, contains('123'));
      expect(content, isNot(contains('456789')));
    });

    test('numPredict limits output tokens', () async {
      final response = await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [
            ChatMessage.system('You are a helpful assistant.'),
            ChatMessage.user('List the numbers from 1 to 100 in order.'),
          ],
          options: const ModelOptions(numPredict: 1),
        ),
      );

      expect(response.done, isTrue);
      // With numPredict: 1, the response should be very short
      expect(response.evalCount, lessThanOrEqualTo(2));
    });

    test(
      'image input works with vision model',
      () async {
        final visionModel =
            Platform.environment['OLLAMA_VISION_MODEL'] ?? 'llava';

        final response = await client.chat.create(
          request: ChatRequest(
            model: visionModel,
            messages: const [
              ChatMessage.system('You are a helpful assistant.'),
              ChatMessage(
                role: MessageRole.user,
                content: 'Describe the contents of the image.',
                images: [
                  // Small base64 encoded star image
                  'iVBORw0KGgoAAAANSUhEUgAAAAkAAAANCAIAAAD0YtNRAAAABnRSTlMA/AD+APzoM1ogAAAAWklEQVR4AWP48+8PLkR7uUdzcMvtU8EhdykHKAciEXL3pvw5FQIURaBDJkARoDhY3zEXiCgCHbNBmAlUiyaBkENoxZSDWnOtBmoAQu7TnT+3WuDOA7KBIkAGAGwiNeqjusp/AAAAAElFTkSuQmCC',
                ],
              ),
            ],
          ),
        );

        expect(response.message, isNotNull);
        final content = response.message!.content?.toLowerCase() ?? '';
        expect(content, contains('star'));
      },
      skip: 'Requires a vision model (e.g., llava) to be available',
    );
  });
}
