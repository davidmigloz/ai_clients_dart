import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrResponse', () {
    group('fromJson', () {
      test('parses minimal response', () {
        final json = {
          'id': 'ocr-123',
          'model': 'mistral-ocr-latest',
          'pages': <dynamic>[],
        };

        final response = OcrResponse.fromJson(json);

        expect(response.id, 'ocr-123');
        expect(response.object, 'ocr.response');
        expect(response.model, 'mistral-ocr-latest');
        expect(response.pages, isEmpty);
      });

      test('parses full response', () {
        final json = {
          'id': 'ocr-456',
          'object': 'ocr.response',
          'model': 'mistral-ocr-latest',
          'pages': [
            {
              'index': 0,
              'markdown': '# Page 1\n\nSome content.',
              'images': [
                {
                  'id': 'img-1',
                  'bounding_box': [0.0, 0.0, 100.0, 100.0],
                },
              ],
            },
            {'index': 1, 'markdown': '# Page 2\n\nMore content.'},
          ],
          'usage': {
            'prompt_tokens': 100,
            'completion_tokens': 200,
            'total_tokens': 300,
          },
          'total_pages': 5,
          'processed_pages': 2,
          'created_at': '2024-01-15T10:00:00Z',
        };

        final response = OcrResponse.fromJson(json);

        expect(response.id, 'ocr-456');
        expect(response.model, 'mistral-ocr-latest');
        expect(response.pages, hasLength(2));
        expect(response.pages[0].index, 0);
        expect(response.pages[0].markdown, contains('Page 1'));
        expect(response.pages[0].images, hasLength(1));
        expect(response.pages[1].index, 1);
        expect(response.usage, isNotNull);
        expect(response.usage!.totalTokens, 300);
        expect(response.totalPages, 5);
        expect(response.processedPages, 2);
        expect(response.createdAt, isNotNull);
      });
    });

    group('toJson', () {
      test('serializes response', () {
        const response = OcrResponse(
          id: 'ocr-789',
          model: 'mistral-ocr-latest',
          pages: [OcrPage(index: 0, markdown: '# Title\n\nParagraph text.')],
          totalPages: 1,
          processedPages: 1,
        );

        final json = response.toJson();

        expect(json['id'], 'ocr-789');
        expect(json['object'], 'ocr.response');
        expect(json['model'], 'mistral-ocr-latest');
        expect(json['pages'], hasLength(1));
        expect(json['total_pages'], 1);
        expect(json['processed_pages'], 1);
      });

      test('omits null fields', () {
        const response = OcrResponse(
          id: 'ocr-test',
          model: 'mistral-ocr-latest',
          pages: [],
        );

        final json = response.toJson();

        expect(json.containsKey('usage'), isFalse);
        expect(json.containsKey('total_pages'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
      });
    });

    group('helper methods', () {
      test('text concatenates all page markdown', () {
        const response = OcrResponse(
          id: 'ocr-text-test',
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
          id: 'ocr-page-test',
          model: 'mistral-ocr-latest',
          pages: [
            OcrPage(index: 0, markdown: 'First page'),
            OcrPage(index: 2, markdown: 'Third page'), // Non-consecutive
          ],
        );

        expect(response.getPageText(0), 'First page');
        expect(response.getPageText(2), 'Third page');
        expect(response.getPageText(1), isNull); // Not present
      });
    });

    group('equality', () {
      test('responses with same id are equal', () {
        const response1 = OcrResponse(
          id: 'ocr-same',
          model: 'model-1',
          pages: [],
        );
        const response2 = OcrResponse(
          id: 'ocr-same',
          model: 'model-2', // Different but not part of equality
          pages: [OcrPage(index: 0, markdown: 'content')],
        );

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      test('responses with different ids are not equal', () {
        const response1 = OcrResponse(id: 'ocr-1', model: 'model', pages: []);
        const response2 = OcrResponse(id: 'ocr-2', model: 'model', pages: []);

        expect(response1, isNot(equals(response2)));
      });
    });

    test('toString returns readable representation', () {
      const response = OcrResponse(
        id: 'ocr-123',
        model: 'mistral-ocr-latest',
        pages: [
          OcrPage(index: 0, markdown: 'content'),
          OcrPage(index: 1, markdown: 'more'),
        ],
      );

      expect(response.toString(), contains('ocr-123'));
      expect(response.toString(), contains('pages: 2'));
    });
  });
}
