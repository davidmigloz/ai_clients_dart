import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ReasoningDetail', () {
    test('fromJson parses summary type', () {
      final json = {
        'type': 'reasoning.summary',
        'text': 'This is a summary of the reasoning.',
      };

      final detail = ReasoningDetail.fromJson(json);

      expect(detail.type, 'reasoning.summary');
      expect(detail.text, 'This is a summary of the reasoning.');
      expect(detail.data, isNull);
      expect(detail.isSummary, true);
      expect(detail.isText, false);
      expect(detail.isEncrypted, false);
    });

    test('fromJson parses text type', () {
      final json = {
        'type': 'reasoning.text',
        'text': 'Full reasoning text here.',
      };

      final detail = ReasoningDetail.fromJson(json);

      expect(detail.type, 'reasoning.text');
      expect(detail.text, 'Full reasoning text here.');
      expect(detail.isSummary, false);
      expect(detail.isText, true);
      expect(detail.isEncrypted, false);
    });

    test('fromJson parses encrypted type', () {
      final json = {
        'type': 'reasoning.encrypted',
        'data': 'YmFzZTY0ZW5jb2RlZGRhdGE=',
      };

      final detail = ReasoningDetail.fromJson(json);

      expect(detail.type, 'reasoning.encrypted');
      expect(detail.text, isNull);
      expect(detail.data, 'YmFzZTY0ZW5jb2RlZGRhdGE=');
      expect(detail.isSummary, false);
      expect(detail.isText, false);
      expect(detail.isEncrypted, true);
    });

    test('toJson produces correct output', () {
      const detail = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Summary text',
      );

      final json = detail.toJson();

      expect(json['type'], 'reasoning.summary');
      expect(json['text'], 'Summary text');
      expect(json.containsKey('data'), false); // null fields excluded
    });

    test('toJson round-trip', () {
      final original = {
        'type': 'reasoning.text',
        'text': 'Some reasoning content',
      };

      final detail = ReasoningDetail.fromJson(original);
      final json = detail.toJson();

      expect(json['type'], original['type']);
      expect(json['text'], original['text']);
    });

    test('equality works correctly', () {
      const detail1 = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Same text',
      );
      const detail2 = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Same text',
      );
      const detail3 = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Different text',
      );

      expect(detail1, equals(detail2));
      expect(detail1, isNot(equals(detail3)));
    });

    test('hashCode is consistent', () {
      const detail1 = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Test text',
      );
      const detail2 = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Test text',
      );

      expect(detail1.hashCode, equals(detail2.hashCode));
    });

    test('toString produces readable output', () {
      const summaryDetail = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Short',
      );
      const encryptedDetail = ReasoningDetail(
        type: 'reasoning.encrypted',
        data: 'base64data',
      );

      expect(summaryDetail.toString(), contains('reasoning.summary'));
      expect(summaryDetail.toString(), contains('5 chars'));
      expect(encryptedDetail.toString(), contains('reasoning.encrypted'));
    });
  });
}
