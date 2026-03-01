import 'package:mistralai_dart/src/platform/http_utils.dart';
import 'package:test/test.dart';

void main() {
  group('parseHttpDate', () {
    group('RFC 1123 format', () {
      test('parses valid date', () {
        final result = parseHttpDate('Wed, 21 Oct 2015 07:28:00 GMT');

        expect(result.year, 2015);
        expect(result.month, 10);
        expect(result.day, 21);
        expect(result.hour, 7);
        expect(result.minute, 28);
        expect(result.second, 0);
        expect(result.isUtc, isTrue);
      });

      test('parses date with single-digit day', () {
        final result = parseHttpDate('Mon, 5 Jan 2024 10:30:45 GMT');

        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 5);
        expect(result.hour, 10);
        expect(result.minute, 30);
        expect(result.second, 45);
      });

      test('parses all months correctly', () {
        final months = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };

        for (final entry in months.entries) {
          final result = parseHttpDate(
            'Mon, 15 ${entry.key} 2024 00:00:00 GMT',
          );
          expect(
            result.month,
            entry.value,
            reason: '${entry.key} should be month ${entry.value}',
          );
        }
      });

      test('parses midnight correctly', () {
        final result = parseHttpDate('Tue, 01 Jan 2024 00:00:00 GMT');

        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
      });

      test('parses end of day correctly', () {
        final result = parseHttpDate('Tue, 31 Dec 2024 23:59:59 GMT');

        expect(result.hour, 23);
        expect(result.minute, 59);
        expect(result.second, 59);
      });
    });

    group('error handling', () {
      // Note: On IO platforms, HttpDate.parse throws HttpException.
      // On web platforms, our implementation throws FormatException.
      // Both are Exceptions, so we test for that common base.

      test('throws exception for empty string', () {
        expect(() => parseHttpDate(''), throwsException);
      });

      test('throws exception for invalid format', () {
        expect(() => parseHttpDate('not a date'), throwsException);
      });

      test('throws exception for invalid month', () {
        expect(
          () => parseHttpDate('Mon, 15 Xyz 2024 00:00:00 GMT'),
          throwsException,
        );
      });

      test('throws exception for missing parts', () {
        expect(() => parseHttpDate('Mon, 15 Jan 2024'), throwsException);
      });
    });
  });

  group('isSocketException', () {
    test('returns false for non-socket exceptions', () {
      expect(isSocketException(const FormatException('test')), isFalse);
      expect(isSocketException(ArgumentError('test')), isFalse);
      expect(isSocketException('string error'), isFalse);
      expect(isSocketException(42), isFalse);
    });

    // Note: On IO platforms, isSocketException returns true for SocketException.
    // On web platforms, it always returns false.
    // This test verifies at minimum the non-socket case works consistently.
  });
}
