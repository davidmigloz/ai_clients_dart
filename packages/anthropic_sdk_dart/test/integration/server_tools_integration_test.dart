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
    final key = Platform.environment['ANTHROPIC_API_KEY'];
    if (key == null || key.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      apiKey = key;
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(key)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Server Tools - Web Search Integration', () {
    test(
      'web search returns results',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-6',
            maxTokens: 1024,
            tools: [ToolDefinition.builtIn(BuiltInTool.webSearch())],
            messages: [
              InputMessage.user(
                'What is the capital of France? Use web search.',
              ),
            ],
          ),
        );

        expect(response.id, isNotEmpty);

        // Find web search result blocks
        final webSearchResults = response.content
            .whereType<WebSearchToolResultBlock>()
            .toList();
        expect(webSearchResults, isNotEmpty);

        final result = webSearchResults.first;
        expect(result.content, isA<WebSearchResultSuccess>());
        final success = result.content as WebSearchResultSuccess;
        expect(success.results, isNotEmpty);
        expect(success.results.first.url, isNotEmpty);
        expect(success.results.first.title, isNotEmpty);
      },
    );

    test(
      'web search streaming returns results',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-sonnet-4-6',
            maxTokens: 1024,
            tools: [ToolDefinition.builtIn(BuiltInTool.webSearch())],
            messages: [
              InputMessage.user(
                'What is the capital of France? Use web search.',
              ),
            ],
          ),
        );

        var hasWebSearchResult = false;

        await for (final event in stream) {
          if (event case ContentBlockStartEvent(:final contentBlock)) {
            if (contentBlock is WebSearchToolResultBlock) {
              hasWebSearchResult = true;
              expect(contentBlock.content, isA<WebSearchResultSuccess>());
            }
          }
        }

        expect(hasWebSearchResult, isTrue);
      },
    );
  });

  group('Server Tools - Advisor Integration', () {
    test(
      'advisor tool returns advisor result (non-streaming)',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-6',
            maxTokens: 4096,
            tools: [
              ToolDefinition.builtIn(
                const AdvisorTool(model: 'claude-opus-4-6'),
              ),
            ],
            messages: [
              InputMessage.user(
                'Build a concurrent worker pool in Go with graceful shutdown.',
              ),
            ],
          ),
          betas: ['advisor-tool-2026-03-01'],
        );

        expect(response.id, isNotEmpty);

        // Should contain a server_tool_use block for the advisor
        final serverToolUses = response.content
            .whereType<ServerToolUseBlock>()
            .toList();
        final advisorUses = serverToolUses
            .where((b) => b.name == 'advisor')
            .toList();
        expect(advisorUses, isNotEmpty, reason: 'Expected advisor tool use');
        expect(advisorUses.first.input, isEmpty);

        // Should contain an advisor_tool_result block
        final advisorResults = response.content
            .whereType<AdvisorToolResultBlock>()
            .toList();
        expect(
          advisorResults,
          isNotEmpty,
          reason: 'Expected advisor tool result',
        );

        final result = advisorResults.first;
        expect(
          result.content,
          anyOf(isA<AdvisorResult>(), isA<AdvisorRedactedResult>()),
        );

        if (result.content is AdvisorResult) {
          expect((result.content as AdvisorResult).text, isNotEmpty);
        }

        // Usage should contain an advisor_message iteration
        expect(response.usage.iterations, isNotNull);
        final advisorIterations = response.usage.iterations!
            .where((i) => i.type == 'advisor_message')
            .toList();
        expect(
          advisorIterations,
          isNotEmpty,
          reason: 'Expected advisor_message in iterations',
        );
        expect(advisorIterations.first.model, isNotEmpty);
      },
    );

    test(
      'advisor tool works with streaming',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-sonnet-4-6',
            maxTokens: 4096,
            tools: [
              ToolDefinition.builtIn(
                const AdvisorTool(model: 'claude-opus-4-6'),
              ),
            ],
            messages: [
              InputMessage.user(
                'Build a concurrent worker pool in Go with graceful shutdown.',
              ),
            ],
          ),
          betas: ['advisor-tool-2026-03-01'],
        );

        var hasAdvisorResult = false;
        Message? finalMessage;

        await for (final event in stream) {
          if (event case ContentBlockStartEvent(:final contentBlock)) {
            if (contentBlock is AdvisorToolResultBlock) {
              hasAdvisorResult = true;
            }
          }
          if (event case MessageStopEvent()) {
            // The stream completed.
          }
          if (event case MessageStartEvent(:final message)) {
            finalMessage = message;
          }
        }

        expect(hasAdvisorResult, isTrue);
        expect(finalMessage, isNotNull);
        expect(finalMessage!.id, isNotEmpty);
      },
    );
  });
}
