// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Messages API - Integration', () {
    test(
      'creates a simple message',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 100,
            messages: [
              InputMessage.user('What is 2 + 2? Reply with just the number.'),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.role, 'assistant');
        expect(response.content, isNotEmpty);
        expect(response.stopReason, StopReason.endTurn);
        expect(response.text, contains('4'));
        expect(response.usage.inputTokens, greaterThan(0));
        expect(response.usage.outputTokens, greaterThan(0));
      },
    );

    test(
      'creates a message with system prompt',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 100,
            system: SystemPrompt.text(
              'You are a helpful assistant that always responds in uppercase.',
            ),
            messages: [InputMessage.user('Hello')],
          ),
        );

        expect(response.content, isNotEmpty);
        // The response should be in uppercase
        expect(response.text, isNotEmpty);
      },
    );

    test(
      'creates a multi-turn conversation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 100,
            messages: [
              InputMessage.user('My name is Alice.'),
              InputMessage.assistant('Hello Alice! Nice to meet you.'),
              InputMessage.user('What is my name?'),
            ],
          ),
        );

        expect(response.content, isNotEmpty);
        expect(response.text.toLowerCase(), contains('alice'));
      },
    );

    test(
      'respects max_tokens limit',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 5,
            messages: [
              InputMessage.user('Tell me a long story about a dragon.'),
            ],
          ),
        );

        expect(response.stopReason, StopReason.maxTokens);
        expect(response.usage.outputTokens, lessThanOrEqualTo(10));
      },
    );

    test(
      'handles tool use',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 200,
            tools: const [
              {
                'name': 'get_weather',
                'description': 'Get the current weather for a location',
                'input_schema': {
                  'type': 'object',
                  'properties': {
                    'location': {
                      'type': 'string',
                      'description': 'The city name',
                    },
                  },
                  'required': ['location'],
                },
              },
            ],
            toolChoice: const {'type': 'tool', 'name': 'get_weather'},
            messages: [InputMessage.user("What's the weather in Tokyo?")],
          ),
        );

        expect(response.stopReason, StopReason.toolUse);
        expect(response.hasToolUse, isTrue);
        expect(response.toolUseBlocks, isNotEmpty);

        final toolUse = response.toolUseBlocks.first;
        expect(toolUse.name, 'get_weather');
        expect(toolUse.input, containsPair('location', contains('Tokyo')));
      },
    );
  });
}
