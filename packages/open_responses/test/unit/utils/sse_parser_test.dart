import 'dart:convert';

import 'package:open_responses/src/utils/sse_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SseParser', () {
    test('parses standard SSE events', () async {
      const input = 'event: message\ndata: {"type":"response.created"}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await SseParser().parse(stream).toList();
      expect(events, hasLength(1));
      expect(events[0]['_event'], 'message');
    });

    test('yields synthetic JSON for event: error with non-JSON data', () async {
      const input = 'event: error\ndata: Service unavailable\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await SseParser().parse(stream).toList();
      expect(events, hasLength(1));
      expect(events[0]['_event'], 'error');
      expect(events[0]['_rawData'], 'Service unavailable');
      expect(events[0]['type'], 'error');
    });

    test('parses event: error with JSON data normally', () async {
      const input =
          'event: error\ndata: {"error":{"type":"server_error","message":"Overloaded"}}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await SseParser().parse(stream).toList();
      expect(events, hasLength(1));
      expect(events[0]['_event'], 'error');
      expect(events[0]['error'], isA<Map<String, dynamic>>());
    });

    test('[DONE] flushes buffered data before terminating', () async {
      const input = 'data: {"type":"response.created"}\ndata: [DONE]\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await SseParser().parse(stream).toList();
      expect(events, hasLength(1));
      expect(events[0]['type'], 'response.created');
    });

    test('event type does not leak across events without data', () async {
      const input =
          'event: error\n\nevent: message\ndata: {"type":"response.created"}\n\n';
      final stream = Stream<List<int>>.value(utf8.encode(input));

      final events = await SseParser().parse(stream).toList();
      expect(events, hasLength(1));
      expect(events[0]['type'], 'response.created');
      expect(events[0]['_event'], 'message');
    });
  });
}
