import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IterationUsage', () {
    test('fromJson parses message iteration without model', () {
      final json = {
        'type': 'message',
        'input_tokens': 412,
        'output_tokens': 89,
        'cache_creation_input_tokens': 0,
        'cache_read_input_tokens': 0,
      };
      final usage = IterationUsage.fromJson(json);

      expect(usage.type, 'message');
      expect(usage.inputTokens, 412);
      expect(usage.outputTokens, 89);
      expect(usage.model, isNull);
    });

    test('fromJson parses advisor_message iteration with model', () {
      final json = {
        'type': 'advisor_message',
        'model': 'claude-opus-4-6',
        'input_tokens': 823,
        'output_tokens': 1612,
        'cache_creation_input_tokens': 0,
        'cache_read_input_tokens': 0,
      };
      final usage = IterationUsage.fromJson(json);

      expect(usage.type, 'advisor_message');
      expect(usage.model, 'claude-opus-4-6');
      expect(usage.inputTokens, 823);
      expect(usage.outputTokens, 1612);
    });

    test('toJson includes model when set', () {
      const usage = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-6',
      );
      final json = usage.toJson();

      expect(json['type'], 'advisor_message');
      expect(json['model'], 'claude-opus-4-6');
    });

    test('toJson omits model when null', () {
      const usage = IterationUsage(
        type: 'message',
        inputTokens: 100,
        outputTokens: 200,
      );
      final json = usage.toJson();

      expect(json.containsKey('model'), isFalse);
    });

    test('round-trip advisor_message iteration', () {
      final original = {
        'type': 'advisor_message',
        'model': 'claude-opus-4-6',
        'input_tokens': 823,
        'output_tokens': 1612,
        'cache_creation_input_tokens': 0,
        'cache_read_input_tokens': 0,
      };
      final usage = IterationUsage.fromJson(original);
      expect(usage.toJson(), original);
    });

    test('equality includes model field', () {
      const a = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-6',
      );
      const b = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-6',
      );
      const c = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-sonnet-4-6',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith model field', () {
      const original = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-6',
      );

      final changed = original.copyWith(model: 'claude-sonnet-4-6');
      expect(changed.model, 'claude-sonnet-4-6');

      final cleared = original.copyWith(model: null);
      expect(cleared.model, isNull);
    });
  });

  group('Usage with advisor iterations', () {
    test('parses Usage with mixed iterations array', () {
      final json = {
        'input_tokens': 412,
        'output_tokens': 531,
        'iterations': [
          {
            'type': 'message',
            'input_tokens': 412,
            'output_tokens': 89,
            'cache_creation_input_tokens': 0,
            'cache_read_input_tokens': 0,
          },
          {
            'type': 'advisor_message',
            'model': 'claude-opus-4-6',
            'input_tokens': 823,
            'output_tokens': 1612,
            'cache_creation_input_tokens': 0,
            'cache_read_input_tokens': 0,
          },
          {
            'type': 'message',
            'input_tokens': 1348,
            'output_tokens': 442,
            'cache_creation_input_tokens': 0,
            'cache_read_input_tokens': 412,
          },
        ],
      };
      final usage = Usage.fromJson(json);

      expect(usage.iterations, isNotNull);
      expect(usage.iterations!.length, 3);

      expect(usage.iterations![0].type, 'message');
      expect(usage.iterations![0].model, isNull);

      expect(usage.iterations![1].type, 'advisor_message');
      expect(usage.iterations![1].model, 'claude-opus-4-6');
      expect(usage.iterations![1].inputTokens, 823);

      expect(usage.iterations![2].type, 'message');
      expect(usage.iterations![2].cacheReadInputTokens, 412);
    });
  });
}
