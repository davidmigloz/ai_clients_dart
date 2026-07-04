import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrPages', () {
    group('fromJson', () {
      test('parses a list of integers', () {
        final pages = OcrPages.fromJson(const [0, 1, 2]);

        expect(pages, isA<OcrPagesList>());
        expect((pages as OcrPagesList).values, [0, 1, 2]);
      });

      test('parses a comma-separated string', () {
        final pages = OcrPages.fromJson('0,2-4');

        expect(pages, isA<OcrPagesString>());
        expect((pages as OcrPagesString).value, '0,2-4');
      });

      test('throws FormatException for an unsupported type', () {
        expect(() => OcrPages.fromJson(42), throwsFormatException);
      });

      test('throws FormatException for a non-int list element', () {
        expect(
          () => OcrPages.fromJson(const [0, 'x', 2]),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('list variant returns the raw list', () {
        expect(const OcrPages.list([0, 1]).toJson(), [0, 1]);
      });

      test('string variant returns the raw string', () {
        expect(const OcrPages.string('0-5').toJson(), '0-5');
      });
    });

    group('equality', () {
      test('list variants with the same values are equal', () {
        expect(const OcrPages.list([0, 1]), const OcrPages.list([0, 1]));
        expect(
          const OcrPages.list([0, 1]).hashCode,
          const OcrPages.list([0, 1]).hashCode,
        );
      });

      test('list variants with different values are not equal', () {
        expect(const OcrPages.list([0, 1]), isNot(const OcrPages.list([0, 2])));
      });

      test('string variants with the same value are equal', () {
        expect(const OcrPages.string('0-5'), const OcrPages.string('0-5'));
      });

      test('list and string variants are not equal', () {
        expect(const OcrPages.list([0]), isNot(const OcrPages.string('0')));
      });
    });
  });
}
