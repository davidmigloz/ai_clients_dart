import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ThinkingDelta', () {
    test('round-trips with estimated_tokens', () {
      final json = {
        'type': 'thinking_delta',
        'thinking': 'Let me think...',
        'estimated_tokens': 42,
      };

      final delta = ContentBlockDelta.fromJson(json);
      expect(delta, isA<ThinkingDelta>());
      final thinkingDelta = delta as ThinkingDelta;
      expect(thinkingDelta.thinking, 'Let me think...');
      expect(thinkingDelta.estimatedTokens, 42);
      expect(thinkingDelta.toJson(), json);
    });

    test('round-trips without estimated_tokens', () {
      final json = {'type': 'thinking_delta', 'thinking': 'Let me think...'};

      final delta = ContentBlockDelta.fromJson(json);
      expect(delta, isA<ThinkingDelta>());
      final thinkingDelta = delta as ThinkingDelta;
      expect(thinkingDelta.thinking, 'Let me think...');
      expect(thinkingDelta.estimatedTokens, isNull);
      // estimated_tokens omitted from JSON when null.
      expect(thinkingDelta.toJson(), json);
      expect(thinkingDelta.toJson().containsKey('estimated_tokens'), isFalse);
    });

    test('partial event parses with estimatedTokens == null', () {
      final delta = ContentBlockDelta.fromJson({
        'type': 'thinking_delta',
        'thinking': 'x',
      });
      expect(delta, isA<ThinkingDelta>());
      expect((delta as ThinkingDelta).estimatedTokens, isNull);
    });

    test('copyWith updates estimatedTokens', () {
      const delta = ThinkingDelta('hello', estimatedTokens: 10);

      final updated = delta.copyWith(estimatedTokens: 99);
      expect(updated.thinking, 'hello');
      expect(updated.estimatedTokens, 99);
    });

    test('copyWith preserves estimatedTokens when not provided', () {
      const delta = ThinkingDelta('hello', estimatedTokens: 10);

      final updated = delta.copyWith(thinking: 'world');
      expect(updated.thinking, 'world');
      expect(updated.estimatedTokens, 10);
    });

    test('copyWith can clear estimatedTokens via sentinel', () {
      const delta = ThinkingDelta('hello', estimatedTokens: 10);

      final updated = delta.copyWith(estimatedTokens: null);
      expect(updated.estimatedTokens, isNull);
    });

    test('toString includes estimatedTokens', () {
      const delta = ThinkingDelta('hello', estimatedTokens: 7);
      expect(delta.toString(), contains('estimatedTokens: 7'));
    });

    test('equality and hashCode include estimatedTokens', () {
      const a = ThinkingDelta('hello', estimatedTokens: 5);
      const b = ThinkingDelta('hello', estimatedTokens: 5);
      const c = ThinkingDelta('hello', estimatedTokens: 6);
      const d = ThinkingDelta('hello');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });
  });
}
