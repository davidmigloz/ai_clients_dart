import 'dart:convert';

import 'package:ollama_dart/src/utils/streaming_parser.dart';
import 'package:test/test.dart';

void main() {
  group('parseNDJSON', () {
    test('parses valid NDJSON lines', () async {
      final bytes = utf8.encode('{"id":1}\n{"id":2}\n');
      final stream = Stream<List<int>>.value(bytes);

      final results = await parseNDJSON(stream).toList();
      expect(results, hasLength(2));
      expect(results[0]['id'], 1);
      expect(results[1]['id'], 2);
    });

    test('skips empty lines', () async {
      final bytes = utf8.encode('{"id":1}\n\n{"id":2}\n');
      final stream = Stream<List<int>>.value(bytes);

      final results = await parseNDJSON(stream).toList();
      expect(results, hasLength(2));
    });

    test('skips malformed JSON gracefully', () async {
      final bytes = utf8.encode('{"id":1}\n{invalid}\n{"id":2}\n');
      final stream = Stream<List<int>>.value(bytes);

      final results = await parseNDJSON(stream).toList();
      expect(results, hasLength(2));
      expect(results[0]['id'], 1);
      expect(results[1]['id'], 2);
    });

    test('handles empty stream', () async {
      const stream = Stream<List<int>>.empty();
      final results = await parseNDJSON(stream).toList();
      expect(results, isEmpty);
    });
  });

  group('parseNDJSONAs', () {
    test('converts parsed JSON to typed objects', () async {
      final bytes = utf8.encode('{"name":"a"}\n{"name":"b"}\n');
      final stream = Stream<List<int>>.value(bytes);

      final results = await parseNDJSONAs<String>(
        stream,
        (json) => json['name'] as String,
      ).toList();

      expect(results, ['a', 'b']);
    });

    test('skips malformed JSON gracefully', () async {
      final bytes = utf8.encode('{"name":"a"}\n{bad}\n{"name":"b"}\n');
      final stream = Stream<List<int>>.value(bytes);

      final results = await parseNDJSONAs<String>(
        stream,
        (json) => json['name'] as String,
      ).toList();

      expect(results, ['a', 'b']);
    });
  });
}
