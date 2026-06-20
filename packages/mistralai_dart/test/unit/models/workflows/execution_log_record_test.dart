import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ExecutionLogRecord', () {
    Map<String, dynamic> recordJson() => {
      'timestamp': '2030-01-01T00:00:00Z',
      'trace_id': 'trace-1',
      'span_id': 'span-1',
      'severity_text': 'INFO',
      'body': 'hello',
      'log_attributes': {'k': 'v'},
    };

    test('fromJson parses all fields', () {
      final record = ExecutionLogRecord.fromJson(recordJson());

      expect(record.timestamp, '2030-01-01T00:00:00Z');
      expect(record.traceId, 'trace-1');
      expect(record.spanId, 'span-1');
      expect(record.severityText, 'INFO');
      expect(record.body, 'hello');
      expect(record.logAttributes, {'k': 'v'});
    });

    test('toJson round-trips', () {
      final record = ExecutionLogRecord.fromJson(recordJson());

      expect(record.toJson(), recordJson());
      expect(ExecutionLogRecord.fromJson(record.toJson()), equals(record));
    });

    test('copyWith replaces values', () {
      final record = ExecutionLogRecord.fromJson(recordJson());

      expect(record.copyWith(body: 'bye').body, 'bye');
      expect(record.copyWith().body, 'hello');
    });

    test('equality and hashCode', () {
      final a = ExecutionLogRecord.fromJson(recordJson());
      final b = ExecutionLogRecord.fromJson(recordJson());

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains fields', () {
      final record = ExecutionLogRecord.fromJson(recordJson());

      expect(record.toString(), contains('traceId: trace-1'));
      expect(record.toString(), contains('logAttributes: 1'));
    });
  });
}
