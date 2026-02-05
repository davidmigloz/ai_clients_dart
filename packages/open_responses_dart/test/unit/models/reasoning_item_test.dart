import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ReasoningItem', () {
    test('equality considers content field', () {
      const a = ReasoningItem(
        id: 'rs_001',
        content: [
          {'type': 'text', 'text': 'A'},
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );
      const b = ReasoningItem(
        id: 'rs_001',
        content: [
          {'type': 'text', 'text': 'B'},
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );
      const c = ReasoningItem(
        id: 'rs_001',
        content: [
          {'type': 'text', 'text': 'A'},
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );

      // Different content should not be equal
      expect(a, isNot(equals(b)));

      // Same content should be equal
      expect(a, equals(c));
      expect(a.hashCode, equals(c.hashCode));
    });

    test('equality handles nested content structures', () {
      const a = ReasoningItem(
        id: 'rs_001',
        content: [
          {
            'type': 'text',
            'nested': {
              'key': 'value',
              'list': [1, 2, 3],
            },
          },
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );
      const b = ReasoningItem(
        id: 'rs_001',
        content: [
          {
            'type': 'text',
            'nested': {
              'key': 'value',
              'list': [1, 2, 3],
            },
          },
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );
      const c = ReasoningItem(
        id: 'rs_001',
        content: [
          {
            'type': 'text',
            'nested': {
              'key': 'different',
              'list': [1, 2, 3],
            },
          },
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );

      // Same nested content should be equal
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      // Different nested content should not be equal
      expect(a, isNot(equals(c)));
    });

    test('equality handles null content', () {
      const a = ReasoningItem(
        id: 'rs_001',
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );
      const b = ReasoningItem(
        id: 'rs_001',
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );
      const c = ReasoningItem(
        id: 'rs_001',
        content: [
          {'type': 'text'},
        ],
        summary: [ReasoningSummaryContent(text: 'Summary')],
      );

      // Both null content should be equal
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      // Null vs non-null content should not be equal
      expect(a, isNot(equals(c)));
    });
  });
}
