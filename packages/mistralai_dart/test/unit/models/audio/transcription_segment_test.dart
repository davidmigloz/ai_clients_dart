import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionSegment', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const segment = TranscriptionSegment(
          id: 0,
          start: 0.0,
          end: 5.0,
          text: 'Hello world',
        );
        expect(segment.id, 0);
        expect(segment.start, 0.0);
        expect(segment.end, 5.0);
        expect(segment.text, 'Hello world');
        expect(segment.seek, isNull);
        expect(segment.tokens, isNull);
        expect(segment.temperature, isNull);
        expect(segment.avgLogprob, isNull);
        expect(segment.compressionRatio, isNull);
        expect(segment.noSpeechProb, isNull);
        expect(segment.words, isNull);
      });

      test('creates with all parameters', () {
        const segment = TranscriptionSegment(
          id: 1,
          seek: 500,
          start: 5.0,
          end: 10.0,
          text: 'This is a test segment',
          tokens: [1, 2, 3, 4, 5],
          temperature: 0.5,
          avgLogprob: -0.3,
          compressionRatio: 1.5,
          noSpeechProb: 0.01,
          words: [
            TranscriptionWord(word: 'This', start: 5.0, end: 5.2),
            TranscriptionWord(word: 'is', start: 5.2, end: 5.4),
          ],
        );
        expect(segment.id, 1);
        expect(segment.seek, 500);
        expect(segment.start, 5.0);
        expect(segment.end, 10.0);
        expect(segment.text, 'This is a test segment');
        expect(segment.tokens, [1, 2, 3, 4, 5]);
        expect(segment.temperature, 0.5);
        expect(segment.avgLogprob, -0.3);
        expect(segment.compressionRatio, 1.5);
        expect(segment.noSpeechProb, 0.01);
        expect(segment.words, hasLength(2));
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const segment = TranscriptionSegment(
          id: 0,
          start: 0.0,
          end: 5.0,
          text: 'Hello',
        );
        final json = segment.toJson();
        expect(json['id'], 0);
        expect(json['start'], 0.0);
        expect(json['end'], 5.0);
        expect(json['text'], 'Hello');
        expect(json.containsKey('seek'), isFalse);
        expect(json.containsKey('tokens'), isFalse);
        expect(json.containsKey('temperature'), isFalse);
        expect(json.containsKey('avg_logprob'), isFalse);
        expect(json.containsKey('compression_ratio'), isFalse);
        expect(json.containsKey('no_speech_prob'), isFalse);
        expect(json.containsKey('words'), isFalse);
      });

      test('serializes all fields', () {
        const segment = TranscriptionSegment(
          id: 1,
          seek: 500,
          start: 5.0,
          end: 10.0,
          text: 'Test segment',
          tokens: [1, 2, 3],
          temperature: 0.5,
          avgLogprob: -0.3,
          compressionRatio: 1.5,
          noSpeechProb: 0.01,
          words: [TranscriptionWord(word: 'Test', start: 5.0, end: 5.5)],
        );
        final json = segment.toJson();
        expect(json['id'], 1);
        expect(json['seek'], 500);
        expect(json['start'], 5.0);
        expect(json['end'], 10.0);
        expect(json['text'], 'Test segment');
        expect(json['tokens'], [1, 2, 3]);
        expect(json['temperature'], 0.5);
        expect(json['avg_logprob'], -0.3);
        expect(json['compression_ratio'], 1.5);
        expect(json['no_speech_prob'], 0.01);
        expect(json['words'], isList);
        expect((json['words'] as List<dynamic>).length, 1);
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{
          'id': 2,
          'start': 10.0,
          'end': 15.0,
          'text': 'From JSON',
        };
        final segment = TranscriptionSegment.fromJson(json);
        expect(segment.id, 2);
        expect(segment.start, 10.0);
        expect(segment.end, 15.0);
        expect(segment.text, 'From JSON');
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'id': 3,
          'seek': 1000,
          'start': 15.0,
          'end': 20.0,
          'text': 'Full segment',
          'tokens': [10, 20, 30],
          'temperature': 0.7,
          'avg_logprob': -0.5,
          'compression_ratio': 1.2,
          'no_speech_prob': 0.05,
          'words': [
            {'word': 'Full', 'start': 15.0, 'end': 15.5},
            {'word': 'segment', 'start': 15.5, 'end': 16.0},
          ],
        };
        final segment = TranscriptionSegment.fromJson(json);
        expect(segment.id, 3);
        expect(segment.seek, 1000);
        expect(segment.start, 15.0);
        expect(segment.end, 20.0);
        expect(segment.text, 'Full segment');
        expect(segment.tokens, [10, 20, 30]);
        expect(segment.temperature, 0.7);
        expect(segment.avgLogprob, -0.5);
        expect(segment.compressionRatio, 1.2);
        expect(segment.noSpeechProb, 0.05);
        expect(segment.words, hasLength(2));
        expect(segment.words!.first.word, 'Full');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'id': 4,
          'start': 20.0,
          'end': 25.0,
          'text': 'Minimal',
        };
        final segment = TranscriptionSegment.fromJson(json);
        expect(segment.seek, isNull);
        expect(segment.tokens, isNull);
        expect(segment.temperature, isNull);
        expect(segment.avgLogprob, isNull);
        expect(segment.compressionRatio, isNull);
        expect(segment.noSpeechProb, isNull);
        expect(segment.words, isNull);
      });

      test('handles integer times', () {
        final json = <String, dynamic>{
          'id': 5,
          'start': 30,
          'end': 35,
          'text': 'Integer times',
        };
        final segment = TranscriptionSegment.fromJson(json);
        expect(segment.start, 30.0);
        expect(segment.end, 35.0);
      });

      test('handles missing required fields with defaults', () {
        final json = <String, dynamic>{};
        final segment = TranscriptionSegment.fromJson(json);
        expect(segment.id, 0);
        expect(segment.start, 0.0);
        expect(segment.end, 0.0);
        expect(segment.text, '');
      });
    });

    group('duration', () {
      test('calculates correct duration', () {
        const segment = TranscriptionSegment(
          id: 0,
          start: 5.0,
          end: 12.5,
          text: 'Duration test',
        );
        expect(segment.duration, 7.5);
      });

      test('handles zero duration', () {
        const segment = TranscriptionSegment(
          id: 0,
          start: 10.0,
          end: 10.0,
          text: 'Zero duration',
        );
        expect(segment.duration, 0.0);
      });
    });

    group('equality', () {
      test('equals with same id', () {
        const segment1 = TranscriptionSegment(
          id: 5,
          start: 0.0,
          end: 5.0,
          text: 'Segment A',
        );
        const segment2 = TranscriptionSegment(
          id: 5,
          start: 0.0,
          end: 5.0,
          text: 'Segment A',
        );
        expect(segment1, equals(segment2));
        expect(segment1.hashCode, segment2.hashCode);
      });

      test('not equals with different id', () {
        const segment1 = TranscriptionSegment(
          id: 5,
          start: 0.0,
          end: 5.0,
          text: 'Same text',
        );
        const segment2 = TranscriptionSegment(
          id: 6,
          start: 0.0,
          end: 5.0,
          text: 'Same text',
        );
        expect(segment1, isNot(equals(segment2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const segment = TranscriptionSegment(
          id: 1,
          start: 0.0,
          end: 5.0,
          text: 'Hello world',
        );
        expect(
          segment.toString(),
          'TranscriptionSegment(id: 1, text: 11 chars)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = TranscriptionSegment(
          id: 10,
          seek: 2000,
          start: 40.0,
          end: 45.0,
          text: 'Round-trip test',
          tokens: [100, 200, 300],
          temperature: 0.6,
          avgLogprob: -0.4,
          compressionRatio: 1.3,
          noSpeechProb: 0.02,
          words: [
            TranscriptionWord(word: 'Round-trip', start: 40.0, end: 41.0),
            TranscriptionWord(word: 'test', start: 41.0, end: 42.0),
          ],
        );
        final json = original.toJson();
        final restored = TranscriptionSegment.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.seek, original.seek);
        expect(restored.start, original.start);
        expect(restored.end, original.end);
        expect(restored.text, original.text);
        expect(restored.tokens, original.tokens);
        expect(restored.temperature, original.temperature);
        expect(restored.avgLogprob, original.avgLogprob);
        expect(restored.compressionRatio, original.compressionRatio);
        expect(restored.noSpeechProb, original.noSpeechProb);
        expect(restored.words?.length, original.words?.length);
      });
    });
  });
}
