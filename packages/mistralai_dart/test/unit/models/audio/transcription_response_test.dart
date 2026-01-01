import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionResponse', () {
    group('constructor', () {
      test('creates with required text parameter', () {
        const response = TranscriptionResponse(text: 'Hello world');
        expect(response.text, 'Hello world');
        expect(response.object, 'transcription');
        expect(response.id, isNull);
        expect(response.language, isNull);
        expect(response.duration, isNull);
        expect(response.segments, isNull);
        expect(response.words, isNull);
        expect(response.usage, isNull);
      });

      test('creates with all parameters', () {
        const response = TranscriptionResponse(
          id: 'trans-123',
          object: 'transcription',
          text: 'Hello world, this is a test.',
          language: 'en',
          duration: 5.5,
          segments: [
            TranscriptionSegment(
              id: 0,
              start: 0.0,
              end: 5.5,
              text: 'Hello world, this is a test.',
            ),
          ],
          words: [
            TranscriptionWord(word: 'Hello', start: 0.0, end: 0.5),
            TranscriptionWord(word: 'world', start: 0.5, end: 1.0),
          ],
          usage: UsageInfo(
            promptTokens: 10,
            completionTokens: 50,
            totalTokens: 60,
          ),
        );
        expect(response.id, 'trans-123');
        expect(response.object, 'transcription');
        expect(response.text, 'Hello world, this is a test.');
        expect(response.language, 'en');
        expect(response.duration, 5.5);
        expect(response.segments, hasLength(1));
        expect(response.words, hasLength(2));
        expect(response.usage?.totalTokens, 60);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const response = TranscriptionResponse(text: 'Simple text');
        final json = response.toJson();
        expect(json['text'], 'Simple text');
        expect(json['object'], 'transcription');
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('language'), isFalse);
        expect(json.containsKey('duration'), isFalse);
        expect(json.containsKey('segments'), isFalse);
        expect(json.containsKey('words'), isFalse);
        expect(json.containsKey('usage'), isFalse);
      });

      test('serializes all fields', () {
        const response = TranscriptionResponse(
          id: 'trans-456',
          object: 'transcription',
          text: 'Full response',
          language: 'fr',
          duration: 10.0,
          segments: [
            TranscriptionSegment(
              id: 0,
              start: 0.0,
              end: 10.0,
              text: 'Full response',
            ),
          ],
          words: [
            TranscriptionWord(word: 'Full', start: 0.0, end: 0.5),
            TranscriptionWord(word: 'response', start: 0.5, end: 1.2),
          ],
          usage: UsageInfo(
            promptTokens: 5,
            completionTokens: 20,
            totalTokens: 25,
          ),
        );
        final json = response.toJson();
        expect(json['id'], 'trans-456');
        expect(json['object'], 'transcription');
        expect(json['text'], 'Full response');
        expect(json['language'], 'fr');
        expect(json['duration'], 10.0);
        expect(json['segments'], isList);
        expect((json['segments'] as List<dynamic>).length, 1);
        expect(json['words'], isList);
        expect((json['words'] as List<dynamic>).length, 2);
        expect(json['usage'], isMap);
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{'text': 'From JSON text'};
        final response = TranscriptionResponse.fromJson(json);
        expect(response.text, 'From JSON text');
        expect(response.object, 'transcription');
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'id': 'trans-789',
          'object': 'transcription',
          'text': 'Complete transcription',
          'language': 'de',
          'duration': 15.5,
          'segments': [
            {
              'id': 0,
              'start': 0.0,
              'end': 15.5,
              'text': 'Complete transcription',
            },
          ],
          'words': [
            {'word': 'Complete', 'start': 0.0, 'end': 0.8},
            {'word': 'transcription', 'start': 0.8, 'end': 1.5},
          ],
          'usage': {
            'prompt_tokens': 8,
            'completion_tokens': 30,
            'total_tokens': 38,
          },
        };
        final response = TranscriptionResponse.fromJson(json);
        expect(response.id, 'trans-789');
        expect(response.object, 'transcription');
        expect(response.text, 'Complete transcription');
        expect(response.language, 'de');
        expect(response.duration, 15.5);
        expect(response.segments, hasLength(1));
        expect(response.segments!.first.text, 'Complete transcription');
        expect(response.words, hasLength(2));
        expect(response.words!.first.word, 'Complete');
        expect(response.usage?.totalTokens, 38);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'text': 'Minimal response',
          'object': 'transcription',
        };
        final response = TranscriptionResponse.fromJson(json);
        expect(response.id, isNull);
        expect(response.language, isNull);
        expect(response.duration, isNull);
        expect(response.segments, isNull);
        expect(response.words, isNull);
        expect(response.usage, isNull);
      });

      test('handles integer duration', () {
        final json = <String, dynamic>{
          'text': 'Integer duration',
          'duration': 20,
        };
        final response = TranscriptionResponse.fromJson(json);
        expect(response.duration, 20.0);
      });

      test('handles empty text', () {
        final json = <String, dynamic>{};
        final response = TranscriptionResponse.fromJson(json);
        expect(response.text, '');
      });

      test('handles null text', () {
        final json = <String, dynamic>{'text': null};
        final response = TranscriptionResponse.fromJson(json);
        expect(response.text, '');
      });
    });

    group('equality', () {
      test('equals with same text', () {
        const response1 = TranscriptionResponse(text: 'Same text');
        const response2 = TranscriptionResponse(text: 'Same text');
        expect(response1, equals(response2));
        expect(response1.hashCode, response2.hashCode);
      });

      test('not equals with different text', () {
        const response1 = TranscriptionResponse(text: 'Text A');
        const response2 = TranscriptionResponse(text: 'Text B');
        expect(response1, isNot(equals(response2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const response = TranscriptionResponse(
          text: 'Hello world',
          language: 'en',
        );
        expect(
          response.toString(),
          'TranscriptionResponse(text: 11 chars, language: en)',
        );
      });

      test('handles null language', () {
        const response = TranscriptionResponse(text: 'No language');
        expect(
          response.toString(),
          'TranscriptionResponse(text: 11 chars, language: null)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = TranscriptionResponse(
          id: 'trans-roundtrip',
          object: 'transcription',
          text: 'Round-trip test transcription',
          language: 'es',
          duration: 25.0,
          segments: [
            TranscriptionSegment(
              id: 0,
              start: 0.0,
              end: 12.5,
              text: 'First half',
            ),
            TranscriptionSegment(
              id: 1,
              start: 12.5,
              end: 25.0,
              text: 'Second half',
            ),
          ],
          words: [
            TranscriptionWord(word: 'Round-trip', start: 0.0, end: 0.5),
            TranscriptionWord(word: 'test', start: 0.5, end: 1.0),
          ],
          usage: UsageInfo(
            promptTokens: 15,
            completionTokens: 100,
            totalTokens: 115,
          ),
        );
        final json = original.toJson();
        final restored = TranscriptionResponse.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.object, original.object);
        expect(restored.text, original.text);
        expect(restored.language, original.language);
        expect(restored.duration, original.duration);
        expect(restored.segments?.length, original.segments?.length);
        expect(restored.words?.length, original.words?.length);
        expect(restored.usage?.totalTokens, original.usage?.totalTokens);
      });
    });

    group('multiple segments and words', () {
      test('handles multiple segments', () {
        final json = <String, dynamic>{
          'text': 'First segment. Second segment. Third segment.',
          'segments': [
            {'id': 0, 'start': 0.0, 'end': 5.0, 'text': 'First segment.'},
            {'id': 1, 'start': 5.0, 'end': 10.0, 'text': 'Second segment.'},
            {'id': 2, 'start': 10.0, 'end': 15.0, 'text': 'Third segment.'},
          ],
        };
        final response = TranscriptionResponse.fromJson(json);
        expect(response.segments, hasLength(3));
        expect(response.segments![0].text, 'First segment.');
        expect(response.segments![1].text, 'Second segment.');
        expect(response.segments![2].text, 'Third segment.');
      });

      test('handles many words', () {
        final words = List<Map<String, dynamic>>.generate(
          10,
          (i) => {'word': 'word$i', 'start': i.toDouble(), 'end': (i + 0.5)},
        );
        final json = <String, dynamic>{
          'text': 'word0 word1 word2 word3 word4 word5 word6 word7 word8 word9',
          'words': words,
        };
        final response = TranscriptionResponse.fromJson(json);
        expect(response.words, hasLength(10));
        for (var i = 0; i < 10; i++) {
          expect(response.words![i].word, 'word$i');
          expect(response.words![i].start, i.toDouble());
        }
      });
    });
  });
}
