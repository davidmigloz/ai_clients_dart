import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrImage', () {
    group('fromJson', () {
      test('parses minimal image', () {
        final json = {'id': 'img-123'};

        final image = OcrImage.fromJson(json);

        expect(image.id, 'img-123');
        expect(image.boundingBox, isNull);
        expect(image.imageBase64, isNull);
        expect(image.format, isNull);
      });

      test('parses full image', () {
        final json = {
          'id': 'img-456',
          'bounding_box': [10.0, 20.0, 100.0, 150.0],
          'image_base64': 'iVBORw0KGgoAAAANSU...',
          'format': 'png',
        };

        final image = OcrImage.fromJson(json);

        expect(image.id, 'img-456');
        expect(image.boundingBox, [10.0, 20.0, 100.0, 150.0]);
        expect(image.imageBase64, 'iVBORw0KGgoAAAANSU...');
        expect(image.format, 'png');
      });
    });

    group('toJson', () {
      test('serializes minimal image', () {
        const image = OcrImage(id: 'img-minimal');

        final json = image.toJson();

        expect(json['id'], 'img-minimal');
        expect(json.containsKey('bounding_box'), isFalse);
        expect(json.containsKey('image_base64'), isFalse);
        expect(json.containsKey('format'), isFalse);
      });

      test('serializes full image', () {
        const image = OcrImage(
          id: 'img-full',
          boundingBox: [0.0, 0.0, 50.0, 50.0],
          imageBase64: 'base64data',
          format: 'jpeg',
        );

        final json = image.toJson();

        expect(json['id'], 'img-full');
        expect(json['bounding_box'], [0.0, 0.0, 50.0, 50.0]);
        expect(json['image_base64'], 'base64data');
        expect(json['format'], 'jpeg');
      });
    });

    group('equality', () {
      test('images with same id are equal', () {
        const image1 = OcrImage(id: 'img-same');
        const image2 = OcrImage(id: 'img-same', format: 'png');

        expect(image1, equals(image2));
        expect(image1.hashCode, equals(image2.hashCode));
      });

      test('images with different id are not equal', () {
        const image1 = OcrImage(id: 'img-1');
        const image2 = OcrImage(id: 'img-2');

        expect(image1, isNot(equals(image2)));
      });
    });

    test('toString returns readable representation', () {
      const image = OcrImage(id: 'img-test-123');

      expect(image.toString(), contains('img-test-123'));
    });
  });
}
