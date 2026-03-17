// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPEN_ROUTER_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPEN_ROUTER_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient.withApiKey(
        apiKey!,
        baseUrl: 'https://openrouter.ai/api/v1',
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('OpenRouter - Integration', () {
    const models = [
      'openai/gpt-5.4-nano',
      'anthropic/claude-haiku-4.5',
      'google/gemini-2.5-flash-lite',
      'mistralai/mistral-nemo',
    ];

    test(
      'creates a chat completion across different providers',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        for (final model in models) {
          final response = await client!.chat.completions.create(
            ChatCompletionCreateRequest(
              model: model,
              messages: [
                ChatMessage.user(
                  'List the numbers from 1 to 5 in order. '
                  'Output ONLY the numbers separated by commas.',
                ),
              ],
              maxTokens: 20,
            ),
          );

          expect(response.choices, isNotEmpty, reason: model);
          expect(
            response.choices.first.message.content,
            isNotNull,
            reason: model,
          );
          final content = response.choices.first.message.content!;
          expect(content, contains('1'), reason: model);
          expect(content, contains('5'), reason: model);
        }
      },
    );

    test(
      'streams a chat completion across different providers',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        for (final model in models) {
          final stream = client!.chat.completions.createStream(
            ChatCompletionCreateRequest(
              model: model,
              messages: [
                ChatMessage.user(
                  'List the numbers from 1 to 5 in order. '
                  'Output ONLY the numbers separated by commas.',
                ),
              ],
              maxTokens: 20,
            ),
          );

          var content = '';
          var chunkCount = 0;
          await for (final event in stream) {
            final delta = event.choices?.first.delta.content;
            if (delta != null) {
              content += delta;
              chunkCount++;
            }
          }

          expect(chunkCount, greaterThan(0), reason: model);
          expect(content, contains('1'), reason: model);
          expect(content, contains('5'), reason: model);
        }
      },
    );
  });
}
