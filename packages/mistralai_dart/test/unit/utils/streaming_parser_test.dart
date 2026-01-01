import 'dart:async';
import 'dart:convert';

// Import the streaming parser functions
// Note: Since parseSSE is not exported, we test through integration
// or recreate the logic for unit testing
import 'package:mistralai_dart/src/utils/streaming_parser.dart';
import 'package:test/test.dart';

void main() {
  group('parseSSE', () {
    test('parses SSE data with space after colon (standard format)', () async {
      final sseData = [
        'data: {"id":"1","object":"chat.completion.chunk","choices":[]}',
        '',
        'data: {"id":"2","object":"chat.completion.chunk","choices":[]}',
        '',
        'data: [DONE]',
      ].join('\n');

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      expect(results, hasLength(2));
      expect(results[0]['id'], '1');
      expect(results[1]['id'], '2');
    });

    test('filters out [DONE] messages correctly', () async {
      final sseData = [
        'data: {"id":"1","object":"chat.completion.chunk"}',
        '',
        'data: [DONE]',
      ].join('\n');

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['id'], '1');
    });

    test('handles empty lines', () async {
      final sseData = [
        '',
        'data: {"id":"1"}',
        '',
        '',
        'data: {"id":"2"}',
        '',
      ].join('\n');

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      expect(results, hasLength(2));
    });

    test('handles UTF-8 characters correctly', () async {
      final sseData = [
        'data: {"text":"España 🇪🇸"}',
        'data: {"text":"日本語 🗾"}',
        'data: [DONE]',
      ].join('\n');

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      expect(results, hasLength(2));
      expect(results[0]['text'], 'España 🇪🇸');
      expect(results[1]['text'], '日本語 🗾');
    });

    test('filters out non-data lines', () async {
      final sseData = [
        ':comment line',
        'event: message',
        'data: {"id":"1"}',
        'id: 123',
        'data: {"id":"2"}',
        'data: [DONE]',
      ].join('\n');

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      // Only data: lines should be processed
      expect(results, hasLength(2));
      expect(results[0]['id'], '1');
      expect(results[1]['id'], '2');
    });

    test('handles streaming chunks (incremental data)', () async {
      final controller = StreamController<List<int>>();
      final resultsFuture = parseSSE(controller.stream).toList();

      // Send data in chunks
      controller.add(utf8.encode('data: {"id":"1"}\n'));
      await Future<void>.delayed(Duration.zero);

      controller.add(utf8.encode('data: {"id":"2"}\n'));
      await Future<void>.delayed(Duration.zero);

      controller.add(utf8.encode('data: [DONE]\n'));
      await controller.close();

      final results = await resultsFuture;

      expect(results, hasLength(2));
      expect(results[0]['id'], '1');
      expect(results[1]['id'], '2');
    });

    test('handles long JSON payloads', () async {
      final largeJson = jsonEncode({
        'id': '1',
        'choices': List.generate(
          100,
          (i) => {'index': i, 'text': 'word' * 100},
        ),
      });

      final sseData = 'data: $largeJson\ndata: [DONE]';

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['id'], '1');
      expect((results[0]['choices'] as List).length, 100);
    });

    test('skips malformed JSON', () async {
      final sseData = [
        'data: {"valid":"json"}',
        'data: {not valid json}',
        'data: {"another":"valid"}',
        'data: [DONE]',
      ].join('\n');

      final bytes = utf8.encode(sseData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseSSE(stream).toList();

      expect(results, hasLength(2));
      expect(results[0]['valid'], 'json');
      expect(results[1]['another'], 'valid');
    });

    test('handles data split across chunks', () async {
      final controller = StreamController<List<int>>();
      final resultsFuture = parseSSE(controller.stream).toList();

      // Split a single SSE message across multiple chunks
      controller.add(utf8.encode('data: {"id":'));
      await Future<void>.delayed(Duration.zero);

      controller.add(utf8.encode('"split"}\n'));
      await Future<void>.delayed(Duration.zero);

      controller.add(utf8.encode('data: [DONE]\n'));
      await controller.close();

      final results = await resultsFuture;

      expect(results, hasLength(1));
      expect(results[0]['id'], 'split');
    });

    test('handles empty stream', () async {
      const stream = Stream<List<int>>.empty();
      final results = await parseSSE(stream).toList();

      expect(results, isEmpty);
    });
  });

  group('parseNDJSON', () {
    test('parses newline-delimited JSON', () async {
      final ndjsonData = [
        '{"id":"1","type":"event1"}',
        '{"id":"2","type":"event2"}',
        '{"id":"3","type":"event3"}',
      ].join('\n');

      final bytes = utf8.encode(ndjsonData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseNDJSON(stream).toList();

      expect(results, hasLength(3));
      expect(results[0]['id'], '1');
      expect(results[1]['id'], '2');
      expect(results[2]['id'], '3');
    });

    test('filters empty lines', () async {
      final ndjsonData = ['{"id":"1"}', '', '{"id":"2"}', ''].join('\n');

      final bytes = utf8.encode(ndjsonData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseNDJSON(stream).toList();

      expect(results, hasLength(2));
    });

    test('handles UTF-8 characters', () async {
      const ndjsonData = '{"emoji":"🚀","text":"日本語"}\n';

      final bytes = utf8.encode(ndjsonData);
      final stream = Stream<List<int>>.value(bytes);
      final results = await parseNDJSON(stream).toList();

      expect(results, hasLength(1));
      expect(results[0]['emoji'], '🚀');
      expect(results[0]['text'], '日本語');
    });
  });

  group('bytesToLines', () {
    test('converts byte stream to lines', () async {
      const text = 'line1\nline2\nline3';
      final bytes = utf8.encode(text);
      final stream = Stream<List<int>>.value(bytes);
      final lines = await bytesToLines(stream).toList();

      expect(lines, ['line1', 'line2', 'line3']);
    });

    test('handles empty stream', () async {
      const stream = Stream<List<int>>.empty();
      final lines = await bytesToLines(stream).toList();

      expect(lines, isEmpty);
    });
  });
}
