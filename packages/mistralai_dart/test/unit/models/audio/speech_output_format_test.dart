import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpeechOutputFormat', () {
    test('has expected values with correct string representations', () {
      expect(SpeechOutputFormat.pcm.value, 'pcm');
      expect(SpeechOutputFormat.wav.value, 'wav');
      expect(SpeechOutputFormat.mp3.value, 'mp3');
      expect(SpeechOutputFormat.flac.value, 'flac');
      expect(SpeechOutputFormat.opus.value, 'opus');
    });

    test('fromString returns correct enum for each valid value', () {
      expect(SpeechOutputFormat.fromString('pcm'), SpeechOutputFormat.pcm);
      expect(SpeechOutputFormat.fromString('wav'), SpeechOutputFormat.wav);
      expect(SpeechOutputFormat.fromString('mp3'), SpeechOutputFormat.mp3);
      expect(SpeechOutputFormat.fromString('flac'), SpeechOutputFormat.flac);
      expect(SpeechOutputFormat.fromString('opus'), SpeechOutputFormat.opus);
    });

    test('fromString returns null for null input', () {
      expect(SpeechOutputFormat.fromString(null), isNull);
    });

    test('fromString returns null for unknown value', () {
      expect(SpeechOutputFormat.fromString('aac'), isNull);
      expect(SpeechOutputFormat.fromString('unknown'), isNull);
    });

    test('value round-trips through fromString', () {
      for (final format in SpeechOutputFormat.values) {
        expect(SpeechOutputFormat.fromString(format.value), format);
      }
    });
  });
}
