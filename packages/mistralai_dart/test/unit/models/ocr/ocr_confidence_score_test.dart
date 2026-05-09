import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrConfidenceScore', () {
    group('fromJson', () {
      test('parses required fields', () {
        final score = OcrConfidenceScore.fromJson(const {
          'confidence': 0.92,
          'start_index': 12,
          'text': 'hello world',
        });

        expect(score.confidence, 0.92);
        expect(score.startIndex, 12);
        expect(score.text, 'hello world');
      });

      test('parses confidence as integer', () {
        final score = OcrConfidenceScore.fromJson(const {
          'confidence': 1,
          'start_index': 0,
          'text': 'x',
        });

        expect(score.confidence, 1.0);
      });

      test('throws FormatException when confidence missing', () {
        expect(
          () => OcrConfidenceScore.fromJson(const {
            'start_index': 0,
            'text': 'x',
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException when start_index missing', () {
        expect(
          () => OcrConfidenceScore.fromJson(const {
            'confidence': 0.5,
            'text': 'x',
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException when text missing', () {
        expect(
          () => OcrConfidenceScore.fromJson(const {
            'confidence': 0.5,
            'start_index': 0,
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException when a required field is null', () {
        expect(
          () => OcrConfidenceScore.fromJson(const {
            'confidence': null,
            'start_index': 0,
            'text': 'x',
          }),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const score = OcrConfidenceScore(
          confidence: 0.5,
          startIndex: 4,
          text: 'foo',
        );

        expect(score.toJson(), {
          'confidence': 0.5,
          'start_index': 4,
          'text': 'foo',
        });
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = OcrConfidenceScore(
          confidence: 0.83,
          startIndex: 7,
          text: 'sample',
        );

        final roundTripped = OcrConfidenceScore.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = OcrConfidenceScore(
          confidence: 0.5,
          startIndex: 0,
          text: 'old',
        );

        final copy = original.copyWith(confidence: 0.9, text: 'new');

        expect(copy.confidence, 0.9);
        expect(copy.startIndex, 0);
        expect(copy.text, 'new');
      });

      test('preserves values when not specified', () {
        const original = OcrConfidenceScore(
          confidence: 0.5,
          startIndex: 1,
          text: 'foo',
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'x');
        const b = OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'x');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when confidence differs', () {
        const a = OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'x');
        const b = OcrConfidenceScore(confidence: 0.6, startIndex: 0, text: 'x');

        expect(a, isNot(equals(b)));
      });

      test('not equal when startIndex differs', () {
        const a = OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'x');
        const b = OcrConfidenceScore(confidence: 0.5, startIndex: 1, text: 'x');

        expect(a, isNot(equals(b)));
      });

      test('not equal when text differs', () {
        const a = OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'x');
        const b = OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'y');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      const score = OcrConfidenceScore(
        confidence: 0.42,
        startIndex: 3,
        text: 'hello',
      );

      final str = score.toString();

      expect(str, contains('OcrConfidenceScore'));
      expect(str, contains('0.42'));
      expect(str, contains('startIndex: 3'));
      expect(str, contains('chars'));
    });
  });
}
