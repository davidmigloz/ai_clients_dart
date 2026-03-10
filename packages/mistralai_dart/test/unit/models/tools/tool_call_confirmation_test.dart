import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolCallConfirmation', () {
    group('constructor', () {
      test('creates with required fields', () {
        const confirmation = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        expect(confirmation.toolCallId, 'call_123');
        expect(confirmation.confirmation, 'allow');
      });

      test('creates with allow named constructor', () {
        const confirmation = ToolCallConfirmation.allow(toolCallId: 'call_456');
        expect(confirmation.toolCallId, 'call_456');
        expect(confirmation.confirmation, 'allow');
      });

      test('creates with deny named constructor', () {
        const confirmation = ToolCallConfirmation.deny(toolCallId: 'call_789');
        expect(confirmation.toolCallId, 'call_789');
        expect(confirmation.confirmation, 'deny');
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const confirmation = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        final json = confirmation.toJson();
        expect(json['tool_call_id'], 'call_123');
        expect(json['confirmation'], 'allow');
      });

      test('serializes allow confirmation', () {
        const confirmation = ToolCallConfirmation.allow(toolCallId: 'call_456');
        final json = confirmation.toJson();
        expect(json['tool_call_id'], 'call_456');
        expect(json['confirmation'], 'allow');
      });

      test('serializes deny confirmation', () {
        const confirmation = ToolCallConfirmation.deny(toolCallId: 'call_789');
        final json = confirmation.toJson();
        expect(json['tool_call_id'], 'call_789');
        expect(json['confirmation'], 'deny');
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'tool_call_id': 'call_123',
          'confirmation': 'allow',
        };
        final confirmation = ToolCallConfirmation.fromJson(json);
        expect(confirmation.toolCallId, 'call_123');
        expect(confirmation.confirmation, 'allow');
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final confirmation = ToolCallConfirmation.fromJson(json);
        expect(confirmation.toolCallId, '');
        expect(confirmation.confirmation, 'deny');
      });

      test('handles missing tool_call_id', () {
        final json = <String, dynamic>{'confirmation': 'allow'};
        final confirmation = ToolCallConfirmation.fromJson(json);
        expect(confirmation.toolCallId, '');
        expect(confirmation.confirmation, 'allow');
      });

      test('handles missing confirmation', () {
        final json = <String, dynamic>{'tool_call_id': 'call_123'};
        final confirmation = ToolCallConfirmation.fromJson(json);
        expect(confirmation.toolCallId, 'call_123');
        expect(confirmation.confirmation, 'deny');
      });
    });

    group('equality', () {
      test('equals with same values', () {
        const c1 = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        const c2 = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('allow constructor equals explicit allow', () {
        const c1 = ToolCallConfirmation.allow(toolCallId: 'call_123');
        const c2 = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('deny constructor equals explicit deny', () {
        const c1 = ToolCallConfirmation.deny(toolCallId: 'call_123');
        const c2 = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'deny',
        );
        expect(c1, equals(c2));
        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('not equals with different tool call id', () {
        const c1 = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        const c2 = ToolCallConfirmation(
          toolCallId: 'call_456',
          confirmation: 'allow',
        );
        expect(c1, isNot(equals(c2)));
      });

      test('not equals with different confirmation', () {
        const c1 = ToolCallConfirmation.allow(toolCallId: 'call_123');
        const c2 = ToolCallConfirmation.deny(toolCallId: 'call_123');
        expect(c1, isNot(equals(c2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const confirmation = ToolCallConfirmation(
          toolCallId: 'call_123',
          confirmation: 'allow',
        );
        final str = confirmation.toString();
        expect(str, contains('ToolCallConfirmation'));
        expect(str, contains('call_123'));
        expect(str, contains('allow'));
      });
    });

    group('round-trip serialization', () {
      test('preserves allow confirmation through JSON round-trip', () {
        const original = ToolCallConfirmation.allow(toolCallId: 'call_123');
        final json = original.toJson();
        final restored = ToolCallConfirmation.fromJson(json);
        expect(restored, equals(original));
      });

      test('preserves deny confirmation through JSON round-trip', () {
        const original = ToolCallConfirmation.deny(toolCallId: 'call_456');
        final json = original.toJson();
        final restored = ToolCallConfirmation.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
