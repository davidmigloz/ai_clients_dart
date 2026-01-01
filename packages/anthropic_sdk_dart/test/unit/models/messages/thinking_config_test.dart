import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ThinkingConfig', () {
    group('enabled factory', () {
      test('creates ThinkingEnabled with budget', () {
        final config = ThinkingConfig.enabled(budgetTokens: 5000);

        expect(config, isA<ThinkingEnabled>());
        expect((config as ThinkingEnabled).budgetTokens, 5000);
      });
    });

    group('disabled factory', () {
      test('creates ThinkingDisabled', () {
        final config = ThinkingConfig.disabled();

        expect(config, isA<ThinkingDisabled>());
      });
    });

    group('fromJson', () {
      test('parses enabled config', () {
        final json = {'type': 'enabled', 'budget_tokens': 3000};

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingEnabled>());
        expect((config as ThinkingEnabled).budgetTokens, 3000);
      });

      test('parses disabled config', () {
        final json = {'type': 'disabled'};

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingDisabled>());
      });

      test('throws on unknown type', () {
        final json = {'type': 'unknown'};

        expect(
          () => ThinkingConfig.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });

  group('ThinkingEnabled', () {
    test('can be created with budget', () {
      const enabled = ThinkingEnabled(budgetTokens: 10000);

      expect(enabled.budgetTokens, 10000);
    });

    test('fromJson parses correctly', () {
      final json = {'type': 'enabled', 'budget_tokens': 8000};

      final enabled = ThinkingEnabled.fromJson(json);

      expect(enabled.budgetTokens, 8000);
    });

    test('toJson serializes correctly', () {
      const enabled = ThinkingEnabled(budgetTokens: 4000);

      final json = enabled.toJson();

      expect(json['type'], 'enabled');
      expect(json['budget_tokens'], 4000);
    });

    test('copyWith creates modified copy', () {
      const original = ThinkingEnabled(budgetTokens: 5000);

      final modified = original.copyWith(budgetTokens: 7000);

      expect(modified.budgetTokens, 7000);
    });

    test('copyWith with no args keeps original', () {
      const original = ThinkingEnabled(budgetTokens: 5000);

      final copy = original.copyWith();

      expect(copy.budgetTokens, 5000);
    });

    test('equality works correctly', () {
      const e1 = ThinkingEnabled(budgetTokens: 5000);
      const e2 = ThinkingEnabled(budgetTokens: 5000);
      const e3 = ThinkingEnabled(budgetTokens: 3000);

      expect(e1, equals(e2));
      expect(e1.hashCode, e2.hashCode);
      expect(e1, isNot(equals(e3)));
    });

    test('toString includes budget', () {
      const enabled = ThinkingEnabled(budgetTokens: 5000);

      expect(enabled.toString(), contains('5000'));
    });
  });

  group('ThinkingDisabled', () {
    test('can be created', () {
      const disabled = ThinkingDisabled();

      expect(disabled, isA<ThinkingConfig>());
    });

    test('fromJson creates instance', () {
      final json = {'type': 'disabled'};

      final disabled = ThinkingDisabled.fromJson(json);

      expect(disabled, isA<ThinkingDisabled>());
    });

    test('toJson serializes correctly', () {
      const disabled = ThinkingDisabled();

      final json = disabled.toJson();

      expect(json['type'], 'disabled');
      expect(json.length, 1);
    });

    test('all instances are equal', () {
      const d1 = ThinkingDisabled();
      const d2 = ThinkingDisabled();

      expect(d1, equals(d2));
      expect(d1.hashCode, d2.hashCode);
    });

    test('is not equal to ThinkingEnabled', () {
      const disabled = ThinkingDisabled();
      const enabled = ThinkingEnabled(budgetTokens: 5000);

      expect(disabled, isNot(equals(enabled)));
    });
  });
}
