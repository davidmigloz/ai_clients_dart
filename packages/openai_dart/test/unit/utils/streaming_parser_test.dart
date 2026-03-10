import 'dart:convert';

import 'package:openai_dart/src/utils/streaming_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SseParser.parseRaw', () {
    const parser = SseParser();

    test('parses standard SSE events', () async {
      const input = 'event: message\ndata: {"type":"hello"}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      expect(events, hasLength(1));
      expect(events[0].event, 'message');
      expect(events[0].data, '{"type":"hello"}');
      expect(events[0].json, {'type': 'hello'});
    });

    test('[DONE] flushes buffered data before terminating', () async {
      // data: line followed by data: [DONE] without blank line between
      const input = 'data: {"type":"buffered"}\ndata: [DONE]\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      // Should get the buffered event, then the [DONE] event
      expect(events, hasLength(2));
      expect(events[0].data, '{"type":"buffered"}');
      expect(events[0].json, {'type': 'buffered'});
      expect(events[1].isDone, isTrue);
    });

    test('event type does not leak across events without data', () async {
      // event: error with no data, followed by a normal event
      const input =
          'event: error\n\nevent: message\ndata: {"type":"hello"}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      expect(events, hasLength(1));
      expect(events[0].event, 'message');
      expect(events[0].data, '{"type":"hello"}');
    });

    test('handles remaining data at stream end', () async {
      // Data without trailing empty line
      const input = 'event: test\ndata: {"type":"trailing"}';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      expect(events, hasLength(1));
      expect(events[0].event, 'test');
      expect(events[0].data, '{"type":"trailing"}');
    });

    test('preserves id and retry fields', () async {
      const input = 'id: 42\nretry: 3000\ndata: {"msg":"test"}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      expect(events, hasLength(1));
      expect(events[0].id, '42');
      expect(events[0].retry, 3000);
    });

    test('resets id and retry after empty line', () async {
      const input =
          'id: 1\ndata: {"first":"event"}\n\ndata: {"second":"event"}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      expect(events, hasLength(2));
      expect(events[0].id, '1');
      expect(events[1].id, isNull);
    });

    test('multi-line data is concatenated with newlines', () async {
      const input = 'data: line1\ndata: line2\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await parser.parseRaw(stream).toList();
      expect(events, hasLength(1));
      expect(events[0].data, 'line1\nline2');
    });
  });
}
