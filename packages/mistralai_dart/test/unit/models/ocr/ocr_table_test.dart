import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OcrTable', () {
    group('fromJson', () {
      test('parses required fields', () {
        final json = {
          'id': 'table-1',
          'content': '| A | B |\n|---|---|\n| 1 | 2 |',
          'format': 'markdown',
        };

        final table = OcrTable.fromJson(json);

        expect(table.id, 'table-1');
        expect(table.content, '| A | B |\n|---|---|\n| 1 | 2 |');
        expect(table.format, OcrTableFormat.markdown);
      });

      test('parses html format', () {
        final json = {
          'id': 'table-2',
          'content': '<table><tr><td>A</td></tr></table>',
          'format': 'html',
        };

        final table = OcrTable.fromJson(json);

        expect(table.format, OcrTableFormat.html);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const table = OcrTable(
          id: 'table-1',
          content: '| A | B |',
          format: OcrTableFormat.markdown,
        );

        final json = table.toJson();

        expect(json['id'], 'table-1');
        expect(json['content'], '| A | B |');
        expect(json['format'], 'markdown');
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = OcrTable(
          id: 'table-1',
          content: '| Col |\n|---|\n| Val |',
          format: OcrTableFormat.markdown,
        );

        final roundTripped = OcrTable.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        const original = OcrTable(
          id: 'table-1',
          content: 'old',
          format: OcrTableFormat.markdown,
        );

        final copy = original.copyWith(
          content: 'new',
          format: OcrTableFormat.html,
        );

        expect(copy.id, 'table-1');
        expect(copy.content, 'new');
        expect(copy.format, OcrTableFormat.html);
      });

      test('preserves values when not specified', () {
        const original = OcrTable(
          id: 'table-1',
          content: 'content',
          format: OcrTableFormat.markdown,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = OcrTable(
          id: 'table-1',
          content: 'content',
          format: OcrTableFormat.markdown,
        );
        const b = OcrTable(
          id: 'table-1',
          content: 'content',
          format: OcrTableFormat.markdown,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when fields differ', () {
        const a = OcrTable(
          id: 'table-1',
          content: 'content',
          format: OcrTableFormat.markdown,
        );
        const b = OcrTable(
          id: 'table-2',
          content: 'content',
          format: OcrTableFormat.markdown,
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      const table = OcrTable(
        id: 'table-1',
        content: 'This is table content',
        format: OcrTableFormat.markdown,
      );

      final str = table.toString();

      expect(str, contains('table-1'));
      expect(str, contains('markdown'));
      expect(str, contains('chars'));
    });

    group('wordConfidenceScores', () {
      test('omitted when null', () {
        const table = OcrTable(
          id: 't',
          content: 'c',
          format: OcrTableFormat.markdown,
        );

        final json = table.toJson();

        expect(json.containsKey('word_confidence_scores'), isFalse);
      });

      test('parses an empty list', () {
        final table = OcrTable.fromJson(const {
          'id': 't',
          'content': 'c',
          'format': 'markdown',
          'word_confidence_scores': <Map<String, dynamic>>[],
        });

        expect(table.wordConfidenceScores, isEmpty);
      });

      test('round-trips a populated list', () {
        const original = OcrTable(
          id: 't',
          content: '| A |\n|---|',
          format: OcrTableFormat.markdown,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.95, startIndex: 2, text: 'A'),
            OcrConfidenceScore(confidence: 0.5, startIndex: 4, text: '|'),
          ],
        );

        final roundTripped = OcrTable.fromJson(original.toJson());

        expect(roundTripped, equals(original));
        expect(roundTripped.wordConfidenceScores, hasLength(2));
        expect(roundTripped.wordConfidenceScores![1].text, '|');
      });

      test('not equal when scores differ', () {
        const a = OcrTable(
          id: 't',
          content: 'c',
          format: OcrTableFormat.markdown,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'a'),
          ],
        );
        const b = OcrTable(
          id: 't',
          content: 'c',
          format: OcrTableFormat.markdown,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'b'),
          ],
        );

        expect(a, isNot(equals(b)));
      });

      test('copyWith clears with explicit null', () {
        const original = OcrTable(
          id: 't',
          content: 'c',
          format: OcrTableFormat.markdown,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.5, startIndex: 0, text: 'a'),
          ],
        );

        final cleared = original.copyWith(wordConfidenceScores: null);

        expect(cleared.wordConfidenceScores, isNull);
        expect(cleared.id, 't');
      });
    });
  });
}
