import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DreamUsage', () {
    test('fromJson/toJson round-trip', () {
      const json = {
        'input_tokens': 100,
        'output_tokens': 50,
        'cache_read_input_tokens': 10,
        'cache_creation_input_tokens': 5,
      };
      final usage = DreamUsage.fromJson(json);
      expect(usage.inputTokens, 100);
      expect(usage.outputTokens, 50);
      expect(usage.cacheReadInputTokens, 10);
      expect(usage.cacheCreationInputTokens, 5);
      expect(usage.toJson(), json);
    });

    test('copyWith replaces values', () {
      const usage = DreamUsage(
        inputTokens: 1,
        outputTokens: 2,
        cacheReadInputTokens: 3,
        cacheCreationInputTokens: 4,
      );
      final updated = usage.copyWith(outputTokens: 20);
      expect(updated.inputTokens, 1);
      expect(updated.outputTokens, 20);
    });

    test('equality and hashCode', () {
      const a = DreamUsage(
        inputTokens: 1,
        outputTokens: 2,
        cacheReadInputTokens: 3,
        cacheCreationInputTokens: 4,
      );
      const b = DreamUsage(
        inputTokens: 1,
        outputTokens: 2,
        cacheReadInputTokens: 3,
        cacheCreationInputTokens: 4,
      );
      const c = DreamUsage(
        inputTokens: 9,
        outputTokens: 2,
        cacheReadInputTokens: 3,
        cacheCreationInputTokens: 4,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes all fields', () {
      const usage = DreamUsage(
        inputTokens: 1,
        outputTokens: 2,
        cacheReadInputTokens: 3,
        cacheCreationInputTokens: 4,
      );
      final str = usage.toString();
      expect(str, contains('inputTokens: 1'));
      expect(str, contains('outputTokens: 2'));
      expect(str, contains('cacheReadInputTokens: 3'));
      expect(str, contains('cacheCreationInputTokens: 4'));
    });
  });
}
