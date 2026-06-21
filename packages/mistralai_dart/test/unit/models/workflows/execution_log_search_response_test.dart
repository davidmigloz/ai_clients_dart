import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ExecutionLogSearchResponse', () {
    Map<String, dynamic> recordJson() => {
      'timestamp': '2030-01-01T00:00:00Z',
      'trace_id': 'trace-1',
      'span_id': 'span-1',
      'severity_text': 'INFO',
      'body': 'hello',
      'log_attributes': {'k': 'v'},
    };

    test('fromJson parses results and next_cursor', () {
      final response = ExecutionLogSearchResponse.fromJson({
        'results': [recordJson()],
        'next_cursor': 'cursor-1',
      });

      expect(response.results, hasLength(1));
      expect(response.results.first.traceId, 'trace-1');
      expect(response.nextCursor, 'cursor-1');
    });

    test('fromJson handles missing next_cursor', () {
      final response = ExecutionLogSearchResponse.fromJson({
        'results': [recordJson()],
      });

      expect(response.nextCursor, isNull);
    });

    test('toJson round-trips', () {
      final response = ExecutionLogSearchResponse(
        results: [ExecutionLogRecord.fromJson(recordJson())],
        nextCursor: 'cursor-1',
      );

      expect(
        ExecutionLogSearchResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('toJson omits null next_cursor', () {
      final response = ExecutionLogSearchResponse(results: const []);

      expect(response.toJson().containsKey('next_cursor'), isFalse);
    });

    test('copyWith clears next_cursor', () {
      final response = ExecutionLogSearchResponse(
        results: const [],
        nextCursor: 'cursor-1',
      );

      expect(response.copyWith(nextCursor: null).nextCursor, isNull);
      expect(response.copyWith().nextCursor, 'cursor-1');
    });

    test('equality and hashCode', () {
      final a = ExecutionLogSearchResponse(
        results: [ExecutionLogRecord.fromJson(recordJson())],
        nextCursor: 'c',
      );
      final b = ExecutionLogSearchResponse(
        results: [ExecutionLogRecord.fromJson(recordJson())],
        nextCursor: 'c',
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains counts', () {
      final response = ExecutionLogSearchResponse(
        results: const [],
        nextCursor: 'c',
      );

      expect(response.toString(), contains('results: 0'));
      expect(response.toString(), contains('nextCursor: c'));
    });
  });
}
