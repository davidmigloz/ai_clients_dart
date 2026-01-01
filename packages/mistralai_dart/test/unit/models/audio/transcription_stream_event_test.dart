import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TranscriptionStreamEvent', () {
    group('constructor', () {
      test('creates with required type parameter', () {
        const event = TranscriptionStreamEvent(type: 'text');
        expect(event.type, 'text');
        expect(event.id, isNull);
        expect(event.text, isNull);
        expect(event.segment, isNull);
        expect(event.word, isNull);
        expect(event.isFinal, isNull);
      });

      test('creates with all parameters', () {
        const event = TranscriptionStreamEvent(
          type: 'segment',
          id: 'event-123',
          text: 'Hello',
          segment: TranscriptionSegment(
            id: 0,
            start: 0.0,
            end: 1.0,
            text: 'Hello',
          ),
          word: TranscriptionWord(word: 'Hello', start: 0.0, end: 0.5),
          isFinal: false,
        );
        expect(event.type, 'segment');
        expect(event.id, 'event-123');
        expect(event.text, 'Hello');
        expect(event.segment, isNotNull);
        expect(event.segment!.text, 'Hello');
        expect(event.word, isNotNull);
        expect(event.word!.word, 'Hello');
        expect(event.isFinal, false);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const event = TranscriptionStreamEvent(type: 'text');
        final json = event.toJson();
        expect(json['type'], 'text');
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('text'), isFalse);
        expect(json.containsKey('segment'), isFalse);
        expect(json.containsKey('word'), isFalse);
        expect(json.containsKey('is_final'), isFalse);
      });

      test('serializes all fields', () {
        const event = TranscriptionStreamEvent(
          type: 'word',
          id: 'event-456',
          text: 'World',
          segment: TranscriptionSegment(
            id: 1,
            start: 1.0,
            end: 2.0,
            text: 'World',
          ),
          word: TranscriptionWord(word: 'World', start: 1.0, end: 1.5),
          isFinal: true,
        );
        final json = event.toJson();
        expect(json['type'], 'word');
        expect(json['id'], 'event-456');
        expect(json['text'], 'World');
        expect(json['segment'], isMap);
        expect(json['word'], isMap);
        expect(json['is_final'], true);
      });
    });

    group('fromJson', () {
      test('deserializes minimal event', () {
        final json = <String, dynamic>{'type': 'text'};
        final event = TranscriptionStreamEvent.fromJson(json);
        expect(event.type, 'text');
        expect(event.id, isNull);
        expect(event.text, isNull);
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'type': 'segment',
          'id': 'event-789',
          'text': 'Complete event',
          'segment': {
            'id': 2,
            'start': 2.0,
            'end': 3.0,
            'text': 'Complete event',
          },
          'word': {'word': 'Complete', 'start': 2.0, 'end': 2.5},
          'is_final': false,
        };
        final event = TranscriptionStreamEvent.fromJson(json);
        expect(event.type, 'segment');
        expect(event.id, 'event-789');
        expect(event.text, 'Complete event');
        expect(event.segment, isNotNull);
        expect(event.segment!.id, 2);
        expect(event.word, isNotNull);
        expect(event.word!.word, 'Complete');
        expect(event.isFinal, false);
      });

      test('handles missing type with default', () {
        final json = <String, dynamic>{'text': 'No type'};
        final event = TranscriptionStreamEvent.fromJson(json);
        expect(event.type, 'text');
      });

      test('handles null type with default', () {
        final json = <String, dynamic>{'type': null, 'text': 'Null type'};
        final event = TranscriptionStreamEvent.fromJson(json);
        expect(event.type, 'text');
      });

      test('handles text delta event', () {
        final json = <String, dynamic>{
          'type': 'text_delta',
          'text': ' more text',
        };
        final event = TranscriptionStreamEvent.fromJson(json);
        expect(event.type, 'text_delta');
        expect(event.text, ' more text');
      });

      test('handles final event', () {
        final json = <String, dynamic>{'type': 'done', 'is_final': true};
        final event = TranscriptionStreamEvent.fromJson(json);
        expect(event.type, 'done');
        expect(event.isFinal, true);
      });
    });

    group('equality', () {
      test('equals with same type and text', () {
        const event1 = TranscriptionStreamEvent(type: 'text', text: 'Hello');
        const event2 = TranscriptionStreamEvent(type: 'text', text: 'Hello');
        expect(event1, equals(event2));
        expect(event1.hashCode, event2.hashCode);
      });

      test('not equals with different type', () {
        const event1 = TranscriptionStreamEvent(type: 'text', text: 'Hello');
        const event2 = TranscriptionStreamEvent(type: 'segment', text: 'Hello');
        expect(event1, isNot(equals(event2)));
      });

      test('not equals with different text', () {
        const event1 = TranscriptionStreamEvent(type: 'text', text: 'Hello');
        const event2 = TranscriptionStreamEvent(type: 'text', text: 'World');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const event = TranscriptionStreamEvent(type: 'text', text: 'Hello');
        expect(
          event.toString(),
          'TranscriptionStreamEvent(type: text, text: Hello)',
        );
      });

      test('handles null text', () {
        const event = TranscriptionStreamEvent(type: 'done');
        expect(
          event.toString(),
          'TranscriptionStreamEvent(type: done, text: null)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = TranscriptionStreamEvent(
          type: 'segment',
          id: 'roundtrip-event',
          text: 'Round-trip segment',
          segment: TranscriptionSegment(
            id: 5,
            start: 10.0,
            end: 15.0,
            text: 'Round-trip segment',
          ),
          word: TranscriptionWord(word: 'Round-trip', start: 10.0, end: 11.0),
          isFinal: false,
        );
        final json = original.toJson();
        final restored = TranscriptionStreamEvent.fromJson(json);
        expect(restored.type, original.type);
        expect(restored.id, original.id);
        expect(restored.text, original.text);
        expect(restored.segment?.id, original.segment?.id);
        expect(restored.word?.word, original.word?.word);
        expect(restored.isFinal, original.isFinal);
      });
    });

    group('event types', () {
      test('handles start event', () {
        const event = TranscriptionStreamEvent(
          type: 'start',
          id: 'trans-start',
        );
        expect(event.type, 'start');
        expect(event.id, 'trans-start');
      });

      test('handles word event', () {
        const event = TranscriptionStreamEvent(
          type: 'word',
          word: TranscriptionWord(word: 'test', start: 0.0, end: 0.5),
        );
        expect(event.type, 'word');
        expect(event.word?.word, 'test');
      });

      test('handles segment event', () {
        const event = TranscriptionStreamEvent(
          type: 'segment',
          segment: TranscriptionSegment(
            id: 0,
            start: 0.0,
            end: 5.0,
            text: 'A segment',
          ),
        );
        expect(event.type, 'segment');
        expect(event.segment?.text, 'A segment');
      });

      test('handles end event', () {
        const event = TranscriptionStreamEvent(type: 'end', isFinal: true);
        expect(event.type, 'end');
        expect(event.isFinal, true);
      });
    });

    group('streaming sequence', () {
      test('can represent a streaming sequence', () {
        final events = [
          const TranscriptionStreamEvent(type: 'start', id: 'trans-1'),
          const TranscriptionStreamEvent(type: 'text', text: 'Hello'),
          const TranscriptionStreamEvent(type: 'text', text: ' world'),
          const TranscriptionStreamEvent(
            type: 'word',
            word: TranscriptionWord(word: 'Hello', start: 0.0, end: 0.5),
          ),
          const TranscriptionStreamEvent(
            type: 'word',
            word: TranscriptionWord(word: 'world', start: 0.5, end: 1.0),
          ),
          const TranscriptionStreamEvent(
            type: 'segment',
            segment: TranscriptionSegment(
              id: 0,
              start: 0.0,
              end: 1.0,
              text: 'Hello world',
            ),
          ),
          const TranscriptionStreamEvent(type: 'end', isFinal: true),
        ];

        expect(events, hasLength(7));
        expect(events.first.type, 'start');
        expect(events.last.type, 'end');
        expect(events.last.isFinal, true);

        // Collect all text
        final text = events
            .where((e) => e.type == 'text' && e.text != null)
            .map((e) => e.text!)
            .join();
        expect(text, 'Hello world');

        // Collect all words
        final words = events
            .where((e) => e.type == 'word' && e.word != null)
            .map((e) => e.word!)
            .toList();
        expect(words, hasLength(2));
        expect(words.map((w) => w.word).toList(), ['Hello', 'world']);
      });
    });
  });
}
