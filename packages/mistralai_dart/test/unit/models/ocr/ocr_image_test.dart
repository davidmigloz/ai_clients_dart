import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrImage', () {
    group('fromJson', () {
      test('parses minimal image', () {
        final json = {'id': 'img-123'};

        final image = OcrImage.fromJson(json);

        expect(image.id, 'img-123');
        expect(image.topLeftX, isNull);
        expect(image.topLeftY, isNull);
        expect(image.bottomRightX, isNull);
        expect(image.bottomRightY, isNull);
        expect(image.imageBase64, isNull);
        expect(image.imageAnnotation, isNull);
      });

      test('parses full image', () {
        final json = {
          'id': 'img-456',
          'top_left_x': 10,
          'top_left_y': 20,
          'bottom_right_x': 100,
          'bottom_right_y': 150,
          'image_base64': 'iVBORw0KGgoAAAANSU...',
          'image_annotation': '{"label": "chart"}',
        };

        final image = OcrImage.fromJson(json);

        expect(image.id, 'img-456');
        expect(image.topLeftX, 10);
        expect(image.topLeftY, 20);
        expect(image.bottomRightX, 100);
        expect(image.bottomRightY, 150);
        expect(image.imageBase64, 'iVBORw0KGgoAAAANSU...');
        expect(image.imageAnnotation, '{"label": "chart"}');
      });
    });

    group('toJson', () {
      test('serializes minimal image', () {
        const image = OcrImage(id: 'img-minimal');

        final json = image.toJson();

        expect(json['id'], 'img-minimal');
        expect(json.containsKey('top_left_x'), isFalse);
        expect(json.containsKey('image_base64'), isFalse);
        expect(json.containsKey('image_annotation'), isFalse);
      });

      test('serializes full image', () {
        const image = OcrImage(
          id: 'img-full',
          topLeftX: 0,
          topLeftY: 0,
          bottomRightX: 50,
          bottomRightY: 50,
          imageBase64: 'base64data',
          imageAnnotation: '{"label": "photo"}',
        );

        final json = image.toJson();

        expect(json['id'], 'img-full');
        expect(json['top_left_x'], 0);
        expect(json['top_left_y'], 0);
        expect(json['bottom_right_x'], 50);
        expect(json['bottom_right_y'], 50);
        expect(json['image_base64'], 'base64data');
        expect(json['image_annotation'], '{"label": "photo"}');
      });
    });

    group('equality', () {
      test('images with same fields are equal', () {
        const image1 = OcrImage(id: 'img-same', topLeftX: 10);
        const image2 = OcrImage(id: 'img-same', topLeftX: 10);

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
