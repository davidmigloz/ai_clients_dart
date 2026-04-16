import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrPageConfidenceScores', () {
    group('fromJson', () {
      test('parses required fields', () {
        final json = {
          'average_page_confidence_score': 0.92,
          'minimum_page_confidence_score': 0.75,
        };

        final scores = OcrPageConfidenceScores.fromJson(json);

        expect(scores.averagePageConfidenceScore, 0.92);
        expect(scores.minimumPageConfidenceScore, 0.75);
        expect(scores.wordConfidenceScores, isNull);
      });

      test('parses with word confidence scores', () {
        final json = {
          'average_page_confidence_score': 0.90,
          'minimum_page_confidence_score': 0.60,
          'word_confidence_scores': [
            {'confidence': 0.95, 'start_index': 0, 'text': 'Hello'},
            {'confidence': 0.60, 'start_index': 6, 'text': 'world'},
          ],
        };

        final scores = OcrPageConfidenceScores.fromJson(json);

        expect(scores.wordConfidenceScores, hasLength(2));
        expect(scores.wordConfidenceScores![0].text, 'Hello');
        expect(scores.wordConfidenceScores![1].confidence, 0.60);
      });

      test('handles null word_confidence_scores', () {
        final json = {
          'average_page_confidence_score': 0.85,
          'minimum_page_confidence_score': 0.70,
          'word_confidence_scores': null,
        };

        final scores = OcrPageConfidenceScores.fromJson(json);

        expect(scores.wordConfidenceScores, isNull);
      });
    });

    group('toJson', () {
      test('serializes without word scores', () {
        const scores = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.92,
          minimumPageConfidenceScore: 0.75,
        );

        final json = scores.toJson();

        expect(json['average_page_confidence_score'], 0.92);
        expect(json['minimum_page_confidence_score'], 0.75);
        expect(json.containsKey('word_confidence_scores'), isFalse);
      });

      test('serializes with word scores', () {
        const scores = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.60,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.95, startIndex: 0, text: 'Hi'),
          ],
        );

        final json = scores.toJson();

        expect(json['word_confidence_scores'], hasLength(1));
        final wordScore =
            (json['word_confidence_scores'] as List).first
                as Map<String, dynamic>;
        expect(wordScore['text'], 'Hi');
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.88,
          minimumPageConfidenceScore: 0.55,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'test'),
          ],
        );

        final roundTripped = OcrPageConfidenceScores.fromJson(
          original.toJson(),
        );

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
        );

        final copy = original.copyWith(averagePageConfidenceScore: 0.95);

        expect(copy.averagePageConfidenceScore, 0.95);
        expect(copy.minimumPageConfidenceScore, 0.70);
      });

      test('preserves values when not specified', () {
        const original = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'a'),
          ],
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
        );
        const b = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('equal with same word scores', () {
        const a = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'hi'),
          ],
        );
        const b = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'hi'),
          ],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when fields differ', () {
        const a = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.90,
          minimumPageConfidenceScore: 0.70,
        );
        const b = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.80,
          minimumPageConfidenceScore: 0.70,
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      const scores = OcrPageConfidenceScores(
        averagePageConfidenceScore: 0.92,
        minimumPageConfidenceScore: 0.75,
        wordConfidenceScores: [
          OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'a'),
          OcrConfidenceScore(confidence: 0.8, startIndex: 2, text: 'b'),
        ],
      );

      final str = scores.toString();

      expect(str, contains('0.92'));
      expect(str, contains('0.75'));
      expect(str, contains('2 items'));
    });
  });
}
