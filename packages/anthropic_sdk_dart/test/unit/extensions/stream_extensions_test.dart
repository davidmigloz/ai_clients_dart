import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

MessageStreamEvent _event(Map<String, dynamic> json) =>
    MessageStreamEvent.fromJson(json);

Stream<MessageStreamEvent> _streamFrom(List<Map<String, dynamic>> events) =>
    Stream.fromIterable(events.map(_event));

// ---------------------------------------------------------------------------
// Reusable JSON helpers (minimal subset for extension tests).
// ---------------------------------------------------------------------------

const Map<String, Object> _messageStartJson = {
  'type': 'message_start',
  'message': {
    'id': 'msg_123',
    'type': 'message',
    'role': 'assistant',
    'content': <dynamic>[],
    'model': 'claude-sonnet-4-20250514',
    'usage': {'input_tokens': 10, 'output_tokens': 0},
  },
};

Map<String, dynamic> _cbStart(int index, Map<String, dynamic> block) => {
  'type': 'content_block_start',
  'index': index,
  'content_block': block,
};

Map<String, dynamic> _cbDelta(int index, Map<String, dynamic> delta) => {
  'type': 'content_block_delta',
  'index': index,
  'delta': delta,
};

Map<String, dynamic> _cbStop(int index) => {
  'type': 'content_block_stop',
  'index': index,
};

Map<String, dynamic> _msgDelta({String? stopReason, int outputTokens = 5}) => {
  'type': 'message_delta',
  'delta': {'stop_reason': ?stopReason},
  'usage': {'output_tokens': outputTokens},
};

const _msgStop = {'type': 'message_stop'};
const _ping = {'type': 'ping'};

Map<String, dynamic> _textBlock() => {'type': 'text', 'text': ''};
Map<String, dynamic> _thinkingBlock() => {
  'type': 'thinking',
  'thinking': '',
  'signature': '',
};
Map<String, dynamic> _toolUseBlock() => {
  'type': 'tool_use',
  'id': 'toolu_1',
  'name': 'tool',
  'input': <String, dynamic>{},
};

Map<String, dynamic> _textDelta(String text) => {
  'type': 'text_delta',
  'text': text,
};
Map<String, dynamic> _thinkingDelta(String t) => {
  'type': 'thinking_delta',
  'thinking': t,
};
Map<String, dynamic> _inputJsonDelta(String j) => {
  'type': 'input_json_delta',
  'partial_json': j,
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MessageStreamExtension', () {
    test('collectText returns concatenated text', () async {
      final stream = _streamFrom([
        _messageStartJson,
        _cbStart(0, _textBlock()),
        _cbDelta(0, _textDelta('Hello')),
        _cbDelta(0, _textDelta(', ')),
        _cbDelta(0, _textDelta('world!')),
        _cbStop(0),
        _msgDelta(stopReason: 'end_turn'),
        _msgStop,
      ]);

      expect(await stream.collectText(), 'Hello, world!');
    });

    test('textDeltas yields individual chunks', () async {
      final stream = _streamFrom([
        _messageStartJson,
        _cbStart(0, _textBlock()),
        _cbDelta(0, _textDelta('a')),
        _cbDelta(0, _textDelta('b')),
        _cbDelta(0, _textDelta('c')),
        _cbStop(0),
        _msgDelta(stopReason: 'end_turn'),
        _msgStop,
      ]);

      final deltas = await stream.textDeltas().toList();
      expect(deltas, ['a', 'b', 'c']);
    });

    test('thinkingDeltas yields only thinking chunks', () async {
      final stream = _streamFrom([
        _messageStartJson,
        _cbStart(0, _thinkingBlock()),
        _cbDelta(0, _thinkingDelta('think1')),
        _cbDelta(0, _thinkingDelta('think2')),
        _cbDelta(0, {'type': 'signature_delta', 'signature': 'sig'}),
        _cbStop(0),
        _cbStart(1, _textBlock()),
        _cbDelta(1, _textDelta('visible')),
        _cbStop(1),
        _msgDelta(stopReason: 'end_turn'),
        _msgStop,
      ]);

      final deltas = await stream.thinkingDeltas().toList();
      expect(deltas, ['think1', 'think2']);
    });

    test('inputJsonDeltas yields only JSON chunks', () async {
      final stream = _streamFrom([
        _messageStartJson,
        _cbStart(0, _textBlock()),
        _cbDelta(0, _textDelta('text')),
        _cbStop(0),
        _cbStart(1, _toolUseBlock()),
        _cbDelta(1, _inputJsonDelta('{"ke')),
        _cbDelta(1, _inputJsonDelta('y":"val"}')),
        _cbStop(1),
        _msgDelta(stopReason: 'tool_use'),
        _msgStop,
      ]);

      final deltas = await stream.inputJsonDeltas().toList();
      expect(deltas, ['{"ke', 'y":"val"}']);
    });

    test('accumulate yields accumulator after each event', () async {
      final events = [
        _messageStartJson,
        _cbStart(0, _textBlock()),
        _cbDelta(0, _textDelta('Hi')),
        _cbStop(0),
        _msgDelta(stopReason: 'end_turn'),
        _msgStop,
      ];
      final stream = _streamFrom(events);
      final snapshots = await stream.accumulate().toList();

      // One yield per event.
      expect(snapshots, hasLength(events.length));

      // All are the same instance (mutable accumulator).
      for (var i = 1; i < snapshots.length; i++) {
        expect(identical(snapshots[i], snapshots[0]), isTrue);
      }

      // Final state has full text and stop reason.
      expect(snapshots.last.text, 'Hi');
      expect(snapshots.last.stopReason, StopReason.endTurn);
    });

    test('stopReason returns last stop reason', () async {
      final stream = _streamFrom([
        _messageStartJson,
        _cbStart(0, _textBlock()),
        _cbDelta(0, _textDelta('done')),
        _cbStop(0),
        _msgDelta(stopReason: 'end_turn'),
        _msgStop,
      ]);

      expect(await stream.stopReason, StopReason.endTurn);
    });

    test(
      'empty stream: collectText returns empty, stopReason returns null',
      () async {
        final emptyStream = _streamFrom([]);
        expect(await emptyStream.collectText(), '');

        final emptyStream2 = _streamFrom([]);
        expect(await emptyStream2.stopReason, isNull);

        final emptyStream3 = _streamFrom([]);
        expect(await emptyStream3.textDeltas().toList(), isEmpty);
      },
    );

    test('stream with only pings: collectText returns empty', () async {
      final stream = _streamFrom([_ping, _ping, _ping]);
      expect(await stream.collectText(), '');

      final stream2 = _streamFrom([_ping, _ping]);
      expect(await stream2.stopReason, isNull);
    });
  });
}
