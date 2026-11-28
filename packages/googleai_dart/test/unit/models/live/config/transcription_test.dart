import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('copies a Live transcription word and clears explicit nulls', () {
    const word = LiveTranscriptionWord(
      word: 'hello',
      startOffset: '1.000000001s',
      endOffset: '1.820s',
    );
    final copy = word.copyWith(word: 'hello!', endOffset: null);
    expect(copy.toJson(), {'word': 'hello!', 'startOffset': '1.000000001s'});
    expect(word.copyWith().toJson(), word.toJson());
    expect(word.copyWith(word: null, startOffset: null).toJson(), {
      'endOffset': '1.820s',
    });
  });

  group('Transcription', () {
    test('round-trips SDK annotations including exact protobuf offsets', () {
      const json = {
        'text': 'A word',
        'finished': true,
        'languageCode': 'en-US',
        'speakerLabel': 'spk_1',
        'words': [
          {'word': 'A', 'startOffset': '0.015000001s', 'endOffset': '0.078s'},
          {'word': 'word', 'startOffset': '0.080s', 'endOffset': '0.190s'},
        ],
        'startOffset': '0.015000001s',
        'endOffset': '0.190s',
      };
      final restored = Transcription.fromJson(json);
      expect(restored.finished, isTrue);
      expect(restored.speakerLabel, 'spk_1');
      expect(restored.languageCode, 'en-US');
      expect(restored.startOffset, '0.015000001s');
      expect(restored.words?.first, isA<LiveTranscriptionWord>());
      expect(restored.words?.first.word, 'A');
      expect(restored.words?.first.startOffset, '0.015000001s');
      expect(restored.words?.last.endOffset, '0.190s');
      expect(restored.toJson(), json);
      expect(
        restored.copyWith(words: null).toJson(),
        {...json}..remove('words'),
      );
    });

    test('preserves a finished result with omitted text', () {
      final restored = Transcription.fromJson({'finished': true});
      expect(restored.text, isNull);
      expect(restored.toJson(), {'finished': true});
    });

    group('fromJson', () {
      test('creates Transcription with text', () {
        final json = {'text': 'Hello, world!'};
        final transcription = Transcription.fromJson(json);

        expect(transcription.text, 'Hello, world!');
      });

      test('creates Transcription with empty text', () {
        final json = {'text': ''};
        final transcription = Transcription.fromJson(json);

        expect(transcription.text, '');
      });

      test('creates Transcription with minimal fields', () {
        final json = <String, dynamic>{};
        final transcription = Transcription.fromJson(json);

        expect(transcription.text, isNull);
      });
    });

    group('toJson', () {
      test('includes text when set', () {
        const transcription = Transcription(text: 'Hello there');
        final json = transcription.toJson();

        expect(json['text'], 'Hello there');
      });

      test('includes empty text', () {
        const transcription = Transcription(text: '');
        final json = transcription.toJson();

        expect(json['text'], '');
      });

      test('omits null text', () {
        const transcription = Transcription();
        final json = transcription.toJson();

        expect(json, isEmpty);
      });
    });

    test('round-trip conversion preserves data', () {
      const original = Transcription(text: 'Test transcription text');
      final json = original.toJson();
      final restored = Transcription.fromJson(json);

      expect(restored.text, original.text);
    });

    test('round-trip with special characters', () {
      const original = Transcription(
        text: 'Hello! How are you? This has "quotes" and \'apostrophes\'.',
      );
      final json = original.toJson();
      final restored = Transcription.fromJson(json);

      expect(restored.text, original.text);
    });

    test('round-trip with unicode', () {
      const original = Transcription(text: 'Hello 世界 🌍');
      final json = original.toJson();
      final restored = Transcription.fromJson(json);

      expect(restored.text, original.text);
    });

    test('toString includes text', () {
      const transcription = Transcription(text: 'Hello');
      final str = transcription.toString();

      expect(str, contains('Transcription'));
      expect(str, contains('text'));
      expect(str, contains('Hello'));
    });

    test('toString with null text', () {
      const transcription = Transcription();
      final str = transcription.toString();

      expect(str, contains('Transcription'));
      expect(str, contains('null'));
    });
  });
}
