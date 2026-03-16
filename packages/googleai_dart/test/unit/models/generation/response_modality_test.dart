import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseModality', () {
    group('responseModalityFromString', () {
      test('parses TEXT', () {
        expect(responseModalityFromString('TEXT'), ResponseModality.text);
      });

      test('parses IMAGE', () {
        expect(responseModalityFromString('IMAGE'), ResponseModality.image);
      });

      test('parses AUDIO', () {
        expect(responseModalityFromString('AUDIO'), ResponseModality.audio);
      });

      test('returns unspecified for unknown value', () {
        expect(
          responseModalityFromString('UNKNOWN'),
          ResponseModality.unspecified,
        );
      });

      test('returns unspecified for null', () {
        expect(responseModalityFromString(null), ResponseModality.unspecified);
      });
    });

    group('responseModalityToString', () {
      test('converts text', () {
        expect(responseModalityToString(ResponseModality.text), 'TEXT');
      });

      test('converts image', () {
        expect(responseModalityToString(ResponseModality.image), 'IMAGE');
      });

      test('converts audio', () {
        expect(responseModalityToString(ResponseModality.audio), 'AUDIO');
      });

      test('converts unspecified', () {
        expect(
          responseModalityToString(ResponseModality.unspecified),
          'MODALITY_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion preserves value', () {
      for (final modality in ResponseModality.values) {
        final str = responseModalityToString(modality);
        final restored = responseModalityFromString(str);
        expect(restored, modality);
      }
    });
  });
}
