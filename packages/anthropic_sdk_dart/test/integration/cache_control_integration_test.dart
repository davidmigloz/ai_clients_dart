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

  group('Top-level Cache Control - Integration', () {
    test(
      'creates a message with top-level cache control',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-haiku-4-5-20251001',
            maxTokens: 100,
            messages: [
              InputMessage.user('What is 2 + 2? Reply with just the number.'),
            ],
            cacheControl: const CacheControlEphemeral(),
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.role, MessageRole.assistant);
        expect(response.content, isNotEmpty);
        expect(response.text, contains('4'));
      },
    );

    test(
      'creates a message with top-level cache control and TTL',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-haiku-4-5-20251001',
            maxTokens: 100,
            system: SystemPrompt.text('You are a helpful assistant.'),
            messages: [InputMessage.user('Say hello.')],
            cacheControl: const CacheControlEphemeral(ttl: CacheTtl.ttl5m),
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.content, isNotEmpty);
      },
    );

    test(
      'counts tokens with top-level cache control',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.countTokens(
          TokenCountRequest(
            model: 'claude-haiku-4-5-20251001',
            messages: [InputMessage.user('Hello, how are you?')],
            cacheControl: const CacheControlEphemeral(),
          ),
        );

        expect(response.inputTokens, greaterThan(0));
      },
    );
  });
}
