import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrConfidenceScore', () {
    group('fromJson', () {
      test('parses all required fields', () {
        final json = {'confidence': 0.95, 'start_index': 10, 'text': 'hello'};

        final score = OcrConfidenceScore.fromJson(json);

        expect(score.confidence, 0.95);
        expect(score.startIndex, 10);
        expect(score.text, 'hello');
      });

      test('handles integer confidence as double', () {
        final json = {'confidence': 1, 'start_index': 0, 'text': 'word'};

        final score = OcrConfidenceScore.fromJson(json);

        expect(score.confidence, 1.0);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const score = OcrConfidenceScore(
          confidence: 0.87,
          startIndex: 5,
          text: 'world',
        );

        final json = score.toJson();

        expect(json['confidence'], 0.87);
        expect(json['start_index'], 5);
        expect(json['text'], 'world');
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = OcrConfidenceScore(
          confidence: 0.99,
          startIndex: 42,
          text: 'test',
        );

        final roundTripped = OcrConfidenceScore.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = OcrConfidenceScore(
          confidence: 0.9,
          startIndex: 0,
          text: 'original',
        );

        final copy = original.copyWith(text: 'modified', confidence: 0.5);

        expect(copy.confidence, 0.5);
        expect(copy.startIndex, 0);
        expect(copy.text, 'modified');
      });

      test('preserves values when not specified', () {
        const original = OcrConfidenceScore(
          confidence: 0.8,
          startIndex: 3,
          text: 'keep',
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = OcrConfidenceScore(
          confidence: 0.95,
          startIndex: 10,
          text: 'word',
        );
        const b = OcrConfidenceScore(
          confidence: 0.95,
          startIndex: 10,
          text: 'word',
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when fields differ', () {
        const a = OcrConfidenceScore(
          confidence: 0.95,
          startIndex: 10,
          text: 'word',
        );
        const b = OcrConfidenceScore(
          confidence: 0.80,
          startIndex: 10,
          text: 'word',
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes all fields', () {
      const score = OcrConfidenceScore(
        confidence: 0.95,
        startIndex: 10,
        text: 'hello',
      );

      final str = score.toString();

      expect(str, contains('0.95'));
      expect(str, contains('10'));
      expect(str, contains('hello'));
    });
  });
}
