import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BatchError', () {
    group('fromJson', () {
      test('parses full error', () {
        final json = {
          'code': 'invalid_input',
          'message': 'Missing required field',
          'count': 5,
        };

        final error = BatchError.fromJson(json);

        expect(error.code, 'invalid_input');
        expect(error.message, 'Missing required field');
        expect(error.count, 5);
      });

      test('parses partial error', () {
        final json = {'code': 'rate_limit'};

        final error = BatchError.fromJson(json);

        expect(error.code, 'rate_limit');
        expect(error.message, isNull);
        expect(error.count, isNull);
      });

      test('parses empty error', () {
        final error = BatchError.fromJson(const {});

        expect(error.code, isNull);
        expect(error.message, isNull);
        expect(error.count, isNull);
      });
    });

    group('toJson', () {
      test('serializes full error', () {
        const error = BatchError(
          code: 'validation_error',
          message: 'Invalid JSON',
          count: 3,
        );

        final json = error.toJson();

        expect(json['code'], 'validation_error');
        expect(json['message'], 'Invalid JSON');
        expect(json['count'], 3);
      });

      test('omits null fields', () {
        const error = BatchError(code: 'error_code');

        final json = error.toJson();

        expect(json.containsKey('code'), isTrue);
        expect(json.containsKey('message'), isFalse);
        expect(json.containsKey('count'), isFalse);
      });
    });

    group('equality', () {
      test('errors with same code, message, and count are equal', () {
        const error1 = BatchError(code: 'err', message: 'msg', count: 5);
        const error2 = BatchError(code: 'err', message: 'msg', count: 5);

        expect(error1, equals(error2));
      });

      test('errors with different count are not equal', () {
        const error1 = BatchError(code: 'err', message: 'msg', count: 1);
        const error2 = BatchError(code: 'err', message: 'msg', count: 5);

        expect(error1, isNot(equals(error2)));
      });

      test('errors with different code are not equal', () {
        const error1 = BatchError(code: 'err1');
        const error2 = BatchError(code: 'err2');

        expect(error1, isNot(equals(error2)));
      });
    });

    test('toString returns readable representation', () {
      const error = BatchError(code: 'invalid_input', message: 'Missing field');

      expect(error.toString(), contains('invalid_input'));
      expect(error.toString(), contains('Missing field'));
    });
  });
}
