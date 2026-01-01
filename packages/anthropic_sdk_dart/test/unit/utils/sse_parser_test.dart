import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SseParser', () {
    late SseParser parser;

    setUp(() {
      parser = SseParser();
    });

    test('parses SSE data with standard format', () async {
      // Standard Anthropic format: "event: <type>\ndata: <json>\n\n"
      const sseData = '''
event: message_start
data: {"type":"message_start","message":{}}

event: content_block_delta
data: {"type":"content_block_delta","delta":{}}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(2));
      expect(results[0]['type'], 'message_start');
      expect(results[1]['type'], 'content_block_delta');
    });

    test('parses SSE data without space after colon', () async {
      // Some providers use format without space: "data:{json}"
      const sseData = '''
event:message_start
data:{"type":"message_start","message":{}}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['type'], 'message_start');
    });

    test('handles empty data fields', () async {
      const sseData = '''
event: ping
data:

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, isEmpty);
    });

    test('handles UTF-8 characters correctly', () async {
      const sseData = '''
event: content_block_delta
data: {"type":"text_delta","text":"España 🇪🇸 日本語 🗾"}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['text'], 'España 🇪🇸 日本語 🗾');
    });

    test('filters out [DONE] marker', () async {
      const sseData = '''
event: message_stop
data: {"type":"message_stop"}

data: [DONE]

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['type'], 'message_stop');
    });

    test('handles streaming chunks (incremental data)', () async {
      // Simulate streaming: data arrives in chunks
      final controller = StreamController<List<int>>();

      final resultsFuture = parser.parse(controller.stream).toList();

      // Send data in chunks
      controller.add(utf8.encode('event: message_start\n'));
      await Future<void>.delayed(Duration.zero);

      controller.add(utf8.encode('data: {"type":"start"}\n'));
      await Future<void>.delayed(Duration.zero);

      controller.add(utf8.encode('\n'));
      await Future<void>.delayed(Duration.zero);

      controller
        ..add(utf8.encode('event: delta\n'))
        ..add(utf8.encode('data: {"type":"delta"}\n'))
        ..add(utf8.encode('\n'));
      await Future<void>.delayed(Duration.zero);

      await controller.close();

      final results = await resultsFuture;

      expect(results, hasLength(2));
      expect(results[0]['type'], 'start');
      expect(results[1]['type'], 'delta');
    });

    test('handles long JSON payloads', () async {
      // Test with large data
      final largeText = 'word ' * 1000;
      final largeJson = jsonEncode({
        'type': 'content_block_delta',
        'delta': {'text': largeText},
      });

      final sseData =
          '''
event: content_block_delta
data: $largeJson

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['type'], 'content_block_delta');
      expect((results[0]['delta'] as Map)['text'], largeText);
    });

    test('skips malformed JSON', () async {
      const sseData = '''
event: message_start
data: {"type":"message_start"}

event: bad_event
data: {invalid json here}

event: message_stop
data: {"type":"message_stop"}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      // Should skip the malformed JSON
      expect(results, hasLength(2));
      expect(results[0]['type'], 'message_start');
      expect(results[1]['type'], 'message_stop');
    });

    test('includes event type in parsed data', () async {
      const sseData = '''
event: message_start
data: {"type":"message_start","message":{}}

event: content_block_delta
data: {"type":"content_block_delta","delta":{}}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results[0].sseEventType, 'message_start');
      expect(results[1].sseEventType, 'content_block_delta');
    });

    test('withoutEventType removes internal field', () async {
      const sseData = '''
event: test_event
data: {"key":"value"}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results[0].sseEventType, 'test_event');
      expect(results[0].containsKey('_event'), isTrue);

      final cleaned = results[0].withoutEventType();
      expect(cleaned.containsKey('_event'), isFalse);
      expect(cleaned['key'], 'value');
    });

    test('handles data without event type', () async {
      const sseData = '''
data: {"type":"ping"}

''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['type'], 'ping');
      expect(results[0].sseEventType, isNull);
    });

    test('handles remaining data at stream end', () async {
      // Data without trailing empty line
      const sseData = '''
event: message_start
data: {"type":"message_start"}''';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parser.parse(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['type'], 'message_start');
    });
  });
}
