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

  group('Token Counting API - Integration', () {
    test(
      'counts tokens for a simple message',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            messages: [InputMessage.user('Hello, how are you?')],
          ),
        );

        expect(response.inputTokens, greaterThan(0));
        // A simple greeting should be less than 20 tokens
        expect(response.inputTokens, lessThan(20));
      },
    );

    test(
      'counts tokens with system prompt',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First count without system prompt
        final withoutSystem = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            messages: [InputMessage.user('Hello')],
          ),
        );

        // Then count with system prompt
        final withSystem = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            system: SystemPrompt.text(
              'You are a helpful assistant that specializes in technical support.',
            ),
            messages: [InputMessage.user('Hello')],
          ),
        );

        // With system prompt should have more tokens
        expect(withSystem.inputTokens, greaterThan(withoutSystem.inputTokens));
      },
    );

    test(
      'counts tokens for multi-turn conversation',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final singleTurn = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            messages: [InputMessage.user('What is machine learning?')],
          ),
        );

        final multiTurn = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            messages: [
              InputMessage.user('What is machine learning?'),
              InputMessage.assistant(
                'Machine learning is a subset of artificial intelligence that '
                'enables systems to learn from data.',
              ),
              InputMessage.user('What are some common applications?'),
            ],
          ),
        );

        // Multi-turn should have more tokens
        expect(multiTurn.inputTokens, greaterThan(singleTurn.inputTokens));
      },
    );

    test(
      'counts tokens with tools',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final withoutTools = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            messages: [InputMessage.user("What's the weather?")],
          ),
        );

        final withTools = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-3-5-haiku-20241022',
            tools: const [
              {
                'name': 'get_weather',
                'description': 'Get the current weather for a location',
                'input_schema': {
                  'type': 'object',
                  'properties': {
                    'location': {
                      'type': 'string',
                      'description': 'City and state, e.g. San Francisco, CA',
                    },
                  },
                  'required': ['location'],
                },
              },
            ],
            messages: [InputMessage.user("What's the weather?")],
          ),
        );

        // With tools should have more tokens due to tool definitions
        expect(withTools.inputTokens, greaterThan(withoutTools.inputTokens));
      },
    );
  });
}
