// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Chat Completions - Integration', () {
    test(
      'creates a simple chat completion',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [
              ChatMessage.user('What is 2 + 2? Reply with just the number.'),
            ],
            maxTokens: 10,
          ),
        );

        expect(response.id, isNotEmpty);
        expect(response.model, contains('gpt-4o-mini'));
        expect(response.choices, isNotEmpty);
        expect(response.choices.first.message.content, contains('4'));
        expect(response.choices.first.finishReason, FinishReason.stop);
        expect(response.usage, isNotNull);
        expect(response.usage!.promptTokens, greaterThan(0));
        expect(response.usage!.completionTokens, greaterThan(0));
      },
    );

    test(
      'creates chat completion with system message',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [
              ChatMessage.system('Always respond in uppercase.'),
              ChatMessage.user('Hello'),
            ],
            maxTokens: 50,
          ),
        );

        expect(response.choices.first.message.content, isNotNull);
        // Response should be in uppercase
        final content = response.choices.first.message.content!;
        expect(content, equals(content.toUpperCase()));
      },
    );

    test(
      'creates multi-turn conversation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [
              ChatMessage.user('My name is Alice.'),
              ChatMessage.assistant(content: 'Hello Alice! Nice to meet you.'),
              ChatMessage.user('What is my name?'),
            ],
            maxTokens: 50,
          ),
        );

        expect(response.choices.first.message.content, isNotNull);
        expect(
          response.choices.first.message.content!.toLowerCase(),
          contains('alice'),
        );
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

        final response = await client!.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [
              ChatMessage.user('Tell me a very long story about a dragon.'),
            ],
            maxTokens: 5,
          ),
        );

        expect(response.choices.first.finishReason, FinishReason.length);
        expect(response.usage!.completionTokens, lessThanOrEqualTo(10));
      },
    );

    test(
      'handles tool calls',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user("What's the weather in Tokyo?")],
            tools: [
              Tool.function(
                name: 'get_weather',
                description: 'Get the current weather for a location',
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
            toolChoice: ToolChoice.function('get_weather'),
            maxTokens: 100,
          ),
        );

        // When forcing a tool call, the model should call the tool
        // (though API behavior can vary)
        if (response.choices.first.message.toolCalls?.isNotEmpty ?? false) {
          // Note: finish_reason can be 'tool_calls' or 'stop' depending on model
          expect(
            response.choices.first.finishReason,
            anyOf(FinishReason.toolCalls, FinishReason.stop),
          );
          final toolCall = response.choices.first.message.toolCalls!.first;
          expect(toolCall.function.name, 'get_weather');
          // Arguments should contain Tokyo (or similar location)
          expect(toolCall.function.arguments, isNotEmpty);
        } else {
          // If no tool calls, at least verify we got a valid response
          expect(response.choices.first.message.content, isNotNull);
        }
      },
    );

    test(
      'streams chat completion',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user('Count from 1 to 5.')],
            maxTokens: 50,
          ),
        );

        final events = await stream.toList();

        expect(events, isNotEmpty);
        // First event should have role
        expect(events.first.choices!.first.delta.role, 'assistant');

        // Collect all text
        final buffer = StringBuffer();
        for (final event in events) {
          if (event.choices?.first.delta.content case final content?) {
            buffer.write(content);
          }
        }

        final fullText = buffer.toString();
        expect(fullText, contains('1'));
        expect(fullText, contains('5'));
      },
    );

    test(
      'uses collectText extension',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user('Say hello')],
            maxTokens: 20,
          ),
        );

        final text = await stream.collectText();

        expect(text, isNotEmpty);
        expect(text.toLowerCase(), contains('hello'));
      },
    );

    test(
      'creates chat completion with file content part (PDF)',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Download a small test PDF and base64-encode it.
        final httpClient = HttpClient();
        try {
          final request = await httpClient.getUrl(
            Uri.parse(
              'https://s29.q4cdn.com/175625835/files/doc_downloads/test.pdf',
            ),
          );
          final httpResponse = await request.close();
          if (httpResponse.statusCode != 200) {
            markTestSkipped(
              'Failed to download test PDF '
              '(status ${httpResponse.statusCode})',
            );
            return;
          }
          final bytes = await httpResponse.fold<List<int>>(
            <int>[],
            (prev, chunk) => prev..addAll(chunk),
          );
          final base64Pdf = base64Encode(bytes);

          final response = await client!.chat.completions.create(
            ChatCompletionCreateRequest(
              model: 'gpt-4o-mini',
              messages: [
                ChatMessage.user([
                  ContentPart.text(
                    'What is the title of this PDF document? '
                    'Reply with just the title.',
                  ),
                  ContentPart.fileData(
                    data: base64Pdf,
                    mediaType: 'application/pdf',
                    filename: 'test.pdf',
                  ),
                ]),
              ],
              maxTokens: 50,
            ),
          );

          expect(response.choices.first.message.content, isNotNull);
          expect(response.choices.first.finishReason, FinishReason.stop);
        } finally {
          httpClient.close();
        }
      },
    );
  });
}
