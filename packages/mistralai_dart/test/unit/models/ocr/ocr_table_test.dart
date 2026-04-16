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
        expect(table.wordConfidenceScores, isNull);
      });

      test('parses with word confidence scores', () {
        final json = {
          'id': 'table-2',
          'content': '<table><tr><td>A</td></tr></table>',
          'format': 'html',
          'word_confidence_scores': [
            {'confidence': 0.95, 'start_index': 0, 'text': 'A'},
          ],
        };

        final table = OcrTable.fromJson(json);

        expect(table.format, OcrTableFormat.html);
        expect(table.wordConfidenceScores, hasLength(1));
        expect(table.wordConfidenceScores![0].text, 'A');
      });

      test('handles null word_confidence_scores', () {
        final json = {
          'id': 'table-3',
          'content': 'content',
          'format': 'markdown',
          'word_confidence_scores': null,
        };

        final table = OcrTable.fromJson(json);

        expect(table.wordConfidenceScores, isNull);
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
        expect(json.containsKey('word_confidence_scores'), isFalse);
      });

      test('serializes with word scores', () {
        const table = OcrTable(
          id: 'table-1',
          content: 'content',
          format: OcrTableFormat.markdown,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.9, startIndex: 0, text: 'word'),
          ],
        );

        final json = table.toJson();

        expect(json['word_confidence_scores'], hasLength(1));
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        const original = OcrTable(
          id: 'table-1',
          content: '| Col |\n|---|\n| Val |',
          format: OcrTableFormat.markdown,
          wordConfidenceScores: [
            OcrConfidenceScore(confidence: 0.95, startIndex: 0, text: 'Col'),
          ],
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
  });
}
