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

  group('Chat Streaming - Integration', () {
    test(
      'streams chat completion events',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [
              ChatMessage.user('Count from 1 to 5, one number per line.'),
            ],
            maxTokens: 50,
          ),
        );

        final events = <ChatStreamEvent>[];

        await stream.forEach(events.add);

        expect(events, isNotEmpty);

        // First event should have role
        expect(events.first.choices!.first.delta.role, 'assistant');

        // Collect all content
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
      'stream collectText extension',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user('Say "streaming works"')],
            maxTokens: 20,
          ),
        );

        final text = await stream.collectText();

        expect(text.toLowerCase(), contains('streaming'));
        expect(text.toLowerCase(), contains('works'));
      },
    );

    test(
      'stream with system message',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [
              ChatMessage.system('Always respond with exactly 3 words.'),
              ChatMessage.user('Greet me'),
            ],
            maxTokens: 20,
          ),
        );

        final text = await stream.collectText();

        expect(text, isNotEmpty);
        // Should be approximately 3 words
        final words = text.trim().split(RegExp(r'\s+'));
        expect(words.length, lessThanOrEqualTo(5)); // Allow some flexibility
      },
    );

    test(
      'stream finishes with stop reason',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user('Hi')],
            maxTokens: 10,
          ),
        );

        FinishReason? finishReason;

        await for (final event in stream) {
          final choices = event.choices;
          if (choices != null &&
              choices.isNotEmpty &&
              choices.first.finishReason != null) {
            finishReason = choices.first.finishReason;
          }
        }

        expect(finishReason, isNotNull);
        expect(
          finishReason == FinishReason.stop ||
              finishReason == FinishReason.length,
          isTrue,
        );
      },
    );

    test(
      'stream with tool calls',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user("What's the weather in Paris?")],
            tools: [
              Tool.function(
                name: 'get_weather',
                description: 'Get weather for a city',
                parameters: const {
                  'type': 'object',
                  'properties': {
                    'city': {'type': 'string'},
                  },
                  'required': ['city'],
                },
              ),
            ],
            toolChoice: ToolChoice.function('get_weather'),
            maxTokens: 100,
          ),
        );

        final events = await stream.toList();

        expect(events, isNotEmpty);

        // Look for tool call chunks
        var hasToolCall = false;
        for (final event in events) {
          final choices = event.choices;
          if (choices != null &&
              choices.isNotEmpty &&
              (choices.first.delta.toolCalls?.isNotEmpty ?? false)) {
            hasToolCall = true;
            break;
          }
        }

        // With toolChoice forcing function, should have tool calls
        expect(hasToolCall, isTrue);
      },
    );

    test(
      'stream tool calls with ChatStreamAccumulator',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user("What's the weather in Paris?")],
            tools: [
              Tool.function(
                name: 'get_weather',
                description: 'Get weather for a city',
                parameters: const {
                  'type': 'object',
                  'properties': {
                    'city': {'type': 'string'},
                  },
                  'required': <dynamic>['city'],
                },
              ),
            ],
            toolChoice: ToolChoice.function('get_weather'),
            maxTokens: 100,
          ),
        );

        final accumulator = ChatStreamAccumulator();
        await stream.forEach(accumulator.add);
        final completion = accumulator.toChatCompletion();

        final toolCalls = completion.choices.first.message.toolCalls!;
        expect(toolCalls, isNotEmpty);
        expect(toolCalls.first.function.name, 'get_weather');
        final args =
            jsonDecode(toolCalls.first.function.arguments)
                as Map<String, dynamic>;
        expect(args['city'].toString().toLowerCase(), contains('paris'));
      },
    );

    test(
      'stream handles multiple choices',
      timeout: const Timeout(Duration(minutes: 2)),
      skip: 'n > 1 with streaming may not be supported for all models',
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user('Give me a word')],
            maxTokens: 10,
            n: 2,
          ),
        );

        final events = await stream.toList();

        // Should receive events for multiple choices
        final choiceIndices = <int>{};
        for (final event in events) {
          final choices = event.choices;
          if (choices == null) continue;
          for (final choice in choices) {
            if (choice.index != null) {
              choiceIndices.add(choice.index!);
            }
          }
        }

        expect(choiceIndices.length, greaterThanOrEqualTo(1));
      },
    );

    test(
      'stream usage with stream_options',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4o-mini',
            messages: [ChatMessage.user('Hello')],
            maxTokens: 20,
            streamOptions: const StreamOptions(includeUsage: true),
          ),
        );

        Usage? usage;

        await for (final event in stream) {
          if (event.usage != null) {
            usage = event.usage;
          }
        }

        // When includeUsage is true, final event should have usage
        expect(usage, isNotNull);
        expect(usage!.promptTokens, greaterThan(0));
        expect(usage.completionTokens, greaterThan(0));
        expect(usage.totalTokens, greaterThan(0));
      },
    );
  });
}
