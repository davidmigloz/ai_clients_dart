import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StreamError', () {
    test('fromJson parses fields', () {
      final error = StreamError.fromJson(const {
        'error': 'internal',
        'reason': 'boom',
      });

      expect(error.error, 'internal');
      expect(error.reason, 'boom');
    });

    test('toJson round-trips', () {
      const error = StreamError(error: 'internal', reason: 'boom');

      expect(error.toJson(), {'error': 'internal', 'reason': 'boom'});
      expect(StreamError.fromJson(error.toJson()), equals(error));
    });

    test('copyWith replaces values', () {
      const error = StreamError(error: 'internal', reason: 'boom');

      expect(error.copyWith(reason: 'other').reason, 'other');
      expect(error.copyWith().error, 'internal');
    });

    test('equality and hashCode', () {
      const a = StreamError(error: 'internal', reason: 'boom');
      const b = StreamError(error: 'internal', reason: 'boom');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains fields', () {
      const error = StreamError(error: 'internal', reason: 'boom');

      expect(error.toString(), contains('error: internal'));
      expect(error.toString(), contains('reason: boom'));
    });
  });
}
