import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ThinkingDisplayMode', () {
    test('fromJson parses summarized', () {
      expect(
        ThinkingDisplayMode.fromJson('summarized'),
        ThinkingDisplayMode.summarized,
      );
    });

    test('fromJson parses omitted', () {
      expect(
        ThinkingDisplayMode.fromJson('omitted'),
        ThinkingDisplayMode.omitted,
      );
    });

    test('toJson serializes correctly', () {
      expect(ThinkingDisplayMode.summarized.toJson(), 'summarized');
      expect(ThinkingDisplayMode.omitted.toJson(), 'omitted');
    });
  });

  group('ThinkingConfig', () {
    group('enabled factory', () {
      test('creates ThinkingEnabled with budget', () {
        final config = ThinkingConfig.enabled(budgetTokens: 5000);

        expect(config, isA<ThinkingEnabled>());
        expect((config as ThinkingEnabled).budgetTokens, 5000);
      });

      test('creates ThinkingEnabled with display', () {
        final config = ThinkingConfig.enabled(
          budgetTokens: 5000,
          display: ThinkingDisplayMode.omitted,
        );

        expect(config, isA<ThinkingEnabled>());
        final enabled = config as ThinkingEnabled;
        expect(enabled.budgetTokens, 5000);
        expect(enabled.display, ThinkingDisplayMode.omitted);
      });
    });

    group('disabled factory', () {
      test('creates ThinkingDisabled', () {
        final config = ThinkingConfig.disabled();

        expect(config, isA<ThinkingDisabled>());
      });
    });

    group('adaptive factory', () {
      test('creates ThinkingAdaptive', () {
        final config = ThinkingConfig.adaptive();

        expect(config, isA<ThinkingAdaptive>());
      });

      test('creates ThinkingAdaptive with display', () {
        final config = ThinkingConfig.adaptive(
          display: ThinkingDisplayMode.summarized,
        );

        expect(config, isA<ThinkingAdaptive>());
        expect(
          (config as ThinkingAdaptive).display,
          ThinkingDisplayMode.summarized,
        );
      });
    });

    group('fromJson', () {
      test('parses enabled config', () {
        final json = {'type': 'enabled', 'budget_tokens': 3000};

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingEnabled>());
        expect((config as ThinkingEnabled).budgetTokens, 3000);
      });

      test('parses enabled config with display', () {
        final json = {
          'type': 'enabled',
          'budget_tokens': 3000,
          'display': 'omitted',
        };

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingEnabled>());
        final enabled = config as ThinkingEnabled;
        expect(enabled.budgetTokens, 3000);
        expect(enabled.display, ThinkingDisplayMode.omitted);
      });

      test('parses disabled config', () {
        final json = {'type': 'disabled'};

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingDisabled>());
      });

      test('parses adaptive config', () {
        final json = {'type': 'adaptive'};

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingAdaptive>());
      });

      test('parses adaptive config with display', () {
        final json = {'type': 'adaptive', 'display': 'summarized'};

        final config = ThinkingConfig.fromJson(json);

        expect(config, isA<ThinkingAdaptive>());
        expect(
          (config as ThinkingAdaptive).display,
          ThinkingDisplayMode.summarized,
        );
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
      expect(enabled.display, isNull);
    });

    test('can be created with budget and display', () {
      const enabled = ThinkingEnabled(
        budgetTokens: 10000,
        display: ThinkingDisplayMode.omitted,
      );

      expect(enabled.budgetTokens, 10000);
      expect(enabled.display, ThinkingDisplayMode.omitted);
    });

    test('fromJson parses correctly', () {
      final json = {'type': 'enabled', 'budget_tokens': 8000};

      final enabled = ThinkingEnabled.fromJson(json);

      expect(enabled.budgetTokens, 8000);
      expect(enabled.display, isNull);
    });

    test('fromJson parses with display', () {
      final json = {
        'type': 'enabled',
        'budget_tokens': 8000,
        'display': 'summarized',
      };

      final enabled = ThinkingEnabled.fromJson(json);

      expect(enabled.budgetTokens, 8000);
      expect(enabled.display, ThinkingDisplayMode.summarized);
    });

    test('toJson serializes correctly', () {
      const enabled = ThinkingEnabled(budgetTokens: 4000);

      final json = enabled.toJson();

      expect(json['type'], 'enabled');
      expect(json['budget_tokens'], 4000);
      expect(json.containsKey('display'), isFalse);
    });

    test('toJson serializes with display', () {
      const enabled = ThinkingEnabled(
        budgetTokens: 4000,
        display: ThinkingDisplayMode.omitted,
      );

      final json = enabled.toJson();

      expect(json['type'], 'enabled');
      expect(json['budget_tokens'], 4000);
      expect(json['display'], 'omitted');
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

    test('copyWith can set display', () {
      const original = ThinkingEnabled(budgetTokens: 5000);

      final modified = original.copyWith(
        display: ThinkingDisplayMode.summarized,
      );

      expect(modified.display, ThinkingDisplayMode.summarized);
    });

    test('copyWith can clear display', () {
      const original = ThinkingEnabled(
        budgetTokens: 5000,
        display: ThinkingDisplayMode.omitted,
      );

      final modified = original.copyWith(display: null);

      expect(modified.display, isNull);
    });

    test('equality works correctly', () {
      const e1 = ThinkingEnabled(budgetTokens: 5000);
      const e2 = ThinkingEnabled(budgetTokens: 5000);
      const e3 = ThinkingEnabled(budgetTokens: 3000);
      const e4 = ThinkingEnabled(
        budgetTokens: 5000,
        display: ThinkingDisplayMode.omitted,
      );

      expect(e1, equals(e2));
      expect(e1.hashCode, e2.hashCode);
      expect(e1, isNot(equals(e3)));
      expect(e1, isNot(equals(e4)));
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

  group('ThinkingAdaptive', () {
    test('can be created', () {
      const adaptive = ThinkingAdaptive();

      expect(adaptive, isA<ThinkingConfig>());
      expect(adaptive.display, isNull);
    });

    test('can be created with display', () {
      const adaptive = ThinkingAdaptive(
        display: ThinkingDisplayMode.summarized,
      );

      expect(adaptive.display, ThinkingDisplayMode.summarized);
    });

    test('fromJson creates instance', () {
      final json = {'type': 'adaptive'};

      final adaptive = ThinkingAdaptive.fromJson(json);

      expect(adaptive, isA<ThinkingAdaptive>());
      expect(adaptive.display, isNull);
    });

    test('fromJson with display', () {
      final json = {'type': 'adaptive', 'display': 'omitted'};

      final adaptive = ThinkingAdaptive.fromJson(json);

      expect(adaptive.display, ThinkingDisplayMode.omitted);
    });

    test('toJson serializes correctly', () {
      const adaptive = ThinkingAdaptive();

      final json = adaptive.toJson();

      expect(json['type'], 'adaptive');
      expect(json.containsKey('display'), isFalse);
    });

    test('toJson serializes with display', () {
      const adaptive = ThinkingAdaptive(display: ThinkingDisplayMode.omitted);

      final json = adaptive.toJson();

      expect(json['type'], 'adaptive');
      expect(json['display'], 'omitted');
    });

    test('equality considers display', () {
      const a1 = ThinkingAdaptive();
      const a2 = ThinkingAdaptive();
      const a3 = ThinkingAdaptive(display: ThinkingDisplayMode.omitted);

      expect(a1, equals(a2));
      expect(a1.hashCode, a2.hashCode);
      expect(a1, isNot(equals(a3)));
    });

    test('copyWith can set display', () {
      const original = ThinkingAdaptive();

      final modified = original.copyWith(
        display: ThinkingDisplayMode.summarized,
      );

      expect(modified.display, ThinkingDisplayMode.summarized);
    });

    test('copyWith can clear display', () {
      const original = ThinkingAdaptive(display: ThinkingDisplayMode.omitted);

      final modified = original.copyWith(display: null);

      expect(modified.display, isNull);
    });
  });
}
