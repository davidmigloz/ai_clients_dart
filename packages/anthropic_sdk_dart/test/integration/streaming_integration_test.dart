// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:async';
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

  group('Streaming API - Integration', () {
    test(
      'streams a simple message',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 100,
            messages: [
              InputMessage.user('Count from 1 to 5, one number per line.'),
            ],
          ),
        );

        final events = <MessageStreamEvent>[];
        var text = '';

        await for (final event in stream) {
          events.add(event);
          if (event is ContentBlockDeltaEvent) {
            final delta = event.delta;
            if (delta is TextDelta) {
              text += delta.text;
            }
          }
        }

        // Verify we received expected event types
        expect(events.whereType<MessageStartEvent>(), hasLength(1));
        expect(events.whereType<ContentBlockStartEvent>(), isNotEmpty);
        expect(events.whereType<ContentBlockDeltaEvent>(), isNotEmpty);
        expect(events.whereType<ContentBlockStopEvent>(), isNotEmpty);
        expect(events.whereType<MessageDeltaEvent>(), hasLength(1));
        expect(events.whereType<MessageStopEvent>(), hasLength(1));

        // Verify text content
        expect(text, contains('1'));
        expect(text, contains('5'));

        // Verify stop reason
        final messageDelta = events.whereType<MessageDeltaEvent>().first;
        expect(messageDelta.delta.stopReason, StopReason.endTurn);
      },
    );

    test(
      'streams tool use',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.messages.createStream(
          MessageCreateRequest(
            model: 'claude-3-5-haiku-20241022',
            maxTokens: 200,
            tools: const [
              {
                'name': 'calculator',
                'description': 'Perform basic math operations',
                'input_schema': {
                  'type': 'object',
                  'properties': {
                    'operation': {
                      'type': 'string',
                      'enum': ['add', 'subtract', 'multiply', 'divide'],
                    },
                    'a': {'type': 'number'},
                    'b': {'type': 'number'},
                  },
                  'required': ['operation', 'a', 'b'],
                },
              },
            ],
            toolChoice: const {'type': 'tool', 'name': 'calculator'},
            messages: [InputMessage.user('What is 15 times 7?')],
          ),
        );

        final events = <MessageStreamEvent>[];
        var inputJson = '';

        await for (final event in stream) {
          events.add(event);
          if (event is ContentBlockDeltaEvent) {
            final delta = event.delta;
            if (delta is InputJsonDelta) {
              inputJson += delta.partialJson;
            }
          }
        }

        // Verify tool use block start
        final blockStarts = events.whereType<ContentBlockStartEvent>().toList();
        expect(blockStarts, isNotEmpty);
        expect(blockStarts.first.contentBlock, isA<ToolUseBlock>());

        // Verify stop reason
        final messageDelta = events.whereType<MessageDeltaEvent>().first;
        expect(messageDelta.delta.stopReason, StopReason.toolUse);

        // Verify input JSON was accumulated
        expect(inputJson, isNotEmpty);
      },
    );

    test(
      'can abort streaming request',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final abortCompleter = Completer<void>();
        var eventCount = 0;
        var wasAborted = false;

        try {
          final stream = client!.messages.createStream(
            MessageCreateRequest(
              model: 'claude-3-5-haiku-20241022',
              maxTokens: 1000,
              messages: [
                InputMessage.user('Write a very long essay about philosophy.'),
              ],
            ),
            abortTrigger: abortCompleter.future,
          );

          await for (final _ in stream) {
            eventCount++;
            // Abort after receiving a few events
            if (eventCount >= 5 && !abortCompleter.isCompleted) {
              abortCompleter.complete();
            }
          }
        } on AbortedException {
          wasAborted = true;
        }

        // We should have received some events before aborting
        expect(eventCount, greaterThanOrEqualTo(5));
        expect(wasAborted, isTrue);
      },
    );
  });
}
