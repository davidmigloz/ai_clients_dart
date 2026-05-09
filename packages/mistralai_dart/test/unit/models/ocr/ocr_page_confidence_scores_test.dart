import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrPageConfidenceScores', () {
    group('fromJson', () {
      test('parses required aggregate scores', () {
        final scores = OcrPageConfidenceScores.fromJson(const {
          'average_page_confidence_score': 0.91,
          'minimum_page_confidence_score': 0.42,
        });

        expect(scores.averagePageConfidenceScore, 0.91);
        expect(scores.minimumPageConfidenceScore, 0.42);
        expect(scores.wordConfidenceScores, isNull);
      });

      test('parses word_confidence_scores when present', () {
        final scores = OcrPageConfidenceScores.fromJson(const {
          'average_page_confidence_score': 0.8,
          'minimum_page_confidence_score': 0.5,
          'word_confidence_scores': [
            {'confidence': 0.95, 'start_index': 0, 'text': 'foo'},
            {'confidence': 0.6, 'start_index': 4, 'text': 'bar'},
          ],
        });

        expect(scores.wordConfidenceScores, hasLength(2));
        expect(scores.wordConfidenceScores![0].confidence, 0.95);
        expect(scores.wordConfidenceScores![0].text, 'foo');
        expect(scores.wordConfidenceScores![1].startIndex, 4);
      });

      test('throws FormatException when average missing', () {
        expect(
          () => OcrPageConfidenceScores.fromJson(const {
            'minimum_page_confidence_score': 0.5,
          }),
          throwsFormatException,
        );
      });

      test('throws FormatException when minimum missing', () {
        expect(
          () => OcrPageConfidenceScores.fromJson(const {
            'average_page_confidence_score': 0.5,
          }),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('omits word_confidence_scores when null', () {
        const scores = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.8,
          minimumPageConfidenceScore: 0.4,
        );

        final json = scores.toJson();

        expect(json['average_page_confidence_score'], 0.8);
        expect(json['minimum_page_confidence_score'], 0.4);
        expect(json.containsKey('word_confidence_scores'), isFalse);
      });

      test('serializes word_confidence_scores when set', () {
        const scores = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.8,
          minimumPageConfidenceScore: 0.4,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'a'),
          ],
        );

        final json = scores.toJson();

        expect(json['word_confidence_scores'], hasLength(1));
        final entry =
            (json['word_confidence_scores'] as List).first
                as Map<String, dynamic>;
        expect(entry['confidence'], 0.5);
        expect(entry['start_index'], 0);
        expect(entry['text'], 'a');
      });
    });

    group('round-trip', () {
      test('with nested word_confidence_scores', () {
        const original = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.77,
          minimumPageConfidenceScore: 0.21,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'lorem'),
            OcrConfidenceScore(confidence: 0.3, startIndex: 6, text: 'ipsum'),
          ],
        );

        final roundTripped = OcrPageConfidenceScores.fromJson(
          original.toJson(),
        );

        expect(roundTripped, equals(original));
        expect(
          roundTripped.wordConfidenceScores,
          equals(original.wordConfidenceScores),
        );
      });
    });

    group('copyWith', () {
      test('clears wordConfidenceScores when explicitly null', () {
        const original = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.8,
          minimumPageConfidenceScore: 0.4,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'a'),
          ],
        );

        final copy = original.copyWith(wordConfidenceScores: null);

        expect(copy.wordConfidenceScores, isNull);
        expect(copy.averagePageConfidenceScore, 0.8);
      });

      test('preserves wordConfidenceScores when not specified', () {
        const original = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.8,
          minimumPageConfidenceScore: 0.4,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'a'),
          ],
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('equal when nested word lists match element-wise', () {
        const a = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.8,
          minimumPageConfidenceScore: 0.4,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'foo'),
          ],
        );
        const b = OcrPageConfidenceScores(
          averagePageConfidenceScore: 0.8,
          minimumPageConfidenceScore: 0.4,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'foo'),
          ],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test(
        'not equal when nested entry text differs (full-fidelity check)',
        () {
          const a = OcrPageConfidenceScores(
            averagePageConfidenceScore: 0.8,
            minimumPageConfidenceScore: 0.4,
            wordConfidenceScores: [
              OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'foo'),
            ],
          );
          const b = OcrPageConfidenceScores(
            averagePageConfidenceScore: 0.8,
            minimumPageConfidenceScore: 0.4,
            wordConfidenceScores: [
              OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'bar'),
            ],
          );

          expect(a, isNot(equals(b)));
        },
      );
    });
  });
}
