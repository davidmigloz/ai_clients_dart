import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrPage', () {
    group('fromJson', () {
      test('parses minimal page', () {
        final json = {'index': 0, 'markdown': '# Hello World'};

        final page = OcrPage.fromJson(json);

        expect(page.index, 0);
        expect(page.markdown, '# Hello World');
        expect(page.images, isEmpty);
        expect(page.dimensions, isNull);
      });

      test('parses page with images', () {
        final json = {
          'index': 1,
          'markdown': 'Some text with images',
          'images': [
            {'id': 'img-1'},
            {'id': 'img-2', 'format': 'png'},
          ],
          'dimensions': [612.0, 792.0],
        };

        final page = OcrPage.fromJson(json);

        expect(page.index, 1);
        expect(page.markdown, 'Some text with images');
        expect(page.images, hasLength(2));
        expect(page.images[0].id, 'img-1');
        expect(page.images[1].id, 'img-2');
        expect(page.images[1].format, 'png');
        expect(page.dimensions, [612.0, 792.0]);
      });
    });

    group('toJson', () {
      test('serializes minimal page', () {
        const page = OcrPage(index: 0, markdown: '# Title');

        final json = page.toJson();

        expect(json['index'], 0);
        expect(json['markdown'], '# Title');
        expect(json.containsKey('images'), isFalse);
        expect(json.containsKey('dimensions'), isFalse);
      });

      test('serializes page with images', () {
        const page = OcrPage(
          index: 2,
          markdown: 'Content with images',
          images: [OcrImage(id: 'img-001')],
          dimensions: [800.0, 600.0],
        );

        final json = page.toJson();

        expect(json['index'], 2);
        expect(json['images'], hasLength(1));
        expect(json['dimensions'], [800.0, 600.0]);
      });
    });

    group('equality', () {
      test('pages with same index are equal', () {
        const page1 = OcrPage(index: 0, markdown: 'text 1');
        const page2 = OcrPage(index: 0, markdown: 'text 2');

        expect(page1, equals(page2));
        expect(page1.hashCode, equals(page2.hashCode));
      });

      test('pages with different index are not equal', () {
        const page1 = OcrPage(index: 0, markdown: 'same');
        const page2 = OcrPage(index: 1, markdown: 'same');

        expect(page1, isNot(equals(page2)));
      });
    });

    test('toString returns readable representation', () {
      const page = OcrPage(
        index: 5,
        markdown: 'This is a long text that should be truncated in toString',
      );

      expect(page.toString(), contains('index: 5'));
      expect(page.toString(), contains('chars'));
    });
  });
}
