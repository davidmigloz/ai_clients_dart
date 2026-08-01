import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DreamError', () {
    test('fromJson/toJson round-trip', () {
      const json = {'type': 'internal_error', 'message': 'boom'};
      final error = DreamError.fromJson(json);
      expect(error.type, 'internal_error');
      expect(error.message, 'boom');
      expect(error.toJson(), json);
    });

    test('copyWith replaces values', () {
      const error = DreamError(type: 'a', message: 'b');
      final updated = error.copyWith(message: 'c');
      expect(updated.type, 'a');
      expect(updated.message, 'c');
    });

    test('equality and hashCode', () {
      const a = DreamError(type: 'a', message: 'b');
      const b = DreamError(type: 'a', message: 'b');
      const c = DreamError(type: 'a', message: 'different');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes all fields', () {
      const error = DreamError(type: 'a', message: 'b');
      expect(error.toString(), contains('type: a'));
      expect(error.toString(), contains('message: b'));
    });
  });
}
