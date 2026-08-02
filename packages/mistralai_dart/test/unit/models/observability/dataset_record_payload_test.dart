@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DatasetRecordPayload model', () {
    test('round-trips arbitrary keys through JSON', () {
      final json = {
        'foo': 'bar',
        'nested': {'a': 1},
        'list': [1, 2, 3],
      };
      final payload = DatasetRecordPayload.fromJson(json);
      expect(payload.data, json);
      expect(payload.toJson(), json);
    });

    test('does not expose a messages field', () {
      final payload = DatasetRecordPayload.fromJson(const {'anything': 'goes'});
      expect(payload.data.containsKey('messages'), isFalse);
    });

    test('handles an empty payload', () {
      final payload = DatasetRecordPayload.fromJson(const {});
      expect(payload.data, isEmpty);
      expect(payload.toJson(), isEmpty);
    });

    test('equality and hashCode are value-based', () {
      final a = DatasetRecordPayload(const {'key': 'value'});
      final b = DatasetRecordPayload(const {'key': 'value'});
      final c = DatasetRecordPayload(const {'key': 'other'});

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
