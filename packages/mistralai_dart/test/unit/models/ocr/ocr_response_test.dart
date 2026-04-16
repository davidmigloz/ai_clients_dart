import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrResponse', () {
    group('fromJson', () {
      test('parses minimal response', () {
        final json = {
          'model': 'mistral-ocr-latest',
          'pages': <dynamic>[],
          'usage_info': {'pages_processed': 0},
        };

        final response = OcrResponse.fromJson(json);

        expect(response.model, 'mistral-ocr-latest');
        expect(response.pages, isEmpty);
        expect(response.usageInfo, isNotNull);
        expect(response.documentAnnotation, isNull);
      });

      test('parses full response', () {
        final json = {
          'model': 'mistral-ocr-latest',
          'pages': [
            {
              'index': 0,
              'markdown': '# Page 1\n\nSome content.',
              'images': [
                {'id': 'img-1', 'top_left_x': 0, 'top_left_y': 0},
              ],
            },
            {'index': 1, 'markdown': '# Page 2\n\nMore content.'},
          ],
          'usage_info': {'pages_processed': 2, 'doc_size_bytes': 102400},
          'document_annotation': '{"type": "report"}',
        };

        final response = OcrResponse.fromJson(json);

        expect(response.model, 'mistral-ocr-latest');
        expect(response.pages, hasLength(2));
        expect(response.pages[0].index, 0);
        expect(response.pages[0].markdown, contains('Page 1'));
        expect(response.pages[0].images, hasLength(1));
        expect(response.pages[1].index, 1);
        expect(response.usageInfo, isNotNull);
        expect(response.usageInfo!.pagesProcessed, 2);
        expect(response.usageInfo!.docSizeBytes, 102400);
        expect(response.documentAnnotation, '{"type": "report"}');
      });

      test('parses response with document_annotation', () {
        final json = {
          'model': 'mistral-ocr-latest',
          'pages': <dynamic>[],
          'usage_info': {'pages_processed': 1},
          'document_annotation': '{"title": "Invoice", "total": 42.0}',
        };

        final response = OcrResponse.fromJson(json);

        expect(response.documentAnnotation, isNotNull);
        expect(response.documentAnnotation, contains('Invoice'));
      });
    });

    group('toJson', () {
      test('serializes response', () {
        const response = OcrResponse(
          model: 'mistral-ocr-latest',
          pages: [OcrPage(index: 0, markdown: '# Title\n\nParagraph text.')],
          usageInfo: OcrUsageInfo(pagesProcessed: 1),
        );

        final json = response.toJson();

        expect(json['model'], 'mistral-ocr-latest');
        expect(json['pages'], hasLength(1));
        expect(json['usage_info'], isA<Map<String, dynamic>>());
      });

      test('omits null fields', () {
        const response = OcrResponse(model: 'mistral-ocr-latest', pages: []);

        final json = response.toJson();

        expect(json.containsKey('usage_info'), isFalse);
        expect(json.containsKey('document_annotation'), isFalse);
      });
    });

    group('helper methods', () {
      test('text concatenates all page markdown', () {
        const response = OcrResponse(
          model: 'mistral-ocr-latest',
          pages: [
            OcrPage(index: 0, markdown: 'Page 1 content'),
            OcrPage(index: 1, markdown: 'Page 2 content'),
            OcrPage(index: 2, markdown: 'Page 3 content'),
          ],
        );

        final text = response.text;

        expect(text, contains('Page 1 content'));
        expect(text, contains('Page 2 content'));
        expect(text, contains('Page 3 content'));
        expect(text, 'Page 1 content\n\nPage 2 content\n\nPage 3 content');
      });

      test('getPageText returns specific page content', () {
        const response = OcrResponse(
          model: 'mistral-ocr-latest',
          pages: [
            OcrPage(index: 0, markdown: 'First page'),
            OcrPage(index: 2, markdown: 'Third page'),
          ],
        );

        expect(response.getPageText(0), 'First page');
        expect(response.getPageText(2), 'Third page');
        expect(response.getPageText(1), isNull);
      });
    });

    group('equality', () {
      test('responses with same fields are equal', () {
        const response1 = OcrResponse(
          model: 'mistral-ocr-latest',
          pages: [OcrPage(index: 0, markdown: 'text')],
        );
        const response2 = OcrResponse(
          model: 'mistral-ocr-latest',
          pages: [OcrPage(index: 0, markdown: 'text')],
        );

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      test('responses with different models are not equal', () {
        const response1 = OcrResponse(model: 'model-1', pages: []);
        const response2 = OcrResponse(model: 'model-2', pages: []);

        expect(response1, isNot(equals(response2)));
      });
    });

    test('toString returns readable representation', () {
      const response = OcrResponse(
        model: 'mistral-ocr-latest',
        pages: [
          OcrPage(index: 0, markdown: 'content'),
          OcrPage(index: 1, markdown: 'more'),
        ],
      );

      expect(response.toString(), contains('mistral-ocr-latest'));
      expect(response.toString(), contains('pages: 2'));
    });
  });
}
