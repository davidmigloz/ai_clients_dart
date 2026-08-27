import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ReasoningDetail', () {
    test('round-trips every documented field and future properties', () {
      final json = <String, dynamic>{
        'type': 'reasoning.text',
        'id': 'reasoning-text-1',
        'format': 'anthropic-claude-v1',
        'index': 2,
        'text': 'Let me think.',
        'signature': null,
        'future': {
          'nested': [
            1,
            {'keep': true},
          ],
        },
      };

      final detail = ReasoningDetail.fromJson(json);

      expect(detail.id, 'reasoning-text-1');
      expect(detail.format, 'anthropic-claude-v1');
      expect(detail.index, 2);
      expect(detail.text, 'Let me think.');
      expect(detail.signature, isNull);
      expect(detail.additionalProperties, contains('future'));
      expect(detail.toJson(), equals(json));
      expect(detail.toJson(), containsPair('signature', null));
    });

    test('round-trips summary and encrypted shapes', () {
      final summary = ReasoningDetail.fromJson(const {
        'type': 'reasoning.summary',
        'summary': 'Checked the constraints.',
        'id': 'summary-1',
        'format': 'openai-responses-v1',
        'index': 0,
      });
      final encrypted = ReasoningDetail.fromJson(const {
        'type': 'reasoning.encrypted',
        'data': 'ZW5jcnlwdGVk',
        'id': 'encrypted-1',
        'format': 'anthropic-claude-v1',
        'index': 1,
      });

      expect(summary.summary, 'Checked the constraints.');
      expect(summary.toJson()['summary'], 'Checked the constraints.');
      expect(encrypted.data, 'ZW5jcnlwdGVk');
      expect(encrypted.toJson()['data'], 'ZW5jcnlwdGVk');
    });

    test('keeps the existing const constructor source compatible', () {
      const first = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Legacy summary text',
      );
      const same = ReasoningDetail(
        type: 'reasoning.summary',
        text: 'Legacy summary text',
      );

      expect(first.isSummary, isTrue);
      expect(first.isText, isFalse);
      expect(first.isEncrypted, isFalse);
      expect(first.toJson(), {
        'type': 'reasoning.summary',
        'text': 'Legacy summary text',
      });
      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first.toString(), contains('19 chars'));
    });

    test('programmatic constructor serializes all typed fields', () {
      const detail = ReasoningDetail(
        type: 'reasoning.text',
        id: 'detail-1',
        format: 'anthropic-claude-v1',
        index: 3,
        text: 'Thinking',
        signature: 'sig-1',
      );

      expect(detail.toJson(), {
        'type': 'reasoning.text',
        'id': 'detail-1',
        'format': 'anthropic-claude-v1',
        'index': 3,
        'text': 'Thinking',
        'signature': 'sig-1',
      });
    });

    test('parsed payload is isolated from source and returned JSON', () {
      final source = <String, dynamic>{
        'type': 'reasoning.text',
        'future': {
          'items': [1, 2],
        },
      };
      final detail = ReasoningDetail.fromJson(source);

      (source['future'] as Map<String, dynamic>)['items'] = [3];
      final serialized = detail.toJson();
      ((serialized['future'] as Map<String, dynamic>)['items'] as List).add(4);

      expect(detail.toJson()['future'], {
        'items': [1, 2],
      });
      expect(
        () => detail.additionalProperties['future'] = false,
        throwsUnsupportedError,
      );
    });

    test('rejects reserved additional-property collisions', () {
      expect(
        () => ReasoningDetail.withAdditionalProperties(
          type: 'reasoning.text',
          additionalProperties: const {'signature': 'duplicate'},
        ),
        throwsArgumentError,
      );
    });

    test('equality and hash include complete serialized payload', () {
      final first = ReasoningDetail.fromJson(const {
        'type': 'reasoning.text',
        'signature': null,
        'future': {'value': 1},
      });
      final same = ReasoningDetail.fromJson(const {
        'future': {'value': 1},
        'signature': null,
        'type': 'reasoning.text',
      });
      final missingNull = ReasoningDetail.fromJson(const {
        'type': 'reasoning.text',
        'future': {'value': 1},
      });

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(missingNull));
    });

    test('chat request preserves reasoning details exactly', () {
      final details = [
        ReasoningDetail.fromJson(const {
          'type': 'reasoning.text',
          'text': '',
          'signature': 'sig-1',
          'id': 'detail-1',
          'format': 'anthropic-claude-v1',
          'index': 0,
          'future': {'opaque': true},
        }),
      ];
      final request = ChatCompletionCreateRequest(
        model: 'provider/model',
        messages: [
          AssistantMessage(toolCalls: const [], reasoningDetails: details),
        ],
      );

      final message =
          (request.toJson()['messages'] as List).single as Map<String, dynamic>;
      expect(
        message['reasoning_details'],
        equals(details.map((detail) => detail.toJson()).toList()),
      );
    });

    test('assistant retains an explicitly empty reasoning array', () {
      final message = AssistantMessage.fromJson(const {
        'role': 'assistant',
        'content': null,
        'reasoning_details': <dynamic>[],
      });

      expect(message.hasReasoningContent, isTrue);
      expect(message.reasoningDetails, isEmpty);
      expect(message.toJson(), containsPair('reasoning_details', <dynamic>[]));
    });
  });
}
