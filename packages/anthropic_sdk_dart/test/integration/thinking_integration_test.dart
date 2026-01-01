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

  group('Extended Thinking API - Integration', () {
    test(
      'creates message with extended thinking',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 16000,
            thinking: const ThinkingEnabled(budgetTokens: 5000),
            messages: [
              InputMessage.user(
                'What is 15% of 240? Think through this step by step.',
              ),
            ],
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.content, isNotEmpty);
        expect(response.stopReason, StopReason.endTurn);

        // Should have thinking blocks
        final thinkingBlocks = response.thinkingBlocks;
        expect(thinkingBlocks, isNotEmpty);

        // First content block should be thinking
        expect(response.content.first, isA<ThinkingBlock>());

        // Thinking content should have actual reasoning
        final thinking = response.thinking;
        expect(thinking, isNotEmpty);
        expect(thinking.length, greaterThan(10));

        // Should also have text response
        final textBlocks = response.content.whereType<TextBlock>().toList();
        expect(textBlocks, isNotEmpty);

        // The answer should contain 36 (15% of 240)
        expect(response.text, contains('36'));
      },
    );

    test(
      'streams message with extended thinking',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 16000,
            thinking: const ThinkingEnabled(budgetTokens: 3000),
            messages: [
              InputMessage.user('What is 7 times 8? Show your reasoning.'),
            ],
          ),
        );

        var hasThinkingBlock = false;
        var hasTextBlock = false;
        var thinkingContent = '';
        var textContent = '';

        await for (final event in stream) {
          switch (event) {
            case ContentBlockStartEvent(:final contentBlock):
              if (contentBlock is ThinkingBlock) {
                hasThinkingBlock = true;
              } else if (contentBlock is TextBlock) {
                hasTextBlock = true;
              }
            case ContentBlockDeltaEvent(:final delta):
              if (delta is ThinkingDelta) {
                thinkingContent += delta.thinking;
              } else if (delta is TextDelta) {
                textContent += delta.text;
              }
            default:
              break;
          }
        }

        // Should have received both thinking and text blocks
        expect(hasThinkingBlock, isTrue);
        expect(hasTextBlock, isTrue);

        // Thinking content should have reasoning
        expect(thinkingContent, isNotEmpty);

        // Text content should have the answer
        expect(textContent, isNotEmpty);
        expect(textContent, contains('56'));
      },
    );

    test(
      'handles complex reasoning with extended thinking',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 16000,
            thinking: const ThinkingEnabled(budgetTokens: 8000),
            messages: [
              InputMessage.user(
                'A farmer has chickens and cows. If there are 20 heads '
                'and 56 legs in total, how many chickens and cows does '
                'the farmer have? Solve step by step.',
              ),
            ],
          ),
        );

        // Should have thinking blocks with reasoning
        expect(response.hasThinking, isTrue);
        final thinking = response.thinking;
        expect(thinking, isNotEmpty);

        // The response should contain the solution
        // 12 chickens and 8 cows (or variations of the answer)
        final text = response.text.toLowerCase();
        expect(
          text.contains('12') && text.contains('8') ||
              text.contains('chicken') && text.contains('cow'),
          isTrue,
        );
      },
    );

    test(
      'thinking blocks have valid signatures',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 16000,
            thinking: const ThinkingEnabled(budgetTokens: 3000),
            messages: [InputMessage.user('What is 2 + 2? Think about it.')],
          ),
        );

        final thinkingBlocks = response.thinkingBlocks;
        expect(thinkingBlocks, isNotEmpty);

        // Each thinking block should have a signature
        for (final block in thinkingBlocks) {
          expect(block.signature, isNotEmpty);
        }
      },
    );
  });
}
