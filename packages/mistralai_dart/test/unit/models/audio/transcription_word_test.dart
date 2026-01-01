import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionWord', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const word = TranscriptionWord(word: 'hello', start: 0.0, end: 0.5);
        expect(word.word, 'hello');
        expect(word.start, 0.0);
        expect(word.end, 0.5);
      });

      test('creates with fractional times', () {
        const word = TranscriptionWord(word: 'world', start: 1.234, end: 1.789);
        expect(word.word, 'world');
        expect(word.start, 1.234);
        expect(word.end, 1.789);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const word = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        final json = word.toJson();
        expect(json['word'], 'hello');
        expect(json['start'], 0.5);
        expect(json['end'], 1.0);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'word': 'goodbye',
          'start': 2.5,
          'end': 3.0,
        };
        final word = TranscriptionWord.fromJson(json);
        expect(word.word, 'goodbye');
        expect(word.start, 2.5);
        expect(word.end, 3.0);
      });

      test('handles integer times', () {
        final json = <String, dynamic>{'word': 'test', 'start': 1, 'end': 2};
        final word = TranscriptionWord.fromJson(json);
        expect(word.start, 1.0);
        expect(word.end, 2.0);
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final word = TranscriptionWord.fromJson(json);
        expect(word.word, '');
        expect(word.start, 0.0);
        expect(word.end, 0.0);
      });

      test('handles null values with defaults', () {
        final json = <String, dynamic>{
          'word': null,
          'start': null,
          'end': null,
        };
        final word = TranscriptionWord.fromJson(json);
        expect(word.word, '');
        expect(word.start, 0.0);
        expect(word.end, 0.0);
      });
    });

    group('duration', () {
      test('calculates correct duration', () {
        const word = TranscriptionWord(word: 'testing', start: 1.5, end: 2.25);
        expect(word.duration, 0.75);
      });

      test('handles zero duration', () {
        const word = TranscriptionWord(word: 'instant', start: 1.0, end: 1.0);
        expect(word.duration, 0.0);
      });

      test('handles very short duration', () {
        const word = TranscriptionWord(word: 'quick', start: 0.0, end: 0.001);
        expect(word.duration, closeTo(0.001, 0.0001));
      });
    });

    group('equality', () {
      test('equals with same values', () {
        const word1 = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        const word2 = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        expect(word1, equals(word2));
        expect(word1.hashCode, word2.hashCode);
      });

      test('not equals with different word', () {
        const word1 = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        const word2 = TranscriptionWord(word: 'world', start: 0.5, end: 1.0);
        expect(word1, isNot(equals(word2)));
      });

      test('not equals with different start', () {
        const word1 = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        const word2 = TranscriptionWord(word: 'hello', start: 0.6, end: 1.0);
        expect(word1, isNot(equals(word2)));
      });

      test('not equals with different end', () {
        const word1 = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        const word2 = TranscriptionWord(word: 'hello', start: 0.5, end: 1.1);
        expect(word1, isNot(equals(word2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const word = TranscriptionWord(word: 'hello', start: 0.5, end: 1.0);
        expect(
          word.toString(),
          'TranscriptionWord(word: hello, start: 0.5, end: 1.0)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = TranscriptionWord(
          word: 'roundtrip',
          start: 5.678,
          end: 6.123,
        );
        final json = original.toJson();
        final restored = TranscriptionWord.fromJson(json);
        expect(restored.word, original.word);
        expect(restored.start, original.start);
        expect(restored.end, original.end);
        expect(restored, equals(original));
      });
    });
  });
}
