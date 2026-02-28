import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

MessageStreamEvent _event(Map<String, dynamic> json) =>
    MessageStreamEvent.fromJson(json);

// ---------------------------------------------------------------------------
// Reusable JSON helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _messageStartJson({
  String id = 'msg_123',
  String model = 'claude-sonnet-4-20250514',
  int inputTokens = 100,
  int outputTokens = 0,
  Map<String, dynamic>? usageExtra,
}) {
  final usage = <String, dynamic>{
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    ...?usageExtra,
  };
  return {
    'type': 'message_start',
    'message': {
      'id': id,
      'type': 'message',
      'role': 'assistant',
      'content': <dynamic>[],
      'model': model,
      'usage': usage,
    },
  };
}

Map<String, dynamic> _contentBlockStartJson(
  int index,
  Map<String, dynamic> block,
) => {'type': 'content_block_start', 'index': index, 'content_block': block};

Map<String, dynamic> _contentBlockDeltaJson(
  int index,
  Map<String, dynamic> delta,
) => {'type': 'content_block_delta', 'index': index, 'delta': delta};

Map<String, dynamic> _contentBlockStopJson(int index) => {
  'type': 'content_block_stop',
  'index': index,
};

Map<String, dynamic> _messageDeltaJson({
  String? stopReason,
  String? stopSequence,
  Map<String, dynamic>? container,
  int outputTokens = 50,
  Map<String, dynamic>? usageExtra,
}) {
  final delta = <String, dynamic>{
    'stop_reason': ?stopReason,
    'stop_sequence': ?stopSequence,
    'container': ?container,
  };
  final usage = <String, dynamic>{
    'output_tokens': outputTokens,
    ...?usageExtra,
  };
  return {'type': 'message_delta', 'delta': delta, 'usage': usage};
}

const _messageStopJson = {'type': 'message_stop'};
const _pingJson = {'type': 'ping'};

Map<String, dynamic> _textBlockJson({String text = ''}) => {
  'type': 'text',
  'text': text,
};

Map<String, dynamic> _thinkingBlockJson({
  String thinking = '',
  String signature = '',
}) => {'type': 'thinking', 'thinking': thinking, 'signature': signature};

Map<String, dynamic> _toolUseBlockJson({
  String id = 'toolu_123',
  String name = 'get_weather',
  Map<String, dynamic> input = const {},
  Map<String, dynamic>? caller,
}) => {
  'type': 'tool_use',
  'id': id,
  'name': name,
  'input': input,
  'caller': ?caller,
};

Map<String, dynamic> _serverToolUseBlockJson({
  String id = 'srvtoolu_123',
  String name = 'web_search',
  Map<String, dynamic> input = const {'query': 'dart'},
}) => {'type': 'server_tool_use', 'id': id, 'name': name, 'input': input};

Map<String, dynamic> _compactionBlockJson({String? content}) => {
  'type': 'compaction',
  'content': content,
};

Map<String, dynamic> _redactedThinkingBlockJson({String data = 'abc123'}) => {
  'type': 'redacted_thinking',
  'data': data,
};

Map<String, dynamic> _containerUploadBlockJson({String fileId = 'file_1'}) => {
  'type': 'container_upload',
  'file_id': fileId,
};

Map<String, dynamic> _textDeltaJson(String text) => {
  'type': 'text_delta',
  'text': text,
};

Map<String, dynamic> _thinkingDeltaJson(String thinking) => {
  'type': 'thinking_delta',
  'thinking': thinking,
};

Map<String, dynamic> _inputJsonDeltaJson(String partialJson) => {
  'type': 'input_json_delta',
  'partial_json': partialJson,
};

Map<String, dynamic> _signatureDeltaJson(String signature) => {
  'type': 'signature_delta',
  'signature': signature,
};

Map<String, dynamic> _citationsDeltaJson(Map<String, dynamic> citation) => {
  'type': 'citations_delta',
  'citation': citation,
};

Map<String, dynamic> _compactionDeltaJson(String? content) => {
  'type': 'compaction_delta',
  'content': content,
};

