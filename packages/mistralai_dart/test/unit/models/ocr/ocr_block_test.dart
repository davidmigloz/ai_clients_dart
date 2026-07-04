import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _block(
  String type, {
  Map<String, dynamic> extra = const {},
}) => {
  'type': type,
  'top_left_x': 10,
  'top_left_y': 20,
  'bottom_right_x': 100,
  'bottom_right_y': 150,
  'content': 'hello',
  ...extra,
};

void main() {
  group('OcrBlock', () {
    group('fromJson dispatch', () {
      const cases = <String, Type>{
        'text': OcrTextBlock,
        'title': OcrTitleBlock,
        'list': OcrListBlock,
        'table': OcrTableBlock,
        'image': OcrImageBlock,
        'equation': OcrEquationBlock,
        'caption': OcrCaptionBlock,
        'code': OcrCodeBlock,
        'references': OcrReferencesBlock,
        'aside_text': OcrAsideTextBlock,
        'header': OcrHeaderBlock,
        'footer': OcrFooterBlock,
        'signature': OcrSignatureBlock,
      };

      for (final entry in cases.entries) {
        final wire = entry.key;
        final type = entry.value;
        test('parses "$wire" into $type', () {
          final extra = wire == 'image'
              ? <String, dynamic>{'image_id': 'img-1'}
              : <String, dynamic>{};
          final block = OcrBlock.fromJson(_block(wire, extra: extra));

          expect(block.runtimeType, type);
          expect(block.type, wire);
        });
      }
    });

    test('parses common bounding box and content fields', () {
      final block = OcrBlock.fromJson(_block('text')) as OcrTextBlock;

      expect(block.topLeftX, 10);
      expect(block.topLeftY, 20);
      expect(block.bottomRightX, 100);
      expect(block.bottomRightY, 150);
      expect(block.content, 'hello');
    });

    test('image block parses required image_id', () {
      final block =
          OcrBlock.fromJson(_block('image', extra: {'image_id': 'img-9'}))
              as OcrImageBlock;

      expect(block.imageId, 'img-9');
    });

    test('table block parses optional table_id', () {
      final withId =
          OcrBlock.fromJson(_block('table', extra: {'table_id': 'tbl-1'}))
              as OcrTableBlock;
      expect(withId.tableId, 'tbl-1');

      final withoutId = OcrBlock.fromJson(_block('table')) as OcrTableBlock;
      expect(withoutId.tableId, isNull);
    });

    group('round-trip', () {
      test('text block', () {
        final json = _block('text');
        expect(OcrBlock.fromJson(json).toJson(), json);
      });

      test('image block includes image_id', () {
        final json = _block('image', extra: {'image_id': 'img-1'});
        expect(OcrBlock.fromJson(json).toJson(), json);
      });

      test('table block omits table_id when absent', () {
        final block = OcrBlock.fromJson(_block('table'));
        expect(block.toJson().containsKey('table_id'), isFalse);
      });
    });

    group('unknown fallback', () {
      test('unrecognized type is preserved as UnknownOcrBlock', () {
        final block = OcrBlock.fromJson(const {
          'type': 'diagram',
          'foo': 'bar',
        });

        expect(block, isA<UnknownOcrBlock>());
        expect(block.type, 'diagram');
      });

      test('preserves the raw JSON through toJson', () {
        final json = {'type': 'diagram', 'foo': 'bar', 'n': 1};
        final block = OcrBlock.fromJson(json);

        expect(block.toJson(), json);
      });

      test('missing type falls back to "unknown"', () {
        final block = OcrBlock.fromJson(const {'foo': 'bar'});

        expect(block, isA<UnknownOcrBlock>());
        expect(block.type, 'unknown');
      });

      test('non-string type falls back to "unknown" without throwing', () {
        final block = OcrBlock.fromJson(const {'type': 123, 'foo': 'bar'});

        expect(block, isA<UnknownOcrBlock>());
        expect(block.type, 'unknown');
        expect(block.toJson(), const {'type': 123, 'foo': 'bar'});
      });
    });

    group('discriminator validation', () {
      test('variant fromJson rejects a mismatched type', () {
        expect(
          () => OcrTextBlock.fromJson(_block('list')),
          throwsFormatException,
        );
      });
    });

    group('required fields fail fast', () {
      test('throws when a bounding box coordinate is missing', () {
        final json = _block('text')..remove('top_left_x');
        expect(() => OcrTextBlock.fromJson(json), throwsFormatException);
      });

      test('throws when content is missing', () {
        final json = _block('text')..remove('content');
        expect(() => OcrTextBlock.fromJson(json), throwsFormatException);
      });

      test('image block throws when image_id is missing', () {
        expect(
          () => OcrImageBlock.fromJson(_block('image')),
          throwsFormatException,
        );
      });
    });

    group('equality and copyWith', () {
      test('equal blocks compare equal', () {
        expect(
          OcrBlock.fromJson(_block('text')),
          OcrBlock.fromJson(_block('text')),
        );
      });

      test('copyWith replaces a field and preserves the rest', () {
        final block = OcrBlock.fromJson(_block('text')) as OcrTextBlock;
        final copy = block.copyWith(content: 'world');

        expect(copy.content, 'world');
        expect(copy.topLeftX, 10);
      });

      test('table copyWith clears tableId with explicit null', () {
        final block = OcrTableBlock.fromJson(
          _block('table', extra: {'table_id': 't1'}),
        );

        expect(block.copyWith(tableId: null).tableId, isNull);
      });
    });
  });
}
