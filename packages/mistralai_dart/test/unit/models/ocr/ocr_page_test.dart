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
        expect(page.tables, isEmpty);
        expect(page.header, isNull);
        expect(page.footer, isNull);
        expect(page.hyperlinks, isEmpty);
        expect(page.confidenceScores, isNull);
      });

      test('parses page with images', () {
        final json = {
          'index': 1,
          'markdown': 'Some text with images',
          'images': [
            {'id': 'img-1'},
            {'id': 'img-2', 'top_left_x': 10, 'top_left_y': 20},
          ],
          'dimensions': {'width': 612, 'height': 792, 'dpi': 72},
        };

        final page = OcrPage.fromJson(json);

        expect(page.index, 1);
        expect(page.markdown, 'Some text with images');
        expect(page.images, hasLength(2));
        expect(page.images[0].id, 'img-1');
        expect(page.images[1].id, 'img-2');
        expect(page.images[1].topLeftX, 10);
        expect(page.dimensions, isNotNull);
        expect(page.dimensions!.width, 612);
        expect(page.dimensions!.height, 792);
        expect(page.dimensions!.dpi, 72);
      });

      test('parses page with tables', () {
        final json = {
          'index': 0,
          'markdown': 'Page with tables',
          'tables': [
            {
              'id': 'table-1',
              'content': '| A | B |\n|---|---|\n| 1 | 2 |',
              'format': 'markdown',
            },
          ],
        };

        final page = OcrPage.fromJson(json);

        expect(page.tables, hasLength(1));
        expect(page.tables[0].id, 'table-1');
        expect(page.tables[0].format, OcrTableFormat.markdown);
      });

      test('parses page with header and footer', () {
        final json = {
          'index': 0,
          'markdown': 'Content',
          'header': 'Page Header',
          'footer': 'Page Footer',
        };

        final page = OcrPage.fromJson(json);

        expect(page.header, 'Page Header');
        expect(page.footer, 'Page Footer');
      });

      test('parses page with hyperlinks', () {
        final json = {
          'index': 0,
          'markdown': 'Content with links',
          'hyperlinks': ['https://example.com', 'https://test.com'],
        };

        final page = OcrPage.fromJson(json);

        expect(page.hyperlinks, hasLength(2));
        expect(page.hyperlinks[0], 'https://example.com');
      });

      test('parses page with confidence scores', () {
        final json = {
          'index': 0,
          'markdown': 'Scored content',
          'confidence_scores': {
            'average_page_confidence_score': 0.92,
            'minimum_page_confidence_score': 0.75,
            'word_confidence_scores': [
              {'confidence': 0.95, 'start_index': 0, 'text': 'Scored'},
              {'confidence': 0.89, 'start_index': 7, 'text': 'content'},
            ],
          },
        };

        final page = OcrPage.fromJson(json);

        expect(page.confidenceScores, isNotNull);
        expect(page.confidenceScores!.averagePageConfidenceScore, 0.92);
        expect(page.confidenceScores!.minimumPageConfidenceScore, 0.75);
        expect(page.confidenceScores!.wordConfidenceScores, hasLength(2));
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
        expect(json.containsKey('tables'), isFalse);
        expect(json.containsKey('header'), isFalse);
        expect(json.containsKey('footer'), isFalse);
        expect(json.containsKey('hyperlinks'), isFalse);
        expect(json.containsKey('confidence_scores'), isFalse);
      });

      test('serializes page with images', () {
        const page = OcrPage(
          index: 2,
          markdown: 'Content with images',
          images: [OcrImage(id: 'img-001')],
          dimensions: OcrPageDimensions(width: 800, height: 600, dpi: 72),
        );

        final json = page.toJson();

        expect(json['index'], 2);
        expect(json['images'], hasLength(1));
        final dims = json['dimensions'] as Map<String, dynamic>;
        expect(dims['width'], 800);
        expect(dims['height'], 600);
      });

      test('serializes page with tables', () {
        const page = OcrPage(
          index: 0,
          markdown: 'Content',
          tables: [
            OcrTable(
              id: 'table-1',
              content: '| A |',
              format: OcrTableFormat.markdown,
            ),
          ],
        );

        final json = page.toJson();

        expect(json['tables'], hasLength(1));
        final table = (json['tables'] as List).first as Map<String, dynamic>;
        expect(table['id'], 'table-1');
      });

      test('serializes page with header, footer, hyperlinks', () {
        const page = OcrPage(
          index: 0,
          markdown: 'Content',
          header: 'Header',
          footer: 'Footer',
          hyperlinks: ['https://example.com'],
        );

        final json = page.toJson();

        expect(json['header'], 'Header');
        expect(json['footer'], 'Footer');
        expect(json['hyperlinks'], ['https://example.com']);
      });

      test('serializes page with confidence scores', () {
        const page = OcrPage(
          index: 0,
          markdown: 'Content',
          confidenceScores: OcrPageConfidenceScores(
            averagePageConfidenceScore: 0.90,
            minimumPageConfidenceScore: 0.80,
          ),
        );

        final json = page.toJson();

        expect(json['confidence_scores'], isA<Map<String, dynamic>>());
        final scores = json['confidence_scores'] as Map<String, dynamic>;
        expect(scores['average_page_confidence_score'], 0.90);
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = OcrPage(index: 0, markdown: 'old');

        final copy = original.copyWith(
          markdown: 'new',
          header: 'Header',
          confidenceScores: const OcrPageConfidenceScores(
            averagePageConfidenceScore: 0.9,
            minimumPageConfidenceScore: 0.8,
          ),
        );

        expect(copy.index, 0);
        expect(copy.markdown, 'new');
        expect(copy.header, 'Header');
        expect(copy.confidenceScores, isNotNull);
      });

      test('preserves values when not specified', () {
        const original = OcrPage(
          index: 1,
          markdown: 'text',
          header: 'H',
          footer: 'F',
          hyperlinks: ['link'],
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('pages with same fields are equal', () {
        const page1 = OcrPage(index: 0, markdown: 'text', header: 'H');
        const page2 = OcrPage(index: 0, markdown: 'text', header: 'H');

        expect(page1, equals(page2));
        expect(page1.hashCode, equals(page2.hashCode));
      });

      test('pages with different fields are not equal', () {
        const page1 = OcrPage(index: 0, markdown: 'text1');
        const page2 = OcrPage(index: 0, markdown: 'text2');

        expect(page1, isNot(equals(page2)));
      });

      test('pages with different tables are not equal', () {
        const page1 = OcrPage(
          index: 0,
          markdown: 'text',
          tables: [
            OcrTable(id: 'a', content: 'c', format: OcrTableFormat.markdown),
          ],
        );
        const page2 = OcrPage(
          index: 0,
          markdown: 'text',
          tables: [
            OcrTable(id: 'b', content: 'c', format: OcrTableFormat.markdown),
          ],
        );

        expect(page1, isNot(equals(page2)));
      });
    });

    test('toString returns readable representation', () {
      const page = OcrPage(
        index: 5,
        markdown: 'This is a long text that should be truncated in toString',
        tables: [
          OcrTable(id: 't1', content: 'c', format: OcrTableFormat.markdown),
        ],
      );

      expect(page.toString(), contains('index: 5'));
      expect(page.toString(), contains('chars'));
      expect(page.toString(), contains('tables: 1'));
    });
  });
}