Map<String, dynamic> _charLocationCitationJson({
  String citedText = 'cited',
  int documentIndex = 0,
  int startCharIndex = 0,
  int endCharIndex = 5,
}) => {
  'type': 'char_location',
  'cited_text': citedText,
  'document_index': documentIndex,
  'start_char_index': startCharIndex,
  'end_char_index': endCharIndex,
};

Map<String, dynamic> _webSearchCitationJson({
  String citedText = 'web cited',
  String encryptedIndex = 'enc_idx',
  String? title,
  String? url,
}) => {
  'type': 'web_search_result_location',
  'cited_text': citedText,
  'encrypted_index': encryptedIndex,
  'title': ?title,
  'url': ?url,
};

// ---------------------------------------------------------------------------
// Helper to feed a sequence of JSON events into an accumulator.
// ---------------------------------------------------------------------------

MessageStreamAccumulator _accumulate(List<Map<String, dynamic>> events) {
  final acc = MessageStreamAccumulator();
  for (final json in events) {
    acc.add(_event(json));
  }
  return acc;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MessageStreamAccumulator', () {
    // -- Core accumulation ---------------------------------------------------

    group('core accumulation', () {
      test('text-only stream', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hello')),
          _contentBlockDeltaJson(0, _textDeltaJson(', ')),
          _contentBlockDeltaJson(0, _textDeltaJson('world!')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.text, 'Hello, world!');
        expect(acc.contentBlocks, hasLength(1));
        expect(acc.textBlocks, hasLength(1));
        expect(acc.textBlocks.first.text, 'Hello, world!');
      });

      test('thinking + text stream', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _thinkingBlockJson()),
          _contentBlockDeltaJson(0, _thinkingDeltaJson('Let me think')),
          _contentBlockDeltaJson(0, _thinkingDeltaJson(' about this.')),
          _contentBlockDeltaJson(0, _signatureDeltaJson('sig_abc')),
          _contentBlockStopJson(0),
          _contentBlockStartJson(1, _textBlockJson()),
          _contentBlockDeltaJson(1, _textDeltaJson('The answer is 42.')),
          _contentBlockStopJson(1),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.thinking, 'Let me think about this.');
        expect(acc.hasThinking, isTrue);
        expect(acc.text, 'The answer is 42.');
        expect(acc.contentBlocks, hasLength(2));
        expect(acc.contentBlocks[0], isA<ThinkingBlock>());
        expect(acc.contentBlocks[1], isA<TextBlock>());
        expect((acc.contentBlocks[0] as ThinkingBlock).signature, 'sig_abc');
      });

      test('tool use stream', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _toolUseBlockJson()),
          _contentBlockDeltaJson(0, _inputJsonDeltaJson('{"city"')),
          _contentBlockDeltaJson(0, _inputJsonDeltaJson(': "San ')),
          _contentBlockDeltaJson(0, _inputJsonDeltaJson('Francisco"}')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);

        expect(acc.hasToolUse, isTrue);
        expect(acc.toolUseBlocks, hasLength(1));
        expect(acc.toolUseBlocks[0].input, {'city': 'San Francisco'});
        expect(acc.toolUseBlocks[0].id, 'toolu_123');
        expect(acc.toolUseBlocks[0].name, 'get_weather');
      });

      test('multiple content blocks (text + tool use)', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Let me check.')),
          _contentBlockStopJson(0),
          _contentBlockStartJson(1, _toolUseBlockJson()),
          _contentBlockDeltaJson(1, _inputJsonDeltaJson('{"q":"dart"}')),
          _contentBlockStopJson(1),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);

        expect(acc.contentBlocks, hasLength(2));
        expect(acc.contentBlocks[0], isA<TextBlock>());
        expect(acc.contentBlocks[1], isA<ToolUseBlock>());
        expect(acc.text, 'Let me check.');
        expect(acc.hasToolUse, isTrue);
      });

      test('server tool use block pass-through', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _serverToolUseBlockJson()),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.contentBlocks, hasLength(1));
        final block = acc.contentBlocks[0];
        expect(block, isA<ServerToolUseBlock>());
        expect((block as ServerToolUseBlock).name, 'web_search');
        expect(block.input, {'query': 'dart'});
      });

      test('compaction block with deltas', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _compactionBlockJson()),
          _contentBlockDeltaJson(0, _compactionDeltaJson('Summary ')),
          _contentBlockDeltaJson(0, _compactionDeltaJson('of context.')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'compaction'),
          _messageStopJson,
        ]);

        expect(acc.contentBlocks, hasLength(1));
        final block = acc.contentBlocks[0];
        expect(block, isA<CompactionBlock>());
        expect((block as CompactionBlock).content, 'Summary of context.');
      });

      test('redacted thinking block pass-through', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _redactedThinkingBlockJson()),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.contentBlocks, hasLength(1));
        final block = acc.contentBlocks[0];
        expect(block, isA<RedactedThinkingBlock>());
        expect((block as RedactedThinkingBlock).data, 'abc123');
      });
    });

    // -- toMessage and round-trip --------------------------------------------

    group('toMessage and round-trip', () {
      test('toMessage produces valid Message', () {
        final acc = _accumulate([
          _messageStartJson(id: 'msg_test', model: 'claude-test'),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hello!')),
          _contentBlockStopJson(0),
          _messageDeltaJson(
            stopReason: 'end_turn',
            stopSequence: null,
            outputTokens: 25,
          ),
          _messageStopJson,
        ]);

        final message = acc.toMessage();
        expect(message.id, 'msg_test');
        expect(message.type, 'message');
        expect(message.role, MessageRole.assistant);
        expect(message.model, 'claude-test');
        expect(message.content, hasLength(1));
        expect(message.content[0], isA<TextBlock>());
        expect((message.content[0] as TextBlock).text, 'Hello!');
        expect(message.stopReason, StopReason.endTurn);
        expect(message.stopSequence, isNull);
        expect(message.usage.inputTokens, 100);
        expect(message.usage.outputTokens, 25);
      });

      test('toMessage round-trips through JSON', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hi there')),
          _contentBlockStopJson(0),
          _contentBlockStartJson(1, _toolUseBlockJson()),
          _contentBlockDeltaJson(1, _inputJsonDeltaJson('{"key":"val"}')),
          _contentBlockStopJson(1),
          _messageDeltaJson(stopReason: 'tool_use', outputTokens: 30),
          _messageStopJson,
        ]);

        final original = acc.toMessage();
        final json = original.toJson();
        final restored = Message.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.model, original.model);
        expect(restored.role, original.role);
        expect(restored.stopReason, original.stopReason);
        expect(restored.usage.inputTokens, original.usage.inputTokens);
        expect(restored.usage.outputTokens, original.usage.outputTokens);
        expect(restored.content, hasLength(2));
        expect((restored.content[0] as TextBlock).text, 'Hi there');
        expect((restored.content[1] as ToolUseBlock).input, {'key': 'val'});
      });

      test('toMessage before any events throws StateError', () {
        final acc = MessageStreamAccumulator();
        expect(acc.toMessage, throwsStateError);
      });
    });

    // -- Usage and metadata --------------------------------------------------

    group('usage and metadata', () {
      test('usage merging preserves base-only fields', () {
        final acc = _accumulate([
          _messageStartJson(
            usageExtra: {
              'service_tier': 'standard',
              'inference_geo': 'us',
              'cache_creation_input_tokens': 10,
              'cache_read_input_tokens': 20,
            },
          ),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hi')),
          _contentBlockStopJson(0),
          _messageDeltaJson(
            stopReason: 'end_turn',
            outputTokens: 50,
            usageExtra: {
              'server_tool_use': {
                'web_search_requests': 1,
                'web_fetch_requests': 0,
              },
              'speed': 'fast',
            },
          ),
          _messageStopJson,
        ]);

        final usage = acc.usage!;
        expect(usage.inputTokens, 100);
        expect(usage.outputTokens, 50);
        expect(usage.serviceTier, ServiceTier.standard);
        expect(usage.inferenceGeo, 'us');
        expect(usage.cacheCreationInputTokens, 10);
        expect(usage.cacheReadInputTokens, 20);
        expect(usage.serverToolUse, isNotNull);
        expect(usage.serverToolUse!.webSearchRequests, 1);
      });

      test(
        'usage from delta without prior message_start preserves all fields',
        () {
          // Directly feed a message_delta without message_start to exercise
          // the _mergeUsage null-base fallback path.
          final acc = MessageStreamAccumulator()
            ..add(
              _event(
                _messageDeltaJson(
                  stopReason: 'end_turn',
                  outputTokens: 42,
                  usageExtra: {
                    'input_tokens': 10,
                    'cache_creation_input_tokens': 5,
                    'cache_read_input_tokens': 3,
                    'server_tool_use': {
                      'web_search_requests': 2,
                      'web_fetch_requests': 1,
                    },
                    'speed': 'fast',
                  },
                ),
              ),
            );

          final usage = acc.usage!;
          expect(usage.inputTokens, 10);
          expect(usage.outputTokens, 42);
          expect(usage.cacheCreationInputTokens, 5);
          expect(usage.cacheReadInputTokens, 3);
          expect(usage.serverToolUse, isNotNull);
          expect(usage.serverToolUse!.webSearchRequests, 2);
          expect(usage.speed, Speed.fast);
        },
      );

      test('stop reason and stop sequence', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hi')),
          _contentBlockStopJson(0),
          _messageDeltaJson(
            stopReason: 'stop_sequence',
            stopSequence: '###',
            outputTokens: 5,
          ),
          _messageStopJson,
        ]);

        expect(acc.stopReason, StopReason.stopSequence);
        expect(acc.stopSequence, '###');
      });

      test('stopReason/stopSequence preserved when later delta has null', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hi')),
          _contentBlockStopJson(0),
          // First message_delta sets stop reason and sequence.
          _messageDeltaJson(
            stopReason: 'end_turn',
            stopSequence: '###',
            outputTokens: 10,
          ),
          // Second message_delta with null stop reason/sequence.
          _messageDeltaJson(outputTokens: 20),
          _messageStopJson,
        ]);

        // The earlier non-null values should be preserved (null-coalescing).
        expect(acc.stopReason, StopReason.endTurn);
        expect(acc.stopSequence, '###');
      });

      test('container from message_delta', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hi')),
          _contentBlockStopJson(0),
          _messageDeltaJson(
            stopReason: 'end_turn',
            container: {'id': 'ctr_123', 'expires_at': '2026-01-01T00:00:00Z'},
          ),
          _messageStopJson,
        ]);

        expect(acc.container, isNotNull);
        expect(acc.container!.id, 'ctr_123');
      });

      test('model, id, role from message_start', () {
        final acc = MessageStreamAccumulator();
        expect(acc.id, isNull);
        expect(acc.model, isNull);

        acc.add(_event(_messageStartJson(id: 'msg_x', model: 'claude-x')));
        expect(acc.id, 'msg_x');
        expect(acc.model, 'claude-x');
      });
    });

    // -- Citations and signatures --------------------------------------------

    group('citations and signatures', () {
      test('multiple citations on text block', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Some text')),
          _contentBlockDeltaJson(
            0,
            _citationsDeltaJson(_charLocationCitationJson(citedText: 'a')),
          ),
          _contentBlockDeltaJson(
            0,
            _citationsDeltaJson(_charLocationCitationJson(citedText: 'b')),
          ),
          _contentBlockDeltaJson(
            0,
            _citationsDeltaJson(_charLocationCitationJson(citedText: 'c')),
          ),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.textBlocks[0].citations, hasLength(3));
      });

      test('signature overwrite (2 deltas)', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _thinkingBlockJson()),
          _contentBlockDeltaJson(0, _thinkingDeltaJson('thinking')),
          _contentBlockDeltaJson(0, _signatureDeltaJson('sig_first')),
          _contentBlockDeltaJson(0, _signatureDeltaJson('sig_last')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.thinkingBlocks[0].signature, 'sig_last');
      });

      test('citations with different types', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Mixed citations')),
          _contentBlockDeltaJson(
            0,
            _citationsDeltaJson(_charLocationCitationJson()),
          ),
          _contentBlockDeltaJson(
            0,
            _citationsDeltaJson(_webSearchCitationJson(title: 'Web Source')),
          ),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        final citations = acc.textBlocks[0].citations!;
        expect(citations, hasLength(2));
        expect(citations[0], isA<CharLocationCitation>());
        expect(citations[1], isA<WebSearchResultLocationCitation>());
      });
    });

    // -- Convenience getters -------------------------------------------------

    group('convenience getters', () {
      test('text with no text blocks returns empty string', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _toolUseBlockJson()),
          _contentBlockDeltaJson(0, _inputJsonDeltaJson('{}')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);

        expect(acc.text, '');
      });

      test('thinking with no thinking blocks', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hi')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.thinking, '');
        expect(acc.hasThinking, isFalse);
      });

      test('isMaxTokens, isEndTurn, isToolUse', () {
        final maxTokensAcc = _accumulate([
          _messageStartJson(),
          _messageDeltaJson(stopReason: 'max_tokens'),
          _messageStopJson,
        ]);
        expect(maxTokensAcc.isMaxTokens, isTrue);
        expect(maxTokensAcc.isEndTurn, isFalse);
        expect(maxTokensAcc.isToolUse, isFalse);

        final endTurnAcc = _accumulate([
          _messageStartJson(),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);
        expect(endTurnAcc.isEndTurn, isTrue);

        final toolUseAcc = _accumulate([
          _messageStartJson(),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);
        expect(toolUseAcc.isToolUse, isTrue);
      });
    });

    // -- Edge cases ----------------------------------------------------------

    group('edge cases', () {
      test('ping and error events are ignored', () {
        final acc = _accumulate([
          _messageStartJson(),
          _pingJson,
          _contentBlockStartJson(0, _textBlockJson()),
          {
            'type': 'error',
            'error': {'type': 'overloaded_error', 'message': 'Overloaded'},
          },
          _contentBlockDeltaJson(0, _textDeltaJson('Hi')),
          _pingJson,
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.text, 'Hi');
        expect(acc.contentBlocks, hasLength(1));
      });

      test('reset clears all state', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('Hello')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.text, 'Hello');
        acc.reset();

        expect(acc.id, isNull);
        expect(acc.model, isNull);
        expect(acc.usage, isNull);
        expect(acc.stopReason, isNull);
        expect(acc.stopSequence, isNull);
        expect(acc.container, isNull);
        expect(acc.text, '');
        expect(acc.thinking, '');
        expect(acc.hasThinking, isFalse);
        expect(acc.contentBlocks, isEmpty);

        // Can accumulate again after reset.
        acc
          ..add(_event(_messageStartJson(id: 'msg_new', model: 'claude-new')))
          ..add(_event(_contentBlockStartJson(0, _textBlockJson())))
          ..add(_event(_contentBlockDeltaJson(0, _textDeltaJson('New'))))
          ..add(_event(_contentBlockStopJson(0)))
          ..add(_event(_messageDeltaJson(stopReason: 'end_turn')))
          ..add(_event(_messageStopJson));

        final message = acc.toMessage();
        expect(message.id, 'msg_new');
        expect(message.text, 'New');
      });

      test('empty tool use input produces empty map', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _toolUseBlockJson()),
          // No InputJsonDelta events.
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);

        expect(acc.toolUseBlocks[0].input, isEmpty);
      });

      test('tool use with malformed JSON falls back to empty map', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _toolUseBlockJson()),
          _contentBlockDeltaJson(0, _inputJsonDeltaJson('{"city":')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);

        expect(acc.toolUseBlocks[0].input, isEmpty);
      });

      test('tool use with caller metadata preserved', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(
            0,
            _toolUseBlockJson(caller: {'type': 'tool', 'tool_id': 'tool_abc'}),
          ),
          _contentBlockDeltaJson(0, _inputJsonDeltaJson('{}')),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'tool_use'),
          _messageStopJson,
        ]);

        expect(acc.toolUseBlocks[0].caller, isNotNull);
        expect(acc.toolUseBlocks[0].caller, isA<ServerToolCaller>());
        expect(
          (acc.toolUseBlocks[0].caller! as ServerToolCaller).toolId,
          'tool_abc',
        );
      });

      test(
        'toMessage mid-stream then continue does not corrupt first message',
        () {
          final acc = MessageStreamAccumulator()
            ..add(_event(_messageStartJson()))
            ..add(_event(_contentBlockStartJson(0, _textBlockJson())))
            ..add(_event(_contentBlockDeltaJson(0, _textDeltaJson('Hello'))))
            ..add(
              _event(
                _contentBlockDeltaJson(
                  0,
                  _citationsDeltaJson(
                    _charLocationCitationJson(citedText: 'c1'),
                  ),
                ),
              ),
            );

          // Take snapshot mid-stream.
          final firstMessage = acc.toMessage();
          final firstText = (firstMessage.content[0] as TextBlock).text;
          final firstCitations =
              (firstMessage.content[0] as TextBlock).citations!;

          // Continue accumulating.
          acc
            ..add(_event(_contentBlockDeltaJson(0, _textDeltaJson(' world'))))
            ..add(
              _event(
                _contentBlockDeltaJson(
                  0,
                  _citationsDeltaJson(
                    _charLocationCitationJson(citedText: 'c2'),
                  ),
                ),
              ),
            )
            ..add(_event(_contentBlockStopJson(0)))
            ..add(_event(_messageDeltaJson(stopReason: 'end_turn')))
            ..add(_event(_messageStopJson));

          // First message is NOT corrupted.
          expect(firstText, 'Hello');
          expect(firstCitations, hasLength(1));

          // Second snapshot has the full data.
          final secondMessage = acc.toMessage();
          expect((secondMessage.content[0] as TextBlock).text, 'Hello world');
          expect(
            (secondMessage.content[0] as TextBlock).citations,
            hasLength(2),
          );
        },
      );

      test('ContainerUploadBlock pass-through', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _containerUploadBlockJson()),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.contentBlocks, hasLength(1));
        final block = acc.contentBlocks[0];
        expect(block, isA<ContainerUploadBlock>());
        expect((block as ContainerUploadBlock).fileId, 'file_1');
      });

      test('compaction block with null initial content and no deltas', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _compactionBlockJson()),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'compaction'),
          _messageStopJson,
        ]);

        final block = acc.contentBlocks[0] as CompactionBlock;
        expect(block.content, isNull);
      });

      test('compaction delta with null content is no-op', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _compactionBlockJson(content: 'initial')),
          _contentBlockDeltaJson(0, _compactionDeltaJson(null)),
          _contentBlockStopJson(0),
          _messageDeltaJson(stopReason: 'compaction'),
          _messageStopJson,
        ]);

        final block = acc.contentBlocks[0] as CompactionBlock;
        // Buffer is empty (null delta was no-op), so falls back to initial.
        expect(block.content, 'initial');
      });
    });

    // -- Out-of-bounds protection --------------------------------------------

    group('out-of-bounds protection', () {
      test('delta for non-existent block index is silently ignored', () {
        final acc = _accumulate([
          _messageStartJson(),
          _contentBlockStartJson(0, _textBlockJson()),
          _contentBlockDeltaJson(0, _textDeltaJson('OK')),
          _contentBlockStartJson(1, _textBlockJson()),
          // Index 5 does not exist — should not crash.
          _contentBlockDeltaJson(5, _textDeltaJson('Ghost')),
          _contentBlockStopJson(0),
          _contentBlockStopJson(1),
          _messageDeltaJson(stopReason: 'end_turn'),
          _messageStopJson,
        ]);

        expect(acc.contentBlocks, hasLength(2));
        expect(acc.text, 'OK');
      });
    });
  });
}
