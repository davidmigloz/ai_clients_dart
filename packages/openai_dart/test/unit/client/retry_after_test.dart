import 'package:openai_dart/src/client/retry_after.dart';
import 'package:test/test.dart';

void main() {
  group('parseRetryAfter numeric guidance (RETRY-05/06)', () {
    final seconds = <String, int>{
      '0': 0,
      '-0.0': 0,
      '+0': 0,
      '  1  ': 1000000,
      '1.25': 1250000,
      '.5': 500000,
      '1.': 1000000,
      '1e-3': 1000,
      '+1.25E+1': 12500000,
      '0.000001': 1,
      '0.0000001': 1,
      '0.0000010000000000000001': 2,
      '1.0000000000000000000001': 1000001,
      '1e-999999999999999999999': 1,
      '0e999999999999999999999': 0,
      '9007199254.740991': 9007199254740991,
      '9007199254.740991000000': 9007199254740991,
      '9.007199254740991e9': 9007199254740991,
    };
    for (final entry in seconds.entries) {
      test('seconds ${entry.key} rounds upward exactly', () {
        expect(
          parseRetryAfter({'retry-after': entry.key}),
          Duration(microseconds: entry.value),
        );
      });
    }
    final milliseconds = <String, int>{
      '0': 0,
      '1.25': 1250,
      '0.0001': 1,
      '1.000000000000000000001': 1001,
      '1e-3': 1,
      '9007199254740.991': 9007199254740991,
    };
    for (final entry in milliseconds.entries) {
      test('milliseconds ${entry.key} takes precedence', () {
        expect(
          parseRetryAfter({'retry-after-ms': entry.key, 'retry-after': '7'}),
          Duration(microseconds: entry.value),
        );
      });
    }
    for (final invalid in [
      '',
      '  ',
      '-1',
      '-0.000000000000000000001',
      'NaN',
      'Infinity',
      '-Infinity',
      'nonsense',
      '1,2',
      '1e999999999999999999999',
      '9007199254740.991000001',
      '9007199254741',
    ]) {
      test('invalid milliseconds $invalid falls back to seconds', () {
        expect(
          parseRetryAfter({'retry-after-ms': invalid, 'retry-after': '1.5'}),
          const Duration(milliseconds: 1500),
        );
      });
    }
    for (final invalid in [
      '',
      '  ',
      '-1',
      '-0.00000001',
      'NaN',
      'Infinity',
      '-Infinity',
      'not a date',
      '1,2',
      '1e999999999999999999999',
      '9007199254.740991000001',
      '9007199255',
    ]) {
      test('invalid seconds $invalid is ignored', () {
        expect(parseRetryAfter({'retry-after': invalid}), isNull);
      });
    }
    test('headers are case insensitive without mutating the input', () {
      const headers = {'Retry-After-Ms': '1.25', 'RETRY-AFTER': '8'};
      expect(parseRetryAfter(headers), const Duration(microseconds: 1250));
      expect(headers, {'Retry-After-Ms': '1.25', 'RETRY-AFTER': '8'});
      expect(
        parseRetryAfter(const {'Retry-After': '.25'}),
        const Duration(milliseconds: 250),
      );
    });
    test('missing headers do not create a delay', () {
      expect(parseRetryAfter(const {}), isNull);
    });
  });

  group('parseRetryAfter HTTP dates (RETRY-05)', () {
    final now = DateTime.utc(2015, 10, 21, 7, 28);
    const date = 'Wed, 21 Oct 2015 07:28:00 GMT';
    test('future HTTP date preserves microsecond difference', () {
      expect(
        parseRetryAfter({
          'retry-after': date,
        }, now: now.subtract(const Duration(microseconds: 1250001))),
        const Duration(microseconds: 1250001),
      );
    });
    test('present and past dates permit zero', () {
      expect(parseRetryAfter({'retry-after': date}, now: now), Duration.zero);
      expect(
        parseRetryAfter({
          'retry-after': date,
        }, now: now.add(const Duration(days: 1))),
        Duration.zero,
      );
    });
    test('invalid milliseconds fall back to HTTP date', () {
      expect(
        parseRetryAfter({
          'retry-after-ms': 'NaN',
          'retry-after': date,
        }, now: now.subtract(const Duration(seconds: 2))),
        const Duration(seconds: 2),
      );
    });
    test('unrepresentable future dates are ignored', () {
      expect(
        parseRetryAfter({
          'retry-after': 'Fri, 31 Dec 9999 23:59:59 GMT',
        }, now: now),
        isNull,
      );
    });
  });
}
