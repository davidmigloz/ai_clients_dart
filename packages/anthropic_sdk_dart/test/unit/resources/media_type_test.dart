import 'package:anthropic_sdk_dart/src/resources/media_type.dart';
import 'package:test/test.dart';

void main() {
  group('parseMediaTypeOrOctetStream', () {
    test('parses a simple mime type', () {
      final mediaType = parseMediaTypeOrOctetStream('image/png');
      expect(mediaType.type, 'image');
      expect(mediaType.subtype, 'png');
      expect(mediaType.parameters, isEmpty);
    });

    test('keeps parameters like charset', () {
      final mediaType = parseMediaTypeOrOctetStream(
        'text/plain; charset=utf-8',
      );
      expect(mediaType.type, 'text');
      expect(mediaType.subtype, 'plain');
      expect(mediaType.parameters['charset'], 'utf-8');
    });

    test('falls back to application/octet-stream for garbage input', () {
      final mediaType = parseMediaTypeOrOctetStream('not a mime type!!');
      expect(mediaType.type, 'application');
      expect(mediaType.subtype, 'octet-stream');
    });
  });
}
