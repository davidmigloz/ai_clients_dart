import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ReasoningInputItem', () {
    test('fromJson parses all fields', () {
      final json = {
        'type': 'reasoning',
        'id': 'rs_001',
        'summary': [
          {'type': 'summary_text', 'text': 'The model reasoned about X.'},
          {'type': 'summary_text', 'text': 'It concluded Y.'},
        ],
        'encrypted_content': 'enc_abc123',
      };

      final item = ReasoningInputItem.fromJson(json);

      expect(item.id, 'rs_001');
      expect(item.summary, hasLength(2));
      expect(item.summary[0].text, 'The model reasoned about X.');
      expect(item.summary[1].text, 'It concluded Y.');
      expect(item.encryptedContent, 'enc_abc123');
    });

    test('fromJson works without optional fields', () {
      final json = {
        'type': 'reasoning',
        'summary': [
          {'type': 'summary_text', 'text': 'Summary text.'},
        ],
      };

      final item = ReasoningInputItem.fromJson(json);

      expect(item.id, isNull);
      expect(item.summary, hasLength(1));
      expect(item.summary[0].text, 'Summary text.');
      expect(item.encryptedContent, isNull);
    });

    test('toJson produces correct output with all fields', () {
      const item = ReasoningInputItem(
        id: 'rs_001',
        summary: [ReasoningSummaryContent(text: 'Summary.')],
        encryptedContent: 'enc_xyz',
      );

      final json = item.toJson();

      expect(json['type'], 'reasoning');
      expect(json['id'], 'rs_001');
      expect(json['summary'], hasLength(1));
      expect((json['summary'] as List)[0], {
        'type': 'summary_text',
        'text': 'Summary.',
      });
      expect(json['encrypted_content'], 'enc_xyz');
    });

    test('toJson omits optional null fields', () {
      const item = ReasoningInputItem(
        summary: [ReasoningSummaryContent(text: 'Summary.')],
      );

      final json = item.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('encrypted_content'), isFalse);
    });

    test('round-trip serialization', () {
      final original = {
        'type': 'reasoning',
        'id': 'rs_002',
        'summary': [
          {'type': 'summary_text', 'text': 'Reasoning summary.'},
        ],
        'encrypted_content': 'enc_data',
      };

      final item = ReasoningInputItem.fromJson(original);
      final roundTripped = item.toJson();

      expect(roundTripped, original);
    });

    test('Item.fromJson dispatches reasoning type to ReasoningInputItem', () {
      final json = {
        'type': 'reasoning',
        'summary': [
          {'type': 'summary_text', 'text': 'Test.'},
        ],
      };

      final item = Item.fromJson(json);

      expect(item, isA<ReasoningInputItem>());
      expect((item as ReasoningInputItem).summary[0].text, 'Test.');
    });

    test('equality', () {
      const a = ReasoningInputItem(
        id: 'rs_001',
        summary: [ReasoningSummaryContent(text: 'A')],
        encryptedContent: 'enc',
      );
      const b = ReasoningInputItem(
        id: 'rs_001',
        summary: [ReasoningSummaryContent(text: 'A')],
        encryptedContent: 'enc',
      );
      const c = ReasoningInputItem(
        id: 'rs_002',
        summary: [ReasoningSummaryContent(text: 'A')],
        encryptedContent: 'enc',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
